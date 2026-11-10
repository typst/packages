// cardinal-su-thesis — Ph.D. dissertation / Engineer thesis at Stanford
//
// Formatting follows the Office of the University Registrar's published
// requirements. See REQUIREMENTS.md for a clause-by-clause mapping with
// source links. The Registrar does not endorse or verify any template,
// including this one — you are responsible for checking your own output.

// ─── Style defaults ──────────────────────────────────────────────────────────

// Level 1..4 heading styles. `page-break: true` forces the heading onto a new
// page (used for chapters).
#let default-heading-styles = (
  (size: 20pt, above: 1.5em, below: 0.75em, weight: "bold", style: "normal", page-break: true, leading: 0.8em),
  (size: 16pt, above: 1em, below: 0.5em, weight: "bold", style: "normal", page-break: false, leading: 0.8em),
  (size: 12pt, above: 0.75em, below: 0.375em, weight: "bold", style: "normal", page-break: false, leading: 1em),
  (size: 11pt, above: 0.3em, below: 0.25em, weight: "regular", style: "italic", page-break: false, leading: 1em),
)

// The "Chapter N" label that sits above a chapter's H1.
#let default-chapter-title-style = (
  size: 24pt, vspace: 0em, weight: "bold", style: "normal",
)

// ─── Internal state ──────────────────────────────────────────────────────────
//
// Helpers such as `fig-legend` are called from chapter files, where the
// arguments passed to `thesis()` are not in scope. `thesis()` therefore
// publishes its resolved configuration into this state, and those helpers
// read it back via `context`. Everything else is closed over directly by the
// show rules defined inside `thesis()`.

#let _defaults = (
  chapter-drop: 1/3,
  margin-outer: 1in,
  chapter-title-style: default-chapter-title-style,
  heading-styles: default-heading-styles,
  caption-size: 9pt,
  caption-leading: 0.6em,
  caption-legend-gap: 0.75em,
  header-size: 9pt,
  chapter-label: "Chapter",
  appendix-label: "Appendix",
  header-sep: ". ",
  running-heads: true,
  double-sided: true,
)

#let _cfg = state("cardinal-su-thesis-cfg", _defaults)

// Signals to the H1 show rule that `chapter-title` already applied the drop.
#let _chapter-title-active = state("cardinal-su-thesis-chapter-active", false)

// Tracks whether we are in the appendix (affects labels and numbering prefix).
#let _in-appendix = state("cardinal-su-thesis-in-appendix", false)

// Optional abbreviated running head set via `chapter-title(short: ..)`.
#let _running-head-override = state("cardinal-su-thesis-running-head", none)

// Chapter prefix for figure, table, note, and methods numbers: the chapter
// number in the main body, the appendix letter inside an appendix. Call from a
// `context` block.
#let _chapter-prefix(loc: none) = {
  let h = if loc == none { counter(heading).get() } else { counter(heading).at(loc) }
  let in-app = if loc == none { _in-appendix.get() } else { _in-appendix.at(loc) }
  if in-app { numbering("A", h.first()) } else { str(h.first()) }
}

// ─── Authoring helpers ───────────────────────────────────────────────────────

// Chapter label above the H1 — not numbered, not in the table of contents.
//
//   #chapter-title[Chapter 1]
//   = Introduction
//
// Pass `short:` to use an abbreviated string in the running head:
//
//   #chapter-title(short: [Regulatory maps])[Chapter 2]
#let chapter-title(short: none, body) = {
  pagebreak(weak: true)
  context {
    let c = _cfg.get()
    let s = c.chapter-title-style
    v(page.height * c.chapter-drop - c.margin-outer)
    text(size: s.size, weight: s.weight, style: s.style)[#body]
    v(s.vspace / 2)
  }
  _chapter-title-active.update(true)
  _running-head-override.update(short)
}

