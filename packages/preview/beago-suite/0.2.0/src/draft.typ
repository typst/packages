#let beago-draft(
    title: [Title],
    author: [Author],
    date: datetime.today().display("[month repr:long] [day], [year]"),
    font-size: 12pt,
    paper: "a4",
    watermark: true,
    title-align: left,
    body,
) = {
    set document(title: title)
    set text(size: font-size)

    set page(
        paper: paper,
        footer: context {
            set text(size: font-size * 0.85)
            [
                #h(1fr) #counter(page).display("1 / 1", both: true)
            ]
        },
    )

    set page(
        background: rotate(-45deg, text(
            size: font-size * 4,
            tracking: font-size * 0.08,
            fill: luma(230),
        )[*DRAFT*]),
    ) if watermark

    block(
        width: if title-align == left { 85% } else { 100% },
        {
            set align(title-align)
            text(size: font-size * 1.35, weight: "bold", title)
            linebreak()
            text(date)
            linebreak()
            text(author)
        },
    )

    v(1em)

    body
}
