// ============================================================================
//  classic-msc-thesis  (0.1.0)
//  A classic, formal, scientific thesis layout for Typst.
//  Author: Alejandro Cobos (@Cobos-Bioinfo)
//
//  Exposes:
//    thesis(..)        the document wrapper (front matter + body + back matter)
//    abbrev-table(..)  renders a two-column List of Abbreviations
//    flex-caption(..)  a caption with a long form (under the figure) and a
//                      short form (in the List of Figures / Tables)
//
//  Design: black serif headings, one-sided / digital-first layout, roman front
//  matter followed by arabic main matter, author-year (APA) citations. Links
//  and cross-references stay black (the thesis is meant to be printed) but are
//  still clickable in the PDF.
// ============================================================================

// ---------------------------------------------------------------------------
//  Short captions for the List of Figures / List of Tables.
//  Use in a figure like:
//      caption: flex-caption(
//        [Full caption shown beneath the figure ...],   // long
//        [Short title shown in the List of Figures],    // short
//      )
//  The long form renders under the figure; the short form renders in the lists.
//  A plain `caption: [...]` still works and shows in full in both places.
// ---------------------------------------------------------------------------
#let _in-outline = state("thesis-in-outline", false)
#let flex-caption(long, short) = context {
  if _in-outline.get() { short } else { long }
}

// When true, the next level-1 heading does not force a page break (used to keep
// the List of Tables on the same page as the List of Figures).
#let _no-break-before = state("thesis-no-break-before", false)

