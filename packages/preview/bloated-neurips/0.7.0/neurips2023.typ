// Workaround for the lack of an `std` scope.
#let std-bibliography = bibliography

// Metrical size of page body.
#let viewport = (
  width: 5.5in,
  height: 9in,
)

// Default font sizes from original LaTeX style file.
#let font-defaults = (
  tiny:	        7pt,
  scriptsize:   7pt,
  footnotesize: 9pt,
  small:        9pt,
  normalsize:   10pt,
  large:        14pt,
  Large:        16pt,
  LARGE:        20pt,
  huge:         23pt,
  Huge:         28pt,
)

// We prefer to use Times New Roman when ever it is possible.
#let font-family = ("Times New Roman", "Nimbus Roman", "TeX Gyre Termes")

#let font = (
  Large: font-defaults.Large,
  footnote: font-defaults.footnotesize,
  large: font-defaults.large,
  small: font-defaults.small,
  normal: font-defaults.normalsize,
  script: font-defaults.scriptsize,
)

#let make_figure_caption(it) = {
  set align(center)
  block(context {
    set align(left)
    set text(size: font.normal)
    it.supplement
    if it.numbering != none {
      [ ]
      it.counter.display(it.numbering)
    }
    it.separator
    [ ]
    it.body
  })
}

#let make_figure(caption_above: false, it) = {
  let body = block(width: 100%, {
    set align(center)
    set text(size: font.normal)
    if caption_above {
      v(1em, weak: true)  // Does not work at the block beginning.
      it.caption
    }
    v(1em, weak: true)
    it.body
    v(8pt, weak: true)  // Original 1em.
    if not caption_above {
      it.caption
      v(1em, weak: true)  // Does not work at the block ending.
    }
  })

  if it.placement == none {
    return body
  } else {
    return place(it.placement, body, float: true, clearance: 2.3em)
  }
}

#let anonymous-author = (
  name: "Anonymous Author(s)",
  email: "anon.email@example.org",
  affl: ("anonymous-affl", ),
)

#let anonymous-affl = (
  department: none,
  institution: "Affilation",
  location: "Address",
)

#let anonymous-notice = [
  Submitted to 37th Conference on Neural Information Processing Systems
  (NeurIPS 2023). Do not distribute.
]

#let arxiv-notice = [Preprint. Under review.]

#let public-notice = [
  37th Conference on Neural Information Processing Systems (NeurIPS 2023).
]

#let get-notice(accepted) = if accepted == none {
  return arxiv-notice
} else if accepted {
  return public-notice
} else {
  return anonymous-notice
}

#let format-author-names(authors) = {
  // Formats the author's names in a list with commas and a
  // final "and".
  let author_names = authors.map(author => author.name)
  let author-string = if authors.len() == 2 {
    author_names.join(" and ")
  } else {
    author_names.join(", ", last: ", and ")
  }
  return author_names
}

#let format-author-name(author, affl2idx, affilated: false) = {
  // Sanitize author affilations.
  let affl = author.at("affl")
  if type(affl) == str {
    affl = (affl,)
  }
  let indices = affl.map(it => str(affl2idx.at(it))).join(" ")
  let result = strong(author.name)
  if affilated {
    result += super(typographic: false, indices)
  }
  return box(result)
}

#let format-afflilation(affl) = {
  assert(affl.len() > 0, message: "Affilation must be non-empty.")

  // Concatenate terms which representat affilation to a single text.
  let affilation = ""
  if type(affl) == array {
    affilation = affl.join(", ")
  } else if type(affl) == dictionary {
    let terms = ()
    if "department" in affl and affl.department != none {
      terms.push(affl.department)
    }
    if "institution" in affl and affl.institution != none {
      terms.push(affl.institution)
    }
    if "location" in affl and affl.location != none {
      terms.push(affl.location)
    }
    if "country" in affl and affl.country != none {
      terms.push(affl.country)
    }
    affilation = terms.filter(it => it.len() > 0).join(", ")
  } else {
    assert(false, message: "Unexpected execution branch.")
  }

  return affilation
}

#let make-single-author(author, affls, affl2idx) = {
  // Sanitize author affilations.
  let affl = author.at("affl")
  if type(affl) == str {
    affl = (affl,)
  }

  // Render author name.
  let name = format-author-name(author, affl2idx)
  // Render affilations.
  let affilation = affl
    .map(it => format-afflilation(affls.at(it)))
    .map(it => box(it))
    .join(" ")

  let lines = (name, affilation)
  if "email" in author {
    let uri = "mailto:" + author.email
    let text = raw(author.email)
    lines.push(box(link(uri, text)))
  }

  // Combine all parts of author's info.
  let body = lines.join([\ ])
  return align(center, body)
}

