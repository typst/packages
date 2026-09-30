#import "@preview/folio:0.0.1": folio-init, quality

#show: body => folio-init(
  data: (
    baselines: (
      quality: (
        standards: ("ISO 9001",),
        acceptance_procedure: "Demo Procedure",
        criteria: (
          (req_id: "REQ-01", criterion: "Demo Criterion", method: "Test"),
        ),
      ),
      requirements: ((id: "REQ-01", description: "Demo Req"),),
    ),
  ),
  body,
)

#quality("baselines.quality")

This is a demonstration of the `quality` component, linking to a requirement.
