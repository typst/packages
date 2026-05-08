#import "../../src/lib.typ": communication, folio-init

#show: body => folio-init(
  data: (
    baselines: (
      communication: (
        (
          what: "Demo Report",
          audience: "Stakeholders",
          frequency: "Weekly",
          channel: "Email",
          owner: "PM",
        ),
      ),
    ),
  ),
  body,
)

#communication("baselines.communication")

This is a demonstration of the `communication` component.
