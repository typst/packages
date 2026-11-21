#import "i18n.typ": i18n

/// Displays the responsible-use confirmations and a localized table of AI-assisted activities.
/// Language is selected from the surrounding `text.lang` setting (`en` or `de`).
///
/// - verification-confirmed (bool): Mark that AI-generated outputs were verified and corrected where needed. Defaults to `false`.
/// - responsibility-confirmed (bool): Mark that responsibility for the thesis remains with its author(s). Defaults to `false`.
/// - idea-generation-tools-used (content): AI tools used for idea generation and conceptualization. Defaults to `[]`.
/// - idea-generation-tool-usage (content): How those tools were used and which thesis sections were affected. Defaults to `[]`.
/// - literature-search-tools-used (content): AI tools used for literature search and analysis. Defaults to `[]`.
/// - literature-search-tool-usage (content): How those tools were used and which thesis sections were affected. Defaults to `[]`.
/// - methodology-tools-used (content): AI tools used for methodology. Defaults to `[]`.
/// - methodology-tool-usage (content): How those tools were used and which thesis sections were affected. Defaults to `[]`.
/// - coding-tools-used (content): AI tools used for coding. Defaults to `[]`.
/// - coding-tool-usage (content): How those tools were used and which thesis sections were affected. Defaults to `[]`.
/// - data-analysis-tools-used (content): AI tools used for data collection and analysis. Defaults to `[]`.
/// - data-analysis-tool-usage (content): How those tools were used and which thesis sections were affected. Defaults to `[]`.
/// - interpretation-tools-used (content): AI tools used for interpretation and validation. Defaults to `[]`.
/// - interpretation-tool-usage (content): How those tools were used and which thesis sections were affected. Defaults to `[]`.
/// - structuring-tools-used (content): AI tools used for structuring and planning the text. Defaults to `[]`.
/// - structuring-tool-usage (content): How those tools were used and which thesis sections were affected. Defaults to `[]`.
/// - text-generation-tools-used (content): AI tools used for generating text. Defaults to `[]`.
/// - text-generation-tool-usage (content): How those tools were used and which thesis sections were affected. Defaults to `[]`.
/// - translation-tools-used (content): AI tools used for translating text. Defaults to `[]`.
/// - translation-tool-usage (content): How those tools were used and which thesis sections were affected. Defaults to `[]`.
/// - text-review-tools-used (content): AI tools used for reviewing and editing text. Defaults to `[]`.
/// - text-review-tool-usage (content): How those tools were used and which thesis sections were affected. Defaults to `[]`.
/// - citation-management-tools-used (content): AI tools used for citation management. Defaults to `[]`.
/// - citation-management-tool-usage (content): How those tools were used and which thesis sections were affected. Defaults to `[]`.
#let generative-ai-documentation(
  verification-confirmed: false,
  responsibility-confirmed: false,
  idea-generation-tools-used: [],
  idea-generation-tool-usage: [],
  literature-search-tools-used: [],
  literature-search-tool-usage: [],
  methodology-tools-used: [],
  methodology-tool-usage: [],
  coding-tools-used: [],
  coding-tool-usage: [],
  data-analysis-tools-used: [],
  data-analysis-tool-usage: [],
  interpretation-tools-used: [],
  interpretation-tool-usage: [],
  structuring-tools-used: [],
  structuring-tool-usage: [],
  text-generation-tools-used: [],
  text-generation-tool-usage: [],
  translation-tools-used: [],
  translation-tool-usage: [],
  text-review-tools-used: [],
  text-review-tool-usage: [],
  citation-management-tools-used: [],
  citation-management-tool-usage: [],
) = [
  == #i18n("ai-responsible-use-heading")

  #i18n("ai-responsible-use-instruction")

  #table(
    columns: (3fr, 1fr),
    fill: (x, y) => if y == 0 { gray },
    table.header(
      [*#i18n("ai-responsible-use-statements")*],
      [*#i18n("ai-responsible-use-confirmation")*],
    ),
    [#i18n("ai-responsible-use-verification")],
    [☐ #if verification-confirmed { place(sym.crossmark, top) }],

    [#i18n("ai-responsible-use-author-responsibility")],
    [☐ #if responsibility-confirmed { place(sym.crossmark, top) }],
  )

  == #i18n("ai-activities-heading")

  #i18n("ai-activities-instruction")

  #i18n("ai-activities-note")

  #show table.cell.where(y: 0): set align(bottom)
  #table(
    columns: 4,
    fill: (x, y) => if y == 0 { gray },
    table.header(repeat: false,)[*#i18n("ai-activity")*][*#i18n(
      "description",
    )*][*#i18n("ai-tools-used")*\ (#i18n(
        "ai-tools-used-sidenote",
      ))#footnote[#i18n("ai-tools-used-footnote")]][*#i18n(
        "ai-tool-usage-description",
      )*\ (#i18n("ai-tool-usage-description-sidenote"))],
    [#i18n("ai-activity-idea-generation")],
    i18n("ai-description-idea-generation"),
    idea-generation-tools-used,
    idea-generation-tool-usage,

    [#i18n("ai-activity-literature-search")],
    i18n("ai-description-literature-search"),
    literature-search-tools-used,
    literature-search-tool-usage,

    [#i18n("ai-activity-methodology")],
    i18n("ai-description-methodology"),
    methodology-tools-used,
    methodology-tool-usage,

    [#i18n("ai-activity-coding")],
    i18n("ai-description-coding"),
    coding-tools-used,
    coding-tool-usage,

    [#i18n("ai-activity-data-analysis")],
    i18n("ai-description-data-analysis"),
    data-analysis-tools-used,
    data-analysis-tool-usage,

    [#i18n("ai-activity-interpretation")],
    i18n("ai-description-interpretation"),
    interpretation-tools-used,
    interpretation-tool-usage,

    [#i18n("ai-activity-structuring")],
    i18n("ai-description-structuring"),
    structuring-tools-used,
    structuring-tool-usage,

    [#i18n("ai-activity-text-generation")],
    i18n("ai-description-text-generation"),
    text-generation-tools-used,
    text-generation-tool-usage,

    [#i18n("ai-activity-translation")],
    i18n("ai-description-translation"),
    translation-tools-used,
    translation-tool-usage,

    [#i18n("ai-activity-text-review")],
    i18n("ai-description-text-review"),
    text-review-tools-used,
    text-review-tool-usage,

    [#i18n("ai-activity-citation-management")],
    i18n("ai-description-citation-management"),
    citation-management-tools-used,
    citation-management-tool-usage,
  )
]
