#import "@local/ratsch-bmim:0.2.0" as bmim: task, hint

#show: bmim.workbook(
  course: [Vorlesung],
  authors: ("John Doe", "Jane Doe", "Max Mustermann"),
  lang:"de",
  show-solution: "inline",
)

#set math.equation(numbering: "(1.1)")

= Systems

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

== first subs

#lorem(30)

== second subs

#lorem(30)

#pagebreak()

#lorem(30)

= Second

#lorem(30)

#pagebreak()

#lorem(30)

#bibliography("sources.bib", title: "References")
