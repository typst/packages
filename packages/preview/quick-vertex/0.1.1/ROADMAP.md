# ROADMAP — feasible-region

Known issues and pending decisions. Nothing here blocks ordinary use; the two
"semantic" items only arise with inputs that do not appear in textbook problems.

## Known limitations

### Semantic (rare edge cases — documented on purpose, not fixed)

- **A strict inequality binding the optimum.** With e.g. `x + y > 2` (strict)
  and a minimization whose optimum lies on that boundary, the plot labels the
  segment/ray as an attained optimum. Strictly, the boundary is *open*, so the
  value is an **infimum that is not attained** — there is no minimum. The package
  normalizes strict operators to non-strict for the geometry (drawing a dashed
  boundary to signal non-membership), so the table text overclaims here.
  *Why unfixed:* strict inequalities binding the optimum do not occur in
  school-level LP; a correct fix needs "infimum not attained" logic.

- **More than two vertices tied in `Z`.** The multiple-optimum highlight draws a
  segment from the first to the last tied vertex. When three or more vertices tie
  and they do not form a single edge (e.g. a degenerate objective like `(0, 0)`,
  where every vertex ties), that segment misrepresents the true optimal set.
  *Why unfixed:* only reachable with pathological objectives or collinear-in-`Z`
  vertices; a fix needs edge-collinearity detection.

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
- A minimal reference-image test setup (e.g. `tytanic`) beyond the compile-only
  regression file in `tests/`.

### Feature ideas

- **A truly minimal preset.** Sugar for `table: false, gradient: false,
  objective: none` (region + lines + vertices only), the common "statement" look,
  so callers don't repeat the flags.
- Consider a shorthand for passing the objective as `Z = a x + b y` symbolically
  (today it's `objective: (a, b)`), matching how textbooks write it.

### Out of scope (decided)

- **Plain half-plane systems (no LP framing)** — drawing the intersection of a
  *system of linear inequalities*, including **unbounded** regions, with **no
  vertex/optimum** annotation (a mesh-fill approach, pre-optimization exercises).
  Considered and **rejected here**: it contradicts this package's vertex-centric
  identity and would add a second, unrelated rendering algorithm. It stays as a
  separate `semiplano` function in the private `mate-graficas` package.

## Before publishing to Typst Universe

- [x] Confirm the name `feasible-region` is free in the index.
- [x] Final visual pass on the gallery images.
- [x] Submit a PR to `typst/packages` (`packages/preview/quick-vertex/0.1.0/`, renamed from `feasible-region` per reviewer feedback).
- [x] `0.1.1`: equal aspect ratio (`∇Z` now truly perpendicular; `equal-aspect: false` opt-out with synced/independent tick steps), exterior-bisector vertex labels, native `.any()` dedup, overflow-safe "unbounded objective" message. PR submitted to `typst/packages`: [#5391](https://github.com/typst/packages/pull/5391) (pending review).
