#import "presentate.typ": slide
#import "animation.typ" as internal: pause, meanwhile, animate, reducer
#import "utils.typ"
#import "store.typ" as store: settings, set-options, default-options, default-frozen-counters, alias-counter
#import "themes/themes.typ"

// Applying context so that it can be called without context.
#let only(..args) = context internal.only(..args)
#let uncover(..args) = context internal.uncover(..args)
#let blink(..args) = context internal.blink(..args)
#let step-transform(..args) = context internal.step-transform(..args)
