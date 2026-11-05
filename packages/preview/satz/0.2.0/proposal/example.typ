#import "../lib.typ": research-proposal, proposal-budget

#show: research-proposal.with(
  title: [A Reproducible Measurement Platform],
  short-title: [Measurement platform],
  applicants: [Dr. Example Author and Dr. Example Collaborator],
  institution: [Example University · Research Methods Group],
  date: [20 October 2026],
  summary: [We propose a reusable platform to compare measurement methods.
    The project will deliver documented data, validated software and a practical
    guide for laboratories adopting the method.],
)

= Motivation and research question
Existing measurements are difficult to compare across laboratories. Can a
shared protocol reduce this variation while preserving sensitivity?

= Objectives and expected contribution
+ Establish an openly documented reference protocol.
+ Compare reliability and sensitivity against current practice.
+ Release a reproducible implementation and training materials.

= Approach and work plan
== WP 1: Reference protocol
Specify instruments, calibration, acquisition and quality criteria.

== WP 2: Validation
Compare the reference protocol against existing methods on held-out data.
Define success criteria before collecting the validation measurements.

== WP 3: Software and dissemination
Release tested analysis code, worked examples and a maintenance plan.

= Schedule and milestones
#table(
  columns: (1fr, 1fr, 2fr),
  table.header([*Period*], [*Work package*], [*Milestone*]),
  [Months 1–3], [WP 1], [Protocol and calibration complete],
  [Months 4–9], [WP 2], [Validation and robustness assessment],
  [Months 10–12], [WP 3], [Software and documentation release],
)

#pagebreak()
= Team, resources and feasibility
The applicants cover instrument development, experimental design and software
engineering. The host provides laboratory space and standard equipment.

= Risks and alternatives
If calibration stability is insufficient, shorten acquisition batches and
repeat reference measurements. Report any resulting loss of precision.

= Ethics, data and open research
Address consent, data protection and sharing restrictions before acquisition.
Archive the protocol, code and permitted data with persistent identifiers.

= Budget and justification
The research associate develops the protocol and validation workflow. Travel
supports coordination and dissemination; materials support calibration.

#proposal-budget((
  (description: [Research associate], unit-cost: 500000, quantity: 12),
  (description: [Travel], unit-cost: 125000, quantity: 2),
  (description: [Calibration materials], unit-cost: 75000),
))

= Outputs and evaluation
Deliver the protocol, validation report, software and training materials.
Evaluate success against the pre-specified reliability and sensitivity targets.
