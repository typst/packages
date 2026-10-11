#import "@preview/solids3d:0.4.0": *

#set page(width: 21cm, height: 29.7cm, margin: (x: 16mm, y: 13mm), fill: vintage-paper)
#set text(font: "DejaVu Serif", size: 8.5pt, fill: vintage-ink)

#let P = perspective(4.2, 5.2, 3.0)
// The nib sample is a 2-D stroke; keep its projection frontal so its
// pressure profile is not skewed by the atlas camera.
#let Pstroke = orthographic(0, 0, 10, up: Y, zoom: 1)
#let light = (1.0, -0.35, 1.0)
#let broad-pen = pencil-pen(paint: vintage-ink, thickness: 0.72pt, nib-major: 1.1, nib-ratio: 0.42)
#let close-pen = pencil-pen(paint: vintage-ink, thickness: 0.68pt, nib-major: 1.05, nib-ratio: 0.30,
  pressure: (minimum-axis: 0.0075, period: 0.11, seed: 41))
#let crossed-pen = pencil-pen(paint: vintage-ink, thickness: 0.64pt, nib-major: 1.0, nib-ratio: 0.25,
  pressure: (minimum-axis: 0.0075, period: 0.10, seed: 59))

#let outline-pen = pencil-pen(paint: vintage-ink, thickness: 0.95pt, nib-major: 1.05, nib-ratio: 0.30)
#let broad-hatch-pen = pencil-pen(paint: vintage-ink, thickness: 0.82pt, nib-major: 1.1, nib-ratio: 0.42)
#let close-hatch-pen = pencil-pen(paint: vintage-ink, thickness: 0.74pt, nib-major: 1.05, nib-ratio: 0.30)
#let crossed-hatch-pen = pencil-pen(paint: vintage-ink, thickness: 0.70pt, nib-major: 1.0, nib-ratio: 0.25)
#let stipple-pen = pencil-pen(paint: vintage-ink, thickness: 0.70pt, nib-major: 0.9, nib-ratio: 0.40)
#let broad = vintage-hatch(count: 420, length: 0.30, crosshatch: 1.0, seed: 11, pen: broad-hatch-pen)
#let close = vintage-hatch(count: 760, length: 0.22, crosshatch: 1.0, seed: 11, pen: close-hatch-pen)
#let crossed = vintage-hatch(count: 980, length: 0.18, crosshatch: 0.76, seed: 11, pen: crossed-hatch-pen)
#let specimen(shape, pattern, pen, outline: false) = picture(
  width: 1.55cm,
  height: 1.8cm,
  projection: P,
  light: light,
  style: "vintage",
  draw(surface(shape), hatch: pattern, meshpen: pen),
  if outline { draw(shape, frontpen: outline-pen) } else { () },
)

#align(center)[
  #text(size: 8.5pt, tracking: 0.8pt, style: "italic")[#smallcaps[Plate VI]]
  #v(3pt)
  #text(size: 13pt, weight: "bold")[An Atlas of Line Shading]
  #v(2pt)
  #text(size: 8.5pt, fill: gray(0.35), style: "italic")[the density and crossing of strokes governed by illumination]
]
#v(8.5mm)

