#import "@preview/exm:0.1.0": *

#show: doc => assignment(doc,
  courseid: "CourseID",
  coursename: "CourseName",
  school: "School",
  semester: "Semester",
  assignment: "Assignment XX",
  title: "Assignment Title"
)

#let section = section.with(number: true)

#docmode.update("screen")

#section("Question Components", number: true)[
  A standard question:

  #question(ansbox: true, height: 2cm, points: 4.0)[
    What is $2 + 2$? Write a statement to evaluate in Python.
    // since this is just Typst content, it can be anything (could include tables, math, images, code blocks, etc...)
  ][
    ```py
    2 + 2  # 4
    ```
  ]

  A multi-choice question:

  #mcq([What will the following Python expression be equivalent to?
    #align(center)[`2 + 2`]
  ], (
    `4`,
    `len(np.array([1, 2, 3, 4]))`,
    `2`,
    `6`,
    "None of the above"
  ),
    (0, 1),
    points: 3.0,
    multi: (true, true, true, true, false)
  )

  #mcq([You can display options with different column lengths.], (
    [Option 1], [Option 2], [Option 3], [Option 4]
  ),
    2,
    points: 3.0,
    multi: false,
    cols: (2.5cm, 5cm, 7cm, 4cm),
  )

  An answer bank:

  #ansbank(cols: 3, choices: (
    [$x^2$], "A quadratic", `x ** 2`,
    "A quartic", $x dot.c x dot.c x$, `pow(x, 3)`
  ))

  #mcq([
    What of the following functions are even?
  ], 
    range(8).map(i => [*#str.from-unicode(65 + i)*]) + ("None of the above",),
    (0,3,4),
    points: 1.0,
    cols: range(8).map(i => 1.53cm) + (10cm,),
    multi: range(8).map(i => true) + (false,)
  )





  #ansbank(cols: 3, choices: (
    [$x^2$], "Any linear function", `x ** 2`,
    "Any quadratic function", $x dot.c x dot.c x$, `pow(x, 3)`,
    $sin(x)$, "Any quartic function", $cos(x)$
  ))

  #mcq([
    What of the following functions are even?
  ], 
    range(9).map(i => [*#str.from-unicode(65 + i)*]) + ("None of the above",),
    (0,2,8),
    points: 1.0,
    cols: range(9).map(i => 1.53cm) + (10cm,),
    multi: range(9).map(i => true) + (false,)
  )
]

#pagebreak()

#section("Second Section", points: true)[
  Content in this second section does total up points

  + #question(points:2.0)[Subquestion][Subquestion answer]

  + #question(points:2.0)[Subquestion][Subquestion answer]

  + #question(points:2.0)[Subquestion][Subquestion answer]
]

#pagebreak()

#section("Callouts")[
  #callout("")[
    You may create a callout with an empty string `""` to omit the title. Any non-special typed callout will be grey by default. 
  ]

  Special callout types (`Definition, Formula, Method, Example`)

  #callout("Definition")[
    A definition callout
  ]

  #callout("Formula")[
    A formula callout
  ]

  #callout("Method")[
    A method callout
  ]

  #callout("Example")[
    An example callout
  ]
]

#v(24pt)

#section("Code Blanks")[
  Complete the `distance` function below, which takes arrays of two predictor variables `p1` and `p2` and returns a distance between a new point `row` and each row in the training data.

  `def distance(p1, p2, row):`

  `    arr = np.array(row)`

  `    v1 = arr.`#blank(150pt, "[A]")

  `    v2 = arr.`#blank(150pt, "[B]")

  `    distances = `#blank(250pt, "[C]")

  `    `#blank(200pt, "[D]")

  #v(4pt)

  + #question(points:2.0,ansbox:true,height:1.5cm)[
    What function should be used in blanks `[A]` and `[B]` to retrieve the two items in the array?
  ][`.item`]

  + #question(points:2.0,ansbox:true,height:1.5cm)[
    Fill in the blank `[C]`, such that the `distance` function returns an *array* of Euclidean distances.][
    `((p1 - v1) ** 2 + (p2 - v2) ** 2) ** 0.5` #h(3pt) *or* #h(3pt) use `np.sqrt(...)`
  ]

  + #question(points:1.0,ansbox:true,height:1.5cm)[
    Fill in the blank `[D]`.
  ][`return distances`]
]
