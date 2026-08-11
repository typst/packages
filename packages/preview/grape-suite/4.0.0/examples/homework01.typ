#import "/src/library.typ": exercise
#import exercise: hint, project, solution, subtask, task

#let task = task.with(numbering-format: (..n) => numbering("1", ..n))
#let subtask = subtask.with(markers: ("a)", "1)"))

#show: project.with(
    no: 1,
    type: "Exercise",
    suffix-title: "Depictions of Pegasus in Ancient Greek Literature",
    show-hints: sys.inputs.at("hints", default: "false") == "true",
    show-solutions: sys.inputs.at("solutions", default: "false") == "true",

    show-grading-rubric: true,

    university: [Universität Musterstadt],
    institute: [Historisches Institut],
    seminar: [Seminar: Antike Mythologie],

    date: datetime(year: 2024, month: 12, day: 31),
)

#task(
    rubric: ((1, lorem(20)), (3, lorem(23))),
    [Pegasus in mythology],
    none,
    [
        #subtask(points: 3)[
            Describe the origin story of Pegasus in Greek mythology. Discuss his origins and the key figures associated with him.
        ]

        #subtask(points: 1)[
            Analyze the role of Pegasus in the myth of Bellerophon. What significance does Pegasus have for the course and outcome of the story?
        ]

        #solution[
            #subtask[
                #lorem(20)
            ]

            #subtask[
                #lorem(20)
            ]
        ]

        #hint[
            #subtask(counter: 2)[
                #lorem(20)
            ]
        ]
    ],
)

#task(points: 5)[Pegasus in literary sources][
    Compare the depiction of Pegasus in two ancient Greek sources (e.g., Hesiod’s Theogony and Pindar’s Odes). Discuss the differences and similarities in the symbolism and characterization of Pegasus.
]

#task(points: 6, rubric: (
    (1, lorem(20)),
    (3, lorem(23)),
    (2, lorem(30)),
))[Pegasus as a cultural symbol][
    Discuss the significance of Pegasus as a symbol in ancient Greek culture. What values or concepts does it embody? In your discussion, also refer to its later portrayal in art and literature.
][
    #solution[
        #lorem(50)
    ]
]
