/// Headings module for APA 7th Edition.
///
/// Implements the five hierarchical heading levels specified in Section 2.27
/// of the Publication Manual of the American Psychological Association (7th ed.),
/// while preserving semantic heading tags for screen readers and PDF/UA-1 conformance.

/// Helper to check if a content element already terminates with ending punctuation (. ? !)
#let ends-with-punctuation(body) = {
  let r = repr(body).trim()
  r.ends-with(".]") or r.ends-with("?]") or r.ends-with("!]") or r.ends-with(".") or r.ends-with("?") or r.ends-with("!")
}

/// Applies APA 7 heading formatting rules to the document.
///
/// Formatting rules per level:
/// - Level 1: Centered, Bold, Title Case. Text starts on the next line.
/// - Level 2: Flush Left, Bold, Title Case. Text starts on the next line.
/// - Level 3: Flush Left, Bold Italic, Title Case. Text starts on the next line.
/// - Level 4: Indented 0.5 in, Bold, Title Case, Ending With a Period. Inline / run-in.
/// - Level 5: Indented 0.5 in, Bold Italic, Title Case, Ending With a Period. Inline / run-in.
///
/// Parameters:
/// - body: Document content to wrap with heading show rules.
#let apply-headings(body) = {
  // APA 7 does not number headings (Section 2.27).
  set heading(numbering: none)

  // APA 7: Headings share the same font and size as body text (e.g. 12pt).
  // Spacing is double-spaced without extra blank lines above or below.
  show heading: set text(size: 1em)
  show heading: set block(above: 1em, below: 1em)

  // Level 1: Centered, Bold
  show heading.where(level: 1): set align(center)
  show heading.where(level: 1): set text(weight: "bold")

  // Level 2: Flush Left, Bold
  show heading.where(level: 2): set align(left)
  show heading.where(level: 2): set text(weight: "bold")

  // Level 3: Flush Left, Bold Italic
  show heading.where(level: 3): set align(left)
  show heading.where(level: 3): set text(weight: "bold", style: "italic")

  // Level 4: Indented 0.5 in, Bold, Ending With a Period (Run-in)
  show heading.where(level: 4): it => [
    #h(0.5in, weak: true)#strong(it.body)#if not ends-with-punctuation(it.body) [.]#h(0.5em)
  ]

  // Level 5: Indented 0.5 in, Bold Italic, Ending With a Period (Run-in)
  show heading.where(level: 5): it => [
    #h(0.5in, weak: true)#emph(strong(it.body))#if not ends-with-punctuation(it.body) [.]#h(0.5em)
  ]

  body
}
