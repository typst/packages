// Camera + projection for the scene core.
// Pure functions, no cetz dependency: a camera is a plain dictionary and
// `project` maps a 3-point to screen coordinates plus a depth value.

/// Creates a camera.
///
/// The view frame is pinned (see `project`): with `azimuth == elevation == 0deg`
/// the view looks along $+y$ with $+x$ to the right and $+z$ up; depth grows
/// toward the viewer.
///
/// - azimuth (angle): Rotation about the vertical axis.
/// - elevation (angle): Tilt above the horizontal plane.
/// - mode (str): `"orthographic"` (default) or `"perspective"`.
/// - distance (float): Perspective only — the camera's world-unit distance
///   from the view-space origin along the depth axis. Smaller = stronger
///   foreshortening; must exceed the scene's greatest depth. Ignored (and not
///   stored) for orthographic cameras, so the orthographic camera dictionary
///   is identical to earlier versions.
/// -> camera
#let camera(azimuth: 25deg, elevation: 15deg, mode: "orthographic", distance: 25.0) = {
  assert(mode in ("orthographic", "perspective"),
    message: "camera mode must be \"orthographic\" or \"perspective\", got " + repr(mode))
  if mode == "perspective" {
    assert(type(distance) in (int, float) and distance > 0,
      message: "perspective camera distance must be a positive number, got " + repr(distance))
    (mode: "perspective", azimuth: azimuth, elevation: elevation, distance: distance)
  } else {
    (mode: "orthographic", azimuth: azimuth, elevation: elevation)
  }
}

/// Creates a 2D identity camera.
///
/// Flat diagrams share the 3D pipeline: `project` passes $(x, y, z)$ straight
/// through to `(sx: x, sy: y, depth: 0)`.
/// -> camera
#let camera-2d() = (mode: "2d")

/// The screen-per-world scale factor at camera depth `depth`: how much a world
/// length placed at that depth is magnified on screen.
///
/// Orthographic and 2d cameras return exactly `1.0` — world radii ARE screen
/// radii there, and every pre-perspective consumer relies on that identity.
/// A perspective camera returns `distance / (distance - depth)`, which is how
/// a world radius `r` at that depth maps to screen: `r * project-scale(..)`.
///
/// - cam (camera): The camera.
/// - depth (float): A camera depth as returned by `project(..).depth`.
/// -> float
#let project-scale(cam, depth) = {
  if cam.mode != "perspective" { return 1.0 }
  let denom = cam.distance - depth
  assert(denom > 1e-9 * cam.distance,
    message: "scenery: point at camera depth " + repr(depth)
      + " is at or behind the perspective camera (distance: " + repr(cam.distance)
      + "); increase the camera's distance")
  cam.distance / denom
}

/// Projects a 3-point to screen coordinates plus depth.
///
/// For an orthographic camera the pinned convention is
/// $x_1 = x cos("az") + y sin("az")$, $y_1 = -x sin("az") + y cos("az")$,
/// $"sx" = x_1$, $"sy" = -y_1 sin("el") + z cos("el")$,
/// $"depth" = y_1 cos("el") + z sin("el")$.
///
/// A perspective camera multiplies `sx`/`sy` by `project-scale(cam, depth)`
/// (divide-by-depth); `depth` itself stays the unscaled view depth, so depth
/// sorting is identical across the two 3D modes.
///
/// For a 2D camera the point passes through as `(sx: x, sy: y, depth: 0)`.
///
/// - cam (camera): The camera to project through.
/// - point (vector): The 3-point $(x, y, z)$ to project.
/// -> dictionary
#let project(cam, point) = {
  let (x, y, z) = point
  if cam.mode == "2d" {
    return (sx: x, sy: y, depth: 0)
  }
  let az = cam.azimuth
  let el = cam.elevation
  let x1 = x * calc.cos(az) + y * calc.sin(az)
  let y1 = -x * calc.sin(az) + y * calc.cos(az)
  let sy = -y1 * calc.sin(el) + z * calc.cos(el)
  let depth = y1 * calc.cos(el) + z * calc.sin(el)
  if cam.mode == "perspective" {
    let s = project-scale(cam, depth)
    return (sx: x1 * s, sy: sy * s, depth: depth)
  }
  (sx: x1, sy: sy, depth: depth)
}
