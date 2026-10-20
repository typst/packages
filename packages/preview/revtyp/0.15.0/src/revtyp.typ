#import "util.typ": *
#import "draft.typ": *


#let revtyp(
  //
  /// Journal
  /// -> str
  journal: "PRAB",
  //
  // The paper title
  // -> content | str | none
  title: none,
  //
  // The list of authors
  // where each author is a dictionary with keys `name` or `names`, `at` and optionally also `email` and `orcid`
  // -> array
  authors: (),
  //
  /// The list of affiliations
  /// mapping the keys used in the authors list as `at` to the affiliation name
  /// -> dictionary
  affiliations: (:),
  //
  /// Switch to change author affiliation style from using superscripts to grouping by affiliation
  /// -> bool
  group-by-affiliation: false,
  //
  /// The paper abstract
  /// -> content | str | none
  abstract: none,
  //
  /// Optional pubmatter object
  /// with `title`, `author`, `affiliations` and/or `abstract` if not passed explicitly
  /// -> dictionary
  pubmatter: none,
  //
  /// Date(s)
  /// -> content | str | none
  date: none,
  //
  /// DOI
  /// -> str
  doi: none,
  //
  /// Header contents
  /// -> content | str | none
  header: (
    title: none,
    left: (
      even: none,
      odd: none,
    ),
    right: (
      even: none,
      odd: none,
    ),
    rule: true,
  ),
  //
  /// Footer contents
  /// -> content | str | none
  footer: (
    title-left: none,
    title-right: none,
    center: context counter(page).display(),
  ),
  //
  /// Optional note in the footer
  /// -> none | str
  footnote-text: none,
  //
  /// To make footnotes span over both columns (instad of left column only)
  /// -> bool
  wide-footnotes: false,
  //
  /// Switch to show line numbers
  /// -> bool
  show-line-numbers: false,
  //
  /// Option to overwrite journal paper format
  /// -> auto | string
  paper: auto,
  //
  /// Switch to overwrite column number
  /// -> auto | bool
  twocolumn: auto,
  //
  /// The content
  /// -> content
  content,
) = {
  //
  // Parameter sanitization and pubmatter support
  // ********************************************

  if pubmatter != none {
    if title == none {
      title = pubmatter.title
    }
    if authors.len() == 0 {
      authors = pubmatter.authors.map(a => {
        a.insert("at", a.affiliations.map(a => a.id))
        a
      })
    }
    if affiliations.len() == 0 {
      affiliations = pubmatter.affiliations.map(a => (a.id, a.name)).to-dict()
    }
    if abstract == none {
      abstract = pubmatter.abstracts.at(0).content
    }
    if doi == none {
      doi = pubmatter.doi
    }
    if date == none {
      date = [(#pubmatter.date.display("[day padding:none] [month repr:long] [year]");)]
    }
  }

  authors = sanitize-authors(authors)
  (header, footer) = sanitize-header-footer(header, footer)


  // Journal style handling
  // **********************

  journal = lower(journal)
  let supported-journals = (
    "pra",
    "prab",
    "prapplied",
    "prb",
    "prc",
    "prd",
    "pre",
    "prfluids",
    "prl",
    "prmaterials",
    "prper",
    "prx",
    "prxenergy",
    "prxlife",
    "prxquantum",
  )
  assert(
    journal in supported-journals,
    message: "Journal `"
      + str(journal)
      + "` not supported. Choose one of: `"
      + supported-journals.join("`, `", last: " or ")
      + "`.",
  )

  import "styles/" + journal + ".typ" as style
  show: style.layout

  set page(..if paper != auto { (paper: paper) })
  set page(..if twocolumn != auto { (columns: if twocolumn { 2 } else { 1 }) })


  // Draft utilities
  // ***************

  show: as-draft.with(
    show-line-numbers: show-line-numbers,
  )


  // Footnotes
  // *********

  // Note: footnotes not working in parent scoped placement with two column mode.
  // See https://github.com/typst/typst/issues/1337#issuecomment-1565376701
  // As a workaround, we handle footnotes in the title area manually.
  // An alternative is to not use place and use "show: columns.with(2, gutter: 0.2in)" after the title area instead of "page(columns: 2)",
  // but then footnotes span the full page and not just the left column.
  //let titlefootnote(text) = { footnote(numbering: titlenotenumbering, text) }
  let footnotes = state("titlefootnotes", (:))
  footnotes.update(footnotes => (:)) // For multiple papers in a single file
  let titlenotenumbering(i) = {
    /// Helper for custom footnote symbols
    i = i - 1
    let symbols = ("*", "#", "§", "∥", "¶", "‡")
    int(1 + i / symbols.len()) * symbols.at(calc.rem(i, symbols.len()))
  }
  let titlefootnote(text) = context {
    // Re-use footnote if already exists
    for (key, value) in footnotes.get() {
      if value == text {
        return key
      }
    }
    // Or else create new
    let key = titlenotenumbering(footnotes.get().len() + 1)
    footnotes.update(footnotes => {
      footnotes.insert(key, text)
      footnotes
    })
    key
  }

  set footnote.entry(separator: line(length: 15%, stroke: 0.5pt))


  // Header and footer
  // *****************

  set page(header: context if here().page() == 1 {
    // Header on page 1
    set align(center)
    set text(size: style.var.first-header-font-size)
    move(dy: style.var.first-header-dy, upper(header.title))
    if header.rule { place(dy: style.var.first-rule-dy, line(length: 100%)) }
  } else {
    set text(size: style.var.header-font-size)
    if calc.even(here().page()) {
      // Header on page 2, 4, 6, ...
      header.left.even + h(1fr) + header.right.even
    } else {
      // Header on page 3, 5, 7, ...
      header.left.odd + h(1fr) + header.right.odd
    }
    if header.rule { place(dy: style.var.rule-dy, line(length: 100%)) }
  })
  set page(footer: context {
    set text(size: style.var.footer-font-size)
    if here().page() == 1 {
      // Left/right footer on page 1 only
      place(footer.title-left + h(1fr) + footer.title-right)
    }
    // Center footer on all pages
    set align(center)
    footer.center
  })


  // Frontmatter with title, author list and abstract
  // ************************************************

  set document(title: title, author: authors.map(author => author.name))

  place(top + center, scope: "parent", float: true, {
    set align(center)
    set par(justify: false)
    set text(hyphenate: false, overhang: false)

    v(style.var.title-descent)

    // Title

    show std.title: set block(below: style.var.title-spacing)
    std.title(title)


    // Author list

    let author-entry(author, numbers: (), no-comma: false) = {
      numbers = numbers.filter(n => n != none)
      if "email" in author {
        numbers = (
          ..numbers,
          titlefootnote("Contact author: " + author.email),
        )
      }
      if "note" in author {
        numbers = (..numbers, titlefootnote(author.note))
      }
      numbers = numbers.map(n => text(fill: style.var.link-color, [#n]))
      if author.at("prebreak", default: false) { linebreak() }
      keep-together({
        author.name
        if "orcid" in author { orcid(author.orcid) + h(-1pt) }
        if not no-comma { "," }
        super(typographic: false, size: 0.7em, numbers.join(","))
      })
    }

    let author-list(authors, numbers: a => ()) = {
      for i in range(authors.len()) {
        let join-and = i > 0 and i == authors.len() - 1
        if join-and { " and " } else if i > 0 { " " }
        author-entry(
          authors.at(i),
          numbers: numbers(authors.at(i)),
          no-comma: join-and or authors.len() <= 2,
        )
      }
    }

    let affiliation-text(id) = {
      affiliations.at(
        // allow passing prim. aff. directly, but only if it's a proper one
        id,
        ..if "," in id { (default: id) },
      )
    }

    let affiliation-entry(id, number: none, prefix: none) = {
      set text(size: 10pt)
      let a = affiliation-text(id)
      if type(a) == str {
        if number != none or prefix != none {
          // trim whitespaces
          a = a.trim()
        } else {
          // but allow newlines at start for manual linebreak control
          a = a.trim(" ").trim(at: end)
        }
      }
      keep-together({
        if number != none { super(typographic: false, str(number)) }
        if prefix != none { prefix }
        emph(a)
      })
    }

    //set par(leading: 0.45em)

    if group-by-affiliation {
      // Author list grouped by affiliation

      let primary-affiliations = authors.map(a => a.affiliation.first()).dedup()
      let also-at = authors
        .sorted(key: a => primary-affiliations.position(i => (
          i == a.affiliation.first()
        )))
        .map(a => a.affiliation.slice(1))
        .flatten()
        .dedup()
      also-at = also-at.zip(also-at.map(a => titlefootnote("Also at " + affiliation-text(a)))).to-dict()

      // author list with primary affiliation
      for aff in primary-affiliations {
        author-list(
          authors.filter(a => a.affiliation.first() == aff),
          numbers: a => {
            a.affiliation.slice(1).map(i => also-at.at(i))
          },
        )

        v(-0.75pt)

        affiliation-entry(aff)

        if (aff != primary-affiliations.last()) { v(style.var.affiliation-spacing) } else { v(1pt) }
      }
    } else {
      // Author list with superscript affiliations

      let at = authors.map(a => a.affiliation).flatten().dedup()
      at = at.zip(range(1, 1 + at.len())).to-dict()
      if at.len() == 1 { at = (at.keys().first(): none) }

      // author list
      author-list(
        authors,
        numbers: a => a.affiliation.map(i => at.at(i)).sorted(),
      )
      linebreak()

      // affiliations
      set par(leading: 0.45em)
      for (a, i) in at {
        affiliation-entry(a, number: i)
        linebreak()
      }
    }


    // Dates
    if date != none {
      v(style.var.date-spacing)
      set text(size: style.var.abstract-font-size)
      date
    }

    v(style.var.abstract-spacing)

    // Abstract

    block(width: style.var.abstract-width, {
      set align(left)
      set text(size: style.var.abstract-font-size)
      set par(justify: true, leading: style.var.abstract-leading, first-line-indent: 0pt)

      h(1em) + abstract

      // DOI
      if doi != none {
        set text(size: style.var.doi-font-size)
        v(8pt)
        doi = doi.find(regex("10\.\S+")) // DOIs always start with 10.
        [DOI: #link("https://doi.org/" + doi, doi)]
      }
    })

    v(style.var.frontmatter-spacing)
  })


  // Footnotes
  // *********

  place(
    bottom,
    ..if wide-footnotes { (scope: "parent") },
    float: true,
    block(width: 100%, {
      line(length: 35pt, stroke: 0.5pt)

      set par(hanging-indent: 0pt, first-line-indent: 0pt)
      set text(size: style.var.footnote-font-size)

      context for (symbol, text) in footnotes.get() {
        h(0.7em) + super(symbol) + text
        linebreak()
      }

      if footnote-text != none {
        set par(justify: true, leading: 3.9pt)
        show: emph

        v(9pt)
        footnote-text
      }
    }),
  )


  // Spacings
  // ********

  show heading.where(level: 1): set block(above: 22pt, below: 5pt)
  show heading.where(level: 2): set block(above: 22pt, below: 2pt)
  show heading: it => {
    // Trick to reduce spacing between consecutive headings
    // See https://github.com/typst/typst/issues/2953
    let previous_headings = query(
      selector(heading).before(here(), inclusive: false),
    )
    if previous_headings.len() > 0 {
      let ploc = previous_headings.last().location().position()
      let iloc = it.location().position()
      if (
        iloc.page == ploc.page and iloc.x == ploc.x and iloc.y - ploc.y < 35pt
      ) {
        v(-15pt)
      }
    }
    it
  }

  show figure.where(placement: none): it => {
    v(0.5em)
    it
    v(0.5em)
  }

  show math.equation.where(block: true): set block(above: 15pt, below: 14pt)


  // Content
  // *******


  show figure.caption: set par(first-line-indent: 0em, justify: true)
  show figure.caption: it => layout(size => context {
    // center for single-line, left for multi-line captions
    set align(if measure(it).width < size.width { center } else { left })
    // workaround for https://github.com/typst/typst/issues/5472
    set block(width: 100%)
    it
  })


  show math.equation: it => {
    // automaticaly hide equation number if no label attached
    if it.block and not it.has("label") and it.numbering != none [
      #counter(math.equation).update(v => v - 1)
      #math.equation(it.body, block: true, numbering: none)
    ] else {
      it
    }
  }


  // Bibliography
  // ************

  set bibliography(
    title: line(length: 75pt) + v(9pt),
    style: "revtyp.csl", // Modified for typst link injection
  )
  show bibliography: it => {
    // Handling of typst link injection
    show "<<<LINK>>>": [#metadata(none) <LINK> ] // Link marker
    show "<<<END>>>": [#metadata(none) <END> ] // End marker

    let linkify-magic = regex("<\[\[\[(.*)\]\]\]>")
    show linkify-magic: it => context {
      // find the link of this citation
      let target = query(
        selector(link).after(selector(label("LINK")).after(here())).before(selector(label("END")).after(here())),
      )
        .last(default: link("?"))
        .dest
      let label = it.text.matches(linkify-magic).first().captures.first()
      if label == "@" { label = target.replace("https://doi.org/", "") }
      //show link: it => [\[#it.body\](#it.dest)]
      text(fill: blue, link(target, sym.zws + label))
    }

    show grid.cell.where(x: 0): set align(right)

    show link: it => {
      if it.body.text.starts-with(sym.zws) {
        it
      }
    }

    show regex("\*(.*)\*"): it => {
      show "*": none
      strong(it)
    }

    it
  }


  content
}







/// Table in our style
///
/// - spec (str): Column alignment specification string such as "ccr"
/// - header (alignment, none): header location (top and/or bottom) or none
/// - contents: table contents
/// -> table
#let revtable(spec, header: top, ..contents) = {
  spec = spec.codepoints()
  if header == none { header = alignment.center }
  let args = (
    columns: spec.len(),
    align: spec.map(i => (a: auto, c: center, l: left, r: right).at(i)),
    stroke: (x, y) => {
      if y == 0 {
        (top: 0.08em, bottom: if header.y == top { 0.05em })
      } else if y > 1 { (top: 0em, bottom: 0.08em) }
    },
  )
  for (key, value) in contents.named() {
    args.insert(key, value)
  }

  show table.cell.where(y: 0): it => if header.y == top { strong(it) } else {
    it
  }
  show table.cell.where(x: 0): it => if header.x == left { strong(it) } else {
    it
  }

  table(
    ..args,
    ..contents.pos(),
  )
}




