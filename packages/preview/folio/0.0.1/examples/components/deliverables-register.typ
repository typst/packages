#import "@preview/folio:0.0.1": deliverables-register, folio-init

#show: body => folio-init(
  data: (
    registers: (
      deliverables_register: (
        (
          id: "D1",
          description: "Demo Deliverable",
          owner: "Team A",
          due_date: "2026-05-01",
          status: "Planned",
          req_ids: ("REQ-01",),
        ),
      ),
    ),
    baselines: (
      requirements: ((id: "REQ-01", description: "Demo Req"),),
    ),
  ),
  body,
)

#deliverables-register("registers.deliverables_register")

This is a demonstration of the `deliverables-register` component, linking to a requirement.
