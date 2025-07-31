/**
 * icml2024.typ
 *
 * International Conference on Machine Learning (ICML) 2024.
 */

// Metrical size of page body.
#let body = (
  width: 6.75in,
  height: 9.0in,
)

// Default font sizes from original LaTeX style file.
#let font-defaults = (
  tiny:	        6pt,
  scriptsize:   7pt,
  footnotesize: 9pt,
  small:        9pt,
  normalsize:   10pt,
  large:        12pt,
  Large:        14pt,
  LARGE:        17pt,
  huge:         20pt,
  Huge:         25pt,
)

// We prefer to use Times New Roman when ever it is possible.
#let font-family = ("Times New Roman", "Nimbus Roman", "TeX Gyre Termes")

#let font = (
  Large: font-defaults.Large + 0.4pt,  // Actual font size.
  footnote: font-defaults.footnotesize,
  large: font-defaults.large,
  small: font-defaults.small,
  normal: font-defaults.normalsize,
  script: font-defaults.scriptsize,
)

#let format_author_names(authors) = {
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

#let make_figure_caption(it) = {
  set align(center)
  block(width: 100%, {
    set align(left)
    set text(size: font.small)
    emph({
      it.supplement
      if it.numbering != none {
        [ ]
        context { it.counter.display(it.numbering) }
      }
      it.separator
    })
    [ ]
    it.body
  })
}

#let make_figure(caption_above: false, it) = {
  // set align(center + top)
  place(center + top, float: true,
  block(breakable: false, width: 100%, {
    if caption_above {
      it.caption
    }
    v(0.1in, weak: true)
    it.body
    v(0.1in, weak: true)
    if not caption_above {
      it.caption
    }
  }))
}

#let anonymous-author = (
  name: "Anonymous Author",
  email: "anon.email@example.org",
  affl: ("anonymous-affl", ),
)

#let anonymous-affl = (
  department: none,
  institution: "Anonymous Institution",
  location: "Anonymous City, Anonymous Region",
  country: "Anonymous Country",
)

#let anonymous-notice = [
  Preliminary work. Under review by the International Conference on Machine
  Learning (ICML). Do not distribute.
]

#let arxiv-notice = []

#let public-notice = [
  _Proceedings of the 41#super[st] International Conference on Machine
  Learning_, Vienna, Austria. PMLR 235, 2024. Copyright 2024 by the author(s).
]

#let make-author(author, affl2idx) = {
  // Sanitize author affilations.
  let affl = author.at("affl")
  if type(affl) == str {
    affl = (affl,)
  }

  // Make a list of superscript indices.
  let indices = affl.map(it => str(affl2idx.at(it)))
  let has-equal-contrib = author.at("equal", default: false)
  if has-equal-contrib {
    indices.insert(0, "*")
  }

  // Render author and affilation references to content.
  set text(size: font.normal, weight: "regular")
  return strong(author.name) + super(typographic: false, [
    #indices.join(" ")
  ])
}

