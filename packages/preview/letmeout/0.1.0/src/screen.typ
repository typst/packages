// What a browser needs beyond the layout: the fonts and text colors, which
// Typst's HTML export drops, colors that follow the reader's light or dark
// mode, and no default margin around the page blocks.
#import "css.typ": color-css, dark-properties
#import "adapters.typ": adapters

// The colors of Typst's default raw theme (typst-library's `RAW_THEME`).
#let raw-palette = ("#16718d", "#198810", "#1d6c76", "#301414", "#4b69c6", "#6b6b6f", "#74747c", "#8b41b1", "#b60157", "#d73948")

// Elements whose content must stay plain text, so they get no spans.
#let raw-text = ("script", "style", "title", "textarea")

#let font-css(fonts) = {
  let fonts = if type(fonts) == array { fonts } else { (fonts,) }
  fonts.map(f => {
    let name = if type(f) == dictionary { f.name } else { f }
    "\"" + name.replace("\\", "\\\\").replace("\"", "\\\"") + "\""
  }).join(", ")
}

// Typst writes the pixel size as `width`/`height` attributes on `<img>`, which
// browsers treat as a CSS size. So a side the document left `auto` would keep
// its pixel size instead of following the aspect ratio, as it does in PDF.
#let image-css = (
  "letmeout-image { display: contents; } "
  // Neither side set: natural size, scaled down to fit like in PDF.
  + "letmeout-image[data-size=\"auto\"] > img { max-width: 100%; height: auto; } "
  + "letmeout-image[data-size=\"width\"] > img { height: auto; } "
  // A fixed height that is too wide for the screen shrinks inside its box.
  + "letmeout-image[data-size=\"height\"] > img { width: auto; max-width: 100%; object-fit: contain; } "
  + "letmeout-image[data-fit=\"cover\"] > img { object-fit: cover; } "
  + "letmeout-image[data-fit=\"contain\"] > img { object-fit: contain; } "
  + "letmeout-image[data-fit=\"stretch\"] > img { object-fit: fill; }"
)

// Records which sides the image sets and, when both are, how it fits them.
#let image-rule(it) = {
  let size = if it.width == auto and it.height == auto { "auto" } else if it.height == auto { "width" } else if it.width == auto { "height" } else { "both" }
  let attrs = (data-size: size)
  if size == "both" { attrs.insert("data-fit", it.fit) }
  html.elem("letmeout-image", attrs: attrs, it)
}

// Rules for dark mode: in a media query while both schemes are allowed, always
// for a dark-only page, never for a light one.
#let dark-rules(scheme, rules) = {
  if scheme == none or not scheme.contains("dark") { return "" }
  if scheme.contains("light") { "@media (prefers-color-scheme: dark) { " + rules + " }" } else { rules }
}

// The document's font and text color go on the body; only text that differs gets a span.
#let screen-style(root, options) = {
  let scheme = options.color-scheme
  let css = ("body { margin: 0; font-family: " + font-css(root.font) + "; color: " + color-css(root.fill, role: "ink") + "; }",)
  if scheme != none { css.push(":root { color-scheme: " + scheme + "; background: Canvas; }") }
  let overrides = dark-properties(options.dark-colors)
  if overrides.len() > 0 { css.push(":root { " + overrides.join("; ") + "; }") }
  let frame-filter = if options.dark-frames == "invert" { "invert(1) hue-rotate(180deg)" } else { "none" }
  css.push(":root { --letmeout-dark-frame-filter: " + frame-filter + "; }")
  css.push(dark-rules(scheme,
    // The filter inherits through themes, so the nearest frame policy wins.
    "letmeout-frame > svg { filter: var(--letmeout-dark-frame-filter); } "
    + "letmeout-light { display: none !important; } letmeout-dark { display: contents !important; }"))
  if scheme != none and scheme.contains("dark") {
    // Typst highlights raw text with inline colors from its default theme; these follow the scheme too.
    css += raw-palette.map(c => "code [style=\"color: " + c + "\"] { color: " + color-css(rgb(c), role: "ink") + " !important; }")
  }
  css.push("letmeout-frame { display: contents; }")
  css.push(image-css)
  css.push(options.css)
  html.elem("style", css.filter(rule => rule != "").join("\n"))
}

#let math-marker = [#metadata(none)<letmeout-math>]

// Show rules for the document body. `root` holds the font and fill in effect at its start.
#let screen(root, body) = {
  // Equations mark their content with a style the text rule reads, so it never wraps MathML text.
  // A state would cost more layout passes. A local identity show rule alone would
  // still allow the outer text transformation to run.
  show text: it => context {
    if math.equation.supplement == math-marker { return it }
    let styles = ()
    if text.font != root.font { styles.push("font-family: " + font-css(text.font)) }
    if type(text.fill) == color and text.fill != root.fill { styles.push("color: " + color-css(text.fill, role: "ink")) }
    if styles.len() == 0 { it } else { html.span(style: styles.join("; "), it) }
  }
  // The HTML exporter builds MathML from native text. HTML spans inside it
  // change token types and break scripts, operators, cases, and matrices.
  // Set inside the rule, so the equation keeps its own supplement for references.
  show math.equation: it => { set math.equation(supplement: math-marker); it }
  show selector.or(..raw-text.map(tag => html.elem.where(tag: tag))): set text(font: root.font, fill: root.fill)
  // A custom element keeps frames inline or block, wherever Typst put them.
  show html.frame: it => html.elem("letmeout-frame", it)
  show image: image-rule
  // Layout elements and shapes that Typst's HTML export ignores.
  show: adapters
  body
}
