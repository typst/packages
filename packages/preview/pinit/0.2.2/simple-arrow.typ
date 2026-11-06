/// Draw a simple arrow on the page with optional settings, implemented by [`polygon`](https://typst.app/docs/reference/visualize/polygon/).
///
/// - `fill`: [`color`] &mdash; The fill color for the arrow.
/// - `stroke`: [`stroke`] &mdash; The stroke for the arrow.
/// - `start`: [`point`] &mdash; The starting point of the arrow.
/// - `end`: [`point`] &mdash; The ending point of the arrow.
/// - `thickness`: [`length`] &mdash; The thickness of the arrow.
/// - `arrow-width`: [`int` or `float`] &mdash; The width of the arrowhead relative to thickness.
/// - `arrow-height`: [`int` or `float`] &mdash; The height of the arrowhead relative to thickness.
/// - `inset`: [`int` or `float`] &mdash; The inset value for the arrowhead relative to thickness.
/// - `tail`: [`array`] &mdash; The tail settings for the arrow.
#let simple-arrow(
  fill: black,
  stroke: 0em,
  start: (0em, 0em),
  end: (3em, 0em),
  thickness: 0.12em,
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
  if _dx.em != 0 and (_dx - _dx.em * 1em).pt() != 0 {
    panic("The x-coordinate must only use pt units or only em units.")
  }
  let _dy = end-y - start-y
  if _dy.em != 0 and (_dy - _dy.em * 1em).pt() != 0 {
    panic("The y-coordinate must only use pt units or only em units.")
  }
  let _angle = if _dx.em != 0 or _dy.em != 0 {
    calc.atan2(_dx.em, _dy.em)
  } else {
    calc.atan2(_dx.pt(), _dy.pt())
  }
  let _ht = 0.5 * thickness
  let _hw = 0.5 * _arrow-width
  let _c = calc.cos(_angle)
  let _s = calc.sin(_angle)

  polygon(
    fill: fill,
    stroke: stroke,
    ..tail,
    (start-x - _s * _ht, start-y + _c * _ht),
    (
      start-x + _dx - _s * _ht - _c * (_arrow-height - _inset),
      start-y + _dy + _c * _ht - _s * (_arrow-height - _inset),
    ),
    (start-x + _dx - _s * _hw - _c * _arrow-height, start-y + _dy + _c * _hw - _s * _arrow-height),
    (end-x, end-y),
    (start-x + _dx + _s * _hw - _c * _arrow-height, start-y + _dy - _c * _hw - _s * _arrow-height),
    (
      start-x + _dx + _s * _ht - _c * (_arrow-height - _inset),
      start-y + _dy - _c * _ht - _s * (_arrow-height - _inset),
    ),
    (start-x + _s * _ht, start-y - _c * _ht),
  )
}

/// Draw a double arrow on the page with optional settings, implemented by [`polygon`](https://typst.app/docs/reference/visualize/polygon/).
///
/// Author: [PaulS](https://github.com/psads-git)
///
/// - `fill`: [`color`] &mdash; The fill color for the arrow.
/// - `stroke`: [`stroke`] &mdash; The stroke for the arrow.
/// - `start`: [`point`] &mdash; The starting point of the arrow.
/// - `end`: [`point`] &mdash; The ending point of the arrow.
/// - `thickness`: [`length`] &mdash; The thickness of the arrow.
/// - `arrow-width`: [`int` or `float`] &mdash; The width of the arrowhead relative to thickness.
/// - `arrow-height`: [`int` or `float`] &mdash; The height of the arrowhead relative to thickness.
/// - `inset`: [`int` or `float`] &mdash; The inset value for the arrowhead relative to thickness.
/// - `tail`: [`array`] &mdash; The tail settings for the arrow.
#let double-arrow(
  fill: black,
  stroke: 0em,
  start: (0em, 0em),
  end: (3em, 0em),
  thickness: 0.12em,
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
  if _dx.em != 0 and (_dx - _dx.em * 1em).pt() != 0 {
    panic("The x-coordinate must only use pt units or only em units.")
  }
  let _dy = end-y - start-y
  if _dy.em != 0 and (_dy - _dy.em * 1em).pt() != 0 {
    panic("The y-coordinate must only use pt units or only em units.")
  }
  let _angle = if _dx.em != 0 or _dy.em != 0 {
    calc.atan2(_dx.em, _dy.em)
  } else {
    calc.atan2(_dx.pt(), _dy.pt())
  }
  let _ht = 0.5 * thickness
  let _hw = 0.5 * _arrow-width
  let _c = calc.cos(_angle)
  let _s = calc.sin(_angle)
  
  polygon(
    fill: fill,
    stroke: stroke,
    ..tail,
    // First arrowhead points
    (start-x + _s * _ht + _c * (_arrow-height - _inset), start-y - _c * _ht + _s * (_arrow-height - _inset)),
    (start-x + _s * _hw + _c * _arrow-height, start-y - _c * _hw + _s * _arrow-height),
    (start-x, start-y),
    (start-x - _s * _hw + _c * _arrow-height, start-y + _c * _hw + _s * _arrow-height),
    (start-x - _s * _ht + _c * (_arrow-height - _inset), start-y + _c * _ht + _s * (_arrow-height - _inset)),
    // Shaft points
    (start-x + _dx - _s * _ht - _c * (_arrow-height - _inset), start-y + _dy + _c * _ht - _s * (_arrow-height - _inset)),
    // Second arrowhead points
    (start-x + _dx - _s * _hw - _c * _arrow-height, start-y + _dy + _c * _hw - _s * _arrow-height),
    (end-x, end-y),
    (start-x + _dx + _s * _hw - _c * _arrow-height, start-y + _dy - _c * _hw - _s * _arrow-height),
    (start-x + _dx + _s * _ht - _c * (_arrow-height - _inset), start-y + _dy - _c * _ht - _s * (_arrow-height - _inset)),
    // Close the polygon back to the shaft
    (start-x + _s * _ht, start-y - _c * _ht),
  )
}