#import "@preview/sheetstorm:0.4.0": *

#show: assignment.with(
  course: smallcaps[Sheetstorm 101],
  title: "Assignment Example",
  authors: (
    (name: "John Doe", id: 123456),
    (name: "Erika Mustermann", id: 654321),
  ),
  info-box-enabled: true,
  score-box-enabled: true,
  // Here you can customize the layout of the page, the header, the widgets.
  // Look at the parameters of the `assignment` function.
)

#task(name: "Introduction")[
  This is #link("https://github.com/rabuu/sheetstorm")[`sheetstorm`],
  a template library that provides a sane default layout for assignment submissions
  with the option of customizability.

  Here you would write down your solutions for the first task:
  #lorem(30)
]

#task(name: "Subtasks", label: "task-subtasks", points: (1, 2))[
  + _What is the color of a banana?_ #subtask-label("banana", display: "a)")

    A banana is *yellow*.

  + _Solve the following equations for $x$._
    + $x^2 = 4 ==> x = plus.minus 2$
    + $x = "color of banana" ==> x = "yellow"$, see @banana.
]

#task(points: 11)[
  Another task but without a name.
  You can reference tasks from above where you set a label, for example @task-subtasks.

  Then you can do some cool math. You could, for example, try to proof that:
  $ forall n gt.eq 0: sum_(i=0)^n i = (n dot (n+1))/2 $

  #proof[
    It is easy to see that the statement is true for the number $0$:
    $sum_(i=0)^0 i = 0 = (0 dot 1)/2$.
    Let's assume that the statement is true for some $n$. It follows:
    $
      sum_(i=0)^(n+1) i & = sum_(i=0)^n i + (n+1)
                          = (n dot (n+1)) / 2 + (n + 1)
                          = (n^2 + n) / 2 + (2n + 2)/2 \
                        & = (n^2 + 3n + 2) / 2
                          = ((n+1) dot (n+2)) / 2
    $
  ]
]

#task(points: 1, bonus: true)[
  #theorem(name: "Very smart formula", label: "example-theorem")[
    Let $x$ be a natural number. Then:
    $ x + 1 + 1 = x + 2 $
  ]
  #proof[The proof of @example-theorem is trivial.]

  #lorem(50)
]
