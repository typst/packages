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
  answer-color: red,
  random: true,
  frame: true,
  frame-stroke: 0.2pt + black,
  double-page: true,
  mono-font: ("Cascadia Code", "LXGW WenKai Mono GB"),
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

  let bigQuestionCounter = counter("bigQuestion")
  let questionCounter = counter("question")

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
      ..args,
    ),
    title: (..args) => title(
      info: info,
      font: title-font,
      font-size: title-font-size,
      type: type,
      method: method,
      title-underline: title-underline,
    ),
    score-table: () => {
      align(center)[#context table(
          columns: (1fr,) * (bigQuestionCounter.final().first() + 2),
          inset: 0.6em,
          align: center,
          [题号], ..(range(1, bigQuestionCounter.final().first() + 1).map(int-to-cn-num)), [总分],
          [得分]
        )
      ]
    },
    questionHeader: desc => {
      bigQuestionCounter.step()
      context block(breakable: false)[
        #table(
          columns: (auto, auto),
          align: (center, left + horizon),
          table.cell(inset: 0.35cm, [得分]),
          table.cell(rowspan: 2, inset: 0.8cm, strong[#int-to-cn-num(bigQuestionCounter.get().first())、#desc]),
          questionCounter.update(1),
        )]
    },
    choice-question: questions => choice-question(
      seed: seed,
      random: random,
      questions: questions,
      side-length: margin.inside + margin.outside,
      show-answer: show-answer,
      answer-color: answer-color,
      font-size: font-size,
      breakable: choice-question-breakable,
    ),
    fill-question: (questions, ..args) => fill-question(
      seed: seed,
      random: random,
      questions: questions,
      font-size: font-size,
      show-answer: show-answer,
      answer-color: answer-color,
      ..args,
    ),
    true-false-question: (questions, ..args) => true-false-question(
      seed: seed,
      random: random,
      questions: questions,
      font-size: font-size,
      show-answer: show-answer,
      answer-color: answer-color,
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
      enum.item(questionCounter.get().first())[
        #question
      ]

      body

      if show-answer {
        set text(fill: answer-color)
        box(inset: 0pt, outset: 0pt, height: spacing, width: 100%)[#answer]

      } else {
        box(inset: 0pt, outset: 0pt, height: spacing, width: 100%)[]
      }
      questionCounter.step()
    },
  )
}
