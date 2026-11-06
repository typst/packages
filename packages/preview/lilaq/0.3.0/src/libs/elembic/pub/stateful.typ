// Exports rules defaulting to stateful mode.
#import "../element.typ": toggle-stateful-mode as toggle, stateful-set as set_, stateful-apply as apply, stateful-revoke as revoke, stateful-reset as reset

// Enable stateful mode.
#let enable = toggle.with(true)

// Disable stateful mode.
#let disable = toggle.with(false)
