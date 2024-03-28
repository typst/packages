#import "./new-theorem-template.typ": new-theorem-template
#import "../colors.typ": color-schema

#let theorem = new-theorem-template(
  "Theorem",
  fill: color-schema.orange.light,
  stroke: color-schema.orange.primary,
)
