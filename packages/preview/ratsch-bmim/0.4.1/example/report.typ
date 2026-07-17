#import "./preamble.typ": *

#show: bmim.report(
  title: ("Task description"),
  lang: "en",
  course: ("Document creation Laboratory", "DCL"),
  authors: ("John Doe", "Jane Doe", "Max Mustermann"),
  date: datetime.today(),
  show-solution: "inline",
  task-show-points: true
)

#set math.equation(numbering: "(1.1)")

#outline()

= A Section

#lorem(10) @netwok2020

#task(
  points: 10,
  label: <task:main1>,
  description: [
    A single task without any subtasks
    $
      p & = s + 4
    $<eq:main2>
    and @netwok2020.

    Take a look in the solution
  ],
  solution: [
    Solution of @task:main1 is $1+1=2$.
  ]
)

== A numbered Subsection

#lorem(10)

#task(
  label: <task:main2>,
  [
    Test Problem with an equation
    $
      p & = s + 4
    $<eq:main1>
    and some citation @netwok2020.
  ],
  (
    points: 10,
    label: <task:sub1>,
    description: [
      This is a subtask description, it will tell you what to do.
    ],
    solution: [
      This is the solution of the subtask.
      We concolude that $1+1=2$.
      w/e @task:main2 before @task:sub2
    ]
  ),
  (
    points: 10,
    label: <task:sub2>,
    description: [
      This is another subtask description, better carry it out to the letter.
    ],
    solution: [
      This time the solution is $2+2=4$.
      w/e @task:main1 before @task:sub1 with @eq:main1 und @task:sub3.
    ]
  ),
  (
    points: 10,
    label: <task:sub3>,
    description: [
      This is yet another subtask description, better carry it out to the letter.
    ],
    solution: [
      This time the solution is $2+2=4$.
      w/e @task:main1 before @task:sub1 with @eq:main1.
    ]
  )
)

=== A numbered Subsubsection

#lorem(10)

#pagebreak()

== Second Subsection without number <bmim:nonumber>

#set enum(full: true, numbering: wrapped-enum-numbering("A"))

Group axioms:
+ #enum-label("ax:ass")Associativity
+ #enum-label("ax:id")Existence of identity element
+ #enum-label("ax:inv")Existence of inverse element


// #set enum(numbering: wrapped-enum-numbering("1.a"), full: true)
#set math.equation(numbering: "(1.1)")
Another important list:
+ Newton's laws of motion are three physical laws that relate the motion of an
  object to the forces acting on it.
  + A body remains at rest, or in motion at a constant speed in a straight
    line, unless it is acted upon by a force.
  + The net force on a body is equal to the body's acceleration multiplied by
    its mass
  + #enum-label[newton-third]If two bodies exert forces on each other, these
    forces have the same magnitude but opposite directions
+ #enum-label[hook1] Another important force is hooks law: $ arrow(F) = -k
  arrow(Delta x) $ <eq:hook> #enum-label[hook2]


We covered the three group axioms @ax:ass[], @ax:id[] and @ax:inv[].

It is important to remember Newton's third law @newton-third, and Hook's law
@hook1. In @hook2 we gave Hook's law in @eq:hook.

= Section

#lorem(20) @netwok2020

#task(
  points: 10,
  label: <task:main3>,
  description: [
    A task with no subtasks
    $
      p & = s + 4
    $<eq:main2>
    and @netwok2020.

    Take a look in the solution
  ],
  solution: [
    Solution of @task:main2 is $1+1=2$.
  ]
)
#task(
  points: 10,
  label: <task:main4>,
  description: [
    A task with no subtasks
    $
      p & = s + 4
    $<eq:main2>
    and @netwok2020.

    Take a look in the solution
  ],
  solution: [
    Solution of @task:main2 is $1+1=2$.
  ]
)

#task(
  label: <task:main11>,
  [
    Test Problem with an equation
    $
      p & = s + 4
    $<eq:main11>
    and some citation @netwok2020.
  ],
  (
    points: 10,
    label: <task:sub11>,
    description: [
      This is a subtask description, it will tell you what to do.
    ],
    solution: [
      This is the solution of the subtask. 
      We concolude that $1+1=2$.
      w/e @task:main11 before @task:sub12
    ]
  ),
  (
    points: 10,
    label: <task:sub12>,
    description: [
      This is another subtask description, better carry it out to the letter.
    ],
    solution: [
      This time the solution is $2+2=4$.
      w/e @task:main11 before @task:sub11 with @eq:main11.
    ]
  ),
  (
    points: 10,
    label: <task:sub13>,
    description: [
      This is yet another subtask description, better carry it out to the letter.
    ],
    solution: [
      This time the solution is $2+2=4$.
      w/e @task:main11 before @task:sub11 with @eq:main11 and @task:sub13.
    ]
  )
)

#show: backmatter

= Appendix Section

#lorem(80)

= Appendix Section

#lorem(80)

#bibliography("sources.bib", title: "Bibliography")
