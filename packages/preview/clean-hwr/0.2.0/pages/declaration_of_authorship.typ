#import "@preview/linguify:0.5.0": linguify, linguify-raw

#import "../helper/to_string.typ": _to-string

/// Renders the declaration of authorship section.
///
/// If `custom-declaration-of-authorship` is not empty ([]),
/// the provided custom content is rendered directly.
///
/// Otherwise, a default declaration section is generated:
/// - An unnumbered heading using the localized
///   `linguify("declaration-title")`
/// - A localized declaration text via
///   `linguify("declaration-text")`, receiving the document
///     title (`metadata.title`) as argument
/// - Vertical spacing
/// - A two-column signature table including:
///     - Place of signature
///     - Date of signature
///     - Signature line
/// - A trailing page break
///
/// Parameters:
/// - custom-declaration-of-authorship (content, default: []):
///     Optional custom declaration content. If not empty,
///     this overrides the default rendering.
///
/// - metadata (dictionary, default:
///     (
///       paper-type: [],
///       title: [PTB Template],
///       student-id: "",
///       authors: none,
///       company: "",
///       enrollment-year: "",
///       semester: "",
///       company-supervisor: "",
///       authors-per-line: 2,
///       field-of-study: none,
///       university: none,
///       date-of-publication: none,
///       uni-logo: none,
///       company-logo: none,
///     )
///   ):
///     Document metadata. The field `metadata.title` is used
///     in the default declaration text.
///
/// Returns:
/// - content:
///     Either:
///     - The custom declaration content (if provided), or
///     - A fully formatted default declaration section with
///       heading, text, signature table, and page break.
///
/// Example:
/// ```typst
/// #_render-declaration-of-authorship(
///   metadata: (title: [My Thesis])
/// )
/// ```
///
/// Example with custom content:
/// ```typst
/// #_render-declaration-of-authorship(
///   custom-declaration-of-authorship: [
///     = Declaration
///     I hereby confirm ...
///   ],
/// )
/// ```
#let _render-declaration-of-authorship(
  custom-declaration-of-authorship: [],
  metadata: (
    paper-type: [],
    title: [PTB Template],
    student-id: "",
    authors: none,
    company: "",
    enrollment-year: "",
    semester: "",
    company-supervisor: "",
    // These do not need to be changed by the user
    authors-per-line: 2,
    field-of-study: none,
    university: none,
    date-of-publication: none,
    uni-logo: none,
    company-logo: none,
  )
) = {
  if custom-declaration-of-authorship != [] {
    custom-declaration-of-authorship
  } else {
    heading(
      linguify(
        "declaration-title",
        args: (
          author-count: metadata.authors.len(),
        )
      ),
      numbering: none
    )

    // NOTE: this is a hacky way to read the text in ftl file as typst.
    // If there is a better option this should be replaced
    context eval(
      "[" +
      linguify-raw(
        "declaration-text",
        args: (
          author-count: metadata.authors.len(),
          title: _to-string(metadata.title)
        ),
      )
      + "]"
    )


    v(4.0em)

    let signature-section = (
      [#line(length: 100%)#linguify("place-of-signature"), #linguify("date-of-signature")],
      [#line(length: 100%)#linguify("signature")]
    )
    let signature-sections = if type(metadata.authors) == str {
      signature-section
    } else if type(metadata.authors) == array {
      metadata.authors.map(_ => signature-section).flatten()
    } else {
      panic("`metadata.authors` should be of type str or array")
    }

    table(
      columns: (50%,50%),
      stroke: none,
      inset: 20pt,
      ..signature-sections
    )
    pagebreak()
  }
}