#grid(columns: (16mm, 1fr, 1fr, 1fr), column-gutter: 3mm, row-gutter: 6.5mm, align: center + horizon,
  [],
  text(size: 8.5pt, style: "italic")[I. Broad contour],
  text(size: 8.5pt, style: "italic")[II. Broken close contour],
  text(size: 8.5pt, style: "italic")[III. Broken crossed shadow],
  rotate(-90deg, text(size: 8.5pt, tracking: 0.8pt, smallcaps[Sphere])),
  specimen(sphere(O, 1), broad, broad-pen, outline: true),
  specimen(sphere(O, 1), close, close-pen, outline: true),
  specimen(sphere(O, 1), crossed, crossed-pen, outline: true),
  rotate(-90deg, text(size: 8.5pt, tracking: 0.8pt, smallcaps[Cone])),
  specimen(cone(0.82, 2.15), broad, broad-pen, outline: true),
  specimen(cone(0.82, 2.15), close, close-pen, outline: true),
  specimen(cone(0.82, 2.15), crossed, crossed-pen, outline: true),
  rotate(-90deg, text(size: 8.5pt, tracking: 0.8pt, smallcaps[Cylinder])),
  specimen(cylinder(0.72, 2.1), broad, broad-pen, outline: true),
  specimen(cylinder(0.72, 2.1), close, close-pen, outline: true),
  specimen(cylinder(0.72, 2.1), crossed, crossed-pen, outline: true),
  rotate(-90deg, text(size: 8.5pt, tracking: 0.8pt, smallcaps[Torus])),
  specimen(torus(0.78, 0.30), broad, broad-pen, outline: true),
  specimen(torus(0.78, 0.30), close, close-pen, outline: true),
  specimen(torus(0.78, 0.30), crossed, crossed-pen, outline: true),
)

#v(5mm)
#grid(columns: (1fr, 1fr), gutter: 7mm, align: center,
  [
    #picture(width: 1.55cm, height: 1.55cm, projection: P, style: "vintage",
      draw(surface(sphere(O, 1)), hatch: none, stipple: vintage-stipple(
        count: 5600, min-size: 0.004, max-size: 0.034, gamma: 1.05,
        distribution: "random", seed: 11, pen: stipple-pen), meshpen: broad-pen),
      draw(sphere(O, 1), frontpen: broad-pen),
    )
    #align(center)[#text(size: 8.5pt, style: "italic")[IV. Random graded stipple]]
  ],
  [
    #picture(width: 1.55cm, height: 1.55cm, projection: P, style: "vintage",
      draw(surface(sphere(O, 1)), hatch: none, stipple: vintage-stipple(
        count: 5600, min-size: 0.004, max-size: 0.034, gamma: 1.05,
        distribution: "fibonacci", seed: 11, pen: stipple-pen), meshpen: broad-pen),
      draw(sphere(O, 1), frontpen: broad-pen),
    )
    #align(center)[#text(size: 8.5pt, style: "italic")[V. Fibonacci graded stipple]]
  ],
)

#let nib-path = mkpath3(
  // The reference stroke is one broad Bézier sweep: dark at the start,
  // visibly bowed in the middle, then tapered below printable width.
  ((-6.0, 0.0, 0.0), (6.0, 0.0, 0.0)),
  ((-6.0, 0.0, 0.0), (2.0, -0.5, 0.0)),
  ((-2.0, 0.5, 0.0), (6.0, 0.0, 0.0)),
  (false,),
  false,
)
#v(4mm)
#align(center)[#picture(width: 12.5cm, height: 1.8cm, inset: 0.1cm, projection: Pstroke, style: "vintage",
  draw(nib-path, pen: pencil-pen(
    paint: vintage-ink, thickness: 1pt,
    samples: (
      (arclength: 0.0, a: 0.18, b: 0.085, angle: 18deg),
      (arclength: 6.0, a: 0.09, b: 0.035, angle: 18deg),
      (arclength: 12.1, a: 0.025, b: 0.008, angle: 18deg),
    ),
    pressure: (minimum-axis: 0.028, period: 0.32, seed: 17))),
)]
#align(center)[#text(size: 8.5pt, style: "italic")[VI. A tapered nib stroke, breaking below the printable width.]]
#v(5mm)
#grid(columns: (1fr, 1fr), gutter: 12mm,
  [
    #text(size: 9pt, smallcaps[Construction.])
    #h(0.3em)
    Marks are laid on each solid before projection. Their extent increases as
    the surface normal turns from the light; hidden portions are removed by the geometry.
  ],
  [
    #text(size: 9pt, smallcaps[Observation.])
    #h(0.3em)
    No gray tone is painted. Apparent shade arises from the number, direction,
    and crossing of discrete engraved paths, all swept with the same elliptical nib.
  ],
)
