#import "@preview/polylux:0.4.0"

#import "german-dates.typ": semester, weekday
#import "colors.typ": *
#import "todo.typ": todo, list-todos, todo-state, hide-todos
#import "elements.typ": *

#let uncover = polylux.uncover
#let only = polylux.uncover
#let later = polylux.later
#let slide(..args) = {
    state("grape-suite-slides", ()).update(k => {
        k.push("normal")
        k
    })

    polylux.slide(..args)
}

#let focus-slide(body) = {
    set page(fill: purple)
    set text(fill: white)

    state("grape-suite-slides", ()).update(k => {
        k.push("focus")
        k
    })

    polylux.polylux-slide[
        #set text(size: 1.5em, weight: "bold")
        #show: align.with(center + horizon)
        #v(-0.75em)
        #body
    ]
}

#let slides(
    no: 0,
    series: none,
    title: none,
    topics: (),

    head-replacement: none,
    title-replacement: none,
    footer: none,

    author: none,
    email: none,

    page-numbering: (n, total) => {
        text(size: 0.75em, strong[#n.first()])
        text(size: 0.5em, [ \/ #total.first()])
    },

    show-title-slide: true,
    show-author: true,
    show-semester: true,
    show-date: true,
    show-outline: true,
    show-todolist: true,
    show-footer: true,
    show-page-numbers: true,

    box-task-title: standard-box-translations.at("task"),
    box-hint-title: standard-box-translations.at("hint"),
    box-solution-title: standard-box-translations.at("solution"),
    box-definition-title: standard-box-translations.at("definition"),
    box-notice-title: standard-box-translations.at("notice"),
    box-example-title: standard-box-translations.at("example"),
    sentence-supplement: "Example",

    outline-title-text: "Outline",

    fontsize: 24pt,
    text-font: ("Atkinson Hyperlegible Next", "Atkinson Hyperlegible", "Libertinus Serif"),
    math-font: ("STIX Two Math", "New Computer Modern Math"),

    date: datetime.today(),
    date-format: (date) => [#weekday(date.weekday()), #date.display("[day].[month].[year]")],

    body
) = {
    let left-footer = if footer != none {
        footer
    } else {
        text(size: 0.5em, (
            if show-semester [#semester(short: true, date)],
            [#series \##no],
            title,
            if show-author { author }).filter(e => e != none).join[ --- ]
        )
    }

    show footnote.entry: set text(size: 0.5em)

    show heading: set text(fill: purple)

    set text(size: fontsize, font: text-font)
    show math.equation: set text(font: math-font, size: fontsize)

    set page(paper: "presentation-16-9",
        footer: {
            let fs = state("grape-suite-slides", ())

            (context if show-footer and (not show-title-slide or here().page() > 1) {
                set text(fill: if fs.at(here()).last() != none and fs.at(here()).last() == "normal" {
                    purple.lighten(25%)
                } else {
                    blue.lighten(25%)
                })

                left-footer

                h(1fr)

                if show-page-numbers {
                    page-numbering(counter(page).at(here()), counter(page).final())
                }
            })
        }
    )

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

    if show-title-slide {
        slide(align(horizon, [
            #block(inset: (left: 1cm, top: 3cm))[
                #if head-replacement == none [
                    #text(fill: purple, size: 2em, strong[#series ] + if no != none [\##no]) \
                ] else { head-replacement }
                //
                #if title-replacement == none [
                   #text(fill: purple.lighten(25%), strong(title))
                ] else { title-replacement }

                #set text(size: 0.75em)
                #if show-author [#author #if email != none [--- #email ] \ ]
                #if show-semester [#semester(date) \ ]
                #if show-date { date-format(date) }
            ]
        ]))
    }

    if show-outline {
        set page(fill: purple, footer: context if show-footer {
            set text(fill: if here().page() > 2 or not show-outline {
                purple.lighten(25%)
            } else {
                blue.lighten(25%)
            })

            left-footer
        })

        slide[
            #set text(fill: white)

            #heading(outlined: false, text(fill: blue.lighten(25%), [#outline-title-text]))

            #context {
                let elems = query(selector(heading).after(here()))

                enum(..elems
                    .filter(e => e.level == 1 and e.outlined)
                    .map(e => {
                        e.body
                    }))
            }
        ]
    }

    if show-todolist {
        context {
            if todo-state.final().len() > 0 {
                slide[
                    #list-todos()
                ]
            }
        }
    }

    counter(page).update(1)

    set page(fill: white)
    body
}