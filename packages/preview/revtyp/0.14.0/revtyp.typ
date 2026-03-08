#import "@preview/scienceicons:0.1.0": orcid-icon
#let orcid(orcid) = {
  if not (orcid.starts-with("https://") or orcid.starts-with("http://")) {
    orcid = "https://orcid.org/" + orcid
  }
  link(orcid, orcid-icon(color: rgb("#AECD54"), height: 0.8em, baseline: 0pt))
}

#let revtyp(
  /// Journal
  /// -> str
  journal: "PRAB",
  /// The paper title
  /// -> content | str | none
  title: none,
  /// The list of authors
  /// where each author is a dictionary with keys `name` or `names`, `at` and optionally also `email` and `orcid`
  /// -> array
  authors: (),
  /// The list of affiliations
  /// mapping the keys used in the authors list as `at` to the affiliation name
  /// -> dictionary
  affiliations: (:),
  /// Switch to change author affiliation style from using superscripts to grouping by affiliation
  /// -> bool
  group-by-affiliation: false,
  /// The paper abstract
  /// -> content | str | none
  abstract: none,
  /// Optional pubmatter object
  /// with `title`, `author`, `affiliations` and/or `abstract` if not passed explicitly
  /// -> dictionary
  pubmatter: none,
  /// Date(s)
  /// -> content | str | none
  date: none,
  /// DOI
  /// -> str
  doi: none,
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
    badges: (),
  ),
  /// Footer contents
  /// -> content | str | none
  footer: (
    title-left: none,
    title-right: none,
    center: context counter(page).display(),
  ),
  /// Optional note in the footer
  /// -> none | str
  footnote-text: none,
  /// To make footnotes span over both columns (instad of left column only)
  /// -> bool
  wide-footnotes: false,
  /// Switch to show line numbers
  /// -> bool
  show-line-numbers: false,
  /// Switch to adjust paper format
  /// -> bool
  paper: "us-letter",
  /// The paper content
  /// -> content
  body,
) = {
  // Pubmatter support
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
      abstract-title = pubmatter.abstracts.at(0).title
      abstract = pubmatter.abstracts.at(0).content
    }
  }


  // sanitize author list
  if type(authors) == dictionary { authors = (authors,) } // single author case
  let i = 0
  while i < authors.len() {
    let a = authors.at(i)
    if "names" in a {
      for name in a.remove("names") {
        authors.insert(i, (name: name, ..a))
        i += 1
      }
    }
    i += 1
  }
  authors = authors.map(a => {
    if "at" in a.keys() { a.insert("affiliation", a.remove("at")) }
    if type(a.affiliation) == str {
      // ensure affiliation is an array
      a.insert("affiliation", (a.remove("affiliation"),))
    }
    if "name" in a.keys() { a.insert("name", a.name.trim(" ")) }
    a
  })
  authors = authors.filter(a => "name" in a.keys())

  // Sanitize header and footer
  if "title" not in header { header.insert("title", none) }
  for key in ("left", "right") {
    if key not in header { header.insert(key, none) }
    if type(header.at(key)) != dictionary {
      header.insert(key, (even: header.at(key), odd: header.at(key)))
    }
  }
  if "badges" not in header { header.insert("badges", ()) }
  for key in ("title-left", "title-right", "center") {
    if key not in footer { footer.insert(key, none) }
  }


  /// Helper for custom footnote symbols
  let titlenotenumbering(i) = {
    i = i - 1
    let symbols = ("*", "#", "§", "∥", "¶", "‡")
    int(1 + i / symbols.len()) * symbols.at(calc.rem(i, symbols.len()))
  }


  let supported-journals = ("PRAB",)
  journal = upper(journal)
  assert(
    journal in supported-journals,
    message: "Journal "
      + str(journal)
      + " not supported. Choose one of: "
      + supported-journals.join(", ", last: " or "),
  )


  // metadata

  set document(title: title, author: authors.map(author => author.name))


  // layout

  set page(
    paper: paper,
    margin: (
      x: 0.725in,
      top: 0.71in,
      bottom: 1.05in,
    ),
    columns: 2,
  )

  set columns(gutter: 0.25in)

  set text(
    font: "TeX Gyre Termes",
    size: 10pt,
    fill: color.rgb("221f1f"),
  )

  set par(
    spacing: 0.65em,
    leading: 0.55em,
    linebreaks: "optimized",
    justification-limits: (
      spacing: (min: 67%, max: 130%),
      tracking: (min: -0.015em, max: 0.02em),
    ),
  )

  let link-color = rgb(46, 48, 146)
  show link: set text(fill: link-color)
  show cite: set text(fill: link-color)


  // draft utilities

  set par.line(..if show-line-numbers {
    (numbering: it => text(fill: gray, size: 0.8em)[#it])
  })


  // Note: footnotes not working in parent scoped placement with two column mode.
  // See https://github.com/typst/typst/issues/1337#issuecomment-1565376701
  // As a workaround, we handle footnotes in the title area manually.
  // An alternative is to not use place and use "show: columns.with(2, gutter: 0.2in)" after the title area instead of "page(columns: 2)",
  // but then footnotes span the full page and not just the left column.
  //let titlefootnote(text) = { footnote(numbering: titlenotenumbering, text) }
  let footnotes = state("titlefootnotes", (:))
  footnotes.update(footnotes => (:)) // For multiple papers in a single file
  let titlefootnote(text) = context {
    // Re-use footnote if already exists
    for (key, value) in footnotes.get() {
      if value == text { return key }
    }
    // Or else create new
    footnotes.update(footnotes => {
      footnotes.insert(titlenotenumbering(footnotes.len() + 1), text)
      footnotes
    })
    h(0pt, weak: true)
    super(context footnotes.get().keys().at(-1))
  }

  set footnote.entry(separator: line(length: 15%, stroke: 0.5pt))


  /*
   * Header
   */

  set page(
    header: align(bottom + center, {
      set text(size: 11pt)
      context if counter(page).get().first() == 1 {
        align(center, text(size: 12pt, upper(header.title))) // TITLE PAGE HEADER
        v(-3pt)
        line(length: 100%)
        v(4pt)
        set text(fill: white, size: 7pt, font: "DejaVu Sans", weight: "bold")
        place(
          bottom + left,
          stack(dir: ltr, spacing: 10pt, ..header.badges.map(
            label => rect(
              fill: color.rgb("7f8185"),
              width: calc.max(90pt, measure(label).width),
              height: 10pt,
              inset: 3pt,
              align(center + bottom, label),
            ),
          ))
            + v(-10pt),
        )
      } else {
        if calc.even(counter(page).get().first()) {
          header.left.even // LEFT HEADER ON EVEN PAGE
          h(1fr)
          header.right.even // RIGHT HEADER ON EVEN PAGE
        } else {
          header.left.odd // LEFT HEADER ON ODD PAGE
          h(1fr)
          header.right.odd // RIGHT HEADER ON ODD PAGE
        }
        line(length: 100%)
        v(-3pt)
      }
    }),
    footer: context {
      align(top + center, {
        set text(size: 11pt)
        if counter(page).get().first() == 1 {
          place(grid(columns: (1fr, 1fr))[
            #footer.title-left // Left footer on title page
          ][
            #set align(right)
            #footer.title-right // Right footer on title page
          ])
        }

        footer.center // Middle footer on all pages
      })
    },
  )


  place(top + center, scope: "parent", float: true, {
    set align(center)
    set par(justify: false)
    set text(hyphenate: false)


    v(20pt)
    box(width: 5.55in, {
      /*
       * Title
       */
      {
        show std.title: set text(size: 12.7pt, weight: "bold")
        show std.title: set block(below: 14.4pt)

        std.title(title)
      }


      /*
       * Author list
       */
      {
        let keep-together(content) = {
          if type(content) == str and "\n" in content {
            // allow manual linebreaks
            show " ": sym.space.nobreak
            show "-": sym.hyph.nobreak
            content
          } else {
            box(content)
          }
        }

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
          numbers = numbers.map(n => [#n]) // convert everything to content for joining
          keep-together({
            author.name
            if "orcid" in author { orcid(author.orcid) + h(-1pt) }
            if not no-comma { "," }
            super(typographic: false, numbers.join(","))
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


        set par(leading: 0.45em)
        set text(size: 11pt, weight: "medium")


        if group-by-affiliation {
          // Authors grouped by affiliation

          let primary-affiliations = authors
            .map(a => a.affiliation.first())
            .dedup()
          let also-at = authors
            .sorted(key: a => primary-affiliations.position(i => (
              i == a.affiliation.first()
            )))
            .map(a => a.affiliation.slice(1))
            .flatten()
            .dedup()
          also-at = also-at
            .zip(also-at.map(
              a => titlefootnote("Also at " + affiliation-text(a)),
            ))
            .to-dict()

          v(1.5pt)

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

            if (aff != primary-affiliations.last()) { v(6.5pt) } else { v(1pt) }
          }
        } else {
          // Authors with superscript affiliations

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
      }

      v(6pt)


      /*
       * Dates in header
       */
      {
        set text(size: 9.9pt)
        date
      }
      v(6pt)


      /*
       * Abstract
       */
      {
        set align(left)
        set par(
          leading: 5.3pt,
          justify: true,
        )
        set text(
          size: 10pt,
          hyphenate: false,
          overhang: false,
        )

        h(1em)
        abstract
      }

      v(7pt)

      /*
       * DOI
       */
      if doi != none {
        set align(left)
        set text(size: 8.5pt)
        doi = doi.find(regex("10\.\S+")) // DOIs always start with 10.
        [DOI: #link("https://doi.org/" + doi, doi)]
      }

      v(14pt)
    })
  })


  /*
   * Footnotes
   */
  place(
    bottom,
    ..if wide-footnotes { (scope: "parent") },
    float: true,
    block(width: 100%, {
      set par(hanging-indent: 0pt)
      set text(size: 9.5pt)
      line(length: 35pt, stroke: 0.5pt)

      context for (symbol, text) in footnotes.get() {
        h(0.7em) + super(symbol) + sym.space.med + text
        linebreak()
      }

      if footnote-text != none {
        set par(justify: true, leading: 3.5pt)
        set text(size: 10pt, tracking: -0.007em)
        show: emph

        v(8pt)
        footnote-text
      }
      v(1pt)
    }),
  )


  /*
   * Contents
   */

  // paragraph
  set align(left)
  set par(
    first-line-indent: (amount: 1em, all: false),
    justify: true,
  )
  set text(
    overhang: false,
  )

  // Headings
  show heading.where(level: 1): set heading(numbering: "I.")
  show heading.where(level: 2): set heading(numbering: (..n, i) => numbering(
    "A.",
    i,
  ))
  show heading: set align(center)
  set heading(hanging-indent: 0pt) // workaround for https://github.com/typst/typst/issues/6834
  show heading: set text(
    size: 10.5pt,
    weight: "bold",
    style: "normal",
    hyphenate: false,
  )
  show heading.where(level: 1): upper
  show heading.where(level: 1): set block(above: 22pt, below: 5pt) // 11
  show heading.where(level: 2): set block(above: 22pt, below: 2pt) // 8
  show heading: it => { it + h(0pt) } // force indent on first paragraph of section
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

  // figures
  //set figure(placement: auto) // default to floating figures
  show figure.where(placement: none): it => {
    // add a little spacing for inline figures and tables
    v(0.5em)
    it
    v(0.5em)
  }
  show figure: set figure(supplement: "FIG.")
  show figure.caption: it => {
    set par(first-line-indent: 0em)
    set text(size: 9.5pt)
    layout(size => context {
      align(
        // center for single-line, left for multi-line captions
        if measure(it).width < size.width { center } else { left },
        if sys.version.at(1) >= 13 {
          // workaround for https://github.com/typst/typst/issues/5472#issuecomment-2730205275
          block(
            width: size.width,
            context [#it.supplement #it.counter.display()#it.separator#it.body],
          )
        } else {
          block(width: size.width, it) // use full width and justify
        },
      )
    })
  }

  // tables
  show figure.where(kind: table): set figure(
    supplement: "TABLE",
    numbering: "I",
  )
  show figure.where(kind: table): set figure.caption(
    position: top,
    separator: ".",
  )


  // equations
  set math.equation(numbering: "(1)")
  show math.equation.where(block: true): set block(above: 14pt, below: 14pt)
  show math.equation.where(block: true): it => {
    // automaticaly hide equation number if no label attached
    if not it.has("label") [
      #counter(math.equation).update(v => v - 1)
      #math.equation(it.body, block: true, numbering: none)#label("_")
    ] else {
      it
    }
  }

  // references
  set ref(supplement: it => {
    if it.func() == figure and it.kind == image {
      "Fig."
    } else if it.func() == figure and it.kind == table {
      "table"
    } else if it.func() == math.equation {
      "Eq."
    } else {
      it.supplement
    }
  })
  show ref: it => {
    show regex("\d+|[IVXL]+"): set text(fill: link-color)
    if it.element != none and it.element.func() == math.equation {
      show regex("\d"): it => text(fill: link-color, "(" + it + ")")
      it
    } else if it.element != none and it.element.func() == heading {
      let supplement = if type(it.supplement) == function { "section" } else {
        it.supplement
      }
      [#supplement #text(fill: link-color, numbering(
          "I A",
          ..counter(heading).at(it.element.location()),
        ))]
    } else {
      it
    }
  }


  // bibliography
  set bibliography(
    title: line(length: 75pt),
    style: "revtyp.csl", // Modified for typst link injection
  )
  show bibliography: it => {
    set text(9pt)
    set par(spacing: 9pt)
    show grid.cell.where(x: 0): set align(right)


    // Handling of typst link injection

    show "<<<LINK>>>": [#metadata(none) <LINK> ] // Link marker
    show "<<<END>>>": [#metadata(none) <END> ] // End marker

    let linkify-magic = regex("<\[\[\[(.*)\]\]\]>")
    show linkify-magic: it => context {
      // find the link of this citation
      let target = query(
        selector(link)
          .after(selector(label("LINK")).after(here()))
          .before(selector(label("END")).after(here())),
      )
        .last(default: link("?"))
        .dest
      let label = it.text.matches(linkify-magic).first().captures.first()
      if label == "@" { label = target.replace("https://doi.org/", "") }
      //show link: it => [\[#it.body\](#it.dest)]
      text(fill: blue, link(target, sym.zws + label))
    }

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


  body
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




/// Wide text environment at the top of a page, followed by two column layout
///
#let widetext-top(
  continue-paragraph-begin: true,
  continue-paragraph-end: true,
  content,
) = {
  if (continue-paragraph-begin) { linebreak(justify: true) }
  pagebreak()
  place(top, float: true, scope: "parent", block(width: 100%)[
    #if (not continue-paragraph-begin) { h(1em, weak: false) }
    #content
    #if (continue-paragraph-end) { linebreak(justify: true) }
    #move(dy: 8pt, curve(
      stroke: 0.5pt,
      curve.move((50%, 7pt)),
      curve.line((50%, 0pt)),
      curve.line((100%, 0pt)),
    ))
  ])
  if (not continue-paragraph-end) { h(1em) }
}

/// Wide text environment at the bottom of a page, preceeded by two column layout
///
#let widetext-bottom(
  continue-paragraph-begin: true,
  continue-paragraph-end: true,
  content,
) = {
  if (continue-paragraph-begin) { linebreak(justify: true) }
  place(bottom, float: true, scope: "parent", block(width: 100%)[
    #move(dy: -6pt, curve(
      stroke: 0.5pt,
      curve.line((50%, 0pt)),
      curve.line((50%, -7pt)),
    ))
    #v(6pt)
    #if (not continue-paragraph-begin) { h(1em, weak: false) }
    #content
    #if (continue-paragraph-end) { linebreak(justify: true) }
  ])
  pagebreak()
  if (not continue-paragraph-end) { h(1em) }
}

/// Wide text environment filling a whole page
///
#let widetext-page(
  continue-paragraph-begin: true,
  continue-paragraph-end: true,
  content,
) = {
  if (continue-paragraph-begin) { linebreak(justify: true) }
  pagebreak()
  place(top, float: true, scope: "parent", block(width: 100%, height: 100%, {
    if (not continue-paragraph-begin) { h(1em, weak: false) }
    content
    if (continue-paragraph-end) { linebreak(justify: true) }
  }))
  if (not continue-paragraph-end) { h(1em) }
}
