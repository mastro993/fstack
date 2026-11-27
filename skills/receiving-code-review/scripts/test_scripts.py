#!/usr/bin/env python3
"""Tests for the skill's scripts, with a stand-in for gh: python3 test_scripts.py"""

import json
import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent

# gh for PR #7 of o/r: `pr view` prints $GH_DATA's "pr"; `api graphql` prints, as one slurped page,
# the nodes $GH_DATA holds for the connection the query asks for.
FAKE_GH = """#!/usr/bin/env python3
import json, os, sys
data = json.load(open(os.environ["GH_DATA"]))
if sys.argv[1] == "pr":
    print(json.dumps(data["pr"]))
else:
    query = next(a for a in sys.argv if a.startswith("query="))
    conn = next(c for c in ("reviewThreads", "reviews", "comments") if c + "(" in query)
    page = {"viewer": {"login": "me"}, "repository": {"pullRequest": {conn: {"nodes": data[conn]}}}}
    print(json.dumps([{"data": page}]))
"""

URL = "https://git.example.com/o/r/pull/7"
AT = "2026-11-01T00:00:00Z"


class FetchThreadsTest(unittest.TestCase):
    def fetch(self, data):
        root = Path(tempfile.mkdtemp()).resolve()
        self.addCleanup(shutil.rmtree, root, True)
        (root / "gh").write_text(FAKE_GH)
        (root / "gh").chmod(0o755)
        (root / "data.json").write_text(json.dumps(data))
        env = dict(os.environ, PATH=f"{root}{os.pathsep}{os.environ['PATH']}", GH_DATA=str(root / "data.json"))
        out = subprocess.run(["bash", str(HERE / "fetch_threads.sh"), "7"], env=env, capture_output=True, text=True)
        self.assertEqual(out.returncode, 0, out.stderr)
        return json.loads(out.stdout)

    def test_a_deleted_account_shows_as_ghost(self):
        # GitHub's GraphQL gives a deleted account's PR, comments, and reviews a null author.
        state = self.fetch({
            "pr": {"number": 7, "url": URL, "headRefOid": "a" * 40, "headRefName": "feat", "baseRefName": "main",
                   "author": None},
            "reviewThreads": [{"id": "T1", "isResolved": False, "isOutdated": False, "path": "src/a.py", "line": 3,
                               "comments": {"nodes": [{"databaseId": 1, "author": None, "body": "This leaks.",
                                                       "url": f"{URL}#r1", "createdAt": AT}]}}],
            "reviews": [{"id": "R1", "author": None, "state": "COMMENTED", "body": "One note.", "url": f"{URL}#review-1",
                         "submittedAt": AT}],
            "comments": [{"id": "C1", "author": {"login": "lint-bot", "__typename": "Bot"}, "body": "Lint passed.",
                          "url": f"{URL}#c1", "createdAt": AT}],
        })
        self.assertEqual(state["author"], "ghost")
        self.assertEqual([(c["author"], c["bot"]) for c in state["threads"][0]["comments"]], [("ghost", False)])
        self.assertEqual(state["reviews"][0]["author"], "ghost")
        self.assertEqual((state["comments"][0]["author"], state["comments"][0]["bot"]), ("lint-bot", True))


if __name__ == "__main__":
    unittest.main()
