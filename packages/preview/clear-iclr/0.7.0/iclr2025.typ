/**
 * iclr2025.typ
 */

#let std-bibliography = bibliography  // Due to argument shadowing.

#let font-family = ("Times New Roman", "CMU Serif", "Latin Modern Roman",
                    "New Computer Modern")

#let font-family-sans = ("Nimbus Sans", "CMU Sans Serif", "Latin Modern Sans",
                         "New Computer Modern Sans")

#let font-family-mono = ("CMU Typewriter Text", "Latin Modern Mono",
                         "New Computer Modern Mono")

#let font-family-link = ("Courier New", "Nimbus Mono PS") + font-family-mono

#let font-size = (
  normal: 10pt,
  small: 9pt,
  footnote: 8pt,
  script: 7pt,
  tiny: 5pt,
  large: 12pt,
  Large: 14.4pt,
  LARGE: 17pt,
  huge: 20pt,
  Huge: 25pt,
)

/*
 * Customized text elements.
 */

 #let default-header-title = (
   [Under review as a conference paper at ICLR 2025],  // blind
   [Published as a conference paper at ICLR 2025],  // accepted
)

#let author-anon = [*Anonymous authors*\ Paper under double-blind review]

/**
 * Ruler definition.
 */

#let lineno = counter("lineno")

#let lineno-fmt(numb, width: 3) = {
    let value = str(numb)
    let prefix-len = width - value.len()
    let prefix = ""
    for _ in range(prefix-len) {
      prefix = prefix + "0"
    }
    return prefix + value
}

#let ruler-color = rgb(70%, 70%, 70%)

#let ruler-style = body => {
  set text(size: 8pt, font: font-family-sans, weight: "bold", fill: ruler-color)
  set par(leading: 6.22pt)
  body
}

#let xruler(side, dx, dy, width, height, offset, num-lines) = {
  let alignment = if side == left {
    right
  } else {
    left
  }

  let numbs = range(0, num-lines).map(ix => {
    let anchor = lineno.step()
    let index = lineno-fmt(offset + ix)
    return [#anchor#index]
  })

  let ruler = block(width: width, height: height, spacing: 0pt, {
    show: ruler-style
    set align(alignment)
    numbs.join([\ ])
  })

  return place(left + top, dx: dx, dy: dy, ruler)
}

#let make-ruler(
  num-lines: 54,
  margin: auto,
  width: auto,
  height: 8.875in,
  gap: 30pt,
) = context {
  let margin = if margin == auto {
    (top: 1in - 0.5pt + 9.5pt, left: 1.75in - 1em, right: 1.75in)  // ICLR 2025 defaults.
  } else {
    margin
  }

  let width = if width == auto {
    (left: margin.left - gap, right: margin.right - gap)
  } else {
    width
  }

  // Only left ruler.
  let dx = 0pt
  let dy = margin.top
  let offset = lineno.get().at(0)
  xruler(left, dx, dy, width.left, height, offset, num-lines)
}

#let ruler = make-ruler()  // Default CVPR 2022 ruler.

#let make-title(title) = {
  align(left, {
    v(0.5pt)
    v(0.3pt)
    set text(size: 17.28pt)
    set par(leading: 8.4pt)
    smallcaps(title)
  })
}

#let make-author-block(authors) = {
  assert(
    "names" in authors,
    message: "Missing mandatory field `names` in author specification.")
  let author_names = authors.names.join([, ], last: [ & ])
  let lines = ([*#author_names*], )
  if "affilation" in authors {
    lines.push(authors.affilation)
  }
  if "address" in authors {
    lines.push(authors.address)
  }
  if "email" in authors {
    lines.push(link(authors.email, raw(authors.email)))
  }
  block(width: 100%, spacing: 0pt, lines.join([\ ]))
}

#let make-authors(authors, accepted) = {
  v(14.7pt)
  if accepted != none and not accepted {
    set par(first-line-indent: 0pt)
    author-anon
  } else {
    // We use *-like footnote markers in author section.
    set footnote(numbering: "*")
    authors
      .map(make-author-block)
      .join(v(22pt, weak: true))
    v(3pt)
    // Thus we should reset footnote counter at the end of authors section.
    counter(footnote).update(0)
  }
  v(27.95pt)
}

#let make-abstract(abstract) = {
  set block(spacing: 0pt)
  v(0.075in, weak: true)
  block(width: 100%, {
    set align(center)
    set text(size: font-size.large)
    smallcaps[Abstract]
  })
  v(16.4pt)
  pad(left: 0.5in, right: 0.5in, {
    set text(size: 10pt)
    set par(leading: 4.35pt)
    abstract
  })
  v(3.8pt, weak: false)
}

/**
 * Utility routine to convert authors (array of content) to authors (array of
 * strings).
 *
 * https://github.com/jgm/pandoc/blob/0e92d9483ce55ca2dc3a7a2d12897ac0e25f4dbd/test/writer.typst
 */
#let content-to-string(content) = {
  if content.has("text") {
    content.text
  } else if content.has("children") {
    content.children.map(content-to-string).at(0)
  } else if content.has("body") {
    content-to-string(content.body)
  } else if content == [ ] {
    " "
  }
}

