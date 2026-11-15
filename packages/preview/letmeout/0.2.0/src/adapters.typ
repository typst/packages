// Show rules that bring native elements to HTML under `#show: letmeout`.
// Each adapter returns `none` for what it cannot express, and the element
// then keeps Typst's native HTML output. Inside `html.frame`, and in paged
// output, every element stays native.
#import "css.typ": num, size, paint
#import "shapes.typ": shape-rule, container-rule, paintable, corners
#import "layout.typ": h-rule, v-rule, pad-rule, hide-rule, move-rule, rotate-rule, skew-rule, scale-rule, stack-rule, columns-rule, colbreak-rule, place-rule, frame-rule

#import "math-marker.typ": math-marker

// Inside an equation, every element stays native: HTML elements are not valid MathML.
#let adapt(render) = it => context {
  if target() != "html" or math.equation.supplement == math-marker { return it }
  let out = render(it)
  if out == none { it } else { out }
}

// A custom stroke or offset on underline, overline, and strike becomes CSS text decoration.
#let decoration-rule(line) = it => {
  if it.stroke == auto and it.offset == auto { return none }
  let styles = ("text-decoration-line: " + line,)
  if it.stroke != auto and it.stroke != none {
    let s = stroke(it.stroke)
    if s.paint != auto {
      if type(s.paint) != color { return none }
      styles.push("text-decoration-color: " + paint(s.paint, role: "ink"))
    }
    if s.thickness != auto { styles.push("text-decoration-thickness: " + size(s.thickness.to-absolute())) }
    if s.dash != auto and s.dash != none {
      styles.push("text-decoration-style: " + if s.dash.array.at(0) in ("dot", 0pt) { "dotted" } else { "dashed" })
    }
  }
  if it.offset != auto and line == "underline" { styles.push("text-underline-offset: " + size(it.offset)) }
  html.span(style: styles.join("; "), it.body)
}

// The highlight's own fill, which follows the color scheme, instead of the browser's yellow.
#let highlight-rule(it) = {
  if it.fill == none or not paintable(it.fill) { return none }
  let styles = ("background: " + paint(it.fill), "color: inherit", "box-decoration-break: clone", "-webkit-box-decoration-break: clone")
  // Only lengths: a ratio would need the highlight's own height.
  let radii = corners(it.radius).values().map(v => if type(v) == relative { v.length } else if type(v) == length { v } else { 0pt })
  if radii.any(v => v != 0pt) { styles.push("border-radius: " + radii.map(size).join(" ")) }
  if it.extent != 0pt { styles.push("padding-inline: " + size(it.extent)) }
  html.elem("mark", attrs: (style: styles.join("; ")), it.body)
}

#let adapters(body) = {
  show std.rect: adapt(shape-rule("rect"))
  show std.square: adapt(shape-rule("square"))
  show std.circle: adapt(shape-rule("circle"))
  show std.ellipse: adapt(shape-rule("ellipse"))
  show std.box: adapt(container-rule("box"))
  show std.block: adapt(container-rule("block"))
  show std.polygon: adapt(frame-rule)
  show std.curve: adapt(frame-rule)
  // A layout callback requires Typst's paged layout engine. Preserve arbitrary
  // third-party drawings in an SVG rather than letting HTML drop the callback.
  show std.layout(_ => []).func(): adapt(frame-rule)
  show std.h: adapt(h-rule)
  show std.v: adapt(v-rule)
  show std.pad: adapt(pad-rule)
  show std.hide: adapt(hide-rule)
  show std.move: adapt(move-rule)
  show std.rotate: adapt(rotate-rule)
  show std.skew: adapt(skew-rule)
  show std.scale: adapt(scale-rule)
  show std.stack: adapt(stack-rule)
  show std.columns: adapt(columns-rule)
  show std.colbreak: adapt(colbreak-rule)
  show std.place: adapt(place-rule)
  show std.underline: adapt(decoration-rule("underline"))
  show std.overline: adapt(decoration-rule("overline"))
  show std.strike: adapt(decoration-rule("line-through"))
  show std.highlight: adapt(highlight-rule)
  body
}
