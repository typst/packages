#import "../../src/lib.typ": folio-init, status-report

#show: body => folio-init(
  data: (
    execution: (
      status: (
        health: "Good",
        spend: "50%",
        variance: "0",
        summary: "Demo status summary.",
      ),
    ),
  ),
  body,
)

#status-report("execution.status")

This is a demonstration of the `status-report` component. It renders completely independently based solely on the data provided to the `folio-init` state container.