// ---------------------------------------------------------------------------
//  Helper: two-column abbreviations table.
//  `entries` is an array of (short, long) pairs, e.g.
//      (("DNA", "Deoxyribonucleic Acid"), ("API", "Application Programming ..."))
// ---------------------------------------------------------------------------
#let abbrev-table(entries) = table(
  columns: (auto, 1fr),
  stroke: none,
  align: (left + top, left + top),
  inset: (x: 0pt, y: 5pt),
  column-gutter: 1.2em,
  ..entries.map(((short, long)) => (strong(short), [#long])).flatten()
)

// ---------------------------------------------------------------------------
//  Main template
// ---------------------------------------------------------------------------
#let thesis(
  // --- metadata ---
  title: "Thesis Title",
  subtitle: none,
  author: "Author Name",
  degree: "MSc in Bioinformatics",
  university: none,
  department: none,
  supervisor: none,
  tutor: none,
  date: datetime.today(),
  location: none,          // e.g. "Barcelona" (printed with the date)
  institute: none,         // research institute where the work was carried out
  logo: none,              // primary logo (e.g. university) — image or content
  logo-secondary: none,    // secondary logo (e.g. research institute)
  // --- front-matter content blocks (none => section omitted) ---
  certificate: none,
  acknowledgments: none,
  abstract: none,
  keywords: none,
  abbreviations: none,
  // --- toggles ---
  show-toc: true,
  show-list-of-figures: true,
  show-list-of-tables: true,
  heading-numbering: true,
  // --- back matter ---
  bibliography: none,
  appendix: none,
  // --- document body ---
  body,
) = {
  // ---- document + base page ----
  set document(author: author, title: title)
  set page(
    paper: "a4",
    margin: (left: 2.5cm, right: 2.5cm, top: 2.5cm, bottom: 2.5cm),
  )

  // ---- typography ----
  set text(font: "New Computer Modern", size: 11pt, lang: "en")
  set par(justify: true, leading: 0.65em)

  // ---- headings (classic: all black serif) ----
  show heading.where(level: 1): it => {
    context { if not _no-break-before.get() { pagebreak(weak: true) } }
    v(0.4cm)
    block(below: 0.5em, text(size: 20pt, weight: "bold", it))
    line(length: 100%, stroke: 0.6pt + luma(130))
    v(0.6em)
  }
  show heading.where(level: 2): it => block(
    above: 1.3em, below: 0.6em, text(size: 14pt, weight: "bold", it),
  )
  show heading.where(level: 3): it => block(
    above: 1.1em, below: 0.5em, text(size: 12pt, weight: "bold", it),
  )
  show heading.where(level: 4): it => block(
    above: 1.0em, below: 0.4em, text(size: 11pt, weight: "bold", style: "italic", it),
  )

  // ---- cross-references: render figures/tables as "Fig. N" / "Table N".
  //      No colour or highlight anywhere — the thesis is meant to be printed,
  //      so links and references stay black (still clickable in the PDF).
  show ref: it => {
    let el = it.element
    if el != none and el.func() == figure {
      if el.kind == image {
        let n = counter(figure.where(kind: image)).at(el.location()).first()
        link(it.target)[Fig. #n]
      } else if el.kind == table {
        let n = counter(figure.where(kind: table)).at(el.location()).first()
        link(it.target)[Table #n]
      } else {
        it
      }
    } else {
      // headings, citations, everything else: default rendering, no colour
      it
    }
  }

  // ---- flex-caption: signal to captions when they are being rendered in an
  //      outline (List of Figures / List of Tables) so they show the short form
  show outline: it => {
    _in-outline.update(true)
    it
    _in-outline.update(false)
  }

  // ---- figures & tables ----
  // separate counters for images and tables; captions above tables
  show figure.where(kind: image): set figure(numbering: "1")
  show figure.where(kind: table): set figure(numbering: "1")
  show figure.where(kind: table): set figure.caption(position: top)
  show figure: it => {
    set align(center)
    it
    v(0.4em)
  }
  show figure.caption: set text(size: 9.5pt)

  // booktabs-style table rules
  set table(
    stroke: (x, y) => if y == 0 { (bottom: 0.9pt + black) } else { (bottom: 0.4pt + luma(150)) },
    inset: (x: 8pt, y: 5pt),
  )

  // ---- block quotes (e.g. the hypothesis) ----
  show quote.where(block: true): it => block(
    inset: (left: 1.2em, top: 0.4em, bottom: 0.4em),
    stroke: (left: 2pt + luma(180)),
    text(style: "italic", it.body),
  )

  // ---- code / raw ----
  show raw.where(block: true): it => block(
    fill: luma(244), inset: 9pt, radius: 3pt, width: 100%, text(size: 9pt, it),
  )
  show raw.where(block: false): it => box(
    fill: luma(244), outset: (y: 2pt, x: 1pt), radius: 2pt, it,
  )

  // =========================================================================
  //  TITLE PAGE  (rule-framed: the thin heading rule is the connecting motif)
  // =========================================================================
  set page(numbering: "i")
  counter(page).update(1)
  page(header: none, footer: none)[
    #set align(center)
    #set par(justify: false, leading: 0.6em)

    // --- institutional header (top) ---
    #v(0.2cm)
    #{
      let logos = ()
      if logo != none { logos.push(logo) }
      if logo-secondary != none { logos.push(logo-secondary) }
      if logos.len() > 0 {
        grid(columns: logos.map(_ => auto), column-gutter: 1.4cm, align: bottom, ..logos)
        v(0.9cm)
      }
    }
    #if university != none { text(size: 13pt, weight: "bold")[#university]; linebreak() }
    #if department != none { text(size: 11pt, fill: luma(90))[#department]; linebreak() }
    #if degree != none { v(0.35cm); text(size: 12pt)[#degree] }

    #v(1fr)

    // --- title, framed by two rules ---
    #line(length: 100%, stroke: 0.8pt + black)
    #v(0.55cm)
    #text(size: 22pt, weight: "bold")[#title]
    #if subtitle != none { v(0.5cm); text(size: 14pt, style: "italic")[#subtitle] }
    #v(0.55cm)
    #line(length: 100%, stroke: 0.8pt + black)

    #v(0.7cm)
    #text(size: 13pt)[Master's Thesis]
    #if institute != none {
      linebreak()
      v(0.15cm)
      text(size: 11pt, fill: luma(80))[carried out at the #institute]
    }

    #v(1fr)

    // --- author, supervision, and date (bottom) ---
    #text(size: 14pt, weight: "bold")[#author]
    #v(0.8cm)
    #if supervisor != none { text(size: 11pt)[Supervisor: #supervisor]; linebreak() }
    #if tutor != none { text(size: 11pt)[Tutor: #tutor]; linebreak() }
    #v(0.8cm)
    #{
      let place = if location != none { location + ", " } else { "" }
      text(size: 11pt, fill: luma(80))[#place#date.display("[month repr:long] [year]")]
    }
  ]

  // =========================================================================
  //  FRONT MATTER  (roman numerals; no running header)
  // =========================================================================
  set heading(numbering: none)
  set page(
    header: none,
    footer: context align(center, text(size: 9pt, fill: luma(110), counter(page).display())),
  )

  // Certificate of Direction — rendered as raw user content (full control)
  if certificate != none {
    certificate
    pagebreak(weak: true)
  }

  // Acknowledgments
  if acknowledgments != none {
    heading(level: 1, outlined: true)[Acknowledgments]
    acknowledgments
  }

  // Abstract (+ optional keywords)
  if abstract != none {
    heading(level: 1, outlined: true)[Abstract]
    abstract
    if keywords != none {
      v(1em)
      text(weight: "bold")[Keywords: ]
      keywords
    }
  }

  // Table of Contents
  if show-toc {
    heading(level: 1, outlined: false)[Contents]
    // bold the chapter (level-1) entries; scoped to this outline only
    {
      show outline.entry.where(level: 1): it => strong(it)
      outline(title: none, depth: 3, indent: auto)
    }
  }

  // List of Figures and List of Tables (kept together on one page)
  if show-list-of-figures {
    heading(level: 1, outlined: true)[List of Figures]
    outline(title: none, target: figure.where(kind: image))
  }
  if show-list-of-tables {
    // follow the List of Figures on the same page rather than breaking
    if show-list-of-figures { v(1.6em); _no-break-before.update(true) }
    heading(level: 1, outlined: true)[List of Tables]
    _no-break-before.update(false)
    outline(title: none, target: figure.where(kind: table))
  }

  // List of Abbreviations
  if abbreviations != none {
    heading(level: 1, outlined: true)[List of Abbreviations]
    abbrev-table(abbreviations)
  }

  // =========================================================================
  //  MAIN MATTER  (arabic numerals; running chapter header)
  // =========================================================================
  counter(heading).update(0)
  set heading(numbering: if heading-numbering { "1.1" } else { none })
  set page(
    numbering: "1",
    header: context {
      let cur = here().page()
      let h1 = query(heading.where(level: 1))
      let starts = h1.filter(h => h.location().page() == cur)
      let prior = h1.filter(h => h.location().page() < cur)
      // suppress on a chapter's opening page; otherwise show the running title
      if starts.len() == 0 and prior.len() > 0 {
        set text(size: 9pt, fill: luma(120))
        prior.last().body
        v(-0.7em)
        line(length: 100%, stroke: 0.4pt + luma(190))
      }
    },
    footer: context align(center, text(size: 9pt, fill: luma(110), counter(page).display())),
  )
  counter(page).update(1)

  body

  // =========================================================================
  //  BACK MATTER
  // =========================================================================
  // Bibliography (unnumbered heading, listed in the TOC)
  if bibliography != none {
    set heading(numbering: none)
    bibliography
  }

  // Appendix (after references; heading numbering A, A.1, ...)
  if appendix != none {
    counter(heading).update(0)
    set heading(numbering: "A.1")
    appendix
  }
}
