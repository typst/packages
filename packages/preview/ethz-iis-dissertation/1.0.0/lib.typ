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
  /// Render mode: "official" (examination copy) or "series" (Hartung-Gorre publication).
  mode: "official",
  /// Series volume number (series mode only).
  volume: none,
  /// ISBN-10 (series mode only).
  isbn: none,
  /// ISBN-13 (series mode only).
  isbn-long: none,
  /// Publication year for series page (defaults to `year` when omitted).
  published: none,
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
  /// Show a copyright reminder page after the abstracts (default: true).
  /// Set to `false` once you have added all required copyright notices.
  show-copyright-notice: true,
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
    let is-odd = calc.odd(pg)
    align(
      if is-odd { right } else { left },
      text(size: 10pt, smallcaps(if is-odd { chapter-title } else {
        section-title
      })),
    )
    v(3pt)
    line(length: 100%, stroke: 0.4pt)
  }

  // Page
  // ────
  set page(
    paper: "a5",
    margin: (top: 20mm, bottom: 20mm, inside: 22mm, outside: 18mm),
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
  show link: set text(fill: blue)

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
  show par: it => {
    after-block.update(false)
    it
  }

  // Level 1: gray number + gray vertical rule + unjustified title
  show heading.where(level: 1): it => {
    pagebreak(weak: true, to: "odd")
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
  // TODO(fischeti): This does not work for all paragraphs for some reason.
  show heading.where(level: 4): it => {
    context if not after-block.get() { h(-par-indent) }
    text(weight: "bold", it.body)
    h(1em)
  }

  // Title Pages
  // ───────────
  let series-title-page() = page(numbering: none, header: none, footer: none, {
    v(1fr)
    align(center, {
      text(size: 12pt, style: "italic", [Series in Microelectronics])
      if volume != none {
        linebreak()
        text(size: 11pt, [Volume #volume])
      }
    })
    v(2fr)
    set text(size: 9pt)
    [*Editors:*\ ]
    v(0.4em)
    [Prof. Dr. Luca Benini (ETH Zurich)\ ]
    [Prof. Dr. Frank K. Gürkaynak (ETH Zurich)]
    v(1em)
    [The series "Series in Microelectronics" is published by the Electronics Laboratory
      (IfE) of ETH Zurich. The volumes are available through Hartung-Gorre Verlag, Konstanz.]
    v(2fr)
    [*Bibliografische Information der Deutschen Nationalbibliothek*\ ]
    [Die Deutsche Nationalbibliothek verzeichnet diese Publikation in der Deutschen
      Nationalbibliografie; detaillierte bibliografische Daten sind im Internet über
      #link("http://dnb.d-nb.de")[http://dnb.d-nb.de] abrufbar.]
    v(0.5em)
    [© #if published != none { published } else if year != none { str(year) } else { "20XX" }
      #if author != none { author }]
    v(0.5em)
    if isbn != none [ISBN #isbn\ ]
    if isbn-long != none [ISBN #isbn-long\ ]
    [ISSN 0179-0307]
    v(1fr)
  })

  let official-title-page() = page(
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
  if mode == "series" { series-title-page() } else { official-title-page() }
  counter(page).update(1)

  page({
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
  })

  if abstracts.len() > 0 {
    for abstract in abstracts {
      page({
        show heading: set heading(numbering: none, outlined: false)
        abstract
      })
    }
  } else {
    page({
      show heading: set heading(numbering: none, outlined: false)
      placeholder(
        title: "Add Abstracts",
        description: [Provide at least an English abstract. Each file should start with its own heading (e.g. `= Abstract` or `= Zusammenfassung`).],
        snippet: "abstracts: (\n    include \"chapters/00_abstract_en.typ\",\n    include \"chapters/00_abstract_de.typ\",\n  ),",
      )
    })
  }

  if show-copyright-notice {
    page({
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

        *For an entire paper reprinted as a chapter*, add the following once in the
        bibliography/references section:
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

        Once all copyright notices have been added, disable this page by setting
        `show-copyright-notice: false` in the template parameters.
      ]
    })
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
    align(left, [#cap.supplement #ch.#n#cap.separator #cap.body])
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
}
