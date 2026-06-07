#import "@preview/suiji:0.4.0": *

#let true-false-question(
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
    let i = 0
    for qt in questions {
      if i > 0 and calc.rem(i, 5) == 0 {
        "\n"
      }
      let n = if continue-number { i + counter("question").get().first() } else { i + 1 }
      [#n、#if questions.at(i - 1).at(1) { $checkmark$ } else { $crossmark$ } #h(1em)]
      i += 1
    }

    if continue-number {
      counter("question").update(c => c + questions.len())
    }
  } else {
    set par(leading: leading, spacing: spacing)

    let i = 1

    for qt in questions {
      set enum(
        numbering: it => if show-answer {
          [#box(width: 3em, "( " + if questions.at(i - 1).at(1) { $checkmark$ } else { $crossmark$ } + "  ) ")#it.]
        } else {
          [#box(width: 3em, "(      ) ")#it.]
        },
      )
      let n = if continue-number { i + counter("question").get().first() - 1 } else { i }
      enum.item(n)[
        #qt.at(0)
      ]
      i += 1
    }
    if continue-number {
      counter("question").update(c => c + questions.len())
    }
  }
}
