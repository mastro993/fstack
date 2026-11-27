#!/usr/bin/env bash
# Check a review-findings.json against assets/findings.schema.json, then that its ids are unique,
# its findings run from most to least severe, and every file location exists at the reviewed head.
#
# Usage: validate_findings.sh [FILE]   (default: review-findings.json)
# Prints `ok: <n> findings, <m> questions`, or one line per problem and exits 1.
set -euo pipefail

schema="$(cd "$(dirname "$0")/.." && pwd)/assets/findings.schema.json"
file=${1:-review-findings.json}

python3 - "$schema" "$file" <<'PY'
import json, re, subprocess, sys

schema_path, path = sys.argv[1], sys.argv[2]
schema = json.load(open(schema_path))
try:
    doc = json.load(open(path))
except (OSError, ValueError) as e:
    sys.exit(f"{path}: {e}")

errors = []
TYPES = {"object": dict, "array": list, "string": str, "integer": int, "null": type(None), "boolean": bool}


def resolve(s):
    while "$ref" in s:
        s = schema["$defs"][s["$ref"].rsplit("/", 1)[-1]]
    return s


def check(node, s, where):
    """The subset of JSON Schema that findings.schema.json uses."""
    s = resolve(s)
    types = s.get("type")
    types = [types] if isinstance(types, str) else types or []
    if types and not any(isinstance(node, TYPES[t]) and not (t == "integer" and isinstance(node, bool)) for t in types):
        errors.append(f"{where}: expected {' or '.join(types)}, got {json.dumps(node)[:60]}")
        return
    if "const" in s and node != s["const"]:
        errors.append(f"{where}: must be {json.dumps(s['const'])}")
    if "enum" in s and node not in s["enum"]:
        errors.append(f"{where}: must be one of {', '.join(map(str, s['enum']))}")
    if isinstance(node, str):
        if len(node) < s.get("minLength", 0):
            errors.append(f"{where}: must not be empty")
        if "pattern" in s and not re.search(s["pattern"], node):
            errors.append(f"{where}: {json.dumps(node)[:60]} does not match {s['pattern']}")
    if isinstance(node, int) and not isinstance(node, bool) and node < s.get("minimum", node):
        errors.append(f"{where}: must be at least {s['minimum']}")
    if isinstance(node, dict):
        props = s.get("properties", {})
        for key in s.get("required", []):
            if key not in node:
                errors.append(f"{where}: missing {key}")
        for key, value in node.items():
            if key in props:
                check(value, props[key], f"{where}.{key}")
            elif s.get("additionalProperties") is False:
                errors.append(f"{where}: unknown field {key}")
    if isinstance(node, list):
        for i, item in enumerate(node):
            check(item, s.get("items", {}), f"{where}[{i}]")


check(doc, schema, "$")
if errors:
    print("\n".join(errors))
    sys.exit(1)

head = doc["head_sha"]
findings, questions = doc["findings"], doc.get("questions", [])
ids = [f["id"] for f in findings] + [q["id"] for q in questions]
for dup in sorted({i for i in ids if ids.count(i) > 1}):
    errors.append(f"id {dup} is used more than once")
rank = {"Critical": 0, "Important": 1, "Minor": 2}
for a, b in zip(findings, findings[1:]):
    if rank[a["severity"]] > rank[b["severity"]]:
        errors.append(f"{b['id']} ({b['severity']}) comes after {a['id']} ({a['severity']}): order Critical, Important, Minor")


def lines_at_head(p):
    """Line count of p at head, None when it isn't a file there, or ... when git can't tell."""
    try:
        out = subprocess.run(["git", "show", f"{head}:{p}"], capture_output=True, check=True).stdout
    except (OSError, subprocess.CalledProcessError):
        known = subprocess.run(["git", "cat-file", "-e", f"{head}^{{commit}}"], capture_output=True)
        return None if known.returncode == 0 else ...
    return out.count(b"\n") + (0 if out.endswith(b"\n") or not out else 1)


for item in findings + questions:
    where, loc = item["id"], item["location"]
    if item.get("head_sha", head) != head:
        errors.append(f"{where}: head_sha differs from the file's head_sha")
    if loc["end_line"] < loc["start_line"]:
        errors.append(f"{where}: end_line {loc['end_line']} is before start_line {loc['start_line']}")
    if loc["path"].startswith("<"):
        continue  # a PR description, title, commit, or comment
    if loc["url"] and head not in loc["url"]:
        errors.append(f"{where}: url is not pinned to head {head[:7]}")
    count = lines_at_head(loc["path"])
    if count is None:
        errors.append(f"{where}: {loc['path']} does not exist at {head[:7]}")
    elif count is not ... and loc["end_line"] > count:
        errors.append(f"{where}: {loc['path']} has {count} lines at {head[:7]}, the location ends at {loc['end_line']}")

if errors:
    print("\n".join(errors))
    sys.exit(1)
print(f"ok: {len(findings)} finding{'s' * (len(findings) != 1)}, {len(questions)} question{'s' * (len(questions) != 1)}")
PY
