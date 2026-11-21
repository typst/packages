// A starter exam: a cover page with a points table, followed by questions
// with answer boxes, parts, multiple choice, and a bonus.
//
// Student version:  typst compile main.typ
// Answer key:       typst compile --input show-solutions=true main.typ
#import "@preview/examy:1.0.0": *

#set page(paper: "us-letter", margin: (x: .75in, bottom: .75in, top: 1in))
#show: exam.with(
  show-solutions: false,
  institution: [University Name],
  exam-name: [Course 101 Midterm Exam],
  term: [Fall 2026],
  duration: duration(minutes: 50),
)

// The title and name blocks, in the monospaced font bundled with Typst.
#{
  set text(font: "DejaVu Sans Mono")
  maketitle()
  name-block(fields: (
    (prefix: [Name:]),
    (prefix: [Student ID:]),
  ))
}

#underline[_Instructions:_]
- Answer each question in the box provided; work outside the boxes will
  not be graded.
- The back of each page may be used for scratch work.
- No calculators or other aids are permitted.

#v(1fr)
#{
  set align(center)
  points-table()
}
#pagebreak()

#question(points: 2)[
  State the definition of a _continuous function_.
  #answer-box(height: 1fr)[
    #solution[
      $f$ is continuous at $a$ if $lim_(x -> a) f(x) = f(a)$.
    ]
  ]
]

#question(points: 1)[
  Which of these functions is differentiable at $x = 0$? _Select one._
  #choices(columns: 2)[
    - $|x|$
    + $x^2$
    - $root(3, x)$
    - $1/x$
  ]
]

#question[
  Let $f(x) = x^3 - 3x$.
  #part(points: 2, label: <critical>)[
    Find the critical points of $f$.
    #answer-box(height: 1fr)[
      #solution[
        $f'(x) = 3x^2 - 3 = 0$ gives $x = plus.minus 1$.
      ]
    ]
  ]
  #part(points: 2)[
    Classify each critical point you found in @critical as a local
    maximum or a local minimum.
    #answer-box(height: 1fr)[
      #solution[
        $f''(x) = 6x$, so $x = -1$ is a local maximum and $x = 1$ is a
        local minimum.
      ]
    ]
  ]
  #part(points: 1, intent: "bonus")[
    *Bonus:* How many real roots does $f$ have?
    #answer-box(width: 100%, height: 3cm)[
      #solution[Three: $x = 0$ and $x = plus.minus sqrt(3)$.]
    ]
  ]
]
