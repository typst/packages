#import "colors.typ": *

#let big-heading(title) = {
    set par(justify: false)
    set text(hyphenate: false)

    pad(bottom: 0.25cm,
        align(center,
            text(fill: purple,
                size: 1.75em,
                strong(title))))
}

#let unbreak(body) = {
    set text(hyphenate: false)
    body
}

#let important-box(body,
    title: none,
    time: none,
    primary-color: magenta,
    secondary-color: magenta.lighten(90%),
    tertiary-color: magenta,
    dotted: false,
    figured: false,
    counter: none,
    show-numbering: false,
    numbering-format: (..n) => numbering("1.1", ..n),
    figure-supplement: none,
    figure-kind: none) = {

    if figured {
        if figure-supplement == none {
            figure-supplement = title
        }

        if figure-kind == none {
            panic("once paramter 'figured' is true, parameter 'figure-kind' must be set!")
        }
    }


    let body = {
        if show-numbering or figured {
            if counter == none {
                panic("parameter 'counter' must be set!")
            }

            counter.step()
        }

        set par(justify: true)
        show: align.with(left)

        block(width: 100%,
            inset: 1em,
            fill: secondary-color,

            stroke: (left: (thickness: 5pt,
                paint: primary-color,
                dash: if dotted { "dotted" } else { "solid" })),


            text(size: 0.75em, strong(text(fill: tertiary-color, smallcaps(title) + if show-numbering or figured {
                [ ] + context numbering(numbering-format, ..counter.at(here()))
            } + h(1fr) + time))) + block(body))
    }

    if figured {
        figure(kind: figure-kind, supplement: figure-supplement, align(left, body))
    } else {
        body
    }
}

#let standard-box-translations = (
    "task": [Task],
    "hint": [Hint],
    "solution": [Suggested solution],
    "definition": [Definition],
    "notice": [Notice!],
    "example": [Example],
)

#let task = important-box.with(
    title: context state("grape-suite-box-translations", standard-box-translations).final().at("task"),
    primary-color: blue,
    secondary-color: blue.lighten(90%),
    tertiary-color: purple,
    figure-kind: "task",
    counter: counter("grape-suite-element-task"))

#let hint = important-box.with(
    title: context state("grape-suite-box-translations", standard-box-translations).final().at("hint"),
    primary-color: yellow,
    secondary-color: yellow.lighten(90%),
    tertiary-color: brown,
    figure-kind: "hint",
    counter: counter("grape-suite-element-hint"))

#let solution = important-box.with(
    title: context state("grape-suite-box-translations", standard-box-translations).final().at("solution"),
    primary-color: blue,
    secondary-color: blue.lighten(90%),
    tertiary-color: purple,
    dotted: true,
    figure-kind: "solution",
    counter: counter("grape-suite-element-solution"))

#let definition = important-box.with(
    title: context state("grape-suite-box-translations", standard-box-translations).final().at("definition"),
    primary-color: magenta,
    secondary-color: magenta.lighten(90%),
    tertiary-color: magenta,
    figure-kind: "definition",
    counter: counter("grape-suite-element-definition"))

#let notice = important-box.with(
    title: context state("grape-suite-box-translations", standard-box-translations).final().at("notice"),
    primary-color: magenta,
    secondary-color: magenta.lighten(90%),
    tertiary-color: magenta,
    dotted: true,
    figure-kind: "notice",
    counter: counter("grape-suite-element-notice"))

#let example = important-box.with(
    title: context state("grape-suite-box-translations", standard-box-translations).final().at("example"),
    primary-color: yellow,
    secondary-color: yellow.lighten(90%),
    tertiary-color: brown,
    dotted: true,
    figure-kind: "example",
    counter: counter("grape-suite-element-example"))

#let sentence-logic(body) = {
    show figure.where(kind: "example"): it => {
        show: pad.with(0.25em)

        grid(columns: (1cm, 1fr),
            column-gutter: 0.5em,
            context [(#(counter("grape-suite-sentence-counter").at(here()).first()+1))],
            it.body)
    }

    body
}

#let sentence(body) = {
    figure(kind: "example", supplement: context state("grape-suite-element-sentence-supplement", "Example").final(), align(left, body) +
    counter("grape-suite-sentence-counter").step())
}

#let format-heading-numbering(body) = {
    show heading: it => context {
        let num-style = it.numbering

        if num-style == none {
            return it
        }

        let num = text(weight: "thin", numbering(num-style, ..counter(heading).at(here()))+[ \u{200b}])
        let x-offset = -1 * measure(num).width

        pad(left: x-offset, par(hanging-indent: -1 * x-offset, text(fill: purple.lighten(25%), num) + [] + text(fill: purple, it.body)))
    }

    body
}

#let format-quotes(body) = {
    set quote(block: true)

    show quote.where(block: true): set par(spacing: 0.65em)
    show quote.where(block: true): set block(above: 0.65em, below: 0.65em)

    show quote.where(block: true): it => {
        block[
            #set text(size: 0.9em)
            #set par(leading: 0.65em)
            #it.body\
        ]

        block(text(size: 0.75em, (it.attribution)))
    }

    show quote.where(block: true): pad.with(left: 1.5em, y: 0.65em, rest: 0em)

    show quote.where(block: false): it => {
        ["] + h(0pt, weak: true) + it.body + h(0pt, weak: true) + ["]
        if it.attribution != none [#footnote(it.attribution)]
    }

    body
}

#let blockquote(body, source) = quote(body, attribution: source)