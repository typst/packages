#import "@preview/folio:0.0.1": acceptance, folio-init

#show: body => folio-init(
  data: (
    closure: (
      acceptance: (
        (
          deliverable_id: "D1",
          accepted_by: "QA",
          acceptance_date: "2026-05-01",
          outstanding_issues: "None",
        ),
      ),
    ),
    registers: (
      deliverables_register: ((id: "D1", description: "Demo Deliverable"),),
    ),
  ),
  body,
)

#acceptance("closure.acceptance")

This is a demonstration of the `acceptance` component, linking to a deliverable.
