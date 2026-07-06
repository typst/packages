#import "@preview/folio:0.0.1": boundaries, folio-init

#show: body => folio-init(
  data: (
    baselines: (
      scope: (in_scope: ("Feature A",), out_of_scope: ("Feature B",)),
    ),
  ),
  body,
)

#boundaries("baselines.scope")

This is a demonstration of the `boundaries` component. It renders completely independently based solely on the data provided to the `folio-init` state container.
