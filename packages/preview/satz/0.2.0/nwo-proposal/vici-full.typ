#import "../lib.typ": nwo-proposal, nwo-text, nwo-page-budget, proposal-budget

#show: nwo-proposal.with(
  scheme: "vici", stage: "full", year: 2026,
  domain: sys.inputs.at("domain", default: "science"),
)

= General information
== Title of research proposal
Reliable measurements across laboratories

#context if state("satz-nwo-profile").get().domain != "zonmw" [
== Scientific summary of research proposal
#nwo-text("scientific-summary", "This project will develop a reference protocol for measurements across laboratories. Controlled calibration and independent validation will establish reproducibility and sensitivity. The project will deliver a documented procedure, tested analysis software and an account of the method's limitations.")

== Public summary of research proposal
*Title in Dutch:* Betrouwbare metingen tussen laboratoria

#nwo-text("public-summary-nl", "Metingen kunnen tussen laboratoria verschillen, ook wanneer hetzelfde materiaal wordt onderzocht. De onderzoekers ontwikkelen daarom een gezamenlijk meetprotocol. Zij testen dit protocol met referentiemonsters en onafhankelijke gegevens. Zo wordt duidelijk welke verschillen door het materiaal ontstaan en welke door de meetapparatuur. De resultaten helpen laboratoria hun metingen beter te vergelijken en worden samen met de analysemethoden gedeeld.")

*Title in English:* Reliable measurements across laboratories

#nwo-text("public-summary-en", "Measurements can differ between laboratories even when the same material is examined. The researchers will therefore develop a shared measurement protocol. They will test it with reference samples and independent data. This will reveal which differences arise from the material and which arise from the instruments. The results and analysis methods will help laboratories compare their measurements more reliably.")

]

== Prospective host institution
Host institution: [Enter institution]

Research group: [Enter group / department]

= Research proposal
#nwo-page-budget("research", max-pages: 14)[
  == Research description
  === Overall aim and key objective
  Establish how reliably a shared protocol identifies known changes under
  realistic measurement conditions. Specify the central question, novelty and
  expected scientific contribution in the completed proposal.

  === Research plan
  The project will develop a reference protocol, compare measurement conditions
  across sites and validate performance using independent recordings.
  [Expand with hypotheses, methods, feasibility, risks, work packages and timeline.]

  #nwo-page-budget("fit", max-pages: 1)[
    === Alignment between research proposal and expertise of the applicant
    [Explain the alignment using the applicant's relevant expertise.]

    === Motivation for the choice of host institution
    [Explain the facilities, intellectual setting and embedding.]
  ]
]

#nwo-page-budget("impact", max-pages: 2.5)[
  == Scientific and/or societal impact
  [Choose and motivate the emphasis required by the form. Describe the
  contribution, relevant partners and how the project will enable impact.]
]

= Literature references
[List works cited in the proposal; bibliographic text may use 9pt. Use native
bibliography or the optional proposal-citations workflow.]

#context {
  let domain = state("satz-nwo-profile").get().domain
  heading(level: 1, if domain == "zonmw" [Additional (applications for) funding for overlapping project(s)] else [Budget])
  if domain != "zonmw" [
// This table illustrates the narrative; it does not replace the official XLSX.
#proposal-budget((
  (description: [Research staff], unit-cost: 500000, quantity: 48),
  (description: [Materials], unit-cost: 1000000),
))
Project duration: [Enter months; at most 60.]

Total NWO funding / own contribution / co-funding: [Complete all requested totals.]

Budget clarification: [Explain choices within 150 words.]

#context if state("satz-nwo-profile").get().domain == "aes" [
  *Interest/benefits for stakeholders*

  [List at least four stakeholders, including at least two non-academic users.
  State each user's type, interest and benefits within 70 words per user.]
]


  ]
}

*Additional (applications for) funding for overlapping project(s)*

[Answer the question and explain within 100 words if applicable.]

= Data management plan
== Will this project involve re-using existing research data?
[Answer and explain constraints, or why reuse was discarded.]

== Will data be collected or generated that are suitable for reuse?
[Answer and explain if not.]

== How will the data be stored for the long-term and made available?
[Describe preservation, access, restrictions and any embargo.]

== Will there be costs related to data management and sharing/preservation?
[Describe financial and time costs.]

= Personal information/signature
*Ethical aspects*

[Specify whether medical, animal-experiment, population-screening or other
ethics approvals are required and their current status.]

[Complete the official exceeding-funding, co-funding, contact-details,
responsible-AI and scientific-conduct declarations.]

Title(s), initial(s), surname(s): [Enter details]

Place and date: [Enter details]
