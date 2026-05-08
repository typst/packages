#import "../../src/lib.typ": cover, folio-init

#show: body => folio-init(
  data: (
    project: (
      name: "Component Demo",
      description: "Standalone component demonstration",
    ),
  ),
  body,
)

#cover()

This is a demonstration of the `cover` component. It renders completely independently based solely on the data provided to the `folio-init` state container.