#let make-two-authors(authors, affls, affl2idx) = {
  let row = authors
    .map(it => make-single-author(it, affls, affl2idx))
    .map(it => box(it))
  return align(center, grid(columns: (1fr, 1fr), gutter: 2em, ..row))
}

#let make-many-authors(authors, affls, affl2idx) = {
  let format-affl(affls, key, index) = {
    let affl = affls.at(key)
    let affilation = format-afflilation(affl)
    let entry = super(typographic: false, [#index]) + affilation
    return box(entry)
  }

  // Concatenate all author names with affilation superscripts.
  let names = authors
    .map(it => format-author-name(it, affl2idx, affilated: true))

  // Concatenate all affilations with superscripts.
  let affilations = affl2idx
    .pairs()
    .map(it => format-affl(affls, ..it))

  // Concatenate all emails to a single paragraph.
  let emails = authors
    .filter(it => "email" in it)
    .map(it => box(link("mailto:" + it.email, raw(it.email))))

  // Combine paragraph pieces to single array, then filter and join to
  // paragraphs.
  let paragraphs = (names, affilations, emails)
    .filter(it => it.len() > 0)
    .map(it => it.join(h(1em, weak: true)))
    .join([#parbreak() ])

  return align(center, {
    pad(left: 1em, right: 1em, paragraphs)
  })
}

#let make-authors(authors, affls) = {
  // Prepare authors and footnote anchors.
  let ordered-affls = authors.map(it => it.affl).flatten().dedup()
  let affl2idx = ordered-affls.enumerate(start: 1).fold((:), (acc, it) => {
    let (ix, affl) = it
    acc.insert(affl, ix)
    return acc
  })

  if authors.len() == 1 {
    return make-single-author(authors.at(0), affls, affl2idx)
  } else if authors.len() == 2 {
    return make-two-authors(authors, affls, affl2idx)
  } else {
    return make-many-authors(authors, affls, affl2idx)
  }
}

/**
 * neurips2023
 *
 * Args:
 *   accepted: Valid values are `none`, `false`, and `true`. Missing value
 *   (`none`) is designed to prepare arxiv publication. Default is `false`.
 */
#let neurips2023(
  title: [],
  authors: (),
  keywords: (),
  date: auto,
  abstract: none,
  bibliography: none,
  bibliography-opts: (:),
  accepted: false,
  aux: (:),
  body,
) = {
  // Sanitize authors and affilations arguments.
  if accepted != none and not accepted {
    authors = ((anonymous-author,), (anonymous-affl: anonymous-affl))
  }
  let (authors, affls) = authors

  // Configure document metadata.
  set document(
    title: title,
    author: format-author-names(authors),
    keywords: keywords,
    date: date,
  )

  set page(
    paper: "us-letter",
    margin: (left: 1.5in, right: 1.5in,
             top: 1.0in, bottom: 1in),
    footer-descent: 25pt - font.normal,
    footer: context {
      let i = counter(page).at(here()).first()
      if i == 1 {
        let get-notice = if "get-notice" in aux {
          aux.get-notice
        } else {
          get-notice
        }
        let notice = get-notice(accepted)
        return align(center, text(size: 9pt, [#notice]))
      } else {
        return align(center, text(size: font.normal, [#i]))
      }
    },
  )

  // In the original style, main body font is Times (Type-1) font but we use
  // OpenType analogue.
  let font_ = aux.at("font", default: (family: font-family))
  set par(justify: true, leading: 0.55em)
  set text(font: font_.family, size: font.normal)

  // Configure quotation (similar to LaTeX's `quoting` package).
  show quote: set align(left)
  show quote: set pad(x: 4em)
  show quote: set block(spacing: 1em)  // Original 11pt.

  // Configure spacing code snippets as in the original LaTeX.
  show raw.where(block: true): set block(spacing: 14pt)  // TODO: May be 15pt?

  // Configure bullet lists.
  show list: set block(spacing: 15pt)  // Original unknown.
  set list(
    indent: 30pt,  // Original 3pc (=36pt) without bullet.
    spacing: 8.5pt)

  // Configure footnote.
  set footnote.entry(
    separator: line(length: 2in, stroke: 0.5pt),
    clearance: 6.65pt,
    indent: 12pt)  // Original 11pt.

  // Configure heading appearence and numbering.
  set heading(numbering: "1.1")
  show heading: it => {
    // Create the heading numbering.
    let number = if it.numbering != none {
      counter(heading).display(it.numbering)
    }

    set align(left)
    if it.level == 1 {
      // TODO: font.large?
      text(size: 12pt, weight: "bold", {
        let ex = 7.95pt
        v(2.7 * ex, weak: true)
        [#number *#it.body*]
        v(2 * ex, weak: true)
      })
    } else if it.level == 2 {
      text(size: font.normal, weight: "bold", {
        let ex = 6.62pt
        v(2.70 * ex, weak: true)
        [#number *#it.body*]
        v(2.03 * ex, weak: true)  // Original 1ex.
      })
    } else if it.level == 3 {
      text(size: font.normal, weight: "bold", {
        let ex = 6.62pt
        v(2.6 * ex, weak: true)
        [#number *#it.body*]
        v(1.8 * ex, weak: true)  // Original -1em.
      })
    }
  }

  // Configure images and tables appearence.
  set figure.caption(separator: [:])
  show figure: set block(breakable: false)
  show figure.caption.where(kind: table): it => make_figure_caption(it)
  show figure.caption.where(kind: image): it => make_figure_caption(it)
  show figure.where(kind: image): it => make_figure(it)
  show figure.where(kind: table): it => make_figure(it, caption_above: true)

  // Math equation numbering and referencing.
  set math.equation(numbering: "(1)")
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
      return it
    }
  }

  // Configure algorithm rendering.
  counter(figure.where(kind: "algorithm")).update(0)
  show figure.caption.where(kind: "algorithm"): it => {
    strong[#it.supplement #it.counter.display(it.numbering)]
    [ ]
    it.body
  }
  show figure.where(kind: "algorithm"): it => {
    place(top, float: true,
      block(breakable: false, width: 100%, {
        set block(spacing: 0em)
        line(length: 100%, stroke: (thickness: 0.08em))
        block(spacing: 0.4em, it.caption)  // NOTE: No idea why we need it.
        line(length: 100%, stroke: (thickness: 0.05em))
        it.body
        line(length: 100%, stroke: (thickness: 0.08em))
      })
    )
  }

  // Render title.
  block(width: 5.5in, {
    // We need to define line widths to reuse them in spacing.
    let top-rule-width = 4pt
    let bot-rule-width = 1pt

    // Add some space based on line width.
    v(0.1in + top-rule-width / 2)
    line(length: 100%, stroke: top-rule-width + black)
    align(center, text(size: 17pt, weight: "bold", [#title]))
    v(-bot-rule-width)
    line(length: 100%, stroke: bot-rule-width + black)
  })

  v(0.25in)

  // Render authors.
  block(width: 100%, {
    set text(size: font.normal)
    set par(leading: 4.5pt)
    set block(spacing: 1.0em)  // Original 11pt.
    make-authors(authors, affls)
    v(0.3in - 0.1in)
  })

  // Vertical spacing between authors and abstract.
  v(6.5pt)  // Original 0.075in.

  // Set up line numbering.
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
        numbering: n => text(size: 7pt)[#n],
        number-clearance: 11pt)
      body
    }
  }

  // Render abstract.
  block(width: 100%, {
    set text(size: 10pt)
    set text(size: font.normal)
    set par(leading: 0.43em)  // Original 0.55em (or 0.45em?).

    // NeurIPS instruction tels that font size of `Abstract` must equal to 12pt
    // but there is not predefined font size.
    align(center, text(size: 12pt)[*Abstract*])
    v(0.215em)  // Original 0.5ex.
    show: lineno.with(accepted, aux)
    pad(left: 0.5in, right: 0.5in, abstract)
    v(0.43em)  // Original 0.5ex.
  })

  v(0.43em / 2)  // No idea.

  // Render main body
  {
    show: lineno.with(accepted, aux)

    // Display body.
    set text(size: font.normal)
    set par(leading: 0.55em)
    set par(leading: 0.43em)
    set block(spacing: 1.0em)  // Original 11pt.
    body

    // Display the bibliography, if any is given.
    if bibliography != none {
      if "title" not in bibliography-opts {
        bibliography-opts.title = "References"
      }
      if "style" not in bibliography-opts {
        bibliography-opts.style = "ieee"
      }
      // NOTE It is allowed to reduce font to 9pt (small) but there is not
      // small font of size 9pt in original sty.
      show std-bibliography: set text(size: font.small)
      set std-bibliography(..bibliography-opts)
      bibliography
    }
  }
}

/**
 * A routine for setting paragraph heading.
 */
#let paragraph(body) = {
  parbreak()
  [*#body*]
  h(1em, weak: true)
}

/**
 * A routine for rendering external links in monospace font.
 */
#let url(uri) = {
  return link(uri, raw(uri))
}
