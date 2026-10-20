#let plugin-wasm = plugin("typst_mmdr.wasm")

#let mermaid-svg(
  code,
  base-theme: "modern",
  theme: none,
  layout: none,
) = {
  let svg-bytes = plugin-wasm.render(
    bytes(code),
    bytes(base-theme),
    bytes(
      if theme == none {
        ""
      } else {
        json.encode(theme)
      },
    ),
    bytes(
      if layout == none {
        ""
      } else {
        json.encode(layout)
      },
    ),
  )
  str(svg-bytes)
}

#let mermaid(
  code,
  base-theme: "modern",
  theme: none,
  layout: none,
) = {
  let svg-str = mermaid-svg(
    code,
    base-theme: base-theme,
    theme: theme,
    layout: layout,
  )
  image(bytes(svg-str), format: "svg")
}
