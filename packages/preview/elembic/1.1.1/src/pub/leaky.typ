// Exports rules defaulting to leaky mode.
#import "../element.typ": leaky-set as set_, leaky-apply as apply, leaky-show as show_, leaky-revoke as revoke, leaky-reset as reset, leaky-cond-set as cond-set, leaky-settings as settings, leaky-toggle as toggle

/// Enable leaky mode by default.
#let enable = toggle.with(true)

/// Disable leaky mode by default.
#let disable = toggle.with(false)
