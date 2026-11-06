#import "common.typ": kickstart, read-file
#let bibliography-path = kickstart.capture.defaults.bibliography-path
#let render = kickstart.capture.defaults.render
#let extra-effects = kickstart.capture.defaults.extra-effects.with(
  read-file: read-file,
  bibliography-path: bibliography-path,
)
