// Evaluation-boundary declarations for externally observable Typst values.

/// Mark source-backed content for provenance externalization.
///
/// The marker is inert unless it is nested in an announcement. During
/// externalization, eval replaces it with the wrapped content's source and
/// byte range.
///
/// - value (content): The exact content whose source span should cross the
///   evaluation boundary.
/// -> content
#let inspect(value) = {
  if type(value) != content {
    panic("inspect expects content")
  }
  [#metadata(value)<eval.inspect>]
}

/// Publish one value as externally observable evaluation state.
///
/// Eval discovers announcements through the `eval.announcement` metadata
/// label, externalizes their values, and indexes them by tag.
///
/// - tag (label): The open announcement kind used by external handlers.
/// - value (any): The Typst value to externalize.
/// -> content
#let announce(tag, value) = {
  if type(tag) != label {
    panic("announcement tag must be a label")
  }
  [#metadata((tag: tag, value: value))<eval.announcement>]
}
