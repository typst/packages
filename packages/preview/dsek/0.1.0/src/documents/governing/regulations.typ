#import "../plain-document.typ": plain-document
#import "../../lib/_mod.typ": *

/// #set raw(lang: "typst")
/// Creates the guild regulations (reglemente) document. Apply with `#show: reglemente.with(...)` or `#show: regulations.with(...)`.
///
/// === Notes
/// - Terms blocks (`/ Term: Description`) are formatted as a 2-column table (term, description).
///
/// === Example
/// ```typst
/// #import "@preview/dsek:0.1.0": *
///
/// #show: reglemente
///
/// = Teknologia
///
/// / Råsa:
///   En lämplig tolkning av råsa är _Pepto-Bismol_.
///
/// / Rosa Pantern:
///   Med Rosa Pantern åsyftas den drink som skapas med mjölk, grenadin och sockerlag.
///
/// / Råsa Digitalis:
///   Råsa, fast digitaliskt.
/// ```
///
/// - lang (str): The language of the document (same format as `text.lang`).
///               Only "sv" and "en" are supported.
/// - date (datetime): The date at which the document was written.
/// - body (content): The body of the document.
///
/// -> content
#let regulations(
  lang: "sv",
  date: datetime.today(),
  body,
) = {
  let regulations-name = translate("Reglemente", "Regulations")

  show: plain-document.with(
    title: [#regulations-name],
    lang: lang,
    date: date,
    doc-type: regulations-name,
    use-cover-page: true,
  )

  show list: resolutions.with(enumerate: false)
  show terms: terms-fmt.with(columns: (10.5em, 1fr))

  body
}

/// Swedish binding for `regulations`
#let reglemente = regulations