#let make-affilations-and-notice(authors, affls) = {
  let info = ()

  // Add equal contribution notice.
  let has-equal-contrib = authors.fold(false, (acc, it) => {
    let equal-contrib = it.at("equal", default: false)
    return acc or equal-contrib
  })
  if has-equal-contrib {
    info.push(super[\*] + [Equal contribution])
  }

  // Prepare list of affilations.
  let ordered-affls = authors.map(it => it.affl).flatten().dedup()
  let affilations = ordered-affls.enumerate(start: 1).map(pair => {
    let (ix, it) = pair
    let affl = affls.at(it, default: none)
    assert(affl != none, message: "unknown affilation: " + it)

    // Convert structured affilation representation to plain one (array).
    if type(affl) == dictionary {
      let keys = ("department", "institution", "location", "country")
      let parts = ()
      for key in keys {
        let val = affl.at(key, default: none)
        if val != none {
          parts.push(val)
        }
      }
      affl = parts
    }

    // Validate affilation representation.
    assert(type(affl) == array,
           message: "wrong affilation type: " + type(affl))
    assert(affl.len() > 0,
           message: "empty affilation: " + it + " :" + repr(affl))

    // Finally, join parts of affilation.
    return super(str(ix)) + affl.join(", ")
  })
  if affilations != () {
    info.push(affilations.join([ ]) + [.])
  }

  // Prepare list of corresponding authors (author which has its email).
  let correspondents = authors.fold((), (acc, it) => {
    let email = it.at("email", default: none)
    if email != none {
      let mailto = link("mailto:" + it.email, it.email)
      acc.push([#it.name \<#mailto\>])
    }
    return acc
  })
  if correspondents != () {
    info.push([Correspondence to: ] + correspondents.join(", ") + [.])
  }

  return info
}

/**
 * icml2024
 *
 * Args:
 *   accepted: Valid values are `none`, `false`, and `true`. Missing value
 *   (`none`) is designed to prepare arxiv publication. Default is `false`.
 */
#let icml2024(
  title: [],
  authors: (),
  keywords: (),
  date: auto,
  abstract: none,
  bibliography: none,
  header: none,
  appendix: none,
  accepted: false,
  aux: (:),
  body,
) = {
  if header == none {
    header = title
  }

  // Allow customization of public notice.
  let public-notice = if "public-notice" in aux {
    aux.public-notice
  } else {
    public-notice
  }

  // Sanitize authors and affilations arguments.
  if accepted != none and not accepted {
    authors = ((anonymous-author,), (anonymous-affl: anonymous-affl))
  }
  let (authors, affls) = authors

  // Configure document metadata.
  set document(
    title: title,
    author: authors.map(it => it.name),
    keywords: keywords,
    date: date,
  )

  // Prepare affilation and notice footnote.
  let contrib-info = make-affilations-and-notice(authors, affls)
  let make-contribs() = {
    set text(size: font.small)
    set par(leading: 0.5em, justify: true)
    line(length: 0.8in, stroke: (thickness: 0.05em))
    block(spacing: 0.45em, width: 100%, {  // Footnote line.
      h(1.2em)  // BUG: https://github.com/typst/typst/issues/311
      if contrib-info != () {
        contrib-info.join([ ])
        parbreak()
      }

      if accepted == none {
        arxiv-notice
      } else if accepted  {
        public-notice
      } else {
        anonymous-notice
      }
    })
  }

  // Prepare authors and footnote anchors.
  let ordered-affls = authors.map(it => it.affl).flatten().dedup()
  let affl2idx = ordered-affls.enumerate(start: 1).fold((:), (acc, it) => {
    let (ix, affl) = it
    acc.insert(affl, ix)
    return acc
  })
  let make-authors() = authors.map(it => make-author(it, affl2idx))

  set page(
    paper: "us-letter",
    margin: (
      left: 0.75in,
      right: 8.5in - (0.75in + 6.75in),
      top: 1.0in,
      bottom: 11in - 1in - 9in),
    columns: 2,
    header-ascent: 10pt,
    header: context {
      // The first page is a title page. It does not have running header.
      let pageno = counter(page).get().first()
      if pageno == 1 {
        return
      }

      // Render running title since the second page.
      set align(center)
      set text(size: font.footnote, weight: "bold")
      block(spacing: 0pt, fill: none, {
        set block(spacing: 0em)
        text(size: font.small, header)
        v(3.5pt) // By default, fancyhdr spaces 4pt.
        line(length: 100%, stroke: (thickness: 1pt))
      })
    },
    footer-descent: 25pt - font.normal,
    footer: context {
      let i = counter(page).get().first()
      align(center, text(size: font.normal, [#i]))
    }
  )
  set columns(gutter: 0.25in)

  // Main body font is Times (Type-1) font.
  let font-family = if "font-family" in aux {
    aux.font-family
  } else {
    font-family
  }
  set par(justify: true, leading: 0.58em)
  set text(font: font-family, size: font.normal)

  set heading(numbering: "1.")
  show heading: it => {
    // Create the heading numbering.
    let number = if it.numbering != none {
      counter(heading).display(it.numbering)
      // h(7pt, weak: true
    }

    set align(left)
    if it.level == 1 {
      text(size: font.large, weight: "bold")[
        #v(0.25in, weak: true)
        #number
        *#it.body*
        #v(0.15in, weak: true)
      ]
    } else if it.level == 2 {
      text(size: font.normal, weight: "bold")[
        #v(0.2in, weak: true)
        #number
        *#it.body*
        #v(0.13in, weak: true)
      ]
    } else if it.level == 3 {
      text(size: font.normal, weight: "regular")[
        #v(0.18in, weak: true)
        #number
        #smallcaps(it.body)
        #v(0.1in, weak: true)
      ]
    }
  }

  set figure.caption(separator: [.])
  show figure: set block(breakable: false)
  show figure.caption.where(kind: table): it => make_figure_caption(it)
  show figure.caption.where(kind: image): it => make_figure_caption(it)
  show figure.where(kind: image): it => make_figure(it)
  show figure.where(kind: table): it => make_figure(it, caption_above: true)

  // Configure numbered lists.
  set enum(indent: 1.4em, spacing: 0.9em)
  show enum: set block(above: 1.63em)

  // Configure bullet lists.
  set list(indent: 1.4em, spacing: 0.9em, marker: ([•], [‣], [⁃]))
  show list: set block(above: 1.63em)

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
    } else if el != none and el.func() == heading {
      let numb = numbering(
        el.numbering,
        ..counter(el.func()).at(el.location()))
      if numb.at(-1) == "." {
        numb = numb.slice(0, -1)
      }
      let color = rgb(0%, 8%, 45%)  // Originally `mydarkblue`. :D
      let content = text(fill: color, numb)
      // If numbering starts with letter then the heading is an appendix.
      let supplement = el.supplement
      if numb.at(0) not in ("0", "1", "2", "3", "4", "5", "6", "7", "8", "9") {
        supplement = [Appendix]
      }
      link(el.location())[#supplement~#content]
    } else if el != none and el.func() == figure {
      let numb = numbering(
        el.numbering,
        ..counter(figure.where(kind: el.kind)).at(el.location()))
      if numb.at(-1) == "." {
        numb = numb.slice(0, -1)
      }
      let color = rgb(0%, 8%, 45%)  // Originally `mydarkblue`. :D
      let content = text(fill: color, numb)
      link(el.location())[#el.supplement~#content]
    }
  }

  // Configure algorithm rendering.
  counter(figure.where(kind: "algorithm")).update(0)
  show figure.caption.where(kind: "algorithm"): it => block(width: 100%, {
    set align(left)
    context { strong[#it.supplement #it.counter.display(it.numbering)] }
    [ ]
    it.body
  })
  show figure.where(kind: "algorithm"): it => {
    let render() = block(breakable: false, width: 100%, {
        set block(spacing: 0em)
        line(length: 100%, stroke: (thickness: 0.08em))
        block(spacing: 0.4em, it.caption)  // NOTE: No idea why we need it.
        line(length: 100%, stroke: (thickness: 0.05em))
        it.body
        line(length: 100%, stroke: (thickness: 0.08em))
      })
    if it.placement == none {
      render()
    } else {
      place(it.placement, float: true, render())
    }
  }

  place(top + center, float: true, scope: "parent", {
    // Render title.
    {
      set align(center)
      set par(spacing: 18pt)
      set text(size: font.Large, weight: "bold")
      v(0.5pt)
      line(length: 100%)
      v(1pt)
      title
      v(1pt)
      line(length: 100%)
    }

    v(0.1in - 1pt)

    // Render authors.
    {
      set align(center)
      make-authors().map(it => {
        box(inset: (left: 0.5em, right: 0.5em), it)
      }).join()
    }
  })

  v(0.2in)

  {
    set text(size: font.normal)
    set par(spacing: 11pt)
    // Render abstract.
    // ICML instruction tels that font size of `Abstract` must equal to 11 but
    // it does not like so.
    align(center, text(size: font.large, [*Abstract*]))
    pad(left: 2em, right: 2em, abstract)
    v(0.12in)

    // Place contribution and notice at the bottom of the first column.
    place(bottom, float: true, clearance: 0.5em, {
      set block(spacing: 0pt)
      make-contribs()
    })

    // Display body.
    set text(size: font.normal)
    body

    // Display the bibliography, if any is given.
    if bibliography != none {
      show std.bibliography: set text(size: font.normal)
      set std.bibliography(title: "References", style: "icml.csl")
      bibliography
    }
  }

  if appendix != none {
    set page(columns: 1)
    pagebreak(weak: true)
    counter(heading).update(0)
    counter("appendices").update(1)
    set heading(
      numbering: (..nums) => {
        let vals = nums.pos()
        let value = "ABCDEFGHIJ".at(vals.at(0) - 1)
        return value + "." + nums.pos().slice(1).map(str).join(".")
      }
    )
    appendix
  }
}

// Helper routine for turning off equation numbering.
#let eq = it => {
  set math.equation(numbering: none)
  it
}

// Vertical ruler on left margin of a page.

#let itoa(val) = {
  if val > 999 {
    return str(val)
  } else if val > 99 {
    return str(val)
  } else if val > 9 {
    return "0" + str(val)
  } else {
    return "00" + str(val)
  }
}

#let vruler(page: 0, offset: 0pt, fill: none) = {
  let count = 55
  let numbers = range(page * count, (page + 1) * count)
  let content = numbers.map(it => itoa(it)).join([ \ ])
  let sidebar = block(width: 15pt, height: 9in, fill: fill)[
    #set text(fill: rgb(70%, 70%, 70%))
    #set par(leading: 5.2pt)
    #align(right, content)
  ]
  return place(
    top,
    sidebar,
    dx: -30pt,
    dy: offset,
    float: false)
}

#let cite-color = rgb(0%, 8%, 45%)

/**
 * Alternative citing routine.
 */
#let refer(..keys, color: cite-color) = {
  let citations = keys.pos().map(key => cite(key)).join([ ])
  return [(] + text(fill: color, citations) + [)]
}

/**
 * Simple routine for rewriting content. It replaces a sequence of references
 * that are joined with spaces or line breaks (elements without width).
 */
#let rewrite-citations(doc, color: cite-color) = style(styles => {
  let atoms = doc.children
  let body = []
  let ix = 0
  while ix < atoms.len() {
    let atom = atoms.at(ix)
    if atom.func() != ref {
      body = body + [#atom]
      ix += 1
    } else {
      // Look-a-head for other refs.
      let refs = (atom, )
      let jx = ix + 1
      while jx < atoms.len() {
        // If the next one content block is a reference then append reference
        // to the list of references.
        let lookahead = atoms.at(jx)
        if lookahead.func() == ref {
          refs.push(lookahead)
          jx += 1
          continue
        }

        // Now, we assume that if the width of content block is zero then it is
        // a space or line break. Thus we skip it and make another iteration.
        let shape = measure(lookahead, styles)
        if shape.width == 0pt {
          jx += 1
          continue
        }

        // Otherwise, we stop iterations.
        break
      }

      // Combine refs into single citation, and wrap it into context with
      // colored text.
      let citation = refs.join([])
      body = body + [(] + text(fill: color, citation) + [)]

      // Advance iterator on number of continues block of citations.
      ix += jx - ix
    }
  }
  return body
})
