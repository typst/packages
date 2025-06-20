// TODO
// ================================================================
#let todo = align(center, box(
  width: 90%,
  height: 30pt,
  fill: red,
  radius: 10pt,
)[#align(center + horizon,"TODO!")])

#let todo-text(body) = {
  let text = box(
    width: 90%,
    height: 30pt,
    fill: red,
    radius: 10pt,
  )[#body]
  
  align(center + horizon, text)
}

#let todo-template = align(center, box(
  width: 90%,
  height: 30pt,
  fill: red,
  radius: 10pt,
)[#align(center + horizon,"Template Todo!")])

