#import "arc-impl.typ": bezier-arc
#import "path.typ": path

#let arc(
  origin: (0pt, 0pt),
  angle: 0deg,
  arc: 45deg,
  radius: 1cm,
  width: auto,
  height: auto,
  stroke: 1pt + black,
  fill: none,
  closed: false,
  tip: none, 
  toe: none,
  shorten: 50%
) = {
  let coords = bezier-arc(
    origin: origin,
    angle: angle,
    arc: arc,
    radius: radius,
    width: width,
    height: height,
  )
  if closed == "sector" {
    coords.push(origin)
  }
  if closed in ("sector", "segment") {
    closed = true
  }
  path(
    stroke: stroke,
    tip: tip,
    toe: toe,
    shorten: shorten,
    fill: fill, closed: closed,
    ..coords
  )

}