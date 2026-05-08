#import "@preview/folio:0.0.1": compliance, folio-init

#show: body => folio-init(
  data: (
    baselines: (
      compliance: (
        (
          id: "COMP-1",
          regulation: "Demo Reg",
          jurisdiction: "Demo City",
          status: "Compliant",
          req_ids: ("REQ-01",),
        ),
      ),
      requirements: ((id: "REQ-01", description: "Demo Req"),),
    ),
  ),
  body,
)

#compliance("baselines.compliance")

This is a demonstration of the `compliance` component, linking to a requirement.
