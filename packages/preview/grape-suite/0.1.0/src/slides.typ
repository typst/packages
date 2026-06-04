#import "@preview/polylux:0.3.1"

#import "dates.typ": semester, weekday
#import "colors.typ": *

#let unbreak(body) = {
    set text(hyphenate: false)
    body
}

#let important-box(title,
    body,
    extra,
    primary-color,
    secondary-color,
    tertiary-color,
    dotted: false) = {

    set par(justify: true)
    block(width: 100%,
        inset: 1em,
        fill: secondary-color,

        stroke: (left: (thickness: 5pt,
            paint: primary-color,
            dash: if dotted { "dotted" } else { "solid" })),


        text(size: 0.75em, strong(text(fill: tertiary-color, smallcaps(title))))
        // + place(dx: 90%, dy: -0.5cm, text(size: 4em, fill: primary-color.lighten(75%), strong(extra)))
        + block(body))
}

#let standard-box-translations = (
    "task": [Task],
    "hint": [Hint],
    "solution": [Suggested solution],
    "definition": [Definition],
    "notice": [Notice!],
    "example": [Example],
)

#let task(body) = {
    important-box(locate(loc => state("grape-suite-box-translations", standard-box-translations).final(loc).at("solution")),
        body,
        [A],
        blue,
        blue.lighten(90%),
        purple)
}

#let hint(body) = {
    important-box(locate(loc => state("grape-suite-box-translations", standard-box-translations).final(loc).at("hint")),
        body,
        [H],
        yellow,
        yellow.lighten(90%),
        brown)
}

#let solution(body) = {
    important-box(locate(loc => state("grape-suite-box-translations", standard-box-translations).final(loc).at("solution")),
        body,
        [L],
        blue,
        blue.lighten(90%),
        purple,
        dotted: true)
}

#let definition(body) = {
    important-box(locate(loc => state("grape-suite-box-translations", standard-box-translations).final(loc).at("definition")),
        body,
        [D],
        magenta,
        magenta.lighten(90%),
        magenta)
}

#let notice(body) = {
    important-box(locate(loc => state("grape-suite-box-translations", standard-box-translations).final(loc).at("notice")),
        body,
        [!],
        magenta,
        magenta.lighten(90%),
        magenta,
        dotted: true)
}

#let example(body) = {
    important-box(locate(loc => state("grape-suite-box-translations", standard-box-translations).final(loc).at("example")),
        body,
        [B],
        yellow,
        yellow.lighten(90%),
        brown,
        dotted: true)
}

#let uncover = polylux.uncover
#let only = polylux.uncover
#let pause = polylux.pause
#let slide(..args) = polylux.polylux-slide(..args) + counter("grape-suite-slide-counter").step()

#let slides(
    no: 0,
    series: none,
    title: none,
    topics: (),

    author: none,
    email: none,

    show-semester: true,
    show-outline: true,

    box-task-title: standard-box-translations.at("task"),
    box-hint-title: standard-box-translations.at("hint"),
    box-solution-title: standard-box-translations.at("solution"),
    box-definition-title: standard-box-translations.at("definition"),
    box-notice-title: standard-box-translations.at("notice"),
    box-example-title: standard-box-translations.at("example"),

    date: datetime.today(),
    body
) = {
    show footnote.entry: set text(size: 0.5em)

    show heading: set text(fill: purple)

    set text(size: 24pt, lang: "de", font: "Atkinson Hyperlegible")
    set page(paper: "presentation-16-9",
        footer: {
                (locate(loc => if (show-outline and loc.page() > 2) or loc.page() > 1 {
                    set text(fill: if loc.page() > 2 or not show-outline {
                        purple.lighten(25%)
                    } else {
                        blue.lighten(25%)
                    })

                    text(size: 0.5em,[
                        #if show-semester [#semester(short: true, date) ---]
                        #series #if no != none [\##no] #if title != none [---
                        #title] ---
                        #author
                    ])

                    h(1fr)

                    text(size: 0.75em,
                        strong(str(counter(page).at(loc).first() - if show-outline { 2 } else { 1 }))) + text(size: 0.5em, [ \/ #(counter(page).final(loc).first() - if show-outline { 2 } else { 1 })])
            }))
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

    slide(align(horizon, [
        #block(inset: (left: 1cm, top: 3cm))[
            #text(fill: purple, size: 2em, strong[#series ] + if no != none [\##no]) \
            #text(fill: purple.lighten(25%), strong(title))

            #set text(size: 0.75em)

            #author #if email != none [--- #email \ ]
            #if show-semester [#semester(date) \ ]
            #weekday(date.weekday()), #date.display("[day].[month].[year]")
        ]
    ]))

    if show-outline {
        set page(fill: purple)
        slide[
            #set text(fill: white)

            #heading(outlined: false, text(fill: blue.lighten(25%), [Ablauf]))

            #locate(loc => {
                let elems = query(selector(heading).after(loc), loc)

                enum(..elems
                    .filter(e => e.level == 1 and e.outlined)
                    .map(e => {
                        e.body
                    }))
            })
        ]
    }

    set page(fill: white)
    body
}