# Changelog

Notable changes to pivot, following
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and
[Semantic Versioning](https://semver.org/). Pre-1.0, a breaking change can land in
a minor release — each is flagged with a migration note.

## [Unreleased]

## [0.1.0] - 2026-06-28

First release: the byte-region family — three views over the same bytes, sharing
one field model so they never disagree on where a field starts.

### Added

- **`packet`** — flat protocol-header view; fields auto-flow and wrap, narrow
  labels become leader callouts, with a deduplicating bit ruler.
- **`struct`** — vertical memory map; box height tracks byte size (oversized
  fields capped with a break mark), hex offsets, sub-byte fields expand in place.
- **`hexdump`** — real bytes + ASCII gutter; annotations you `fill:` are
  highlighted in place, and every annotation is keyed in a byte-range legend.
  `data:` takes `read(f, encoding: none)` or an int array.
- Shared elements `bytes` / `bits` / `gap` / `reserved`, with `at:` (byte offset
  on `bytes`, bit offset on `bits`) and `fill:`.
- **`palette`** — Okabe–Ito colour-blind-safe highlight colours, for `fill:`.
- Theming via a `theme:` dict; built on `@preview/cetz:0.5.2` (Typst ≥ 0.14).

[Unreleased]: https://github.com/cybermallard/typst-pivot/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/cybermallard/typst-pivot/releases/tag/v0.1.0