// Full figure legend — place immediately after the `#figure(..)` call.
// The figure's `caption:` should hold only the short title, since that is
// what appears in the List of Figures. The caption is printed above the legend
// on the page, so the legend carries the description alone and does not repeat
// the title.
//
//   #figure(image("figures/f1.jpg"), caption: [Short title]) <fig-one>
//   #fig-legend[*(a)* Description of the first panel. *(b)* And the second.]
#let fig-legend(body) = context {
  let c = _cfg.get()
  v(c.caption-legend-gap, weak: true)
  text(
    size: c.caption-size,
    par(leading: c.caption-leading, first-line-indent: 0pt)[#body],
  )
}

// Panel reference for running text, where the figure number is needed:
// figpanel(<fig-one>, [a]) → "Figure 1a". Inside a legend, write the marker
// plainly as `*(a)*` instead — the caption above it already carries the number.
#let figpanel(label, panel) = [#ref(label)#strong(panel)]

// Inline citation number rendered on the baseline rather than as a superscript.
// Use `ref.~#refnum(<key>)` for a non-breaking space before the number.
#let refnum(key) = {
  show super: it => text(size: 1em, baseline: 0pt)[#it.body]
  cite(key)
}

// Supplementary table stub — a labelled entry pointing at an external file.
//
//   #supp-table(
//     [Benchmark results],
//     [One row per evaluated model.],
//     filename: "TableS1.tsv",
//   ) <supp-tab-bench>
//
// Cite with @supp-tab-bench → "Table A.1"
#let supp-table(title, description, filename: none) = figure(
  [],
  kind: "supp-table",
  supplement: [Table],
  caption: {
    let file-line = if filename != none { [\ _Name:_ #raw(filename)] } else { [] }
    [*#title.* #description#file-line]
  },
)

// Supplementary note — a numbered callout in the appendix.
//
//   #supp-note[Indirect effects][Body of the note.] <supp-note-indirect>
//
// Cite with @supp-note-indirect → "Note A.1"
#let supp-note(title, body) = figure(
  body,
  kind: "supp-note",
  supplement: [Note],
  numbering: "1",
  caption: title,
)

// Methods subsection heading with its own numbering and label support.
//
//   #method-heading[Genome build] <method-genome>
//
// Cite with @method-genome → "Methods A.1"
#let method-heading(title) = figure(
  [],
  kind: "method",
  supplement: [Methods],
  numbering: "1",
  caption: title,
  placement: none,
  outlined: false,
)

// ─── Document-structure helpers ──────────────────────────────────────────────

// Leaves headings unnumbered, for the preliminary pages.
// Apply as `#show: front-matter` before the Abstract.
#let front-matter(body) = {
  set heading(numbering: none)
  body
}

// Switches to letter-numbered headings for the appendices.
// Apply as `#show: appendix` after the last chapter.
// NOTE: the parameter is deliberately not called `numbering`, which would
// shadow the builtin `numbering()` function inside the body.
#let appendix(heading-numbering: "A.1", body) = {
  counter(heading).update(0)
  _in-appendix.update(true)
  set heading(numbering: heading-numbering)
  body
}

// Switches to Arabic pagination and turns on running heads.
// Apply as `#show: main-body` at the start of the main text.
//
// Page numbers stay wherever `thesis()` put them; only the running head
// lives in the header, so pagination placement is identical in the
// preliminary pages and the main body.
// NOTE: the parameter is deliberately not called `numbering`, which would
// shadow the builtin `numbering()` function used in the running head below.
#let main-body(heading-numbering: "1.1", body) = {
  // Reset so chapters number from 1 regardless of unnumbered front matter.
  counter(heading).update(0)
  // Restore numbering, since `front-matter` switched it off for everything
  // that followed it.
  set heading(numbering: heading-numbering)
  set page(
    numbering: "1",
    header: context {
      let c = _cfg.get()
      if c.running-heads {
        let all-chapters = query(heading.where(level: 1))
        let is-chapter-page = all-chapters.any(h => h.location().page() == here().page())
        let prev-chapters = query(heading.where(level: 1).before(here()))
        // No running head on a chapter-opening page or before the first chapter.
        if not (is-chapter-page or prev-chapters.len() == 0) {
          let ch = prev-chapters.last()
          let ch-num = if ch.numbering != none {
            numbering(ch.numbering, counter(heading).at(ch.location()).first())
          } else { "" }
          let label = if _in-appendix.get() { c.appendix-label } else { c.chapter-label }
          let override = _running-head-override.get()
          let head-text = if override != none { override } else { ch.body }
          let running = text(size: c.header-size, style: "italic")[
            #if ch-num != "" [#label #ch-num#c.header-sep]#head-text
          ]
          // Running head on the inner edge: left on recto, right on verso.
          if not c.double-sided or calc.odd(here().page()) { running } else {
            align(right, running)
          }
        }
      }
    },
  )
  counter(page).update(1)
  body
}

