#import "env.typ"
#import "utils.typ": *
#import "question.typ": *
#import "question-group.typ": *
#import "reference.typ": *
#import "answer.typ"

#let Title = sxjTitle
#let TitleSmall = sxjTitleSmall
#let si = sxjStudentInfo
#let un = sxjUnit
#let rn = sxjResetQuestionNum
#let op = sxjOptions
#let qg = sxjQuestionGroup
#let bl = sxjBlank
#let br = sxjBracket

#let shuxuejuan(font: (), font-bold: (), leading: .68em, qst-number-level2: none, body) = {
  set text(font: font)
  set pagebreak(weak: true)
  set heading(numbering: "1.")
  set table(align: center + horizon)
  set par(leading: leading)
  set page(
    paper: "iso-b5",
    footer: context sxjFooter(counter(page).get().first(), counter(page).final().first()),
  )

  show "。": "．"
  show text.where(weight: "semibold").or(text.where(weight: "bold")).or(text.where(weight: "extrabold")): set text(
    // Can't bold SimSun, use LXGW WenKai for substitution
    font: font-bold,
  )
  show math.equation: sxjEqu

  show heading: it => sxjQuestion(it.level, it.body, qst-number-level2: qst-number-level2)
  show ref: it => {
    if it.element.func() == heading {
      reference_fromQuestion(it, qst-number-level2: qst-number-level2)
    }
  }

  sxjResetQuestionNum()

  body
}
