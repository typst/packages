#import "@preview/suiji:0.4.0": *

#let fill-question(
  questions: ((:),),
  random: true,
  font-size: 13pt,
  show-answer: false,
  answer-color: red,
  leading: 1.5em,
  spacing: 1.5em,
  seed: 1,
) = {
  if random {
    let rng = gen-rng-f(seed)
    (rng, questions) = shuffle-f(rng, questions)
  }
  set par(leading: leading, spacing: spacing)

  let i = 1
  for qt in questions {
    enum.item(i)[
      #for part in qt {
        if type(part) == array {
          let answer = part.at(0)
          let width = part.at(1)
          if show-answer {
            box(width: width, stroke: (bottom: 1pt + answer-color))[
              #align(center)[#text(weight: "bold", fill: answer-color)[#answer]]
            ]
          } else {
            box(width: width, stroke: (bottom: 1pt + black))
          }
        } else {
          part
        }
      }
    ]
    i += 1
  }
}
