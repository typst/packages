#import "@preview/ctheorems:2.0.0": *
#show: thm-rules.with(qed-symbol: $square$)


#let thm = thm.with(
  fmt: thm-fmt-block.with(
    name-fmt: x => [(#x)],
    title-fmt: strong,
    body-fmt: emph,
    separator: [*.* ]
  )
)

#let thm-def = thm.with(
  fmt: thm-fmt-block.with(
    name-fmt: x => [(#x)],
    title-fmt: strong,
    body-fmt: x => x,
    separator: [*.* ]
  )
)

#let thm-rem = thm.with(
  numbering: none,
  fmt: thm-fmt-block.with(
    name-fmt: name => emph([(#name)]),
    title-fmt: emph,
    body-fmt: x => x,
    separator: [. ]
  )
)


#let teorema = thm.with(
  supplement: "Teorema",
  counter: "Theorem",
  fill: rgb("#e8e8f8"),
)
#let proposicion = thm.with(
  supplement: "Proposición",
  counter: "Theorem",
  fill: rgb("#e8f8ea"),
)
#let lema = thm.with(
  supplement: "Lema",
  counter: "Theorem"
)
#let conjetura = thm.with(
  supplement: "Conjetura",
  counter: "Theorem"
)

#let corolario = thm.with(
  supplement: "Corolario",
  counter: "Sub-Theorem",
  base: "Theorem"
)

#let definicion = thm-def.with(
  supplement: "Definicion",
  counter: "Theorem"
)
#let ejemplo = thm-def.with(
  supplement: "Ejemplo",
  counter: "Sub-Theorem",
  base: "Theorem"
)

#let problem = thm-def.with(
  supplement: "Problem",
  counter: "Problem"
)

#let aclaracion = thm-rem.with(
  supplement: "Aclaracion",
)
#let afirmacion = thm-rem.with(
  supplement: "afirmacion"
)

#let demostracion = thm.with(
  supplement: "Demostracion",
  numbering: none,
  fmt: thm-fmt-block.with(
    name-fmt: emph,
    title-fmt: emph,
    body-fmt: proof-body-fmt,
    separator: [. ]
  )
)