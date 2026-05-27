#import "@preview/folio:0.0.1": folio-init, sign-off

#show: body => folio-init(
  data: (
    closure: (sign-off: ((name: "Demo Signer", role: "Demo Role"),)),
  ),
  body,
)

#sign-off("closure.sign_off")

This is a demonstration of the `sign-off` component. It renders completely independently based solely on the data provided to the `folio-init` state container.
