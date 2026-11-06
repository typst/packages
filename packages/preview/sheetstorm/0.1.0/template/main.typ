#import "@preview/sheetstorm:0.1.0" as sheetstorm: task

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
  This is the #link("https://github.com/rabuu/sheetstorm")[`sheetstorm`].
  It provides a sane default layout for university assignment submissions with the option of customizability.

  Here you would write down your solutions for the first task:
  #lorem(100)
]

#task(name: "Subtasks", subtask-numbering: true)[
  + _What is the color of a banana?_

    A banana is *yellow*.

  + _Solve the following equations for $x$._
    + $x^2 = 4 ==> x = plus.minus 2$
    + $x = integral_0^1 x^2 ==> x = [1/3 x^3]_0^1 = 1/3$
]

#task[
  Another task but without a name.

  #lorem(1300)
]
