// education.typ — helpers for collège-style geometry diagrams.
//
// These small builders keep annotations in the same command language as
// picture(): they return drawing-command arrays, so they can be mixed with
// draw(), dot(), labels and surfaces.  The notation is intentionally neutral
// and is inspired by the kinds of annotated figures used in French teaching
// material, without copying any implementation from pas-cours.

#import "vec.typ": *
#import "path3.typ": *
#import "surface.typ": *
#import "solids.typ": *
#import "pens.typ": *
#import "picture.typ": draw, dot, Label, label, Arrow, BeginArrow, Arrows, Arrow3, Arrows3, E, N, apply

// ---------------------------------------------------------------------------
// Annotation primitives
// ---------------------------------------------------------------------------

// Mark a 3D point and attach its name. `align` is a projected 2D direction;
// dx/dy adjust the label anchor in projected picture units (or absolute Typst
// lengths such as 2pt).
#let point3(name, p, align: E, pen: auto, size: auto, dx: 0, dy: 0) = {
  dot(Label(name, align: align, dx: dx, dy: dy), p, pen, size: size)
}

// A callout whose arrow tip is at `target` and whose label is placed at
// `label-at`.  Using BeginArrow leaves the arrowhead at the target while the
// text remains at the free end of the leader.
#let callout3(text, target, label-at, align: E, pen: auto, arrow: BeginArrow, dx: 0, dy: 0) = {
  draw(Label(text, position: 1, align: align, dx: dx, dy: dy), line3(target, label-at), pen, arrow)
}

// Label an edge or a segment. `offset` is a 3D translation of the dimension
// line. Extension lines are drawn by default, but `extensions: false` makes
// the arrows start directly on the translated dimension line. `pen` controls
// the dimension line and its arrowheads; `extension-pen` controls the small
// attachment lines independently (both accept `solid`, `dashed` and
// `dotted`). The label follows the projected dimension line by default (pass
// `rotate: false` to keep it horizontal, or an angle for a manual override).
// `dx`/`dy` move the centred annotation without changing the 3D dimension line.
#let dimension3(text, a, b, offset: O, align: N, pen: auto, arrow: Arrows, rotate: auto,
  dx: 0, dy: 0, extensions: true, extension-pen: auto) = {
  let aa = vadd(a, offset)
  let bb = vadd(b, offset)
  let out = ()
  let ep = if extension-pen == auto { pen } else { extension-pen }
  if extensions and vabs(offset) > 1e-12 {
    out += draw(line3(a, aa), ep)
    out += draw(line3(b, bb), ep)
  }
  out += draw(Label(text, position: 0.5, align: align, rotate: rotate, dx: dx, dy: dy, center: true), line3(aa, bb), pen, arrow)
  out
}

// Short alias for the common “length of AB” annotation.
#let length3-label(text, a, b, ..args) = dimension3(text, a, b, ..args)

// Put one, two or three conventional equality ticks on an edge. The ticks are
// constructed in 3D and are therefore projected together with the segment.
// `count` is the code used by the teacher: equal counts mean equal lengths.
#let edge-code3(a, b, count: 1, size: 0.14, spacing: 0.16, at: 0.5, direction: auto, pen: auto) = {
  let d = vunit(vsub(b, a))
  let normal = if direction == auto { vperp(d) } else { vunit(direction) }
  let center = interp(a, b, at)
  let count = calc.max(1, int(count))
  let out = ()
  for i in range(count) {
    let shift = (i - (count - 1) / 2) * spacing
    let middle = vadd(center, vmul(shift, d))
    out += draw(line3(
      vadd(middle, vmul(-size / 2, normal)),
      vadd(middle, vmul(size / 2, normal)),
    ), pen: pen)
  }
  out
}

// Apply the same equality code to several edges. Each item of `edges` is a
// pair `(start, end)`.
#let equal-edges3(edges, count: 1, size: 0.14, spacing: 0.16, at: 0.5, direction: auto, pen: auto) = {
  let out = ()
  for edge in edges {
    out += edge-code3(edge.at(0), edge.at(1), count: count, size: size, spacing: spacing, at: at, direction: direction, pen: pen)
  }
  out
}

