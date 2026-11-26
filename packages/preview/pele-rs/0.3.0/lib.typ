// Renders Mermaid diagrams with pele_rs, a Rust port of pele (https://github.com/obsidianmd/pele),
// compiled to a WebAssembly plugin. All 33 Pele 1.12.0 diagram types are supported.
//
// Labels are measured with the widths of Arial, as pele does outside a browser, and drawn in the
// font you choose, so a much wider font can overflow its boxes.

#let _plugin = plugin("pele.wasm")

// The colors and sizes of pele's themes, by the short name of each `--pele-*` variable.
#let _theme-keys = (
  "bg", "fg", "muted", "line", "surface", "surface-alt", "border", "accent", "radius",
  "fg-on-light", "fg-on-dark", "critical", "bold-weight", "title-weight", "heading-weight",
)

#let _css(value) = {
  if type(value) == color { value.to-hex() }
  else if type(value) == length { str(value.to-absolute() / 1pt) + "px" }
  else { str(value) }
}

#let _family(fonts) = {
  let list = if type(fonts) == array { fonts } else { (fonts,) }
  list.map(f => if type(f) == dictionary { f.name } else { f }).map(f => "\"" + f + "\"").join(", ")
}

/// Draws a Mermaid diagram.
///
/// The diagram type is detected from the first line of the source, as in Mermaid. Front matter
/// and `%%{init: ...}%%` directives are honored. Syntax errors stop the compilation with
/// pele's message, which names the line and the expected token.
///
/// The result is an `image`, so it can be placed in a `figure`, scaled, aligned or rotated like
/// any other image.
///
/// - source (str, raw): The Mermaid text, or a raw block holding it. Raw blocks make it easy to
///   render every ```` ```mermaid ```` block with a show rule.
/// - width (auto, relative): Width of the image. By default, the diagram's natural width.
/// - height (auto, relative): Height of the image. By default, the diagram's natural height.
/// - fit (str): How the diagram fills a box given both a `width` and a `height`: `"contain"`,
///   `"cover"` or `"stretch"`, as for `image`.
/// - font (auto, str, array): Font family for labels. By default, the surrounding text's font.
/// - font-size (auto, length): Size of node labels. By default, the surrounding text's size.
/// - mono-font (str, array): Font family for text pele draws in monospace, such as class
///   members and file trees.
/// - monospace (none, array): Which parts are drawn in `mono-font`, from `"members"`,
///   `"attributes"`, `"files"` and `"messages"`. `none` keeps pele's defaults.
/// - now (none, int, float): The current time, as a Unix timestamp in milliseconds. Gantt
///   charts require it, so that their today marker and relative dates are reproducible.
/// - time-zone (str): IANA time zone for Gantt calendar arithmetic, such as
///   `"Europe/Paris"`. Daylight-saving transitions are respected.
/// - icons (dictionary): Icons by decoded name, such as `"fa:fa-star"`, mapped to SVG markup
///   drawn in a 24×24 viewport. Missing icons fall back to pele's default behavior.
/// - math (dictionary): Math by TeX source, mapped to `(svg: str, width: float, height: float)`
///   in pixels. Labels written as `$$...$$` use it; unknown formulas are drawn as text.
/// - padding (length): Room around the drawing.
/// - theme (dictionary): Colors and sizes by the short name of pele's CSS variables, such as
///   `(fg: black, bg: white, accent: blue, surface: luma(240), radius: 4pt)`. Values may be
///   colors, lengths or strings. Keys starting with `--` are passed as raw CSS variables.
/// - background (auto, bool): Whether to paint the theme's `bg` behind the diagram. By default,
///   only when the theme sets `bg`.
/// - config (dictionary): Mermaid configuration, as in front matter's `config:`, such as
///   `(flowchart: (curve: "linear"))` or `(pie: (donutHole: 0.5))`. The source's own front
///   matter and directives take precedence.
/// - alt (none, str): Alternative text for the image, for accessibility.
/// -> content
#let mermaid(
  source,
  width: auto,
  height: auto,
  fit: "contain",
  font: auto,
  font-size: auto,
  mono-font: "DejaVu Sans Mono",
  monospace: none,
  now: none,
  time-zone: "UTC",
  icons: (:),
  math: (:),
  padding: 8pt,
  theme: (:),
  background: auto,
  config: (:),
  alt: none,
) = context {
  let text-source = if type(source) == content and source.func() == raw { source.text } else { source }
  assert(type(text-source) == str, message: "mermaid: expected a string or a raw block")
  let vars = (:)
  for (key, value) in theme {
    let name = if key.starts-with("--") { key } else { "--pele-" + key }
    vars.insert(name, _css(value))
  }
  let options = (
    fontSize: (if font-size == auto { text.size } else { font-size }).to-absolute() / 1pt,
    fontFamily: _family(if font == auto { text.font } else { font }),
    fontFamilyMono: _family(mono-font),
    monospace: monospace,
    now: now,
    timeZone: time-zone,
    icons: icons,
    math: math,
    padding: padding.to-absolute() / 1pt,
    theme: vars,
    background: if background == auto { "--pele-bg" in vars } else { background },
    config: config,
  )
  let svg = _plugin.render(bytes(text-source), bytes(json.encode(options)))
  image(svg, format: "svg", width: width, height: height, fit: fit, alt: alt)
}
