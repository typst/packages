/**
 * tmlr.typ
 *
 * Template for Transactions on Machine Learning Research (TMLR) journal.
 *
 * [1]: https://jmlr.org/tmlr/
 * [2]: https://jmlr.org/tmlr/author-guide.html
 * [2]: https://github.com/JmlrOrg/tmlr-style-file
 */

// Lists of acceptable fonts.
//
// We prefer to use CMU Bright variant instead of Computer Modern Bright when
// ever it is possible.
#let font-family = ("Latin Modern Roman", "New Computer Modern", "CMU Serif", )
#let font-family-sans = ("Latin Modern Sans", "New Computer Modern Sans",
                         "CMU Sans Serif")
#let font-family-mono = ("Latin Modern Mono", "New Computer Modern Mono")

#let font = (
  Large: 17pt,
  footnote: 10pt,
  large: 12pt,
  normal: 10pt,
  script: 8pt,
  small: 9pt,
)

/**
 * Default font config (FC).
 */
#let font-config-default() = (
  family: (serif: font-family,
           sans: font-family-sans,
           mono: font-family-mono),
  size: font,
)

/**
 * Ensure font config is valid.
 */
#let font-config-ensure(fc) = {
  if fc == none {
    return font-config-default()
  } else if type(fc) == array and fc.len() != 2 {
    return font-config-default()
  } else if type(fc) == dictionary and fc.len() != 2 {
    return font-config-default()
  } else {
    return fc
  }
}

/**
 * Merge auxiliary options to font config structure.
 */
#let font-config-merge(fc, aux) = {
  if "font-family" in aux {
    for kind in ("serif", "sans", "mono") {
      if kind in aux.font-family {
        fc.family.insert(kind, aux.font-family.at(kind))
      }
    }
  }

  if "font-size" in aux {
    // Large, footnote, large, and so on.
    for size in font.keys() {
      if size in aux.font-family {
        fc.family.insert(size, aux.font-family.at(size))
      }
    }
  }

  return fc
}

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

#let make-author(author, affls, fc: none) = {
  let fc = font-config-ensure(fc)

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
    set par(justify: true, leading: 0.50em, spacing: 0em)  // Visually perfect.
    text(size: fc.size.normal)[*#author.name*\ ]
    text(size: fc.size.small)[#lines.join([\ ])]
  })
}

#let make-email(author, fc: none) = {
  let fc = font-config-ensure(fc)
  let label = text(size: fc.size.small, emph(author.email))
  return block(spacing: 0em, {
    // Compensate difference between name and email font sizes (10pt vs 9pt).
    v(1pt)
    link("mailto:" + author.email, label)
  })
}

#let make-authors(authors, affls, fc: none) = {
  let cells = authors
    .map(it => (make-author(it, affls, fc: fc), make-email(it, fc: fc)))
    .join()
  return grid(
    columns: (2fr, 1fr),
    align: (left + top, right + top),
    row-gutter: 15.8pt,  // Visually perfect.
    ..cells)
}

#let make-title(title, authors, abstract, review, accepted, fc: none) = {
  let fc = font-config-ensure(fc)

  // Render title.
  v(-0.04in)  // Visually perfect.
  block(spacing: 0em, {
    set par(leading: 8pt, spacing: 0em)  // Empirically found.
    text(font: fc.family.sans, size: font.Large, weight: "bold", title)
  })

  // Render authors if paper is accepted or not accepted or ther is no
  // acceptance status (aka preprint).
  if accepted == none {
    v(31pt, weak: true)  // Visually perfect.
    make-authors(..authors, fc: fc)
    v(-2pt)  // Visually perfect.
  } else if accepted {
    v(31pt, weak: true)  // Visually perfect.
    make-authors(..authors, fc: fc)
    v(14.9pt, weak: true)  // Visually perfect.
    let label = text(font: fc.family.mono, weight: "bold", emph(review))
    [*Reviewed on OpenReview:* #link(review, label)]
  } else {
    v(0.3in + 0.2in - 3.5pt, weak: true)
    block(spacing: 0em, {
      [*Anonymous authors*\ ]
      [*Paper under double-blind review*]
    })
  }
  v(0.5in, weak: true)  // Visually perfect.

  // Render abstract.
  block(spacing: 0em, width: 100%, {
    set text(size: fc.size.normal)
    set par(leading: 4.5pt, spacing: 0em)  // Original 0.55em (or 0.45em?).

    // While all content is serif, headers and titles are sans serif.
    align(center,
      text(
        font: fc.family.sans,
        size: fc.size.large,
        weight: "bold",
        [*Abstract*]))
    v(22.4pt, weak: true)
    pad(left: 0.5in, right: 0.5in, abstract)
  })
  v(29.5pt, weak: true)  // Visually perfect.
}

/**
 * Show-rule for appendix styling.
 */
#let default-appendix(body) = {
  set heading(numbering: "A.1")
  counter(heading).update(0)
  body
}

/**
 * Show-rule for bibliography.
 */
#let default-bibliography(body) = {
  set std.bibliography(title: [References], style: "tmlr.csl")
  body
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
  aux: (:),
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

  // Prepare font config (FC).
  let fc = font-config-default()
  fc = font-config-merge(fc, aux)

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
    header: context block(spacing: 0em, {
      header(accepted, pubdate)
      v(3.5pt, weak: true)
      line(length: 100%, stroke: (thickness: 0.4pt))
    }),
    footer-descent: 20pt, // Visually perfect.
    footer: context {
      let loc = here()
      let ix = counter(page).at(loc).first()
      return align(center, text(size: fc.size.normal, [#ix]))
    })

  // The original style requirements is to use Computer Modern Bright but we
  // just use OpenType CMU Bright font.
  set text(font: fc.family.serif, size: fc.size.normal)
  set par(justify: true, leading: 5pt, spacing: 11pt)  // Visually perfect.

  // Configure heading appearence and numbering.
  set heading(numbering: "1.1")
  show heading: set text(font: fc.family.sans)
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
      text(size: fc.size.large, weight: "bold", {
        let ex = 10pt
        v(2.1 * ex, weak: true)  // Visually perfect.
        [#prefix*#it.body*]
        v(1.8 * ex, weak: true) // Visually perfect.
      })
    } else if level == 2 {
      text(size: fc.size.normal, weight: "bold", {
        let ex = 6.78pt
        v(2.45 * ex, weak: true)  // Visually perfect.
        [#prefix*#it.body*]
        v(2.15 * ex, weak: true)  // Visually perfect. Original 1ex.
      })
    } else if level == 3 {
      text(size: fc.size.normal, weight: "bold", {
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

  // All captions either centered or aligned to the left (See
  // https://github.com/daskol/typst-templates/issues/6 for details).
  show figure.caption: body => {
    set align(center)
    block(width: auto, {
      set align(start)
      body
    })
  }

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
  make-title(title, authors, abstract, review, accepted, fc: fc)
  // Render body as is.
  body

  if bibliography != none {
    show: default-bibliography
    bibliography
  }

  if appendix != none {
    show: default-appendix
    appendix
  }
}
