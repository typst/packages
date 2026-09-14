#let show-set-supplement(s) = {
  show heading.where(level: 1): set heading(supplement: [Chapter])
  show heading.where(level: 2): set heading(supplement: [Section])
  show heading.where(level: 3): set heading(supplement: [Section])
  show heading.where(level: 4): set heading(supplement: [Section])
  s
}