// A right-angle marker at vertex `b`, for the angle a-b-c.  `size` is in
// model units and the marker is automatically oriented in 3D.
#let right-angle3(a, b, c, size: 0.15, pen: auto) = {
  let u = vmul(size, vunit(vsub(a, b)))
  let v = vmul(size, vunit(vsub(c, b)))
  draw(line3(vadd(b, u), vadd(vadd(b, u), v), vadd(b, v)), pen: pen)
}

// Draw an arc for a non-right angle. `a-b-c` names the angle in the usual
// school order; `b` is the vertex. A label, when supplied, is placed on the
// arc and may be ordinary content or mathematical content such as `$90°$`.
#let angle-mark3(a, b, c, radius: 0.24, pen: auto, label: none, align: N) = {
  let u = vunit(vsub(a, b))
  let v = vunit(vsub(c, b))
  let normal = vcross(u, v)
  if vabs(normal) < 1e-12 { return () }
  let arc = Arc3(b, vadd(b, vmul(radius, u)), vadd(b, vmul(radius, v)), normal: normal, direction: CCW)
  if label == none {
    draw(arc, pen: pen)
  } else {
    draw(Label(label, position: 0.5, align: align), arc, pen: pen)
  }
}

// Unified angle helper. Set `right: true` for the conventional square; with
// `right: false` it draws a circular angle arc.
#let angle-code3(a, b, c, right: false, size: 0.15, radius: 0.24, pen: auto, label: none, align: N) = {
  if right {
    right-angle3(a, b, c, size: size, pen: pen)
  } else {
    angle-mark3(a, b, c, radius: radius, pen: pen, label: label, align: align)
  }
}

// Convenient aliases for classroom prose.
#let vertex3 = point3
#let segment-label3 = dimension3

// A dashed construction line between two points, useful for heights, axes and
// hidden diagonals in school diagrams.
#let construction3(a, b, pen: auto) = draw(line3(a, b), if pen == auto { dashed } else { pen })

// ---------------------------------------------------------------------------
// Reusable educational solids
// ---------------------------------------------------------------------------

// A cuboid (pavé droit) with its lower corner at `origin`.
#let cuboid(origin: O, length: 3, width: 2, height: 1.5) = {
  apply(shift(origin), apply(scale3(length, y: width, z: height), unitcube))
}

#let pave-droit = cuboid

// A true regular polygon, not a smooth Circle3. This distinction matters
// for school figures: n = 3, 4 and 6 must produce triangular, square and
// hexagonal bases rather than a circular approximation.
#let regular-polygon3(center: O, radius: 1, n: 6, angle: 0) = {
  let pts = range(n).map(i => {
    let theta = (angle + 360 * i / n) * 1deg
    vadd(center, (radius * calc.cos(theta), radius * calc.sin(theta), 0))
  })
  line3(..pts, cyclic: true)
}

// Regular pyramid: a polygonal base in the xy-plane and an apex above its
// centre. The result is a surface (base included).
#let regular-pyramid(center: O, radius: 1, height: 2, n: 4, angle: 45) = {
  let base = regular-polygon3(center: center, radius: radius, n: n, angle: angle)
  let vertex = vadd(center, vmul(height, Z))
  surface(cone-over(base, vertex), surface(base))
}

// Regular prism with polygonal bases parallel to the xy-plane.
#let regular-prism(center: O, radius: 1, height: 2, n: 6, angle: 0) = {
  let base = regular-polygon3(center: center, radius: radius, n: n, angle: angle)
  let top = apply(shift((0, 0, height)), base)
  surface(extrude(base, vmul(height, Z)), surface(base), surface(top))
}

// A visible/hidden construction pair for a point projected onto a plane.
#let projection3(p, foot, pen: auto) = construction3(p, foot, pen: pen)
