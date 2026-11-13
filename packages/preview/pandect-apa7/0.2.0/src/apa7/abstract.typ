/// Abstract module for APA 7th Edition.
///
/// Implements the Abstract and Keywords page according to Sections 2.9 and 2.10
/// of the Publication Manual of the American Psychological Association (7th ed.),
/// with semantic headings for PDF/UA-1 accessibility.

/// Formats a list or content of keywords according to APA 7 style.
///
/// Keywords are formatted on a new line, indented 0.5 inches (1.27 cm),
/// starting with an italicized label ("Keywords:" or "Palabras clave:"),
/// followed by lowercase keywords separated by commas, with no ending period.
#let render-keywords(keywords, lang: "en") = {
  if keywords == none or keywords == () or keywords == "" {
    return none
  }

  let label = if lang == "es" {
    emph[Palabras clave:]
  } else {
    emph[Keywords:]
  }

  let formatted-keywords = if type(keywords) == array {
    keywords.map(k => if type(k) == str { k } else { repr(k) }).join(", ")
  } else {
    keywords
  }

  block[
    #set par(first-line-indent: 0.5in)
    #label #formatted-keywords
  ]
}

/// Renders the APA 7 Abstract page.
///
/// Parameters:
/// - abstract: Content or string representing the abstract.
/// - keywords: Array of keywords or string/content.
/// - lang: ISO 639-1 language code (default: "en").
#let render-abstract(
  abstract: none,
  keywords: (),
  lang: "en",
) = {
  if abstract == none or abstract == "" {
    return none
  }

  let abstract-title = if lang == "es" {
    [Resumen]
  } else {
    [Abstract]
  }

  // Level 1 heading for semantic outline and PDF/UA-1 accessibility.
  // In APA 7, Level 1 headings are centered and bold.
  heading(level: 1, abstract-title)

  // APA 7 Section 2.9: The abstract text must be in a single paragraph
  // WITHOUT paragraph indentation (first-line-indent: 0pt).
  block[
    #set par(first-line-indent: 0pt)
    #abstract
  ]

  // APA 7 Section 2.10: Keywords block indented 0.5in with italicized label
  render-keywords(keywords, lang: lang)

  pagebreak()
}
