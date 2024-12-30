#import "../utils/cover-with-rect.typ": cover-with-white-rect

#let preface-impl(
    margin: (:),
    it,
) = {
    set page(
        margin: margin,
        background: cover-with-white-rect(image("../nthu-logo.svg", width: 1.95in, height: 1.95in)),
        numbering: "i",
    )

    set text(
        size: 12pt,
        font: ("New Computer Modern", "TW-MOE-Std-Kai"),
        hyphenate: true,
    )

    set par(
        leading: 1.5em,
        first-line-indent: 2em,
    )

    // Disable heading numbering.
    set heading(numbering: none)

    show heading.where(
        level: 1,
    ): it => {
        // Show the body of the heading with some vertical spacing surrounding.
        // Headings in the preface are not numbered.
        block(width: 100%, {
            set text(size: 24pt)
            v(3em)
            it.body
            v(2em)
        })
    }

    // Show level-1 outline entries in bold text and without the dots.
    show outline.entry.where(
        level: 1,
    ): it => {
        strong(it.body)
        h(1fr)
        // strong(repr(it))
        strong(it.page)
    }

    // Reset the page counter to start the abstract at page i.
    counter(page).update(1)

    it
}
