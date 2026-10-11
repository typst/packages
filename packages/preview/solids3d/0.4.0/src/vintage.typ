// Optional illustration styles inspired by the visual vocabulary of old
// scientific plates: warm paper, sepia ink, engraved hatching, and vector
// pencil passes. Pencil contours are stroked with a nibart elliptical nib; the
// shaded surfaces of a `vintage` / `pencil` picture are engraved (tonal line work).

#import "picture.typ": *
#import "pens.typ": *

// A hatch specification accepted by draw(..., hatch: ...). For generic
// surfaces, `spacing` is in 3D user units after projection, `angle` is in
// degrees, and `cross` adds a second family at right angles. `count`, `length`,
// `crosshatch` and `seed` are kept for compatibility (ignored since 0.4.0).
#let vintage-hatch(spacing: 0.24, angle: 35.0, cross: false,
  broken: true, lit: true, segment: 0.22, gap: 0.08,
  light: auto, count: none, length: none, crosshatch: none, seed: 11,
  pen: pencil-pen(paint: vintage-pale-ink, thickness: 0.24pt, roughness: 0.08, passes: 1, opacity: 0.72)) = (
  spacing: spacing,
  angle: angle,
  cross: cross,
  lit: lit,
  broken: broken,
  segment: segment,
  gap: gap,
  light: light,
  count: count,
  length: length,
  crosshatch: crosshatch,
  seed: seed,
  pen: pen,
)

// A deterministic stippling specification (projected patch stipple). The renderer emits vector marks on both SVG and native Typst
// backends. `count` is a target, while `gamma` biases the radius distribution
// toward fine or bold marks. The pure patch fallback limits each projected
// patch to `max-patch-count` marks by default, avoiding an accidental
// multiplication of a global target by every surface patch; raise it for a
// denser engraving.
#let vintage-stipple(count: 42, seed: 0, min-size: 0.012, max-size: 0.028,
  gamma: 1.8, distribution: "random", lit: true, light: auto,
  max-patch-count: 96,
  pen: pencil-pen(paint: vintage-pale-ink, thickness: 0.20pt, roughness: 0.04, passes: 1, opacity: 0.62)) = (
  count: int(count),
  seed: float(seed),
  min-size: float(min-size),
  max-size: float(max-size),
  gamma: float(gamma),
  distribution: distribution,
  light: light,
  lit: lit,
  max-patch-count: int(max-patch-count),
  pen: pen,
)

// Compose the atlas idiom: surface marks are laid before projection and a
// separate contour is drawn on top. Pass `outline: (plain: true, ...)` for a
// conventional vector contour; the hatch/stipple pen remains an elliptical
// nib. `outline: auto` reuses the texture pen, while `outline: none` omits it.
#let vintage-shaded(shape, hatch: auto, stipple: none,
  pen: auto, outline: auto) = {
  let source = if hatch != none and hatch != auto { hatch } else if stipple != none { stipple } else { none }
  let hp = if pen != auto { pen } else if type(source) == dictionary {
    source.at("pen", default: pencil-pen(paint: vintage-ink, thickness: 0.62pt))
  } else { pencil-pen(paint: vintage-ink, thickness: 0.62pt) }
  let op = if outline == none or outline == false { none } else if outline == auto or outline == true { hp } else { outline }
  (
    draw(surface(shape), hatch: hatch, stipple: if hatch == auto and stipple == none { auto } else { stipple }, meshpen: hp),
    if op == none { () } else { draw(shape, frontpen: op) },
  )
}

// Warm material helpers for explicit surface styling.
#let vintage-material(color: vintage-wash, opacity: 0.82) = material(
  diffuse: withopacity(color, opacity),
  opacity: opacity,
  shininess: 0.15,
)

#let vintage-style = (
  name: "vintage",
  paper: vintage-paper,
  ink: vintage-ink,
  pale-ink: vintage-pale-ink,
  wash: vintage-wash,
)

#let pencil-style = (
  name: "pencil",
  roughness: 0.18,
  passes: 1,
)

// Convenience wrappers.  The same options as picture are repeated here so
// these functions remain self-contained and work from the public entrypoint.
#let vintage-picture(..cmds, size: auto, width: auto, height: auto, unitsize: 1cm,
  projection: currentprojection, light: currentlight, limits: none, margin: 0pt,
  inset: 0pt, fill: none, stroke: none, radius: 0pt, dotfactor: dotfactor,
  arrowsize: auto, clip: false, baseline: 0pt, zsort: "command", shading: "smooth",
  refine: true, backend: "svg") = picture(..cmds, size: size, width: width, height: height,
  unitsize: unitsize, projection: projection, light: light, limits: limits, margin: margin,
  inset: inset, fill: fill, stroke: stroke, radius: radius, dotfactor: dotfactor,
  arrowsize: arrowsize, clip: clip, baseline: baseline, zsort: zsort, shading: shading,
  refine: refine, backend: backend, style: "vintage")

#let pencil-picture(..cmds, size: auto, width: auto, height: auto, unitsize: 1cm,
  projection: currentprojection, light: currentlight, limits: none, margin: 0pt,
  inset: 0pt, fill: none, stroke: none, radius: 0pt, dotfactor: dotfactor,
  arrowsize: auto, clip: false, baseline: 0pt, zsort: "command", shading: "smooth",
  refine: true, backend: "svg") = picture(..cmds, size: size, width: width, height: height,
  unitsize: unitsize, projection: projection, light: light, limits: limits, margin: margin,
  inset: inset, fill: fill, stroke: stroke, radius: radius, dotfactor: dotfactor,
  arrowsize: arrowsize, clip: clip, baseline: baseline, zsort: zsort, shading: shading,
  refine: refine, backend: backend, style: "pencil")

// A path/surface convenience helper.  `pencil-picture` is preferable for
// a complete scene because it also styles generated surface meshes and applies
// the illustration palette.  For a revolution, implicit hidden pens are still
// removed here; an explicitly supplied back pen remains a request by the user.
#let pencil-draw(..args, pen: auto, surfacepen: auto, arrow: none, label: none,
  align: auto, light: auto, meshpen: none, m: auto, n: nslice, frontpen: auto,
  backpen: auto, longitudinalpen: auto, longitudinalbackpen: auto,
  ninterpolate: auto, seam: auto, hatch: auto, stipple: auto) = {
  let pp = if pen == auto { pencil-pen() } else { pencilize-pen(pen) }
  let sp = if surfacepen == auto { surfacepen } else { pencilize-pen(surfacepen) }
  let mp = if meshpen == none { none } else { pencilize-pen(meshpen) }
  let bp = if backpen == auto { none } else { pencilize-pen(backpen) }
  let lbp = if longitudinalbackpen == auto { none } else { pencilize-pen(longitudinalbackpen) }
  draw(..args, pen: pp, surfacepen: sp, arrow: arrow, label: label, align: align,
    light: light, meshpen: mp, m: m, n: n, frontpen: frontpen, backpen: bp,
    longitudinalpen: longitudinalpen, longitudinalbackpen: lbp,
    ninterpolate: ninterpolate, seam: seam, hatch: hatch, stipple: stipple)
}
