#import "arc-impl.typ": bezier-arc2
#import "curve.typ": curve

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
  shorten: 100%
) = {
  let coords = bezier-arc2(
    origin: origin,
    angle: angle,
    arc: arc,
    radius: radius,
    width: width,
    height: height,
  )

  if closed == "sector" {
    coords.push(std.curve.line(origin))
  }
  if closed in ("sector", "segment") {
    coords.push(std.curve.close(mode: "straight"))
    closed = true
  } else if closed == true {
    coords.push(std.curve.close())
  }

  curve(
    stroke: stroke,
    tip: tip,
    toe: toe,
    shorten: shorten,
    fill: fill, 
    ..coords
  )

}