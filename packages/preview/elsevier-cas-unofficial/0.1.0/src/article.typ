// elsevier-cas-unofficial: a Typst port of Elsevier's CAS LaTeX classes (cas-sc.cls and
// cas-dc.cls, v2.4).
#import "globals.typ": *
#import "utils.typ": *
#import "frontmatter.typ": *
#import "environments.typ": *

// The `layout` argument of `article` shadows the built-in function.
#let measure-layout = layout

/// The elsevier-cas-unofficial template. Apply it with `#show: article.with(...)`.
///
/// Authors are dictionaries with the keys `name` (required; a string split
/// into given names and surname at the last space, or `(given: .., family:
/// ..)`), `affiliations` (ids of `affiliations`), `corresponding` (`true`
/// or the number of the corresponding-author note), `footnotes` (numbers of
/// `author-notes`), `email`, `url`, `orcid`, `credit`, `prefix`, `suffix`,
/// `degree`, `role`, `style` (`"chinese"` puts the surname first),
/// `deceased`, `twitter`, `facebook`, `linkedin`, `gplus`.
///
/// - layout (str): `"dc"` for double column (cas-dc) or `"sc"` for single
///   column (cas-sc).
/// - title (content): the article title.
/// - alt-title, subtitle, trans-title, trans-subtitle (content): the other
///   `\title[mode=...]` variants.
/// - short-title (content, auto): running head; defaults to the title.
/// - short-authors (content, auto): author part of the footer; defaults to
///   "F. Author et al.".
/// - authors (array): the authors, see above.
/// - affiliations (dictionary): affiliation id → content, or → a dictionary
///   with `organization`, `addressline`, `city`, `postcode`, `state`,
///   `country` (and optional `<key>sep` separators).
/// - title-notes (array): notes attached to the title (⋆, ⋆⋆, ...).
/// - corresponding-notes (array, auto): texts for the corresponding-author
///   marks ∗, ∗∗, ...; defaults to "Corresponding author".
/// - author-notes (array): numbered author footnotes (1, 2, ...).
/// - nonum-notes (array): first-page notes without mark.
/// - abstract (content): the abstract.
/// - abstract-title (content): heading of the abstract.
/// - keywords (array): keywords, one per line in the article-info box.
/// - keywords-title (content): label of the keywords.
/// - msc, jel, pacs (content, dictionary): classification codes; `msc` may
///   be `(year: 2020, codes: [...])`.
/// - graphical-abstract (content): content of a graphical-abstract page.
/// - highlights (array): research highlights, printed on their own page.
/// - journal (content): shown as "Preprint submitted to <journal>".
/// - blind (bool): hide author information for double-blind review.
/// - review (bool): double line spacing.
/// - long-title (bool): let a long front matter break across pages
///   (`longmktitle`); in two-column layout the body then starts below it,
///   and `pagebreak()` in the body is emulated with column breaks.
/// - logos (bool): icons before emails, URLs and social links.
/// - fleqn (bool): left-align display equations.
/// - line-numbers (bool): number the lines of each page.
/// - paper (auto, str): paper size; `auto` uses the CAS trim size.
/// - fonts (dictionary): overrides of `serif`, `sans`, `mono`, `math`.
/// - lang (str): document language.
/// -> content
#let article(
  layout: "dc",
  title: none,
  alt-title: none,
  subtitle: none,
  trans-title: none,
  trans-subtitle: none,
  short-title: auto,
  short-authors: auto,
  authors: (),
  affiliations: (:),
  title-notes: (),
  corresponding-notes: auto,
  author-notes: (),
  nonum-notes: (),
  abstract: none,
  abstract-title: [Abstract],
  keywords: (),
  keywords-title: [Keywords],
  msc: none,
  jel: none,
  pacs: none,
  graphical-abstract: none,
  highlights: (),
  journal: [Elsevier],
  blind: false,
  review: false,
  long-title: false,
  logos: true,
  fleqn: true,
  line-numbers: false,
  paper: auto,
  fonts: (:),
  lang: "en",
  body,
) = {
  assert(layout in layouts, message: "`layout` must be \"sc\" or \"dc\"")
  let geom = layouts.at(layout)
  let two-columns = geom.columns == 2
  let fonts = default-fonts + fonts
  let affiliations = affiliations.pairs().map(((k, v)) => (str(k), v)).to-dict()
  let title-notes = as-array(title-notes)
  let author-notes = as-array(author-notes)
  let keywords = as-array(keywords)

  let n-cor = calc.max(0, ..authors.map(corresponding-level))
  let corresponding-notes = if corresponding-notes == auto {
    range(n-cor).map(_ => [Corresponding author])
  } else { as-array(corresponding-notes) }
  assert(
    n-cor <= corresponding-notes.len(),
    message: "an author has `corresponding: " + str(n-cor) + "`, which needs "
      + str(n-cor) + " `corresponding-notes`; got "
      + str(corresponding-notes.len()),
  )

  let classifications = ()
  if msc != none {
    let year = if type(msc) == dictionary { msc.at("year", default: none) }
    let codes = if type(msc) == dictionary { msc.codes } else { msc }
    classifications.push((if year == none [MSC] else [#year MSC], codes))
  }
  if jel != none { classifications.push(([JEL], jel)) }
  if pacs != none { classifications.push(([PACS], pacs)) }

  let short-title = if short-title == auto { title } else { short-title }
  let short-authors = if short-authors != auto {
    short-authors
  } else if authors.len() == 0 {
    none
  } else if authors.len() == 1 {
    short-name(authors.first())
  } else if authors.len() == 2 {
    [#short-name(authors.first()) and #short-name(authors.last())]
  } else {
    [#short-name(authors.first()) et al.]
  }

  // Document ---------------------------------------------------------------
  set document(
    title: title,
    author: if blind { () } else { authors.map(a => to-str(full-name(a))) },
    keywords: keywords.map(to-str),
  )

  // Page -------------------------------------------------------------------
  // LaTeX puts the first baseline 10pt below the top of the text area and
  // the last one on its bottom; Typst lines reach 7pt above and 3pt below
  // their baseline, hence the 3pt shifts.
  let page-size = if paper == auto {
    (width: geom.width, height: geom.height)
  } else {
    (paper: paper)
  }
  set page(
    ..page-size,
    margin: (top: geom.top + 3pt, bottom: geom.bottom - 3pt, x: geom.x),
    columns: if long-title { 1 } else { geom.columns },
    numbering: "1",
    header-ascent: 12.4pt,
    footer-descent: 8.9pt,
    header: context {
      let title-page = query(<cas-title-page>).map(m => m.location().page())
      if title-page.len() > 0 and here().page() > title-page.first() {
        set text(size: 9pt)
        set par(first-line-indent: 0pt)
        with-font(fonts.sans, align(center, short-title))
      }
    },
    footer: context {
      set text(size: 9pt)
      set par(first-line-indent: 0pt, justify: false)
      block(spacing: 0pt, line(length: 100%, stroke: 0.2pt))
      v(5.7pt)
      block(spacing: 0pt, {
        if not blind and short-authors != none {
          with-font(fonts.sans)[#short-authors: ]
        }
        emph[Preprint submitted to #journal]
        h(1fr)
        let total = counter(page).final().first()
        with-font(fonts.sans)[Page #counter(page).display() of #total]
      })
    },
  )
  set columns(gutter: column-gutter)

  // Text -------------------------------------------------------------------
  set text(
    font: fonts.serif,
    size: 10pt,
    lang: lang,
    top-edge: top-edge,
    bottom-edge: bottom-edge,
  )
  let skip = if review { 10pt } else { 2pt } // \doublespacing under `review`
  set par(justify: true, leading: skip, spacing: skip)
  set par(first-line-indent: (amount: par-indent, all: true))
  set par.line(
    numbering: if line-numbers {
      n => text(size: 6pt, fill: luma(40%), str(n))
    },
    numbering-scope: "page",
  )
  show raw: it => with-font(fonts.mono, it)
  show raw.where(block: true): set block(above: 8pt, below: 8pt)
  show raw.where(block: true): set par(leading: 4pt)
  show link: set text(fill: link-color)
  show link: it => if type(it.dest) == str and to-str(it.body) == it.dest {
    with-mono(fonts.mono, it)
  } else { it }
  show ref: set text(fill: link-color)
  show cite: set text(fill: link-color)

  // Like LaTeX, a paragraph that continues right after a display equation
  // (no blank line in between) gets no first-line indent.
  show parbreak: it => [#it#metadata(none)<cas-parbreak>]
  show par: it => {
    if it.first-line-indent.amount == 0pt { return it }
    context {
      let eq-ends = query(selector(<cas-eq-end>).before(here()))
      let eq-end = eq-ends.at(-1, default: none)
      if eq-end == none { return it }
      let at-eq-end = eq-end.location().position() == here().position()
      let breaks = selector(<cas-parbreak>).after(eq-end.location())
      if not at-eq-end or query(breaks.before(here())).len() > 0 { return it }
      let fields = it.fields()
      let body = fields.remove("body")
      let _ = fields.remove("first-line-indent", default: none)
      par(..fields, first-line-indent: 0pt, body)
    }
  }

  // Headings ---------------------------------------------------------------
  // Sections, subsections and subsubsections are numbered (secnumdepth 3).
  let section-numbering(..n) = if n.pos().len() <= 3 { numbering("1.1", ..n) }
  set heading(numbering: section-numbering)
  show heading: it => {
    if it.level >= 4 {
      // \paragraph and \subparagraph: run-in headings
      return {
        v(if it.level == 4 { 8pt } else { 0pt })
        box(text(
          size: 11pt,
          weight: "regular",
          style: if it.level == 4 { "italic" } else { "normal" },
          it.body,
        ))
        h(6pt)
      }
    }
    // (size, baselineskip), weight, style, space above and below
    let (size, weight, style, above, below) = (
      (sizes.large, "bold", "normal", 18.1pt, 5.4pt),
      ((11pt, 13pt), "bold", "normal", 12.3pt, 1.8pt),
      ((10.5pt, 12pt), "bold", "italic", 11.65pt, 1.95pt),
    ).at(it.level - 1)
    let title = with-size(size, {
      set text(weight: weight, style: style)
      set par(justify: false, first-line-indent: 0pt)
      context {
        let num = if it.numbering != none {
          counter(heading).display(it.numbering)
        }
        let number = if num not in (none, []) [#num.#h(0.5em)]
        let hang = if number != none { measure(number).width } else { 0pt }
        par(hanging-indent: hang)[#number#it.body]
      }
    })
    block(above: above, below: below, sticky: true, breakable: false, title)
  }

  // Lists ------------------------------------------------------------------
  // As in LaTeX, the items of a list at depth k are indented by
  // \leftmargin of that depth, and the label is right-aligned \labelsep
  // before them (and overhangs to the left if it is too wide).
  let list-label(depth, label) = box(
    width: list-margins.at(calc.min(depth, 3)) - label-sep,
    align(right, label),
  )
  // \labelitemi to \labelitemiv; LaTeX takes \textasteriskcentered and
  // \textperiodcentered from the math font. The bullet of STIX Two is
  // smaller than the one of STIX, unlike that of (built-in) New Computer
  // Modern Math.
  let markers = (
    text(font: "New Computer Modern Math")[•],
    text(weight: "bold")[–],
    $ast.op$,
    $dot.op$,
  )
  set list(
    marker: depth => list-label(depth, markers.at(calc.rem(depth, 4))),
    indent: 0pt,
    body-indent: label-sep,
    spacing: 10pt,
  )
  show list: set block(above: 10pt, below: 10pt)
  // Labels 1., (a), i., A. by depth, set upright. A pattern like
  // "1.(a)i.A." cannot do this (all levels share its prefix and suffix),
  // so a function receives the numbers of all levels (`full: true`). `full`
  // is only set for this function, so that a user's pattern keeps its usual
  // meaning; its label starts at the margin, like `enumerate[(1)]` in CAS.
  let enum-numbering(..n) = {
    let n = n.pos()
    let depth = n.len() - 1
    let pattern = ("1.", "(a)", "i.", "A.").at(calc.min(depth, 3))
    list-label(depth, text(style: "normal", numbering(pattern, n.last())))
  }
  set enum(
    numbering: enum-numbering,
    indent: 0pt,
    body-indent: label-sep,
    spacing: 3.2pt,
  )
  show enum.where(numbering: enum-numbering): set enum(full: true)
  show enum: set block(above: 8pt, below: 8pt)

  // Equations --------------------------------------------------------------
  set math.equation(numbering: "(1)")
  show math.equation: it => with-font(fonts.math, it)
  show math.equation.where(block: true): set block(above: 8pt, below: 8pt)
  show math.equation.where(block: true): it => {
    let eq = if fleqn {
      set align(left)
      pad(left: math-indent, it)
    } else { it }
    // Marker used by the `show par` rule above (must stay outside `pad`).
    eq + [#[ #[]<cas-eq-end>]]
  }

  // Figures and tables -----------------------------------------------------
  set figure(gap: 6pt)
  show figure: set block(above: 12pt, below: 12pt) // \intextsep
  // Cells: \tabcolsep, and the strut of LaTeX tables (0.7\baselineskip
  // above the baseline, 0.3\baselineskip below). Lines span 0.7em above to
  // 0.3em below it, and \baselineskip is 2pt more than the size at \small
  // and \normalsize.
  set table(
    stroke: none,
    inset: (x: 6pt, top: 1.4pt, bottom: 0.6pt),
    align: start,
  )
  show table: show-booktabs
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: table): set figure(gap: 5pt)
  // Figure and table environments are set in \sffamily\small.
  let sans-small(it) = with-font(fonts.sans, with-size(sizes.small, it))
  show figure.where(kind: image): sans-small
  show figure.where(kind: table): sans-small
  // CAS sets a table caption in a \parbox as wide as the `width` option of
  // the table (default: the column), which is also \tblwidth for the
  // tabular. Here that width is the one of a block around the table.
  show figure.where(kind: table): it => {
    let width = if it.body.func() in (block, box) {
      it.body.at("width", default: auto)
    } else { auto }
    show figure.caption: cap => block(width: width, cap)
    it
  }
  show figure.caption: it => {
    with-size(sizes.small, context {
      set par(first-line-indent: 0pt, justify: true)
      let label = if it.numbering != none {
        [#it.supplement~#it.counter.display(it.numbering)]
      } else {
        it.supplement
      }
      if it.kind == table {
        // "Table 1" on its own line above the caption text
        align(left)[#strong(label)\ #it.body]
      } else {
        // "Figure 1: ...", centred when it fits on one line
        let cap = [#strong[#label:] #it.body]
        measure-layout(size => if measure(cap).width <= size.width {
          align(center, cap)
        } else { cap })
      }
    })
  }
  show figure: show-theorem

  // Footnotes --------------------------------------------------------------
  set footnote.entry(
    // \footnoterule, and the room LaTeX leaves below it
    separator: block(height: 3.5pt, line(length: 40%, stroke: 0.4pt)),
    clearance: 6pt,
    gap: 1.5pt,
    indent: 0pt,
  )
  // Front-matter notes carry their mark in the author list, not in the text.
  show footnote: it => if (
    it.has("label") and it.label in (<cas-frontnote>, <cas-frontnote-ragged>)
  ) {
    []
  } else { it }
  show footnote.entry: it => {
    let ragged = (
      it.note.has("label") and it.note.label == <cas-frontnote-ragged>
    )
    with-size(sizes.footnotesize, context {
      set par(first-line-indent: 0pt, hanging-indent: 0pt, justify: not ragged)
      set par.line(numbering: none)
      let num = numbering(
        it.note.numbering,
        ..counter(footnote).at(it.note.location()),
      )
      [#box(width: 18pt)[#h(1fr)#super(size: 0.75em, num)]#it.note.body]
    })
  }

  // Bibliography -----------------------------------------------------------
  set bibliography(title: [References], style: "elsevier-harvard")
  show bibliography: it => with-size((8pt, 10pt), it)

  // Content ----------------------------------------------------------------
  cas-info.update((authors: authors, blind: blind))

  if graphical-abstract != none {
    prelim-page(
      [Graphical Abstract],
      graphical-abstract,
      title: title,
      authors: authors,
      blind: blind,
    )
  }
  let highlights = as-array(highlights)
  if highlights.len() > 0 {
    prelim-page(
      [Highlights],
      list(..highlights),
      title: title,
      authors: authors,
      blind: blind,
    )
  }
  counter(page).update(1)
  [#metadata(none)<cas-title-page>]

  let titles = (
    ("title", title),
    ("alt", alt-title),
    ("sub", subtitle),
    ("trans", trans-title),
    ("transsub", trans-subtitle),
  ).filter(((_, t)) => t != none)
  let title-block = make-title(
    titles: titles,
    n-title-notes: title-notes.len(),
    authors: authors,
    affiliations: affiliations,
    blind: blind,
    abstract: abstract,
    abstract-title: abstract-title,
    keywords: keywords,
    keywords-title: keywords-title,
    classifications: classifications,
    fonts: fonts,
  )
  let notes = front-notes(
    title-notes: title-notes,
    nonum-notes: as-array(nonum-notes),
    corresponding-notes: corresponding-notes,
    author-notes: author-notes,
    authors: authors,
    blind: blind,
    logos: logos,
    fonts: fonts,
  )

  // Body footnotes are numbered after the author notes, if these are shown.
  let first-footnote = if blind { 0 } else { author-notes.len() }

  if two-columns and not long-title {
    // \twocolumn[\MaketitleBox]: the title block spans both columns and the
    // first-page notes go to the foot of the first column. A float cannot
    // break across pages, so a taller title block would overlap the footer.
    context assert(
      measure(title-block, width: page.width - 2 * geom.x).height
        <= page.height - geom.top - geom.bottom,
      message: "the front matter does not fit on the first page; "
        + "set `long-title: true`",
    )
    place(top, scope: "parent", float: true, clearance: 7.6pt, title-block)
    notes
    counter(footnote).update(first-footnote)
    body
  } else {
    notes
    title-block
    counter(footnote).update(first-footnote)
    if two-columns {
      v(7.6pt)
      // Page breaks are not allowed inside the `columns` container: break
      // columns until a new page starts. A weak break at the top of a page
      // is skipped.
      show pagebreak: it => context {
        let pos = here().position()
        let first-column = pos.x < page.width / 2
        let at-top = pos.y <= geom.top + 3pt + 0.01pt
        if not (it.weak and first-column and at-top) {
          colbreak()
          if first-column { colbreak() }
        }
      }
      block(above: 0pt, columns(geom.columns, body))
    } else {
      v(4.8pt)
      body
    }
  }
}
