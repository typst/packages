#import "/src/library.typ": colors, exercise
#import exercise: project, subtask, task
#import colors: *

#show: project.with(
    title: [History Exam],
    type: "Exam",

    show-point-distribution: true,
    show-namefield: true,
    show-timefield: true,

    max-time: 25,
    show-lines: true,

    show-solutions: true,
    show-grading-rubric: true,

    university: [],
    institute: [],

    abstract: [Task 1 is a facultative task. For each task 2 and 3, choose either version A or B. If both are solved, neither are scored.],
)

#task(numbering-format: (..) => "1")[Ingredients][
    Name the three necessary ingredients to make bread!
]

For each of the following tasks, choose either A or B!

#grid(columns: 2, column-gutter: 1em, row-gutter: 1.25em)[
    #task(numbering-format: (..) => "2A")[Hey][
        #lorem(20)
    ]
][
    #task(numbering-format: (..) => "2B")[Hey][
        #lorem(20)
    ]
][
    #task(numbering-format: (..) => "3A")[Hey][
        #lorem(20)
    ]
][
    #task(numbering-format: (..) => "3B")[Hey][
        #lorem(20)
    ]
]
