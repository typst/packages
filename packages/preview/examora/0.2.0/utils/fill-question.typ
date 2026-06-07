#import "@preview/suiji:0.4.0": *

#let fill-question(
  questions: ((:),),
  random: true,
  font-size: 13pt,
  show-answer: false,
  answer-color: red,
  leading: 1.5em,
  spacing: 1.5em,
  only-show-answer: false,
  continue-number: false,
  seed: 1,
) = {
  if random {
    let rng = gen-rng-f(seed)
    (rng, questions) = shuffle-f(rng, questions)
  }
  context if only-show-answer {
    let i = 1
    for qt in questions {
      context if continue-number {
        [#{ i + counter("question").get().first() - 1 }、]
      } else {
        [#i、]
      }
      for part in qt {
        if type(part) == array {
          [#part.at(0)]
        }
      }
      i += 1
      "\n"
    }
    if continue-number {
      counter("question").update(c => c + questions.len())
    }
  } else {
    set par(leading: leading, spacing: spacing)

    let i = 1
    for qt in questions {
      let n = if continue-number {
        i + counter("question").get().first() - 1
      } else { i }
      enum.item(n)[
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
    if continue-number {
      counter("question").update(c => c + questions.len())
    }
  }
}
