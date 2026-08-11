/*
 * Typst template for papers to be published with JACoW
 *
 * Based on the JACoW guide for preparation of papers.
 * See https://jacow.org/ for more information.
 * Requires Typst version 0.12 for compiling
 *
 * This document is licensed under the GNU General Public License 3
 * https://www.gnu.org/licenses/gpl-3.0.html
 * Copyright (c) 2024 Philipp Niedermayer (github.com/eltos)
 */

#let jacow(
  /// The paper title
  /// -> content | str | none
  title: none,
  /// The list of authors
  /// where each author is a dictionary with keys `name` or `names`, `at` and optionally also `email`
  /// -> array
  authors: (),
  /// The list of affiliations
  /// mapping the keys used in the authors list as `at` to the affiliation name
  /// -> dictionary
  affiliations: (:),
  /// Switch to chagne between author list grouped by affiliation (default) or using superscripts to indicate affiliations
  /// -> bool
  group-by-affiliation: true,
  /// Optional name of collaboration the author is writing the paper on behalf of
  /// -> none | str | content
  on-behalf-of: none,
  /// The paper abstract
  /// -> content | str | none
  abstract: none,
  /// Optional pubmatter object
  /// with `title`, `author`, `affiliations` and/or `abstract` if not passed explicitly
  /// -> dictionary
  pubmatter: none,
  /// Optional funding note
  /// -> none | str
  funding: none,
  /// The paper size
  /// -> "jacow" | "a4" | "letter"
  paper-size: "jacow",
  /// The heading used for the abstract
  /// -> str | content
  abstract-title: "Abstract",
  /// The heading used for the references
  /// -> str | content
  bibliography-title: "References",
  /// Optional page limit to show a warning when the paper length exceeds the limit
  /// -> none | int
  page-limit: none,
  /// Optional note to show on the paper, e.g. to indicate a draft revision number
  /// -> none | str | content
  draft-note: none,
  /// Switch to show line numbers
  /// -> bool
  show-line-numbers: false,
  /// Switch to show gridlines and column margins
  /// -> bool
  show-grid: false,
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
    if "by" in a.keys() { a.insert("name", a.remove("by")) }
    if "at" in a.keys() { a.insert("affiliation", a.remove("at")) }
    if type(a.affiliation) == str {
      // ensure affiliation is an array
      a.insert("affiliation", (a.remove("affiliation"),))
    }
    if "name" in a.keys() { a.insert("name", a.name.trim(" ")) }
    a
  })
  authors = authors.filter(a => "name" in a.keys())

  // sort authors: corresponding first, then alphabetic by last name
  authors = authors.sorted(key: a => (
    if "email" in a { " " } + a.name.split(" ").last()
  ))


  /// Helper for custom footnote symbols
  let titlenotenumbering(i) = {
    if i < 6 { ("*", "#", "§", "¶", "‡").at(i - 1) } else { (i - 4) * "*" }
  }

  /// Capitalize all characters in the text, e.g. "THIS IS AN ALLCAPS HEADING"
  let allcaps = upper

  /// Capitalize major words, e.g. "This is a Word-Caps Heading"
  /// Heuristic until we have https://github.com/typst/typst/issues/1707
  let wordcaps(body) = {
    if body.has("text") {
      let txt = body.text //lower(body.text)
      let words = txt.matches(regex("^()(\\w+)")) // first word
      words += txt.matches(regex("([.:;?!]\s+)(\\w+)")) // words after punctuation
      words += txt.matches(regex("()(\\w{4,})")) // words with 4+ letters
      for m in words {
        let (pre, word) = m.captures
        word = upper(word.at(0)) + word.slice(1)
        txt = txt.slice(0, m.start) + pre + word + txt.slice(m.end)
      }
      txt
    } else if body.has("children") {
      body.children.map(it => wordcaps(it)).join()
    } else {
      body
    }
  }


  // metadata

  set document(title: title, author: authors.map(author => author.name))


  // layout

  let paper = (
    if lower(paper-size) == "a4" {
      (width: 21mm, height: 29.7mm)
    } else if lower(paper-size) in ("us", "letter", "us-letter") {
      (width: 8.5in, height: 11in)
    } else if lower(paper-size) in ("jacow", "test") {
      (width: 21cm, height: 11in)
    } else {
      panic("Unsupported paper-size, use 'a4', 'us-letter' or 'jacow'!")
    }
  )

  // jacow margins slightly increased as per editor request
  let left-margin = 20mm
  let column-width = 82.5mm
  let column-gutter = 5mm
  let bottom-margin = 0.75in + 0.1in
  let column-height = 9.5in - 0.1in

  set page(
    width: paper.width,
    height: if lower(paper-size) == "test" { auto } else { paper.height },
    margin: (
      left: left-margin,
      right: paper.width
        - left-margin
        - 2 * column-width
        - column-gutter
        + 0.4mm,
      top: paper.height - bottom-margin - column-height + 0.005in,
      bottom: bottom-margin + 0.03in,
    ),
    columns: 2,
  )

  set columns(gutter: column-gutter + 0.4mm)


  set text(
    font: "TeX Gyre Termes",
    size: 10pt,
  )

  set par(
    spacing: 0.65em,
    leading: 0.5em,
    ..if sys.version >= version(0, 14) {
      (
        justification-limits: (
          spacing: (min: 70%, max: 130%),
          tracking: (min: -0.01em, max: 0.02em),
        ),
      )
    },
  )


  // draft utilities

  set page(
    header: grid(columns: (2fr, 3fr), align: (left, right))[
      // Page limit warning with note in header
      // until we have https://github.com/typst/typst/issues/1322
      #set text(fill: red, size: 13pt, weight: "bold")
      #context if (
        page-limit != none
          and query(<content-end>).at(0).location().page() > page-limit
      ) [
        Limit of #page-limit pages exceeded
      ]
    ][
      // Draft note
      #set text(fill: red)
      #draft-note
    ],
    ..if show-grid {
      (
        background: [
          #let at = (x: 0pt, y: 0pt, c) => place(bottom + left, move(
            dx: x,
            dy: -y,
            c,
          ))
          // grid
          #context for i in range(-1, 28) {
            let style = (length: 100%, stroke: silver)
            at(x: left-margin + i * 1cm, line(angle: 90deg, ..style))
            at(y: bottom-margin + i * 0.5in, line(..style))
            set text(fill: gray.darken(50%))
            at(x: left-margin + i * 1cm, y: bottom-margin - 0.5in, if i
              == 1 [1 cm] else if i >= 0 [#i])
            at(x: left-margin - 1cm, y: bottom-margin + i * 0.5in, if i
              == 1 [½ in] else if i >= 0 { str(i / 2).replace(".5", "½") })
          }
          // page and column borders
          #at(rect(width: 21cm, height: 29.7cm)) // DIN A4
          #at(rect(width: 8.5in, height: 11in)) // US letter
          #at(x: left-margin, y: bottom-margin, rect(
            width: column-width,
            height: column-height,
            stroke: green,
          ))
          #at(
            x: left-margin + column-width + column-gutter,
            y: bottom-margin,
            rect(width: column-width, height: column-height, stroke: green),
          )
        ],
      )
    },
  )

  set par.line(..if show-line-numbers {
    (numbering: it => text(fill: gray)[#it])
  })


  // Note: footnotes not working in parent scoped placement with two column mode.
  // See https://github.com/typst/typst/issues/1337#issuecomment-1565376701
  // As a workaround, we handle footnotes in the title area manually.
  // An alternative is to not use place and use "show: columns.with(2, gutter: 0.2in)" after the title area instead of "page(columns: 2)",
  // but then footnotes span the full page and not just the left column.
  //let titlefootnote(text) = { footnote(numbering: titlenotenumbering, text) }
  let footnotes = state("titlefootnotes", (:))
  footnotes.update(footnotes => (:)) // For multiple papers in a single file
  let titlefootnote(text) = {
    footnotes.update(footnotes => {
      footnotes.insert(titlenotenumbering(footnotes.len() + 1), text)
      footnotes
    })
    h(0pt, weak: true)
    context { super(footnotes.get().keys().at(-1)) }
  }

  show footnote.entry: set align(left)
  show footnote.entry: set par(hanging-indent: 0.57em)
  set footnote.entry(
    indent: 0em,
    separator: [
      #set align(left)
      #line(length: 40%, stroke: 0.5pt)
    ],
  )


  place(
    top + center,
    scope: "parent",
    float: true,
    {
      set align(center)
      set par(justify: false)
      set text(hyphenate: false)

      /*
       * Title
       */


      v(0.75pt)
      if (sys.version < version(0, 14)) {
        text(size: 14pt, weight: "bold", [
          #allcaps(title)
          #if funding != none { titlefootnote(funding) }
        ])
        v(8pt)
      } else {
        show std.title: set text(size: 14pt, weight: "bold")
        show std.title: set block(below: 17pt)
        std.title({
          allcaps(title)
          if funding != none { titlefootnote(funding) }
        })
      }


      /*
       * Author list
       */

      let keep-together(content) = {
        if type(content) == str and "\n" in content {
          // allow manual linebreaks
          show " ": sym.space.nobreak
          show "-": sym.hyph.nobreak
          content
        } else {
          set box(
            fill: green.lighten(50%),
            stroke: green.lighten(50%),
          ) if show-grid
          box(content)
        }
      }

      let author-entry(author, numbers: none) = {
        keep-together({
          author.name
          if "email" in author { titlefootnote(author.email) }
          if numbers != none {
            super(typographic: false, numbers.sorted().map(str).join(","))
          }
        })
      }

      let affiliation-entry(id, number: none, prefix: none) = {
        let a = affiliations.at(
          // allow passing prim. aff. directly, but only if it's a proper one
          id,
          ..if "," in id { (default: id) },
        )
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
          a
        })
      }

      text(size: 12pt, {
        if group-by-affiliation {
          // Grouped by Affiliation
          // **********************

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
          also-at = also-at.zip(range(1, 1 + also-at.len())).to-dict()

          // author list with primary affiliation
          for aff in primary-affiliations {
            let author-content = authors
              .filter(a => a.affiliation.first() == aff)
              .map(a => author-entry(
                a,
                numbers: a.affiliation.slice(1).map(i => also-at.at(i)),
              ))
              .join(", ")

            let affiliation-content = affiliation-entry(aff)

            // print author and primary affiliation entries on same or separate lines
            layout(it => {
              let combined-entry = author-content + ", " + affiliation-content
              if (
                measure(author-content, width: it.width).height
                  == measure(combined-entry, width: it.width).height
              ) {
                combined-entry + "\n"
              } else {
                author-content + affiliation-content + "\n" // No comma here!
              }
            })
          }

          // secondary affiliations
          for (a, i) in also-at {
            affiliation-entry(a, number: i, prefix: "also at ")
            linebreak()
          }
        } else {
          // Grouped by Author
          // *****************

          let at = authors.map(a => a.affiliation).flatten().dedup()
          at = at.zip(range(1, 1 + at.len())).to-dict()
          if at.len() == 1 { at = (at.keys().first(): "") }

          // author list
          authors
            .map(
              a => author-entry(a, numbers: a.affiliation.map(i => at.at(i))),
            )
            .join(", ")
          linebreak()

          // affiliations
          for (a, i) in at {
            affiliation-entry(a, number: i)
            linebreak()
          }
        }

        if on-behalf-of != none {
          "on behalf of " + on-behalf-of
        }
      })
      v(1pt)
    },
  )


  context {
    for (symbol, text) in footnotes.get() {
      place(footnote(
        numbering: it => "",
        { super(symbol) + sym.space.med + text },
      ))
    }
  }


  /*
   * Contents
   */

  // paragraph
  set align(left)
  set par(
    first-line-indent: 1em,
    justify: true,
  )
  //show: columns.with(2, gutter: 0.2in)


  // SECTION HEADINGS
  show heading.where(level: 1): it => {
    set align(center)
    set text(size: 12pt, weight: "bold", style: "normal", hyphenate: false)
    block(
      below: 2pt,
      sticky: true,
      allcaps(it.body),
    )
    h(1em)
  }

  // Subsection Headings
  show heading.where(level: 2): it => {
    set align(left)
    set text(size: 12pt, weight: "regular", style: "italic", hyphenate: false)
    block(
      below: 2pt,
      sticky: true,
      wordcaps(it.body),
    )
    h(1em)
  }

  // Third-Level Headings
  show heading.where(level: 3): it => {
    v(6pt)
    text(size: 10pt, weight: "bold", style: "normal", wordcaps(it.body))
    h(0.5em)
  }

  // lists
  show list: set list(indent: 1em)

  // figures
  //set figure(placement: auto) // default to floating figures
  show figure.where(placement: none): it => {
    // add a little spacing for inline figures and tables
    v(0.5em)
    it
    v(0.5em)
  }
  show figure.caption: it => {
    set par(first-line-indent: 0em)
    layout(size => context {
      align(
        // center for single-line, left for multi-line captions
        if measure(it).width < size.width { center } else { left },
        if sys.version >= version(0, 13) {
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
  show "Figure": set text(hyphenate: false)

  // tables
  show figure.where(
    kind: table,
  ): set figure.caption(position: top)

  // equations
  set math.equation(numbering: "(1)")
  show math.equation: it => {
    if it.block and not it.has("label") and it.numbering != none [
      #counter(math.equation).update(v => v - 1)
      #math.equation(it.body, block: true, numbering: none)
    ] else {
      it
    }
  }

  // references
  set ref(supplement: it => {
    if it.func() == figure and it.kind == image {
      "Fig."
    } else if it.func() == math.equation {
      "Eq."
    } else {
      it.supplement
    }
  })

  // bibliography
  set bibliography(title: none, style: "jacow.csl")
  show bibliography: it => {
    // marker to check for page limit
    [#block(height: 0pt, above: 0pt, below: 0pt)<content-end>]

    heading(bibliography-title)
    set text(9pt)
    set par(spacing: 9pt)
    show grid.cell.where(x: 0): set align(right)

    show regex("\b(https?://\S+|10(\.\d+)+/\S+)"): it => {
      let is-doi = it.text.starts-with("10")
      let it = if is-doi [doi:#it] else { it }
      let link = text(
        font: "DejaVu Sans Mono",
        size: 7.2pt,
        hyphenate: false,
        it,
      )

      if is-doi {
        // Avoid breaking DOI: Put in same line if it fits, otherwise force into new line
        let link-on-new-line = state("link-on-new-line", false)
        box(width: 1fr, layout(it => {
          let fits-in-same-line = measure(link).width < it.width
          link-on-new-line.update(it => not fits-in-same-line)
          if fits-in-same-line { link }
        }))
        context if link-on-new-line.get() {
          linebreak()
          link
        }
      } else {
        // URL
        link
        if it.text.ends-with("/") [.]
      }
    }
    // JACoW demands URLs not to be clickable, only DOIs
    // This could be done with the following show rule, however we will not do so,
    // becaue modern PDF readers will recognize the https:// and make it clickable anyways,
    // but most of them will fail to do it properly when the link text spanns multiple lines.
    // So this effectively just breaks the link for the user, not remove it. We can do better!
    //show link: it => {if (it.body.text.match(regex("http.*")) == none) {it} else {it.body.text}}
    it
  }


  // abstract
  if abstract != none [
    == #abstract-title
    #abstract
  ]


  // content
  body
}



/// Table in jacow style
///
/// - spec (str): Column alignment specification string such as "ccr"
/// - header (alignment, none): header location (top and/or bottom) or none
/// - contents: table contents
/// -> table
#let jacow-table(spec, header: top, ..contents) = {
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


