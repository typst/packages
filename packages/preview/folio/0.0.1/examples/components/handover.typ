#import "@preview/folio:0.0.1": folio-init, handover

#show: body => folio-init(
  data: (
    closure: (
      handover: (
        documentation: ("User Manual", "API Reference"),
        training: "3 sessions provided",
        support: "24/7 helpdesk",
        transfer_date: "2026-06-01",
      ),
    ),
  ),
  body,
)

#handover("closure.handover")

This is a demonstration of the `handover` component.
