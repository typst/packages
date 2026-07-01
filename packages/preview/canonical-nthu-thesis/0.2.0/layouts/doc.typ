// Show rules and set rules applied throughout the whole thesis document.

#let doc-impl(
    info: (:),
    style: (:),
    show-draft-mark: true,
    it
) = {
    set document(
        title: info.title-en + " " + info.title-zh,
        author: info.author-en + " " + info.author-zh,
        keywords: info.keywords-en + info.keywords-zh,
    )

    set text(
        size: 12pt,
        font: style.fonts,
        hyphenate: true,
    )

    show math.equation: set text(font: style.math-fonts)

    set par(
        justify: true,
    )

    set page(
        background: {
            image("../nthu-logo.svg", width: 1.95in, height: 1.95in)
            if show-draft-mark {
                set text(size: 18pt, fill: gray, weight: "regular")
                place(
                    top + right,
                    dx: -1em,
                    dy: 1em,
                    rotate(
                        -90deg,
                        reflow: true,
                        [Draft version #datetime.today().display()]
                    )
                )
            }
        },
    )

    show ref: it => {
        let el = it.element
        if el != none and el.func() == heading and el.level == 1 {
            [Chapter #numbering(el.numbering, ..counter(heading).at(el.location()))]
        } else {
            it
        }
    }

    it
}
