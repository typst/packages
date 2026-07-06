#import "@preview/folio:0.0.1": assumptions-log, folio-init

#show: body => folio-init(
  data: (
    initiation: (
      assumptions_log: (
        (
          id: "A-1",
          description: "Demo Assumption",
          type: "assumption",
          status: "Open",
          risk_id: "R1",
        ),
      ),
    ),
    registers: (
      risk_register: ((id: "R1", description: "Linked Risk"),),
    ),
  ),
  body,
)

#assumptions-log("initiation.assumptions_log")

This is a demonstration of the `assumptions-log` component, including a link to a risk.
