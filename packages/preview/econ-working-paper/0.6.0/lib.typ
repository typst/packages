// econ-working-paper: Working-paper template for SSRN and economics manuscripts
// Copyright (c) 2026 Ulrich Atz — MIT License

// save built-in before the `bibliography` parameter shadows it
#let _bib-func = bibliography

// prose-form citation shorthand: #textcite(<key>) → "Author (Year)"
#let textcite(key) = cite(key, form: "prose")
#let c(key) = cite(key, form: "prose")

// Table/figure note placed below the float at `size` (match the table body),
// left-aligned and single-spaced. Drop one at the end of a #figure body; since
// table captions sit on top, the note lands under the table. Set `size` to the
// table font size if the paper renders tables at something other than 10pt, or
// `size: auto` to inherit the surrounding text size (e.g. match body text).
#let note(body, size: 10pt) = {
  v(-0.4em)
  set par(first-line-indent: 0em, leading: 0.5em, spacing: 0.5em)
  set align(left)
  let styled = [_Note:_ #body]
  if size == auto { styled } else { text(size: size, styled) }
}

#let source(body, size: 10pt) = {
  v(-0.4em)
  set par(first-line-indent: 0em, leading: 0.5em, spacing: 0.5em)
  set align(left)
  let styled = [_Source:_ #body]
  if size == auto { styled } else { text(size: size, styled) }
}

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
  table-fontsize: 10pt,
  // inline math size relative to the surrounding text; display equations
  // are unaffected. Try 0.9em if the math font renders optically larger.
  math-fontsize: 1em,
  // metadata
  title: none,
  // draft banner under the title, e.g. "WORK IN PROGRESS";
  // hidden when anonymize: true
  status: none,
  authors: (),
  date: none,
  abstract: none,
  keywords: none,
  jel: none,
  acknowledgments: none,
  epigraph: none,
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
  // endfloat: false (none), true / "both", "tables", or "figures"
  endfloat: false,
  // where to flush the floats: "end" (after everything),
  // "after-references" (right after the bibliography), or "after-appendix"
  endfloat-position: "end",
  first-line-indent: 1.5em,
  // spacing — "double" (default), "onehalf", or "single"
  line-spacing: "double",
  par-spacing: auto,
  // title-page styling
  title-size: 20pt,
  status-size: 14pt,
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

  // -- resolve endfloat options -----------------------------------------
  // which kinds go to the end; tables and figures are chosen independently
  let float-tables = endfloat == true or endfloat == "both" or endfloat == "tables" or endfloat == "table"
  let float-figures = endfloat == true or endfloat == "both" or endfloat == "figures" or endfloat == "figure"
  let any-endfloat = float-tables or float-figures
  if type(endfloat) == str and not any-endfloat {
    panic("endfloat must be false, true, \"both\", \"tables\", or \"figures\"")
  }
  // normalize the flush position (accept "after-bibliography" as an alias)
  let endfloat-position = if endfloat-position == "after-bibliography" {
    "after-references"
  } else {
    endfloat-position
  }
  if endfloat-position not in ("end", "after-references", "after-appendix") {
    panic("endfloat-position must be \"end\", \"after-references\", or \"after-appendix\"")
  }

  // -- endfloat state ---------------------------------------------------
  let float-store = state("endfloat-figures", ())
  let in-endfloat = state("in-endfloat", false)

  // flush the collected floats: tables first (each on its own page), then
  // figures. Flipping `in-endfloat` makes any later floats (e.g. in an
  // appendix rendered after this point) render inline instead of collecting.
  let table-counter = counter(figure.where(kind: table))
  let image-counter = counter(figure.where(kind: image))
  let flush-floats() = {
    pagebreak(weak: true)
    in-endfloat.update(true)
    context {
      let floats = float-store.final()
      let tables = floats.filter(f => f.kind == "table")
      let figures = floats.filter(f => f.kind == "figure")
      // the counters have advanced past every placeholder; remember where so
      // any floats after this flush (e.g. in an appendix) keep numbering
      let saved-table = table-counter.get().first()
      let saved-image = image-counter.get().first()
      for fig in tables + figures {
        // reset the counter so each float's caption shows its original number
        // (a re-rendered float does not re-increment, so set it exactly)
        let c = if fig.kind == "table" { table-counter } else { image-counter }
        c.update(fig.num)
        align(center, fig.body)
        pagebreak(weak: true)
      }
      table-counter.update(saved-table)
      image-counter.update(saved-image)
    }
  }

  // -- figures and tables -----------------------------------------------
  // table captions on top, figure captions on bottom
  show figure.where(kind: table): set figure.caption(position: top)
  // table bodies at table-fontsize; captions and #note[] keep their size
  show table: set text(size: table-fontsize)

  // bold "Figure 1." / "Table 1." caption format, left-aligned, single-spaced
  show figure.caption: it => {
    set align(left)
    set par(leading: 0.5em, spacing: 0.5em)
    strong(it.supplement + " " + context it.counter.display() + ".")
    [ ] + it.body
  }

  // collect figures/tables for endfloat, replace with placeholder
  show figure: it => {
    let this-floats = (it.kind == table and float-tables) or (it.kind == image and float-figures)
    if this-floats {
      context {
        if in-endfloat.get() {
          it
        } else {
          // capture the number now; the counter moves on before the float is
          // flushed, so the caption is reset to `num` at flush time
          let num = it.counter.get().first()
          // capture the caption position in effect here (the template's
          // table rule or any user override) and re-apply it at flush time;
          // set rules are lost through the state round-trip
          let cap-pos = figure.caption.position
          float-store.update(arr => {
            arr.push((
              kind: if it.kind == table { "table" } else { "figure" },
              num: num,
              body: { set figure.caption(position: cap-pos); it },
            ))
            arr
          })
          // use the figure's supplement ("Table", "Figure", "Table IA", ...)
          // so placeholders match the caption labels
          let kind-name = if it.supplement in (none, auto) {
            if it.kind == table { [Table] } else { [Figure] }
          } else {
            it.supplement
          }
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
  // inline math sizing (math fonts can render optically larger than the
  // text font, e.g. New Computer Modern Math against Libertine or Times)
  show math.equation.where(block: false): set text(size: math-fontsize)

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

    // draft banner, suppressed for blind review
    if status != none and not anonymize {
      v(1.2em)
      text(status-size, emph(status))
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

  // -- epigraph (optional opening quotation) --------------------------------
  if epigraph != none {
    set par(first-line-indent: 0em, leading: 0.65em, spacing: 0.65em)
    align(right,
      box(width: 80%)[
        #set align(left)
        #emph(epigraph.quote)
        #if "attribution" in epigraph {
          v(4pt)
          text(size: 0.9em)[--- #epigraph.attribution]
        }
      ],
    )
    v(1.5em)
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

  if any-endfloat and endfloat-position == "after-references" { flush-floats() }

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

  if any-endfloat and endfloat-position == "after-appendix" { flush-floats() }

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

  if any-endfloat and endfloat-position == "end" { flush-floats() }
}
