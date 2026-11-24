#import "../plain-document.typ": plain-document
#import "../../lib/_mod.typ": *
#import strings: guild

/// #set raw(lang: "typst")
/// Creates the guild statutes (stadgar) document. Apply with `#show: stadgar.with(...)` or `#show: statutes.with(...)`.
///
/// === Notes
/// - Terms blocks (`/ Term: Description`) are formatted as a §-numbered 3-column table.
///   - The §-number combines the current heading section and the term's index within the block (e.g. §1.2 for the second term under `= Sektionen`).
///
/// === Example
/// ```typst
/// #import "@preview/dsek:0.1.0": *
///
/// #show: stadgar
///
/// = Sektionen
///
/// / Namn:
///   Sektionens namn är D-sektionen.
///
/// / Ändamål:
///   Föreningens ändamål och syfte är att diskutera Policy för val.
/// ```
///
/// - lang (str): The language of the document (same format as `text.lang`).
///               Only "sv" and "en" are supported.
/// - date (datetime): The date at which the document was written.
/// - body (content): The body of the document.
///
/// -> content
#let statutes(
  lang: "sv",
  date: datetime.today(),
  body,
) = {
  let statutes-name = translate("Stadgar", "Statutes")

  // TODO: Should we set the meeting? Practice seems to be to set it to the meeting of last change.
  // Probably yes, but then ideally we'd need a way to also automatically get the last meeting
  // For other governing documents that's easy since an array of history entries is already required
  // But doing it for Regulations feels very tedious unless we also introduce the history array here
  show: plain-document.with(
    title: [#statutes-name],
    lang: lang,
    date: date,
    doc-type: statutes-name,
    use-cover-page: true,
  )

  show list: resolutions.with(enumerate: false)
  show terms: terms-fmt.with(columns: (3.5em, 9.5em, 1fr))

  body
}

/// Swedish binding for `statutes`
#let stadgar = statutes
