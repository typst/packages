# ROADMAP — quick-vertex

Known presentation limitations and optional features. Mathematical results
are covered by assertions and an independent exact projection oracle in tests.

## Correctness changes in 0.2.0

- Replaced angular sampling with analytic recession directions.
- Normalized constraints/objectives before geometric comparisons.
- Separated feasibility and optimization from the visible frame and CeTZ.
- Added strict feasibility and attained/unattained optimal-face checks.
- Supported regions without vertices and the zero objective.
- Added input validation and kept objective diagnostics independent of tables.
- Removed solid strict-boundary underlays and duplicate frame intersections.
- Labeled the optimization arrow `max Z` or `min Z`, keeping the level lines.

## Known limitations

- Floating-point tolerances remain: nearly parallel lines or boundaries closer
  than numerical precision should not be treated as exact rational geometry.
- Normalization that exceeds the floating-point range is rejected explicitly.

### Possible new flag

- **`level-lines: false`** — show the highlighted optimal vertex from `objective`
  *without* drawing the level-line family, for materials that solve LP by the
  vertex-evaluation method (not the level-line method) and don't want to mix the
  two on the same figure. Today `objective != none` always draws the level lines.

### Cosmetic

- **Vertex label can still land on an axis tick** — labels are now placed along
  the exterior bisector (away from the polygon), which fixes overlaps with
  *other vertices/edges*, but the bisector doesn't know about axis tick labels,
  so a vertex right next to a tick (e.g. on the y-axis) can still collide with
  it (e.g. `E` vs the `6` tick in a 5-vertex region).
- **Zero-area regions** (a single point or a segment) are drawn, but without
  hatching (the hatch loop has nothing to traverse).
- The **sliding level lines** are schematic (they illustrate the sweep; they are
  not a metric scale).

## Possible improvements (Phase 4, optional)

- Hatching (or a clearer mark) for degenerate zero-area regions.
- More localization languages in `_i18n` (currently `en`, `es`).
- Reference-image comparisons for visual details beyond the existing SVG
  checks and mathematical assertions.

### Feature ideas

- **A truly minimal preset.** Sugar for `table: false, gradient: false,
  objective: none` (region + lines + vertices only), the common "statement" look,
  so callers don't repeat the flags.
- Consider a shorthand for passing the objective as `Z = a x + b y` symbolically
  (today it's `objective: (a, b)`), matching how textbooks write it.

### Out of scope (decided)

- A separate mesh-fill renderer for plain inequality systems. Half-planes,
  strips and other vertex-free regions now use the existing clipping renderer;
  a second rendering algorithm is unnecessary.

## Before publishing to Typst Universe

- [x] Confirm the name `feasible-region` is free in the index.
- [x] Final visual pass on the gallery images.
- [x] Submit a PR to `typst/packages` (`packages/preview/quick-vertex/0.1.0/`, renamed from `feasible-region` per reviewer feedback).
- [x] `0.1.1`: equal aspect ratio and exterior-bisector vertex labels. Published through [#5391](https://github.com/typst/packages/pull/5391).
- [ ] Publish `0.2.0` after Typst maintainers' review: correctness fixes, pure analysis, level-line legends and direction labels.
