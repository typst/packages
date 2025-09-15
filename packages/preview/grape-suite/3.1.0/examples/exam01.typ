#import "/src/library.typ": exercise, colors
#import exercise: project, task, subtask
#import colors: *

#show: project.with(
    no: 1,
    type: [LEV],
    suffix-title: [Logische Grundlagen],

    show-point-distribution-in-tasks: true,
    show-namefield: true,
    show-timefield: true,

    max-time: 25,
    show-lines: true,

    show-solutions: true,
    solutions-as-matrix: true,

    university: [Universität Musterstadt],
    institute: [Institut für Philosophie],
    seminar: [Tutorium: Sprache, Logik, Argumentation],

    task-type: [Aufgabe],
    extra-task-type: [Extraaufgabe],

    solution-matrix-task-header: [Aufgabe],
    solution-matrix-achieved-points-header: [Erreichte Punkte],

    distribution-header-point-value: [Punkte],
    distribution-header-point-grade: [Wert],

    message: (points-sum, extrapoints-sum) => [Insgesamt sind #points-sum + #extrapoints-sum P. erreichbar. Sie haben #box(line(stroke: purple, length: 1cm)) P. von #points-sum P. erreicht.],

    solutions-title: [Lösungsvorschläge],
    timefield: (time) => [Zeit: #time min.],

    grade-scale: (([sehr gut], 0.9), ([gut], 0.76), ([befriedigend], 0.63), ([ausreichend], 0.5), ([n.b.], 0.49))
)

#task(lines: 10, points: 3, [Grundbegriffe], [
    Erklären Sie, womit sich die Logik beschäftigt. Nennen Sie außerdem die zwei Gütekriterien von Argumenten.
], [], (
    (1, [Bestimmung der Logik als Lehre vom gültigen, formalen Schließen.]),
    (2, [Benennen der Gütekriterien Gültigkeit und Schlüssigkeit.]),
))

#task(lines: 20, [Gütekriterien], [
    Beurteilen Sie die folgenden Argumente jeweils in Bezug auf die zwei Gütekriterien! Begründen Sie ihre Antworten kurz.
], [
    #subtask(points: 2)[
        Wenn ich auf dem Mond laufe, kann ich höher springen als auf der Erde. \
        Ich kann nicht höher als auf der Erde springen.\
        #box(line(length: 5cm)) \
        Ich bin nicht auf dem Mond.
    ]

    #subtask(points: 2)[
        Entweder alle Kirschen sind grün oder es regnet Sonnenstrahlen.\
        Nicht alle Kirschen sind grün.\
        #box(line(length: 5cm)) \
        Also regnet es Sonnenstrahlen.
    ]

    #subtask(points: 2)[
        Alle Menschen können Fleisch essen.\
        #box(line(length: 5cm)) \
        Alle Menschen sollten Fleisch essen.
    ]

], (
    (2, [
        1. Das Argument wurde als schlüssig und gültig charakterisiert, da die Prämissen wahr und die Konklusion logisch aus den Prämissen folgt. Wurde es als unschlüssig beurteilt, so muss eine Begründung erfolgen.
    ]),

    (2, [
        2. Das Argument wurde als gültig, aber nicht schlüssig beurteilt, da die Prämissen falsch sind aber die Konklusion logisch aus den Prämissen folgt. Weder sind alle Kirschen grün, noch regnet es Sonnenstrahlen, daher ist die erste Prämisse falsch. Für eine andere Bewertung muss eine angemessene Begründung vorgebracht werden.
    ]),

    (2, [
        3. Das Argument ist weder schlüssig noch gültig. Da das Argument nicht gültig ist und auch nicht als gültig gesehen werden kann, kann es ebenfalls nicht schlüssig sein.
    ]),
))

#task(lines: 10, [logische Folgerung], [
    Geben Sie zu jedem Argument eine Konklusion an, die logisch aus den Prämissen folgt!
], [
    #subtask(points: 1)[
        Alle Vögel können fliegen.\
        Ein Pinguin ist ein Vogel.\
        #box(line(length: 5cm)) \
        ...
    ]

    #subtask(points: 1)[
        Pinguine leben am Südpol und Eisbären am Nordpol.\
        #box(line(length: 5cm)) \
        ...
    ]

    #subtask(points: 1)[
        Die Straße ist nass.\
        #box(line(length: 5cm)) \
        ...
    ]
], (
    (1, [
        Eines der folgenden:
        - "Alle Vögel können fliegen."
        - "Ein Pinguin ist ein Vogel."
        - "Ein Pinguin kann fliegen."
        - äquivalente oder allgemeingültige Aussagen
    ]),

    (1, [
        Eines der folgenden:
        - "Pinguine leben am Südpol und Eisbären am Nordpol."
        - "Pinguine leben am Südpol."
        - "Eisbären leben am Nordpol."
        - äquivalente oder allgemeingültige Aussagen
    ]),

    (1, [
        Eines der folgenden:
        - "Die Straße ist nass."
        - "Es ist nicht der Fall, dass die Straße nicht nass ist."
        - äquivalente oder allgemeingültige Aussagen
    ]),
))

#task(lines: 10, points: 4, extra: true, [Beweis], [
    Beweisen Sie die Gültigkeit des folgenden Arguments durch einen indirekten Beweis!
], [
        Alle Ärzte sind brilliant. \
        Alle Chirurgen sind Ärzte. \
        #box(line(length: 5cm)) \
        Alle Chirurgen sind brilliant.
], (
    (1, [Die Konklusion wurde verneint.]),
    (1, [Weitere Beweisschritte sind nachvollziehbar.]),
    (1, [Der Widerspruch wurde gefunden.]),
    (1, [Der Beweis wurde mit "QED" beendet.]),
))