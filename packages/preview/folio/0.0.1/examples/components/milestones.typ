#import "@preview/folio:0.0.1": folio-init, milestones

#show: body => folio-init(
  data: (
    baselines: (
      schedule: (
        milestones: (
          (
            id: "M1",
            date: "2026-01-01",
            title: "Demo Milestone",
            status: "Done",
          ),
        ),
      ),
    ),
  ),
  body,
)

#milestones("baselines.schedule.milestones")

This is a demonstration of the `milestones` component. It renders completely independently based solely on the data provided to the `folio-init` state container.
