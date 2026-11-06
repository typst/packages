// misq.typ — MIS Quarterly submission template for Typst
//
// Font: Times New Roman is required by MISQ.
// "Times" is the macOS/Linux fallback if TNR is not installed.
// No runtime font check — silent fallback per MISQ template policy.

#let misq(
  title: [Untitled],
  abstract: none,
  keywords: (),
  paragraph-style: "indent",   // "indent" (first-line, no extra spacing) or "block" (no indent, extra spacing)
  body
) = {

  // --- Page geometry (PAGE-01, PAGE-02) ---
  // US Letter: 8.5" x 11"
  // Margins: 1" all sides → 6.5" text width, 9" text height
  // Matches LaTeX: textwidth 6.5in, textheight 9in
  set page(
    paper: "us-letter",
    margin: (x: 1in, top: 1in, bottom: 1in),
    numbering: "1",
    number-align: center + bottom,  // PAGE-03: centered footer page numbers
  )

  // --- Font (TYPO-01) ---
  // Times New Roman is required; Times is the macOS/Linux fallback
  set text(font: ("Times New Roman", "Times"), size: 12pt)

  // --- Body paragraph spacing (TYPO-02) ---
  // Double-spaced: visually equivalent to LaTeX \baselinestretch{2.0}
  // Calibrated empirically in Phase 1: leading = 1.85em, spacing = 1.85em
  set par(justify: true, leading: 1.85em, spacing: 1.85em)

  // --- Paragraph style toggle ---
  // "indent": first-line indent (LaTeX convention), no extra between-paragraph spacing
  // "block": no indent, extra spacing between paragraphs (Word convention)
  // NOTE: set rules must be at show-rule scope to propagate to body content.
  // Using set/show inside an if-block scopes them to that block only.
  // `all: true` is required so that paragraphs immediately following headings also
  // receive the first-line indent. Without `all: true`, Typst skips the indent on
  // the first paragraph after a heading (Typst's default CSS-like behavior), which
  // does NOT match MISQ's requirement of indenting every paragraph including those
  // that follow section headings.
  set par(first-line-indent: (amount: if paragraph-style == "indent" { 0.5in } else { 0pt }, all: true))
  set par(spacing: if paragraph-style == "block" { 2.5em } else { 1.85em })

  // --- Citation style (CITE-03) ---
  // Auto-apply bundled APA 7th CSL so authors call #bibliography() with no style: needed.
  // Authors may override: #bibliography("refs.bib", style: "chicago-author-date")
  set bibliography(style: "apa.csl")

  // --- Bibliography formatting (TYPO-04, STRC-03) ---
  // Single-spacing + REFERENCES heading formatting.
  // HOW hanging indent works: The bundled apa.csl is an unmodified upstream APA 7th
  // edition CSL file. It has hanging-indent="true", which means the CSL itself delivers
  // the 0.5-inch hanging indent natively. No Typst-level hanging-indent code is needed.
  // WHAT this show rule does: The show rule handles only two concerns:
  //   1. Single-spacing — overrides document-level double-spacing for bibliography
  //      entries via par(leading: 0.65em, spacing: 0.65em).
  //   2. REFERENCES heading formatting (STRC-03) — centered, bold, uppercase.
  // WHY single show rule: Multiple transformational show rules for the same element
  // (bibliography) cause the last rule to overwrite all earlier ones. All bibliography
  // formatting is combined here in one rule.
  show bibliography: it => {
    set par(leading: 0.65em, spacing: 0.65em)
    // STRC-03: Auto-format heading — centered, bold, uppercase
    show heading: it_h => align(center, block(
      above: 1.85em,
      below: 1.85em,
      {
        set text(weight: "bold", size: 12pt)
        upper(it_h.body)
      }
    ))
    it
  }

  // --- Single-spacing for figures and tables (TYPO-05) ---
  // Captions and figure/table content rendered at single-spacing (same as bibliography).
  // HOW the scoping works: `show figure: set par(...)` is a set rule attached to a
  // show rule. The par() settings (leading/spacing) apply only within figure content
  // (captions and body), not globally to the document. This is distinct from a bare
  // `set par(...)` which would apply to all subsequent content in scope. The show rule
  // creates a scoped styling context that reverts to document-level par settings after
  // the figure closes.
  show figure: set par(leading: 0.65em, spacing: 0.65em)

  // --- Heading numbering (HEAD-04) ---
  // Hierarchical numbering pattern: "1", "1.1", "1.1.1"
  // Using "1.1" (no trailing dot) to avoid trailing period on level-1 display ("1." → "1")
  set heading(numbering: "1.1")

  // --- Heading show rules (HEAD-01, HEAD-02, HEAD-03) ---
  // All levels: bold, 12pt, uniform spacing above/below
  // IMPORTANT: counter(heading).display(it.numbering) reconstructs the number
  // because full transformational show rules bypass default heading number rendering.
  // See RESEARCH.md Pitfall 1.

  // Level 1: centered, uppercase, bold, 12pt, numbered (1, 2, 3, ...)
  show heading.where(level: 1): it => align(center, block(
    above: 1.85em,
    below: 1.85em,
    {
      set text(weight: "bold", size: 12pt)
      if it.numbering != none {
        counter(heading).display(it.numbering)
        h(0.5em)
      }
      upper(it.body)
    }
  ))

  // Level 2: centered, bold, 12pt, numbered (1.1, 1.2, ...) — no uppercase
  show heading.where(level: 2): it => align(center, block(
    above: 1.85em,
    below: 1.85em,
    {
      set text(weight: "bold", size: 12pt)
      if it.numbering != none {
        counter(heading).display(it.numbering)
        h(0.5em)
      }
      it.body
    }
  ))

  // Level 3: left-aligned, bold, 12pt, numbered (1.1.1, 1.1.2, ...)
  show heading.where(level: 3): it => block(
    above: 1.85em,
    below: 1.85em,
    {
      set text(weight: "bold", size: 12pt)
      if it.numbering != none {
        counter(heading).display(it.numbering)
        h(0.5em)
      }
      it.body
    }
  )

  // --- Front matter: title page (STRC-01) ---
  // Title: bold and centered, original author casing (no auto-uppercase)
  align(center, text(weight: "bold", title))
  v(1em)

  // --- Front matter: abstract (TYPO-03) ---
  if abstract != none {
    // Abstract label: centered and bold (updated from Phase 1's left-aligned)
    align(center, text(weight: "bold")[Abstract])
    linebreak()
    // 1.5x spacing: calibrated in Phase 1 at 0.9em leading/spacing
    // Scoped to abstract block only; body spacing is restored after this block
    block({
      set par(leading: 0.9em, spacing: 0.9em)
      abstract
    })
    parbreak()
  }

  // --- Front matter: keywords ---
  if keywords.len() > 0 {
    block({
      set par(first-line-indent: 0pt)
      text(weight: "bold")[Keywords: ]
      for (i, k) in keywords.enumerate() {
        k
        if i < keywords.len() - 1 { [, ] }
      }
    })
    parbreak()
  }

  // --- Page break (STRC-02) ---
  // Force Introduction to start at top of page 2
  // weak: true avoids blank page if the page is already empty
  pagebreak(weak: true)

  // --- Body content ---
  body
}
