#import "./show.typ": activate-show-rules, show-fn-rule, show-set-rule

#let _font-info-state = state("7e79ee62c4164f44af4c01f139a93236", none)
#let font-info() = {
    let x = _font-info-state.get()
    assert.ne(x, none, message: "Must call `#show: fonts` first.")
    x
}
#let _font-scale(font, scaling) = scaling.at(if type(font) == array { font.first() } else { font })
#let _as-font(font-type, body) = context {
    let fi = font-info()
    let font = fi.at(font-type)
    let size = 1em * (_font-scale(font, fi.scaling) / _font-scale(text.font, fi.scaling))
    text(font: font, size: size, body)
}
#let as-normal(body) = _as-font("normal-font", body)
#let as-math(body) = _as-font("math-font", body)  // Not useful, $..$ exists.
#let as-code(body) = _as-font("code-font", body)  // Not useful, `..` exists.
#let as-bio(body) = _as-font("bio-font", body)

/// Sets fonts and sizes across the document.
///
/// By default this just recapitulates Typst defaults. However my own favourite choices for academic writing are:
/// ```typst
/// #show: fonts.with(
///     title-font: "New Computer Modern",
///     heading-font: "New Computer Modern",
///     normal-font: "New Computer Modern",
///     title-size: 20pt,
///     heading-sizes: (13pt, 12pt, 11pt, 10pt),
///     text-size: 10pt,
///     fallback-fonts: false,
/// )
/// ```
/// Each font argument may also be an array of fallback fonts, such as
/// `normal-font: ("Libertinus Serif", "New Computer Modern")`. All fonts in
/// an array must have the same value in `scaling`.
#let fonts(
    title-font: "Libertinus Serif",
    heading-font: "Libertinus Serif",
    normal-font: "Libertinus Serif",
    math-font: "New Computer Modern Math",
    code-font: "DejaVu Sans Mono",
    bio-font: "DejaVu Sans Mono",
    scaling: (
        "Libertinus Serif": 100%,
        "New Computer Modern": 100%,
        "New Computer Modern Math": 100%,
        "DejaVu Sans Mono": 80%,
    ),
    title-size: 18.7pt, // 1.7em * 11pt
    heading-sizes: (15.4pt, 13.2pt, 11pt), // 1.4em * 11pt, 1.2em * 11pt, 1em * 11pt
    text-size: 11pt,
    fallback-fonts: true,
    fallback-smallcaps: false,
    doc,
) = {
    // Normalize to arrays of lower-case names, which is how `context text.font` is stored.
    let normalize-fonts(font) = {
        let fonts = if type(font) == array { font } else { (font,) }
        fonts.map(lower)
    }
    title-font = normalize-fonts(title-font)
    heading-font = normalize-fonts(heading-font)
    normal-font = normalize-fonts(normal-font)
    math-font = normalize-fonts(math-font)
    code-font = normalize-fonts(code-font)
    bio-font = normalize-fonts(bio-font)
    let scaling2 = (:)
    for (k, v) in scaling.pairs() {
        scaling2.insert(lower(k), v)
    }
    scaling = scaling2
    let font-scale(name, fonts) = {
        assert(fonts.len() > 0, message: "`" + name + "` must contain at least one font.")
        let scale = scaling.at(fonts.first())
        for font in fonts.slice(1) {
            assert.eq(
                scaling.at(font),
                scale,
                message: "All fonts in `" + name + "` must have the same value in `scaling`.",
            )
        }
        scale
    }
    let title-scale = font-scale("title-font", title-font)
    let heading-scale = font-scale("heading-font", heading-font)
    let normal-scale = font-scale("normal-font", normal-font)
    let math-scale = font-scale("math-font", math-font)
    let code-scale = font-scale("code-font", code-font)
    let _ = font-scale("bio-font", bio-font)
    let font-info-to-set = (
        title-font: title-font,
        heading-font: heading-font,
        normal-font: normal-font,
        math-font: math-font,
        code-font: code-font,
        bio-font: bio-font,
        title-size: title-size,
        heading-sizes: heading-sizes,
        text-size: text-size,
        scaling: scaling,
    )
    // Poor man's set-rule.
    context {
        assert.eq(_font-info-state.get(), none, message: "Cannot call `fonts` twice.")
        _font-info-state.update(font-info-to-set)
    }

    set text(font: normal-font, size: text-size * normal-scale, fallback: fallback-fonts)

    show title: set text(font: title-font, size: title-size * title-scale, hyphenate: false)
    show heading: set text(font: heading-font, size: heading-sizes.last() * heading-scale)
    show math.equation: set text(font: math-font, size: 1em * math-scale)
    // 1.25em default because the default `raw` size is `0.8em`, see https://github.com/typst/typst/issues/1331
    show raw: set text(font: code-font, size: 1.25em * code-scale)
    show title: set par(justify: false)
    let dynamic-rules = ()
    for (level, size) in heading-sizes.slice(0, -1).enumerate(start: 1) {
        dynamic-rules.push(show-set-rule(heading.where(level: level), text, size: size * heading-scale))
    }
    if fallback-smallcaps {
        dynamic-rules.push(show-fn-rule(smallcaps, it => text(size: 0.8em, upper(it))))
    }
    show: activate-show-rules.with(dynamic-rules)

    doc
}

