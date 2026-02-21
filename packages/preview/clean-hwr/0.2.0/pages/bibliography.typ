/// Configures and renders the bibliography if a bibliography object is provided.
///
/// This function checks whether `bibliography-object` is not `none`.
/// If present, it sets the bibliography style using the given
/// `citation-style` (resolved relative to the parent directory),
/// and then renders the provided bibliography object.
///
/// If `bibliography-object` is `none`, nothing is rendered.
///
/// Parameters:
/// - bibliography-object (content or none):
///     A bibliography element (e.g. created via `bibliography(...)`)
///     that contains the references to be printed. If `none`,
///     the bibliography section is skipped.
///
/// - citation-style (str):
///     The CSL filename used for formatting citations and references.
///     The style path is resolved as `"../" + citation-style`.
///
/// Returns:
/// - content:
///     The rendered bibliography using the configured citation style,
///     or empty content if no bibliography object is provided.
///
/// Example:
/// ```typst
/// #_set-biblography(
///   bibliography("references.bib"),
///   "hwr_citation.csl",
/// )
/// ```
#let _set-biblography(
  bibliography-object: none,
  citation-style: "hwr_citation.csl"
) = {
  if bibliography-object != none {
    set bibliography(style: "../" + citation-style)
    bibliography-object
  }
}
