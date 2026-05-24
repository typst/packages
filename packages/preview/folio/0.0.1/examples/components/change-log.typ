#import "@preview/folio:0.0.1": change-log, folio-init

#show: body => folio-init(
  data: (
    registers: (
      change_log: (
        (
          id: "C1",
          description: "Add weather sensors",
          status: "Approved",
          type: "scope",
          affects_baseline: "baselines.scope",
        ),
      ),
    ),
  ),
  body,
)

#change-log("registers.change_log")

This is a demonstration of the `change-log` component, showcasing enhanced metadata for change type and affected baseline.
