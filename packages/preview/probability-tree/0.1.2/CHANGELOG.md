# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.2] - 2026-08-22

### Added

- New `extra: (pos, draw) => ...` callback, drawn inside the tree canvas after
  the tree. It receives the exact canvas position of every node as a dictionary
  keyed `N<level><index>` (1-indexed, in visual top-to-bottom order, e.g.
  `N11` = root, `N41` = 1st leaf of a 4-level tree), plus the CeTZ `draw`
  namespace — letting you overlay labels, annotations or lines that align
  perfectly with the tree, without importing CeTZ yourself.
- Node positions are computed by replicating CeTZ's own measurement and layout,
  so overlaid content matches the rendered nodes exactly, whatever the value of
  `first-child-top`.

## [0.1.1] - 2026-08-14

### Fixed

- The probability style was merged twice (once in `normalize-proba`, once in
  `draw-edge`); it is now merged a single time, so local `sp(style:)` keys
  behave as documented.
- Duplicate node paths could make `on`-mode probability labels collide; nodes
  now get a unique path.
- Generic Typst index error for malformed nodes replaced with a clear message:
  `proba-tree: non-root node without probability — the expected format is
  (label, proba, ..children)`.

### Changed

- Default `proba-distance` shortened from `0.4` to `0.3`.

## [0.1.0] - 2026-08-04

### Added

- Initial release: n×p probability trees growing left-to-right, built on
  [CeTZ](https://typst.app/universe/package/cetz).
- Per-node and per-probability local settings (`sn` / `sp`).
- Global and local text styles (weight, italic, small caps, highlight, custom
  function).
- Probability label placements: `above`, `below`, `on`, `hybrid`, optionally
  sloped along the edge.
- In `on` mode the edge is cut under the label, with transparency preserved.
- Default tree (Ω, A/Ā, B/B̄) used when `data` is omitted.
