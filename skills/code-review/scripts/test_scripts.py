#!/usr/bin/env python3
"""Tests for the review's scripts, with a stand-in for gh: python3 test_scripts.py"""

import json
import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
COLLECT, VALIDATE, RANK, POST = (str(HERE / name) for name in
                                 ("collect_context.sh", "validate_findings.sh", "rank_findings.sh", "post_comments.sh"))

# gh for PR #7 of o/r: reads print every body posted so far, a POST adds its bodies.
FAKE_GH = """#!/usr/bin/env bash
case "$1" in
  pr) echo https://git.example.com/o/r/pull/7 ;;
  api)
    while [ $# -gt 0 ] && [ "$1" != --input ]; do shift; done
    if [ $# -gt 1 ]; then
      python3 -c 'import json, sys; d = json.load(open(sys.argv[1])); print("\\n".join([d["body"], *(c["body"] for c in d["comments"])]))' "$2" >> "$GH_POSTED"
      echo https://git.example.com/o/r/pull/7#review
    else
      cat "$GH_POSTED"
    fi ;;
esac
"""


class ScriptsTest(unittest.TestCase):
    def setUp(self):
        root = Path(tempfile.mkdtemp()).resolve()
        self.addCleanup(shutil.rmtree, root, True)
        self.repo, self.tmp = root / "repo", root / "tmp"
        self.tmp.mkdir()
        self.repo.mkdir()
        self.git("init", "-q", "-b", "main")
        self.git("config", "user.email", "t@example.com")
        self.git("config", "user.name", "T")
        self.write("CLAUDE.md", "- Money is integer cents.\n")
        self.write("REVIEW.md", "strictness: thorough\n")
        self.write("src/calc.py", "def add(a, b):\n    return a + b\n")
        self.commit("fix: add (#3)")
        self.git("checkout", "-q", "-b", "feat")

    def git(self, *args):
        return subprocess.run(["git", *args], cwd=self.repo, check=True, capture_output=True, text=True).stdout.strip()

    def write(self, path, text):
        (self.repo / path).parent.mkdir(parents=True, exist_ok=True)
        (self.repo / path).write_text(text)

    def commit(self, message):
        self.git("add", "-A")
        self.git("commit", "-qm", message)

    def run_script(self, script, *args, **env):
        env = dict(os.environ, TMPDIR=str(self.tmp), **env)
        return subprocess.run(["bash", script, *args], cwd=self.repo, capture_output=True, text=True, env=env)

    def collect(self, *args):
        proc = self.run_script(COLLECT, *args)
        self.assertEqual(proc.returncode, 0, proc.stderr)
        return dict(line.split("=", 1) for line in proc.stdout.splitlines())

    def test_branch_with_rewritten_lines(self):
        self.write("src/calc.py", "def add(a, b):\n    return a - b\n")
        self.commit("Subtract instead")
        ctx = self.collect()
        self.assertEqual((ctx["size"], ctx["strictness"], ctx["snapshot"]), ("small", "thorough", "false"))
        self.assertEqual(ctx["passes"], "bugs security standards history")
        self.assertIn("fix: add (#3)", (Path(ctx["work_dir"]) / "history.txt").read_text())
        self.assertEqual(ctx["tree"], str(self.repo))

    def test_change_that_only_adds_lines(self):
        self.write("src/mul.py", "def mul(a, b):\n    return a * b\n")
        self.commit("Add mul")
        ctx = self.collect()
        self.assertEqual((ctx["history"], ctx["passes"]), ("0", "bugs security standards"))

    def test_uncommitted_work_is_a_stable_snapshot(self):
        self.write("src/calc.py", "def add(a, b):\n    return b + a\n")
        self.write("src/new.py", "X = 1\n")
        first, second = self.collect(), self.collect()
        self.assertEqual(first["snapshot"], "true")
        self.assertEqual(first["head_sha"], second["head_sha"])
        self.assertIn("src/new.py", (Path(first["work_dir"]) / "diff.patch").read_text())
        self.assertEqual(self.git("status", "--porcelain"), "M src/calc.py\n?? src/new.py".strip())

    def test_rules_come_from_base(self):
        self.write("CLAUDE.md", "- Floats are fine.\n")
        self.write("src/calc.py", "def add(a, b):\n    return a + b + 0.0\n")
        self.commit("Loosen the rules")
        ctx = self.collect("--strictness", "balanced")
        self.assertEqual((Path(ctx["work_dir"]) / "rules/CLAUDE.md").read_text(), "- Money is integer cents.\n")
        self.assertEqual(ctx["strictness"], "balanced")

    def test_docs_only_change_is_trivial_but_a_rules_file_is_code(self):
        self.write("README.md", "# Calc\n")
        self.commit("Docs")
        self.assertEqual(self.collect()["size"], "trivial")
        self.write("REVIEW.md", "strictness: balanced\n")
        self.commit("Relax the review")
        self.assertEqual(self.collect()["size"], "small")

    def test_whitespace_is_trivial_only_where_indentation_is_not_syntax(self):
        self.git("checkout", "-q", "main")
        self.write("src/app.js", "function add(a, b) {\n  return a + b;\n}\n")
        self.commit("Add app.js")
        self.git("checkout", "-q", "-B", "feat")
        self.write("src/app.js", "function add(a, b) {\n    return a + b;\n}\n")
        self.commit("Reindent app.js")
        self.assertEqual(self.collect()["size"], "trivial")
        self.write("src/calc.py", "def add(a, b):\n        return a + b\n")
        self.commit("Reindent calc.py")
        self.assertEqual(self.collect()["size"], "small")

    def test_findings_files_stay_out_of_the_snapshot(self):
        self.write("src/calc.py", "def add(a, b):\n    return a - b\n")
        self.commit("Subtract instead")
        first = self.collect()
        self.write("review-findings.json", "{}\n")
        self.write("src/review-findings.json", "{}\n")
        second = self.collect()
        self.assertEqual((second["snapshot"], second["head_sha"]), ("false", first["head_sha"]))

    def test_fails_fast_and_leaves_nothing(self):
        proc = self.run_script(COLLECT, "v9..")
        self.assertEqual((proc.returncode, proc.stderr.strip()), (2, "error: unresolved ref: v9"))
        proc = self.run_script(COLLECT, "main..main")
        self.assertEqual(proc.returncode, 3)
        self.assertIn("empty diff", proc.stderr)
        self.assertEqual(list(self.tmp.iterdir()), [])

    def review(self, strictness="balanced"):
        self.write("src/calc.py", "def add(a, b):\n    return a - b\n")
        self.commit("Subtract instead")
        return Path(self.collect("--strictness", strictness)["work_dir"])

    def rank(self, verdicts, strictness="balanced", work=None):
        work = work or self.review(strictness)
        (work / "verdicts-1.json").write_text(json.dumps(verdicts))
        out = self.repo / "review-findings.json"
        proc = self.run_script(RANK, str(work), "--engine", "general finder", "--out", str(out))
        self.assertEqual(proc.returncode, 0, proc.stderr)
        return proc.stdout.splitlines(), json.loads(out.read_text())

    def verdict(self, severity, line=2, **extra):
        return {"verdict": "confirmed", "pass": "bugs", "path": "src/calc.py", "start_line": line, "end_line": line,
                "severity": severity, "problem": f"{severity} problem.", "reasoning": "r", "impact": "i", **extra}

    def test_rank_orders_findings_and_counts_actions(self):
        question = {"verdict": "question", "path": "src/calc.py", "start_line": 1, "end_line": 1, "question": "Why?"}
        lines, doc = self.rank([self.verdict("Important"), self.verdict("Critical", fix="Add."), question,
                                {"verdict": "dropped", "path": "x", "start_line": 1, "end_line": 1, "why": "nit"}])
        self.assertEqual([f["id"] + f["severity"] for f in doc["findings"]], ["F1Critical", "F2Important"])
        self.assertEqual(doc["questions"][0]["id"], "Q1")
        self.assertEqual(lines[1], "src/calc.py:L2: Critical Critical problem. Add.")
        self.assertEqual(lines[-1].split(" · ", 1)[1], "1 Critical: fix before merge · 1 Important: fix before proceeding")

    def test_rank_applies_strictness(self):
        question = {"verdict": "question", "path": "src/calc.py", "start_line": 1, "end_line": 1, "question": "Why?"}
        lines, doc = self.rank([self.verdict("Minor"), question], strictness="critical-only")
        self.assertEqual((doc["findings"], "questions" in doc), ([], False))
        self.assertEqual(len(lines), 1)
        self.assertTrue(lines[0].startswith("No findings in feat "))

    def test_validate_rejects_what_the_contract_forbids(self):
        lines, doc = self.rank([self.verdict("Critical"), self.verdict("Important")])
        broken = dict(doc, findings=[dict(doc["findings"][1], id="F1"), dict(doc["findings"][0], id="F1")])
        broken["findings"][1]["location"] = dict(broken["findings"][1]["location"], path="src/gone.py")
        path = self.repo / "broken.json"
        path.write_text(json.dumps(broken))
        proc = self.run_script(VALIDATE, str(path))
        self.assertEqual(proc.returncode, 1)
        self.assertIn("id F1 is used more than once", proc.stdout)
        self.assertIn("comes after", proc.stdout)
        self.assertIn("src/gone.py does not exist", proc.stdout)

    def test_post_skips_only_comments_already_posted(self):
        bin_dir, posted = self.repo.parent / "bin", self.repo.parent / "posted.txt"
        bin_dir.mkdir()
        (bin_dir / "gh").write_text(FAKE_GH)
        (bin_dir / "gh").chmod(0o755)
        posted.write_text("")
        env = {"PATH": f"{bin_dir}:{os.environ['PATH']}", "GH_POSTED": str(posted)}
        work = self.review()
        self.rank([self.verdict("Critical")], work=work)
        self.assertEqual(self.run_script(POST, "7", **env).returncode, 0)
        again = self.run_script(POST, "7", **env)
        self.assertEqual((again.returncode, again.stdout.split(":")[0]), (3, "already posted"))
        # A later run at the same head gives F1 to a different finding.
        self.rank([self.verdict("Critical", problem="Another problem.")], work=work)
        proc = self.run_script(POST, "7", **env)
        self.assertEqual(proc.returncode, 0, proc.stderr)
        self.assertIn("Another problem.", posted.read_text())
        self.assertEqual(list(self.tmp.glob("code-review-post.*")), [])


if __name__ == "__main__":
    unittest.main()
