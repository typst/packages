#import "@local/ratsch-bmim:0.2.0" as bmim: task

#show: bmim.exam(
  title: "Eingangstest",
  course: ([Vorlesung],[VL]),
  authors: ("John Doe", "Jane Doe", "Max Mustermann"),
  show-solution: "bottom",
  empty-sheets: auto,
  total-time: [90min],
  show-hints: true,
  lang: "de",
)

#set math.equation(numbering: "(1.1)")

#task(
  label: <task:main1>,
  [
    Test Problem with a equation
    $
      p & = s + 4
    $<eq:main1>
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
    and a reference to @eq:main1 in @task:main2.

    Take a look in the solution
  ],
  solution: [
    Solution of @task:main2 is $1+1=2$.
  ]
)
