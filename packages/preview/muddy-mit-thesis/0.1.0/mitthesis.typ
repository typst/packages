// mitthesis.typ — MIT Thesis Typst Template
// Mirrors mitthesis.cls v1.22 (2026/01/31)
// Compiles with: typst compile MIT-Thesis.typ

// ── Colors ─────────────────────────────────────────────────────────────────
#let link-color = rgb("#0000CD")   // Blue3 (xcolor dvipsnames)
#let url-color  = rgb("#EE82EE")   // violet

// ── Internal state ──────────────────────────────────────────────────────────
#let _in-appendix = state("_in-appendix", false)

// ── Letter-spaced uppercase (mirrors \textls[60]{\MakeUpperCase{...}}) ──────
#let tracked(body) = text(tracking: 0.06em, upper(body))

// ── MIT license permission text ─────────────────────────────────────────────
#let _mit-permission(n) = (
  (if n > 1 { "The authors hereby grant" } else { "The author hereby grants" })
  + " to MIT a nonexclusive, worldwide, irrevocable, royalty-free license to exercise"
  + " any and all rights under copyright, including to reproduce, preserve, distribute"
  + " and publicly display copies of the thesis, or release the thesis under an"
  + " open-access license."
)

// ── Title page ──────────────────────────────────────────────────────────────
#let _make-title-page(
  title, authors, degrees, supervisors, acceptors,
  degree-month, degree-year, thesis-date, institution, cc-license,
) = {
  let author-names = authors.map(a => a.name).join(", ")
  let cr-text = if cc-license != none {
    [This work is licensed under a #cc-license.name license. #_mit-permission(authors.len())]
  } else {
    [All rights reserved. #_mit-permission(authors.len())]
  }

  // Degree submission line
  let dept-items = degrees.filter(d => d.at("department", default: "") != "")
                          .map(d => "the " + d.department)
  let dept-line = dept-items.join(" and ")
  let deg-word = if degrees.len() > 1 { "degrees" } else { "degree" }

  // Build signature grid rows
  let sig = ()
  for (i, a) in authors.enumerate() {
    sig += (
      [Authored by:],
      {
        set par(spacing: 0pt)
        [#a.name \ #a.at("department", default: "") \ #thesis-date]
      },
    )
    if i < authors.len() - 1 { sig += ([#v(0.8em)], []) }
  }
  sig += ([#v(0.8em)], [])
  for (i, s) in supervisors.enumerate() {
    sig += (
      [Certified by:],
      {
        set par(spacing: 0pt)
        [#s.name \ #s.title, Thesis Supervisor]
      },
    )
    if i < supervisors.len() - 1 { sig += ([#v(0.8em)], []) }
  }
  sig += ([#v(0.8em)], [])
  for acc in acceptors {
    let acc-body = {
      set par(spacing: 0pt)
      if acc.at("title", default: "") != "" {
        [#acc.name \ #acc.at("department", default: "") \ #acc.title]
      } else {
        [#acc.name \ #acc.at("department", default: "")]
      }
    }
    sig += ([Accepted by:], acc-body)
  }

  // Emit title page content
  {
    set par(spacing: 0pt, first-line-indent: 0pt)
    set text(size: 12pt)

    // ─ Title ─
    align(center, text(size: 17.28pt, weight: "bold", title))

    v(12pt); v(1.5fr)

    // ─ Author block ─
    align(center)[
      by
      #v(7.5pt)
      #for (i, a) in authors.enumerate() {
        text(size: 14.4pt, a.name)
        for pd in a.at("prev-degrees", default: ()) {
          linebreak()
          text(size: 12pt, pd)
        }
        if i < authors.len() - 1 { linebreak(); [and] }
      }
    ]

    v(12pt); v(1.5fr)

    // ─ Degree / Institution block ─
    align(center)[
      Submitted to #dept-line \
      in partial fulfillment of the requirements for the #deg-word of
      #v(7.5pt)
      #for d in degrees {
        tracked(d.name)
        v(7.5pt)
      }
      at the
      #v(7.5pt)
      #tracked(institution)
      #v(7.5pt)
      #degree-month #degree-year
    ]

    v(12pt); v(2fr)

    // ─ Copyright ─
    // First line: "© year name. All rights reserved." (or CC license line)
    // Second paragraph: MIT permission text
    let cr-line = if cc-license != none {
      [This work is licensed under a #cc-license.name license.]
    } else {
      [All rights reserved.]
    }
    align(center)[© #degree-year #author-names. #cr-line]
    v(0.5em)
    align(center)[#_mit-permission(authors.len())]

    v(18pt); v(2fr)

    // ─ Signature block ─
    grid(
      columns: (auto, 1fr),
      column-gutter: 1em,
      row-gutter: 0pt,
      align: (left + top, left + top),
      ..sig,
    )

    v(12fr)
  }
}

// ── Committee members page ───────────────────────────────────────────────────
#let _make-committee-page(supervisors, readers) = {
  let sup-label = if supervisors.len() > 1 { "Thesis Supervisors" } else { "Thesis Supervisor" }
  let read-label = if readers.len() > 1 { "Thesis Readers" } else { "Thesis Reader" }

  {
    set par(spacing: 0pt, first-line-indent: 0pt)

    v(56pt)

    // "THESIS COMMITTEE" — right-aligned, bold Large, tracked
    align(right,
      text(size: 17.28pt, weight: "bold", tracking: 0.06em)[THESIS COMMITTEE]
    )

    v(56pt)

    // Supervisor subheading — right-aligned, small caps, Large, tracked
    align(right, text(size: 14.4pt, tracking: 0.06em, smallcaps(sup-label)))
    v(12pt)

    for s in supervisors {
      align(right)[
        *#s.name*\
        #emph[#s.title]\
        #if s.at("department", default: "") != "" { emph(s.department) }
      ]
      v(14pt)
    }

    v(32pt)

    // Reader subheading
    align(right, text(size: 14.4pt, tracking: 0.06em, smallcaps(read-label)))
    v(12pt)

    for r in readers {
      align(right)[
        *#r.name*\
        #emph[#r.title]\
        #if r.at("department", default: "") != "" { emph(r.department) }
      ]
      v(14pt)
    }

    v(1fr)  // Push content to top (mirrors 0pt plus 16fill at bottom)
  }
}

// ── Abstract page ────────────────────────────────────────────────────────────
#let _make-abstract-page(title, authors, degrees, supervisors, thesis-date, abstract-body) = {
  let dept-items = degrees.filter(d => d.at("department", default: "") != "")
                          .map(d => "the " + d.department)
  let dept-line = dept-items.join(" and ")
  let deg-word = if degrees.len() > 1 { "degrees" } else { "degree" }

  {
    set par(spacing: 0pt, first-line-indent: 0pt)

    // Centered header block
    align(center)[
      #text(size: 14.4pt, weight: "bold", title)
      #v(0.5em)
      by
      #v(0.5em)
      #authors.map(a => a.name).join(" and ")
      #v(0.5em)
      Submitted to #dept-line \
      on #thesis-date in partial fulfillment of the requirements for the #deg-word of
      #v(6pt)
      #for d in degrees {
        tracked(d.name)
        v(6pt)
      }
    ]

    v(2em)  // 2\baselineskip

    // "ABSTRACT" label (left-aligned, bold)
    text(weight: "bold")[ABSTRACT]
    v(0.5em)

    // Abstract body
    {
      set par(first-line-indent: 1.5em, spacing: 0pt)
      abstract-body
    }

    // Supervisor info at bottom
    v(1em)
    {
      set par(spacing: 0pt, first-line-indent: 0pt)
      for (i, s) in supervisors.enumerate() {
        [Thesis supervisor: #s.name \ Title: #s.title]
        if i < supervisors.len() - 1 { v(12pt) }
      }
    }
  }
}

// ── Start appendix mode ──────────────────────────────────────────────────────
// Both updates must be returned as concatenated content.
#let start-appendix() = [
  #_in-appendix.update(true)
  #counter(heading).update(0)
]

// ── Main template function ───────────────────────────────────────────────────
#let mitthesis(
  title:        [],
  authors:      (),
  degrees:      (),
  supervisors:  (),
  readers:      (),
  acceptors:    (),
  degree-month: "",
  degree-year:  "",
  thesis-date:  "",
  institution:  "Massachusetts Institute of Technology",
  cc-license:   none,
  abstract-body: [],
  body,
) = {

  // ── Document metadata ────────────────────────────────────────────────────
  set document(
    title:  title,
    author: authors.map(a => a.name).join(", "),
  )

  // ── Page layout ──────────────────────────────────────────────────────────
  // Footer: page number centred on all pages except the title page (page 1).
  set page(
    paper:   "us-letter",
    margin:  (top: 1in, bottom: 1in, left: 1in, right: 1in),
    numbering: none,
    header:  none,
    footer:  context {
      let pg = counter(page).get().first()
      if pg > 1 {
        set text(size: 12pt, font: "New Computer Modern")
        align(center, str(pg))
      }
    },
    // footskip ≈ 0.5 in; Typst footer-descent is measured from baseline of last
    // text line to baseline of footer.  We approximate here.
    footer-descent: 24pt,
  )

  // ── Typography ───────────────────────────────────────────────────────────
  set text(
    font:   "New Computer Modern",
    size:   12pt,
    lang:   "en",
    region: "US",
  )
  show math.equation: set text(font: "New Computer Modern Math")

  set par(
    leading:           0.5em,    // 0.5em ≈ 14.5pt baseline-to-baseline (matches LaTeX \baselineskip)
    spacing:           0.5em,    // must equal leading: in LaTeX \baselineskip governs ALL adjacent
                                 // baselines (within and between paragraphs), so inter-para gap
                                 // = line_height + spacing must equal line_height + leading
                                 // (\parskip=0pt means no *extra* space beyond one baseline skip)
    first-line-indent: 1.5em,    // \parindent = 1.5em at 12pt
    justify:           true,
  )

  // ── Heading numbering (switches at appendix) ──────────────────────────────
  // LaTeX report class: secnumdepth=2, so \subsubsection (level 4 in Typst)
  // and deeper are unnumbered.
  set heading(
    numbering: (..nums) => context {
      if nums.pos().len() > 3 { return none }  // level 4+ → unnumbered
      if _in-appendix.get() {
        numbering("A.1.1", ..nums)
      } else {
        numbering("1.1.1", ..nums)
      }
    }
  )

  // ── Level 1: Chapter / Appendix ──────────────────────────────────────────
  // Mirrors report.cls @makechapterhead: 50pt top space, 20pt between label
  // and title, 40pt after title.  Unnumbered chapters omit the label line.
  show heading.where(level: 1): it => [
    // Only reset per-chapter counters for numbered chapters/appendices,
    // not for unnumbered front-matter headings like List of Figures.
    #if it.numbering != none {
      counter(math.equation).update(0)
      counter(figure.where(kind: image)).update(0)
      counter(figure.where(kind: table)).update(0)
    }
    #pagebreak(to: "odd", weak: true)
    #v(50pt)
    #align(left)[
      #if it.numbering != none {
        context {
          let in-app = _in-appendix.get()
          let num = numbering(it.numbering, ..counter(heading).at(here()))
          block(
            above: 0pt, below: 0pt,
            text(size: 24.88pt, weight: "bold",
              if in-app [Appendix #num]
              else      [Chapter #num]
            ),
          )
        }
        v(20pt)
      }
      #block(
        above: 0pt, below: 0pt,
        text(size: 24.88pt, weight: "bold", it.body),
      )
    ]
    #v(40pt)
  ]

  // ── Level 2: Section ─────────────────────────────────────────────────────
  // \Large\bfseries\raggedright, before: 3.5ex ≈ 15pt, after: 2.3ex ≈ 10pt
  show heading.where(level: 2): it => [
    #v(15pt, weak: true)
    #align(left)[
      #block(
        above: 0pt, below: 0pt,
        text(size: 17.28pt, weight: "bold")[
          #context if it.numbering != none [#numbering(it.numbering, ..counter(heading).at(here()))#h(1em)]#it.body
        ],
      )
    ]
    #v(10pt, weak: true)
  ]

  // ── Level 3: Subsection ───────────────────────────────────────────────────
  // \large\bfseries\raggedright, before: 3.25ex ≈ 14pt, after: 1.5ex ≈ 6.5pt
  show heading.where(level: 3): it => [
    #v(14pt, weak: true)
    #align(left)[
      #block(
        above: 0pt, below: 0pt,
        text(size: 14.4pt, weight: "bold")[
          #context if it.numbering != none [#numbering(it.numbering, ..counter(heading).at(here()))#h(1em)]#it.body
        ],
      )
    ]
    #v(6.5pt, weak: true)
  ]

  // ── Level 4: Subsubsection ────────────────────────────────────────────────
  // \normalsize\bfseries, before: 3.25ex ≈ 14pt, after: 1.5ex ≈ 6.5pt
  show heading.where(level: 4): it => [
    #v(14pt, weak: true)
    #align(left)[
      #block(
        above: 0pt, below: 0pt,
        text(size: 12pt, weight: "bold")[
          #context if it.numbering != none [#numbering(it.numbering, ..counter(heading).at(here()))#h(1em)]#it.body
        ],
      )
    ]
    #v(6.5pt, weak: true)
  ]

  // ── Equations: numbered (chapter).(equation) ─────────────────────────────
  set math.equation(
    numbering: num => context {
      let ch = counter(heading).at(here()).first()
      let in-app = _in-appendix.at(here())
      let prefix = if in-app { numbering("A", ch) } else { str(ch) }
      "(" + prefix + "." + str(num) + ")"
    },
    supplement: [Equation],
  )

  // ── Figures: numbered (chapter).(figure) ─────────────────────────────────
  set figure(
    numbering: num => context {
      let ch = counter(heading).at(here()).first()
      let in-app = _in-appendix.at(here())
      let prefix = if in-app { numbering("A", ch) } else { str(ch) }
      prefix + "." + str(num)
    },
  )

  // ── Table captions above the table (LaTeX convention) ───────────────────
  show figure.where(kind: table): set figure.caption(position: top)

  // ── Multi-page tables: figures are non-breakable by default in Typst ─────
  // Without this, a long table overflows the page bottom instead of breaking.
  show figure.where(kind: table): set block(breakable: true)

  // ── Figure captions: bold label + colon, small text ──────────────────────
  // Mirrors mydesign.tex: labelfont=bf, labelsep=colon; caption text \small
  show figure.caption: it => {
    set text(size: 10.95pt)
    context {
      let label = text(weight: "bold")[#it.supplement #it.counter.display(it.numbering):] + [ ]
      label + it.body
    }
  }

  // ── Link / reference colours ──────────────────────────────────────────────
  show link: set text(fill: link-color)
  show ref:  set text(fill: link-color)

  // ── Outline entry styling (TOC + LoF + LoT) ──────────────────────────────
  // Suppress paragraph first-line-indent inside every outline so that the
  // global 1.5em first-line-indent does not leak into TOC entry text.
  show outline: set par(first-line-indent: 0pt)

  // All entries are explicitly reconstructed for predictable indentation and
  // blue link color. The main outline uses indent: 0pt; indentation here
  // mirrors the LaTeX report class TOC defaults:
  //   Level 1: 0em   Level 2: 1.5em   Level 3: 3.8em   Level 4: 7.0em
  show outline.entry: it => {
    if it.element.func() == figure {
      // ── LoF / LoT body entries ─────────────────────────────────────────
      context {
        let loc = it.element.location()
        let fig = it.element
        let pg = counter(page).at(loc).first()
        let ch = counter(heading).at(loc).first()
        let in-app = _in-appendix.at(loc)
        let ch-str = if in-app { numbering("A", ch) } else { str(ch) }
        let kind-counter = if fig.kind == image {
          counter(figure.where(kind: image))
        } else {
          counter(figure.where(kind: table))
        }
        let fig-num = ch-str + "." + str(kind-counter.at(loc).first())
        block(above: 4pt, below: 4pt,
          link(loc)[
            #text(weight: "bold")[#fig.supplement #fig-num:]
            #h(0.5em)
            #fig.caption.body
            #box(width: 1fr, repeat[.])
            #str(pg)
          ]
        )
      }
    } else {
      // ── TOC heading entries ────────────────────────────────────────────
      // All level/numbering checks are done OUTSIDE context to avoid any
      // potential evaluation-order issues with it.level inside context {}.
      let unnumbered = it.element.numbering == none
      if it.level == 1 and unnumbered {
        // Front/back matter (LoF, LoT, References) — italic blue, flush left
        block(above: 5pt, below: 0pt,
          context {
            let loc = it.element.location()
            let pg = counter(page).at(loc).first()
            text(fill: link-color, emph(link(loc)[
              #it.element.body
              #box(width: 1fr, repeat[.])
              #str(pg)
            ]))
          }
        )
      } else if it.level == 1 {
        // Chapter/appendix — bold blue, flush left, extra space above
        [
          #v(6pt, weak: true)
          #context {
            let loc = it.element.location()
            let pg = counter(page).at(loc).first()
            let in-app = _in-appendix.at(loc)
            let nums = counter(heading).at(loc)
            let num-str = if in-app { numbering("A", nums.first()) } else { str(nums.first()) }
            strong(text(fill: link-color, link(loc)[
              #num-str
              #h(1em)
              #it.element.body
              #box(width: 1fr, repeat[.])
              #str(pg)
            ]))
          }
        ]
      } else {
        // Level 2, 3, 4 — indented blue (LaTeX report class indents)
        let indent = if it.level == 2 { 1.5em } else if it.level == 3 { 3.8em } else { 7.0em }
        pad(left: indent,
          context {
            let loc = it.element.location()
            let pg = counter(page).at(loc).first()
            let in-app = _in-appendix.at(loc)
            let nums = counter(heading).at(loc)
            let num-str = if not unnumbered {
              if in-app { numbering("A.1.1", ..nums) } else { numbering("1.1.1", ..nums) }
            } else { "" }
            text(fill: link-color, link(loc)[
              #if not unnumbered [#num-str#h(0.5em)]
              #it.element.body
              #box(width: 1fr, repeat[.])
              #str(pg)
            ])
          }
        )
      }
    }
  }

  // ── Raw (code listing) block styling ─────────────────────────────────────
  // Approximates listings package with light blue background (CadetBlue!15)
  show raw.where(block: true): it => {
    set text(font: ("DejaVu Sans Mono", "Courier New"), size: 10pt)
    block(
      fill:    rgb("#D4E8E8"),
      width:   100%,
      inset:   (x: 8pt, y: 6pt),
      radius:  2pt,
      it,
    )
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  Front matter pages
  // ══════════════════════════════════════════════════════════════════════════

  // Page 1 — Title page (footer suppressed via conditional in set page above)
  _make-title-page(
    title, authors, degrees, supervisors, acceptors,
    degree-month, degree-year, thesis-date, institution, cc-license,
  )

  // Page 2 — blank verso
  pagebreak(to: "odd")

  // Pages 3–4 — Thesis Committee page (only when readers are present)
  if readers.len() > 0 {
    _make-committee-page(supervisors, readers)
    pagebreak(to: "odd")   // blank verso
  }

  // Pages 5–6 — Abstract
  _make-abstract-page(title, authors, degrees, supervisors, thesis-date, abstract-body)
  pagebreak(to: "odd")   // blank verso

  // ══════════════════════════════════════════════════════════════════════════
  //  Body (acknowledgments, TOC, chapters, appendices, bibliography)
  // ══════════════════════════════════════════════════════════════════════════
  body
}
