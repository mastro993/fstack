# Migrate callers, then delete legacy APIs

When a new internal API replaces an old one, move every caller to the new API and delete the old one in the same change, so one way remains. The old name leaves with no alias, wrapper, re-export, or deprecation shim.

- Find every caller first, including tests, scripts, docs, and examples. With more than a couple, build a lever (see build-the-lever.md).
- Each caller keeps what the old API did for it: normalizing input, defaults, error mapping, logging. That behavior moves into the new API or into the caller, with a test.
- Tests assert the new contract through the public interface. Tests that only protected the old API's internals are deleted, after any behavior they covered moves into tests of the new API.
- Delete the old API last, once nothing references it.

This holds when only code you can change depends on the old API. When something outside the repo relies on it (a published package, a public endpoint, a CLI, a file format another program reads), follow SKILL.md's rule for outside contracts.

**Test:** a search for the old name finds nothing in the tree.
