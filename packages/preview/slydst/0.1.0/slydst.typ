#let default-color = blue.darken(40%)
#let header-default = default-color.lighten(75%)
#let body-default = default-color.lighten(85%)

#let slides(
    content,
    title: none,
    subtitle: none,
    date: none,
    authors: [],
    layout: "medium",
    title-color: none,
    cite-color: none,
    math-color: none,
) = {

    // Parsing
    let width = none
    let height = none
    let banner = none
    if layout == "small" {
        (width, height) = (12cm, 9cm)
        banner = 1.4cm
    }
    else if layout == "medium" {
        (width, height) = (14cm, 10.5cm)
        banner = 1.6cm
    }
    else if layout == "large" {
        (width, height) = (16cm, 12cm)
        banner = 1.8cm
    }
    else {
        panic("Unknown layout " + layout)
    }

    // Colors
    if title-color == none {
        title-color = default-color
    }
    if cite-color == none {
        cite-color = default-color
    }
    if math-color == none {
        math-color = default-color
    }

    // Setup
    set document(
        title: title,
        author: authors,
    )
    set page(
        width: width,
        height: height,
        margin: (x: 0.5 * banner, top: banner, bottom: 0.6 * banner),
        header: locate(loc => {
            let page = loc.page()
            let selection = heading.where(level: 2).or(heading.where(level: 1))
            let headings = query(selector(selection), loc)
            let heading = headings.rev().find(x => x.location().page() <= page)
            if heading != none and not heading.level == 1 {
                set text(1.4em, weight: "bold", fill: title-color)
                set align(top)
                v(banner / 2)
                block(heading.body +
                    if not heading.location().page() == loc.page() [
                        #{numbering("(i)", loc.page() - heading.location().page() + 1)}
                    ]
                )
            }
        }),
        header-ascent: 0%,
        footer: [
            #set text(0.8em)
            #set align(right)
            #counter(page).display("1/1", both: true)
        ],
        footer-descent: 0.8em,
    )
    set outline(
        target: heading.where(level: 1),
        title: none,
    )
    set bibliography(title: none)

    // Rules
    show heading.where(level: 1): set align(center + horizon)
    show heading.where(level: 1): set text(1.2em)
    show heading.where(level: 1): x => pagebreak(weak: true) + v(- banner / 2) + x
    show heading.where(level: 2): pagebreak(weak: true)
    show heading: set text(1.1em, fill: title-color)
    show cite: set text(fill: cite-color)
    show figure.caption: x => [*#x.supplement #x.counter.display():* #x.body]
    show math.equation: set text(fill: math-color)
    show ref: it => {
        set text(fill: cite-color)
        let el = it.element
        if el != none and el.func() == math.equation {
            numbering(el.numbering, ..counter(math.equation).at(el.location()))
        } else {
            it
        }
    }

    // Title
    if (title == none) {
        panic("A title is required")
    }
    else {
        set page(footer: none)
        set align(horizon)
        v(- banner / 2)
        block(
            text(2.0em, weight: "bold", fill: title-color, title) +
            v(1.4em, weak: true) +
            if subtitle != none { text(1.1em, weight: "bold", subtitle) } +
            if subtitle != none and date != none { text(1.1em)[ \- ] } +
            if date != none {text(1.1em, date)} +
            v(1em, weak: true) +
            align(left, authors.join(", ", last: " and "))
        )
    }

    // Content
    content
}

#let frame(content, counter: none, title: none) = {

    let header = none
    if counter == none and title != none {
        header = [*#title.*]
    }
    else if counter != none and title == none {
        header = [*#counter.*]
    }
    else {
        header = [*#counter:* #title.]
    }

    set block(width: 100%, inset: (x: 0.4em, top: 0.35em, bottom: 0.45em))
    show stack: set block(breakable: false)
    show stack: set block(breakable: false, above: 0.8em, below: 0.5em)

    stack(
        block(fill: header-default, radius: (top: 0.2em, bottom: 0cm), header),
        block(fill: body-default, radius: (top: 0cm, bottom: 0.2em), content),
    )
}

#let d = counter("definition")
#let definition(content, title: none) = {
    d.step()
    frame(counter: d.display(x => "Definition " + str(x)), title: title, content)
}

#let t = counter("theorem")
#let theorem(content, title: none) = {
    t.step()
    frame(counter: t.display(x => "Theorem " + str(x)), title: title, content)
}

#let l = counter("lemma")
#let lemma(content, title: none) = {
    l.step()
    frame(counter: l.display(x => "Lemma " + str(x)), title: title, content)
}

#let c = counter("corollary")
#let corollary(content, title: none) = {
    c.step()
    frame(counter: c.display(x => "Corollary " + str(x)), title: title, content)
}

#let a = counter("algorithm")
#let algorithm(content, title: none) = {
    a.step()
    frame(counter: a.display(x => "Algorithm "+ str(x)), title: title, content)
}
