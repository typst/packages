#let ink = rgb("252522")
#let muted = rgb("63635E")
#let pale = rgb("F4F4F1")
#let border = rgb("D4D4CD")
#let levels = (
  low: (label: "Faible", fill: rgb("E5F2EF"), ink: rgb("215A4D")),
  medium: (label: "Moyen", fill: rgb("FFF1D1"), ink: rgb("735013")),
  high: (label: "Élevé", fill: rgb("F9DFDC"), ink: rgb("8D3028")),
)
#let note(body) = block(width: 100%, inset: (y: 10pt),
  stroke: (top: 0.5pt + border, bottom: 0.5pt + border, rest: none), body)
#let refs(values) = if values.len() == 0 { [Aucun] } else { values.join(", ") }
