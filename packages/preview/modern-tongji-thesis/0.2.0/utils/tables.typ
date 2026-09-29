// Three-line table rules (booktabs-style, using native table.hline)
#let heavyrulewidth = .08em
#let lightrulewidth = .05em
#let cmidrulewidth = .03em

#let toprule(stroke: heavyrulewidth) = { table.hline(stroke: stroke) }
#let midrule(stroke: lightrulewidth) = { table.hline(stroke: stroke) }
#let bottomrule(stroke: heavyrulewidth) = { table.hline(stroke: stroke) }
#let cmidrule(start: 0, end: -1, stroke: cmidrulewidth) = { table.hline(start: start, end: end, stroke: stroke) }
