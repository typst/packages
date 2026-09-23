// SPIRIT 2025 checklist of items to address in a randomized trial
// protocol. Transcribed from `checklists/SPIRIT 2025 editable
// checklist.docx` (Chan A-W, Boutron I, Hopewell S, Moher D, Schulz KF,
// et al. SPIRIT 2025 statement: updated guideline for protocols of
// randomised trials. BMJ 2025;389:e081477.
// https://dx.doi.org/10.1136/bmj-2024-081477), verified line by line
// against a plain-text conversion of the .docx.
//
// Data only: no rendering, no logic. Shares CONSORT 2025's authorship and
// house style closely — same 4-column shape, and the same single
// mid-level "Randomization" group (here inside "Methods: Assignment of
// interventions", covering sequence generation/allocation concealment/
// implementation/blinding, items 21a-24c), reusing `grid.typ`'s
// `group` mechanism unchanged.
//
// `style`: read from the .docx XML like consort.typ — `w:pgSz` (US
// Letter, landscape: 15840x12240 twips), `w:gridCol` (2405/567/8723/1260
// twips), `w:sz`/`w:ascii` (Calibri 10pt — approximated as Arial, same
// reasoning as consort.typ), `w:shd w:fill` (B4C6E7 for section bands,
// a plain grey BFBFBF specifically for the "Randomization" group band —
// distinct from CONSORT's own group color, faithful to what's actually
// in this particular source file rather than reused for consistency's
// sake).
#let spirit = (
  name: "SPIRIT 2025",
  full-name: [SPIRIT 2025 checklist of items to address in a randomized trial protocol],
  headers: ("Section / Topic", "No", "SPIRIT 2025 checklist item description", "Reported on page no."),
  style: (
    paper: "us-letter",
    landscape: true,
    columns: (18.6%, 4.4%, 1fr, 9.7%),
    font: "Arial",
    text-size: 10pt,
    header-fill: none,
    header-text-color: black,
    section-fill: rgb("#B4C6E7"),
    group-fill: rgb("#BFBFBF"),
  ),
  citation: [
    We strongly recommend reading this checklist in conjunction with the
    SPIRIT 2025 Explanation and Elaboration and the SPIRIT 2025 Expanded
    Checklist for important clarifications on all the items. We also
    recommend reading relevant SPIRIT extensions. See
    #link("https://www.consort-spirit.org")[www.consort-spirit.org].

    Citation: Chan A-W, Boutron I, Hopewell S, Moher D, Schulz KF, et al.
    SPIRIT 2025 statement: updated guideline for protocols of randomised
    trials. BMJ 2025;389:e081477.
    #link("https://dx.doi.org/10.1136/bmj-2024-081477")[https://dx.doi.org/10.1136/bmj-2024-081477].

    © 2025 Chan A-W et al. This is an Open Access article distributed
    under the terms of the Creative Commons Attribution License
    (#link("https://creativecommons.org/licenses/by/4.0/")[https://creativecommons.org/licenses/by/4.0/]),
    which permits unrestricted use, distribution, and reproduction in any
    medium, provided the original work is properly cited.
  ],
  items: (
    (section: "Administrative information", topic: "Title and structured summary", group: none, id: "1a",
      description: [Title stating the trial design, population, and interventions, with identification as a protocol]),
    (section: "Administrative information", topic: "Title and structured summary", group: none, id: "1b",
      description: [Structured summary of trial design and methods, including items from the World Health Organization Trial Registration Data Set]),
    (section: "Administrative information", topic: "Protocol version", group: none, id: "2",
      description: [Version date and identifier]),
    (section: "Administrative information", topic: "Roles and responsibilities", group: none, id: "3a",
      description: [Names, affiliations, and roles of protocol contributors]),
    (section: "Administrative information", topic: "Roles and responsibilities", group: none, id: "3b",
      description: [Name and contact information for the trial sponsor]),
    (section: "Administrative information", topic: "Roles and responsibilities", group: none, id: "3c",
      description: [Role of trial sponsor and funders in design, conduct, analysis, and reporting of trial; including any authority over these activities]),
    (section: "Administrative information", topic: "Roles and responsibilities", group: none, id: "3d",
      description: [Composition, roles, and responsibilities of the coordinating site, steering committee, endpoint adjudication committee, data management team, and other individuals or groups overseeing the trial, if applicable]),

    (section: "Open science", topic: "Trial registration", group: none, id: "4",
      description: [Name of trial registry, identifying number (with URL), and date of registration. If not yet registered, name of intended registry]),
    (section: "Open science", topic: "Protocol and statistical analysis plan", group: none, id: "5",
      description: [Where the trial protocol and statistical analysis plan can be accessed]),
    (section: "Open science", topic: "Data sharing", group: none, id: "6",
      description: [Where and how the individual de-identified participant data (including data dictionary), statistical code, and any other materials will be accessible]),
    (section: "Open science", topic: "Funding and conflicts of interest", group: none, id: "7a",
      description: [Sources of funding and other support (e.g., supply of drugs)]),
    (section: "Open science", topic: "Funding and conflicts of interest", group: none, id: "7b",
      description: [Financial and other conflicts of interest for principal investigators and steering committee members]),
    (section: "Open science", topic: "Dissemination policy", group: none, id: "8",
      description: [Plans to communicate trial results to participants, healthcare professionals, the public, and other relevant groups (e.g., reporting in trial registry, plain language summary, publication)]),

    (section: "Introduction", topic: "Background and rationale", group: none, id: "9a",
      description: [Scientific background and rationale, including summary of relevant studies (published and unpublished) examining benefits and harms for each intervention]),
    (section: "Introduction", topic: "Background and rationale", group: none, id: "9b",
      description: [Explanation for choice of comparator]),
    (section: "Introduction", topic: "Objectives", group: none, id: "10",
      description: [Specific objectives related to benefits and harms]),

    (section: "Methods: Patient and public involvement, trial design", topic: "Patient and public involvement", group: none, id: "11",
      description: [Details of, or plans for, patient or public involvement in the design, conduct, and reporting of the trial]),
    (section: "Methods: Patient and public involvement, trial design", topic: "Trial design", group: none, id: "12",
      description: [Description of trial design including type of trial (e.g., parallel group, crossover), allocation ratio, and framework (e.g., superiority, equivalence, non-inferiority, exploratory)]),

    (section: "Methods: Participants, interventions, and outcomes", topic: "Trial setting", group: none, id: "13",
      description: [Settings (e.g., community, hospital) and locations (e.g., countries, sites) where the trial will be conducted]),
    (section: "Methods: Participants, interventions, and outcomes", topic: "Eligibility criteria", group: none, id: "14a",
      description: [Eligibility criteria for participants]),
    (section: "Methods: Participants, interventions, and outcomes", topic: "Eligibility criteria", group: none, id: "14b",
      description: [If applicable, eligibility criteria for sites and for individuals who will deliver the interventions (e.g., surgeons, physiotherapists)]),
    (section: "Methods: Participants, interventions, and outcomes", topic: "Intervention and comparator", group: none, id: "15a",
      description: [Intervention and comparator with sufficient details to allow replication including how, when, and by whom they will be administered. If relevant, where additional materials describing the intervention and comparator (e.g., intervention manual) can be accessed]),
    (section: "Methods: Participants, interventions, and outcomes", topic: "Intervention and comparator", group: none, id: "15b",
      description: [Criteria for discontinuing or modifying allocated intervention/comparator for a trial participant (e.g., drug dose change in response to harms, participant request, or improving/worsening disease)]),
    (section: "Methods: Participants, interventions, and outcomes", topic: "Intervention and comparator", group: none, id: "15c",
      description: [Strategies to improve adherence to intervention/comparator protocols, if applicable, and any procedures for monitoring adherence (e.g., drug tablet return, sessions attended)]),
    (section: "Methods: Participants, interventions, and outcomes", topic: "Intervention and comparator", group: none, id: "15d",
      description: [Concomitant care that is permitted or prohibited during the trial]),
    (section: "Methods: Participants, interventions, and outcomes", topic: "Outcomes", group: none, id: "16",
      description: [Primary and secondary outcomes, including the specific measurement variable (e.g., systolic blood pressure), analysis metric (e.g., change from baseline, final value, time to event), method of aggregation (e.g., median, proportion), and time point for each outcome]),
    (section: "Methods: Participants, interventions, and outcomes", topic: "Harms", group: none, id: "17",
      description: [How harms are defined and will be assessed (e.g., systematically, non-systematically)]),
    (section: "Methods: Participants, interventions, and outcomes", topic: "Participant timeline", group: none, id: "18",
      description: [Time schedule of enrollment, interventions (including any run-ins and washouts), assessments, and visits for participants. A schematic diagram is highly recommended (see Figure)]),
    (section: "Methods: Participants, interventions, and outcomes", topic: "Sample size", group: none, id: "19",
      description: [How sample size was determined, including all assumptions supporting the sample size calculation]),
    (section: "Methods: Participants, interventions, and outcomes", topic: "Recruitment", group: none, id: "20",
      description: [Strategies for achieving adequate participant enrollment to reach target sample size]),

    (section: "Methods: Assignment of interventions", topic: "Sequence generation", group: "Randomization", id: "21a",
      description: [Who will generate the random allocation sequence and the method used]),
    (section: "Methods: Assignment of interventions", topic: "Sequence generation", group: "Randomization", id: "21b",
      description: [Type of randomization (simple or restricted) and details of any factors for stratification. To reduce predictability of a random sequence, other details of any planned restriction (e.g., blocking) should be provided in a separate document that is unavailable to those who enroll participants or assign interventions]),
    (section: "Methods: Assignment of interventions", topic: "Allocation concealment mechanism", group: "Randomization", id: "22",
      description: [Mechanism used to implement the random allocation sequence (e.g., central computer/telephone; sequentially numbered, opaque, sealed containers), describing any steps to conceal the sequence until interventions are assigned]),
    (section: "Methods: Assignment of interventions", topic: "Implementation", group: "Randomization", id: "23",
      description: [Whether the personnel who will enroll and those who will assign participants to the interventions will have access to the random allocation sequence]),
    (section: "Methods: Assignment of interventions", topic: "Blinding", group: "Randomization", id: "24a",
      description: [Who will be blinded after assignment to interventions (e.g., participants, care providers, outcome assessors, data analysts)]),
    (section: "Methods: Assignment of interventions", topic: "Blinding", group: "Randomization", id: "24b",
      description: [If blinded, how blinding will be achieved and description of the similarity of interventions]),
    (section: "Methods: Assignment of interventions", topic: "Blinding", group: "Randomization", id: "24c",
      description: [If blinded, circumstances under which unblinding is permissible, and procedure for revealing a participant's allocated intervention during the trial]),

    (section: "Methods: Data collection, management, and analysis", topic: "Data collection methods", group: none, id: "25a",
      description: [Plans for assessment and collection of trial data, including any related processes to promote data quality (e.g., duplicate measurements, training of assessors) and a description of trial instruments (e.g., questionnaires, laboratory tests) along with their reliability and validity, if known. Reference to where data collection forms can be accessed, if not in the protocol]),
    (section: "Methods: Data collection, management, and analysis", topic: "Data collection methods", group: none, id: "25b",
      description: [Plans to promote participant retention and complete follow-up, including list of any outcome data to be collected for participants who discontinue or deviate from intervention protocols]),
    (section: "Methods: Data collection, management, and analysis", topic: "Data management", group: none, id: "26",
      description: [Plans for data entry, coding, security, and storage, including any related processes to promote data quality (e.g., double data entry; range checks for data values). Reference to where details of data management procedures can be accessed, if not in the protocol]),
    (section: "Methods: Data collection, management, and analysis", topic: "Statistical methods", group: none, id: "27a",
      description: [Statistical methods used to compare groups for primary and secondary outcomes, including harms]),
    (section: "Methods: Data collection, management, and analysis", topic: "Statistical methods", group: none, id: "27b",
      description: [Definition of who will be included in each analysis (e.g., all randomized participants), and in which group]),
    (section: "Methods: Data collection, management, and analysis", topic: "Statistical methods", group: none, id: "27c",
      description: [How missing data will be handled in the analysis]),
    (section: "Methods: Data collection, management, and analysis", topic: "Statistical methods", group: none, id: "27d",
      description: [Methods for any additional analyses (e.g., subgroup and sensitivity analyses)]),

    (section: "Methods: Monitoring", topic: "Data monitoring committee", group: none, id: "28a",
      description: [Composition of data monitoring committee (DMC); summary of its role and reporting structure; statement of whether it is independent from the sponsor and funder; conflicts of interest and reference to where further details about its charter can be found, if not in the protocol. Alternatively, an explanation of why a DMC is not needed]),
    (section: "Methods: Monitoring", topic: "Data monitoring committee", group: none, id: "28b",
      description: [Explanation of any interim analyses and stopping guidelines, including who will have access to these interim results and make the final decision to terminate the trial]),
    (section: "Methods: Monitoring", topic: "Trial monitoring", group: none, id: "29",
      description: [Frequency and procedures for monitoring trial conduct. If there is no monitoring, give explanation]),

    (section: "Ethics", topic: "Research ethics approval", group: none, id: "30",
      description: [Plans for seeking research ethics committee/institutional review board approval]),
    (section: "Ethics", topic: "Protocol amendments", group: none, id: "31",
      description: [Plans for communicating important protocol modifications to relevant parties]),
    (section: "Ethics", topic: "Consent or assent", group: none, id: "32a",
      description: [Who will obtain informed consent or assent from potential trial participants or authorized proxies, and how]),
    (section: "Ethics", topic: "Consent or assent", group: none, id: "32b",
      description: [Additional consent provisions for collection and use of participant data and biological specimens in ancillary studies, if applicable]),
    (section: "Ethics", topic: "Confidentiality", group: none, id: "33",
      description: [How personal information about potential and enrolled participants will be collected, shared, and maintained in order to protect confidentiality before, during, and after the trial]),
    (section: "Ethics", topic: "Ancillary and post-trial care", group: none, id: "34",
      description: [Provisions, if any, for ancillary and post-trial care, and for compensation to those who suffer harm from trial participation]),
  ),
)
