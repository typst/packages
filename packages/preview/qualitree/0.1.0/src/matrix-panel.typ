// The central panel displays current relationships, or historical symbols for
// removed cells. Historical values are display-only; figure-data owns totals.
#import "symbols.typ": _segment, _frame, _relation, _direction
#import "text.typ": _cell, _as-content
#import "change-display.typ": fill-cell, row-status, column-status, cell-status, changed-label, change-mark

#let draw-matrix(data, g, style) = {
  _cell(g.pad, g.roof-base, g.what, g.header,
    stack(spacing: 2mm, text(font: style.serif-font, size: style.font-size * 1.2,
      weight: "bold", _as-content(data.labels.whats)),
      text(size: style.font-size * 0.85, [→ #data.labels.hows])),
    wrap: true, inset: g.label-padding)
  for (c, label) in data.hows.enumerate() {
    let status = column-status(data, c)
    fill-cell(g.mx + c * g.cell, g.roof-base, g.cell, g.header, status, style)
    _cell(g.mx + c * g.cell, g.roof-base, g.cell, g.header - g.direction,
      rotate(-90deg, reflow: true, box(changed-label(label, status))),
      anchor: center + bottom, inset: g.header-padding)
    if g.direction > 0pt {
      _cell(g.mx + c * g.cell, g.my - g.direction, g.cell, g.direction,
        text(size: style.font-size * 1.3, weight: "bold", _direction(data.directions.at(c))), inset: 0pt)
    }
  }
  if data.show-importance {
    _cell(g.pad + g.what, g.roof-base, g.iw, g.header,
      rotate(-90deg, reflow: true, box(strong(_as-content(data.labels.importance)))),
      anchor: center + bottom, inset: g.header-padding)
  }
  for (r, label) in data.whats.enumerate() {
    let status = row-status(data, r)
    fill-cell(g.pad, g.my + r * g.row, g.what + g.iw, g.row, status, style)
    _cell(g.pad, g.my + r * g.row, g.what, g.row, changed-label(label, status),
      anchor: left + horizon, wrap: true, inset: g.label-padding)
    if data.show-importance {
      _cell(g.pad + g.what, g.my + r * g.row, g.iw, g.row,
        if status == "removed" { calc.round(data.changes.previous-importance.at(r), digits: style.weight-digits) }
        else { calc.round(data.importance.at(r), digits: style.weight-digits) }, inset: g.cell-padding)
    }
    for c in range(data.nc) {
      let status = cell-status(data, r, c)
      fill-cell(g.mx + c * g.cell, g.my + r * g.row, g.cell, g.row, status, style)
      let current = data.matrix.at(r).at(c)
      let value = if status == "removed" { data.changes.previous-matrix.at(r).at(c) } else { current }
      _cell(g.mx + c * g.cell, g.my + r * g.row, g.cell, g.row,
        _relation(value, style.symbol-size, style.ink, thickness: style.symbol-thickness), inset: g.cell-padding)
      if status != "unchanged" {
        _cell(g.mx + (c + 0.65) * g.cell, g.my + r * g.row, g.cell * 0.35, g.row * 0.35,
          text(size: 5pt, weight: "bold", change-mark(status)), inset: 0pt)
        if status == "changed" {
          _cell(g.mx + c * g.cell, g.my + (r + 0.70) * g.row, g.cell, g.row * 0.30,
            text(size: 5pt, [#(data.changes.previous-matrix.at(r).at(c))→#current]), inset: 0pt)
        }
      }
    }
  }
}

#let draw-basement(data, g, style) = {
  for (b, row) in data.basement.enumerate() {
    _cell(g.pad, g.my + g.mh + b * g.basement, g.what + g.iw, g.basement,
      emph(_as-content(row.label)), anchor: right + horizon, inset: g.label-padding)
    for (c, value) in row.values.enumerate() {
      let value = if row.at("computed", default: false) { calc.round(value, digits: style.weight-digits) } else { value }
      let body = _as-content(value)
      if row.at("bold", default: false) { body = strong(body) }
      _cell(g.mx + c * g.cell, g.my + g.mh + b * g.basement,
        g.cell, g.basement, body, inset: g.cell-padding)
    }
  }
}

// Grid strokes are drawn after fills. Every neighboring panel shares the same
// boundaries, including when importance or competitive assessment is hidden.
#let draw-grid(data, g, style) = {
  for r in range(1, data.nr) { _segment(g.pad, g.my + r * g.row, g.right, g.my + r * g.row, style.thin) }
  for c in range(1, data.nc) {
    _segment(g.mx + c * g.cell, g.roof-base, g.mx + c * g.cell,
      g.my + g.mh + data.basement.len() * g.basement, style.thin)
  }
  for b in range(1, data.basement.len()) {
    _segment(g.mx, g.my + g.mh + b * g.basement, g.mx + g.mw,
      g.my + g.mh + b * g.basement, style.thin)
  }
  _frame(g.pad, g.my, g.what + g.iw + g.mw, g.mh, style.frame)
  _segment(g.mx, g.my, g.mx, g.my + g.mh, style.frame)
  if data.show-importance { _segment(g.pad + g.what, g.my, g.pad + g.what, g.my + g.mh, style.frame) }
  _frame(g.mx, g.roof-base, g.mw, g.header, style.frame)
  if data.basement.len() > 0 { _frame(g.mx, g.my + g.mh, g.mw, data.basement.len() * g.basement, style.frame) }
  if data.show-competitive { _frame(g.mx + g.mw, g.my, g.cw, g.mh, style.frame) }
}
