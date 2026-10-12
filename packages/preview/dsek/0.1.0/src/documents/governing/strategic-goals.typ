#import "governing-document.typ": governing-document
#import "../../lib/_mod.typ": *

/// #set raw(lang: "typst")
/// Creates a strategic goals (strategiska mål) document. Apply with `#show: strategiska-mål.with(...)` or `#show: strategic-goals.with(...)`.
///
/// === Notes
/// - The document begins with an "Översikt" / "Overview" section containing the summary, purpose, scope, and a revision history table. A page break separates the Overview section from the body.
///
/// === Example
/// ```typst
/// #import "@preview/dsek:0.1.0": *
///
/// #show: strategiska-mål.with(
///   summary: [De strategiska målen är mål som är strategiska.],
///   purpose: [Syftet med de strategiska målen är göra styrelsens arbete lite jobbigare.],
///   scope: [Hela D-sektionens verksamhet.],
///   history: (
///     (meeting: "HTM2 2021", change: "Ursprungligen antagen", who: "Framtidsutskottet 2021"),
///   ),
/// )
///
/// = Mål
///
/// == Korrigera benämning av de strategiska målen (2026--2028)
/// I dagsläget är det tydligen ingen som vet vad det här dokumentet faktiskt heter, utan i folkmun kallas det av outgrundliga skäl fortfarande för "den strategiska planen".
///
/// - Få folk att kalla de strategiska målen för de strategiska målen.
/// ```
///
/// - summary (content): Description of what this document covers.
/// - purpose (content): Why this document exists.
/// - scope (content): Who or what this document applies to.
/// - history (array): Modification history.
///                    Each entry is a dict with required keys `meeting`, `change`, and `who`.
/// - lang (str): The language of the document (same format as `text.lang`).
///               Only "sv" and "en" are supported.
/// - date (datetime): The date at which the document was written.
/// - body (content): The body of the document.
///
/// -> content
#let strategic-goals(
  summary: none,
  purpose: none,
  scope: none,
  history: (),
  date: datetime.today(),
  lang: "sv",
  body,
) = {
  let strategic-goals-name = translate("Strategiska mål", "Strategic goals")

  governing-document(
    title: strategic-goals-name,
    summary: summary,
    purpose: purpose,
    scope: scope,
    history: history,
    date: date,
    lang: lang,
    doc-type: strategic-goals-name,
    use-cover-page: true,
    body,
  )
}

/// Swedish binding for `strategic-goals`
#let strategiska-mål = strategic-goals
