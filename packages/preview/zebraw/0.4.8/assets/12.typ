#{
// render_code
context grid(
  columns: 2,
  align: center,
  row-gutter: .5em,
  column-gutter: .5em,
  grid.header([`copyable: false`], [`copyable: true`]),
  image("assets/copyable-false.png"), image("assets/copyable-true.png"),
)
}