#import "env.typ"
#import "utils.typ": *
#import "question.typ": *
#import "question-group.typ": *
#import "reference.typ": *
#import "answer.typ"

#let title = sxj-title
#let title-small = sxj-title-small
#let si = sxj-student-info
#let un = sxj-unit
#let rn = sxj-question-reset-num
#let op = sxj-options
#let qg = sxj-question-group
#let bl = sxj-blank
#let br = sxj-bracket

#let shuxuejuan(font: (), font-bold: (), leading: .68em, qst-number-level2: none, body) = {
  set text(font: font)
  set pagebreak(weak: true)
  set heading(numbering: "1.")
  set table(align: center + horizon)
  set par(leading: leading)
  set page(
    paper: "iso-b5",
    footer: context sxj-footer(counter(page).get().first(), counter(page).final().first()),
  )

  show "。": "．"
  show text.where(weight: "semibold").or(text.where(weight: "bold")).or(text.where(weight: "extrabold")): set text(
    // Can't bold SimSun, use LXGW WenKai for substitution
    font: font-bold,
  )
  show math.equation: sxj-equ

  show heading: it => sxj-question(it.level, it.body, qst-number-level2: qst-number-level2)
  show ref: it => {
    if it.element.func() == heading {
      sxj-ref-question(it, qst-number-level2: qst-number-level2)
    }
  }

  sxj-question-reset-num()

  body
}
