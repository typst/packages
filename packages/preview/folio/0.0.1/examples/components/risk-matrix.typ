#import "@preview/folio:0.0.1": folio-init, risk-matrix

#show: body => folio-init(
  data: (
    registers: (
      risk_register: (
        (
          id: "R1",
          description: "Supply chain delays",
          mitigation: "Secondary vendor sourced",
          probability: "High",
          impact: "Medium",
          status: "Monitoring",
          affects_wbs: ("T1", "T2"),
          blocks_milestone: ("M1",),
          source_assumption: "A-1",
        ),
      ),
    ),
    initiation: (
      assumptions_log: ((id: "A-1", description: "Demo Assumption"),),
    ),
  ),
  body,
)

#risk-matrix("registers.risk_register")

This is a demonstration of the `risk-matrix` component, showcasing enhanced cross-references to tasks, milestones, and assumptions.
