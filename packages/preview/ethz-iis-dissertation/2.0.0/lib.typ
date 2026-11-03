// Copyright 2026 ETH Zurich.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Author: Tim Fischer <fischeti@iis.ee.ethz.ch>
//
// ETH Zurich IIS PhD Thesis Template for Typst

#import "shared/utils.typ": fieldpar, include-pdf, placeholder, pulp-colors
#import "@preview/acrostiche:0.7.0": (
  acr, acrfull, acrpl, init-acronyms, print-index, reset-acronym,
  reset-all-acronyms,
)
#import "@preview/gentle-clues:1.3.1": task

#let placeholder = placeholder.with(template: "dissertation")

/// The Typst Quick Guide appendix, ready to drop into the appendices array.
#let typst-guide = include "shared/typst-guide.typ"

/// State holding an optional short chapter title for the running header.
/// Set via the exported `chapter` helper; reset automatically after each heading.
#let chapter-short = state("dissertation-chapter-short", none)

/// Ready-made IEEE reprint statement for ETH Zurich theses. Required by IEEE
/// when reprinted IEEE material is posted online. Drop it straight into the
/// `copyright-notice` parameter: `copyright-notice: ieee-reprint-notice`.
/// Per-chapter "© <year> IEEE. Reprinted, with permission, from …" credits are
/// added separately by the author at each reprinted chapter or figure.
#let ieee-reprint-notice = [
  In reference to IEEE copyrighted material which is used with permission in
  this thesis, the IEEE does not endorse any of ETH Zurich's products or
  services. Internal or personal use of this material is permitted. If
  interested in reprinting/republishing IEEE copyrighted material for
  advertising or promotional purposes or for creating new collective works for
  resale or redistribution, please go to
  #link(
    "http://www.ieee.org/publications_standards/publications/rights/rights_link.html",
  )
  to learn how to obtain a License from RightsLink. If applicable, University
  Microfilms and/or ProQuest Library, or the Archives of Canada may supply
  single copies of the dissertation.
]

