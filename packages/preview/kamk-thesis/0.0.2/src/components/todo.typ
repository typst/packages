#import "../core/colors.typ": todo-block-bg, todo-block-stroke

#let todo(body) = block(
  fill: todo-block-bg,
  width: 100%,
  inset: 8pt,
  radius: 2pt,
  stroke: todo-block-stroke,
  [*TODO:* #body],
)
