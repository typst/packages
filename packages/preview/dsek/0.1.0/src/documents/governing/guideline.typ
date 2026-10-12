#import "governing-document.typ": governing-document
#import "../../lib/_mod.typ": *

/// #set raw(lang: "typst")
/// Creates a guideline (riktlinje) document. Apply with `#show: riktlinje.with(...)` or `#show: guideline.with(...)`.
///
/// === Notes
/// - The document begins with an "Översikt" / "Overview" section containing the summary, purpose, scope, and a revision history table. A page break separates the Overview section from the body.
///
/// === Example
/// ```typst
/// #import "@preview/dsek:0.1.0": *
///
/// #show: riktlinje.with(
///   subject: "sektionsbilens användning", // title becomes "Riktlinje för sektionsbilens användning"
///   summary: [Riktlinjen beskriver hur man inte är en trafikfara.],
///   purpose: [Syftet med denna riktlinje är att undvika ännu ett VTM-extra.],
///   scope: [Alla på sektionen som har körkort.],
///   history: (
///     (
///       meeting: "S14 2024",
///       change: "Uppdaterade bilens registreringsnummer",
///       who: "Styrelsen genom Truls Teknolog",
///     ),
///   ),
/// )
///
/// = Hastigheter
///
/// Bilen får inte köras i över 80 km/h. Inte för att det är olagligt, utan för att motorn inte klarar av det.
/// ```
///
///
/// - subject (str): The subject of the guideline, e.g. `"Grafisk design"` or `"Överlämning"`.
/// - summary (content): A description of what this document covers.
/// - purpose (content): Why this document exists.
/// - scope (content): Who or what this document applies to.
/// - history (array): Modification history. Each entry is a dict with required keys
///   `meeting`, `change`, and `who`.
/// - date (datetime): The date at which the document was written.
/// - lang (str): The language of the document (same format as `text.lang`).
///               Only "sv" and "en" are supported.
/// - use-cover-page (bool): Whether to render the title on a separate cover page instead of a heading.
/// - body (content): The body of the document.
///
/// -> content
#let guideline(
  subject: none,
  summary: none,
  purpose: none,
  scope: none,
  history: (),
  date: datetime.today(),
  lang: "sv",
  use-cover-page: false,
  body,
) = {
  required(subject, "subject", fn: "guideline")
  let guideline-name = translate("Riktlinje", "Guideline")

  governing-document(
    title: if use-cover-page { subject } else [#guideline-name #translate("för", "for") #subject],
    summary: summary,
    purpose: purpose,
    scope: scope,
    history: history,
    date: date,
    lang: lang,
    doc-type: guideline-name,
    use-cover-page: use-cover-page,
    body,
  )
}

/// Swedish binding for `guideline`.
#let riktlinje = guideline
