#import "../tudacolors.typ": tuda_colors
/// Draws a star with the given number of edges, size, stroke width, fill color and rotation. Usage:
/// ```example
///  #draw-star(fill: red)
/// ```
///
/// - edges (int): The number of edges of the star. Default is 5.
/// - size (length): The size of the star. Default is 1cm.
/// - stroke (length): The stroke width of the star. Default is 1.5pt.
/// - fill (color): The fill color of the star. Default is red.
/// - rotation (angle): The rotation of the star in degrees. Default is 90deg.
/// - baseline (length): The baseline of the star. Default is 0.5pt.
/// -> Returns: A star shape.
#let draw-star(edges: 5, size: 1em, stroke: .8pt, fill: red, rotation: 270deg,baseline: 0.5pt) = {
  let inner_size = size / 2 - stroke
  let outer_r = inner_size
  let inner_r = inner_size * 0.4
  let center_p = (inner_size, inner_size)
  let points = ()
  for idx in range(edges * 2) {
    let angle = idx * (360deg / (edges * 2)) + rotation
    let radius = if calc.rem(idx, 2) == 0 { outer_r } else { inner_r }
    points.push((
      center_p.at(0) + radius * calc.cos(angle),
      center_p.at(1) + radius * calc.sin(angle),
    ))
  }
  box(width: size, height: size, baseline: baseline, inset: 0pt, outset: 0pt, align(center + horizon, curve(
    stroke: stroke,
    fill: fill,
    curve.move(points.remove(0)),
    ..points.map(p => curve.line(p)),
    curve.close(mode: "straight"),
  )))
}

/// Draws a number of stars to represent the difficulty of a task.
///
/// - difficulty (float): The difficulty of the task, must be between 0 and `max-difficulty`.
/// - max_difficulty (int): The maximum difficulty, default is 5.
/// - fill (color): The fill color of the stars, default is `rgb(tuda_colors.at("3b"))`.
/// - spacing (length): The spacing between the stars, default is 2pt.
/// - difficulty-name (str): The name of the difficulty, prefix for the stars, default is `none`.
/// - otherargs: Additional arguments to pass to the `draw-star` function.
/// -> Returns: A canvas with the stars drawn on it.
#let difficulty-stars(
  difficulty,
  max-difficulty: 5,
  fill: rgb(tuda_colors.at("3b")),
  spacing: 2pt,
  difficulty-name: none,
  difficulty-sep: ": ",
  ..otherargs,
) = {
  assert(type(difficulty) in (float,int), message: "difficulty must be a number")
  assert.eq(type(max-difficulty), int, message: "max-difficulty must be an integer")
  assert(difficulty >= 0 and difficulty <= max-difficulty, message: "difficulty must be between 0 and " + str(max-difficulty))
  assert.eq(type(fill), color, message: "fill must be a color, got " + str(type(fill)))
  let remaining_difficulty = difficulty
  let first = true
  if difficulty-name != none {
    difficulty-name
    difficulty-sep
  }
  for d in range(max-difficulty) {
    let fill_percentage = if remaining_difficulty > 0 {
      100% * calc.min(1, remaining_difficulty)
    } else {
      0%
    }
    if first {
      first = false
    } else {
      h(spacing)
    }
    draw-star(
      fill: if fill_percentage > 0% {
        gradient.linear(
          (fill, 0%),
          (fill, fill_percentage),
          (rgb("#00000000"), fill_percentage),
          (rgb("#00000000"), 100%),
          angle: 0deg,
        )
      } else {
        rgb("#00000000")
      },
      ..otherargs,
    )
    remaining_difficulty -= 1
  }
}