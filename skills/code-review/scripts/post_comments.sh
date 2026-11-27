#!/usr/bin/env bash
# Post a review-findings.json to its pull request as one review with event COMMENT: an inline
# comment per finding or question whose lines are in the diff, the rest in the review body. Each
# comment carries a hidden marker with its id and the reviewed head, so later reviews can count
# what got addressed. A rerun skips the comments already posted word for word.
#
# This is the only path in the skill that writes to a PR. It never approves or requests changes.
#
# Usage: post_comments.sh PR [FILE]   (PR: a number or URL; FILE default: review-findings.json)
set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
[[ ${1:-} =~ ([0-9]+)/?$ ]] || { echo "usage: post_comments.sh PR [FILE]" >&2; exit 2; }
pr=${BASH_REMATCH[1]}
file=${2:-review-findings.json}

bash "$here/validate_findings.sh" "$file" >&2
url=$(gh pr view "$pr" --json url --jq .url)
repo=${url#*://*/} repo=${repo%/pull/*}
work=$(mktemp -d "${TMPDIR:-/tmp}"/code-review-post.XXXXXX)
trap 'rm -rf "$work"' EXIT
{ gh api "repos/$repo/pulls/$pr/comments" --paginate --jq '.[].body'
  gh api "repos/$repo/pulls/$pr/reviews" --paginate --jq '.[].body'
} > "$work/posted.txt"

python3 - "$file" "$work" <<'PY'
import json, re, subprocess, sys

path, work = sys.argv[1], sys.argv[2]
doc = json.load(open(path))
head, base = doc["head_sha"], doc["base_sha"]
posted = open(f"{work}/posted.txt").read()

# Lines GitHub accepts inline comments on: the new side of every hunk, context included.
commentable = {}
diff = subprocess.run(["git", "diff", "--no-color", "--no-ext-diff", "-M", base, head],
                      capture_output=True, text=True, check=True).stdout
current = None
for line in diff.splitlines():
    if line.startswith("+++ "):
        current = line[6:] if line.startswith("+++ b/") else None
    elif line.startswith("@@") and current:
        m = re.match(r"@@ -\S+ \+(\d+)(?:,(\d+))? @@", line)
        start, count = int(m.group(1)), int(m.group(2) or 1)
        commentable.setdefault(current, set()).update(range(start, start + count))


def marker(item):
    return f"<!-- code-review id={item['id']} sha={head} -->"


def body_of(item):
    if "question" in item:
        return f"**q:** {item['question']}\n\n{marker(item)}"
    text = f"**{item['severity']}** · {item['pass']}: {item['problem']}"
    if item.get("fix"):
        text += f" {item['fix']}"
    why = f"{item['reasoning']}\n\nImpact: {item['impact']}"
    if item["pass"] == "security":
        text += f"\n\n{why}"
    else:
        text += f"\n\n<details><summary>Why</summary>\n\n{why}\n\n</details>"
    return f"{text}\n\n{marker(item)}"


inline, in_body, skipped = [], [], 0
for item in doc["findings"] + doc.get("questions", []):
    # Ids are rank positions: another run at this head can give F1 to another finding.
    if body_of(item) in posted:
        skipped += 1
        continue
    loc = item["location"]
    lines = commentable.get(loc["path"], set())
    if all(n in lines for n in range(loc["start_line"], loc["end_line"] + 1)):
        comment = {"path": loc["path"], "line": loc["end_line"], "side": "RIGHT", "body": body_of(item)}
        if loc["start_line"] < loc["end_line"]:
            comment.update(start_line=loc["start_line"], start_side="RIGHT")
        inline.append(comment)
    else:
        link = f"[{loc['path']}:L{loc['start_line']}]({loc['url']})" if loc["url"] else f"{loc['path']}:L{loc['start_line']}"
        in_body.append(f"- {link}: {body_of(item)}")

review_marker = f"<!-- code-review sha={head} strictness={doc['strictness']} -->"
if not inline and not in_body and review_marker in posted:
    print(f"already posted: {skipped} items at {head[:7]}")
    sys.exit(3)
n, q = len(doc["findings"]), len(doc.get("questions", []))
summary = f"**Code review** · {doc['strictness']} · {base[:7]}..{head[:7]}: "
summary += f"{n} finding{'s' * (n != 1)}, {q} question{'s' * (q != 1)}." if n or q else "no findings."
body = "\n\n".join([summary, *in_body, review_marker])
payload = {"commit_id": head, "event": "COMMENT", "body": body, "comments": inline}
json.dump(payload, open(f"{work}/payload.json", "w"))
# The fallback, for when GitHub rejects an inline position: everything in the body.
flat = [f"- {c['path']}:L{c['line']}: {c['body']}" for c in inline]
json.dump({"commit_id": head, "event": "COMMENT", "body": "\n\n".join([summary, *flat, *in_body, review_marker]),
           "comments": []}, open(f"{work}/payload-flat.json", "w"))
print(f"posting: {len(inline)} inline, {len(in_body)} in the body, {skipped} already posted", file=sys.stderr)
PY

if ! gh api "repos/$repo/pulls/$pr/reviews" --method POST --input "$work/payload.json" --jq .html_url 2> "$work/err"; then
  echo "inline comments rejected ($(head -c 200 "$work/err")); posting them in the review body" >&2
  gh api "repos/$repo/pulls/$pr/reviews" --method POST --input "$work/payload-flat.json" --jq .html_url
fi
