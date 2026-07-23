// Theme data and per-primitive style resolution for the scene renderer.
//
// A theme is plain data: a colour `palette` for auto-colouring, a world-space
// `light` direction for flat face shading, a set of global `defaults`, and one
// override dictionary per primitive `kind`. Nothing here touches cetz — style
// resolution is a pure dictionary merge so it is importable and testable on its
// own.
//
// `resolve-style(theme, prim)` merges three layers, right-most winning:
//   theme.defaults  <-  theme.<kind>  <-  the prim's own styling hooks
// The prim's styling hooks are every named field that is not structural
// geometry (see `_STRUCT`): e.g. `color`, `w`, `head` ride along verbatim from
// the `scene.typ` constructors and override the theme.

#import "linalg.typ": vsub, vcross, vdot, vlen, vscale, vnorm

/// The built-in theme. All lengths are absolute; widths named `w` are in scene
/// units (scaled by the renderer's `unit`), matching `seg`/`arrow` conventions.
#let default-theme = (
  // Qualitative palette for auto-colouring successive primitives.
  palette: (
    rgb("#4c72b0"), rgb("#dd8452"), rgb("#55a868"), rgb("#c44e52"),
    rgb("#8172b3"), rgb("#937860"), rgb("#da8bc3"), rgb("#8c8c8c"),
    rgb("#ccb974"), rgb("#64b5cd"),
  ),
  // World-space direction the light comes from; used to shade mesh/face fills.
  light: (-0.4, -0.5, 0.8),
  // Global fallbacks, merged under every per-kind block.
  defaults: (
    color: luma(160),
    stroke-darken: 40%,
    stroke-width: 0.5pt,
  ),
  sphere: (
    color: luma(185),
    stroke-darken: 45%,
    stroke-width: 0.5pt,
    specular: true, // specular highlight stop in the ball gradient (issue #30)
  ),
  seg: (
    color: luma(90),
    w: 0.12, // stroke width in scene units
  ),
  edge: (
    color: luma(120),
    width: 0.7pt, // absolute stroke thickness
    dash: "solid",
  ),
  arrow: (
    color: black,
    w: 0.05, // stroke width in scene units
    head: ">",
    head-scale: 22, // arrowhead size = head-scale * w * unit
  ),
  face: (
    color: rgb("#6a9fd8"),
    fill-opacity: 55%, // transparentize amount; 0% = opaque
    stroke-darken: 35%,
    stroke-width: 0.5pt,
    shade: true, // apply flat lighting to the fill
  ),
  label: (
    color: black,
    size: 7pt,
    weight: "bold",
    text-anchor: none,
  ),
)

/// Structural (geometry) fields carried by a primitive. Everything else on a
/// primitive dictionary is treated as a styling hook.
#let _STRUCT = (
  "kind", "name", "anchor", "center", "r", "a", "b", "from", "to", "pts",
  "vertices", "faces", "at", "text", "depth", "mesh-face", "mesh-center",
  "rear-face", "draw-head", "depth-key",
)

/// The styling hooks on a primitive: its named fields minus structural geometry.
///
/// - prim (dictionary): A scene primitive.
/// -> dictionary
#let style-hooks(prim) = {
  let d = (:)
  for (k, v) in prim {
    if k not in _STRUCT { d.insert(k, v) }
  }
  d
}

/// Resolves the effective style for a primitive against a theme.
///
/// Merges `theme.defaults`, then the theme's per-kind override block, then the
/// primitive's own styling hooks (right-most wins). Pure data; no cetz.
///
/// - theme (dictionary): A theme (see `default-theme`).
/// - prim (dictionary): A scene primitive with a `kind` field.
/// -> dictionary
#let resolve-style(theme, prim) = {
  let base = theme.at("defaults", default: (:))
  let per = theme.at(prim.kind, default: (:))
  base + per + style-hooks(prim)
}

/// Picks colour `i` from a theme's palette, wrapping around.
///
/// - theme (dictionary): A theme with a `palette` array.
/// - i (int): Index (any integer; taken modulo the palette length).
/// -> color
#let palette-color(theme, i) = {
  let p = theme.palette
  p.at(calc.rem(calc.rem(i, p.len()) + p.len(), p.len()))
}

/// Brightness in `[0.55, 1]` for a flat-shaded polygon: `0.55 + 0.45·|n · light|`
/// where `n` is the polygon's face normal and `light` the world light
/// direction. Degenerate polygons (fewer than three points or collinear) return
/// full brightness.
///
/// - pts (array): The polygon's 3D vertices.
/// - light (vector): World-space light direction.
/// -> float
#let face-brightness(pts, light) = {
  if pts.len() < 3 { return 1.0 }
  let n = vcross(vsub(pts.at(1), pts.at(0)), vsub(pts.at(2), pts.at(0)))
  let ln = vlen(n)
  if ln < 1e-9 { return 1.0 }
  // |n·light| is winding-agnostic (hull/mesh faces have no guaranteed
  // orientation); the [0.55, 1] remap keeps shaded solids luminous instead of
  // crushing side-facing facets toward black
  0.55 + 0.45 * calc.abs(vdot(vscale(n, 1 / ln), vnorm(light)))
}