/**
 * iclr2025 - Template for International Conference on Learning Representations
 * (ICLR) 2025.
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
 *   aux: Auxiliary parameters to tune font settings (e.g. font familty) or
 *   page decorations (e.g. page header).
 *   id: Submission identifier.
 */
#let iclr2025(
  title: [],
  authors: (),
  keywords: (),
  date: auto,
  abstract: [],
  bibliography: none,
  appendix: none,
  accepted: false,
  aux: (:),
  id: none,
  body,
) = {
  // Override defaults if needed.
  let header-title = aux.at("header-title", default: default-header-title)
  let font_ = aux.at("font", default: (family: font-family))

  let meta-authors = if accepted == none or accepted {
    authors.map(it => it.names.map(content-to-string)).join()
  } else {
    ()
  }
  set document(
    title: title,
    author: meta-authors,
    keywords: keywords,
    date: date)

  set page(
    paper: "us-letter",
    margin: (left: 1.5in, right: 1.5in, top: 1in + 9.5pt, bottom: 1in - 9.5pt),
    background: if accepted != none and not accepted {
      ruler  // Rullers on sides.
    },
    header-ascent: 32.9pt + 9.5pt,
    header: {
      set block(spacing: 3.7pt)
      set text(size: font-size.normal)
      set align(left)
      let header-text = if accepted == none {
        []
      } else if not accepted {
        header-title.at(0)
      } else if  accepted {
        header-title.at(1)
      }
      block(header-text)
      line(length: 100%, stroke: 0.4pt)
    },
    footer-descent: 23.5pt, // Visually perfect.
    footer: context {
      let ix = counter(page).at(here()).first()
      return align(center, text(size: font-size.normal, [#ix]))
    },
  )

  // \topsep + \parskip + \partopsep
  set text(font: font_.family, size: font-size.normal)
  set par(justify: true, leading: 4.3pt, spacing: 10pt)

  show raw: set text(font: font-family-mono, size: font-size.normal)

  // Configure heading appearence and numbering.
  set heading(numbering: "1.1")
  show heading: set text(font: font_.family, weight: "regular")
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
      level = 2
      prefix = []
    }

    // TODO(@daskol): Use styles + measure to estimate ex.
    set align(left)
    let gap = h(1em, weak: true)
    if level == 1 {
      text(size: font-size.large, context {
        let ex = measure(smallcaps[x]).height
        v(2 * ex + 5pt, weak: true)
        smallcaps[#prefix#gap#it.body]
        v(1.5 * ex + 5pt, weak: true)  // 1.5ex + \topsep + \partopsep
      })
    } else if level == 2 {
      text(size: font-size.normal, context {
        let ex = measure(smallcaps[x]).height
        v(1.8 * ex + 7pt, weak: true)
        smallcaps[#prefix#gap#it.body]
        v(0.8 * ex + 8.5pt, weak: true)
      })
    } else if level == 3 {
      text(size: font-size.normal, context {
        let ex = measure(smallcaps[x]).height
        v(1.5 * ex + 7pt, weak: true)
        smallcaps[#prefix#gap#it.body]
        v(0.5 * ex + 9.5pt, weak: true)
      })
    } else if level == 4 {
      text(size: font-size.normal, {
        v(5pt, weak: true)  // Visually perfect.
        smallcaps[#prefix#gap#it.body]
      })
    }
  }

  // Configure footnote (almost default).
  show footnote.entry: set text(size: font-size.small)
  set footnote.entry(
    separator: line(length: 2in, stroke: 0.35pt),
    clearance: 6.65pt,
    gap: 0.40em,
    indent: 12pt)

  // All captions either centered or aligned to the left.
  show figure.caption: set align(left)

  // Configure figures.
  show figure.where(kind: image): set figure.caption(position: bottom)
  show figure.where(kind: image): set figure(gap: 16pt)
  show figure.where(kind: image): it => {
    let render() = {
      set align(center)
      it.body
      v(it.gap, weak: true)
      block(spacing: 0pt, {
        it.caption
      })
    }
    
    if it.placement == none {
      render()
    } else {
      place(it.placement, float: true,
        block(width: 100%, spacing: 0pt, render()))
    }
  }

  // Configure tables.
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: table): set figure(gap: 6pt)
  show figure.where(kind: table): it => {
    let render() = {
      set align(center)
      block(spacing: 0pt, {
        it.caption
      })
      v(it.gap, weak: true)
      it.body
    }

    if it.placement == none {
      render()
    } else {
      place(it.placement, float: true,
        block(width: 100%, spacing: 0pt, render()))
    }
  }

  // Configure numbered lists.
  set enum(indent: 2.4em, spacing: 0.9em)
  show enum: set block(above: 1.63em)

  // Configure bullet lists.
  set list(indent: 2.4em, spacing: 0.9em, marker: ([•], [‣], [⁃]))
  show list: set block(above: 1.63em)

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
      let content = link(el.location(), numb)
      [(#content)]
    } else {
      it
    }
  }

  make-title(title)
  make-authors(authors, accepted)
  make-abstract(abstract)

  body

  if bibliography != none {
    set std-bibliography(title: [References], style: "iclr.csl")
    bibliography
  }

  if appendix != none {
    set heading(numbering: "A.1")
    counter(heading).update(0)
    appendix
  }
}
