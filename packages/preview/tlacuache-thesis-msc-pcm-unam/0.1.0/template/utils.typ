#import "@preview/ctheorems:1.1.3": *
#show: thmrules
// Some basic enviroments
#let teorema = thmbox(
  "teorema", // identifier
  "Teorema", // head
  fill: rgb("#e8e8f8"),
).with(supplement: none)


#let corolario = thmbox(
  "corolario", // identifier
  "Corolario", // head
  base: "teorema", // base - use the theorem counter
  fill: rgb("#f8e8e8"),
).with(supplement: none)


#let proposicion = thmbox(
  "proposicion", // identifier
  "Proposición", // head
  fill: rgb("#e8f8ea"),
).with(supplement: none)


#let definicion = thmbox("definicion", "Definición", inset: (x: 0.0em, top: 0.0em)).with(supplement: "definición")

#let ejemplo = thmplain("ejemplo", "Ejemplo").with(numbering: none)
#let demostracion = thmproof("demostracion", "Demostración")

#let observacion = thmplain("observación", "Observación", base: "heading")
