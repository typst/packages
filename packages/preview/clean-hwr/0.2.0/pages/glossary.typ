#import "@preview/linguify:0.5.0": linguify
#import "@preview/glossarium:0.5.9": print-glossary

/// Renders the glossary section if entries are provided.
///
/// This function checks whether `glossary.entries` is non-empty.
/// If so, it renders an unnumbered heading with the glossary title,
/// using `glossary.title` if provided, otherwise falling back to
/// the localized default `linguify("glossary-title")`.
///
/// The glossary entries are rendered using `print-glossary` with:
/// - `show-all: true` to display all entries
/// - `disable-back-references` controlled by
///   `glossary.disable-back-references` (default `false`)
///
/// A page break is inserted after the glossary. If no entries
/// exist, nothing is rendered.
///
/// Parameters:
/// - glossary (dictionary, default:
///     (
///       title: "",
///       entries: (),
///       disable-back-references: none,
///     )
///   ):
///     - title (content or str):
///         Optional custom glossary title
///     - entries (dictionary):
///         Glossary entries to render
///     - disable-back-references (bool or none):
///         Whether to disable back-references in the glossary
///
/// Returns:
/// - content:
///     The rendered glossary section with heading and entries,
///     followed by a page break, or empty content if no entries exist.
///
/// Example:
/// ```typst
/// #_render-glossary(glossary: (
///   title: [Glossary of Terms],
///   entries: (
///     API: "Application Programming Interface",
///     NLP: "Natural Language Processing",
///   ),
///   disable-back-references: false,
/// ))
/// ```
#let _render-glossary(glossary: (
  title: "",
  entries: (),
  disable-back-references: false,
)) = {
  if glossary.entries != () {
    heading(
      glossary.at("title", default: linguify("glossary-title")),
      numbering: none
    )
    print-glossary(
      glossary.entries,
      show-all: true,
      disable-back-references: glossary.at("disable-back-references", default: false)
    )
    pagebreak()
  }
}
