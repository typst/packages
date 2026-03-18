// Some inspiration for this template came from <https://github.com/talal/ilm>
#let link-color = rgb("#3282B8")
#let muted-color = luma(160)
#let block-bg-color = luma(240)

#let text-muted(it) = {text(fill: muted-color, it)}

// Report template
#let kunskap(
    // Metadata
    title: [Title],
    author: "Anonymous",
    header: "",
    date: datetime.today().display("[month repr:long] [day padding:zero], [year repr:full]"),

    // Paper size
    paper-size: "a4",

    // Fonts
    body-font: ("Noto Serif"),
    body-font-size: 10pt,
    raw-font: ("Hack Nerd Font", "Hack", "Source Code Pro"),
    raw-font-size: 9pt,
    headings-font: ("Source Sans Pro", "Source Sans 3"),

    // Colors
    link-color: link-color,
    muted-color: muted-color,
    block-bg-color: block-bg-color,

    // The main document body
    body
) = {
    // Configure page size
    set page(
        paper: paper-size,
        margin: (top: 2.625cm),
    )

    // Set the document's metadata
    set document(title: title, author: author)

    // Set the fonts
    set text(font: body-font, size: body-font-size)
    show raw: set text(font: raw-font, size: raw-font-size)

    show heading: it => {
        // Add vertical space before headings
        if it.level == 1 {
            v(6%, weak: true)
        } else {
            v(4%, weak: true)
        }

        // Set headings font
        set text(font: headings-font, weight: "medium")
        it

        // Add vertical space after headings
        v(3%, weak: true)
    }

    show heading.where(level: 3): it => text(
        font: headings-font,
        //size: body-font-size,
        weight: "medium",
        it.body + h(1em),
    )

    // Set paragraph properties
    set par(leading: 0.95em, spacing: 1.7em, justify: true)

    // Set list styling
    set enum(indent: 1.5em, numbering: "1.a.i.")
    set list(indent: 1.5em)
    set terms(indent: 1.5em, hanging-indent: 1.33em)
    // Redefine term list item in order to redefine the term font
    show terms.item: it => par(
        hanging-indent: terms.indent + terms.hanging-indent,
        {
            h(terms.indent)
            text(font: headings-font, weight: "medium", it.term)
            h(1.1em)
            it.description
        }
    )

    // Display block code with padding and shaded background
    show raw.where(block: true): block.with(
        inset: (x: 1.5em, y: 5pt),
        outset: (x: -1em),
        width: 100%,
        fill: block-bg-color,
    )
    show raw.where(block: true): set par(justify: false)

    // Display inline code with shaded background while retaining the correct baseline
    show raw.where(block: false): box.with(
        inset: (x: 3pt, y: 0pt),
        outset: (y: 3pt),
        fill: block-bg-color,
    )

    // Set block quote styling
    show quote.where(block: true): set pad(x: 1.5em)

    // Set link styling
    show link: it => {
        set text(fill: link-color)
        it
    }

    // TYPESETTING THE DOCUMENT
    // -----------------------------------------------------------------------
    // Set page header and footer (numbering)
    set page(
        header: context {
            if counter(page).get().first() > 1 [
                #set text(font: headings-font, weight: "medium", fill: muted-color)
                #header
                #h(1fr)
                #title
            ] else [
                #set text(font: headings-font, weight: "medium")
                #header
            ]
        },
        numbering: (..nums) => {
            set text(font: headings-font, weight: "medium", fill: muted-color)
            nums.pos().first()
        },
    )

    // Set title block
    {
        v(26pt)
        text(font: headings-font, weight: "medium", size: 22pt, title)
        linebreak()
        v(16pt)
        if type(author) == array {
            text(font: body-font, style: "italic", author.join(", "))
        } else {
            text(font: body-font, style: "italic", author)
        }
        if date != none {
            v(2pt)
            text(font: body-font, date)
        }
        v(5em)
    }

    // Main body
    {body}
}