// Sets the page composition – the spacing of all the text.
//
/// By default this just recapitulates Typst defaults. However my own favourite choices for academic writing are:
/// ```typst
/// #show: composition.with(
///     justify: true,
///     par-spacing: 1.3em,
///     margin: (top: 40pt, x: 40pt, bottom: 60pt),
///     heading-spacings: (
///         (above: 24pt, below: 8pt),
///         (above: 16pt, below: 8pt),
///         (above: 10pt, below: 8pt),
///     )
/// )
/// ```
#let composition(
    justify: false,
    par-spacing: 1.2em,
    margin: 2.5cm,
    // Defaults taken from
    // https://github.com/typst/typst/blob/6b9b78596a6103dfbcadafaeb03eda624da5306a/crates/typst-library/src/model/heading.rs#L313-L314
    heading-spacings: (
        (above: 1.8em / 1.4, below: 0.75em / 1.4),
        (above: 1.44em / 1.2, below: 0.75em / 1.2),
        (above: 1.44em, below: 0.75em),
    ),
    doc,
) = {
    set par(justify: justify, spacing: par-spacing)
    set page(margin: margin)

    let last-heading-spacing = heading-spacings.at(-1)
    show heading: set block(above: last-heading-spacing.above, below: last-heading-spacing.below)
    let dynamic-rules = ()
    for (level, heading-spacing) in heading-spacings.slice(0, -1).enumerate(start: 1) {
        dynamic-rules.push(show-set-rule(heading.where(level: level), block, above: heading-spacing.above, below: heading-spacing.below))
    }
    show: activate-show-rules.with(dynamic-rules)
    doc
}

/// Sets the numberings for various elements in the document.
///
/// By default this just recapitulates Typst defaults. However my own favourite choices for academic writing are:
/// ```typst
/// #show: numberings.with(page: "1", heading: "1.1")
/// ```
#let numberings(
    page: none,
    heading: none,
    footnote: "1",
    doc,
) = {
    set std.page(numbering: page)
    set std.heading(numbering: heading)
    set std.footnote(numbering: footnote)
    doc
}

