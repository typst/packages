// PRISMA 2020 Checklist. Transcribed from `checklists/PRISMA_2020_checklist.pdf`
// (Page MJ, McKenzie JE, Bossuyt PM, Boutron I, Hoffmann TC, Mulrow CD, et
// al. The PRISMA 2020 statement: an updated guideline for reporting
// systematic reviews. BMJ 2021;372:n71. doi: 10.1136/bmj.n71), verified
// page by page.
//
// Data only: no rendering, no logic. Deliberately shares the exact same
// shape as `consort.typ` — `section`, `topic`, `group`, `id`,
// `description` — added specifically to test that `render-checklist`'s
// mechanism generalizes, not just to CONSORT: `group` is `none` on every
// single item here (PRISMA 2020 has no mid-level heading at all, unlike
// CONSORT 2025's "Randomisation"), and `headers`/section wording differ
// from CONSORT's own ("Section and Topic" / "Item #" / "Checklist item" /
// "Location where item is reported", all-caps section bands) — nothing
// in `grid.typ` is CONSORT-specific, so both render correctly with zero
// checklist-specific code. See `tests/bundle-prisma-demo/`.
//
// `style`: only a PDF is available for PRISMA (no .docx to read exact
// XML values from, unlike consort.typ/spirit.typ/stard.typ), so this is
// approximated from the rendered page rather than measured — verified
// only for page size, which the PDF's own /MediaBox states exactly
// (792x612pt = US Letter landscape). Header/section colors are read off
// the checklist's own visual design (a dark navy-grey header band, pale
// yellow section bands) but not pixel-sampled, so treat the hex values
// as "close", not "exact" — safe to override via `set-style(...)` for
// anyone who has the original template to check against.
#let prisma = (
  name: "PRISMA 2020",
  full-name: [PRISMA 2020 Checklist],
  headers: ("Section and Topic", "Item #", "Checklist item", "Location where item is reported"),
  style: (
    paper: "us-letter",
    landscape: true,
    columns: (17.8%, 6.9%, 1fr, 9.9%),
    font: "Arial",
    text-size: 9pt,
    header-fill: rgb("#44546A"),
    header-text-color: white,
    section-fill: rgb("#FFF2CC"),
    group-fill: rgb("#FFF2CC"),
  ),
  citation: [
    From: Page MJ, McKenzie JE, Bossuyt PM, Boutron I, Hoffmann TC, Mulrow
    CD, et al. The PRISMA 2020 statement: an updated guideline for
    reporting systematic reviews. BMJ 2021;372:n71. doi:
    #link("https://doi.org/10.1136/bmj.n71")[10.1136/bmj.n71].
  ],
  items: (
    (section: "TITLE", topic: "Title", group: none, id: "1",
      description: [Identify the report as a systematic review.]),

    (section: "ABSTRACT", topic: "Abstract", group: none, id: "2",
      description: [See the PRISMA 2020 for Abstracts checklist.]),

    (section: "INTRODUCTION", topic: "Rationale", group: none, id: "3",
      description: [Describe the rationale for the review in the context of existing knowledge.]),
    (section: "INTRODUCTION", topic: "Objectives", group: none, id: "4",
      description: [Provide an explicit statement of the objective(s) or question(s) the review addresses.]),

    (section: "METHODS", topic: "Eligibility criteria", group: none, id: "5",
      description: [Specify the inclusion and exclusion criteria for the review and how studies were grouped for the syntheses.]),
    (section: "METHODS", topic: "Information sources", group: none, id: "6",
      description: [Specify all databases, registers, websites, organisations, reference lists and other sources searched or consulted to identify studies. Specify the date when each source was last searched or consulted.]),
    (section: "METHODS", topic: "Search strategy", group: none, id: "7",
      description: [Present the full search strategies for all databases, registers and websites, including any filters and limits used.]),
    (section: "METHODS", topic: "Selection process", group: none, id: "8",
      description: [Specify the methods used to decide whether a study met the inclusion criteria of the review, including how many reviewers screened each record and each report retrieved, whether they worked independently, and if applicable, details of automation tools used in the process.]),
    (section: "METHODS", topic: "Data collection process", group: none, id: "9",
      description: [Specify the methods used to collect data from reports, including how many reviewers collected data from each report, whether they worked independently, any processes for obtaining or confirming data from study investigators, and if applicable, details of automation tools used in the process.]),
    (section: "METHODS", topic: "Data items", group: none, id: "10a",
      description: [List and define all outcomes for which data were sought. Specify whether all results that were compatible with each outcome domain in each study were sought (e.g. for all measures, time points, analyses), and if not, the methods used to decide which results to collect.]),
    (section: "METHODS", topic: "Data items", group: none, id: "10b",
      description: [List and define all other variables for which data were sought (e.g. participant and intervention characteristics, funding sources). Describe any assumptions made about any missing or unclear information.]),
    (section: "METHODS", topic: "Study risk of bias assessment", group: none, id: "11",
      description: [Specify the methods used to assess risk of bias in the included studies, including details of the tool(s) used, how many reviewers assessed each study and whether they worked independently, and if applicable, details of automation tools used in the process.]),
    (section: "METHODS", topic: "Effect measures", group: none, id: "12",
      description: [Specify for each outcome the effect measure(s) (e.g. risk ratio, mean difference) used in the synthesis or presentation of results.]),
    (section: "METHODS", topic: "Synthesis methods", group: none, id: "13a",
      description: [Describe the processes used to decide which studies were eligible for each synthesis (e.g. tabulating the study intervention characteristics and comparing against the planned groups for each synthesis (item #5)).]),
    (section: "METHODS", topic: "Synthesis methods", group: none, id: "13b",
      description: [Describe any methods required to prepare the data for presentation or synthesis, such as handling of missing summary statistics, or data conversions.]),
    (section: "METHODS", topic: "Synthesis methods", group: none, id: "13c",
      description: [Describe any methods used to tabulate or visually display results of individual studies and syntheses.]),
    (section: "METHODS", topic: "Synthesis methods", group: none, id: "13d",
      description: [Describe any methods used to synthesize results and provide a rationale for the choice(s). If meta-analysis was performed, describe the model(s), method(s) to identify the presence and extent of statistical heterogeneity, and software package(s) used.]),
    (section: "METHODS", topic: "Synthesis methods", group: none, id: "13e",
      description: [Describe any methods used to explore possible causes of heterogeneity among study results (e.g. subgroup analysis, meta-regression).]),
    (section: "METHODS", topic: "Synthesis methods", group: none, id: "13f",
      description: [Describe any sensitivity analyses conducted to assess robustness of the synthesized results.]),
    (section: "METHODS", topic: "Reporting bias assessment", group: none, id: "14",
      description: [Describe any methods used to assess risk of bias due to missing results in a synthesis (arising from reporting biases).]),
    (section: "METHODS", topic: "Certainty assessment", group: none, id: "15",
      description: [Describe any methods used to assess certainty (or confidence) in the body of evidence for an outcome.]),

    (section: "RESULTS", topic: "Study selection", group: none, id: "16a",
      description: [Describe the results of the search and selection process, from the number of records identified in the search to the number of studies included in the review, ideally using a flow diagram.]),
    (section: "RESULTS", topic: "Study selection", group: none, id: "16b",
      description: [Cite studies that might appear to meet the inclusion criteria, but which were excluded, and explain why they were excluded.]),
    (section: "RESULTS", topic: "Study characteristics", group: none, id: "17",
      description: [Cite each included study and present its characteristics.]),
    (section: "RESULTS", topic: "Risk of bias in studies", group: none, id: "18",
      description: [Present assessments of risk of bias for each included study.]),
    (section: "RESULTS", topic: "Results of individual studies", group: none, id: "19",
      description: [For all outcomes, present, for each study: (a) summary statistics for each group (where appropriate) and (b) an effect estimate and its precision (e.g. confidence/credible interval), ideally using structured tables or plots.]),
    (section: "RESULTS", topic: "Results of syntheses", group: none, id: "20a",
      description: [For each synthesis, briefly summarise the characteristics and risk of bias among contributing studies.]),
    (section: "RESULTS", topic: "Results of syntheses", group: none, id: "20b",
      description: [Present results of all statistical syntheses conducted. If meta-analysis was done, present for each the summary estimate and its precision (e.g. confidence/credible interval) and measures of statistical heterogeneity. If comparing groups, describe the direction of the effect.]),
    (section: "RESULTS", topic: "Results of syntheses", group: none, id: "20c",
      description: [Present results of all investigations of possible causes of heterogeneity among study results.]),
    (section: "RESULTS", topic: "Results of syntheses", group: none, id: "20d",
      description: [Present results of all sensitivity analyses conducted to assess the robustness of the synthesized results.]),
    (section: "RESULTS", topic: "Reporting biases", group: none, id: "21",
      description: [Present assessments of risk of bias due to missing results (arising from reporting biases) for each synthesis assessed.]),
    (section: "RESULTS", topic: "Certainty of evidence", group: none, id: "22",
      description: [Present assessments of certainty (or confidence) in the body of evidence for each outcome assessed.]),

    (section: "DISCUSSION", topic: "Discussion", group: none, id: "23a",
      description: [Provide a general interpretation of the results in the context of other evidence.]),
    (section: "DISCUSSION", topic: "Discussion", group: none, id: "23b",
      description: [Discuss any limitations of the evidence included in the review.]),
    (section: "DISCUSSION", topic: "Discussion", group: none, id: "23c",
      description: [Discuss any limitations of the review processes used.]),
    (section: "DISCUSSION", topic: "Discussion", group: none, id: "23d",
      description: [Discuss implications of the results for practice, policy, and future research.]),

    (section: "OTHER INFORMATION", topic: "Registration and protocol", group: none, id: "24a",
      description: [Provide registration information for the review, including register name and registration number, or state that the review was not registered.]),
    (section: "OTHER INFORMATION", topic: "Registration and protocol", group: none, id: "24b",
      description: [Indicate where the review protocol can be accessed, or state that a protocol was not prepared.]),
    (section: "OTHER INFORMATION", topic: "Registration and protocol", group: none, id: "24c",
      description: [Describe and explain any amendments to information provided at registration or in the protocol.]),
    (section: "OTHER INFORMATION", topic: "Support", group: none, id: "25",
      description: [Describe sources of financial or non-financial support for the review, and the role of the funders or sponsors in the review.]),
    (section: "OTHER INFORMATION", topic: "Competing interests", group: none, id: "26",
      description: [Declare any competing interests of review authors.]),
    (section: "OTHER INFORMATION", topic: "Availability of data, code and other materials", group: none, id: "27",
      description: [Report which of the following are publicly available and where they can be found: template data collection forms; data extracted from included studies; data used for all analyses; analytic code; any other materials used in the review.]),
  ),
)
