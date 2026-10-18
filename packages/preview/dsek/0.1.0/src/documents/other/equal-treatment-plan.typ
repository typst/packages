#import "../plain-document.typ": plain-document
#import "../../lib/_mod.typ": *

/// #set raw(lang: "typst")
/// Creates an Equal treatment plan (likabehandlingsplan) document. Apply with `#show: likabehandlingsplan.with(...)` or `#show: equal-treatment-plan.with(...)`.
///
/// === Example
/// ```typst
/// #import "@preview/dsek:0.1.0": *
/// #import strings: km
///
/// #show: likabehandlingsplan.with(
///   committee: km.name, // title becomes "Likabehandlingsplan - Källarmästeriet"
///   meeting: [S21],
/// )
///
/// Vi ska verka för att alla ska få lika mycket köttfärssås på Snickerboa.
/// ```
///
/// - committee (str, content): The committee the plan applies to.
/// - meeting (str, content): The meeting for which the document was written, e.g. `"HTM1"`.
/// - date (datetime): The date at which the document was written.
/// - lang (str): The language of the document (same format as `text.lang`).
///               Only "sv" and "en" are supported.
/// - body (content): The body of the document.
///
/// -> content
#let equal-treatment-plan(
  committee: none,
  meeting: none,
  date: datetime.today(),
  lang: "sv",
  body,
) = {
  let etp = "equal-treatment-plan"
  required(committee, "committee", fn: etp)
  required(meeting, "meeting", fn: etp)
  let plan-name = translate("Likabehandlingsplan", "Equal Treatment Plan")
  show: plain-document.with(
    title: [#plan-name -- #committee],
    doc-type: plan-name,
    meeting: meeting,
    date: date,
    lang: lang,
  )

  body
}

/// Swedish binding for `equal-treatment-plan`
#let likabehandlingsplan = equal-treatment-plan
