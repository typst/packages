#import "@preview/folio:0.0.1": folio-init, pitch

#show: body => folio-init(
  data: (
    initiation: (pitch: "This is a standalone pitch component demonstration."),
  ),
  body,
)

#pitch("initiation.pitch")

This is a demonstration of the `pitch` component. It renders completely independently based solely on the data provided to the `folio-init` state container.
