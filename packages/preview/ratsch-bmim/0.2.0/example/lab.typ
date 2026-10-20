#import "@local/ratsch-bmim:0.2.0" as bmim: task, enum-label, wrapped-enum-numbering, backmatter, important, tip, example, hint

#show: bmim.lab(
  title: ("Title"),
  lang: "de",
  course: ("Vorlesung", "VL"),
  authors: ("John Doe", "Jane Doe", "Max Mustermann"),
  date: datetime(day: 1, month: 3, year: 2024),
  show-solution: "inline",
)

#set math.equation(numbering: "(1.1)")

#outline()

= First Section

#lorem(10) @netwok2020

== First Subsection with number

#lorem(10)

#task(
  label: <task:main1>,
  [
    Test Problem with a equation
    $
      p & = s + 4
    $<eq:main1>
    and @netwok2020.
  ],
  (
    points: 10,
    label: <task:sub1>,
    description: [
      Test Problem

      Take a look in the solution
    ],
    solution: [
      Solution is $1+1=2$.
      w/e @task:main1 before @task:sub2
    ]
  ),
  (
    points: 10,
    label: <task:sub2>,
    description: [
      Test Problem

      Take a look in the solution
    ],
    solution: [
      Solution is $1+1=2$.
      w/e @task:main1 before @task:sub1 with @eq:main1.
    ]
  )
)

=== First Subsubsection

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
  label: <task:main2>,
  description: [
    Test Problem with a equation
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

#show: backmatter

= Appendix Section

#lorem(80)

= Appendix Section

#lorem(80)

#important[Test]

#tip[Test]

#example[#lorem(20)]

#hint[Test]

#bibliography("sources.bib", title: "Bibliography")
