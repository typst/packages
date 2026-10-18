// Roof correlations belong to column pairs. The lattice geometry is shared with
// the calculation API; revision overlays must use the same diamond centers.
#import "symbols.typ": _segment, _sign
#import "text.typ": _cell
#import "change-display.typ": change-fill, change-mark

#let draw-roof(data, g, style) = {
  if not data.show-roof { return [] }
  if data.changes != none {
    for entry in data.changes.at("correlations", default: ()) {
      if entry.status != "unchanged" {
        let x = g.mx + (entry.i + entry.j - 1) / 2 * g.cell
        let y = g.roof-base - calc.abs(entry.j - entry.i) / 2 * g.cell
        place(top + left, dx: x - g.cell / 2, dy: y - g.cell / 2,
          polygon((g.cell / 2, 0pt), (g.cell, g.cell / 2), (g.cell / 2, g.cell), (0pt, g.cell / 2),
            fill: change-fill(entry.status, style), stroke: none))
        let sign = if entry.current == none { entry.previous } else { entry.current }
        _cell(x - g.cell / 4, y - g.cell / 4, g.cell / 2, g.cell / 2,
          _sign(sign, style: style.correlation-style, size: style.symbol-size,
            ink: style.ink, thickness: style.symbol-thickness), inset: 0pt)
        _cell(x + g.cell / 8, y - g.cell / 4, g.cell / 4, g.cell / 4,
          text(size: 5pt, weight: "bold", change-mark(entry.status)), inset: 0pt)
      }
    }
  }
  for k in range(1, data.nc) {
    _segment(g.mx + k * g.cell, g.roof-base,
      g.mx + (k + data.nc) * g.cell / 2, g.roof-base - (data.nc - k) * g.cell / 2, style.thin)
    _segment(g.mx + k * g.cell, g.roof-base,
      g.mx + k * g.cell / 2, g.roof-base - k * g.cell / 2, style.thin)
  }
  _segment(g.mx, g.roof-base, g.mx + g.mw / 2, g.pad, style.frame)
  _segment(g.mx + g.mw / 2, g.pad, g.mx + g.mw, g.roof-base, style.frame)
  for item in data.correlations {
    let edited = data.changes != none and data.changes.at("correlations", default: ()).any(e =>
      e.i == item.i and e.j == item.j and e.status != "unchanged")
    if not edited {
      let x = g.mx + item.point.x * g.cell
      let y = g.roof-base - item.point.y * g.cell
      _cell(x - g.cell / 4, y - g.cell / 4, g.cell / 2, g.cell / 2,
        _sign(item.sign, style: style.correlation-style, size: style.symbol-size,
          ink: style.ink, thickness: style.symbol-thickness), inset: 0pt)
    }
  }
}
