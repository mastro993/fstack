#!/usr/bin/env bash
# The pipeline's rank-and-dedupe stage: turn the verifiers' verdicts into review-findings.json and
# the report. Confirmed findings go Critical, Important, Minor (findings in code before those in PR
# text); questions follow, at most 3, none at critical-only; dropped verdicts are left out. Ids, the
# head SHA, and links come from the work dir's context.env. The file is checked with
# validate_findings.sh, then the report is printed.
#
# Usage: rank_findings.sh WORK_DIR [--engine TEXT] [--out FILE]   (FILE default: review-findings.json)
set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
work=${1:?usage: rank_findings.sh WORK_DIR [--engine TEXT] [--out FILE]}
shift
engine="" out=review-findings.json
while [ $# -gt 0 ]; do
  case "$1" in
    --engine) engine=${2:?--engine needs a value}; shift 2 ;;
    --out) out=${2:?--out needs a value}; shift 2 ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
done

python3 - "$work" "$out" "$engine" <<'PY'
import glob, json, sys

work, out, engine = sys.argv[1:]
ctx = dict(line.rstrip("\n").split("=", 1) for line in open(f"{work}/context.env") if "=" in line)
head, base, strictness = ctx["head_sha"], ctx["base_sha"], ctx["strictness"]
blob, pr_url = ctx.get("blob_url", ""), ctx.get("pr_url", "")

verdicts = []
for path in sorted(glob.glob(f"{work}/verdicts-*.json")):
    try:
        verdicts += json.load(open(path))
    except ValueError as e:
        sys.exit(f"{path}: not a JSON array of verdicts: {e}")

rank = {"Critical": 0, "Important": 1, "Minor": 2}
keep = {"critical-only": {"Critical", "Important"}, "balanced": {"Critical", "Important"}}.get(strictness, set(rank))
confirmed = [v for v in verdicts if v.get("verdict") == "confirmed" and v.get("severity") in keep]
questions = [] if strictness == "critical-only" else [v for v in verdicts if v.get("verdict") == "question"][:3]
confirmed.sort(key=lambda v: (rank[v["severity"]], v["path"].startswith("<"), v["path"], v["start_line"]))


def location(v):
    start, end = v["start_line"], v.get("end_line") or v["start_line"]
    if v["path"].startswith("<"):
        url = v.get("url") or pr_url or None
    else:
        url = f"{blob}{v['path']}#L{start}-L{end}" if blob else None
    return {"path": v["path"], "start_line": start, "end_line": end, "url": url}


findings = []
for i, v in enumerate(confirmed, 1):
    f = {"id": f"F{i}", "head_sha": head, "location": location(v), "severity": v["severity"], "pass": v["pass"],
         "problem": v["problem"], "reasoning": v["reasoning"], "impact": v["impact"]}
    if v.get("fix"):
        f["fix"] = v["fix"]
    findings.append(f)
asked = [{"id": f"Q{i}", "location": location(v), "question": v["question"]} for i, v in enumerate(questions, 1)]
doc = {"schema_version": "1.0", "target": ctx["target"], "base_sha": base, "head_sha": head,
       "strictness": strictness, "findings": findings}
if asked:
    doc["questions"] = asked
json.dump(doc, open(out, "w"), indent=2)
open(out, "a").write("\n")


def where(loc):
    lines = f"L{loc['start_line']}" + (f"-L{loc['end_line']}" if loc["end_line"] != loc["start_line"] else "")
    return f"{loc['path']}:{lines}"


def sentence(text):
    return text.strip().rstrip(".") + "."


span = f"{base[:7]}..{head[:7]}"
if not findings and not asked:
    report = [f"No findings in {ctx['target']} {span} ({strictness}); {out} is empty."]
else:
    header = f"Review {ctx['target']} {span} · {strictness}" + (f" · {engine}" if engine else "")
    if ctx.get("earlier"):
        header += f" · Earlier review: {ctx.get('addressed', 0)} of {ctx['earlier']} addressed"
    report = [header]
    for f, v in zip(findings, confirmed):
        line = f"{where(f['location'])}: {f['severity']} {sentence(f['problem'])}"
        if f.get("fix"):
            line += f" {sentence(f['fix'])}"
        report.append(line)
        if f["pass"] == "security" or v.get("architectural"):
            report += [f"  why: {f['reasoning']}", f"  impact: {f['impact']}"]
    report += [f"q: {where(q['location'])}: {q['question']}" for q in asked]
    actions = {"Critical": "fix before merge", "Important": "fix before proceeding", "Minor": "note for later"}
    counts = []
    for sev in rank:
        n = sum(f["severity"] == sev for f in findings)
        if n:
            counts.append(f"{n} {sev}: {actions[sev]}")
    report.append(" · ".join([f"Findings: {out} ({len(findings)} at {head[:7]})", *counts]))
open(f"{work}/report.txt", "w").write("\n".join(report) + "\n")
PY

bash "$here/validate_findings.sh" "$out" >&2
cat "$work/report.txt"
