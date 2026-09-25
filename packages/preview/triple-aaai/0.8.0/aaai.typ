/**
 * aaai.typ
 *
 * Template for The Association for the Advancement of Artificial Intelligence
 * (AAAI) conference.
 *
 * [1]: https://aaai.org/
 */

// Times, Helvetica, and Courier, including metric-compatible substitutes.
#let font-family = ("Times New Roman", "Nimbus Roman", "Liberation Serif")
#let font-family-sans = ("Nimbus Sans", "Liberation Sans")
#let font-family-mono = ("Courier New", "Nimbus Mono PS", "Liberation Mono")

#let font = (
  LARGE: 14.5pt,
  Large: 12pt,
  footnote: 9pt,
  large: 11pt,
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
      if size in aux.font-size {
        fc.size.insert(size, aux.font-size.at(size))
      }
    }
  }

  return fc
}

#let affl-keys = ("department", "institution", "location", "country")

#let author-affiliations(author) = {
  let affl = author.at("affl", default: ())
  if type(affl) == array {
    affl
  } else {
    (affl,)
  }
}

#let make-author(author, affls, fc: none) = {
  let fc = font-config-ensure(fc)
  set text(size: fc.size.Large)
  strong(author.name)
  if affls.len() > 1 {
    super(author-affiliations(author).map(key => {
      str(affls.keys().position(it => it == key) + 1)
    }).join(","))
  }
}

#let make-email(author, fc: none) = {
  let fc = font-config-ensure(fc)
  let email = author.at("email", default: none)
  if email != none and email != "" {
    text(size: fc.size.small, email)
  }
}

#let make-authors(authors, affls, fc: none) = {
  let fc = font-config-ensure(fc)
  let keys = authors.map(author-affiliations).flatten().dedup()
  let used-affls = (:)
  for key in keys {
    used-affls.insert(key, affls.at(key))
  }
  let affls = used-affls

  block(width: 100%, spacing: 0pt, {
    set align(center)
    set par(justify: false, leading: 3pt, spacing: 0pt)
    authors.map(it => make-author(it, affls, fc: fc)).join(", ")

    v(2pt)
    set text(size: fc.size.small)
    let lines = affls.values().enumerate().map(((index, affl)) => {
      let fields = affl-keys.map(key => affl.at(key, default: none))
        .filter(it => it != none)
      if affls.len() > 1 {
        super(str(index + 1)) + fields.join(", ")
      } else {
        fields.join(linebreak())
      }
    })
    lines.join(linebreak())

    let emails = authors.map(it => make-email(it, fc: fc))
      .filter(it => it != none).dedup()
    if emails.len() > 0 {
      linebreak()
      emails.join(", ")
    }
  })
}

#let make-title-block(title, authors, accepted, fc: none) = {
  let fc = font-config-ensure(fc)
  set align(center)

  // Render title.
  v(1.25cm)
  block(spacing: 0em, {
    set text(font: fc.family.serif, size: fc.size.LARGE)
    set par(leading: 0.15em, spacing: 0em)
    strong(title)
  })

  // Show authors for camera-ready papers and preprints.
  v(14pt)
  if accepted == none or accepted {
    make-authors(..authors, fc: fc)
  } else {
    block(spacing: 0em, {
      set text(size: fc.size.Large)
      [*Anonymous submission*]
    })
  }

  v(0.5in)
}

#let h1(fc: none, body) = align(center, {
  set text(size: fc.size.Large, weight: "bold")
  set par(justify: false, leading: 0.53cm - 1em)
  let leading = 0.53cm - 1em
  v(0.64cm + leading)
  body
  v(0.21cm + leading)
})

#let h2(fc: none, body) = align(left, {
  set text(size: fc.size.large, weight: "bold")
  set par(justify: false, leading: 0.46cm - 1em)
  let leading = 0.46cm - 1em
  v(0.42cm + leading)
  body
  v(0.11cm + leading)
})

#let h3(fc: none, body) = {
  let fc = font-config-ensure(fc)
  v(6pt, weak: true)
  // Start a new paragraph sequence so run-in headings do not inherit its indent.
  block(height: 0pt, spacing: 0pt, sticky: true)[]
  text(size: fc.size.normal, weight: "bold", body)
  h(1em, weak: true)
}

#let abstract-header(fc: none, body) = align(center, {
  set text(size: fc.size.normal, weight: "bold")
  set par(justify: false, leading: 0.42cm - 1em, spacing: 0pt)
  body
  v(0.11cm)
})

#let abstract-text(fc: none, body) = align(center, {
  set text(size: fc.size.small)
  set par(leading: 0.35cm - 1em, spacing: 0.35cm - 1em)
  pad(left: 0.35cm, right: 0.35cm, body)
})

#let make-abstract(abstract, fc: none) = {
  let fc = font-config-ensure(fc)

  block(spacing: 0em, width: 100%, {
    abstract-header(fc: fc)[Abstract]
    abstract-text(fc: fc, abstract)
  })
}

#let make-title(title, authors, accepted, fc: none) = place(
  top,
  block(width: 100%, {
    make-title-block(title, authors, accepted, fc: fc)
  }),
  scope: "parent",
  float: true,
)

/**
 * Show rule for appendix styling. Use `#show: appendix` before its headings.
 * References supplied to `aaai` remain after the appendix.
 */
#let appendix(body) = context {
  set heading(numbering: if heading.numbering == none { none } else { "A.1" })
  counter(heading).update(0)
  body
}

// Compatibility with documents importing the previous show-rule name.
#let default-appendix = appendix

