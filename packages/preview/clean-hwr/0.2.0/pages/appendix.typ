#import "@preview/linguify:0.5.0": linguify

/// Renders the appendix section if it is enabled.
///
/// This function checks the `appendix.enabled` flag. If set to `true`,
/// a page break is inserted, followed by an unnumbered heading.
/// The heading title is taken from `appendix.title` if provided,
/// otherwise it falls back to the localized default
/// `linguify("appendix-title")`.
///
/// After the heading, the appendix content is rendered as provided.
/// If the appendix is not enabled, nothing is rendered.
///
/// Parameters:
/// - appendix (dictionary):
///     (
///       enabled: false,
///       title: "",
///       content: [],
///     )
///     - enabled (bool):
///         Whether the appendix section should be rendered.
///     - title (content or str):
///         Optional custom appendix title.
///     - content (content):
///         The body content of the appendix.
///
/// Returns:
/// - content:
///     An appendix section consisting of:
///     - A page break
///     - An unnumbered heading
///     - The appendix body content
///     or empty content if `enabled` is `false`.
///
/// Example:
/// ```typst
/// #_render-appendix((
///   enabled: true,
///   title: [Appendix A],
///   content: [
///     = Additional Material
///     Supplementary figures and tables.
///   ],
/// ))
/// ```
#let _render-appendix(appendix: (
  enabled: false,
  title: "",
  content: []
)) = {
  if appendix.enabled {
    pagebreak()
    heading(
      appendix.at("title", default: linguify("appendix-title")),
      numbering: none
    )
    appendix.content
  }
}
