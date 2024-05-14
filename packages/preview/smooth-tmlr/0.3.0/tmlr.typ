#let std-bibliography = bibliography

// We prefer to use CMU Bright variant instead of Computer Modern Bright when
// ever it is possible.
#let font-family = ("CMU Serif", "Latin Modern Roman", "New Computer Modern",
                    "Serif")
#let font-family-sans = ("CMU Sans Serif", "Latin Modern Sans",
                         "New Computer Modern Sans", "Sans")
#let font-family-mono = ("Latin Modern Mono", "New Computer Modern Mono",
                         "Mono")

#let font = (
  Large: 17pt,
  footnote: 10pt,
  large: 12pt,
  normal: 10pt,
  script: 8pt,
  small: 9pt,
)

#let affl-keys = ("department", "institution", "location", "country")

#let header(accepted, pubdate) = {
  if accepted == none {
    return ""
  } else if accepted {
    return (
      "Published in Transactions on Machine Learning Research (",
      pubdate.display("[month]/[year]"), ")",
    ).join()
  } else {
    return "Under review as submission to TMLR"
  }
}

#let make-author(author, affls) = {
  let author-affls = if type(author.affl) == array {
    author.affl
  } else {
    (author.affl, )
  }

  let lines = author-affls.map(key => {
    let affl = affls.at(key)
    return affl-keys
      .map(key => affl.at(key, default: none))
      .filter(it => it != none)
      .join("\n")
  }).map(it => emph(it))

  return block(spacing: 0em, {
    set par(justify: true, leading: 0.50em)  // Visually perfect.
    show par: set block(spacing: 0em)
    text(size: font.normal)[*#author.name*\ ]
    text(size: font.small)[#lines.join([\ ])]
  })
}

#let make-email(author) = {
  let label = text(size: font.small, emph(author.email))
  return block(spacing: 0em, {
    // Compensate difference between name and email font sizes (10pt vs 9pt).
    v(1pt)
    link("mailto:" + author.email, label)
  })
}

#let make-authors(authors, affls) = {
  let cells = authors
    .map(it => (make-author(it, affls), make-email(it)))
    .join()
  return grid(
    columns: (2fr, 1fr),
    align: (left + top, right + top),
    row-gutter: 15.8pt,  // Visually perfect.
    ..cells)
}

#let make-title(title, authors, abstract, review, accepted) = {
  // Render title.
  v(-0.03in)  // Visually perfect.
  block(spacing: 0em, {
    set block(spacing: 0em)
    set par(leading: 10pt)  // Empirically found.
    text(font: font-family-sans, size: font.Large, weight: "bold", title)
  })

  // Render authors if paper is accepted or not accepted or ther is no
  // acceptance status (aka preprint).
  if accepted == none {
    v(31pt, weak: true)  // Visually perfect.
    make-authors(..authors)
    v(-2pt)  // Visually perfect.
  } else if accepted {
    v(31pt, weak: true)  // Visually perfect.
    make-authors(..authors)
    v(14.9pt, weak: true)  // Visually perfect.
    let label = text(font: font-family-mono, weight: "bold", emph(review))
    [*Reviewed on OpenReview:* #link(review, label)]
  } else {
    v(0.3in + 0.2in - 3.5pt, weak: true)
    block(spacing: 0em, {
      [*Anonymous authors*\ ]
      [*Paper under double-blind review*]
    })
  }
  v(0.45in, weak: true)  // Visually perfect.

  // Render abstract.
  block(spacing: 0em, width: 100%, {
    set text(size: font.normal)
    set par(leading: 0.51em)  // Original 0.55em (or 0.45em?).

    // While all content is serif, headers and titles are sans serif.
    align(center,
      text(
        font: font-family-sans,
        size: font.large,
        weight: "bold",
        [*Abstract*]))
    v(22.2pt, weak: true)
    pad(left: 0.5in, right: 0.5in, abstract)
  })
  v(29.5pt, weak: true)  // Visually perfect.
}

/**
 * tmlr
 *
 * Args:
 *   title: Paper title.
 *   authors: Tuple of author objects and affilation dictionary.
 *   keywords: Publication keywords (used in PDF metadata).
 *   date: Creation date (used in PDF metadata).
 *   abstract: Paper abstract.
 *   bibliography: Bibliography content. If it is not specified then there is
 *   not reference section.
 *   appendix: Content to append after bibliography section.
 *   accepted: Valid values are `none`, `false`, and `true`. Missing value
 *   (`none`) is designed to prepare arxiv publication. Default is `false`.
 *   review: Hypertext link to review on OpenReview.
 *   pubdate: Date of publication (used only month and date).
 */
