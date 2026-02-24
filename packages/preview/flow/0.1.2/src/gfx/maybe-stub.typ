// Intends to reduce query times hugely.
// When not calling any cetz functions, only importing and parsing it takes a significant amount of
// time.
// Hence this module wraps cetz and imports it only if cfg.render=true.
// Otherwise it offers do-nothing stubs in place.

#import "../cfg.typ"

#let cetz = if cfg.render {
  import "@preview/cetz:0.3.1"
  cetz
} else {
  import "stub.typ"
  stub
}
