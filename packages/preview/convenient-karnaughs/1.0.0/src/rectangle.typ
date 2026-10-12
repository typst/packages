
#import "./point.typ": neighbour, point, x, y

/// -> rectangle
#let rectangle(
  /// Left boundary. Inclusive.
  /// -> int
  left,
  /// Top boundary. Inclusive.
  /// -> int
  top,
  /// Right boundary. Exclusive.
  /// -> int
  right,
  /// Bottom boundary. Exclusive.
  /// -> int
  bottom,
) = (left: left, top: top, right: right, bottom: bottom)

/// -> int
#let width(
  /// -> rectangle
  rect,
) = rect.right - rect.left

/// -> int
#let height(
  /// -> rectangle
  rect,
) = rect.bottom - rect.top

/// -> side
#let left = "left"
/// -> side
#let top = "top"
/// -> side
#let right = "right"
/// -> side
#let bottom = "bottom"
/// -> array
#let all-sides = (left, top, right, bottom)

/// -> corner
#let top-left = "top-left"
/// -> corner
#let top-right = "top-right"
/// -> corner
#let bottom-right = "bottom-right"
/// -> corner
#let bottom-left = "bottom-left"
/// -> array
#let all-corners = (top-left, top-right, bottom-right, bottom-left)
/// -> array
#let adjacent-sides(
  /// -> corner
  corner,
) = (
  "top-left": (top, left),
  "top-right": (top, right),
  "bottom-right": (bottom, right),
  "bottom-left": (bottom, left),
).at(corner)

/// -> array
#let just-outside(
  /// -> side
  side,
  /// -> rectangle
  rect,
) = (
  left: point(rect.left - 1, rect.top),
  top: point(rect.left, rect.top - 1),
  right: point(rect.right, rect.top),
  bottom: point(rect.left, rect.bottom),
).at(side)

/// -> array
#let just-insides(
  /// -> side
  side,
  /// -> rectangle
  rect,
) = (
  left: range(rect.top, rect.bottom).map(y => point(rect.left, y)),
  top: range(rect.left, rect.right).map(x => point(x, rect.top)),
  right: range(rect.top, rect.bottom).map(y => point(rect.right - 1, y)),
  bottom: range(rect.left, rect.right).map(x => point(x, rect.bottom - 1)),
).at(side)

/// Combines connected points into rectangles.
///
/// Assumes all connected groups form rectangles and input is in row-major
/// order.
///
/// ```examplec
///
/// ```
/// -> array
#let merge-rectangles(
  /// -> array
  points,
) = (
  points
    // `rect-ids` maps points to rect-ids, `rect` maps rect-ids to point arrays
    .fold((rect-ids: (:), rects: (:)), (
      ((rect-ids, rects), point) => {
        let neighbour = side => neighbour(side, point)
        let (rect-id, rect) = if points.contains(neighbour(left)) {
          let rect-id = rect-ids.at(repr(neighbour(left)))
          (rect-id, rects.at(rect-id))
        } else if points.contains(neighbour(top)) {
          let rect-id = rect-ids.at(repr(neighbour(top)))
          (rect-id, rects.at(rect-id))
        } else {
          (repr(point), ())
        }
        (
          rect-ids: (..rect-ids, repr(point): rect-id),
          rects: (..rects, (rect-id): (..rect, point)),
        )
      }
    ))
    .rects
    .values()
    .map(points => rectangle(
      calc.min(..points.map(x)),
      calc.min(..points.map(y)),
      calc.max(..points.map(x)) + 1,
      calc.max(..points.map(y)) + 1,
    ))
)

// #{
//   import "@preview/tidy:0.4.3"

//   tidy.show-module(
//     tidy.parse-module(
//       read("./kv.typ"),
//       name: "rectangle",
//       scope: (
//         _merge-rectangles: merge-rectangles,
//         rectangle: rectangle,
//         width: width,
//         height: height,
//         adjacent-sides: adjacent-sides,
//         just-outside: just-outside,
//       ),
//       preamble: ```typ
//         #set text(font: "libertinus serif")

//       ```.text,
//     ),
//     first-heading-level: 1,
//     omit-private-definitions: true,
//     omit-private-parameters: true,
//     sort-functions: none,
//   )
// }
