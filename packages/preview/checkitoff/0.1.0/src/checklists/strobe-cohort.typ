// STROBE Statement — checklist of items that should be included in
// reports of cohort studies. Transcribed from `checklists/
// STROBE_checklist_cohort.docx` (von Elm E, Altman DG, Egger M, et al.
// The Strengthening the Reporting of Observational Studies in
// Epidemiology (STROBE) statement: guidelines for reporting observational
// studies. Lancet 2007;370:1453-1457), verified line by line against a
// plain-text conversion of the .docx.
//
// Data only: no rendering, no logic. A structural finding worth flagging
// explicitly, because it changes the shape of the data below compared to
// consort.typ/spirit.typ: STROBE's own "No" column does *not* split a
// multi-part item into separate ids the way CONSORT's 12a/12b or SPIRIT's
// 14a/14b do — item "1", say, carries a single page-number blank in the
// source table, with "(a) ..." and "(b) ..." as two paragraphs *inside
// that one item's own description* (same shape as CONSORT's item 26,
// which bundles four bullet points under one id). So this checklist has
// only 22 items (not ~30), several of which have a multi-paragraph
// description rather than a one-liner.
//
// `id-display` is used on items 8, 13, 14 and 15: the source table shows
// "8*", "13*", "14*", "15*" in the No column, the asterisk referring to
// the footnote in `citation` below ("Give information separately for
// exposed and unexposed groups") — the `*` is kept out of `id` itself so
// `check("8", ...)` stays a plain, unsurprising identifier; only the
// rendered column label carries it, exactly the same split `grid.typ`
// already needed for CONSORT's own footnote-marked items? No — CONSORT
// 2025 doesn't use this convention at all, so `id-display` was added to
// the schema specifically because of what this file needed, evidence
// (not assumed in advance) that a real second/third use case is what
// should decide a new generic field, not CONSORT's needs alone.
//
// `style`: `w:pgSz` (A4, portrait), `w:sz` (20 half-points = 10pt, theme
// font Calibri — approximated as Arial, same reasoning as consort.typ).
// No `w:shd` fill anywhere in the source at all — unlike every other
// checklist in this package, the real STROBE table is plain
// black-and-white, just bold text for section/topic labels — so
// `section-fill`/`group-fill` are `none` here on purpose, not an
// oversight.
#let strobe-cohort = (
  name: "STROBE (cohort)",
  full-name: [STROBE Statement — checklist of items that should be included in reports of cohort studies],
  headers: ("", "Item No", "Recommendation", "Page No"),
  style: (
    paper: "a4",
    landscape: false,
    columns: (20%, 7%, 1fr, 10%),
    font: "Arial",
    text-size: 10pt,
    header-fill: none,
    header-text-color: black,
    section-fill: none,
    section-text-color: black,
    group-fill: none,
    group-text-color: black,
  ),
  citation: [
    \*Give information separately for exposed and unexposed groups.

    Note: An Explanation and Elaboration article discusses each checklist
    item and gives methodological background and published examples of
    transparent reporting. The STROBE checklist is best used in
    conjunction with this article (freely available on the Web sites of
    PLoS Medicine at #link("http://www.plosmedicine.org/"), Annals of
    Internal Medicine at #link("http://www.annals.org/"), and
    Epidemiology at #link("http://www.epidem.com/")). Information on the
    STROBE Initiative is available at
    #link("http://www.strobe-statement.org").
  ],
  items: (
    (section: "Title and abstract", topic: none, group: none, id: "1", description: [
      (a) Indicate the study's design with a commonly used term in the title or the abstract

      (b) Provide in the abstract an informative and balanced summary of what was done and what was found
    ]),

    (section: "Introduction", topic: "Background/rationale", group: none, id: "2",
      description: [Explain the scientific background and rationale for the investigation being reported]),
    (section: "Introduction", topic: "Objectives", group: none, id: "3",
      description: [State specific objectives, including any prespecified hypotheses]),

    (section: "Methods", topic: "Study design", group: none, id: "4",
      description: [Present key elements of study design early in the paper]),
    (section: "Methods", topic: "Setting", group: none, id: "5",
      description: [Describe the setting, locations, and relevant dates, including periods of recruitment, exposure, follow-up, and data collection]),
    (section: "Methods", topic: "Participants", group: none, id: "6", description: [
      (a) Give the eligibility criteria, and the sources and methods of selection of participants. Describe methods of follow-up

      (b) For matched studies, give matching criteria and number of exposed and unexposed
    ]),
    (section: "Methods", topic: "Variables", group: none, id: "7",
      description: [Clearly define all outcomes, exposures, predictors, potential confounders, and effect modifiers. Give diagnostic criteria, if applicable]),
    (section: "Methods", topic: "Data sources/measurement", group: none, id: "8", id-display: "8*",
      description: [For each variable of interest, give sources of data and details of methods of assessment (measurement). Describe comparability of assessment methods if there is more than one group]),
    (section: "Methods", topic: "Bias", group: none, id: "9",
      description: [Describe any efforts to address potential sources of bias]),
    (section: "Methods", topic: "Study size", group: none, id: "10",
      description: [Explain how the study size was arrived at]),
    (section: "Methods", topic: "Quantitative variables", group: none, id: "11",
      description: [Explain how quantitative variables were handled in the analyses. If applicable, describe which groupings were chosen and why]),
    (section: "Methods", topic: "Statistical methods", group: none, id: "12", description: [
      (a) Describe all statistical methods, including those used to control for confounding

      (b) Describe any methods used to examine subgroups and interactions

      (c) Explain how missing data were addressed

      (d) If applicable, explain how loss to follow-up was addressed

      (e) Describe any sensitivity analyses
    ]),

    (section: "Results", topic: "Participants", group: none, id: "13", id-display: "13*", description: [
      (a) Report numbers of individuals at each stage of study — eg numbers potentially eligible, examined for eligibility, confirmed eligible, included in the study, completing follow-up, and analysed

      (b) Give reasons for non-participation at each stage

      (c) Consider use of a flow diagram
    ]),
    (section: "Results", topic: "Descriptive data", group: none, id: "14", id-display: "14*", description: [
      (a) Give characteristics of study participants (eg demographic, clinical, social) and information on exposures and potential confounders

      (b) Indicate number of participants with missing data for each variable of interest

      (c) Summarise follow-up time (eg, average and total amount)
    ]),
    (section: "Results", topic: "Outcome data", group: none, id: "15", id-display: "15*",
      description: [Report numbers of outcome events or summary measures over time]),
    (section: "Results", topic: "Main results", group: none, id: "16", description: [
      (a) Give unadjusted estimates and, if applicable, confounder-adjusted estimates and their precision (eg, 95% confidence interval). Make clear which confounders were adjusted for and why they were included

      (b) Report category boundaries when continuous variables were categorized

      (c) If relevant, consider translating estimates of relative risk into absolute risk for a meaningful time period
    ]),
    (section: "Results", topic: "Other analyses", group: none, id: "17",
      description: [Report other analyses done — eg analyses of subgroups and interactions, and sensitivity analyses]),

    (section: "Discussion", topic: "Key results", group: none, id: "18",
      description: [Summarise key results with reference to study objectives]),
    (section: "Discussion", topic: "Limitations", group: none, id: "19",
      description: [Discuss limitations of the study, taking into account sources of potential bias or imprecision. Discuss both direction and magnitude of any potential bias]),
    (section: "Discussion", topic: "Interpretation", group: none, id: "20",
      description: [Give a cautious overall interpretation of results considering objectives, limitations, multiplicity of analyses, results from similar studies, and other relevant evidence]),
    (section: "Discussion", topic: "Generalisability", group: none, id: "21",
      description: [Discuss the generalisability (external validity) of the study results]),

    (section: "Other information", topic: "Funding", group: none, id: "22",
      description: [Give the source of funding and the role of the funders for the present study and, if applicable, for the original study on which the present article is based]),
  ),
)
