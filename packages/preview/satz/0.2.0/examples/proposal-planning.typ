#import "../lib.typ": research-proposal, proposal-gantt, work-package, proposal-budget
#show: research-proposal.with(
  title: [A reproducible measurement platform], short-title: [Project plan],
  applicants: [Dr. Example Researcher], institution: [Example University],
  summary: [A two-year project connecting calibration, independent validation and an openly documented release.],
)

= Work programme
#work-package(
  title: [Reference protocol], lead: [Example University], period: [Months 1–9],
  objective: [Establish a reproducible calibration procedure.],
  tasks: ([Agree quality criteria.], [Calibrate and test the instruments.]),
  deliverables: ([D1: Versioned protocol and analysis scripts.],),
  milestones: ([M1: Independent calibration passed in month 9.],),
  risk: [If transfer fails, isolate instrument-specific corrections before collecting validation data.],
) <wp:protocol>

#work-package(
  title: [Independent validation], lead: [Partner laboratory], period: [Months 10–24],
  objective: [Test transfer to held-out recordings and publish the methods.],
  tasks: ([Run the independent validation.], [Release the protocol and permitted data.]),
  deliverables: ([D2: Validation report.], [D3: Public release.]),
  milestones: ([M2: Validation complete in month 20.],),
) <wp:validation>

#pagebreak()
= Schedule and resources
The schedule links @wp:protocol and @wp:validation to explicit milestones.
Person-month figures describe planned effort; the budget uses monetary costs.

#figure(
  proposal-gantt((
    (label: [#ref(<wp:protocol>) Reference protocol], kind: "group", spans: ((1, 9),)),
    (label: [Quality criteria], spans: ((1, 3),), resources: ([2], [1])),
    (label: [Calibration], spans: ((3, 9),), resources: ([6], [2])),
    (label: [M1: Calibration passed], kind: "milestone", at: 9),
    (label: [#ref(<wp:validation>) Validation], kind: "group", spans: ((10, 24),)),
    (label: [Independent evaluation], spans: ((10, 15), (17, 20)), resources: ([3], [8])),
    (label: [M2: Validation complete], kind: "milestone", at: 20),
    (label: [Release and outreach], spans: ((21, 24),), resources: ([2], [2])),
  ), periods: 24, size: 9pt, resources: ([PM A], [PM B])),
  caption: [Two-year work programme. Diamonds mark milestones; PM A/B denote person-months at the two institutions.],
) <fig:schedule>

= Requested resources
#proposal-budget((
  (description: [Research associate], unit-cost: 500000, quantity: 12),
  (description: [Travel and collaboration], unit-cost: 125000, quantity: 2),
  (description: [Materials and archiving], unit-cost: 75000),
))
