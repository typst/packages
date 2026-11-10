#let p = plugin("typst_oxdraw.wasm")

/// Render Mermaid diagram into SVG image.
///
/// This is based on #link("https://github.com/RohanAdwankar/oxdraw")[oxdraw] library.
///
/// - definition (str|content): The definition of Mermaid diagram, both string and raw content are allowed.
/// - background (str|color): The background color of the diagram. Supports hex string (#"#ffffff") or color (```typst #rgb(255, 255, 255)```).
/// - overrides (none|str|dict): Optional style overrides. Supports string in JSON format or dictionary.
///
/// #example(````example
/// #oxdraw("graph TD\n    A --> B")
///
/// #oxdraw(```
/// graph LR
///     User --> System
///     System --> Database
/// ```, background: "#f0f8ff")
///
/// #oxdraw("graph TD\n    A --> B", background: white, overrides: (
///   node_styles: (A: (fill: "#ff6b6b"))
/// ))
/// ````)
///
/// -> content
#let oxdraw(definition, background: none, overrides: none) = {
  assert(
    type(definition) == str or (type(definition) == content and definition.func() == raw),
    message: "definition must be a string or raw content containing Mermaid diagram syntax",
  )

  assert(
    type(overrides) == type(none) or type(background) == str or type(background) == color,
    message: "background must be a string (hex color like '#ffffff') or a color value",
  )

  assert(
    type(overrides) == type(none) or type(overrides) != str or type(overrides) == dictionary,
    message: "overrides must be a JSON string or a dictionary containing layout configuration",
  )

  image(p.render_svg(
    bytes(if (type(definition) == content) { definition.text } else { definition }),
    bytes(if background == none {
      ""
    } else if (type(background) == str) { background } else { background.to-hex() }),
    bytes(
      if overrides == none {
        ""
      } else if type(overrides) == str {
        overrides
      } else {
        json.encode(overrides)
      },
    ),
  ))
}
