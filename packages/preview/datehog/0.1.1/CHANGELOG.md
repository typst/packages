# Changelog of all Changes to Datehog

## v0.1.1

No functional changes. The `v0.1.0` was prematurely created without this changelog and the release pipeline.

## v0.1.0

Initial release. Parses date strings and epoch milliseconds into a plain
*moment* dictionary (`from-ms`, `parse`, `parse-ms`, ...), converts back to
epoch ms/seconds/days or ISO 8601, interops with Typst's native `datetime`,
and adds calendar arithmetic (`add-days`, `add-months`, `is-leap-year`,
`days-in-month`, ...). Nothing panics: unparseable input returns `none`.

Parsing tracks JavaScript's `Date.parse` order and is calibrated against
flint-py, the reference implementation datehog exists to stay compatible
with. Basically on par with V8's own parsing, and bug-for-bug compatible with
the mismatches flint-py also makes -- except where flint-py's mismatch is
simply a flint-py bug, in which case datehog follows V8 instead:

- Strings V8 sloppily accepts as dates but flint-py rejects, so datehog does
  too: invalid calendar dates (`2020-02-30`, `2019-02-29`), and short
  fragments V8 parses through a loose heuristic (`Wk 01`, `Round 1`..`Round 6`,
  `Stage 1`..`Stage 12`).
- `2018 FY` goes the other way: flint-py (and datehog) parse the trailing
  year out of it; V8 does not.
- Month-name formats flint-py mishandles even though V8 parses them
  correctly -- a genuine flint-py bug, not a deliberate JS leniency, so
  datehog matches V8 here instead of replicating it: bare `"Month Year"` and
  `"Month D Year"` in their various spellings (`Feb 2020`, `February 2020`,
  `Feb 15 2020`, `Feb 15, 2020`, `February 15, 2020`, `15 Feb 2020`,
  `15 February 2020`, `Sept 2020`, `Jan. 2020`, plus RFC 2822 forms like
  `Tue, 15 Feb 2020 08:30:00 GMT` and `15 Feb 2020 08:30:00 +0200`), and the
  bare year-month `2020-03`.

Verified against 29,031/29,031 calendar dates (1600-2400) vs. Python's
`datetime`, and 445/445 parser cases vs. flint-py or, on the cases just
above, vs. V8. See [Testing](README.md#testing) for how the suite is run.