// The series panel consumes one set of displaced points for BOTH lines and
// markers. Missing scores split paths, avoiding invented interpolated evidence.
#import "symbols.typ": _polyline
#import "profile-symbols.typ": _profile-pen, _profile-marker
#import "profile-layout.typ": stagger-profiles
#import "text.typ": _cell, _as-content

#let draw-comparison(data, g, style) = {
  if not data.show-competitive { return [] }
  let (minimum, maximum) = data.score-range
  let tick-width = g.cw / (maximum - minimum + 1)
  let score-x(score) = g.mx + g.mw + (score - minimum + 0.5) * tick-width
  let tick-height = calc.min(4.5mm, g.header / 4)
  let title-height = calc.min(11mm, g.header - tick-height)
  _cell(g.mx + g.mw, g.my - tick-height - title-height, g.cw, title-height,
    strong(_as-content(data.labels.comparison)), wrap: true, inset: g.cell-padding)
  for tick in range(minimum, maximum + 1) {
    _cell(score-x(tick) - tick-width / 2, g.my - tick-height,
      tick-width, tick-height, tick, inset: 0pt)
  }
  let sizes = data.alternatives.map(item => calc.min(item.marker-size * (style.symbol-size / 7pt),
    tick-width * 0.75, g.row * 0.40))
  let diameter = if sizes.len() == 0 { 0 } else { calc.max(..sizes) / g.row + 0.035 }
  let points = stagger-profiles(data.alternatives.map(a => a.scores),
    enabled: style.marker-stagger, spread: style.marker-spread, diameter: diameter, x-step: tick-width / g.row)
  for (s, item) in data.alternatives.enumerate() {
    let run = ()
    for point in points.at(s) {
      if point == none { _polyline(run, _profile-pen(item)); run = () }
      else { run.push((score-x(point.x), g.my + point.y * g.row)) }
    }
    _polyline(run, _profile-pen(item))
  }
  for (s, item) in data.alternatives.enumerate() {
    for (r, point) in points.at(s).enumerate() {
      if point == none { continue }
      // For large tie groups, shrink just the tied markers enough to fit their
      // available vertical lanes. The data x-coordinate remains untouched.
      let gaps = points.enumerate().filter(((i, p)) => i != s and p.at(r) != none and
        calc.abs(p.at(r).x - point.x) * tick-width < sizes.at(s))
        .map(((i, p)) => calc.abs(p.at(r).y - point.y) * g.row)
        .filter(gap => gap > 0pt)
      let size = if style.marker-stagger and gaps.len() > 0 {
        calc.min(sizes.at(s), calc.min(..gaps) * 0.88)
      } else { sizes.at(s) }
      place(top + left, dx: score-x(point.x) - size / 2, dy: g.my + point.y * g.row - size / 2,
        _profile-marker(item, size))
    }
  }
  _cell(g.mx + g.mw, g.my + g.mh, g.cw / 2, 5mm, emph(_as-content(data.labels.poor)),
    anchor: left + horizon, inset: 0.5mm)
  _cell(g.mx + g.mw + g.cw / 2, g.my + g.mh, g.cw / 2, 5mm, emph(_as-content(data.labels.excellent)),
    anchor: right + horizon, inset: 0.5mm)
}
