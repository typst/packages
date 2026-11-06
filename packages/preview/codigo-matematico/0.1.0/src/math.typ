// Maths-oriented helpers and aliases.

#import "./palette.typ": *
#import "./settings.typ": *


// Math font: New Computer Modern versión 8.1.0 (since Typst v0.15+)
// show math.equation: set text(stylistic-set: 6)


// #let emptyset = sym.diameter
// #let emptyset = sym.emptyset.zero // Since Typst v0.15+



#let norm(cuerpo) = {
  set text(..main_body_text_settings)
  show math.equation: set text(
    font: "New Computer Modern Math",
    size: 1.5em,
  )
  h(1.2em)
  cuerpo
}



#let func_sig(name, dom, codom, var, value) = [
  $ & name  & : && dom & -->         && codom \
    &       &   && var & mapsto.long && value $
]

// TODO Quizás sea mejor marcarlo como operador binario, en lugar de con
// espacios fijos.
#let iff = $#math.space #math.arrow.l.r.double.long #math.space$
#let implies = $#math.space #math.arrow.r.double.long #math.space$


// Highlight in a box.
#let hl(it) = align(center)[#rect(stroke: 0.3pt + palette.fg)[#it]]