#let tmlr(
  title: [],
  authors: (),
  keywords: (),
  date: auto,
  abstract: none,
  bibliography: none,
  appendix: none,
  accepted: false,
  review: none,
  pubdate: none,
  body,
) = {
  if pubdate == none {
    pubdate = if date != auto and data != none {
      date
    } else {
      datetime.today()
    }
  }

  // Prepare authors for PDF metadata.
  let author = if accepted == none or accepted {
    authors.at(0).map(it => it.name)
  } else {
    ()
  }

  set document(
    title: title,
    author: author,
    keywords: keywords,
    date: date)

  set page(
    paper: "us-letter",
    margin: (left: 1in,
             right: 8.5in - (1in + 6.5in),
             // top: 1in - 0.25in,
             // bottom: 11in - (1in + 9in + 0.25in)),
             top: 1.18in,
             bottom: 11in - (1.18in + 9in)),
    header-ascent: 46pt,  // 1.5em in case of 10pt font
    header: locate(loc => block(spacing: 0em, {
      header(accepted, pubdate)
      v(3.5pt, weak: true)
      line(length: 100%, stroke: (thickness: 0.4pt))
    })),
    footer-descent: 20pt, // Visually perfect.
    footer: locate(loc => {
      let ix = counter(page).at(loc).first()
      return align(center, text(size: font.normal, [#ix]))
    }))

  // The original style requirements is to use Computer Modern Bright but we
  // just use OpenType CMU Bright font.
  set text(font: font-family, size: font.normal)
  set par(justify: true, leading: 0.52em)  // TODO: Why? Visually perfect.
  show par: set block(spacing: 1.1em)

  // Configure heading appearence and numbering.
  set heading(numbering: "1.1")
  show heading: set text(font: font-family-sans)
  show heading: it => {
    // Create the heading numbering.
    let number = if it.numbering != none {
      counter(heading).display(it.numbering)
    }

    // Render section with such names without numbering as level 3 heading.
    let unnumbered = (
      [Broader Impact Statement],
      [Author Contributions],
      [Acknowledgments],
    )
    let level = it.level
    let prefix = [#number ]
    if unnumbered.any(name => name == it.body) {
      level = 3
      prefix = []
    }

    // TODO(@daskol): Use styles + measure to estimate ex.
    set align(left)
    if level == 1 {
      text(size: font.large, weight: "bold", {
        let ex = 10pt
        v(2.05 * ex, weak: true)  // Visually perfect.
        [#prefix*#it.body*]
        v(1.80 * ex, weak: true) // Visually perfect.
      })
    } else if level == 2 {
      text(size: font.normal, weight: "bold", {
        let ex = 6.78pt
        v(2.8 * ex, weak: true)  // Visually perfect.
        [#prefix*#it.body*]
        v(2.15 * ex, weak: true)  // Visually perfect. Original 1ex.
      })
    } else if level == 3 {
      text(size: font.normal, weight: "bold", {
        let ex = 6.78pt
        v(2.7 * ex, weak: true)  // Visually perfect.
        [#prefix*#it.body*]
        v(2.0 * ex, weak: true)  // Visually perfect. Original -0.7em.
      })
    }
  }

  // Configure code blocks (listings).
  show raw: set block(spacing: 1.95em)

  // Configure footnote (almost default).
  show footnote.entry: set text(size: 8pt)
  set footnote.entry(
    separator: line(length: 2in, stroke: 0.35pt),
    clearance: 6.65pt,
    gap: 0.40em,
    indent: 12pt)  // Original 12pt.

  // Configure figures.
  show figure.where(kind: image): set figure.caption(position: bottom)
  set figure(gap: 16pt)

  // Configure tables.
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: table): set figure(gap: 6pt)
  set table(inset: 4pt)

  // Configure numbered lists.
  set enum(indent: 2.4em, spacing: 1.3em)
  show enum: set block(above: 2em)

  // Configure bullet lists.
  set list(indent: 2.4em, spacing: 1.3em, marker: ([•], [‣], [⁃]))
  show list: set block(above: 2em)

  // Configure math numbering and referencing.
  set math.equation(numbering: "(1)", supplement: [])
  show ref: it => {
    let eq = math.equation
    let el = it.element
    if el != none and el.func() == eq {
      let numb = numbering(
        "1",
        ..counter(eq).at(el.location())
      )
      let color = rgb(0%, 8%, 45%)  // Originally `mydarkblue`. :D
      let content = link(el.location(), text(fill: color, numb))
      [(#content)]
    } else {
      it
    }
  }

  // Render title + authors + abstract.
  make-title(title, authors, abstract, review, accepted)
  // Render body as is.
  body

  if bibliography != none {
    set std-bibliography(title: [References], style: "tmlr.csl")
    bibliography
  }

  if appendix != none {
    set heading(numbering: "A.1")
    counter(heading).update(0)
    appendix
  }
}
