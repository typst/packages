#import "@preview/suiji:0.4.0": *

#let true-false-question(
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
    set enum(
      numbering: it => if show-answer {
        [#box(width: 3em, "( " + if questions.at(it - 1).at(1) { $checkmark$ } else { $crossmark$ } + "  ) ")#it.]
      } else {
        [#box(width: 3em, "(      ) ")#it.]
      },
    )
    enum.item(i)[
      #qt.at(0)
    ]
    i += 1
  }
}
