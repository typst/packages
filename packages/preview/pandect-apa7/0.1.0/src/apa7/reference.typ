/// References module for APA 7th Edition.
///
/// Implements APA 7 reference list and citation formatting (Chapter 9 & 10):
/// - Automatic page break before the reference list.
/// - Centered bold Level 1 heading ("References" or "Referencias").
/// - Hanging indent of 0.5 inches (1.27 cm) on all reference entries.
/// - Double line spacing throughout.
/// - Native APA CSL citation style.
/// - Helpers for parenthetical and narrative citations with page numbers.

/// Formats a narrative APA 7 citation where author names are part of the sentence text.
///
/// Examples:
/// - `#cite-narrative(<baddeley1974>)` -> `Baddeley and Hitch (1974)`
/// - `#cite-narrative(<baddeley1974>, page: 48)` -> `Baddeley and Hitch (1974, p. 48)`
/// - `#cite-narrative(<baddeley1974>, pages: "48-52")` -> `Baddeley and Hitch (1974, pp. 48-52)`
///
/// Parameters:
/// - key: Citation label or key string (e.g. `<baddeley1974>` or `"baddeley1974"`).
/// - page: Optional single page number (automatically prefixes "p. ").
/// - pages: Optional page range (automatically prefixes "pp. ").
/// - supplement: Explicit custom supplement content.
#let cite-narrative(
  key,
  page: none,
  pages: none,
  supplement: none,
) = {
  let sup = if supplement != none {
    supplement
  } else if page != none {
    [p. #page]
  } else if pages != none {
    [pp. #pages]
  } else {
    none
  }
  let target = if type(key) == label { key } else { label(str(key)) }
  cite(target, form: "prose", supplement: sup)
}

/// Formats a parenthetical APA 7 citation where both author and year are enclosed in parentheses.
///
/// Examples:
/// - `@baddeley1974` -> `(Baddeley & Hitch, 1974)`
/// - `#cite-parenthetical(<baddeley1974>, page: 48)` -> `(Baddeley & Hitch, 1974, p. 48)`
/// - `#cite-parenthetical(<baddeley1974>, pages: "48-52")` -> `(Baddeley & Hitch, 1974, pp. 48-52)`
///
/// Parameters:
/// - key: Citation label or key string.
/// - page: Optional single page number.
/// - pages: Optional page range.
/// - supplement: Explicit custom supplement content.
#let cite-parenthetical(
  key,
  page: none,
  pages: none,
  supplement: none,
) = {
  let sup = if supplement != none {
    supplement
  } else if page != none {
    [p. #page]
  } else if pages != none {
    [pp. #pages]
  } else {
    none
  }
  let target = if type(key) == label { key } else { label(str(key)) }
  cite(target, form: "normal", supplement: sup)
}

/// Applies APA 7 bibliography and reference list formatting.
///
/// Parameters:
/// - lang: ISO 639-1 language code ("en" or "es").
/// - body: Document content.
#let apply-references(lang: "en", body) = {
  // Use Typst's built-in APA 7th edition CSL citation and reference style
  set bibliography(
    style: "apa",
    title: if lang == "es" [Referencias] else [References],
  )

  // APA 7 Section 9.43:
  // - Starts on a new page.
  // - Hanging indent of 0.5 inches (first line flush left, subsequent lines indented 0.5in).
  // - Double line spacing (leading: 1em) without extra space between entries (spacing: 1em).
  show bibliography: it => {
    pagebreak()
    set par(
      hanging-indent: 0.5in,
      first-line-indent: 0pt,
      leading: 1em,
      spacing: 1em,
      justify: false,
    )
    it
  }

  body
}
