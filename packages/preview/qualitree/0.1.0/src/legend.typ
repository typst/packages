// Legend height follows its visible sections and actual series labels.
#import "symbols.typ": _relation, _sign
#import "profile-symbols.typ": _sample
#import "text.typ": _as-content

#let _legend(labels, alternatives, order, limits, width, thin, frame, ink,
  symbol-size, symbol-thickness: 1.1pt, correlation-style: "circled", changes: false, change-fills: (:), relation: true, correlation: true, evaluation: true) = {
  let row(sample, label) = grid(
    columns: (0.65cm, 1fr), column-gutter: 0.1cm, align: left + horizon,
    align(center, sample), _as-content(label),
  )
  let section(title, entries) = stack(dir: ttb, spacing: 0.15cm,
    strong(_as-content(title)), line(length: 100%, stroke: thin), ..entries)
  let sections = ()
  if relation {
    sections.push(section(labels.relation, (
      row(_relation(9, symbol-size, ink, thickness: symbol-thickness), labels.strong),
      row(_relation(3, symbol-size, ink, thickness: symbol-thickness), labels.medium),
      row(_relation(1, symbol-size, ink, thickness: symbol-thickness), labels.weak),
    )))
  }
  if correlation {
    sections.push(section(labels.correlation, (
      row(_sign("++", style: correlation-style, size: symbol-size, ink: ink, thickness: symbol-thickness), labels.very-positive), row(_sign("+", style: correlation-style, size: symbol-size, ink: ink, thickness: symbol-thickness), labels.positive),
      row(_sign("-", style: correlation-style, size: symbol-size, ink: ink, thickness: symbol-thickness), labels.negative), row(_sign("--", style: correlation-style, size: symbol-size, ink: ink, thickness: symbol-thickness), labels.very-negative),
    )))
  }
  if evaluation {
    let entries = order.map(index => {
      let item = alternatives.at(index - 1)
      let label = _as-content(item.label)
      if item.at("emphasize", default: false) { label = strong(label) }
      row(_sample(item, item.marker-size * (symbol-size / 7pt)), label)
    })
    let note = if labels.score-note == auto {
      [#(limits.at(0)) = #labels.poor, #(limits.at(1)) = #labels.excellent]
    } else { _as-content(labels.score-note) }
    entries.push(emph(note))
    sections.push(section(labels.evaluation, entries))
  }
  if changes {
    sections.push(section(labels.changes, ("added", "removed", "changed").map(status =>
      row(rect(width: 0.45cm, height: 0.3cm, fill: change-fills.at(status), stroke: thin), labels.at(status)))))
  }
  if sections.len() == 0 { return none }
  rect(width: width, inset: 0.15cm, radius: 2pt, stroke: frame, fill: none,
    stack(dir: ttb, spacing: 0.4cm, ..sections))
}

