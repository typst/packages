// Internal placement façade.
//
// Reference resolution, element placement, and placed-scene assembly have
// distinct owners while callers retain one stable geometry boundary.

#import "quantities.typ" as quantities
#import "anchors.typ" as anchors
#import "situation.typ" as situation

#let gravity-quantity = quantities.gravity-quantity
#let mass-symbol = quantities.mass-symbol
#let angle-symbol = quantities.angle-symbol

#let body-corners = anchors.body-corners
#let resolve-attachment-point = anchors.resolve-attachment-point

#let resolve-situation-geometry = situation.resolve-situation-geometry
