// STARD 2015 checklist for reporting of studies of diagnostic accuracy.
// Transcribed from `checklists/STARD-2015-Checklist.docx` (Bossuyt PM,
// Reitsma JB, Bruns DE, et al. STARD 2015: An Updated List of Essential
// Items for Reporting Diagnostic Accuracy Studies. BMJ 2015;351:h5527),
// verified line by line against a plain-text conversion of the .docx.
//
// Data only: no rendering, no logic. Two structural points worth calling
// out, both handled by the existing generic model without any change:
// - Several single-item sections ("TITLE OR ABSTRACT", "ABSTRACT",
//   "INTRODUCTION", "DISCUSSION", "OTHER INFORMATION") have no distinct
//   Topic label in the source table at all — `topic: none` on those
//   items renders as a blank Topic cell, exactly matching the source's
//   own merged/blank cell there (`grid.typ`'s `[#it.topic]` already
//   renders `none` as nothing).
// - `group` is `none` everywhere: unlike CONSORT 2025/SPIRIT 2025, STARD
//   has no mid-level heading at all.
//
// `style`: this checklist's official reference document is a .docx
// (unlike PRISMA, which is PDF-only) — `w:pgSz` (US Letter, portrait),
// `w:gridCol` (121/1727/518/7281/1692 twips; the 121-twip column is a
// thin decorative spacer, dropped — the remaining four normalize to the
// ratios below), `w:sz` (18 half-points = 9pt, no explicit `w:ascii`,
// theme default is Calibri — approximated as Arial, same reasoning as
// consort.typ), `w:shd w:fill` (5B9BD5, a substantially more saturated
// blue than CONSORT's or SPIRIT's pale bands — kept as found rather than
// smoothed toward the other checklists' palette, since it's what this
// particular source actually uses; paired with white section-band text,
// since black-on-5B9BD5 reads noticeably worse).
#let stard = (
  name: "STARD 2015",
  full-name: [STARD 2015 checklist for reporting of studies of diagnostic accuracy],
  headers: ("Section & Topic", "No", "Item", "Reported on page #"),
  style: (
    paper: "us-letter",
    landscape: false,
    columns: (15.4%, 4.6%, 1fr, 15.1%),
    font: "Arial",
    text-size: 9pt,
    header-fill: none,
    header-text-color: black,
    section-fill: rgb("#5B9BD5"),
    section-text-color: white,
    group-fill: rgb("#5B9BD5"),
    group-text-color: white,
  ),
  citation: [
    *AIM* — STARD stands for "Standards for Reporting Diagnostic accuracy
    studies". This list of items was developed to contribute to the
    completeness and transparency of reporting of diagnostic accuracy
    studies. Authors can use the list to write informative study reports.
    Editors and peer-reviewers can use it to evaluate whether the
    information has been included in manuscripts submitted for
    publication.

    *Explanation* — A diagnostic accuracy study evaluates the ability of
    one or more medical tests to correctly classify study participants as
    having a target condition. The test whose accuracy is evaluated is
    called the index test; the reference standard is the best available
    method for establishing the presence or absence of the target
    condition.

    *Development* — This STARD list was released in 2015. The 30 items
    were identified by an international expert group of methodologists,
    researchers, and editors, and represent an update of the first
    version, published in 2003. More information can be found at
    #link("http://www.equator-network.org/reporting-guidelines/stard")[www.equator-network.org/reporting-guidelines/stard].
  ],
  items: (
    (section: "TITLE OR ABSTRACT", topic: none, group: none, id: "1",
      description: [Identification as a study of diagnostic accuracy using at least one measure of accuracy (such as sensitivity, specificity, predictive values, or AUC)]),

    (section: "ABSTRACT", topic: none, group: none, id: "2",
      description: [Structured summary of study design, methods, results, and conclusions (for specific guidance, see STARD for Abstracts)]),

    (section: "INTRODUCTION", topic: none, group: none, id: "3",
      description: [Scientific and clinical background, including the intended use and clinical role of the index test]),
    (section: "INTRODUCTION", topic: none, group: none, id: "4",
      description: [Study objectives and hypotheses]),

    (section: "METHODS", topic: "Study design", group: none, id: "5",
      description: [Whether data collection was planned before the index test and reference standard were performed (prospective study) or after (retrospective study)]),
    (section: "METHODS", topic: "Participants", group: none, id: "6",
      description: [Eligibility criteria]),
    (section: "METHODS", topic: "Participants", group: none, id: "7",
      description: [On what basis potentially eligible participants were identified (such as symptoms, results from previous tests, inclusion in registry)]),
    (section: "METHODS", topic: "Participants", group: none, id: "8",
      description: [Where and when potentially eligible participants were identified (setting, location and dates)]),
    (section: "METHODS", topic: "Participants", group: none, id: "9",
      description: [Whether participants formed a consecutive, random or convenience series]),
    (section: "METHODS", topic: "Test methods", group: none, id: "10a",
      description: [Index test, in sufficient detail to allow replication]),
    (section: "METHODS", topic: "Test methods", group: none, id: "10b",
      description: [Reference standard, in sufficient detail to allow replication]),
    (section: "METHODS", topic: "Test methods", group: none, id: "11",
      description: [Rationale for choosing the reference standard (if alternatives exist)]),
    (section: "METHODS", topic: "Test methods", group: none, id: "12a",
      description: [Definition of and rationale for test positivity cut-offs or result categories of the index test, distinguishing pre-specified from exploratory]),
    (section: "METHODS", topic: "Test methods", group: none, id: "12b",
      description: [Definition of and rationale for test positivity cut-offs or result categories of the reference standard, distinguishing pre-specified from exploratory]),
    (section: "METHODS", topic: "Test methods", group: none, id: "13a",
      description: [Whether clinical information and reference standard results were available to the performers/readers of the index test]),
    (section: "METHODS", topic: "Test methods", group: none, id: "13b",
      description: [Whether clinical information and index test results were available to the assessors of the reference standard]),
    (section: "METHODS", topic: "Analysis", group: none, id: "14",
      description: [Methods for estimating or comparing measures of diagnostic accuracy]),
    (section: "METHODS", topic: "Analysis", group: none, id: "15",
      description: [How indeterminate index test or reference standard results were handled]),
    (section: "METHODS", topic: "Analysis", group: none, id: "16",
      description: [How missing data on the index test and reference standard were handled]),
    (section: "METHODS", topic: "Analysis", group: none, id: "17",
      description: [Any analyses of variability in diagnostic accuracy, distinguishing pre-specified from exploratory]),
    (section: "METHODS", topic: "Analysis", group: none, id: "18",
      description: [Intended sample size and how it was determined]),

    (section: "RESULTS", topic: "Participants", group: none, id: "19",
      description: [Flow of participants, using a diagram]),
    (section: "RESULTS", topic: "Participants", group: none, id: "20",
      description: [Baseline demographic and clinical characteristics of participants]),
    (section: "RESULTS", topic: "Participants", group: none, id: "21a",
      description: [Distribution of severity of disease in those with the target condition]),
    (section: "RESULTS", topic: "Participants", group: none, id: "21b",
      description: [Distribution of alternative diagnoses in those without the target condition]),
    (section: "RESULTS", topic: "Participants", group: none, id: "22",
      description: [Time interval and any clinical interventions between index test and reference standard]),
    (section: "RESULTS", topic: "Test results", group: none, id: "23",
      description: [Cross tabulation of the index test results (or their distribution) by the results of the reference standard]),
    (section: "RESULTS", topic: "Test results", group: none, id: "24",
      description: [Estimates of diagnostic accuracy and their precision (such as 95% confidence intervals)]),
    (section: "RESULTS", topic: "Test results", group: none, id: "25",
      description: [Any adverse events from performing the index test or the reference standard]),

    (section: "DISCUSSION", topic: none, group: none, id: "26",
      description: [Study limitations, including sources of potential bias, statistical uncertainty, and generalisability]),
    (section: "DISCUSSION", topic: none, group: none, id: "27",
      description: [Implications for practice, including the intended use and clinical role of the index test]),

    (section: "OTHER INFORMATION", topic: none, group: none, id: "28",
      description: [Registration number and name of registry]),
    (section: "OTHER INFORMATION", topic: none, group: none, id: "29",
      description: [Where the full study protocol can be accessed]),
    (section: "OTHER INFORMATION", topic: none, group: none, id: "30",
      description: [Sources of funding and other support; role of funders]),
  ),
)
