#import "@preview/linguify:0.5.0": linguify

/// Renders a note on gender-inclusive language for German documents.
///
/// This function checks whether `note-gender-inclusive-language.enabled` is `true`
/// and the document `language` is `"de"`. If both conditions are met, it renders:
/// - An unnumbered heading using the localized `linguify("gender-note-title")`
/// - The localized note text via `linguify("gender-note-text")`
/// - A page break after the note
///
/// If the note is disabled or the language is not German, nothing is rendered.
///
/// Parameters:
/// - note-gender-inclusive-language (dictionary, default:
///     (enabled: false, title: "")
///   ):
///     - enabled (bool):
///         Whether to display the note.
///     - title (content or str):
///         Optional custom title for the note (not used in default rendering).
///
/// - language (str, default: "en"):
///     Document language. The note is only rendered if `language == "de"`.
///
/// Returns:
/// - content:
///     The rendered gender-inclusive language note with heading and page break,
///     or empty content if the conditions are not met.
///
/// Example:
/// ```typst
/// #_render-note-on-gender-inclusive-lang(
///   note-gender-inclusive-language: (enabled: true),
///   language: "de",
/// )
/// ```
#let _render-note-on-gender-inclusive-lang(
  note-gender-inclusive-language: (
    enabled: false,
    title: ""
  ),
  language: "en"
) = {
 if note-gender-inclusive-language.enabled and language == "de" {
    heading(
      linguify("gender-note-title"),
      numbering: none
    )
    linguify("gender-note-text")
    pagebreak()
  }
}

