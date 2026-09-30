#import "@preview/folio:0.0.1": business-case, folio-init

#show: body => folio-init(
  data: (
    initiation: (
      business_case: "This is a standalone business case component demonstration.",
    ),
  ),
  body,
)

#business-case("initiation.business_case")

This is a demonstration of the `business_case` component. It renders completely independently based solely on the data provided to the `folio-init` state container.
