// style.typ
//
// Page geometry, fonts, headings, and styling rules for the thesis.
// Used by lib.typ. Not a public-facing module.

#import "common.typ": colors, fonts
#import "@preview/codly:2.0.0" as codly
#import "@preview/codly-languages:0.1.10": codly-languages

// Build the header and footer used on body pages. Two-sided.
// Returns a dictionary suitable for `set page(header: ..., footer: ...)`.
// Defined before apply-style because apply-style calls it.
#let two-sided-header-footer(language: "english") = {
  // Header. Chapter title appears on the outer side of the page.
  let header-content = context {
    let here = here()
    let chapter-title = ""
    // Find the nearest preceding level-1 heading.
    let candidates = query(selector(heading.where(level: 1)).before(here))
    if candidates.len() > 0 {
      chapter-title = candidates.last().body
    }
    set text(size: 9pt, fill: colors.anthrazit)
    if calc.odd(here.page()) {
      // Right page. Chapter title on the right (outer).
      align(right, chapter-title)
    } else {
      // Left page. Chapter title on the left (outer).
      align(left, chapter-title)
    }
  }

  let footer-content = context {
    // Pages with no numbering pattern (cover, title, declaration, blank
    // versos in front matter) emit no footer content.
    if page.numbering == none {
      return
    }
    set text(size: 9pt, fill: colors.anthrazit)
    // Use the counter value (logical page number) so that the abstract
    // page reads "i" even though it sits later in the absolute page sequence.
    let counter-val = counter(page).get().first()
    let formatted = numbering(page.numbering, counter-val)
    // Left / right corner placement follows absolute page parity (binding).
    if calc.odd(here().page()) {
      align(right, formatted)
    } else {
      align(left, formatted)
    }
  }

  (header: header-content, footer: footer-content)
}

// Apply all global thesis styling. Returns a closure that takes body content
// and wraps it with the right `set`/`show` rules. body-font is "sans"
// (default, Helvetica everywhere) or "serif" (Latin Modern body with sans
// headings, matching the LaTeX KOMA-Script default). heading-rule draws a
// thin mittelblau rule below every chapter-level heading.
#let apply-style(body, body-font: "sans", sans-font: fonts.sans, heading-rule: false) = {
  // A4, two-sided. Inside (binding) margin is larger to leave the bound edge
  // clear; outside is the margin away from the binding.
  set page(
    paper: "a4",
    margin: (inside: 30mm, outside: 25mm, top: 25mm, bottom: 30mm),
    binding: left,
  )

  // Body text. 11pt body size. Font depends on the body-font parameter.
  // Line spacing approximately 1.4 by using leading 0.8em (close to Word's
  // 1.4 line height when default is around 0.65em).
  // Language is set by the caller (thesis() in lib.typ) before apply-style
  // runs. Do not override it here.
  let body-font-stack = if body-font == "serif" { fonts.serif } else { sans-font }
  set text(font: body-font-stack, size: 11pt)
  // Headings stay on the sans stack even in serif body mode. This mirrors
  // KOMA-Script's default heading family of \sffamily.
  show heading: set text(font: sans-font)
  set par(leading: 0.8em, justify: true, first-line-indent: 0pt, spacing: 1.2em)

  // Indent enumerations, bullet lists, and description lists from the
  // left margin so they sit visually inset from the surrounding text.
  set enum(indent: 1em)
  set list(indent: 1em)
  set terms(indent: 1em)

  // Wire up the two-sided footer so outer-corner page numbers appear.
  // Header is disabled for now (set to none); the running chapter title
  // header is implemented in two-sided-header-footer() and can be enabled
  // by passing the .header field to set page(header: ...) here, or by
  // wiring in the hydra package for richer context-aware headers later.
  let hf = two-sided-header-footer()
  set page(header: none, footer: hf.footer)

  // Numbered chapters and sections by default. Front-matter chapters
  // (abstract, declaration, abbreviations, notation, TOC) override this with
  // `numbering: none` at their own heading() call sites.
  // Numbering renders as "1", "1.1", "1.1.1" with no trailing dot.
  set heading(numbering: (..nums) => nums.pos().map(str).join("."))

  // Math defaults. Typst's New Computer Modern math is used as-is.
  // Equations referenced via `<label>` need numbering to be resolvable.
  set math.equation(numbering: "(1)")

  // Strong stays default black. Emphasis stays default italic black.
  // Links get a subtle mittelblau without underline.
  show link: set text(fill: colors.mittelblau)

  // Inline code. Light gray background like the poster, but smaller.
  show raw.where(block: false): it => box(
    fill: colors.block-body,
    inset: (x: 3pt, y: 0.5pt),
    outset: (y: 1pt),
    radius: 2pt,
    text(font: fonts.mono, size: 0.92em, fill: colors.mittelblau, it),
  )

  // Block code. Delegate to codly for line numbers and language-aware styling.
  // Defaults from @preview/codly with the language map from codly-languages.
  show: codly.lang-set_(languages: codly-languages)
  show raw.where(block: true): codly.new

  // Chapter-level (level 1) heading. New right-opening page with the chapter
  // number rendered inline next to the title at the same size, all in black,
  // optionally followed by a thin mittelblau rule below. The spacing to the
  // text is the same with and without the rule. Hyphenation is disabled so
  // long words like "enumerated" stay intact when the title wraps.
  show heading.where(level: 1): it => {
    pagebreak(to: "odd", weak: true)
    v(2cm)
    let prefix = if it.numbering != none {
      [#counter(heading).display()#h(0.6em)]
    } else {
      []
    }
    // Disable justify so two-line titles wrap as ragged-right instead of
    // stretching the first line to full width.
    set par(justify: false)
    text(
      size: 24pt,
      weight: "bold",
      fill: black,
      hyphenate: false,
    )[#prefix#it.body]
    v(4mm)
    if heading-rule {
      line(length: 100%, stroke: 1pt + colors.mittelblau)
    }
    v(1.5cm)
  }

  // Section, subsection, subsubsection. All black, decreasing sizes.
  show heading.where(level: 2): it => {
    v(8mm, weak: true)
    text(size: 14pt, weight: "bold", fill: black, it)
    v(2mm)
  }
  show heading.where(level: 3): it => {
    v(5mm, weak: true)
    text(size: 12pt, weight: "bold", fill: black, it)
    v(1mm)
  }
  show heading.where(level: 4): it => {
    v(3mm, weak: true)
    text(size: 11pt, weight: "bold", style: "italic", fill: black, it)
  }

  // Figure caption styling. Black bold "Figure N.M" label, then normal body.
  show figure.caption: it => {
    text(weight: "bold", fill: black, it.supplement + " " + str(it.counter.display()) + ":")
    " "
    it.body
  }

  body
}