/// The IIS PhD Thesis template, following ETH Zurich doctoral regulations.
#let dissertation(
  /// Title of the dissertation.
  title: none,
  /// Full name of the author.
  author: none,
  /// Email address of the author.
  email: none,
  /// Date of birth in "dd.mm.yyyy" format (required on title page).
  date-of-birth: none,
  /// ETH dissertation number. Pass `none` to print a blank field.
  diss-number: none,
  /// Doctoral thesis supervisor: (name: "Prof. Dr. …", email: "…").
  supervisor: none,
  /// Array of co-examiners: ((name: "Prof. Dr. …", email: "…"), …).
  co-examiners: (),
  /// Year of acceptance by the Department Conference.
  year: datetime.today().year(),
  /// Render mode, controlling layout for the output medium:
  /// - `"digital"` (default): single-stream PDF for the research collection.
  ///   Symmetric margins, no blank filler pages, and clickable blue links.
  /// - `"booklet"`: print-ready copy. Mirrored binding margins, chapters and
  ///   front-matter sections opening on recto (odd) pages with a blank verso
  ///   where parity requires it, and black links.
  mode: "digital",
  /// Bleed margin added to all page edges for print trimming (typically `3mm`).
  /// Margins are automatically expanded by the same amount so the text block
  /// size and its position relative to the trim edge remain unchanged.
  /// Leave at `0mm` unless required by your print shop.
  bleed: 0mm,
  /// Target multiple for the total page count in `"booklet"` mode.
  /// Pads the document with unnumbered blank pages at the end until the total
  /// page count is divisible by this value. Defaults to `2` (physical leaves
  /// are double-sided); use `4` or your print shop's signature size if required.
  round-pages-to: 2,
  /// Abstracts array. Each entry is content (typically an `include` call).
  /// The heading is defined inside each file itself.
  /// Example: abstracts: (
  ///   include "chapters/abstract_en.typ",
  ///   include "chapters/abstract_de.typ",
  /// )
  abstracts: (),
  /// Acknowledgements. Pass content directly or via `include "…"`.
  acknowledgements: none,
  /// Acronym dictionary in acrostiche format. Define in `preamble.typ` and pass here.
  acronyms: (:),
  /// Bibliography. Pass `bibliography("refs.bib", style: "ieee")` directly.
  bibliography: none,
  /// Additional appendices: array of content blocks. Each file should start with its own
  /// `= Appendix Title` heading (numbered A, B, … automatically by the template).
  appendices: (),
  /// Curriculum vitae content. Pass content directly or via `include "cv.typ"`.
  cv: none,
  /// Copyright notice for reprinted material, rendered as its own front-matter
  /// page after the abstracts. Three states:
  /// - `auto` (default): show a reminder page nudging you to address reuse
  ///   permissions for any reprinted papers, figures, or tables.
  /// - content: render this notice. For IEEE, pass the bundled
  ///   `ieee-reprint-notice`; for other publishers pass your own content or
  ///   `include "…"`. Per-chapter "© <year> IEEE. Reprinted, …" credits are
  ///   added separately at each reprinted chapter or figure.
  /// - `none`: no page — use this when the thesis contains no reprinted material.
  copyright-notice: auto,
  /// Main body — chapters included via `#include` calls after the show rule.
  body,
) = {
  // Defaults
  // ────────
  if title == none { title = fieldpar[title] }
  if author == none { author = fieldpar[author name] }
  if date-of-birth == none { date-of-birth = fieldpar[dd.mm.yyyy] }
  if supervisor == none { supervisor = fieldpar[doctoral thesis supervisor] }
  if co-examiners.len() == 0 { co-examiners = (fieldpar[co-examiner],) }
  if year == none { year = fieldpar[20XX] }
  init-acronyms(acronyms)

  // Mode
  // ────
  let booklet = mode == "booklet"
  // Open a major section on a fresh page. In booklet mode, force a recto (odd)
  // page so chapters and front-matter sections start on the right, inserting a
  // blank verso when needed; in digital mode, just break to the next page.
  let open-section() = if booklet {
    pagebreak(weak: true, to: "odd")
  } else {
    pagebreak(weak: true)
  }

  // Header
  // ──────
  let show-header = state("phd-show-header", false)

  // Running header: chapter title (recto) / section title (verso).
  // Suppressed on chapter-opening pages and outside the main matter.
  let make-header() = context {
    if not show-header.at(here()) { return }
    let pg = here().page()
    if query(heading.where(level: 1)).any(h => (
      h.numbering != none and h.location().page() == pg
    )) { return }
    let h1s = query(heading.where(level: 1).before(here())).filter(h => (
      h.numbering != none
    ))
    let h2s = query(heading.where(level: 2).before(here())).filter(h => (
      h.numbering != none
    ))
    if h1s.len() == 0 { return }
    let h1 = h1s.last()
    let chapter-num = numbering(
      h1.numbering,
      ..counter(heading).at(h1.location()),
    )
    let chapter-label = if h1.numbering == "A.1" { "Appendix" } else {
      "Chapter"
    }
    let short = chapter-short.at(h1.location())
    let chapter-title = (
      [#chapter-label #chapter-num: ]
        + if short != none { short } else { h1.body }
    )
    let section-title = if h2s.len() > 0 {
      let h2 = h2s.last()
      (
        [#numbering(h2.numbering, ..counter(heading).at(h2.location())) ]
          + h2.body
      )
    } else { [] }
    if booklet {
      // Two-page spread: chapter title on recto (right), section on verso (left).
      let is-odd = calc.odd(pg)
      align(
        if is-odd { right } else { left },
        text(size: 10pt, smallcaps(if is-odd { chapter-title } else {
          section-title
        })),
      )
    } else {
      // Single stream: chapter title consistently on every page.
      align(left, text(size: 10pt, smallcaps(chapter-title)))
    }
    v(3pt)
    line(length: 100%, stroke: 0.4pt)
  }

  // Page
  // ────
  // Base A5 dimensions expanded by bleed. Margins expand correspondingly so the
  // text block position remains fixed relative to the trim line.
  set page(
    width: 148mm + 2 * bleed,
    height: 210mm + 2 * bleed,
    // Both modes keep a 108 mm content width (148 − 22 − 18 = 148 − 20 − 20),
    // so line breaking and margin-note widths are identical. Booklet mirrors a
    // wider inside (binding) margin per spread; digital is symmetric.
    margin: if booklet {
      (
        top: 20mm + bleed,
        bottom: 20mm + bleed,
        inside: 22mm + bleed,
        outside: 18mm + bleed,
      )
    } else {
      (
        top: 20mm + bleed,
        bottom: 20mm + bleed,
        left: 20mm + bleed,
        right: 20mm + bleed,
      )
    },
    header: make-header(),
    footer: context {
      align(center, text(size: 12pt, counter(page).display()))
    },
  )

  // Text & Paragraphs
  // ─────────────────
  set text(size: 10pt, lang: "en")
  let par-indent = 1.5em
  set par(justify: true, first-line-indent: (amount: par-indent, all: false))
  set list(indent: 1em)
  // Blue clickable links in the digital PDF; plain black in print.
  show link: set text(fill: if booklet { black } else { blue })

  // Figures & Tables
  // ────────────────
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.caption: set align(left)
  show table.cell: set par(justify: false)

  // Headings
  // ────────
  // Track whether the last block-level element was a non-paragraph, used by
  // the level-4 show rule to decide whether to cancel first-line-indent.
  let after-block = state("dissertation-after-block", true)
  // Update *after* `it`: a run-in level-4 heading merges into the following
  // paragraph, so this rule wraps it. Updating before `it` would clobber the
  // state before the heading reads it, making every level-4 heading think it
  // follows a paragraph. Updating after lets the heading see the preceding
  // element's value instead.
  show par: it => {
    it
    after-block.update(false)
  }

  // Level 1: gray number + gray vertical rule + unjustified title
  show heading.where(level: 1): it => {
    open-section()
    v(2em)
    if it.numbering != none {
      set par(justify: false)
      table(
        columns: (auto, 1fr),
        align: horizon,
        stroke: ((right: 1pt + pulp-colors.gray.base), none),
        inset: (
          (left: 0pt, right: 1em, top: 0pt, bottom: 0pt),
          (left: 1em, right: 0pt, top: 0pt, bottom: 0pt),
        ),
        // Use it.numbering so appendices show "A", "B", … not "1", "2", …
        text(size: 40pt, fill: pulp-colors.gray.base, weight: "bold", numbering(
          it.numbering,
          ..counter(heading).at(it.location()),
        )),
        text(size: 24pt, weight: "bold", it.body),
      )
    } else {
      text(size: 24pt, weight: "bold", it.body)
    }
    line(length: 100%, stroke: 0.5pt + pulp-colors.gray.base)
    v(1em)
    chapter-short.update(none)
    after-block.update(true)
  }
  show heading.where(level: 1): set heading(supplement: [Chapter])
  show heading.where(level: 2): set text(size: 14pt, weight: "bold")
  show heading.where(level: 2): set block(above: 1.6em, below: 0.8em)
  show heading.where(level: 2): it => {
    it
    after-block.update(true)
  }
  show heading.where(level: 3): set text(size: 12pt, weight: "bold")
  show heading.where(level: 3): set block(above: 1.6em, below: 0.8em)
  show heading.where(level: 3): it => {
    it
    after-block.update(true)
  }
  // Level 4: inline paragraph heading — bold text followed by em-space.
  // Cancel the first-line indent only when the heading runs into an indented
  // paragraph (i.e. it follows another paragraph, not a block-level element).
  show heading.where(level: 4): it => {
    context if not after-block.get() { h(-par-indent) }
    text(weight: "bold", it.body)
    h(1em)
  }

  // Title Page
  // ──────────
  let title-page() = page(
    numbering: none,
    header: none,
    footer: none,
    {
      set align(center)
      let diss-str = if diss-number != none { str(diss-number) } else {
        "___________"
      }
      text(size: 12pt, weight: "bold", smallcaps[Diss. ETH No. #diss-str])
      v(1fr)
      text(size: 24pt, weight: "bold", title)
      v(1fr)
      text(size: 12pt)[
        A thesis submitted to attain the degree of

        #text(size: 18pt, smallcaps[*Doctor of Sciences*])
        #linebreak()
        *(Dr. sc. ETH Zurich)*

        presented by
      ]
      v(1fr)
      text(size: 18pt, author)
      linebreak()
      text(size: 12pt, [born on #date-of-birth])
      v(1fr)
      text(size: 12pt)[accepted on the recommendation of]
      v(0.1em)
      text(size: 12pt, supervisor + [, supervisor])
      for ex in co-examiners {
        linebreak()
        text(size: 12pt, ex + [, co-examiner])
      }
      v(1fr)
      text(size: 12pt, str(year))
    },
  )

  // Front Matter
  // ────────────
  set page(numbering: "i")
  title-page()
  counter(page).update(1)

  // Front-matter sections rely on the level-1 heading rule's `open-section()`
  // call to open a new page (recto in booklet mode), so each is a plain block
  // (not `page(…)`) — wrapping in `page(…)` would stack a second page break on
  // top of the heading's and leave extra blank pages. Sections without a
  // heading (placeholders, copyright notice) call `open-section()` explicitly.
  {
    show heading: set heading(numbering: none, outlined: false)
    if acknowledgements != none {
      acknowledgements
    } else {
      heading(level: 1)[Acknowledgements]
      placeholder(
        title: "Write Acknowledgements",
        description: [Pass content directly or load from a file:],
        snippet: "acknowledgements: include \"chapters/00_acknowledgements.typ\",",
      )
    }
  }

  if abstracts.len() > 0 {
    for abstract in abstracts {
      {
        show heading: set heading(numbering: none, outlined: false)
        abstract
      }
    }
  } else {
    {
      open-section()
      show heading: set heading(numbering: none, outlined: false)
      placeholder(
        title: "Add Abstracts",
        description: [Provide at least an English abstract. Each file should start with its own heading (e.g. `= Abstract` or `= Zusammenfassung`).],
        snippet: "abstracts: (\n    include \"chapters/00_abstract_en.typ\",\n    include \"chapters/00_abstract_de.typ\",\n  ),",
      )
    }
  }

  if copyright-notice == auto {
    {
      open-section()
      task(title: "Copyright Notices for Reprinted Material")[
        If any chapter of this thesis is based on or reprints a previously published
        paper, copyright notices are required by the publisher. For *IEEE publications*:

        *For figures and tables* taken from an IEEE paper, add a short copyright line
        prominently to each caption — even if the surrounding chapter text is your own
        paper. Example caption suffix:
        #block(
          inset: (left: 1em),
          [_© 2022 IEEE. Reprinted, with permission, from
          A. Author et al., "A Novel Architecture for Efficient On-Chip Communication,"
          IEEE Trans. VLSI Syst., 2022._],
        )

        *For an entire paper reprinted as a chapter*, add the bundled blanket
        statement once as a front-matter page and a per-chapter credit at the
        chapter opening:
        #block(
          inset: (left: 1em),
          [_© 2023 IEEE. Reprinted, with permission, from
          A. Author and B. Coauthor, "Scalable Interconnect Design for Many-Core Systems,"
          IEEE J. Solid-State Circuits, vol. 58, no. 4, pp. 1012–1025, Apr. 2023._],
        )

        *Note:* If you are the first/senior author, no formal reuse license is required
        by IEEE — the notices above are sufficient.

        *To obtain the official permission statement for a specific paper:*
        + Go to your published paper on IEEE Xplore.
        + Click the *©* (*"Request Permissions"*) button at the top of the paper page.
        + Select *"Thesis / Dissertation"* as the reuse type.
        + Follow the steps — IEEE will generate the exact wording to use.

        Once addressed, replace this page: set `copyright-notice` to the bundled
        `ieee-reprint-notice` (or your own content), or to `none` if this thesis
        contains no reprinted material.
      ]
    }
  } else if copyright-notice != none {
    {
      open-section()
      show heading: set heading(numbering: none, outlined: false)
      copyright-notice
    }
  }

  {
    show heading: set heading(numbering: none, outlined: false)
    show outline.entry.where(level: 1): set text(size: 11pt, weight: "bold")
    outline(title: [Contents], depth: 3, indent: auto)
    pagebreak()
  }

  // Main Matter
  // ───────────
  set page(numbering: "1")
  counter(page).update(1)
  set heading(numbering: "1.1")

  // Per-chapter figure and table numbering (e.g. Figure 3.2, Table 5.1)
  show heading.where(level: 1): it => {
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    it
  }
  show figure.caption: cap => context {
    let ch = counter(heading).get().first()
    let n = cap.counter.get().first()
    [#cap.supplement #ch.#n#cap.separator #cap.body]
  }
  show ref: r => context {
    let el = r.element
    if el == none or el.func() != figure { return r }
    let ch = counter(heading).at(el.location()).first()
    let n = counter(figure.where(kind: el.kind)).at(el.location()).first()
    let s = if el.kind == image { [Figure] } else { [Table] }
    link(el.location(), [#s~#ch.#n])
  }

  show-header.update(true)
  body

  // Back Matter
  // ───────────
  show-header.update(false)

  if appendices != none and appendices.len() > 0 {
    pagebreak()
    set heading(numbering: "A.1")
    counter(heading).update(0)
    for app in appendices {
      app
      pagebreak()
    }
  }

  pagebreak()
  if bibliography != none {
    bibliography
  } else {
    placeholder(
      title: "Add Bibliography",
      description: [Create a BibTeX file and pass its path to the template:],
      snippet: "bibliography: bibliography(\"references.bib\", style: \"ieee\"),",
    )
  }

  if acronyms.len() > 0 {
    pagebreak()
    {
      show heading: set heading(numbering: none)
      print-index(
        depth: 1,
        row-gutter: 0.8em,
        numbering: none,
        delimiter: none,
        outlined: true,
        sorted: "up",
        used-only: false,
        title: "List of Acronyms",
      )
    }
  }

  if cv != none {
    pagebreak()
    {
      show heading: set heading(numbering: none, outlined: true)
      heading(level: 1)[Curriculum Vitae]
    }
    cv
  }

  // Querying total page count directly within the document creates a circular
  // dependency. Mark the end of content instead to calculate trailing blank pages.
  // Padding pages carry no page number, matching blank versos between chapters.
  [#metadata(none)<dissertation-content-end>]
  if booklet and round-pages-to > 1 {
    context {
      let last = query(<dissertation-content-end>).first().location().page()
      let short = calc.rem(
        round-pages-to - calc.rem(last, round-pages-to),
        round-pages-to,
      )
      for _ in range(short) {
        page(header: none, footer: none, numbering: none, hide[.])
      }
    }
  }
}
