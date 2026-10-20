// Table of contents and list pages

#import "translations.typ": t
#import "figures.typ": in-outline

/// Shared outline styling, applied as a show rule so every outline in the
/// document — including a user's own — matches.
///
/// - body (content): Document body (injected automatically by the show rule).
/// -> content
#let setup-outlines(body) = {
    set outline.entry(fill: repeat(".", gap: 0.4em, justify: false))
    show outline: set par(justify: false)
    show outline.entry: it => context {
        // Measured rather than fixed because Roman front-matter page numbers can
        // exceed a 3-digit Arabic one.
        let page-width = query(outline.entry).fold(0pt, (w, e) => calc.max(
            w,
            measure(e.page()).width,
        ))
        // Bold only the parts, never the leader: `strong` is an additive weight,
        // so bolding the whole entry would also thicken the dots. Passing `none`
        // through unwrapped keeps unnumbered chapters from getting an indent:
        // `strong(none)` is an empty prefix, not an absent one.
        let bold = if it.level == 1 and it.element.func() == heading {
            it => if it == none { none } else { strong(it) }
        } else {
            it => it
        }
        // Two columns keep the body from wrapping under the page number;
        // right-aligning the leader makes it end at the same x on every row.
        link(
            it.element.location(),
            grid(
                columns: (1fr, page-width),
                column-gutter: 0.5em,
                align: (top + left, bottom + right),
                it.indented(bold(it.prefix()), {
                    bold(it.body())
                    h(0.5em)
                    box(width: 1fr, align(right, it.fill))
                }),
                bold(it.page()),
            ),
        )
    }
    body
}

/// Print the table of contents.
///
/// - lang (str): Document language — `"de"` or `"en"`.
/// -> content
#let print-toc(lang: "de") = {
    set text(hyphenate: false)

    // Extra space above each top-level entry.
    show outline.entry.where(level: 1): set block(above: 1.6em)

    outline(
        title: t.at(lang).toc,
        depth: 3,
        indent: auto,
    )
}

/// Print a back-matter list page for one figure kind.
///
/// Handles the `in-outline` state that switches `flex-caption` to its short form,
/// which a hand-rolled `outline(target: …)` would miss.
///
/// - kind (function | str): Figure kind to list — an element function such as
///   `image`, or a string such as `"algorithm"`.
/// - title (content | str): Heading of the list page.
/// -> content
#let print-list-of(kind, title: none) = {
    set text(hyphenate: true)
    heading(level: 1, numbering: none, outlined: true, bookmarked: true)[#title]
    in-outline.update(true)
    outline(
        title: none,
        target: figure.where(kind: kind),
    )
    in-outline.update(false)
}

/// Print the list of figures.
///
/// - lang (str): Document language — `"de"` or `"en"`.
/// -> content
#let print-lof(lang: "de") = print-list-of(image, title: t.at(lang).lof)

/// Print the list of tables.
///
/// - lang (str): Document language — `"de"` or `"en"`.
/// -> content
#let print-lot(lang: "de") = print-list-of(table, title: t.at(lang).lot)

/// Print the list of listings.
///
/// - lang (str): Document language — `"de"` or `"en"`.
/// -> content
#let print-lol(lang: "de") = print-list-of(raw, title: t.at(lang).lol)
