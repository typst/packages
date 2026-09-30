#import "@preview/folio:0.0.1": folio-init, issue-log

#show: body => folio-init(
  data: (
    registers: (
      issue_log: (
        (
          id: "I1",
          description: "API Authentication Failure",
          owner: "Lead Dev",
          status: "In-Progress",
          affects_risk: ("R1",),
          blocks_milestone: ("M1",),
          blocks_deliverable: ("D1",),
        ),
      ),
    ),
  ),
  body,
)

#issue-log("registers.issue_log")

This is a demonstration of the `issue-log` component, showcasing enhanced cross-references to risks, milestones, and deliverables.
