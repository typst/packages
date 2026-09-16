# Changelog

All notable changes to `calendaring` are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## 0.1.0 — unreleased

Initial release.

### Functions

- `month-grid(year, month, ...)` — render a month as a 7-column grid with
  correct leading and trailing blank days. Optional rotation, custom cell
  rendering, weekday-name localization, per-day events, today highlight,
  and an ISO 8601 week-number column.
- `year-grid(year, columns: 3, ...)` — compose twelve `month-grid` instances
  on one page.
- `is-leap-year(year)` — Gregorian leap-year predicate.

### Notes

- The `cell-content` callback receives a `datetime`, so `date.weekday()` and
  `date.day()` are available without closing over scope.
- `weekday-names`, when overridden, must be in the same order as `week-start`
  (e.g. for `week-start: "sun"`, the array starts with the Sunday label).
- ISO 8601 week numbers are always anchored to the row's Monday, even when
  `week-start: "sun"`.
