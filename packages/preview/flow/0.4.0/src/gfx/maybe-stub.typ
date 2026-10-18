// Intends to reduce query times hugely.
// When not calling any cetz functions, only importing and parsing it takes a significant amount of
// time.
// Hence this module wraps cetz and imports it only if cfg.render=true.
// Otherwise it offers do-nothing stubs in place.

#import "../cfg.typ"
#import "../util/small.typ": *

#let cetz = if cfg.render == "all" {
  import "@preview/cetz:0.4.2"
  cetz
} else {
  import "stub.typ"
  stub
}
