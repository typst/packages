// Utility helpers for the blockst manual.
// Pattern adapted from zap/docs/template/utils.typ

#import "@preview/manifesto:0.2.0": template as _manifesto

#let template(body) = {
  _manifesto(
    body,
    toml: toml("../../typst.toml"),
  )
}

// A styled info box
#let info(title: "Info", body) = {
  let children = [*#title* \ #body]
  html.elem("div", attrs: (style: "background-color:#e8f4fd;border:1px solid blue;border-radius:4px;padding:10px;margin:.8em 0;"), children)
}

// A styled warning box
#let warning(title: "Warning", body) = {
  let children = [*#title* \ #body]
  html.elem("div", attrs: (style: "background-color:#fff3e0;border:1px solid orange;border-radius:4px;padding:10px;margin:.8em 0;"), children)
}

// Embed a formatted code example with its rendered output side by side.
#let example(typst-code, rendered, caption: none) = {
  grid(
    columns: (1fr, 1fr),
    gutter: 8mm,
    align(left)[```typst
#typst-code
```],
    align(right)[#rendered],
  )
  if caption != none {
    align(center, text(fill: gray, size: 0.8em, caption))
  }
  v(4mm)
}

// Render a Scratch code block with its preview.
#let scratch-example(scratch-code, caption: none) = {
  let rendered = context scratch(scratch-code)
  example(scratch-code, rendered, caption: caption)
}
