// Outline styling and the short-caption helper.
//
// `setup-outlines` teaches Typst's own `outline` what it is missing
// --- an outlined, bookmarked, localized heading on a list page ---
// so a document places its table of contents and its list pages with the built-in call.

#import "translations.typ": t
#import "figure-kinds.typ": resolve-figure-kinds

// Whether we're rendering inside an outline; lets captions switch to short form.
#let in-outline = state("in-outline", false)

// Typst's `auto` outline title is the *contents* title whatever the outline
// targets, so a list page has to be named. These are the kinds the template has a
// word for; any other kind belongs to the document's own vocabulary and titles its
// own list page.
#let _builtin-list-titles = (
    (image, "list-of-figures"),
    (table, "list-of-tables"),
    (raw, "list-of-listings"),
)

// The heading a list page gets in place of the title Typst would print itself.
#let _list-page-heading(kind, title) = context {
    let resolved = if title != auto { title } else {
        let named = _builtin-list-titles.find(entry => entry.at(0) == kind)
        if named == none {
            panic(
                "the list page for figure kind "
                    + repr(kind)
                    + " needs a title of its own --- the template only names the "
                    + "built-in image, table and raw",
            )
        }
        t.at(text.lang).at(named.at(1))
    }
    heading(level: 1, numbering: none, outlined: true, bookmarked: true)[#resolved]
}

/// Shared outline styling, applied as a show rule so every outline in the
/// document --- including a user's own --- matches.
///
/// -> content
#let setup-outlines(
    /// Figure kind declarations, merged onto the built-in ones. A list page is an
    /// outline over one of these; everything else is a table of contents.
    /// -> array
    figure-kinds: (),

    /// Document body, injected by the show rule.
    /// -> content
    body,
) = {
    // The template only claims authority over outlines whose target it can build
    // itself. Comparing against those selectors is what tells a list page from a
    // table of contents --- including one written as `outline(target: heading.where(..))`.
    let list-page-kinds = resolve-figure-kinds(figure-kinds).map(entry => entry.kind)

    set outline(depth: 3)
    // Set on `repeat` rather than only on the entry so a list page assembled by
    // hand gets the same leader.
    set repeat(gap: 0.4em, justify: false)
    set outline.entry(fill: repeat("."))
    show outline: set par(justify: false)

    // Give non-toc listings a custom, localized heading.
    show outline: it => {
        let kind = list-page-kinds.find(k => it.target == selector(figure.where(kind: k)))
        if it.title == none or kind == none {
            it
        } else {
            _list-page-heading(kind, it.title)
            outline(..it.fields(), title: none)
        }
    }

    show outline.entry: it => context {
        let is-heading-entry = it.element.func() == heading
        let is-chapter = is-heading-entry and it.level == 1
        set block(above: 1.6em) if is-chapter
        set text(hyphenate: true) if not is-heading-entry

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
        let bold = if is-chapter {
            it => if it == none { none } else { strong(it) }
        } else {
            it => it
        }
        // Bracket the entry so @flex-caption renders its short form here.
        in-outline.update(true)
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
        in-outline.update(false)
    }
    body
}

/// Two-part caption: a short version for the list pages, a long one under the
/// figure. Every outline switches it to the short form, including one you write
/// yourself.
///
/// ```typc
/// figure(image("plot.svg"), caption: flex-caption(short: [Short], long: [Long.]))
/// ```
///
/// -> content
#let flex-caption(
    /// Caption shown on the list page.
    /// -> content
    short: none,

    /// Caption shown below the figure in the document body.
    /// -> content
    long: none,
) = context if in-outline.get() {
    short
} else {
    long
}
