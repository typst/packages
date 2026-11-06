#import "env.typ"
#import "term.typ": *
#import "question.typ": *
#import "question-group.typ": *
#import "reference.typ": *
#import "answer.typ": *
#import "utils.typ": *

#let si = sxj-student-info
#let un = sxj-unit
#let op = sxj-options
#let br = sxj-bracket
#let bl = sxj-blank

#let qst(level: 2, body) = context sxj-question-zh(level: level, body)
#let qg = sxj-question-group
#let ans = sxj-answer-sol

#let rfq(
  ref-style: auto,
  counter-with-acc-to-nums: auto,
  target,
) = context sxj-ref-to-question(
  ref-style: ref-style,
  counter-with-acc-to-nums: counter-with-acc-to-nums,
  (target: target),
)
#let cu = sxj-counter-question-update

#let shuxuejuan(body) = {
  show title: it => sxj-title(size: env-get("font-size").huge, body: it)
  show heading: it => sxj-question-zh(level: it.level, it.body)
  show ref: it => if it.element == none {
    it
  } else if it.element.func() == heading {
    sxj-ref-to-question(it)
  } else { it }
  show math.equation: it => sxj-equ(spacing: .2em, it)
  show "。": "．"

  set page(
    width: 18.4cm,
    height: 26cm,
    margin: 19pt,
    footer: context sxj-footer(
      counter(page).get().first(),
      counter(page).final().first(),
    ),
  )
  set par(justify: true)

  body
}
