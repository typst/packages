#import "@preview/cetz:0.4.2"


/// Draw a zigzag wire between two points.
///
/// Inspired by https://git.kb28.ch/HEL/circuiteria/src/branch/main/src/wire.typ
///
/// - points-style (coordinate, style): The two points to connect and the style.
/// - ratio (float): The ratio for the zigzag displacement.
/// - direction (string): The direction of the zigzag, either "vertical" or "horizontal".
/// - name (none, str): The name.
/// -> group: Draws the zigzag wire between two points.
#let wire(..points-style, ratio: 0.5, direction: "vertical", name: none) = {
  import cetz.draw: *
  import cetz.coordinate: resolve
  let style = points-style.named()
  let points = points-style.pos()
  if points.len() != 2 {
    error("wire function requires exactly two points.")
  }
  group(name: name, ctx => {
    let (ctx, start, end) = resolve(ctx, ..points)
    let zig = if direction == "vertical" {
      ((start.at(0) + end.at(0)) / 2, start.at(1))
    } else {
      (start.at(0), (start.at(1) + end.at(1)) / 2)
    }
    let zag = if direction == "vertical" {
      ((start.at(0) + end.at(0)) / 2, end.at(1))
    } else {
      (end.at(0), (start.at(1) + end.at(1)) / 2)
    }
    // Reset points to use element-line-intersection
    // which is a private function
    // https://github.com/cetz-package/cetz/blob/0d90a47c69bdb0463be0f24f94d2c0fbb4ae702a/src/draw/shapes.typ#L570
    (start, end) = points
    line(start, zig, zag, end, ..style)
    anchor("start", start)
    anchor("end", end)
    anchor("zig", zig)
    anchor("zag", zag)
  })
}