/**
 * Show-rule for bibliography.
 */
#let default-bibliography(fc: none, body) = {
  let fc = font-config-ensure(fc)
  set text(size: fc.size.small)
  set par(
    justify: true,
    first-line-indent: 0em,
    leading: 0.35cm - 1em,
    spacing: 0.11cm + (0.35cm - 1em))
  set std.bibliography(title: [References], style: "aaai.csl")
  body
}

// A first-column float reserves space inside the text area for the notice.
#let make-copyright(pubdate, fc: none) = {
  let fc = font-config-ensure(fc)
  place(bottom, float: true, clearance: 6.65pt, block(width: 100%, {
    set text(size: fc.size.footnote)
    set par(justify: true, first-line-indent: 0pt, leading: 1pt)
    line(length: 2in, stroke: 0.5pt)
    v(4pt)
    [Copyright © #pubdate.display("[year]"), Association for the Advancement
    of Artificial Intelligence (www.aaai.org). All rights reserved.]
  }))
}

/**
 * aaai
 *
 * Args:
 *   title: Paper title.
 *   authors: Tuple of author objects and affilation dictionary.
 *   keywords: Publication keywords (used in PDF metadata).
 *   date: Creation date (used in PDF metadata).
 *   abstract: Paper abstract.
 *   bibliography: Bibliography content. If it is not specified then there is
 *   not reference section.
 *   appendix: Content to append before the bibliography section.
 *   accepted: Valid values are `none`, `false`, and `true`. Missing value
 *   (`none`) is designed to prepare arxiv publication. Default is `false`.
 *   review: Retained for compatibility; AAAI does not print a review banner.
 *   pubdate: Publication date (used for the copyright year).
 *   numbering: Heading numbering pattern, or `none` for unnumbered sections.
 */
#let aaai(
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
  numbering: "1.1",
  aux: (:),
  body,
) = {
  if pubdate == none {
    pubdate = if date != auto and date != none {
      date
    } else {
      datetime.today()
    }
  }

  if authors.len() == 0 {
    authors = ((), (:))
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

  set document(title: title, author: author, keywords: keywords, date: date)
  set page(
    paper: "us-letter",
    columns: 2,
    margin: (left: 0.75in, right: 0.75in, top: 0.75in, bottom: 1.25in))

  set columns(gutter: 0.375in)

  set text(
    font: fc.family.serif,
    size: fc.size.normal,
    top-edge: 1em,
    bottom-edge: 0em)
  let leading = 0.42cm - 1em
  set par(
    justify: true,
    first-line-indent: 1em,
    leading: leading,
    spacing: leading)

  // Preserve heading counters and render every heading level.
  set heading(numbering: numbering)
  show heading: set text(font: fc.family.serif)

  let unnumbered = heading.where(level: 1, body: [Ethical Statement])
    .or(heading.where(level: 1, body: [Acknowledgments]))
    .or(heading.where(level: 1, body: [Acknowledgements]))
    .or(heading.where(level: 1, body: [Broader Impact Statement]))
    .or(heading.where(level: 1, body: [Author Contributions]))
  show unnumbered: set heading(numbering: none)

  show heading: it => context {
    let body = if it.numbering == none {
      it.body
    } else {
      counter(heading).display(it.numbering) + h(0.5em) + it.body
    }
    if it.level >= 3 {
      h3(fc: fc, body)
    } else {
      block(width: 100%, spacing: 0pt, {
        if it.level == 1 {
          h1(fc: fc, body)
        } else {
          h2(fc: fc, body)
        }
      })
    }
  }

  // Configure code blocks (listings).
  show raw: set text(font: fc.family.mono)
  show raw.where(block: true): set block(spacing: 12pt)

  // Configure footnote (almost default).
  show footnote.entry: set text(size: fc.size.footnote)
  show footnote.entry: set par(leading: 1pt, spacing: 0pt)
  set footnote.entry(
    separator: line(length: 2in, stroke: 0.5pt),
    clearance: 6.65pt,
    gap: 0.40em,
    indent: 12pt)

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
  show figure.where(kind: table): set figure.caption(position: bottom)
  show figure.where(kind: table): set figure(gap: 6pt)
  set table(inset: 4pt)

  // Configure numbered lists.
  set enum(indent: 0.5em, spacing: 2 * leading)
  show enum: it => {
    set block(above: leading * 0.8, below: leading)
    set par(leading: leading * 0.4)
    it
  }

  // Configure bullet lists.
  set list(indent: 0.5em, spacing: 2 * leading, marker: ([•], [‣], [⁃]))
  show list: it => {
    set block(above: leading * 0.8, below: leading)
    set par(leading: leading * 0.4)
    it
  }

  // Configure math numbering and referencing.
  set math.equation(numbering: "(1)", supplement: [])
  show ref: it => {
    let eq = math.equation
    let el = it.element
    if el != none and el.func() == eq {
      let numb = std.numbering(
        "1",
        ..counter(eq).at(el.location())
      )
      let content = link(el.location(), numb)
      [(#content)]
    } else {
      it
    }
  }

  // Render title + authors + abstract.
  make-title(title, authors, accepted, fc: fc)
  if accepted == true {
    make-copyright(pubdate, fc: fc)
  }
  if abstract != none {
    make-abstract(abstract, fc: fc)
  }

  // Render body as is.
  body

  if appendix != none {
    show: default-appendix
    appendix
  }

  if bibliography != none {
    show: default-bibliography.with(fc: fc)
    bibliography
  }
}

// Compatibility with documents importing the original year-specific name.
#let aaai2026 = aaai
