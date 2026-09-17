#import "@preview/showybox:2.0.4": showybox
#import "@preview/ctheorems:1.1.3": thmenv
#import "translated_terms.typ": *

#let color-purple = rgb("#9a77cf")
#let color-pink = rgb("#ff71ce")
#let color-blue = rgb("#118dc3")
#let color-green = rgb("#1da912")
#let color-orange = rgb("#ee9025")
#let color-yellow = rgb("#eea825")
#let color-red = rgb("#e05661")
#let color-gray = rgb("#9b9fa6")

#let boxnumbering = "1.1.1.1.1.1"
#let boxcounting = "heading"

// General box
#let box_thm(
  identifier,
  title,
  base-color,
  numbered: true,
  breakable: true,
) = thmenv(
  identifier,
  boxcounting,
  none,
  (name, number, body, ..args) => {
    showybox(
      breakable: breakable,
      frame: (
        border-color: base-color,
        body-color: base-color.lighten(96%),
        thickness: (left: 2pt, right: 2pt, rest: 0pt),
        radius: (right: 3pt, left: 3pt),
        inset: (x: 12pt, y: 12pt),
      ),
      footer-style: (color: base-color),
      ..args.named(),
      [
        #text(fill: base-color, weight: "bold")[#title]
        #if numbered [ #text(fill: base-color, weight: "bold")[#number] ]
        #if name != none [ #text(fill: base-color.darken(20%), style: "italic")[ (#name)] ]
        #text(fill: base-color, weight: "bold")[.]
        #h(0.4em)
        #body
      ],
    )
  },
).with(numbering: boxnumbering)

#let theorem = box_thm("theorem", get_translation(translated_terms.theorem), color-purple)
#let corollary = box_thm("corollary", get_translation(translated_terms.corollary), color-purple)
#let lemma = box_thm("lemma", get_translation(translated_terms.lemma), color-purple)
#let proposition = box_thm("proposition", get_translation(translated_terms.proposition), color-purple)
#let hypothesis = box_thm("hypothesis", get_translation(translated_terms.hypothesis), color-pink)
#let definition = box_thm("definition", get_translation(translated_terms.definition), color-blue)
#let example = box_thm("example", get_translation(translated_terms.example), color-green)
#let note = box_thm("note", get_translation(translated_terms.note), color-yellow)
#let attention = box_thm("attention", get_translation(translated_terms.attention), color-red)
#let important = box_thm("important", get_translation(translated_terms.important), color-red)
#let exercise = box_thm("exercise", get_translation(translated_terms.exercise), color-orange)
#let tip = box_thm("tip", get_translation(translated_terms.tip), numbered: false, color-pink)
#let remark = box_thm("remark", get_translation(translated_terms.remark), numbered: false, color-gray)
#let proof = thmenv(
  "proof",
  boxcounting,
  none,
  (name, number, body, ..args) => {
    block(
      width: 100%,
      breakable: true,
      inset: (top: 0.5em, bottom: 0.5em),
      [*_#get_translation(translated_terms.proof)._*] + body + [#h(1fr) $qed$],
    )
  },
).with(numbering: none)
