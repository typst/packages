#let simple-arrow(
  fill: black,
  stroke: 0pt,
  start: (0pt, 0pt),
  end: (30pt, 0pt),
  thickness: 2pt,
  arrow-width: 4,
  arrow-height: 4,
  inset: 0.5,
  tail: (),
) = {
  let _arrow-width = arrow-width * thickness
  let _arrow-height = arrow-height * thickness
  let _inset = inset * thickness
  let start-x = start.at(0)
  let start-y = start.at(1)
  let end-x = end.at(0)
  let end-y = end.at(1)
  let _dx = end-x - start-x
  let _dy = end-y - start-y
  let _angle = calc.atan2(_dx.pt(), _dy.pt())
  let _ht = 0.5 * thickness
  let _hw = 0.5 * _arrow-width
  let _c = calc.cos(_angle)
  let _s = calc.sin(_angle)
  
  polygon(
    fill: fill,
    stroke: stroke,
    ..tail,
    (start-x - _s * _ht, start-y + _c * _ht),
    (start-x + _dx - _s * _ht - _c * (_arrow-height - _inset), start-y + _dy + _c * _ht - _s * (_arrow-height - _inset)),
    (start-x + _dx - _s * _hw - _c * _arrow-height, start-y + _dy + _c * _hw - _s * _arrow-height),
    (end-x, end-y),
    (start-x + _dx + _s * _hw - _c * _arrow-height, start-y + _dy - _c * _hw - _s * _arrow-height),
    (start-x + _dx + _s * _ht - _c * (_arrow-height - _inset), start-y + _dy - _c * _ht - _s * (_arrow-height - _inset)),
    (start-x + _s * _ht, start-y - _c * _ht),
  )
}