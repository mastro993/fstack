#!/usr/bin/env python3
"""Check a JSON file against one of this skill's JSON Schemas, with the standard library only.

  check_schema.py SCHEMA FILE

Covers the keywords the bundled schemas use: type, enum, const, required, properties,
additionalProperties, items, minItems, minLength, pattern, minimum, allOf, oneOf, not,
if/then/else, $ref to #/$defs, and boolean schemas. Prints one line per violation and exits 1.
"""

import json
import re
import sys

TYPES = {"object": dict, "array": list, "string": str, "boolean": bool, "null": type(None)}


def type_ok(value, name):
    if name == "integer":
        return isinstance(value, int) and not isinstance(value, bool)
    if name == "number":
        return isinstance(value, (int, float)) and not isinstance(value, bool)
    return isinstance(value, TYPES[name])


def errors(value, schema, root, path):
    if schema is True:
        return []
    if schema is False:
        return [f"{path}: not allowed here"]
    if "$ref" in schema:
        target = root
        for part in schema["$ref"].removeprefix("#/").split("/"):
            target = target[part]
        return errors(value, target, root, path)
    out = []
    if "type" in schema:
        names = schema["type"] if isinstance(schema["type"], list) else [schema["type"]]
        if not any(type_ok(value, n) for n in names):
            return [f"{path}: expected {' or '.join(names)}, got {json.dumps(value)[:60]}"]
    if "const" in schema and value != schema["const"]:
        out.append(f"{path}: must be {json.dumps(schema['const'])}, got {json.dumps(value)[:60]}")
    if "enum" in schema and value not in schema["enum"]:
        out.append(f"{path}: must be one of {', '.join(map(json.dumps, schema['enum']))}, got {json.dumps(value)[:60]}")
    if isinstance(value, str):
        if len(value.strip()) < schema.get("minLength", 0):
            out.append(f"{path}: must not be empty")
        if "pattern" in schema and not re.search(schema["pattern"], value):
            out.append(f"{path}: {json.dumps(value)[:60]} doesn't match {schema['pattern']}")
    if isinstance(value, (int, float)) and "minimum" in schema and value < schema["minimum"]:
        out.append(f"{path}: must be at least {schema['minimum']}")
    if isinstance(value, list):
        if len(value) < schema.get("minItems", 0):
            out.append(f"{path}: needs at least {schema['minItems']} entries")
        if "items" in schema:
            for i, item in enumerate(value):
                out += errors(item, schema["items"], root, f"{path}[{i}]")
    if isinstance(value, dict):
        for key in schema.get("required", []):
            if key not in value:
                out.append(f"{path}: missing {key}")
        props = schema.get("properties", {})
        for key, sub in props.items():
            if key in value:
                out += errors(value[key], sub, root, f"{path}.{key}")
        extra = schema.get("additionalProperties", True)
        for key in value:
            if key not in props and extra is not True:
                out += errors(value[key], extra, root, f"{path}.{key}")
    for sub in schema.get("allOf", []):
        out += errors(value, sub, root, path)
    if "oneOf" in schema:
        passing = sum(not errors(value, sub, root, path) for sub in schema["oneOf"])
        if passing != 1:
            out.append(f"{path}: {schema.get('description', 'must match exactly one of its alternatives')}")
    if "not" in schema and not errors(value, schema["not"], root, path):
        out.append(f"{path}: {schema['not'].get('description', 'matches a shape that is not allowed')}")
    if "if" in schema:
        branch = schema.get("then") if not errors(value, schema["if"], root, path) else schema.get("else")
        if branch is not None:
            out += errors(value, branch, root, path)
    return out


def main():
    schema_path, file_path = sys.argv[1:3]
    schema = json.loads(open(schema_path).read())
    try:
        value = json.loads(open(file_path).read())
    except json.JSONDecodeError as e:
        print(f"{file_path}: not valid JSON: {e}")
        return 1
    problems = errors(value, schema, schema, "$")
    for p in problems:
        print(p)
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
