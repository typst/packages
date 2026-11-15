# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-10-09

### Added

- Project scaffold: package manifest, CI, test layout, manual skeleton.
- Size-generic cube state (`cube`, `case`, `apply`, `face`, `sticker`, `is-solved`).
- Move notation: face, wide, slice and rotation moves, `'`/`2` suffixes, repeated groups.
- Masks: `keep-colors`, `hide-faces`, `hide-pieces`, `mask`.
- `draw` with views `oll`, `ll`, `face` (any face straight on, optional side strips and arrows),
  `f2l`, `full` (3D via CeTZ) and `net`.
- Skewb, pyraminx and megaminx, selected with `cube(event: ..)`, with WCA notation,
  per-puzzle view availability and a `tip` view for the pyraminx.
- A geometric move engine shared by every puzzle: moves are rotations of sticker
  polygons about an axis, piece identity and all renderers derive from the 3D model.
- Puzzle options (`cube(options: (cut: 0.4))` on the megaminx), validated per puzzle.
- `labels: true` on the straight-on views writes each sticker's index on it.
- `face: auto` (the default) is the puzzle's first face, so `view: "face"` works on the pyraminx.
- Whole-puzzle rotations `y` on the skewb and `y`, `z` on the pyraminx.
- Commutator `[A, B]` and conjugate `[A: B]` / `A: B` notation on every puzzle, nestable.
- Square-1 (`event: "square1"`): WCA `(x,y)` and `/` notation with slice legality checked at
  compile time, state-dependent geometry, views `layers`, `obl` (only U and D colours) and
  `cs` (shape only) besides `face` and `net`, with the slice marked by a line (`slices`)
  and a `direction` option for horizontal or vertical arrangement; palette colour `black`.
- Megaminx `full` view: straight down the front face, showing it and its five neighbours.
  One megaminx unit is the edge of the centre pentagon at the default cut.
- Megaminx side faces are drawn head-on with a vertex at the top and `U` at the upper right,
  so every megaminx face has a horizontal bottom edge.
- `draw(face:, top:)` orient the `full` view of every puzzle but the Square-1: the face in front
  and the face (pyraminx: vertex) on top, any pair that sits like `F` and `U`. The Square-1
  rejects `face:` and `top:`.
- Per-arrow `thickness` and `head` besides `color`, overriding the `arrow-*` defaults.
- `draw(view: auto)` (the default) draws the puzzle's default view: `full`, or `layers` on the Square-1.
- Cube events accept `*` as well as `x`: `"3*3"`, `"3*3*3"`.
- `labels: "faces"` writes the face names on the straight-on and net views; `labels: true` now works on the net too.
- `draw(options: (:))` for puzzle-specific drawing settings, validated per puzzle:
  Square-1 `slices`, `direction` and `turn` (layers turned so the slice is vertical).
  The pyraminx `tip` view takes its vertex as `draw(tip:)`, beside `face:`.

### Changed

- `cube(size: 3)` became `cube(event: "3x3")`; `solved`, `case`, `parse` and `inverse` take `event:`.
- Faces of puzzles other than cubes are flat arrays; `sticker(c, face, index)`.
- `gap` shrinks stickers in place instead of adding space between them.
- The strip thickness parameter is `side-length` (was `side`).
- CeTZ 0.5.2, so the package needs Typst 0.14 or newer.

[Unreleased]: https://github.com/ANCuber/cubst/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/ANCuber/cubst/releases/tag/v0.1.0
