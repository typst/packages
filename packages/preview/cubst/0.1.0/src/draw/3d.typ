// 3D renderer built on CeTZ: an orthographic view of the puzzle from a
// camera direction, drawing the stickers that point towards the camera, far
// ones first. The puzzle supplies the cameras (one for the `full` view, one
// per tip for the pyraminx); other faces are shown by rotating the *state*.
// A sticker's normal is its face's, unless the model gives the sticker its
// own (Square-1, whose side stickers point anywhere).

#import "../deps.typ": cetz
#import "../geom.typ" as g
#import "../state.typ": assert-puzzle
#import "../puzzles/registry.typ" as registry
#import "common.typ": default-palette, fill-of, abs-pt

// A unit edge along the camera's up direction is drawn this long (the usual
// isometric drawing scale).
#let view-scale = calc.sqrt(1.5)

/// Draw a puzzle in 3D.
///
/// - `camera`: `(dir:, up:)`, the direction from the puzzle towards the viewer
///   and which way is up; `auto` = the puzzle's `full` camera.
/// - `sticker`: length of one unit (absolute length).
/// - `gap`: space between stickers, shown in `body` color.
/// - `body`: color of the puzzle body behind the stickers (`none` = not drawn).
#let draw-3d(
  c,
  camera: auto,
  sticker: 6mm,
  gap: 0pt,
  stroke: 0.5pt + black,
  palette: default-palette,
  hidden: auto,
  body: none,
) = {
  assert-puzzle(c, who: "draw-3d")
  let model = registry.model(c)
  let camera = if camera == auto { (registry.of(c).cameras)(c.params).full } else { camera }
  assert(camera != none, message: "cubst: the " + c.event + " has no 3D view")
  let s = abs-pt(sticker, "sticker")
  let gp = abs-pt(gap, "gap") / s

  let zs = g.unit(camera.dir)
  let ys = g.unit(g.project-onto-plane(camera.up, zs))
  let xs = g.cross(ys, zs)
  let proj(p) = (g.dot(p, xs) * view-scale, g.dot(p, ys) * view-scale)
  let normal-of(st) = if "normal" in st { st.normal } else { model.faces.at(st.face).normal }
  // a 2D frame in the sticker's plane, for the gap inset
  let frame-of(st) = if "normal" in st {
    let n = st.normal
    g.frame(g.centroid(st.poly), n, if calc.abs(n.at(1)) > 0.9 { (0, 0, 1) } else { (0, 1, 0) })
  } else { model.faces.at(st.face).frame }
  let visible = model.stickers.filter(st => g.dot(normal-of(st), zs) > 1e-6)
  assert(visible.len() > 0, message: "cubst: the camera sees no face")
  // convex puzzles need no depth order; a shape-shifter is drawn far to near
  let ordered = if model.stickers.any(st => "normal" in st) {
    visible.sorted(key: st => g.dot(g.centroid(st.poly), zs))
  } else { visible }

  box(cetz.canvas(length: sticker, {
    import cetz.draw: line
    if body != none {
      for (name, f) in model.faces {
        if g.dot(f.normal, zs) > 1e-6 and f.verts.len() > 2 { line(..f.verts.map(proj), close: true, fill: body, stroke: none) }
      }
    }
    for st in ordered {
      // inset in the sticker's plane, then back to 3D and onto the screen
      let fr = frame-of(st)
      let poly = g.inset(st.poly.map(p => g.to-local(fr, p)), gp).map(q => g.from-local(fr, q))
      line(..poly.map(proj), close: true, fill: fill-of(c.faces.at(st.face).at(st.index), palette, hidden), stroke: stroke)
    }
  }))
}
