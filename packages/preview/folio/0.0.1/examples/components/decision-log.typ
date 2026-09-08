#import "@preview/folio:0.0.1": decision-log, folio-init

#show: body => folio-init(
  data: (
    registers: (
      decision_log: (
        (
          id: "DEC-1",
          description: "Demo Decision",
          date: "2026-04-01",
          decision_maker: "PM",
          rationale: "Demo Rationale",
          prompted_by_risk: "R1",
        ),
      ),
      risk_register: ((id: "R1", description: "Linked Risk"),),
    ),
  ),
  body,
)

#decision-log("registers.decision_log")

This is a demonstration of the `decision-log` component, linking to a risk.
