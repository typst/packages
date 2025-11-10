#import "@preview/cetz:0.4.0"
#import "@preview/cetz-plot:0.1.2"
#import "@preview/lilaq:0.3.0"

/// Get the 2D coordinates in form of (x: i, y: j).
/// - coord (array, dictionary): The coordinates, must be 2-elements long.
#let get-2d-coord(coord) = {
  assert(type(coord) in (array, dictionary))

  if (type(coord) == dictionary) { return coord }
  return (x: coord.at(0), y: coord.at(1))
}

/// Use in a `cetz.canvas`!
/// Draw an upright no-perspective cylinder.
/// - center (array, dictionary): The center of the cylinder.
/// - radius (array): The radius of the cylinder.
/// - height (length): The height of the cylinder.
/// - fill-top (color): The color to fill the top of the cylinder.
/// - fill-side (color): The color to fill the side of the cylinder.
#let cylinder(center, radius, height, fill-top: none, fill-side: none) = {
  import cetz.draw: *
  let center = get-2d-coord(center)
  let lt = (center.x - radius.at(0), center.y)
  
  merge-path(fill: fill-side, {
    line(lt, (rel: (0, -height)))
    arc((), start: 180deg, delta: 180deg, radius: radius)
    line((), (rel: (0, height)))
    arc((), stop: 180deg, delta: -180deg, radius: radius)
  })
  circle(center, radius: radius, fill: fill-top)
}
