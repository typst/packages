// Internal annotation façade.
//
// Annotations are declared where a figure is drawn rather than inside the
// situation, because what a reader should be told about a figure is a property
// of that figure and not of the physics.

#import "measures.typ"
#import "notes.typ"
#import "schema.typ"

#let dimension = measures.dimension
#let angle-mark = measures.angle-mark
#let axis = measures.axis
#let callout = notes.callout
#let brace = notes.brace
#let arrow = notes.arrow

#let validate-annotation-list = schema.validate-annotation-list
