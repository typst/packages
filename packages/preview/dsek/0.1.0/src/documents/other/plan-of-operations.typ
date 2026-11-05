#import "../plain-document.typ": plain-document
#import "../../lib/_mod.typ": *

/// #set raw(lang: "typst")
/// Creates a plan of operations (verksamhetsplan) document. Apply with `#show: verksamhetsplan.with(...)` or `#show: plan-of-operations.with(...)`.
///
/// === Notes
/// - The document begins with a pre-filled "Översikt" / "Overview" section containing subsections summary, purpose, structure, responsibility, and reporting. A page break separates the Overview section from the body.
///   - The different sections can be overridden using the `overview-overrides` parameter.
///
/// === Example
/// ```typst
/// #import "@preview/dsek:0.1.0": *
///
/// #show: verksamhetsplan // `Overview` section inserted automatically
///
/// = Mål från de strategiska målen
///
/// == Korrigera benämning av de strategiska målen
/// För att säkerställa att målet uppfylls tänker vi ta i med hårdhandskarna.
/// - Be jättesnällt för annars blir vi ledsna i ögat :(
/// ```
///
/// - overview-overrides (dict): A dictionary of overrides in the Overview section.
///                              Available keys are `summary`, `purpose`, `structure`,
///                              `responsibility` and `reporting`.
/// - year (int): The year for which the plan was written. Defaults to next year.
/// - lang (str): The language of the document (same format as `text.lang`).
///               Only "sv" and "en" are supported.
/// - date (datetime): The date at which the document was written.
/// - body (content): The body of the document.
///
/// -> content
#let plan-of-operations(
  year: datetime.today().year() + 1,
  overview-overrides: (:),
  lang: "sv",
  date: datetime.today(),
  body,
) = {
  required-keys(
    overview-overrides,
    (),
    allowed: (
      "summary",
      "purpose",
      "structure",
      "responsibility",
      "reporting",
    ),
    fn: "plan-of-operations",
    hint: "must be one of `summary`, `purpose`, `structure`, `responsibility` or `reporting`",
  )

  let plan-name = translate("Verksamhetsplan", "Plan of Operations")

  show: plain-document.with(
    title: [#plan-name #year],
    doc-type: plan-name,
    date: date,
    lang: lang,
    use-cover-page: true,
  )

  [= #translate("Översikt", "Overview")]
  [
    #show terms: terms-fmt.with(columns: (9.5em, 1fr))
    / #translate("Sammanfattning", "Summary"): #overview-overrides.at(
        "summary",
        default: translate(
          [Verksamhetsplan för D-sektionen, vilken innehåller aktuella mål för året.],
          [The Plan of Operations for the D-guild, which contains the current goals for the year.],
        ),
      )
    / #translate("Syfte", "Purpose"): #overview-overrides.at(
        "purpose",
        default: translate(
          [Verksamhetsplanen är ett sätt för sektionens medlemmar att påverka vad som skall ligga i fokus det nästkommande verksamhetsåret],
          [The Plan of Operations is a way for the guild's members to influence the focus of the upcoming operational year.],
        ),
      )
    / #translate("Upplägg", "Structure"): #overview-overrides.at(
        "structure",
        default: translate(
          [Verksamhetsplanen består av två olika delar: projekt sprungna ur den strategiska planen samt årsspecifika projekt. Alla mål skall vara tydligt förklarade samt konkreta. Det ska vara lätt att utvärdera huruvida målet är uppnått.],
          [The Plan of Operations consists of two parts: projects derived from the Strategic plan and year-specific projects. All goals should be clearly explained and concrete. It should be easy to evaluate whether a goal has been achieved.],
        ),
      )
    / #translate("Ansvar", "Responsibility"): #overview-overrides.at(
        "responsibility",
        default: translate(
          [Ytterst ansvariga för verksamhetsplanen är styrelsen. Styrelsen kan dock med fördel ta hjälp av andra delar av sektionen för att uppnå målen.],
          [The Board is ultimately responsible for the Plan of Operations. However, the Board may benefit from the assistance of other parts of the guild to achieve the goals.],
        ),
      )
    / #translate("Rapportering", "Reporting"): #overview-overrides.at(
        "reporting",
        default: translate(
          [Styrelsen ska rapportera status kring det arbete som pågår med målen minst två gånger per år, förslagsvis på sektionsmöten. Styrelsen har dessutom som mål att på styrelsemöten ta upp hur verksamhetsplanen arbetas med i utskotten. Verksamhetsplanen ska finnas tydligt reflekterad i verksamhetsrapporten i slutet av året. I verksamhetsrapporten ska minst finnas vad som gjordes samt resultatet av dessa handlingar.],
          [The Board shall report on the progress of the goals at least twice a year, preferably at guild assemblies. Furthermore, the Board should aim to discuss the progress of the Plan of Operations within the committees during board meetings. The Plan of Operations should be clearly reflected in the operational report at the end of the year, detailing what was done and the results of those actions.],
        ),
      )
  ]
  pagebreak()
  body
}

/// Swedish binding for `plan-of-operations`
#let verksamhetsplan = plan-of-operations
