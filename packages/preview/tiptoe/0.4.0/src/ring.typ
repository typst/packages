#import "arc-impl.typ": bezier-arc2
#import "curve.typ": curve

#let ring(
  origin: (0pt, 0pt),
  angle: 0deg,
  arc: 45deg,
  inner: 0.5cm,
  outer: 1cm,
  stroke: auto,
  fill: auto,
) = {
  let inner-coords = bezier-arc2(
    origin: origin,
    angle: arc + angle,
    arc: -arc,
    radius: inner,
  )
  let outer-coords = bezier-arc2(
    origin: origin,
    angle: angle,
    arc: arc,
    radius: outer,
    move: arc == 360deg,
  )

  if arc == 360deg {
    inner-coords.push(std.curve.close(mode: "straight"))
  }


  curve(
    stroke: stroke,
    fill: fill,
    ..inner-coords,
    ..outer-coords,
    (std.curve.close(mode: "straight")),
  )
}
