# Opening issues

Load the create-issues skill and follow it once per row marked **open issue** in `issues.md`. Each `UX-NN` is its own contract and one root cause, so it gets one issue: no parent, no tiering or matrix across the rows. The user picked these rows from the ranked table in step 4, so that choice is the approval of exact issues create-issues' step 5 accepts; don't ask again. With no tracker reachable, write `RUN/issues/UX-NN.md` per issue instead and say so.

Write each issue for a developer who never saw this run:

- **Title**: the issue in plain words ("Signup hides the password rule until it fails").
- **Body**: hit by (count and personas), severity, where, root cause; repro steps and expected behaviour from the clearest finding; one line per persona in their own words; for needs-owner issues, what the owner must supply.
- **Screenshots**: attach the ones that pass create-issues' check for sensitive content, and name any you held back and why. If the tracker can't take attachments, list the file names.
