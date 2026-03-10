#import "@preview/tiptoe:0.3.1": arc


/// A mark for a plot. Refer to the #link("tutorials/marks")[mark tutorial] for
/// a list of available mark shapes and more details. 
#let mark(

  /// The size of the mark. The built-in mark shapes are tuned to match in 
  /// optical size, see #link("tutorials/marks#sizing")[mark sizing]. 
  /// -> length
  size: 4pt,

  /// How to fill the mark. If set to `auto`, the fill is inherited from the
  /// plot. 
  /// -> auto | none | color | gradient | tiling
  fill: auto,

  /// How to stroke the mark. If set to `auto`, the stroke is inherited from the
  /// plot.
  /// -> stroke
  stroke: 0.7pt,

  /// The shape of the mark. This can be a string identifying one of the 
  /// built-in marks (check out the tutorial) or a function that takes a mark 
  /// and produces content. 
  /// -> str | function
  shape: "."

) = {}

#let mark = grid



#let circle = mark => {
  let radius = mark.size / 2
  move(
    dx: -radius, 
    dy: -radius, 
    std.ellipse(width: radius*2, height: radius*2, fill: mark.fill, stroke: mark.stroke)
  )
}


#let small-circle = mark => {
  let radius = mark.size / 4
  move(
    dx: -radius, 
    dy: -radius, 
    std.ellipse(width: radius*2, height: radius*2, fill: mark.fill, stroke: mark.stroke)
  )
}


#let point = mark => {
  let radius = .5pt
  move(
    dx: -radius, 
    dy: -radius, 
    std.circle(radius: radius, fill: mark.fill, stroke: mark.stroke)
  )
}


#let square = mark => {
  let s = mark.size * 0.85
  move(
    dx: -s / 2, 
    dy: -s / 2, 
    rect(width: s, height: s, fill: mark.fill, stroke: mark.stroke)
  )
}


#let cross = mark => {
  let s = mark.size / calc.sqrt(8) * 1.2
  place(line(start: (-s, -s), end: (s, s), stroke: mark.stroke))
  line(start: (s, -s), end: (-s, s), stroke: mark.stroke)
}


// #let plus = mark => {
//   let s = mark.size / 2 * 1.2
//   place(line(start: (0pt, -s), end: (0pt, s), stroke: mark.stroke))
//   line(start: (s, 0pt), end: (-s, 0pt), stroke: mark.stroke)
// }


#let polygon = (mark, n: 5, angle: 0deg) => { 
  // The last term serves for equalizing the apparent size of polygons with different n. 
  let radius = mark.size / 2 * calc.sqrt(1 + 4 / (n*n))
  let dy = (0, .13, 0, .03, 0, .02).at(n - 2, default: 0) * radius
  let poly = std.polygon(
    stroke: mark.stroke, fill: mark.fill,
    ..range(n).map(i => {
      let phi = i * 360deg / n
      (
        radius * calc.sin(phi),
        -radius * calc.cos(phi) + dy
      )
    })
  )
  if angle != 0deg {
    poly = rotate(angle, origin: left + top, poly)
  }
  poly
}


#let star = (mark, n: 5, angle: 0deg, inset: 60%) => { 
  let radius = mark.size / 2 * 1.15
  
  std.polygon(
    stroke: mark.stroke, 
    fill: mark.fill,
    ..range(n * 2).map(i => {
      let r = if calc.even(i) { radius } else { radius * (100% - inset) }
      let phi = i * 360deg / n / 2 + angle
      (
        r * calc.sin(phi),
        -r * calc.cos(phi)
      )
    })
  )
}


#let asterisk = star.with(inset: 100%)


#let moon = (mark, angle: 0deg) => {
  let radius = mark.size / 2
  
  arc(
    radius: radius, 
    fill: mark.fill, 
    closed: "segment", 
    arc: 180deg, 
    stroke: 0pt, 
    angle: angle
  )
  move(
    dx: -radius, 
    dy: -radius, 
    std.circle(radius: radius, fill: none, stroke: mark.stroke)
  )
}


#let text-mark = (mark, body: emoji.heart) => place(
  center + horizon,
  body
)



#let marks = (
  ".": small-circle,
  ",": point,
  "*": asterisk,
  "asterisk": asterisk,
  "x": cross,
  "+": asterisk.with(n: 4),
  "|": polygon.with(n: 2),
  "-": polygon.with(n: 2, angle: 90deg),
  "a3": asterisk.with(n: 3),
  "a4": asterisk.with(n: 4),
  "a5": asterisk.with(n: 5),
  "a6": asterisk.with(n: 6),
  "<": polygon.with(n: 3, angle: -90deg),
  ">": polygon.with(n: 3, angle: 90deg),
  "^": polygon.with(n: 3),
  "v": polygon.with(n: 3, angle: 180deg),
  "o": circle,
  "s": square,
  "polygon": polygon,
  "d": polygon.with(n: 4),
  "p5": polygon.with(n: 5),
  "p6": polygon.with(n: 6),
  "p7": polygon.with(n: 7),
  "p8": polygon.with(n: 8),
  "star": star,
  "s3": star.with(n: 3, inset: 70%),
  "s4": star.with(n: 4),
  "s5": star.with(n: 5),
  "s6": star.with(n: 6),
  "moon": moon,
  "text": text-mark,
  "none": mark => none
)
