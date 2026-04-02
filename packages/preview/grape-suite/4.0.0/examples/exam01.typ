#import "/src/library.typ": colors, exercise
#import exercise: project, subtask, task
#import colors: *

#show: project.with(
    no: 1,
    suffix-title: [Foundations of Logic],

    show-namefield: true,
    show-timefield: true,

    max-time: 25,
    show-lines: true,

    show-solutions: true,
    show-solution-matrix: true,

    university: [Example University],
    institute: [Institute for Philosophy],
    seminar: [Tutorium: Philosophical Logic],
)

#task(
    lines: 10,
    points: 3,
    [Fundamentals],
    [
        Explain what logic is concerned with. Also, list the two criteria for evaluating the quality of arguments.
    ],
    [],
    solution-parts: (
        (1, [Definition of logic as the study of valid, formal reasoning.]),
        (2, [Identify the quality criteria of validity and soundness.]),
    ),
)

#task(
    lines: 20,
    [Criteria for good arguments],
    [
        Evaluate the following arguments in terms of the two quality criteria. Briefly explain your answers.
    ],
    [
        #subtask(points: 2)[
            When I walk on the moon, I can jump higher than on Earth. \
            I can't jump higher than on Earth.\
            #box(line(length: 5cm)) \
            I'm not on the moon.
        ]

        #subtask(points: 2)[
            Either all the cherries are green, or it's raining sunshine.\
            Not all the cherries are green.\
            #box(line(length: 5cm)) \
            So it's raining sunshine.
        ]

        #subtask(points: 2)[
            Everyone can eat meat.\
            #box(line(length: 5cm)) \
            Everyone should eat meat.
        ]

    ],
    (
        (
            2,
            [
                1. The argument was characterized as sound and valid, since the premises are true and the conclusion follows logically from the premises. If it was judged to be unsound, a justification must be provided.
            ],
        ),

        (
            2,
            [
                2. The argument was judged to be valid but not sound, since the premises are false even though the conclusion follows logically from them. Not all cherries are green, nor does it rain rays of sunshine; therefore, the first premise is false. Any different assessment must be supported by an appropriate justification.
            ],
        ),

        (
            2,
            [
                3. The argument is neither valid nor sound. Since the argument is not valid and cannot be regarded as valid, it cannot be sound either.
            ],
        ),
    ),
)

#task(
    lines: 10,
    [Logical validity],
    [
        For each argument, state a conclusion that logically follows from the premises!
    ],
    [
        #subtask(points: 1)[
            All birds can fly.\
            A penguin is a bird.\
            #box(line(length: 5cm)) \
            ...
        ]

        #subtask(points: 1)[
            Penguins live at the South Pole and polar bears at the North Pole.\
            #box(line(length: 5cm)) \
            ...
        ]

        #subtask(points: 1)[
            The street is wet.\
            #box(line(length: 5cm)) \
            ...
        ]
    ],
    (
        (
            1,
            [
                One of the following:
                - "All birds can fly."
                - "A penguin is a bird."
                - "A penguin can fly."
                - equivalent or tautologic statements
            ],
        ),

        (
            1,
            [
                One of the following:
                - "Penguins live at the South Pole and polar bears at the North Pole."
                - "Penguins live at the South Pole."
                - "Polar bears live at the North Pole."
                - equivalent or tautologic statements
            ],
        ),

        (
            1,
            [
                One of the following:
                - "The street is wet."
                - "It is not the case that the street is not wet."
                - equivalent or tautologic statements
            ],
        ),
    ),
)

#task(
    lines: 10,
    points: 4,
    extra: true,
    [Beweis],
    [
        Prove the validity of the following argument using indirect proof!
    ],
    [
        All doctors are brilliant. \
        All surgeons are doctors. \
        #box(line(length: 5cm)) \
        All surgeons are brilliant.
    ],
    (
        (1, [The conclusion was rejected.]),
        (1, [Further steps in the proof are clear.]),
        (1, [The contradiction was found.]),
        (1, [The proof was concluded with “QED”.]),
    ),
)
