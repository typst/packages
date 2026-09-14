#import "@preview/sheetstorm:0.2.0" as sheetstorm: task

#show: sheetstorm.setup.with(
  course: smallcaps[A very interesting course 101],
  title: "Assignment 42",
  authors: (
    (name: "John Doe", id: 123456),
    (name: "Erika Mustermann", id: 654321),
  ),

  info-box-enabled: true,
  score-box-enabled: true,
)

#task(name: "Introduction")[
  This is #link("https://github.com/rabuu/sheetstorm")[`sheetstorm`],
  a template library that provides a sane default layout for university assignment submissions with the option of customizability.

  Here you would write down your solutions for the first task:
  #lorem(100)
]

#task(name: "Subtasks", subtask-numbering: true, points: 3)[
  + _What is the color of a banana?_

    A banana is *yellow*.

  + _Solve the following equations for $x$._
    + $x^2 = 4 ==> x = plus.minus 2$
    + $x = integral_0^1 x^2 ==> x = [1/3 x^3]_0^1 = 1/3$
]

#task(points: 11)[
  Another task but without a name.

  Then you can do some cool math. You could, for example, try to proof that:
  $ forall n gt.eq 0: sum_(i=0)^n i = (n dot (n+1))/2 $

  _Proof._ It is easy to see that the statement is true for the number $0$:
  $sum_(i=0)^0 i = 0 = (0 dot 1)/2$
  Let's assume that the statement is true for some $n$. It follows:
  $ sum_(i=0)^(n+1) i 
    &= sum_(i=0)^n i + (n+1)
    = (n dot (n+1)) / 2 + (n + 1)
    = (n^2 + n) / 2 + (2n + 2)/2 \
    &= (n^2 + 3n + 2) / 2
    = ((n+1) dot (n+2)) / 2 $

  Therefore, the statement is proven using the principle of induction. #h(1fr)$square$
]

#task(points: 1, lorem(300))
