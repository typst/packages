// econ-working-paper: Working-paper template for SSRN and economics manuscripts
// Copyright (c) 2026 Ulrich Atz — MIT License

// save built-in before the `bibliography` parameter shadows it
#let _bib-func = bibliography

// prose-form citation shorthand: #textcite(<key>) → "Author (Year)"
#let textcite(key) = cite(key, form: "prose")
#let c(key) = cite(key, form: "prose")

// ---------------------------------------------------------------------------
// Helper: deduplicate affiliations and build the author line
// ---------------------------------------------------------------------------

// Returns (author-line: content, affil-footnotes: array of content)
// Deduplicates institutions, assigns superscript numbers.
// Affiliations are rendered as footnotes on the title page.
// When every author shares one affiliation, superscripts are omitted and
// a single footnote is still generated.
#let make-author-info(authors, name-size: 14pt) = {
  if authors.len() == 0 { return none }

  // collect unique affiliations in order of first appearance
  let affils = ()
  for a in authors {
    let inst = a.at("affiliation", default: none)
    if inst != none and inst not in affils {
      affils.push(inst)
    }
  }

  let single = affils.len() <= 1

  // build the author name fragments with superscript markers
  let frags = ()
  for (i, a) in authors.enumerate() {
    let inst = a.at("affiliation", default: none)
    let idx = if inst != none { affils.position(x => x == inst) + 1 } else { none }
    let piece = if not single and idx != none {
      [#a.name#super[#idx]]
    } else {
      a.name
    }
    frags.push(piece)
  }

  // join with commas and "and"
  let author-line = if frags.len() == 1 {
    frags.at(0)
  } else if frags.len() == 2 {
    [#frags.at(0) and #frags.at(1)]
  } else {
    let parts = frags.slice(0, -1).map(f => [#f]).join([, ])
    [#parts, and #frags.last()]
  }

  (
    author-line: text(name-size, author-line),
    affiliations: affils,
    single: single,
  )
}

// ---------------------------------------------------------------------------
// Helper: render abstract, keywords, JEL
// ---------------------------------------------------------------------------

#let render-frontmatter(
  abstract,
  keywords,
  jel,
  acknowledgments: none,
  abstract-width: 69%,
  meta-width: 90%,
  gap: 12pt,
) = {
  if abstract == none and keywords == none and jel == none { return none }

  // abstract: narrower column, single-spaced
  if abstract != none {
    box(width: abstract-width)[
      #set align(left)
      #set par(first-line-indent: 0em, leading: 0.65em, spacing: 0.65em, justify: true)
      #align(center)[*Abstract*#if acknowledgments != none [\*]]
      #v(gap, weak: true)
      #par(justify: true, abstract)
    ]
  }

  // keywords and JEL at wider width
  if keywords != none or jel != none {
    if abstract != none { v(gap, weak: true) }
    box(width: meta-width)[
      #set align(left)
      #set par(first-line-indent: 0em, leading: 0.65em, spacing: 0.65em, justify: true)

      #if keywords != none {
        par(justify: true)[*_Keywords:_* #keywords]
      }

      #if keywords != none and jel != none {
        v(gap, weak: true)
      }

      #if jel != none {
        par(justify: true)[*_JEL Classification:_* #jel]
      }
    ]
  }
}

// ---------------------------------------------------------------------------
// Main template function
// ---------------------------------------------------------------------------

#let paper(
  // typography
  font: ("Linux Libertine", "Times New Roman", "New Computer Modern"),
  fontsize: 12pt,
  // metadata
  title: none,
  subtitle: none,
  authors: (),
  date: none,
  abstract: none,
  keywords: none,
  jel: none,
  acknowledgments: none,
  bibliography: none,
  appendix: none,
  internet-appendix: none,
  citation-style: "chicago-author-date",
  // layout
  margin: 1in,
  paper: "us-letter",
  anonymize: false,
  // draft watermark: false for none, true for "DO NOT CITE", or custom string
  draft: false,
  endfloat: false,
  first-line-indent: 1.5em,
  // spacing — "double" (default), "onehalf", or "single"
  line-spacing: "double",
  par-spacing: auto,
  // title-page styling
  title-size: 20pt,
  subtitle-size: 14pt,
  author-name-size: 14pt,
  cover-text-width: 90%,
  frontmatter-gap: 12pt,
  // body
  doc,
) = {
  // -- resolve line-spacing to a leading value --------------------------
  let leading = if line-spacing == "double" {
    1.32em
  } else if line-spacing == "onehalf" {
    0.98em
  } else if line-spacing == "single" {
    0.65em
  } else {
    panic("line-spacing must be \"double\", \"onehalf\", or \"single\"")
  }

  // -- resolve par-spacing (auto = same as leading, matching LaTeX default)
  let par-spacing = if par-spacing == auto { leading } else { par-spacing }

  // -- document metadata ------------------------------------------------
  set document(
    title: if title != none { title } else { "" },
    author: if anonymize { () } else { authors.map(a => a.name) },
  )

  // -- page setup -------------------------------------------------------
  set page(
    paper: paper,
    margin: margin,
    numbering: "1",
    background: if draft != false {
      let msg = if draft == true { "DO NOT CITE" } else { draft }
      place(
        center + horizon,
        rotate(45deg, text(120pt, fill: luma(92%), weight: "bold", msg)),
      )
    },
  )

  // -- base typography --------------------------------------------------
  set text(font: font, size: fontsize)
  set par(leading: leading, spacing: par-spacing, justify: true)
  // -- citations (authoryear, like natbib) --------------------------------
  set _bib-func(style: citation-style)
  // -- footnotes --------------------------------------------------------
  set footnote.entry(separator: line(length: 100%, stroke: 0.5pt))
  set footnote.entry(indent: 0em, gap: 0.6em)
  show footnote.entry: set align(left)

  // -- endfloat state ---------------------------------------------------
  let float-store = state("endfloat-figures", ())
  let in-endfloat = state("in-endfloat", false)

  // -- figures and tables -----------------------------------------------
  // table captions on top, figure captions on bottom
  show figure.where(kind: table): set figure.caption(position: top)

  // bold "Figure 1." / "Table 1." caption format, left-aligned, single-spaced
  show figure.caption: it => {
    set align(left)
    set par(leading: 0.5em, spacing: 0.5em)
    strong(it.supplement + " " + context it.counter.display() + ".")
    [ ] + it.body
  }

  // collect figures/tables for endfloat, replace with placeholder
  show figure: it => {
    if endfloat {
      context {
        if in-endfloat.get() {
          it
        } else {
          // wrap table figures so caption position survives state
          // round-tripping (set rules are lost through context blocks)
          float-store.update(arr => {
            arr.push(if it.kind == table {
              { set figure.caption(position: top); it }
            } else {
              it
            })
            arr
          })
          let kind-name = if it.kind == table { "Table" } else { "Figure" }
          let num = it.counter.get().first()
          align(center, pad(y: 1em, emph[\[#kind-name #num about here\]]))
        }
      }
    } else {
      it
    }
  }

  // -- links ------------------------------------------------------------
  show link: set text(fill: black)

  // -- equations --------------------------------------------------------
  set math.equation(numbering: "(1)", supplement: auto)

  // ====================================================================
  // TITLE PAGE
  // ====================================================================

  {
    set par(leading: leading, spacing: par-spacing, first-line-indent: 0em, justify: false)
    set align(center)

    // suppress Typst's built-in footnotes on the title page; we render our own
    set footnote.entry(separator: none)
    show footnote.entry: hide

    if title != none {
      v(2em)
      text(title-size, strong(title))
    }

    // author line with superscript affiliation markers
    if not anonymize {
      let info = make-author-info(authors, name-size: author-name-size)
      if info != none {
        v(1.2em)
        info.author-line
      }

      if date != none {
        v(1.5em)
        text(author-name-size, emph[Version: #date])
      }
    }

    if subtitle != none {
      v(1.2em)
      text(subtitle-size, subtitle)
    }

    // frontmatter (abstract narrower + single-spaced; keywords/JEL wider)
    {
      v(1.5em)
      render-frontmatter(
        abstract, keywords, jel,
        acknowledgments: if anonymize { none } else { acknowledgments },
        abstract-width: cover-text-width - 15%,
        meta-width: cover-text-width,
        gap: frontmatter-gap,
      )
    }

    // unified footnote block at page bottom: affiliations + acknowledgments + notes
    if not anonymize {
      let info = make-author-info(authors, name-size: author-name-size)
      let has-affils = info != none and info.affiliations.len() > 0
      let has-ack = acknowledgments != none
      // build affiliation → emails mapping
      let affil-emails = (:)
      for a in authors {
        let inst = a.at("affiliation", default: none)
        let email = a.at("email", default: none)
        if inst != none and email != none {
          if inst in affil-emails {
            affil-emails.at(inst).push(email)
          } else {
            affil-emails.insert(inst, (email,))
          }
        }
      }
      let author-notes = authors.filter(a => a.at("note", default: none) != none)
      let has-notes = author-notes.len() > 0
      if has-affils or has-ack or has-notes {
        let foot-content = {
          set text(size: 0.85em)
          set align(left)
          set par(first-line-indent: 0em, leading: 0.5em, spacing: 0.4em)
          line(length: 100%, stroke: 0.5pt)
          v(0.3em)
          if has-ack {
            [\*#acknowledgments]
          }
          if has-ack and has-affils { v(0.2em) }
          if has-affils {
            let affils = info.affiliations
            if info.single {
              let inst = affils.at(0)
              let emails = affil-emails.at(inst, default: ())
              if emails.len() > 0 {
                [#inst, #emails.map(e => link("mailto:" + e, e)).join(", ")]
              } else {
                inst
              }
            } else {
              for (i, inst) in affils.enumerate() {
                let emails = affil-emails.at(inst, default: ())
                if emails.len() > 0 {
                  [#super[#(i + 1)]#inst, #emails.map(e => link("mailto:" + e, e)).join(", ")]
                } else {
                  [#super[#(i + 1)]#inst]
                }
                if i < affils.len() - 1 { linebreak() }
              }
            }
          }
          if has-notes and (has-affils or has-ack) { v(0.2em) }
          if has-notes {
            for a in author-notes {
              [#a.name: #a.note]
              if a != author-notes.last() { linebreak() }
            }
          }
        }
        place(bottom + left, foot-content)
      }
    }

    pagebreak()
  }

  // ====================================================================
  // BODY
  // ====================================================================

  set footnote(numbering: "1")
  set align(left)
  set heading(numbering: "1.1")
  set par(
    leading: leading,
    spacing: par-spacing,
    first-line-indent: first-line-indent,
    justify: true,
  )

  // headings: bold, numbered, with spacing
  show heading: it => {
    v(1.2em, weak: true)
    it
    v(0.8em, weak: true)
    // suppress first-line indent on the paragraph right after a heading
    h(0pt)
  }

  doc

  // ====================================================================
  // BIBLIOGRAPHY
  // ====================================================================

  if bibliography != none {
    pagebreak(weak: true)
    show heading: it => {
      set align(left)
      it.body
      v(0.8em)
    }
    bibliography
  }

  // ====================================================================
  // APPENDIX
  // ====================================================================

  if appendix != none {
    pagebreak(weak: true)
    {
      set par(leading: 0.65em, spacing: 0.65em)
      set block(spacing: 0.65em)
      counter(heading).update(0)
      set heading(numbering: (..nums) => {
        let vals = nums.pos()
        if vals.len() <= 1 { none }
        else { "A." + str(vals.at(1)) }
      })
      appendix
    }
  }

  // ====================================================================
  // INTERNET APPENDIX
  // ====================================================================

  if internet-appendix != none {
    pagebreak(weak: true)
    {
      set par(leading: 0.65em, spacing: 0.65em)
      set block(spacing: 0.65em)
      counter(heading).update(0)
      set heading(numbering: (..nums) => {
        let vals = nums.pos()
        if vals.len() <= 1 { none }
        else { "IA." + str(vals.at(1)) }
      })
      // restart table and figure counters with IA prefix
      counter(figure.where(kind: table)).update(0)
      show figure.where(kind: table): set figure(supplement: [Table IA])
      counter(figure.where(kind: image)).update(0)
      show figure.where(kind: image): set figure(supplement: [Figure IA])
      internet-appendix
    }
  }

  // ====================================================================
  // ENDFLOAT: flush collected figures/tables
  // ====================================================================

  if endfloat {
    pagebreak(weak: true)
    in-endfloat.update(true)
    context {
      let floats = float-store.final()
      for fig in floats {
        align(center, fig)
        pagebreak(weak: true)
      }
    }
  }
}
