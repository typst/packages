#let default-colors = (
  text: rgb("#111827"),
  line-no: rgb("#6b7280"),
  border: rgb("#cfd7e3"),
  header: rgb("#e8edf5"),
  equal: white,
  delete: rgb("#ffe3e6"),
  insert: rgb("#dcf7e4"),
  replace: rgb("#fff1bf"),
  inline-delete: rgb("#ff9aa5"),
  inline-insert: rgb("#83dea1"),
  inline-equal: none,
  delete-text: rgb("#7f1d1d"),
  insert-text: rgb("#14532d"),
  replace-text: rgb("#713f12"),
  marker: rgb("#2563eb"),
  collapsed: rgb("#f7f8fb"),
)

#let minimal-colors = (
  text: black,
  line-no: luma(45%),
  border: black,
  header: white,
  equal: white,
  delete: luma(98%),
  insert: luma(99%),
  replace: luma(97%),
  inline-delete: rgb("#f2b6bf"),
  inline-insert: rgb("#a8d5b3"),
  inline-equal: none,
  delete-text: black,
  insert-text: black,
  replace-text: black,
  marker: rgb("#2563eb"),
  collapsed: white,
)

#let default-table-style = (
  columns: (2.4em, 1fr, 2.4em, 1fr),
  rules: "default",
  stroke-width: (
    header: 0.8pt,
    body: 0.45pt,
  ),
)

#let minimal-table-style = default-table-style + (
  rules: "minimal",
  stroke-width: 0.6pt,
)
