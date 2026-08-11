/**
 * rlj.typ
 *
 * Reinforcement Learning Journal/Conference (RLJ/RLC) template.
 */

#let font-face = (
  serif: ("Times New Roman", "Libertinus Serif"),
)

#let dark-blue = rgb(0, 0, 70%)
#let cite-color = dark-blue

#let font-size = (
  footnote: 8.0pt,
  small: 9.0pt,
  normal: 10.0pt,
  large: 12.0pt,
  Large: 14.4pt,
  LARGE: 17.28pt,
  Huge: 20.74pt,
  HUGE: 24.88pt,
)

#let h1(body) = {
  set text(size: font-size.large, weight: "bold")
  context {
    let shape = measure({
      text(
        size: font-size.normal,
        weight: "bold",
        top-edge: "bounds",
        bottom-edge: "baseline",
      )[x]
    })
    let ex = shape.height  // ex = 4.57pt

    let spacing = 9pt
    let above = 2.0 * ex + spacing

    let spacing = 6pt
    let below = 1.5 * ex + spacing

    block(above: above, below: below, body)
  }
}

#let h2(body) = {
  set text(size: font-size.normal, weight: "bold")
  context {
    let shape = measure(text(top-edge: "bounds", bottom-edge: "baseline")[x])
    let shape = measure({
      text(
        size: font-size.normal,
        weight: "regular",
        top-edge: "bounds",
        bottom-edge: "baseline",
      )[x]
    })
    let ex = shape.height  // ex = 4.47pt

    let spacing = 7pt
    let above = 1.8 * ex + spacing

    let spacing = 7pt
    let below = 0.8 * ex + spacing

    block(above: above, below: below, body)
  }
}

#let h3(body) = {
  let spacing = 6pt
  set text(size: font-size.normal, weight: "regular")
  context {
    let shape = measure(text(top-edge: "bounds", bottom-edge: "baseline")[x])
    let ex = shape.height // ex = 4.47pt
    let above = 1.8 * ex + spacing
    let below = 0.5 * ex + spacing + 1pt
    block(above: above, below: below, {
      set text(size: font-size.normal, weight: "bold")
      body
    })
  }
}

#let h4(body) = {
  set text(size: font-size.normal, weight: "regular")
  let spacing = 7pt
  let above = spacing + 5pt
  let below = spacing
  block(above: above, below: below, body)
}

#let appendix(body) = {
  counter(heading).update(0)
  set heading(numbering: "A.1")
  body
}

#let appendix-rule = appendix

#let summary-box(title: [Summary], body) = {
  set par(first-line-indent: 1em)
  let inset = (x: 12pt, top: 9.3pt, bottom: 12pt)
  block(width: 100%, above: 0pt, below: 0pt, inset: inset, radius: 2mm, fill: rgb("#f1f4f7"), {
    align(center, {
      set text(size: font-size.Large, weight: "bold")
      title
    })
    v(0.025in + 4pt)
    body
  })
}

#let contrib-box(contribs) = {
  show: summary-box.with(title: [Contribution(s)])
  let items = contribs.map(it => {
    it.contribution
    let caveat = it.at("caveat", default: [None])
    [\ *Context:* #caveat]
  })
  v(-4pt)
  enum(tight: false, spacing: 5pt, ..items)
}

