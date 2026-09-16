#let (
    slides,
    slide,
    focus-slide,
    uncover,
    only,
    later,
    task,
    hint,
    solution,
    definition,
    notice,
    example,
    sentence,
    todo,
    list-todos,
    hide-todos,
    unbreak,
) = {
    import "@preview/polylux:0.4.0"

    import "german-dates.typ": semester, weekday
    import "colors.typ": *
    import "todo.typ": hide-todos, list-todos, todo, todo-state
    import "elements.typ": *

    let uncover = polylux.uncover
    let only = polylux.uncover
    let later = polylux.later
    let slide(..args) = {
        state("grape-suite-slides", ()).update(k => {
            k.push("normal")
            k
        })

        polylux.slide(..args)
    }

    let focus-slide(body) = context {
        let c = get-colors()
        set page(fill: c.primary)
        set text(fill: white)

        state("grape-suite-slides", ()).update(k => {
            k.push("focus")
            k
        })

        polylux.slide[
            #show: align.with(center + horizon)
            #text(size: 1.5em, weight: "bold")[
                #v(-0.75em)
                #body
            ]
        ]
    }

    let slides(
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
        outline-depth: 1,
        heading-numbering: none,

        fontsize: 24pt,
        text-font: (
            "Atkinson Hyperlegible Next",
            "Atkinson Hyperlegible",
            "Libertinus Serif",
        ),
        math-font: ("STIX Two Math", "New Computer Modern Math"),

        date: datetime.today(),
        date-format: date => if type(date)
            == type(
                datetime.today(),
            ) [#weekday(date.weekday()), #date.display("[day].[month].[year]")] else {
            date
        },

        colors-primary: purple,
        colors-accent: blue,
        colors-highlight: magenta,
        colors-warning: yellow,
        colors-warning-dark: brown,

        body,
    ) = {
        set-colors(
            primary: colors-primary,
            accent: colors-accent,
            highlight: colors-highlight,
            warning: colors-warning,
            warning-dark: colors-warning-dark,
        )
        let left-footer = if footer != none {
            footer
        } else {
            text(
                size: 0.5em,
                (
                    if show-semester [#semester(short: true, date)],
                    [#series] + if no != none [ \##no],
                    title,
                    if show-author { author },
                )
                    .filter(e => e != none)
                    .join[ --- ],
            )
        }

        show footnote.entry: set text(size: 0.5em)

        set text(size: fontsize, font: text-font)
        show math.equation: set text(font: math-font, size: fontsize)

        set page(paper: "presentation-16-9", footer: {
            let fs = state("grape-suite-slides", ())

            (
                context if show-footer
                    and (not show-title-slide or here().page() > 1) {
                    let c = get-colors()
                    set text(fill: if fs.at(here()).last() != none
                        and fs.at(here()).last() == "normal" {
                        c.primary-light
                    } else {
                        c.accent.lighten(25%)
                    })

                    left-footer

                    h(1fr)

                    if show-page-numbers {
                        page-numbering(
                            counter(page).at(here()),
                            counter(page).final(),
                        )
                    }
                }
            )
        })

        state("grape-suite-box-translations").update((
            "task": box-task-title,
            "hint": box-hint-title,
            "solution": box-solution-title,
            "definition": box-definition-title,
            "notice": box-notice-title,
            "example": box-example-title,
        ))

        state("grape-suite-element-sentence-supplement").update(
            sentence-supplement,
        )
        show: sentence-logic

        if show-title-slide {
            slide(align(horizon, [
                #block(inset: (left: 1cm, top: 3cm))[
                    #if head-replacement == none [
                        #context text(
                            fill: get-colors().primary,
                            size: 2em,
                            strong[#series ] + if no != none [\##no],
                        ) \
                    ] else { head-replacement }
                    //
                    #if title-replacement == none [
                        #context text(
                            fill: get-colors().primary-light,
                            strong(title),
                        )
                    ] else { title-replacement }

                    #set text(size: 0.75em)
                    #if show-author [#author #if email != none [--- #email ] \ ]
                    #if show-semester [#semester(date) \ ]
                    #if show-date { date-format(date) }
                ]
            ]))
        }

        if show-outline {
            context {
                let c = get-colors()
                set page(fill: c.primary, footer: context if show-footer {
                    set text(fill: if here().page() > 2 or not show-outline {
                        c.primary-light
                    } else {
                        c.accent.lighten(25%)
                    })

                    left-footer
                })

                slide[
                    #set text(fill: white)

                    #heading(outlined: false, text(
                        fill: c.accent.lighten(25%),
                        [#outline-title-text],
                    ))

                    #show outline.entry: it => link(
                        it.element.location(),
                        it.indented(it.prefix(), it.body()),
                    )

                    #outline(
                        depth: outline-depth,
                        title: none,
                    )
                ]
            }
        }

        set heading(numbering: if heading-numbering == none {
            (..nums) => {
                let number = numbering("1. a", ..nums)
                if not number.contains(".") { number + "." } else { number }
            }
        } else { heading-numbering })

        show heading: it => context {
            if heading-numbering == none { text(it.body) } else { it }
        }

        show heading: it => context {
            set text(get-colors().primary)

            if heading-numbering == none {
                block(sticky: true, text(it.body) + v(0.25em / it.level))
            } else {
                it
            }
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

    (
        slides,
        slide,
        focus-slide,
        uncover,
        only,
        later,
        task,
        hint,
        solution,
        definition,
        notice,
        example,
        sentence,
        todo,
        list-todos,
        hide-todos,
        unbreak,
    )
}
