#import "@preview/suiji:0.4.0": *

#let choice-question(
  questions: ((:),),
  random: true,
  font-size: 13pt,
  side-length: 0pt,
  show-answer: false,
  answer-color: red,
  breakable: true,
  seed: 1,
) = {
  set text(size: font-size)
  let rng = gen-rng-f(seed)
  if random {
    (rng, questions) = shuffle-f(rng, questions)

    for i in range(questions.len()) {
      (rng, questions.at(i).at(1)) = shuffle-f(rng, questions.at(i).at(1))
    }
  }

  let isAnswer(c) = {
    return type(c) == array and c.at(1)
  }

  let getAnswer(choices) = {
    let answer = ()
    if (isAnswer(choices.at(0))) {
      answer.push("A")
    }
    if (isAnswer(choices.at(1))) {
      answer.push("B")
    }
    if (isAnswer(choices.at(2))) {
      answer.push("C")
    }
    if (isAnswer(choices.at(3))) {
      answer.push("D")
    }
    return answer.join()
  }

  let rowNum = calc.ceil(questions.len() / 10) * 2

  align(
    center,
    table(
      columns: (1fr,) * 11,
      align: center,
      inset: 0.3em,
      ..range(11 * rowNum).map(i => {
        let row = calc.floor(i / 11)
        let answerNum = i - 6 * row - 5
        let questionNum = i - row * 6
        if calc.rem(i, 22) == 0 {
          [题号]
        } else if calc.rem(row, 2) == 0 {
          if questionNum <= questions.len() {
            [#questionNum]
          } else { [] }
        } else if calc.rem(i, 11) == 0 {
          [答案]
        } else if show-answer and answerNum <= questions.len() {
          [#getAnswer(questions.at(answerNum - 1).at(1))]
        } else {
          []
        }
      })
    ),
  )

  for i in range(questions.len()) {
    let question = questions.at(i)
    let ct = [
      #enum.item(i + 1)[
        #question.at(0)
      ]

      #let choices = question.at(1)

      #let getChoice(c) = {
        if type(c) == str or type(c) == content {
          return c
        }
        return c.at(0)
      }

      #context [
        #let maxW = calc.max(..choices.map(c => measure(getChoice(c)).width.pt()))
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
            #if show-answer and isAnswer(c) {
              text(fill: answer-color, weight: "bold")[
                A. #getChoice(c)
              ]
            } else {
              [A. #getChoice(c)]
            }
            ],
          [
            #let c = choices.at(1)
            #if show-answer and isAnswer(c) {
              text(fill: answer-color, weight: "bold")[
                B. #getChoice(c)
              ]
            } else {
              [B. #getChoice(c)]
            }
            ],
          [
            #let c = choices.at(2)
            #if show-answer and isAnswer(c) {
              text(fill: answer-color, weight: "bold")[
                C. #getChoice(c)
              ]
            } else {
              [C. #getChoice(c)]
            }
            ],
          [
            #let c = choices.at(3)
            #if show-answer and isAnswer(c) {
              text(fill: answer-color, weight: "bold")[
                D. #getChoice(c)
              ]
            } else {
              [D. #getChoice(c)]
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
}