#let make-cover(
  title, authors, keywords, summary, contribs, accepted: false,
) = {
  v(2pt)
  block(width: 100%, below: 0pt, {
    set align(center)
    set text(size: font-size.LARGE, top-edge: 11pt)
    strong(title)
  })
  v(12.7pt)
  block(width: 100%, below: 0pt, {
    set align(center)
    if accepted != none and not accepted {
      set text(size: font-size.large, top-edge: 11pt)
      [*Anonymous authors*\ Paper under double-blind review]
    } else {
      v(-2pt)  // Unclear why.
      set text(size: font-size.large, top-edge: 11pt)
      authors.map(it => [*#it.name*]).join([, ])
    }
  })
  v(11pt)
  block(width: 100%, below: 0pt, {
    set align(center)
    [*Keywords:* ] + keywords.join([, ])
  })
  v(22pt)

  summary-box(summary)
  v(20pt)
  contrib-box(contribs)
  pagebreak()
}

#let make-abstract(abstract) = context {
  set text(size: font-size.normal, weight: "regular")
  let shape = measure(text(top-edge: "bounds", bottom-edge: "baseline")[x])
  let ex = shape.height  // ex = 4.47pt

  // TODO
  // block(above: 0.05in, below: ex + 18pt, {
  block(above: 0.05in, below: 0pt, {
    align(center, {
      set text(size: font-size.large, weight: "bold")
      [Abstract]
    })
    // Default spacing before and after `quote` in LaTeX is 10pt.
    pad(x: 0.5in, top: 10pt - 1.5 * ex + 1.7pt, bottom: 10pt, abstract)
  })
}

#let groupby(arr, key-fn: x => x) = {
  return arr.fold((:), (acc, it) => {
    let key = key-fn(it)
    let values = acc.at(key, default: ())
    values.push(it)
    acc.insert(key, values)
    return acc
  })
}

#let index-affilations(authors, affls) = {
  // Normalize `affl` field of author dictionary.
  let flat-affls = authors.map(it => it.affl).flatten().dedup()

  // Assign an index to each distinct affilation.
  let uniq-affls = flat-affls.filter(it => {
    if it not in affls {
      return false
    }
    let affl = affls.at(it)
    return "comment" not in affl
  })
  let affl2index = uniq-affls.enumerate(start: 1).fold((:), (acc, it) => {
    let (ix, affl) = it
    acc.insert(affl, ix)
    return acc
  })

  // Assign an index to each distinct comment.
  let uniq-affls = flat-affls.filter(it => {
    if it not in affls {
      return false
    }
    let affl = affls.at(it)
    return "comment" in affl
  })
  let comment2index = uniq-affls.enumerate(start: 1).fold((:), (acc, it) => {
    let (ix, affl) = it
    acc.insert(affl, ix)
    return acc
  })

  return (affl: affl2index, comment: comment2index)
}

#let make-affilation(affl) = {
  if type(affl) == str {
    return affl
  } else if type(affl) == array {
    return affl.join([, ])
  }

  let parts = ()
  if "department" in affl {
    parts.push(affl.department)
  }
  if "institution" in affl {
    parts.push(affl.institution)
  }
  if "location" in affl {
    parts.push(affl.location)
  }
  if "country" in affl {
    parts.push(affl.country)
  }
  return parts.join([, ])
}

#let make-affilations(authors, affls) = {
}

#let make-emails(authors) = {
  let emails = authors
    .filter(it => "email" in it)
    .map(it => it.email)

  let get-domain(email) = {
    return email.split("@").last()
  }

  let domain2email = groupby(emails, key-fn: get-domain)
  let compressed-emails = domain2email.pairs().map(pair => {
    let (domain, emails) = pair
    if emails.len() > 1 {
      let names = emails.map(it => it.trim("@" + domain, at: end)).join(",")
      return "{" + names + "}@" + domain
    } else {
      return emails.first()
    }
  })

  return compressed-emails.map(it => if it.starts-with("{") {
    return raw(it)
  } else {
    return link(it, raw(it))
  }).join([, ])
}

#let make-authors(authors, affls) = {
  // Normalize `affl` field of author dictionary.
  let authors = authors.map(it => if "affl" not in it {
    it.affl = ()
    return it
  } else if type(it.affl) == array {
    return it
  } else {
    it.affl = (it.affl, )
    return it
  })

  // Map affilations and comments to ordinals.
  let index = index-affilations(authors, affls)

  set text(size: font-size.large, weight: "regular")
  let names = authors.map(it => {
    let affls = it.affl
      .map(it => index.affl.at(it, default: none))
      .filter(it => it != none)
      .map(it => numbering("1", it))
    let comments = it.affl
      .map(it => index.comment.at(it, default: none))
      .filter(it => it != none)
      .map(it => numbering("*", it))
    let indices = affls + comments
    box(strong(it.name) + super(indices.join(",")))
  })
  v(4pt)
  names.join([, ])
  v(-2pt)

  set text(size: font-size.normal, weight: "regular")
  let emails = make-emails(authors)
  emails

  set text(size: font-size.normal, weight: "regular")
  let affilations = index.affl.pairs().map(it => {
    let (tag, ix) = it
    let affl = affls.at(tag, default: none)
    if affl == none {
      return none
    }
    super[#ix] + h(0.02em) + strong(make-affilation(affl))
  })
  v(8.5pt)
  affilations.join([\ ])

  set text(size: font-size.normal, weight: "regular")
  let comments = index.comment.pairs().map(it => {
    let (tag, ix) = it
    let affl = affls.at(tag, default: none)
    if affl == none {
      return none
    }
    super(numbering("*",ix)) + h(0.02em) + affl.comment
  })
  v(1.9pt)
  comments.join([\ ])
}

