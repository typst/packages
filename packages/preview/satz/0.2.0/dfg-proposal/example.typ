// DFG 53.01 — 09/26. Replace every placeholder before submission.
// Keep the prescribed headings; consult the official form for instructions.
#import "../lib.typ": dfg-proposal, dfg-supplement, dfg-publications, proposal-budget

#show: dfg-proposal.with(
  applicant: [Example Applicant, Example University, Example City],
  project: [Example Research Project],
  language: "english",
)

= Starting Point

[Text]

*State of the art and preliminary work*

[Text]

= Objectives and work programme

[Text]

== Anticipated total duration of the project

[Text]

== Objectives

[Text]

== Work programme incl. proposed research methods

[Text]

== Handling of research data

[Text]

== Relevance of sex, gender and/or diversity in the research project

[Text]

= Project- and subject-related list of publications

// Cite publications in sections 1–2, then uncomment:
// #dfg-publications("lit.bib", size: 9pt)
[Literature / Literatur]

#dfg-supplement()

= Supplementary information on the research context

[Text]

== Ethical and/or legal aspects of the project

[Text]

=== General ethical aspects and obligations

[Text]

=== Descriptions of proposed investigations involving experiments on animals

[Text]

=== Descriptions of projects involving genetic resources (or associated traditional knowledge) from a foreign country

[Text]

=== Explanations regarding any possible safety-related aspects

[Text]

==== “Dual Use Research of Concern”; foreign trade law

[Text]

==== Risks in international cooperation

[Text]

=== Considerations on aspects of ecological sustainability in the planning and implementation of the project

[Text]

== Employment status information

[Text]

== First-time proposal data

[Text]

== Composition of the project group

[Text]

== Researchers in Germany with whom you have agreed to cooperate on this project

[Text]

== Researchers abroad with whom you have agreed to cooperate on this project

[Text]

== Researchers with whom you have collaborated scientifically within the past three years

[Text]

== Project-relevant cooperation with commercial enterprises

[Text]

== Project-relevant participation in commercial enterprises

[Text]

== Scientific equipment

[Text]

== Other submissions

[Text]

== Other information

[Text]

= Requested modules

[Text]

== Basic Module

[Text]

=== Funding for Staff

#proposal-budget((
  (description: [Research associate, 12 months], unit-cost: 500000, quantity: 12),
  (description: [Student assistant, 6 months], unit-cost: 45000, quantity: 6),
), language: "english")

=== Direct Project Costs

[Text]

==== Equipment up to €10,000, Software and Consumables

[Text]

==== Travel

[Text]

==== Visiting Researchers (excluding Mercator Fellows)

[Text]

==== Expenses for Laboratory Animals

[Text]

==== Other Costs

[Text]

==== Project-related Publication Expenses

[Text]

=== Instrumentation

[Text]

==== Equipment Exceeding €10,000

[Text]

==== Major Instrumentation Exceeding €50,000

[Text]

== Module Temporary Position for Principal Investigator

[Text]

== Module Replacements

[Text]

== Module Temporary Substitutes for Clinicians

[Text]

== Module Mercator Fellows

[Text]

== Module Project-Specific Workshops

[Text]

== Module Science Communication

[Text]

== Module Standard Allowance for Equity and Diversity

[Text]