// ─── The template ────────────────────────────────────────────────────────────

#let thesis(
  // Identity ---------------------------------------------------------------
  title: "Thesis Title",
  // Optional line-broken form of the title for the title page, e.g.
  // [First half of the title \ second half of the title]
  title-display: none,
  author: "Author Name",
  date: datetime.today(),
  // "phd" → "A DISSERTATION" / "DOCTOR OF PHILOSOPHY"
  // "engineer" → "A THESIS" / "ENGINEER"
  degree: "phd",
  // Exactly one of these. `program` renders "PROGRAM IN ..", otherwise
  // `department` renders "DEPARTMENT OF ..".
  department: "Your Department",
  program: none,

  // Layout -----------------------------------------------------------------
  paper: "us-letter",
  margin-inner: 1.5in,
  margin-outer: 1in,
  // Distance from the page edge to the page number.
  page-number-margin: 0.5in,
  // Fraction of the page height at which a chapter title starts.
  chapter-drop: 1/3,
  // true  → binding edge alternates (inner margin), running heads mirrored
  // false → binding edge always on the left
  double-sided: true,
  // The Registrar's primary instruction is that the Abstract itself carries
  // page iv. Set this to true only when printing double-sided with each
  // section opening on a right-hand page: a blank page then takes iv and the
  // Abstract becomes v. Both are explicitly permitted.
  blank-page-iv: false,

  // Typography -------------------------------------------------------------
  // "New Computer Modern" ships with Typst, so it resolves everywhere without
  // installing anything, and Computer Modern is on the Registrar's list of
  // acceptable families.
  body-font: "New Computer Modern",
  // Typst bundles DejaVu Sans Mono, so this never warns. The Registrar's list
  // names Courier for monospace — set `mono-font: "Courier New"` if you use
  // code blocks and want to stay strictly on that list.
  mono-font: "DejaVu Sans Mono",
  body-size: 10pt,
  // 1.32em ≈ 1.5 × the font size, satisfying "one-and-a-half spaced".
  body-leading: 1.32em,
  par-indent: 1.2em,
  par-justify: true,

  // Title page -------------------------------------------------------------
  title-size: 10pt,
  title-leading: 0.75em,
  title-vspace: 8em,
  // "page"    → centred on the physical page
  // "margins" → centred within the margins, per the letter of the requirement
  title-page-centering: "page",
  // "standard" → title and degree block uppercase, author and date as written
  // "all"      → everything uppercase, matching the official samples
  // "none"     → nothing uppercased
  title-page-case: "standard",
  // Full override of the block between the title and the author. Use for the
  // GSB, GSE, Law (J.S.D.) and D.M.A. variants. Array of strings or content.
  title-page-lines: none,

  // Headings ---------------------------------------------------------------
  heading-styles: default-heading-styles,
  chapter-title-style: default-chapter-title-style,

  // Running heads and pagination -------------------------------------------
  running-heads: true,
  header-size: 9pt,
  chapter-label: "Chapter",
  appendix-label: "Appendix",
  header-sep: ". ",
  // "bottom-center" or "bottom-outer". Applied uniformly to every numbered
  // page so that placement is consistent throughout the document.
  page-number-position: "bottom-center",

  // Figures ----------------------------------------------------------------
  figure-supplement: [Figure],
  table-supplement: [Table],
  figure-sep: [: ],
  caption-size: 9pt,
  caption-leading: 0.6em,
  caption-legend-gap: 0.75em,
  supp-table-supplement: [Table],
  supp-table-sep: [: ],
  supp-note-supplement: [Note],
  method-supplement: [Methods],

  // Equations -------------------------------------------------------------
  // `auto` numbers display equations per chapter, e.g. (2.1), matching the
  // figure convention. Pass a pattern such as "(1)" for flat numbering, or
  // `none` to leave display equations unnumbered.
  equation-numbering: auto,

  body,
) = {
  // Publish the subset of configuration that authoring helpers need.
  _cfg.update((
    chapter-drop: chapter-drop,
    margin-outer: margin-outer,
    chapter-title-style: chapter-title-style,
    heading-styles: heading-styles,
    caption-size: caption-size,
    caption-leading: caption-leading,
    caption-legend-gap: caption-legend-gap,
    header-size: header-size,
    chapter-label: chapter-label,
    appendix-label: appendix-label,
    header-sep: header-sep,
    running-heads: running-heads,
    double-sided: double-sided,
  ))

  set document(title: title, author: author, date: date)
  set page(
    paper: paper,
    margin: if double-sided {
      (inside: margin-inner, rest: margin-outer)
    } else {
      (left: margin-inner, rest: margin-outer)
    },
  )
  // Font colour must be black.
  set text(font: body-font, size: body-size, fill: black, slashed-zero: true)
  show raw: set text(font: mono-font)
  set par(first-line-indent: (amount: par-indent, all: false), justify: par-justify)

  // Display equations, chapter-prefixed by default. The counter is reset by the
  // level-1 heading rule below.
  set math.equation(
    numbering: if equation-numbering == auto {
      n => context {
        let h = counter(heading).get().first()
        let prefix = if _in-appendix.get() { numbering("A", h) } else { str(h) }
        [(#prefix.#n)]
      }
    } else { equation-numbering },
  )

  // ── Figures ──────────────────────────────────────────────────────────────
  // Scoped per kind: a bare `set figure(supplement: ..)` would relabel tables
  // (and every custom kind) as "Figure" too.
  show figure.where(kind: image): set figure(supplement: figure-supplement)
  show figure.where(kind: table): set figure(supplement: table-supplement)
  // Tables conventionally carry the caption above the table body.
  show figure.where(kind: table): set figure.caption(position: top)
  set figure.caption(separator: figure-sep)
  show figure: set align(center)
  // Full text width, so that the caption and any `fig-legend` beneath it share
  // a left edge regardless of how wide the figure itself is.
  show figure.caption: it => align(
    left,
    context block(width: 100%)[
      #let n = it.counter.get().first()
      #par(leading: caption-leading, first-line-indent: 0pt)[
        #text(size: body-size)[*#it.supplement~#_chapter-prefix().#n#it.separator*]#text(size: caption-size)[*#it.body*]
      ]
    ],
  )

  // Intercept the custom figure kinds for bespoke rendering.
  //
  // GOTCHA: the `show figure: set align(center)` rule above wraps this entire
  // show-rule chain, so any block returned here is placed inside a centred
  // context. Two consequences, both worked around below:
  //   1. `set align(left)` must come *before* the block, at branch level. Doing
  //      it inside the block's content only affects the text, not the block's
  //      own placement, so a narrow block ends up centred.
  //   2. `block(breakable: true, ..)` is not enough when the content holds a
  //      large unbreakable child (an `enum`, say). Return a flat sequence with
  //      `set block(breakable: true)` in scope instead of wrapping it.
  show figure: it => {
    if it.kind == "supp-table" {
      set align(left)
      block(above: 1.2em, below: 0.4em)[
        #set text(size: caption-size)
        #par(leading: caption-leading, first-line-indent: 0pt)[
          *#supp-table-supplement~#context {
            let n = it.counter.display(it.numbering)
            [#_chapter-prefix().#n]
          }#supp-table-sep* #it.caption.body
        ]
      ]
    } else if it.kind == "supp-note" {
      set align(left)
      set block(breakable: true)
      v(1.5em, weak: true)
      heading(level: 3, numbering: none, outlined: false)[
        #supp-note-supplement~#context {
          let n = it.counter.display(it.numbering)
          [#_chapter-prefix().#n]
        }#if it.caption.body != [] [: #it.caption.body]
      ]
      it.body
      v(0.5em, weak: true)
    } else if it.kind == "method" {
      let s = heading-styles.at(2)
      set align(left)
      v(s.above)
      context {
        let n = it.counter.display(it.numbering)
        block(text(size: s.size, weight: s.weight, style: s.style)[
          #_chapter-prefix().#n. #it.caption.body
        ])
      }
      v(s.below)
    } else {
      it
    }
  }

  // Cross-references: bold and chapter-prefixed, e.g. @fig-x → **Figure 2.1**
  show ref: it => {
    if it.element != none and it.element.func() == figure {
      let loc = it.element.location()
      let kind = it.element.kind
      let supplement = if kind == "supp-table" { supp-table-supplement } else if kind == "supp-note" { supp-note-supplement } else if kind == "method" { method-supplement } else { it.element.supplement }
      // Count within the referenced figure's own kind, so that a table
      // reference reads off the table counter rather than the image counter.
      let target-kind = kind
      context {
        let n = counter(figure.where(kind: target-kind)).at(loc).first()
        strong[#supplement~#_chapter-prefix(loc: loc).#n]
      }
    } else {
      it
    }
  }

  // ── Outlines ─────────────────────────────────────────────────────────────
  show outline: it => {
    set par(first-line-indent: (amount: 0pt, all: false))
    it
  }
  show outline.entry.where(level: 1): it => {
    v(1.5em, weak: true)
    strong[#it.prefix() #it.body() #h(1fr) #it.page()]
  }
  show outline.entry.where(level: 2): it => {
    pad(left: 1.5em)[#it.prefix() #it.body() #box(width: 1fr, repeat[.]) #it.page()]
  }
  show outline.entry.where(level: 3): it => {
    pad(left: 3em)[#it.prefix() #it.body() #box(width: 1fr, repeat[.]) #it.page()]
  }
  // List of Figures / Tables entries, styled like TOC level 2.
  show outline.entry: it => {
    if it.element != none and it.element.func() == figure and it.element.kind not in ("supp-table", "supp-note", "method") {
      let cap = it.element.caption
      let loc = it.element.location()
      context {
        let n = counter(figure.where(kind: it.element.kind)).at(loc).first()
        block(width: 100%)[*#_chapter-prefix(loc: loc).#n#cap.separator*#cap.body #box(width: 1fr, repeat[.]) #it.page()]
      }
    } else {
      it
    }
  }

  // ── Headings ─────────────────────────────────────────────────────────────
  set heading(numbering: "1.1")
  show heading: it => {
    let s = heading-styles.at(it.level - 1)
    set text(hyphenate: false)
    set par(leading: s.leading)
    if it.level == 1 {
      // If chapter-title ran, the page break and drop are already applied.
      context if _chapter-title-active.get() {
        v(0.25em)
      } else {
        pagebreak(weak: true)
        v(page.height * chapter-drop - margin-outer)
        // No `chapter-title` for this chapter, so clear any abbreviation left
        // over from an earlier one rather than reusing it in the running head.
        _running-head-override.update(none)
      }
      _chapter-title-active.update(false)
      // Restart per-chapter counters.
      counter(figure.where(kind: image)).update(0)
      counter(figure.where(kind: table)).update(0)
      // Only the chapter-prefixed scheme resets per chapter; an explicit
      // pattern such as "(1)" is meant to run continuously.
      if equation-numbering == auto { counter(math.equation).update(0) }
      context if _in-appendix.get() {
        counter(figure.where(kind: "supp-table")).update(0)
        counter(figure.where(kind: "supp-note")).update(0)
        counter(figure.where(kind: "method")).update(0)
      }
    } else {
      if s.page-break { pagebreak(weak: true) }
      v(s.above)
    }
    // `sticky` keeps a heading with the text that follows it, so it cannot be
    // stranded at the foot of a page.
    block(sticky: true, text(size: s.size, weight: s.weight, style: s.style)[#it.body])
    v(s.below)
  }

  // ── Title page ───────────────────────────────────────────────────────────
  // Uppercase, no bold, no pagination, centred vertically and horizontally.
  let cased = (s) => if title-page-case == "none" { s } else { upper(s) }
  let degree-block = if title-page-lines != none { title-page-lines } else {
    let (kind, degree-name) = if degree == "engineer" {
      ("A Thesis", "Engineer")
    } else {
      ("A Dissertation", "Doctor of Philosophy")
    }
    let unit = if program != none {
      "Submitted to the Program in " + program
    } else {
      "Submitted to the Department of " + department
    }
    (
      kind,
      unit,
      "and the Committee on Graduate Studies",
      "of Stanford University",
      "in partial fulfillment of the requirements",
      "for the degree of",
      degree-name,
    )
  }
  let author-block = if title-page-case == "all" {
    (upper(author), upper(date.display("[month repr:long] [year]")))
  } else {
    (author, date.display("[month repr:long] [year]"))
  }

  // Centred and ragged: justification would spread the words of a title long
  // enough to wrap.
  set par(leading: title-leading, justify: false)
  let title-page = align(center)[
    #text(size: title-size)[#cased(if title-display != none { title-display } else { title })]
    #v(title-vspace)
    #text(size: title-size)[#degree-block.map(cased).join(linebreak())]
    #v(title-vspace)
    #text(size: body-size)[#author-block.join(linebreak())]
  ]

  // A `set` rule inside an `if` branch would scope to that branch, so the
  // foreground is computed first and applied at this level.
  //
  // A page foreground covers the whole sheet, not the text area, so the block
  // width has to be constrained explicitly or a title long enough to wrap runs
  // to the paper edge. Clearing the larger of the two margins on both sides
  // keeps the block centred on the sheet *and* inside the margins.
  set page(
    foreground: if title-page-centering == "margins" { none } else {
      // Centre on the physical page.
      align(center + horizon, context block(
        width: page.width - 2 * calc.max(margin-inner, margin-outer),
        title-page,
      ))
    },
  )
  if title-page-centering == "margins" {
    // Centre within the text area: the flow region is bounded by the margins.
    v(1fr)
    title-page
    v(1fr)
  }
  pagebreak()

  // ── Preliminary pages ────────────────────────────────────────────────────
  // Axess inserts the copyright page (ii) and signature page (iii) on
  // submission, so this document must not contain them. Physical numbering
  // therefore resumes at iv.
  counter(page).update(4)
  set page(
    numbering: "i",
    header: none,
    footer: none,
    foreground: context {
      if page.numbering != none {
        let inner = page-number-margin
        let folio = text(size: header-size, counter(page).display(page.numbering))
        if page-number-position == "bottom-outer" {
          if not double-sided or calc.odd(here().page()) {
            place(right + bottom, dx: -margin-outer, dy: -inner, folio)
          } else {
            place(left + bottom, dx: margin-outer, dy: -inner, folio)
          }
        } else {
          place(center + bottom, dy: -inner, folio)
        }
      }
    },
  )
  // `justify` is restored here: the title-page rule above switched it off, and
  // a `set` rule stays in effect for everything that follows it.
  set par(leading: body-leading, justify: par-justify)

  // "Physical pagination must begin immediately after the title page, on the
  // Abstract page using the number 'iv'." The blank-page-iv alternative exists
  // only for double-sided printing with each section opening on a recto.
  if blank-page-iv { pagebreak() }

  body
}
