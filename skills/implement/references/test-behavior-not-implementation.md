# Test behavior, not implementation

A test is a claim about what users of the code can observe through its interface: return values, raised errors, state they can read back, and effects on outside systems (what a mail server, database, or HTTP API receives). Private helpers, internal call order, and intermediate data are implementation.

Judge each test you write, change, or keep against two imagined edits:

- **Break the behavior** (a wrong value, a skipped or doubled effect). The test fails. When it still passes it proves nothing; the usual causes are a loose assertion, an expected value computed by the code under test, and an assertion on data the test built itself.
- **Change the internals** and keep every observable result. The test passes. When it fails, it is pinned to the implementation.

Keep the tests that catch the first edit and survive the second; rewrite or delete the rest.

- Drive the code through its public interface with concrete inputs, and write the expected value out as a literal taken from the requirement.
- Pass in what lies outside the system (the clock, the network, the mail transport) as a fake, and assert what it received. Patching an internal helper, or asserting that it was called, pins the test to the implementation.
- Pair each "this never happens" with a case where it does, so the test can't pass by doing nothing.
- Where the code already raises an error type or code that callers branch on, assert that rather than the message text.

**Test:** for each test in the diff, name the behavior change that would make it fail. When only an internal rename would, rewrite it.
