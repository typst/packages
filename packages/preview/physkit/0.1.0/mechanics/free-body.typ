#import "../primitives/lib.typ" as p
#import "renderer.typ": diagram

/// Render an isolated body with all forces acting on it.
/// If the body has no explicit position, it is placed at `at`.
#let free-body(
  body,
  forces: (),
  at: (0, 0),
  theme: p.default-theme,
) = {
  assert(body.kind == "box",
    message: "free-body currently supports box objects")
  for force in forces {
    assert(force.object == body.id,
      message: "Every free-body force must act on the isolated body")
  }
  let isolated = body
  if isolated.at == none {
    isolated.insert("at", at)
  }
  diagram(objects: (isolated,), forces: forces, theme: theme)
}
