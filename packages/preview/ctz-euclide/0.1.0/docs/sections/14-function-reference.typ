// Function Reference
#import "../helpers.typ": *

= Function Reference

== Point Definition
- `ctz-def-points(A: (x, y), ...)` — Define named points
- `ctz-def-line(name, a, b)` — Named line from two points
- `ctz-def-circle(name, center, radius|through)` — Named circle
- `ctz-def-polygon(name, a, b, c, ...)` — Named polygon
- `ctz-def-midpoint(name, a, b)` — Midpoint of segment
- `ctz-def-linear(name, a, b, k)` — Point at ratio k along line
- `ctz-def-regular-polygon([name,] names, center, first)` — Regular n-gon vertices (optionally register polygon name)
- `ctz-def-point-on-circle(name, center, radius, angle)` — Point on circle at angle
- `ctz-def-equilateral(name, a, b)` — Third vertex of equilateral triangle
- `ctz-def-golden(name, a, b)` — Golden ratio point

== Line Constructions
- `ctz-def-perp(n1, n2, line, through)` — Perpendicular through point
- `ctz-def-para(n1, n2, line, through)` — Parallel through point
- `ctz-def-bisect(n1, n2, a, vertex, c)` — Angle bisector
- `ctz-def-mediator(n1, n2, a, b)` — Perpendicular bisector

== Intersections
- `ctz-def-ll(name, line1, line2)` — Line-line intersection
- `ctz-def-lc(names, line, circle)` — Line-circle intersections
- `ctz-def-cc(names, circle1, circle2)` — Circle-circle intersections

== Triangle Centers
- `ctz-def-centroid`, `ctz-def-circumcenter`, `ctz-def-incenter`, `ctz-def-orthocenter`
- `ctz-def-euler`, `ctz-def-lemoine`, `ctz-def-nagel`, `ctz-def-gergonne`, `ctz-def-spieker`
- `ctz-def-feuerbach`, `ctz-def-mittenpunkt`, `ctz-def-excenter`

== Special Triangles
- `ctz-def-medial-triangle(na, nb, nc, a, b, c)` — Medial triangle
- `ctz-def-orthic-triangle(na, nb, nc, a, b, c)` — Orthic triangle
- `ctz-def-intouch-triangle(na, nb, nc, a, b, c)` — Intouch triangle
- `ctz-def-thales-triangle(na, nb, nc, center, radius, ...)` — Right triangle via Thales' theorem

== Transformations
- `ctz-def-rotation(name, source, center, angle)` — Rotation (works on all object types)
- `ctz-def-reflect(name, source, line-a, line-b)` — Reflection
- `ctz-def-translate(name, source, vector)` — Translation
- `ctz-def-homothety(name, source, center, factor)` — Homothety
- `ctz-def-project(name, source, line-a, line-b)` — Projection
- `ctz-def-inversion(name, source, center, radius)` — Inversion (works on points, lines, circles, polygons)
- `ctz-duplicate(target, source, points: auto)` — Duplicate any geometric object

== Drawing
- `ctz-draw(name, ...)` or `ctz-draw(points: ..., labels: ...)` — Draw any object type (polymorphic) or draw/label points using unified API
- `ctz-draw-points(names...)` — Draw points (legacy, prefer unified `ctz-draw()`)
- `ctz-draw-labels(names, placements)` — Label points (legacy, prefer unified `ctz-draw()`)
- `ctz-style(point: (...))` — Set styling
- `ctz-draw-angle(vertex, a, b, ...)` — Mark angle
- `ctz-draw-mark-right-angle(a, vertex, c, ...)` — Right angle mark
- `ctz-draw-segment(a, b, ...)` — Draw segment
- `ctz-draw-measure-segment(a, b, ...)` — Offset measurement with fences and label
- `ctz-draw-path(spec, ...)` — Draw path with per-segment tips
- `ctz-draw-polygon(points...)` — Draw polygon (triangle, quadrilateral, etc.)
- `ctz-draw-fill-polygon(points...)` — Fill polygon
- `ctz-draw-regular-polygon(names, ...)` — Draw regular polygon by vertex names
- `ctz-draw-fill-regular-polygon(names, ...)` — Fill regular polygon by vertex names
- `ctz-draw-circle(name, ...)` — Draw named circle
- `ctz-label-circle(name, label, ...)` — Label named circle
- `ctz-label-polygon(name, label, ...)` — Label named polygon
- `ctz-draw-circumcircle(a, b, c, ...)` — Circumscribed circle
- `ctz-draw-incircle(a, b, c, ...)` — Inscribed circle

== Clipping
- `ctz-set-clip(xmin, ymin, xmax, ymax)` — Set clip region
- `ctz-clear-clip()` — Clear clip region
- `ctz-draw-line-global-clip(a, b, ...)` — Draw clipped line
- `ctz-draw-seg-global-clip(a, b, ...)` — Draw clipped segment

== Grid Positioning
- `triangular-pos(row, col, ...)` — Position in triangular grid (Pascal layout)
- `grid-pos(row, col, ...)` — Position in rectangular grid
- `hex-pos(row, col, ...)` — Position in hexagonal grid
- `binomial(n, k)` — Binomial coefficient C(n,k)

== Grid Drawing
- `draw-triangular-grid(cetz-draw, rows, content-fn, ...)` — Draw triangular grid with custom content
- `draw-rectangular-grid(cetz-draw, rows, cols, content-fn, ...)` — Draw rectangular grid
- `draw-pascal-values(cetz-draw, rows, ...)` — Draw Pascal's triangle values
- `draw-row-labels(cetz-draw, rows, ...)` — Draw row labels
- `draw-diagonal-labels(cetz-draw, count, ...)` — Draw diagonal labels

== Annotations
- `highlight-fill(cetz-draw, pos, ...)` — Filled circle highlight
- `highlight-outline(cetz-draw, pos, ...)` — Outlined circle highlight
- `highlight-many(cetz-draw, positions, ...)` — Highlight multiple positions
- `curved-arrow(cetz-draw, from, to, ...)` — Curved annotation arrow
- `smooth-arrow(cetz-draw, from, to, waypoints, ...)` — Smooth spline arrow
- `draw-addition-indicator(cetz-draw, a, b, result, ...)` — Show addition relationship
- `draw-brace-h(cetz-draw, start, end, ...)` — Horizontal brace
- `draw-brace-v(cetz-draw, start, end, ...)` — Vertical brace

#pagebreak()

