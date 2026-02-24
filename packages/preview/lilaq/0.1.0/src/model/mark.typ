#import "@preview/tiptoe:0.3.0": arc


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
  let s = mark.size / 1.13
  move(
    dx: -s / 2, 
    dy: -s / 2, 
    rect(width: s, height: s, fill: mark.fill, stroke: mark.stroke)
  )
}


#let cross = mark => {
  let s = mark.size / calc.sqrt(8) * 1.07
  place(line(start: (-s, -s), end: (s, s), stroke: mark.stroke))
  line(start: (s, -s), end: (-s, s), stroke: mark.stroke)
}


#let plus = mark => {
  let s = mark.size / 2 * 1.05
  place(line(start: (0pt, -s), end: (0pt, s), stroke: mark.stroke))
  line(start: (s, 0pt), end: (-s, 0pt), stroke: mark.stroke)
}


#let polygon = (mark, n: 5, angle: 0deg) => { 
  // The last term serves for equalizing the apparent size of polygons with different n. 
  let radius = mark.size / 2 * calc.sqrt(1 + 3 / (n*n))
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
  let radius = mark.size / 2 * 1.1
  
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
  "+": plus,
  "|": polygon.with(n: 2),
  "-": polygon.with(n: 2, angle: 90deg),
  "star": star,
  "o": circle,
  "s": square,
  "polygon": polygon,
  "triangle": polygon.with(n: 3),
  "diamond": polygon.with(n: 4),
  "pentagon": polygon.with(n: 5),
  "hexagon": polygon.with(n: 6),
  "heptagon": polygon.with(n: 7),
  "octagon": polygon.with(n: 8),
  "moon": moon,
  "none": mark => none,
  "text": text-mark
)