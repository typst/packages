#import "@preview/linguify:0.5.0": linguify
#import "@preview/acrostiche:0.7.0": print-index

/// Renders the acronyms index if acronym entries are defined.
///
/// This function checks whether `acronyms.entries` is non-empty.
/// If entries exist, it prints an outlined index using `print-index`.
/// The index title is taken from `acronyms.title` if provided,
/// otherwise it falls back to the localized default
/// `linguify("acronyms-title")`.
///
/// Text rendering is adjusted to use proper typographic top and bottom
/// edges ("ascender" and "descender") before printing the index.
/// A page break is inserted after the acronyms section.
///
/// If no acronym entries are defined, nothing is rendered.
///
/// Parameters:
/// - acronyms (dictionary):
///     (
///       title: "",
///       entries: (),
///     )
///     - title (content or str):
///         Optional custom title for the acronyms section.
///     - entries (dictionary):
///         Acronym definitions previously initialized via `init-acronyms`.
///
/// Returns:
/// - content:
///     An outlined acronyms index followed by a page break,
///     or empty content if no entries are present.
///
/// Example:
/// ```typst
/// #_render-acronyms((
///   title: [List of Acronyms],
///   entries: (
///     API: "Application Programming Interface",
///     NLP: "Natural Language Processing",
///   ),
/// ))
/// ```
#let _render-acronyms(acronyms: (
  title: "",
  entries: ()
)) = {
  if acronyms.entries != () {
    set text(top-edge: "ascender", bottom-edge: "descender")
    print-index(
      outlined: true,
      title: acronyms.at("title", default: linguify("acronyms-title"))
    )
    pagebreak()
  }
}
