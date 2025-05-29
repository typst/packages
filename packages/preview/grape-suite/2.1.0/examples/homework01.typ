#import "/src/library.typ": exercise
#import exercise: project, task, subtask

#let task = task.with(numbering-format: (..n) => numbering("1", ..n))
#let subtask = subtask.with(markers: ("a)", "1)"))

#show: project.with(no: 1,
    type: "Aufgabenblatt",
    suffix-title: "Darstellungen des Pegasus in der antiken griechischen Literatur",

    show-solutions: true,
    show-hints: true,

    task-type: [Aufgabe],
    extra-task-type: [Zusatzaufgabe],

    solution-type: [Lösungsvorschlag],
    solutions-title: [Lösungsvorschläge],

    hint-type: [Hinweis],
    hints-title: [Hinweise],

    box-task-title: [Aufgabe],
    box-hint-title: [Hinweis],
    box-solution-title: [Lösung],

    university: [Universität Musterstadt],
    institute: [Historisches Institut],
    seminar: [Seminar: Antike Mythologie],

    date: datetime(year: 2024, month: 12, day: 31)
)

#task[Pegasus in der Mythologie][][
    #subtask[
        Beschreiben Sie die Entstehungsgeschichte des Pegasus in der griechischen Mythologie. Gehen Sie dabei auf seine Herkunft und die wichtigsten Figuren ein, die mit ihm verbunden sind.
    ]

    #subtask[
        Analysieren Sie die Rolle des Pegasus im Mythos von Bellerophon. Welche Bedeutung hat Pegasus für den Verlauf und den Ausgang der Geschichte?
    ]
][ // Solution
    #subtask[
        #lorem(20)
    ]

    #subtask[
        #lorem(20)
    ]
][ // Hints
    #subtask(counter: 2)[
        #lorem(20)
    ]
]

#task[Pegasus in literarischen Quellen][
    Vergleichen Sie die Darstellung des Pegasus in zwei antiken griechischen Quellen (z.B. in Hesiods Theogonie und Pindars Oden). Gehen Sie auf Unterschiede und Gemeinsamkeiten in der Symbolik und Charakterisierung des Pegasus ein.
]

#task[Pegasus als kulturelles Symbol][
    Diskutieren Sie die Bedeutung des Pegasus als Symbol in der antiken griechischen Kultur. Welche Werte oder Konzepte verkörpert er? Beziehen Sie sich dabei auch auf seine spätere Rezeption in Kunst und Literatur.
][][ // Solution
    #lorem(50)
]
