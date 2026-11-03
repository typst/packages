#import "@preview/suiji:0.5.1": *

#let choice-question(
  questions: ((:),),
  random: true,
  font-size: 13pt,
  side-length: 0pt,
  show-answer: false,
  answer-color: red,
  breakable: true,
  only-show-answer: false,
  continue-number: false,
  show-score-table: true,
  show-fill-blank: false,
  seed: 1,
) = {
  set text(size: font-size)
  let rng = gen-rng-f(seed)
  if random {
    (rng, questions) = shuffle-f(rng, questions)

    for i in range(questions.len()) {
      let qt = questions.at(i)
      let fixed = false
      for itm in qt {
        if type(itm) == dictionary and "fixed" in itm and itm.at("fixed") {
          fixed = true
        }
      }
      if not fixed {
        (rng, questions.at(i).at(1)) = shuffle-f(rng, questions.at(i).at(1))
      }
    }
  }

  let is-answer(c) = {
    return type(c) == array and c.at(1)
  }

  let get-answer(choices) = {
    let answer = ()
    if (is-answer(choices.at(0))) {
      answer.push("A")
    }
    if (is-answer(choices.at(1))) {
      answer.push("B")
    }
    if (is-answer(choices.at(2))) {
      answer.push("C")
    }
    if (is-answer(choices.at(3))) {
      answer.push("D")
    }
    return answer.join()
  }

  let row-num = calc.ceil(questions.len() / 10) * 2

  context if not only-show-answer {
    if show-score-table {
      align(
        center,
        table(
          columns: (1fr,) * 11,
          align: center,
          inset: 0.3em,
          ..range(11 * row-num).map(i => {
            let row = calc.floor(i / 11)
            let answer-num = i - 6 * row - 5
            let question-num = i - row * 6
            if calc.rem(i, 22) == 0 {
              if text.lang == "zh" { [题号] } else { [ID] }
            } else if calc.rem(row, 2) == 0 {
              if question-num <= questions.len() {
                [#question-num]
              } else { [] }
            } else if calc.rem(i, 11) == 0 {
              if text.lang == "zh" { [答案] } else { [Ans] }
            } else if show-answer and answer-num <= questions.len() {
              [#get-answer(questions.at(answer-num - 1).at(1))]
            } else {
              []
            }
          })
        ),
      )
    }
  }

  if not only-show-answer {
    for i in range(questions.len()) {
      let question = questions.at(i)
      let ct = [
        #enum.item(i + 1)[
          #question.at(0)
          #if show-fill-blank {
            [#box(baseline: -0.1em)[(#h(2em))]]
          }
        ]

        #let choices = question.at(1)

        #let get-choice(c) = {
          if type(c) == str or type(c) == content {
            return c
          }
          return c.at(0)
        }

        #context [
          #let maxW = calc.max(..choices.map(c => measure(get-choice(c)).width.pt()))
          #let columNum = 1

          #if maxW * 1pt < ((page.width - side-length) / 4 - font-size * 2) {
            columNum = 4
          } else if maxW * 1pt < ((page.width - side-length) / 2 - font-size * 2) {
            columNum = 2
          }

          #let ist = question.find(e => type(e) == dictionary and e.keys().contains("inset"))

          #grid(
            columns: (1fr,) * columNum,
            inset: if ist == none {
              0.5em
            } else { ist.at("inset") },
            [
              #let c = choices.at(0)
              #if show-answer and is-answer(c) {
                text(fill: answer-color, weight: "bold")[
                  A. #get-choice(c)
                ]
              } else {
                [A. #get-choice(c)]
              }
            ],
            [
              #let c = choices.at(1)
              #if show-answer and is-answer(c) {
                text(fill: answer-color, weight: "bold")[
                  B. #get-choice(c)
                ]
              } else {
                [B. #get-choice(c)]
              }
            ],
            [
              #let c = choices.at(2)
              #if show-answer and is-answer(c) {
                text(fill: answer-color, weight: "bold")[
                  C. #get-choice(c)
                ]
              } else {
                [C. #get-choice(c)]
              }
            ],
            [
              #let c = choices.at(3)
              #if show-answer and is-answer(c) {
                text(fill: answer-color, weight: "bold")[
                  D. #get-choice(c)
                ]
              } else {
                [D. #get-choice(c)]
              }
            ],
          )
        ]
      ]
      if breakable {
        ct
      } else {
        box(width: 100%)[#ct]
      }
    }
  } else {
    for i in range(questions.len()) {
      let question = questions.at(i)
      if calc.rem(i, 5) == 0 and i > 0 {
        "\n"
      }
      context if continue-number {
        [#{ i + counter("question").get().first() }]
      } else { [#{ i + 1 }] }
      [、#get-answer(question.at(1))#h(2em)]
    }
    if calc.rem(questions.len(), 5) != 0 {
      "\n"
    }
  }

  context if continue-number {
    counter("question").update(c => c + questions.len())
  }
}
