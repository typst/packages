// layout: ordered events -> placement. Pure, no cetz.
// `slot` is the ordinal position along the axis (the renderer scales it by the
// pitch token); `side` alternates +1 / -1 so consecutive labels sit on opposite
// sides of the axis and don't stack on top of each other. Text measurement and
// the pixel geometry happen in `render` (it needs `context`).

#let layout(events) = events.map(e => (
  ..e,
  slot: e.index,
  side: if calc.rem(e.index, 2) == 0 { 1 } else { -1 },
))
