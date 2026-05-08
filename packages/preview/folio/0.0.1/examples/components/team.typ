#import "../../src/lib.typ": folio-init, team

#show: body => folio-init(
  data: (
    governance: (
      team: (
        (role: "Demo Role", name: "Demo Name", email: "demo@example.com"),
      ),
    ),
  ),
  body,
)

#team("governance.team")

This is a demonstration of the `team` component. It renders completely independently based solely on the data provided to the `folio-init` state container.
