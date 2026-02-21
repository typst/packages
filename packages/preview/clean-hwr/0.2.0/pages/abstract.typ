#import "@preview/linguify:0.5.0": linguify

/// Renders the abstract page of the document.
///
/// This function creates a dedicated abstract page using Roman page
/// numbering ("I") centered at the bottom. The abstract title is
/// localized via `linguify("abstract-title")`, rendered in small caps,
/// and displayed as an unnumbered, non-outlined heading.
///
/// The abstract content is typeset inside a centered container with
/// 90% page width and justified paragraph alignment. Vertical spacing
/// is added above and below the content to visually center it on the page.
/// A page break is inserted after rendering.
///
/// Parameters:
/// - abstract (content):
///     The abstract text to be rendered. This can contain arbitrary
///     Typst content (formatted text, inline markup, etc.).
///
/// Returns:
/// - content:
///     A fully formatted abstract page including:
///     * Roman page numbering
///     * Centered, localized abstract heading
///     * Justified abstract body text
///     * A trailing page break
///
/// Example:
/// ```typst
/// #_render-abstract([
///   This thesis investigates the impact of ...
/// ])
/// ```
#let _render-abstract(abstract: [#lorem(30)]) = {
  set page(numbering: "I", number-align: center)
  v(1fr)
  align(center)[
    #heading(
      outlined: false,
      numbering: none,
      text(0.85em, smallcaps[#linguify("abstract-title")]),
    )
    #box(width: 90%)[#align(left)[#par(justify: true)[#abstract]]]
  ]
  v(1.618fr)
  pagebreak()
}

