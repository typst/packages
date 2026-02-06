// Intends to reduce query times hugely.
// When not calling any cetz functions, only importing and parsing it takes a significant amount of
// time.
// Hence this module wraps cetz and imports it only if cfg.render=true.
// Otherwise it offers do-nothing stubs in place.

#import "../cfg.typ"
#import "../util/mod.typ": *

#let cetz = if cfg.render == "all" {
  versioned((
    "0.12": {
      import "@preview/cetz:0.3.2"
      cetz
    },
    "0.13": {
      import "@preview/cetz:0.3.3"
      cetz
    },
  ))
} else {
  import "stub.typ"
  stub
}
