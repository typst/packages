#import "../../src/lib.typ": folio-init, stakeholders

#show: body => folio-init(
  data: (
    initiation: (
      stakeholders: (
        (
          id: "SH-1",
          name: "Demo Stakeholder",
          role: "Sponsor",
          organization: "Demo Org",
          interest: "high",
          influence: "high",
        ),
      ),
    ),
  ),
  body,
)

#stakeholders("initiation.stakeholders")

This is a demonstration of the `stakeholders` component.
