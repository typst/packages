#import "new-theorem-template.typ": new-theorem-template
#import "../counters.typ": definition-counter
#import "../colors.typ": color-schema

#let definition = new-theorem-template(
  "Definition",
  fill: color-schema.green.light,
  stroke: color-schema.green.primary,
  theorem-counter: definition-counter,
)

