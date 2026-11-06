#import "../plain-document.typ": plain-document
#import "../../lib/_mod.typ": *

// Since these generally are not edited nor written often, we think it is fine,
// or even appropriate, for governing documents to be more "function-heavy".
// This way, a more correct way of writing is enforced, rather than relying on
// freehand typing to be consistent.

/// #set raw(lang: "typst")
/// Creates a generic governing document (policy / guideline / strategic goals).
///
/// === Notes
/// - The document begins with an "Översikt" / "Overview" section containing the summary, purpose, scope, and a revision history table. A page break separates the Overview section from the body.
///
/// - title (content): The title of the rubric, e.g. `"val"` or `"överlämning"`.
/// - summary (content): Description of what this document covers.
/// - purpose (content): Why this document exists.
/// - scope (content): Who or what this document applies to.
/// - history (array): The modification history.
///                    Each entry is a dict with required keys `meeting`, `change`, and `who`.
/// - lang (str): The language of the document (same format as `text.lang`).
///               Only "sv" and "en" are supported.
/// - date (datetime): The date at which the document was written.
/// - doc-type (str): Document "type" label, shown in the page header.
/// - use-cover-page (bool): Whether to render the title on a separate cover page instead of a heading.
/// - body (content): The body of the document.
///
/// -> content
#let governing-document(
  title: none,
  summary: none,
  purpose: none,
  scope: none,
  history: (),
  date: datetime.today(),
  lang: "sv",
  doc-type: "",
  use-cover-page: false,
  body,
) = {
  required(summary, "summary", fn: "governing-document")
  required(purpose, "purpose", fn: "governing-document")
  required(scope, "scope", fn: "governing-document")
  required(
    history,
    "history",
    fn: "governing-document",
    hint: "array of (meeting: ..., change: ..., who: ...) dicts, e.g. ((meeting: \"HTM1\", change: \"Uppdaterad enligt proposition\", who: \"Styrelsen genom Truls Teknolog och Trula Teknolog\"),)",
  )
  for entry in history {
    required-keys(
      entry,
      ("meeting", "change", "who"),
      fn: "governing-document (history entry)",
      hint: "(meeting: \"HTM1\", change: \"Uppdaterad enligt proposition\", who: \"Styrelsen genom Truls Teknolog och Trula Teknolog\")",
      allowed: ("meeting", "change", "who"),
    )
  }

  show: plain-document.with(
    title: title,
    doc-type: doc-type,
    meeting: history.last().meeting,
    date: date,
    lang: lang,
    use-cover-page: use-cover-page,
  )

  // TODO: Change "Policy för styrdokument" to reflect the new style.
  // <policybrott>
  context [= #translate-str("Översikt", "Overview")]

  context [
    // #show heading.where(level: 20): it => [
    //   #set text(font: text.font, size: text.size, weight: text.weight)
    //   #it.body
    // ]
    #let fmt-term(se, en) = {
      set heading(depth: 2, numbering: none)
      show heading: set text(size: text.size, weight: text.weight, font: text.font)
      show heading: set par(justify: false)
      heading(translate-str(se, en))
    }
    #show terms: terms-fmt.with(columns: (9.5em, 1fr))
    / #fmt-term("Sammanfattning", "Summary"): #summary
    / #fmt-term("Syfte", "Purpose"): #purpose
    / #fmt-term("Omfattning", "Scope"): #scope
  ]

  context heading(
    numbering: none,
    depth: 2,
    translate-str("Historik", "Revisions"),
  )
  // </policybrott>

  context table(
    columns: (8em, 1.2fr, auto),
    stroke: none,
    table.hline(stroke: 0.4pt, position: bottom),
    table.header(
      [*#translate("Möte", "Meeting")*],
      [*#translate("Ändring", "Modification")*],
      [*#translate("Ansvarig", "Responsible")*],
    ),
    row-gutter: (0.25em, auto),
    ..history
      .map(edit => {
        (
          [
            #edit.meeting
          ],
          [
            #set par(justify: false)
            #edit.change
          ],
          [
            #set par(justify: false)
            #context {
              let width = measure(edit.who).width
              block(width: calc.min(width, 150pt), edit.who)
            }
          ],
        )
      })
      .flatten(),
  )

  pagebreak(weak: true)
  body
}
