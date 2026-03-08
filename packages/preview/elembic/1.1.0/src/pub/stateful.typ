// Exports rules defaulting to stateful mode.
#import "../element.typ": toggle-stateful-mode as toggle, stateful-set as set_, stateful-apply as apply, stateful-show as show_, stateful-revoke as revoke, stateful-reset as reset, stateful-cond-set as cond-set, stateful-get as get, stateful-settings as settings

// Enable stateful mode.
#let enable = toggle.with(true)

// Disable stateful mode.
#let disable = toggle.with(false)