#let make-title(title, authors, affls, abstract, accepted: false) = {
  v(0.15in)  // Fixed.
  block(above: 0pt, below: 0pt, {
    align(center, {
      set text(size: font-size.LARGE, weight: "bold", top-edge: 19pt)
      title
    })
    if accepted == none or accepted {
      v(0.2in)
      make-authors(authors, affls)
      v(-9.5pt)
    } else {
      v(0.25in + 2pt)
      [*Anonymous authors*\ Paper under double-blind review\ ]
    }
  })
  v(0.3in + 12.5pt)

  make-abstract(abstract)
}

#let make-supplementary(supplementary) = {
  block(width: 100%, {
    set align(center)
    text(size: font-size.LARGE, top-edge: 12.28pt)[*Supplementary Materials*]
    v(-0.5pt)
    emph[The following content was not necessarily subject to peer review.]
    v(4pt)
    line(length: 100%, stroke: 0.4pt)
    v(1.9pt)
  })
  supplementary
}

/**
 * rlj - Template for Reinforcement Learning Journal (and Conference).
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
 *   aux: Dictionary of auxiliary options. For example, `lineno` boolean key
 *   forces line numbering.
 */
#let rlj(
  title: [],
  authors: (),
  keywords: (),
  date: auto,
  abstract: [],
  bibliography: none,
  appendix: none,
  accepted: false,
  summary: [],
  contributions: (),
  running-title: none,
  supplementary: none,
  aux: (:),
  body,
) = {
  // Deconstruct authors for convenience.
  let (authors, affls) = if authors.len() == 2 {
    authors
  } else {
    ((), ())
  }
  if accepted != none and not accepted {
    authors = ((name: "Anonymous Author"), )
  }
  set document(
    title: title,
    author: authors.map(it => it.name),
    keywords: keywords,
    date: date)

  let running-title = if accepted == none or running-title == none {
    []
  } else {
    running-title
  }

  let running-title-notice = if accepted == none {
    []
  } else if accepted {
    [Reinforcement Learning Journal #h(1fr) 2025]
  } else {
    [Under review for RLC 2025, to be published in RLJ 2025]
  }
  let running-title-notice-cover = if accepted == none {
    []
  } else if accepted {
    [Reinforcement Learning Journal 2025]
  } else {
    running-title-notice
  }

  set page(
    paper: "us-letter",
    margin: (
      left: 1.5in, right: 8.5in - 1.5in - 5.5in,
      top: 1in, bottom: 11in - 1in - 9in),
    footer: context {
      set align(center + top)
      let ix = counter(page).get().first()
      if ix > 1 {
        ix - 1
      }
    },
    footer-descent: 30pt + 1pt,
    header: {
      set par(spacing: 0pt)
      set align(left)
      text(top-edge: "ascender", bottom-edge: "descender", context {
        let ix = counter(page).get().first()
        if ix == 1 {
          grid(
            columns: (1fr, auto),
            running-title-notice-cover,
            grid.vline(stroke: 0.35pt),
            grid.cell(inset: (y: 1pt), h(0.4em) + [*Cover Page*]))
        } else if calc.even(ix) {
          running-title
          v(1pt)
        } else {
          running-title-notice
          v(1pt)
        }
      })
      line(length: 100%, stroke: 0.35pt)
    },
    header-ascent: 24pt - 0.35pt / 2,
  )

  set text(size: 10pt, font: font-face.serif, top-edge: 11pt)
  set par(justify: true, leading: 1pt, spacing: 5pt)

  let lineno(accepted, aux, body) = {
    let skip = if "lineno" in aux {
      not aux.lineno
    } else {
      accepted == none or accepted
    }
    if skip {
      body
    } else {
      set par.line(
        numbering: n => text(fill: gray, [#n]),
        number-clearance: 11pt)
      body
    }
  }

  show: lineno.with(accepted, aux)

  // Footnote's `\baselineskip` is 9.5pt.
  set footnote.entry(
    clearance: 9pt,
    indent: 10pt,
    gap: 1.5pt,
    separator: line(length: 2in, stroke: 0.42pt)
  )
  show footnote.entry: it => {
    set text(size: font-size.footnote, top-edge: 8pt)
    set par(justify: true, leading: 1.5pt, spacing: 1.5pt)
    set par.line(numbering: none)
    it
  }

  // Bullet and numbered lists.
  show list.where(tight: false): set list(spacing: 3pt)
  show enum.where(tight: false): set enum(spacing: 3pt)

  // Headings.
  set heading(numbering: "1.1")
  show heading.where(level: 1): h1
  show heading.where(level: 2): h2
  show heading.where(level: 3): h3
  show heading.where(level: 4): h4

  // Set up equations.
  set math.equation(numbering: "(1)")

  // Image figures.
  show figure.where(kind: image): set block(above: 0.3in, below: 0.3in)
  show figure.where(kind: image): set figure(gap: 13.5pt)

  // Table figures.
  show figure.where(kind: table): set block(above: 12pt, below: 20pt)
  show figure.where(kind: table): set figure(gap: 16.7pt)
  show figure.where(kind: table): set figure.caption(position: top)

  // Colorize bibliography citations.
  show cite: it => {
    if it.form == "normal" {
      box({
        [(]
        cite(it.key, form: "author")
        [,~]
        cite(it.key, form: "year")
        [)]
      })
    } else if it.form == "prose" {
      box({
        cite(it.key, form: "author")
        [~(]
        cite(it.key, form: "year")
        [)]
      })
    } else if it.form == "author" or it.form == "year" {
      set text(fill: cite-color)
      it
    } else {
      it
    }
  }

  // Colorize references to equations, figures, tables, etc.
  show ref: it => {
    let el = it.element
    if el != none and el.func() == math.equation {
      let ix = numbering("1", ..counter(math.equation).at(el.location()))
      let body = if it.supplement == auto or it.supplement == [] {
        [(#text(fill: cite-color, ix))]
      } else {
        [#it.supplement~#text(fill: cite-color, ix)]
      }
      link(el.location(), body)
    } else if el != none and el.func() == figure {
      let ix = numbering("1", ..counter(figure.where(kind: el.kind)).at(el.location()))
      let supplement = if it.supplement != auto {
        it.supplement
      } else {
        el.supplement
      }
      let body = [#supplement~#text(fill: cite-color, ix)]
      link(el.location(), body)
    } else {
      it
    }
  }

  make-cover(
    title, authors, keywords, summary, contributions, accepted: accepted)
  make-title(title, authors, affls, abstract, accepted: accepted)
  body

  if appendix != none {
    show: appendix-rule
    appendix
  }

  set std.bibliography(title: [References], style: "rlj.csl")
  if bibliography != none {
    set par(spacing: 10pt)
    bibliography
  }

  if supplementary != none {
    pagebreak(weak: true)
    make-supplementary(supplementary)
  }
}

#let aux-statement(title: [], body) = {
  heading(level: 3, numbering: none, outlined: false, title)
  body
}

#let acknowledgments(body) = aux-statement(title: [Acknowledgments], body)

#let impact-statement(body) = aux-statement(
  title: [Broader Impact Statement], body)

/**
 * Auxiliary function for contribution representation (aka struct/type
 * constructor).
 */
#let contribution(caveat: none, contribution) = (
  caveat: caveat,
  contribution: contribution,
)

/**
 * Auxiliary routine to render links as monospaced text.
 */
#let url(uri) = link(uri, text(fill: cite-color, raw(uri)))
