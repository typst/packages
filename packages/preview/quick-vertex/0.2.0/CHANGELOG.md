# Changelog

## 0.2.0 — 2026-10-12

- Replace angular sampling with analytic recession directions and normalize
  constraints/objectives before geometric comparisons.
- Separate feasibility and optimization from the visible frame; support
  half-planes, strips, lines and the whole plane without vertices.
- Check strict feasibility and distinguish attained optima from unattained
  suprema/infima. Mark excluded closure vertices with hollow points and `○`.
- Add the pure `analyze` function, returning feasibility, boundedness and
  optimal-face data without rendering.
- Validate coefficients, operators, colors, sense, dimensions and labels;
  check constant constraints and floating-point overflow explicitly.
- Treat a zero objective as optimal on the entire feasible region.
- Fix duplicate frame intersections and solid strict-boundary underlays.
- Name the objective family "Level lines" / "Rectas de nivel" and label the
  optimization direction `max Z` / `min Z`. Keep `gradient` as the compatible
  arrow flag; `gradient: false` retains the level lines.
- Preserve objective diagnostics when the vertex table is hidden, and wrap
  unbounded-objective warnings correctly on auto-sized pages.
- Add mathematical assertions, comparisons against exact Fourier–Motzkin
  projection, input-validation checks and text/SVG regressions.

Compatibility: Typst 0.14.0 or newer; CeTZ 0.5.2. Inputs that used unsupported
operators or senses, incomplete labels, invalid colors, nonpositive dimensions
or margins below 1 now fail with explicit errors.
