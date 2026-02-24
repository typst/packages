#import "colors.typ" as colors: *
#import "elements.typ": big-heading
#import "tasks.typ": *
#import "todo.typ": todo, list-todos, todo-state, hide-todos

#let standard-box-translations = (
    "task": [Task],
    "hint": [Hint],
    "solution": [Suggested solution],
    "definition": [Definition],
    "notice": [Notice!],
    "example": [Example],
)

#let otype = type // should not have called the argument "type"...
#let project(
    no: none,

    // category of the document, eg. "Exam", "Handout", "Series"
    type: [Exam],

    // title of the document; if not set, type and suffix-title generate the title of the document
    title: none,

    // if title is not set, it is used to generate the title of the document
    suffix-title: none,

    // disable/enable outline
    show-outline: false,

    // abstract
    abstract: none,

    // used in header; if none, then is set to title
    document-title: none,

    show-hints: false,
    show-solutions: false,

    // show name and time in header of first page
    show-namefield: false,
    namefield: [Name:],
    show-timefield: false,
    timefield: (time) => [Time: #time min.],

    // if show-timefield is true, then the timefield(max-time) is generated in the header
    max-time: 0,

    // if task has a defined amount of lines, draw the amount of lines below the task
    show-lines: false,

    // show point distributions after tasks/at the end of the solutions
    show-point-distribution-in-tasks: false,
    show-point-distribution-in-solutions: false,

    // show solution matrix; expected solution argument of the tasks is now a list of 2-tuples, where the first element is always a number of points and the second element is the description of what these points are awarded for
    solutions-as-matrix: false,

    // show comment field in solution matrix
    show-solution-matrix-comment-field: false,
    solution-matrix-comment-field-value: [*Note:* #v(0.5cm)],

    university: none,
    faculty: none,
    institute: none,
    seminar: none,
    semester: none,
    docent: none,
    author: none,
    date: datetime.today(),

    date-format: (date) => if type(date) == type(datetime.today()) { date.display("[day].[month].[year]") } else { date },

    // if set, above attributes featuring automatic generation of the header are ignored
    header: none,
    header-gutter: 20%,
    header-right: none,
    header-middle: none,
    header-left: none,
    show-header-line: true,

    footer: none,
    footer-right: none,
    footer-middle: none,
    footer-left: none,
    show-footer-line: true,

    // translations
    task-type: [Task],
    extra-task-type: [Extra task],

    box-task-title: standard-box-translations.at("task"),
    box-hint-title: standard-box-translations.at("hint"),
    box-solution-title: standard-box-translations.at("solution"),
    box-definition-title: standard-box-translations.at("definition"),
    box-notice-title: standard-box-translations.at("notice"),
    box-example-title: standard-box-translations.at("example"),
    sentence-supplement: "Example",

    hint-type: [Hint],
    hints-title: [Hints],

    solution-type: [Suggested solution],
    solutions-title: [Suggested solutions],

    solution-matrix-task-header: [Tasks],
    solution-matrix-achieved-points-header: [Points achieved],

    distribution-header-point-value: [Point],
    distribution-header-point-grade: [Grade],

    message: (points-sum, extrapoints-sum) => [In sum #points-sum + #extrapoints-sum P. are achievable. You achieved #box(line(stroke: purple, length: 1cm)) out of #points-sum points.],
    grade-scale: (
        ([excellent], 0.9),
        ([very good], 0.8),
        ([good], 0.7),
        ([pass], 0.6),
        ([fail], 0.49)),

    page-margins: none,

    text-font: ("Atkinson Hyperlegible Next", "Atkinson Hyperlegible", "Libertinus Serif"),
    math-font: ("STIX Two Math", "New Computer Modern Math"),

    fontsize: 11pt,

    show-todolist: true,

    body
) = {
    let ifnn-line(e) = if e != none [#e \ ]

    if title == none {
        title = if type != none or no != none [ #type #no ] + if (type != none or no != none) and suffix-title != none [ --- ] + if suffix-title != none [#suffix-title]
    }

    if document-title == none {
        document-title = title
    }

    set text(font: text-font, size: fontsize)
    show math.equation: set text(font: math-font, size: fontsize)

    set par(justify: true)

    set enum(indent: 1em)
    set list(indent: 1em)

    show link: underline
    show link: set text(fill: purple)

    show heading: set text(fill: purple)
    show heading: set par(justify: false)
    show: format-heading-numbering

    show: format-quotes

    let ufi = ()
    if university != none { ufi.push(university) }
    if faculty != none { ufi.push(faculty) }
    if institute != none { ufi.push(institute) }

    set page(
        margin: if page-margins != none {page-margins} else {
            (top: if ufi.len() <= 2 or not show-namefield {
                3.5cm
            } else {
                4cm
            }, bottom: 3cm)
        },

        background: context {
            let point-list = query(metadata).filter(e => if "type" in e.value { e.value.type == "grape-suite-subtask-points" })

            if otype(point-list) == array and point-list.len() > 0 {
                for p in point-list {
                    if p.location().page() == here().page() {
                        place(dx: 89.5%, dy: p.location().position().y, p.value.content)
                    }
                }
            }
        },

        header: if header != none {header} else [
            #set text(size: 0.75em)

            #let h-r = if header-left != none {header-left} else [
                #let ufi = ufi.filter(e => e not in ("", none, []))
                #if ufi.len() == 2 {
                    ufi.join(", ")
                    [\ ]
                } else if ufi.len() > 0 {
                    ufi.join([\ ])
                    [\ ]
                }
                #ifnn-line(seminar)
                #ifnn-line(semester)
                #ifnn-line(docent)
                #context {
                    if state("grape-suite-namefields").at(here()) != 1 {
                        if show-namefield {
                            namefield
                        }

                        state("grape-suite-namefields").update(1)
                    }
                }
            ]

            #let h-m = align(center, if header-middle != none {header-middle} else [])

            #let h-l = if header-right != none {header-right} else [
                #show: align.with(top + right)
                #ifnn-line(document-title)
                #ifnn-line(author)
                #ifnn-line(date-format(date))
                #context {
                    if state("grape-suite-timefield").at(here()) != 1 {
                        if show-timefield {
                            timefield(max-time)
                        }

                        state("grape-suite-timefield").update(1)
                    }
                }
            ]

            #set text(hyphenate: false)
            #set par(justify: false)

            #if header-middle != none {
                grid(columns: (auto, 1fr, auto),
                    align: top,
                    column-gutter: header-gutter,
                    inset: 0pt,

                    h-r,
                    h-m,
                    h-l
                )
            } else {
                grid(columns: (40%, 1fr, 40%),
                    align: top,
                    inset: 0pt,

                    h-r,
                    none,
                    h-l
                )
            }
        ] + if show-header-line {
            v(-0.5em) + line(length: 100%, stroke: purple)
        },

        footer: if show-footer-line {
            line(length: 100%, stroke: purple) + v(-0.5em)
        } + if footer != none {footer} else {
            set text(size: 0.75em)

            table(columns: (1fr, auto, 1fr),
                align: top,
                stroke: none,
                inset: 0pt,

                if footer-left != none {footer-left},

                align(center, context {
                    str(counter(page).display())
                    [ \/ ]
                    str(counter(page).final().first())
                }),

                if footer-right != none {footer-right}
            )
        },
    )

    state("grape-suite-task-translations").update((
        "task-type": task-type,
        "extra-task-type": extra-task-type
    ))

    state("grape-suite-box-translations").update((
        "task": box-task-title,
        "hint": box-hint-title,
        "solution": box-solution-title,
        "definition": box-definition-title,
        "notice": box-notice-title,
        "example": box-example-title,
    ))

    state("grape-suite-element-sentence-supplement").update(sentence-supplement)
    show: sentence-logic

    if title != none {
        big-heading(title)
    }

    if abstract != none {
        set text(size: 0.85em)
        pad(x: 1cm, abstract)
    }

    if show-outline {
        set par(spacing: 0em)
        show outline.entry: it => h(1em) + it
        set text(size: 0.75em)
        pad(x: 1cm, top: if abstract != none {0.25cm} else {0cm}, outline(indent: 1.5em))
    }

    if show-todolist {
        set text(size: 0.75em)
        context {
            if todo-state.final().len() > 0 {
                pad(x: 1cm, top: if abstract != none or show-outline != none {0.25cm} else {0cm}, list-todos())
            }
        }
    }

    set heading(numbering: "1.")

    state("grape-suite-tasks").update(())
    state("grape-suite-show-lines").update(show-lines)

    body

    if show-point-distribution-in-tasks {
        context make-point-distribution(here(), message, grade-scale, distribution-header-point-value, distribution-header-point-grade)
    }

    context {
        let tasks = state("grape-suite-tasks", ()).at(here())

        if show-hints and tasks.filter(e => e.hint != none).len() != 0 {
            pagebreak()
            big-heading[#hints-title #if type != none or no != none [ -- ] #type #no]
            make-hints(here(), hint-type)
        }
    }

    show: it => if show-solutions and solutions-as-matrix {
        set page(flipped: true, columns: 2, margin: (x: 1cm, top: 3cm, bottom: 2cm))
        it
    } else if show-solutions {
        pagebreak()
        it
    }

    if show-solutions {
        context {
            let tasks = state("grape-suite-tasks", ()).at(here())

            if tasks.filter(e => e.solution != none).len() != 0 {
                big-heading[#solutions-title #if type != none or no != none [ -- ] #type #no]

                if solutions-as-matrix {
                    set text(size: 0.75em)
                    make-solution-matrix(
                        show-comment-field: show-solution-matrix-comment-field,
                        comment-field-value: solution-matrix-comment-field-value,
                        here(),
                        solution-matrix-task-header,
                        task-type,
                        extra-task-type,
                        solution-matrix-achieved-points-header)

                    if show-point-distribution-in-solutions {
                        make-point-distribution(loc)
                    }

                } else {
                    make-solutions(here(), solution-type)
                }
            }
        }
    }
}
