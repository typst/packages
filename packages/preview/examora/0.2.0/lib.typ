#import "layouts/mainmatter.typ": mainmatter
#import "layouts/title.typ": title
#import "@preview/a2c-nums:0.0.1": int-to-cn-num
#import "utils/choice-question.typ": choice-question
#import "utils/fill-question.typ": fill-question
#import "utils/true-false-question.typ": true-false-question

#let documentclass(
  info: (:),
  margin: (
    top: 3cm,
    bottom: 3cm,
    outside: 2cm,
    inside: 4cm,
  ),
  type: "",
  method: "闭卷",
  seed: -1,
  font: ("Times New Roman", "KaiTi"),
  font-size: 13pt,
  show-answer: false,
  only-show-answer: false,
  continue-number: false,
  answer-color: red,
  random: true,
  frame: true,
  frame-stroke: 0.2pt + black,
  double-page: true,
  mono-font: ("JetBrains Mono", "LXGW WenKai Mono GB"),
  mono-font-size: 13pt,
  title-font: ("Times New Roman", "KaiTi"),
  title-underline: true,
  title-font-size: 1.5em,
  choice-question-breakable: true,
  student-info: ("学院", "专业班级", "姓名", "学号"),
) = {
  if seed < 0 {
    seed = if type == "" { 1 } else { type.codepoints().map(c => str.to-unicode(c)).sum() }
  }

  let big-question-counter = counter("big-question")
  let question-counter = counter("question")

  let get-num = n => {
    if text.lang == "zh" {
      return int-to-cn-num(n)
    } else {
      return numbering("I", n)
    }
  }

  return (
    mainmatter: (..args) => mainmatter(
      margin: margin,
      type: type,
      seed: seed,
      font: font,
      frame: frame,
      frame-stroke: frame-stroke,
      font-size: font-size,
      mono-font-size: mono-font-size,
      show-answer: show-answer,
      mono-font: mono-font,
      double-page: double-page,
      student-info: student-info,
      only-show-answer: only-show-answer,
      ..args,
    ),
    title: (..args) => title(
      info: info,
      font: title-font,
      font-size: title-font-size,
      type: type,
      method: method,
      title-underline: title-underline,
      only-show-answer: only-show-answer,
    ),
    score-table: () => {
      if not only-show-answer {
        align(center)[#context table(
            columns: (1fr,) * (big-question-counter.final().first() + 2),
            inset: if text.lang == "zh" { 0.6em } else { 0.3em },
            align: center,
            if text.lang == "zh" { [题号] } else { [Question] }, ..(
              range(1, big-question-counter.final().first() + 1).map(get-num)
            ), if text.lang == "zh" { [总分] } else { [Total] },
            if text.lang == "zh" { [得分] } else { [Score] }
          )
        ]
      }
    },
    question-header: desc => {
      big-question-counter.step()
      context if not continue-number or question-counter.get().first() == 0 {
        question-counter.update(1)
      }
      if not only-show-answer {
        context block(breakable: false)[
          #table(
            columns: (auto, auto),
            align: (center, left + horizon),
            table.cell(inset: 0.35cm, if text.lang == "zh" { [得分] } else { [Score] }),
            table.cell(rowspan: 2, inset: 0.8cm, strong[#get-num(big-question-counter.get().first())#if (
                text.lang == "zh"
              ) { "、" } else { ". " }#desc]),
          )]
      } else {
        context {
          [
            #get-num(big-question-counter.get().first())、#desc
          ]
        }
      }
    },
    choice-question: (questions, ..args) => choice-question(
      seed: seed,
      random: random,
      questions: questions,
      side-length: margin.inside + margin.outside,
      show-answer: show-answer,
      answer-color: answer-color,
      font-size: font-size,
      breakable: choice-question-breakable,
      only-show-answer: only-show-answer,
      continue-number: continue-number,
      ..args,
    ),
    fill-question: (questions, ..args) => fill-question(
      seed: seed,
      random: random,
      questions: questions,
      font-size: font-size,
      show-answer: show-answer,
      answer-color: answer-color,
      only-show-answer: only-show-answer,
      continue-number: continue-number,
      ..args,
    ),
    true-false-question: (questions, ..args) => true-false-question(
      seed: seed,
      random: random,
      questions: questions,
      font-size: font-size,
      show-answer: show-answer,
      answer-color: answer-color,
      only-show-answer: only-show-answer,
      continue-number: continue-number,
      ..args,
    ),
    question: (
      question: [],
      body: [],
      answer: [],
      spacing: 2pt,
      show-answer: show-answer,
      answer-color: answer-color,
    ) => context {
      enum.item(question-counter.get().first())[
        #if not only-show-answer {
          question
        } else {
          if answer == [] {
            if text.lang == "zh" { "(略)" } else { "(Omitted)" }
          } else {
            answer
          }
        }
      ]

      question-counter.step()

      if only-show-answer { return }

      body

      if show-answer {
        set text(fill: answer-color)
        box(inset: 0pt, outset: 0pt, height: spacing, width: 100%)[#answer]
      } else {
        box(inset: 0pt, outset: 0pt, height: spacing, width: 100%)[]
      }
    },
    new-page: () => {
      if not only-show-answer {
        pagebreak()
      }
    },
  )
}
