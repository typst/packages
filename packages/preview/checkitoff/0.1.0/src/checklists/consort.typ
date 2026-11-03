// CONSORT 2025 checklist of information to include when reporting a
// randomised trial. Transcribed from `checklists/CONSORT 2025 editable
// checklist.pdf` (Hopewell S, Chan AW, Collins GS, Hróbjartsson A, Moher D,
// Schulz KF, et al. CONSORT 2025 Statement: updated guideline for
// reporting randomised trials. BMJ. 2025; 388:e081123.
// https://dx.doi.org/10.1136/bmj-2024-081123), verified page by page — see
// CLAUDE.md for the full transcription kept alongside the design notes.
//
// Data only: no rendering, no logic. `group` is `none` for every item
// except the five under "Randomisation" (17a–21d), CONSORT 2025's one
// mid-level heading nested inside the "Methods" section, between the
// section band and the topic rows — see `render-checklist` in `grid.typ`
// for how `group` is rendered.
//
// `style` reproduces the real .docx as closely as practical, values read
// directly out of its XML rather than guessed: `w:pgSz` (A4, landscape),
// `w:gridCol` widths (2547/992/9356/1417 twips, normalized below),
// `w:shd w:fill` (C6D9F1 for the 6 section bands, a slightly darker
// BDD7EE for the "Randomisation" group band — two distinct blues in the
// source, kept distinct here rather than collapsed to one), and
// `w:sz`/`w:ascii` (Calibri 11pt — Calibri itself isn't bundled with
// Typst and isn't installed on most systems, so `font:` falls back to
// Arial, a metrically close, widely available sans-serif substitute).
#let consort = (
  name: "CONSORT 2025",
  full-name: [CONSORT 2025 checklist of information to include when reporting a randomised trial],
  headers: ("Section / Topic", "No", "Description", "Reported on page no."),
  style: (
    paper: "a4",
    landscape: true,
    columns: (17.8%, 6.9%, 1fr, 9.9%),
    font: "Arial",
    text-size: 11pt,
    header-fill: none,
    header-text-color: black,
    section-fill: rgb("#C6D9F1"),
    group-fill: rgb("#BDD7EE"),
  ),
  citation: [
    We strongly recommend reading this statement in conjunction with the
    CONSORT 2025 Explanation and Elaboration and/or the CONSORT 2025
    Expanded Checklist for important clarifications on all the items. We
    also recommend reading relevant CONSORT extensions. See
    #link("https://www.consort-spirit.org")[www.consort-spirit.org].

    Citation: Hopewell S, Chan AW, Collins GS, Hróbjartsson A, Moher D,
    Schulz KF, et al. CONSORT 2025 Statement: updated guideline for
    reporting randomised trials. BMJ. 2025; 388:e081123.
    #link("https://dx.doi.org/10.1136/bmj-2024-081123")[https://dx.doi.org/10.1136/bmj-2024-081123].

    © 2025 Hopewell et al. This is an Open Access article distributed
    under the terms of the Creative Commons Attribution License
    (#link("https://creativecommons.org/licenses/by/4.0/")[https://creativecommons.org/licenses/by/4.0/]),
    which permits unrestricted use, distribution, and reproduction in any
    medium, provided the original work is properly cited.
  ],
  items: (
    (section: "Title and abstract", topic: "Title and structured abstract", group: none, id: "1a",
      description: [Identification as a randomised trial]),
    (section: "Title and abstract", topic: "Title and structured abstract", group: none, id: "1b",
      description: [Structured summary of the trial design, methods, results, and conclusions]),

    (section: "Open science", topic: "Trial registration", group: none, id: "2",
      description: [Name of trial registry, identifying number (with URL) and date of registration]),
    (section: "Open science", topic: "Protocol and statistical analysis plan", group: none, id: "3",
      description: [Where the trial protocol and statistical analysis plan can be accessed]),
    (section: "Open science", topic: "Data sharing", group: none, id: "4",
      description: [Where and how the individual de-identified participant data (including data dictionary), statistical code and any other materials can be accessed]),
    (section: "Open science", topic: "Funding and conflicts of interest", group: none, id: "5a",
      description: [Sources of funding and other support (e.g., supply of drugs), and role of funders in the design, conduct, analysis and reporting of the trial]),
    (section: "Open science", topic: "Funding and conflicts of interest", group: none, id: "5b",
      description: [Financial and other conflicts of interest of the manuscript authors]),

    (section: "Introduction", topic: "Background and rationale", group: none, id: "6",
      description: [Scientific background and rationale]),
    (section: "Introduction", topic: "Objectives", group: none, id: "7",
      description: [Specific objectives related to benefits and harms]),

    (section: "Methods", topic: "Patient and public involvement", group: none, id: "8",
      description: [Details of patient or public involvement in the design, conduct and reporting of the trial]),
    (section: "Methods", topic: "Trial design", group: none, id: "9",
      description: [Description of trial design including type of trial (e.g., parallel group, crossover), allocation ratio, and framework (e.g., superiority, equivalence, non-inferiority, exploratory)]),
    (section: "Methods", topic: "Changes to trial protocol", group: none, id: "10",
      description: [Important changes to the trial after it commenced including any outcomes or analyses that were not prespecified, with reason]),
    (section: "Methods", topic: "Trial setting", group: none, id: "11",
      description: [Settings (e.g., community, hospital) and locations (e.g., countries, sites) where the trial was conducted]),
    (section: "Methods", topic: "Eligibility criteria", group: none, id: "12a",
      description: [Eligibility criteria for participants]),
    (section: "Methods", topic: "Eligibility criteria", group: none, id: "12b",
      description: [If applicable, eligibility criteria for sites and for individuals delivering the interventions (e.g., surgeons, physiotherapists)]),
    (section: "Methods", topic: "Intervention and comparator", group: none, id: "13",
      description: [Intervention and comparator with sufficient details to allow replication. If relevant, where additional materials describing the intervention and comparator (e.g., intervention manual) can be accessed]),
    (section: "Methods", topic: "Outcomes", group: none, id: "14",
      description: [Pre-specified primary and secondary outcomes, including the specific measurement variable (e.g., systolic blood pressure), analysis metric (e.g., change from baseline, final value, time to event), method of aggregation (e.g., median, proportion), and time point for each outcome]),
    (section: "Methods", topic: "Harms", group: none, id: "15",
      description: [How harms were defined and assessed (e.g., systematically, non-systematically)]),
    (section: "Methods", topic: "Sample size", group: none, id: "16a",
      description: [How sample size was determined, including all assumptions supporting the sample size calculation]),
    (section: "Methods", topic: "Sample size", group: none, id: "16b",
      description: [Explanation of any interim analyses and stopping guidelines]),

    (section: "Methods", topic: "Sequence generation", group: "Randomisation", id: "17a",
      description: [Who generated the random allocation sequence and the method used]),
    (section: "Methods", topic: "Sequence generation", group: "Randomisation", id: "17b",
      description: [Type of randomisation and details of any restriction (e.g., stratification, blocking and block size)]),
    (section: "Methods", topic: "Allocation concealment mechanism", group: "Randomisation", id: "18",
      description: [Mechanism used to implement the random allocation sequence (e.g., central computer/telephone; sequentially numbered, opaque, sealed containers), describing any steps to conceal the sequence until interventions were assigned]),
    (section: "Methods", topic: "Implementation", group: "Randomisation", id: "19",
      description: [Whether the personnel who enrolled and those who assigned participants to the interventions had access to the random allocation sequence]),
    (section: "Methods", topic: "Blinding", group: "Randomisation", id: "20a",
      description: [Who was blinded after assignment to interventions (e.g., participants, care providers, outcome assessors, data analysts)]),
    (section: "Methods", topic: "Blinding", group: "Randomisation", id: "20b",
      description: [If blinded, how blinding was achieved and description of the similarity of interventions]),
    (section: "Methods", topic: "Statistical methods", group: "Randomisation", id: "21a",
      description: [Statistical methods used to compare groups for primary and secondary outcomes, including harms]),
    (section: "Methods", topic: "Statistical methods", group: "Randomisation", id: "21b",
      description: [Definition of who is included in each analysis (e.g., all randomised participants), and in which group]),
    (section: "Methods", topic: "Statistical methods", group: "Randomisation", id: "21c",
      description: [How missing data were handled in the analysis]),
    (section: "Methods", topic: "Statistical methods", group: "Randomisation", id: "21d",
      description: [Methods for any additional analyses (e.g., subgroup and sensitivity analyses), distinguishing prespecified from post-hoc]),

    (section: "Results", topic: "Participant flow, including flow diagram", group: none, id: "22a",
      description: [For each group, the numbers of participants who were randomly assigned, received intended intervention, and were analysed for the primary outcome]),
    (section: "Results", topic: "Participant flow, including flow diagram", group: none, id: "22b",
      description: [For each group, losses and exclusions after randomisation, together with reasons]),
    (section: "Results", topic: "Recruitment", group: none, id: "23a",
      description: [Dates defining the periods of recruitment and follow-up for outcomes of benefits and harms]),
    (section: "Results", topic: "Recruitment", group: none, id: "23b",
      description: [If relevant, why the trial ended or was stopped]),
    (section: "Results", topic: "Intervention and comparator delivery", group: none, id: "24a",
      description: [Intervention and comparator as they were actually administered (e.g., where appropriate, who delivered the intervention/comparator, how participants adhered, whether they were delivered as intended [fidelity])]),
    (section: "Results", topic: "Intervention and comparator delivery", group: none, id: "24b",
      description: [Concomitant care received during the trial for each group]),
    (section: "Results", topic: "Baseline data", group: none, id: "25",
      description: [A table showing baseline demographic and clinical characteristics for each group]),
    (section: "Results", topic: "Numbers analysed, outcomes and estimation", group: none, id: "26",
      description: [
        For each primary and secondary outcome, by group:
        - the number of participants included in the analysis
        - the number of participants with available data at the outcome time point
        - result for each group, and the estimated effect size and its precision (such as 95% confidence interval)
        - for binary outcomes, presentation of both absolute and relative effect size
      ]),
    (section: "Results", topic: "Harms", group: none, id: "27",
      description: [All harms or unintended events in each group]),
    (section: "Results", topic: "Ancillary analyses", group: none, id: "28",
      description: [Any other analyses performed, including subgroup and sensitivity analyses, distinguishing prespecified from post-hoc]),

    (section: "Discussion", topic: "Interpretation", group: none, id: "29",
      description: [Interpretation consistent with results, balancing benefits and harms, and considering other relevant evidence]),
    (section: "Discussion", topic: "Limitations", group: none, id: "30",
      description: [Trial limitations, addressing sources of potential bias, imprecision, generalisability, and, if relevant, multiplicity of analyses]),
  ),
)
