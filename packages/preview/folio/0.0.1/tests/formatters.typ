// Test: format-date and format-money formatters
// Verifies default behavior, edge-case handling, and config override.
#import "@preview/folio:0.0.1": folio-init, format-date, format-money

#show: body => folio-init(
  data: (:),
  config: (:),
  body,
)

= Formatter Tests

== format-date

Standard ISO dates:

#table(
  columns: (auto, auto, auto),
  table.header([Input], [Expected], [Result]),
  raw("2026-01-01"), [Jan 1, 2026], format-date("2026-01-01"),
  raw("2026-04-30"), [Apr 30, 2026], format-date("2026-04-30"),
  raw("2026-12-31"), [Dec 31, 2026], format-date("2026-12-31"),
  raw("2025-06-15"), [Jun 15, 2025], format-date("2025-06-15"),
)

Edge cases (all should render a missing-box, not crash):

- Non-ISO string: #format-date("not-a-date")
- Not a string: #format-date(42)
- Empty string: #format-date("")

== format-money

Standard amounts:

#table(
  columns: (auto, auto, auto),
  table.header([Input], [Expected], [Result]),
  [0], [\$0.00], format-money(0),
  [1000], [\$1,000.00], format-money(1000),
  [235000], [\$235,000.00], format-money(235000),
  [1234567], [\$1,234,567.00], format-money(1234567),
  [99.5], [\$99.50], format-money(99.5),
  [0.1], [\$0.10], format-money(0.1),
)

Edge case — invalid type (should render a missing-box, not crash):

- String input: #format-money("not a number")
