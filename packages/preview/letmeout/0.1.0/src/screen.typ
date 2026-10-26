// What a browser needs beyond the layout: the fonts and text colors, which
// Typst's HTML export drops, colors that follow the reader's light or dark
// mode, and no default margin around the page blocks.
#import "css.typ": color-css, dark-properties, size, num, font-css, weight-css
#import "adapters.typ": adapters, math-marker
#import "scroll.typ": scroll-css, scroll-rules
#import "grid.typ": render-grid
#import "line.typ": html-line
#import "align.typ": html-align
#import "flow.typ": flow-css, flow-attrs, flow-style, fractional-body

// The colors of Typst's default raw theme (typst-library's `RAW_THEME`).
#let raw-palette = ("#16718d", "#198810", "#1d6c76", "#301414", "#4b69c6", "#6b6b6f", "#74747c", "#8b41b1", "#b60157", "#d73948")

// Elements whose content must stay plain text, so they get no spans.
#let raw-text = ("script", "style", "title", "textarea")

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
  if target() != "html" { return it }
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
  let css = ("body { margin: 0; font-family: " + font-css(root.font) + "; font-size: " + size(root.size) + "; font-weight: " + weight-css(root.weight) + "; font-style: " + root.style + "; letter-spacing: " + size(root.tracking) + "; color: " + color-css(root.fill, role: "ink") + "; }",)
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
  css.push("letmeout-frame { display: contents; } letmeout-frame > svg { max-width: 100%; height: auto !important; }")
  // Links keep Typst's styling; an explicit underline inside one still renders.
  css.push("a:any-link { text-decoration: none; }")
  css.push(flow-css)
  // When text-box trimming is unavailable, short measured Typst line boxes
  // cannot safely contain a different browser font's ascenders/descenders.
  css.push("@supports not (text-box-trim: trim-both) { .letmeout-text-block { line-height: normal !important; padding-block-end: 0 !important; } }")
  css.push("letmeout-par { display: flow-root; } letmeout-par > p { margin-block: 0; text-box-trim: trim-both; text-box-edge: cap alphabetic; }")
  css.push("p:has(> [data-fraction]) { display: flex; align-items: baseline; } p:has(> [data-fraction]) > span:not([data-fraction]) { flex: 0 1 auto; min-width: 0; white-space: pre-wrap; }")
  css.push("p .letmeout-box { margin-block: calc(var(--letmeout-leading, 0pt) / 2); }")
  css.push(image-css)
  css.push(scroll-css)
  css.push(options.css)
  html.elem("style", css.filter(rule => rule != "").join("\n"))
}

// Show rules for the document body. `root` holds the font and fill in effect at its start.
#let screen(root, body) = {
  // Equations mark their content with a style the text rule reads, so it never wraps MathML text.
  // A state would cost more layout passes. A local identity show rule alone would
  // still allow the outer text transformation to run.
  show text: it => context {
    if target() != "html" or math.equation.supplement == math-marker { return it }
    let styles = ()
    if text.font != root.font { styles.push("font-family: " + font-css(text.font)) }
    if text.size != root.size { styles.push("font-size: " + size(text.size)) }
    if text.weight != root.weight { styles.push("font-weight: " + weight-css(text.weight)) }
    if text.style != root.style { styles.push("font-style: " + text.style) }
    if text.tracking != root.tracking { styles.push("letter-spacing: " + size(text.tracking)) }
    if type(text.fill) == color and text.fill != root.fill { styles.push("color: " + color-css(text.fill, role: "ink")) }
    if styles.len() == 0 { it } else { html.span(style: styles.join("; "), it) }
  }
  // Typst leading is extra space between lines, including lines of tall boxes.
  // A CSS line-height alone only grows the paragraph strut, so inline boxes
  // also share that leading through their block margins.
  show par: it => context {
    if target() != "html" or math.equation.supplement == math-marker { return it }
    let line-height = (measure([Hg]).height + it.leading.to-absolute()) / text.size
    let fractional = fractional-body(it.body)
    html.elem("letmeout-par", attrs: flow-attrs() + (style: flow-style(above: it.spacing, below: it.spacing)
      + "; font-family: " + font-css(text.font) + "; font-size: " + size(text.size)
      + "; font-weight: " + weight-css(text.weight) + "; font-style: " + text.style
      + "; --letmeout-leading: " + size(it.leading.to-absolute())
      + "; --letmeout-par-spacing: " + size(it.spacing.to-absolute())
      + "; line-height: " + num(line-height)), if fractional == none { it } else { html.elem("p", fractional) })
  }
  // The HTML exporter builds MathML from native text. HTML spans inside it
  // change token types and break scripts, operators, cases, and matrices.
  // Set inside the rule, so the equation keeps its own supplement for references.
  show math.equation: it => { set math.equation(supplement: math-marker); it }
  show selector.or(..raw-text.map(tag => html.elem.where(tag: tag))): set text(font: root.font, fill: root.fill, size: root.size, weight: root.weight, style: root.style, tracking: root.tracking)
  // A custom element keeps frames inline or block, wherever Typst put them.
  // Native SVG dimensions use em relative to this Typst font size, even when
  // the frame contains no text that could otherwise carry that size to HTML.
  show html.frame: it => context html.elem("letmeout-frame", attrs: (style: "font-size: " + size(text.size)), it)
  show image: image-rule
  // Native elements keep their set/show APIs and associated definitions.
  show std.grid: it => context {
    if target() != "html" or math.equation.supplement == math-marker { return it }
    render-grid(it)
  }
  show std.line: it => context {
    if target() != "html" or math.equation.supplement == math-marker { it } else { html-line(it) }
  }
  show std.align: it => context {
    if target() != "html" or math.equation.supplement == math-marker { it }
    else { html-align(it, outer: std.align.alignment) }
  }
  // Layout elements and shapes that Typst's HTML export ignores.
  show: adapters
  show: scroll-rules
  body
}