#let _title = title
/// A simple style for the top matter.
///
/// *Example:*
///
/// ```typst
/// #show: topmatter.with(
///   title: [How to foobar],
///   authors: (
///     (
///       name: "Tom Smith",
///       affiliation: "ShallowMind",
///       email: "foo@bar.com",
///     ),
///   ),
///   abstract: [We show to really baz things up.],
/// )
/// ```
///
/// *Arguments:*
///
/// Arguments are list in the order they render from top-to-bottom down the page.
///
/// - header (content): header of the first page.
/// - topline (bool): whether to place a line after the header.
/// - title (content): the title.
/// - logo-left (none, content): placed to the left of the title.
/// - logo-right (none, content): placed to the right of the title.
/// - authors (array): an array of dictionaries `(name: str, affiliation: str, email: str)`.
/// - authors-maxcols: the number of columns to organize the authors into.
/// - abstract (content): the abstract.
/// - bottomline (bool): placed after the abstract.
#let topmatter(
    header: [],
    topline: true,
    title: [],
    logo-left: none,
    logo-right: none,
    authors: (),
    author-maxcols: 3,
    abstract: [],
    bottomline: true,
    doc,
) = {
    // Metadata
    set document(title: title)

    // Header
    set page(
        header: context {
            if counter(page).get().at(0) == 1 {
                set text(size: 0.85em)
                header
                v(-5pt)
                if topline { line(length: 100%) }
            }
        },
        header-ascent: 0%,
    )
    // Title
    /* This alignment is set up so that we get the following behaviour:

    With a short title, it is centered relative to the larger logo:

                              ╔═╗
    Short title on one line.  ║ ║
                              ╚═╝

    With a long title, the logo remains at the top of the page:

    Long title that covers    ╔═╗
    multiple lines: lorem     ║ ║
    ipsum dolor sit amet      ╚═╝
    consectetur adipiscing
    elit sed do eiusmod
    */
    v(20pt)
    let title-columns = ()
    let title-aligns = ()
    let title-pieces = ()
    if logo-left != none {
        title-columns.push(15fr)
        title-aligns.push(top)
        title-pieces.push(logo-left)
    }
    title-columns.push(85fr)
    title-aligns.push(horizon)
    title-pieces.push(_title(title))
    if logo-right != none {
        title-columns.push(15fr)
        title-aligns.push(top)
        title-pieces.push(logo-right)
    }
    grid(columns: title-columns, column-gutter: 4fr, align: title-aligns, ..title-pieces)
    v(10pt)
    // Authors
    {
        set align(center)
        let count = authors.len()
        let ncols = calc.min(count, author-maxcols)
        grid(
            columns: (1fr,) * ncols,
            row-gutter: 24pt,
            ..authors.map(author => [
                *#author.name* \
                #if author.affiliation != none [#author.affiliation#linebreak()]
                #if author.email != none { as-code(author.email) }
            ]),
        )
    }
    // Abstract
    if abstract != [] {
        v(10pt)
        set align(center)
        text(size: 1.3em, smallcaps("Abstract", all: true))
        parbreak()
        set align(left)
        abstract
    }
    // Bottomline
    if bottomline {
        v(15pt)
        line(length: 100%)
        v(10pt)
    } else {
        v(20pt)
    }
    doc
}

/// Marks the transition to the appendix, for example meaning that:
///
/// - Heading numbering shifts to "A.1.".
/// - A new title is provided.
///
/// *Usage:*
///
/// ```typst
/// #show: appendix.with(title: "Supplementary")
/// ```
///
/// - title (none, content): the title to place at the start of the appendix.
/// - numbering (str, function): the numbering for `heading`s.
/// - supplement (str): the supplement for `heading`s.
/// -> content
#let appendix(title: auto, numbering: "A.1", supplement: "Appendix", doc) = {
    place.flush()
    pagebreak(weak: true)
    set heading(numbering: numbering, supplement: supplement)
    counter(heading).update(0)
    assert.ne(title, auto, message: "Must specify a title: `#show appendix.with(title: ...)`.")
    if title != none { std.title(title) }
    doc
}

/// Arranges for all headings to include their `supplement` in their name.
///
/// This is expected to be particularly useful for certain kinds of appendices.
///
/// *Usage:*
///
/// ```typst
/// #show: section-prefixed-by-supplement
/// ```
#let section-prefixed-by-supplement(it) = {
    show heading: it => [#it.supplement #box(it)]
    it
}

/// Arranges for all level-1 headings to start on a new page.
///
/// This is expected to be particularly useful for certain kinds of appendices.
///
/// *Usage:*
///
/// ```typst
/// #show: section-starts-on-new-page
/// ```
#let section-starts-on-new-page(it) = {
    show heading.where(level: 1): it => {
        pagebreak(weak: true)
        it
    }
    it
}

