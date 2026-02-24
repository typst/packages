#import "math.typ"

/// The dictionary ```typc (direction: "cw")``` representing clockwise winding. This can be added to
/// a dictionary instead of typing out the whole key and value:
///
/// ```typc
/// my-dictionary + cw
/// // is equivalent to
/// (..my-dictionary, direction: "cw")
/// ```
///
/// -> dictionary
#let cw = (direction: "cw")

/// The dictionary ```typc (direction: "ccw")``` representing counter-clockwise winding. This can be
/// added to a dictionary instead of typing out the whole key and value:
///
/// ```typc
/// my-dictionary + ccw
/// // is equivalent to
/// (..my-dictionary, direction: "ccw")
/// ```
///
/// -> dictionary
#let ccw = (direction: "ccw")

/// Generates a CeTZ path for a rope winding around a number of points and pulleys. Each positional
/// argument is one winding anchor; named arguments are used to style the path and passed to
/// #link("https://cetz-package.github.io/docs/api/draw-functions/shapes/merge-path")[`cetz.draw.merge-path()`].
///
/// Winding anchors can be specified in one of three ways:
/// - a dictionary with the `radius`, `direction` and `coord` keys: the `coord` is
///   #link("https://cetz-package.github.io/docs/api/internal/coordinate#resolve")[resolved]
///   according to CeTZ's rules and treated as the center of a circle around which the given
///   `radius`; the rope winds around the circle in the given direction.
/// - a dictionary with the `radius` and `direction` keys, and any other keys other than `coord`:
///   the other keys are collectively treated as the `coord`, i.e. the radius and winding direction
///   are "embedded" into a CeTZ coordinate dictionary. For example,
///   ```typc (coord: (rel: (2, 2)), radius: 1) + cw``` could be rewritten as
///   ```typc (rel: (2, 2), radius: 1) + cw```.
/// - a valid CeTZ coordinate (not necessarily a dictionary): the rope goes directly to the point,
///   without winding radius or direction.
///
/// At least two positional arguments are required. The returned path consists of the following
/// segments:
/// - For each pair of adjacent anchors, a straight line segment connecting the two. This line will
///   either be a direct connection (if both anchors are points) or a circle-line/circle-circle
///   tangent. Which tangent it is is defined by the winding direction. \
///   The line segment is omitted if its length would be zero, i.e. the anchors are touching.
/// - For each anchor except for the first and last, an arc that connects the (potential) line
///   segments surrounding it. \
///   The arc is omitted if its angle would be zero, or if the anchor is a point anyway.
///
/// By using `cetz.draw.merge-path()`, the styles should apply to the whole path and things such as
/// dashed strokes should work correctly without looking strange around segment transitions. Due to
/// the need of resolving coordinates, the returned shape is actually the result of
/// #link("https://cetz-package.github.io/docs/api/draw-functions/grouping/get-ctx")[`cetz.draw.get-ctx()`].
///
/// -> shape
#let wind(
  /// positional winding anchors and named CeTZ arguments; see above for details.
  ///
  ///  -> arguments
  ..args,
) = {
  import "cetz.typ"
  import cetz.draw: *

  let windings = args.pos()
  let style = args.named()

  get-ctx(ctx => merge-path(..style, {
    let prev-angle = none
    let windings = windings.map(winding => {
      let coord = winding
      let radius = 0
      if type(coord) == dictionary and "radius" in coord and "direction" in coord {
        radius = coord.remove("radius")
        let direction = coord.remove("direction")
        assert(direction in ("cw", "ccw"), message: "direction must be cw or ccw")
        if direction == "ccw" { radius = -radius }
        if "coord" in coord {
          coord = coord.coord
        }
      }
      (coord, radius)
    })

    let (ctx, ..coords) = cetz.coordinate.resolve(ctx, update: true, ..windings.map(array.first))
    let windings = windings.zip(coords).map(((winding, coord)) => {
      assert.eq(coord.last(), 0, message: "only coordinates on the 0 z-plane are supported")
      _ = coord.remove(2)
      let radius = winding.last()
      (coord, radius)
    })

    for ((c1, r1), (c2, r2)) in windings.windows(2) {
      let (p1, p2) = math.tangent(c1, r1, c2, r2)

      let angle = if p1 != p2 {
        // the angle can be calculated from the tangent
        cetz.vector.angle2(p1, p2)
      } else {
        // the tangent is only a single point; the angle is perpendicular to the line through the
        // centers of the touching circles. The tangent direction depends on the winding direction.
        cetz.vector.angle2(c1, c2) + if r1 < 0 { 90deg } else { -90deg }
      }

      if prev-angle != none and r1 != 0 and prev-angle != angle {
        // create an arc segment between two straight line segments

        // the arc angles are measured from the center. An arc touching a tangent therefore uses
        // angles normal to the tangent's angle. The direction depends on the winding direction.
        let start = {
          if r1 > 0 { prev-angle + 90deg }
          else { prev-angle - 90deg }
        }
        let stop = {
          if r1 > 0 { angle + 90deg }
          else { angle - 90deg }
        }
        // make sure we are spanning the right side of the circle. Clockwise means angles decrease,
        // Counter-clockwise means they increase
        if r1 > 0 and stop > start {
          stop -= 360deg
        } else if r1 < 0 and stop < start {
          stop += 360deg
        }

        arc(c1, anchor: "origin", radius: calc.abs(r1), start: start, stop: stop)
      }
      prev-angle = angle

      if p1 != p2 {
        // create a line segment between two arc segments
        line(p1, p2)
      }
    }
  }))
}