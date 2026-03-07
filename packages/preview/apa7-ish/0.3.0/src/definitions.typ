#let script-size = 8pt
#let footnote-size = 8.5pt
#let small-size = 9.25pt
#let normal-size = 11pt
#let large-size = 1.33 * normal-size

// Utilities for tables
// thicknesses stolen from latex's booktabs package
#let heavyrulewidth = 0.08em
#let lightrulewidth = 0.05em
#let toprule = table.hline(stroke: heavyrulewidth)
#let midrule = table.hline(stroke: lightrulewidth)
#let bottomrule = table.hline(stroke: heavyrulewidth)
#let tablenote(body) = { align(left, [_Note_. #body]) }
