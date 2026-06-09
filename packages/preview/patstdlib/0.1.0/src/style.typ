#let _font-info-state = state("7e79ee62c4164f44af4c01f139a93236", none)
#let font-info() = {
    let x = _font-info-state.get()
    assert.ne(x, none, message: "Must call `#show: style` first.")
    x
}
#let _as-font(font-type, body) = context {
    let fi = font-info()
    let font = fi.at(font-type)
    let size = 1em * (fi.scaling.at(font) / fi.scaling.at(text.font))
    text(font: font, size: size, body)
}
#let as-title(body) = _as-font("title-font", body)
#let as-normal(body) = _as-font("normal-font", body)
#let as-math(body) = _as-font("math-font", body)  // Not useful, $..$ exists.
#let as-code(body) = _as-font("code-font", body)  // Not useful, `..` exists.
#let as-bio(body) = _as-font("bio-font", body)

/// Sets fonts and sizes across the document.
#let fonts(
    title-font: "New Computer Modern",
    heading-font: "New Computer Modern",
    normal-font: "New Computer Modern",
    math-font: "New Computer Modern Math",
    code-font: "DejaVu Sans Mono",
    bio-font: "DejaVu Sans Mono",
    title-size: 20pt,
    text-size: 11pt,
    fallback-text: false,
    smallcaps-backup: false,
    scaling: ("New Computer Modern": 100%, "New Computer Modern Math": 100%, "DejaVu Sans Mono": 91%),
    doc,
) = {
    // Normalize to lower, which is how `context text.font` is stored.
    title-font = lower(title-font)
    heading-font = lower(heading-font)
    normal-font = lower(normal-font)
    math-font = lower(math-font)
    code-font = lower(code-font)
    bio-font = lower(bio-font)
    let scaling2 = (:)
    for (k, v) in scaling.pairs() {
        scaling2.insert(lower(k), v)
    }
    scaling = scaling2
    let font-info-to-set = (
        title-font: title-font,
        heading-font: heading-font,
        normal-font: normal-font,
        math-font: math-font,
        code-font: code-font,
        bio-font: bio-font,
        title-size: title-size,
        text-size: text-size,
        scaling: scaling,
    )
    // Poor man's set-rule.
    context {
        assert.eq(_font-info-state.get(), none, message: "Cannot call `style` twice.")
        _font-info-state.update(font-info-to-set)
    }

    // Numbering
    set page(numbering: "1")
    set heading(numbering: "1.1")

    // Layout
    set par(justify: true)
    set page("a4", margin: (top: 40pt, x: 40pt, bottom: 60pt))

    // Font
    set text(font: normal-font, size: text-size * scaling.at(normal-font), fallback: fallback-text)
    show heading: set text(font: heading-font)
    show math.equation: set text(font: math-font, size: 1em * scaling.at(math-font))
    show raw: set text(font: code-font, size: 1em * scaling.at(code-font))
    show smallcaps: doc => if smallcaps-backup {text(size: 0.8em, upper(doc))} else {doc}

    doc
}

/// Styles text as a title.
/// - body (str, content): the text to use for the title.
/// -> content
#let title(body) = context {
    let fi = font-info()
    set par(justify: false)
    set text(size: fi.title-size, hyphenate: false, weight: "bold")
    as-title(body)
}
// Just a rename for usage in `#style`, which has a local variable `title`.
#let _title = title

/// A simple style for the top matter.
///
/// *Example:*
///
/// ```typst
/// #show: style.with(
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
                #if author.email != none {as-code(author.email)}
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
/// -> content
#let appendix(title: auto, doc) = {
    place.flush()
    pagebreak()
    set heading(numbering: "A.1", supplement: "Appendix")
    counter(heading).update(0)
    assert.ne(title, auto, message: "Must specify a title: `#show appendix.with(title: ...)`.")
    if title != none { _title(title) }
    doc
}
