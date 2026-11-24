#let beago-article(
    title: [Title],
    subtitle: none,
    author: [Author],
    date: datetime.today().display("[month repr:long] [day], [year]"),
    abstract: none,
    font-size: 12pt,
    paper: "a4",
    heading-numbering: "1.1.",
    title-align: center,
    first-line-indent: none,
    line-spacing: 1em,
    body,
) = {
    set document(title: title)
    set text(size: font-size, hyphenate: true)

    set page(
        paper: paper,
        footer: context {
            set text(size: font-size * 0.85)
            [
                #h(1fr) #counter(page).display("1 / 1", both: true)
            ]
        },
    )

    set par(
        justify: true,
        leading: line-spacing,
        spacing: line-spacing,
    )

    set par(first-line-indent: first-line-indent) if first-line-indent != none
    set heading(numbering: heading-numbering) if heading-numbering != none

    show heading.where(level: 1): it => {
        set text(weight: "bold")
        it
    }

    show heading.where(level: 2): it => {
        set text(weight: "regular", style: "italic")
        it
    }

    block(
        width: if title-align == left { 85% } else { 100% },
        {
            set par(justify: if title-align == left {
                false
            } else if title-align == right { false } else { true })
            set align(title-align)
            text(size: font-size * 1.35, weight: "bold", title)
            if subtitle != none {
                linebreak()
                text(style: "italic", subtitle)
            }

            linebreak()

            if date != none {
                text(date)
            }
            if author != none and date != none {
                [, #text(author)]
            } else {
                text(author)
            }
        },
    )

    if abstract != none {
        block(
            width: 100%,
            inset: (x: 3em, y: 0.75em),
            [
                #set align(title-align)
                #set text(size: font-size * 0.95)
                #set par(
                    justify: true,
                    leading: 0.8em,
                    spacing: 0.8em,
                    first-line-indent: 0em,
                )
                #text(weight: "bold")[Abstract]
                #v(0.5em)
                #abstract
            ],
        )
    }

    body
}
