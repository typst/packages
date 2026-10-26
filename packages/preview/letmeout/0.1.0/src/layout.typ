// Layout elements that Typst's HTML export ignores: spacing, padding, hiding,
// transforms, stacks, columns, placement, and vector shapes. Each rule returns
// `none` for what CSS cannot express; the caller then keeps Typst's native output.
#import "css.typ": num, size, sides, direction
#import "align.typ": html-align
#import "shapes.typ": text-block, trim-text-block

#let div(class, styles, body, hidden: false, attrs: (:)) = {
  attrs += (class: class, style: styles.join("; "))
  if hidden { attrs.insert("aria-hidden", "true") }
  html.elem("div", attrs: attrs, body)
}

// Typst's `h(1fr)` and `v(1fr)` share free space, which normal flow does not have.
#let h-rule(it) = {
  if type(it.amount) == fraction { return none }
  html.elem("span", attrs: (class: "letmeout-h", "aria-hidden": "true",
    style: "margin-inline-start: " + size(it.amount)))
}

// A weak space is a collapsing margin, as weak spacing collapses in Typst.
#let v-rule(it) = {
  if type(it.amount) == fraction { return none }
  let negative = type(it.amount) == length and it.amount.to-absolute() < 0pt
  let property = if it.weak or negative { "margin-top: " } else { "height: " }
  div("letmeout-v", (property + size(it.amount),), [], hidden: true, attrs: (data-weak: repr(it.weak)))
}

// Block content needs a `div`; a `span` around it would break the paragraph structure.
#let block-elements = (parbreak, block, par, heading, list, enum, terms, list.item, enum.item, terms.item,
  std.grid, table, figure, std.align, pad, stack, columns, colbreak, place, rect, square, circle, ellipse,
  std.line, polygon, curve, v, pagebreak, outline, bibliography)
#let is-block(it) = {
  if type(it) != content { return false }
  let f = it.func()
  if f in block-elements { return true }
  if f in (raw, math.equation, quote) { return it.at("block", default: false) }
  if f == html.elem { return it.tag not in ("span", "a", "em", "strong", "code", "sub", "sup", "mark", "s", "u", "small", "b", "i") }
  if it.has("children") { return it.children.any(is-block) }
  if it.has("child") { return is-block(it.child) }
  false
}

#let pad-rule(it) = {
  let styles = ()
  for side in ("top", "right", "bottom", "left") {
    let value = it.at(side)
    if value == 0% + 0pt or value == 0pt { continue }
    let negative = (if type(value) == relative { value.length } else { value }).to-absolute() < 0pt
    styles.push((if negative { "margin-" } else { "padding-" }) + side + ": " + size(value))
  }
  div("letmeout-pad", ("display: flow-root",) + styles,
    if text-block(it.body) { trim-text-block(it.body) } else { it.body })
}

#let hide-rule(it) = {
  let tag = if is-block(it.body) { "div" } else { "span" }
  html.elem(tag, attrs: (class: "letmeout-hide", style: "visibility: hidden"), it.body)
}

// Degrees, without floating-point noise such as 29.999999999999996.
#let deg(angle) = num(calc.round(angle.deg(), digits: 9)) + "deg"

#let origin-css(origin) = {
  let rtl = direction() == "rtl"
  let x = if origin.x == none or origin.x == center { "center" }
    else if origin.x == left or (origin.x == start and not rtl) or (origin.x == end and rtl) { "left" }
    else { "right" }
  let y = if origin.y == none or origin.y == horizon { "center" } else { repr(origin.y) }
  x + " " + y
}

// Transforms draw the content moved, rotated, scaled, or skewed. As with
// `reflow: false` in Typst, the content keeps its original space in the layout.
#let transformed(class, it, transform, extra: ()) = div(class, (
  "width: fit-content", "max-width: 100%", "transform: " + transform,
  "transform-origin: " + origin-css(it.origin),
) + extra, it.body)

#let move-rule(it) = div("letmeout-move",
  ("position: relative", "left: " + size(it.dx), "top: " + size(it.dy)), it.body)

#let rotate-rule(it) = transformed("letmeout-rotate", it, "rotate(" + deg(it.angle) + ")")

#let skew-rule(it) = transformed("letmeout-skew", it,
  "skew(" + deg(it.ax) + ", " + deg(it.ay) + ")")

// Scaling to a length needs the content's size, which CSS cannot read.
#let scale-rule(it) = {
  let (x, y) = (it.x, it.y)
  if x == auto { x = y }
  if y == auto { y = x }
  if x == auto { (x, y) = (100%, 100%) }
  if type(x) != ratio or type(y) != ratio { return none }
  if it.reflow and x == y and x > 0% {
    // `zoom` scales and reflows the layout, like `reflow: true`.
    return div("letmeout-scale", ("zoom: " + num(x / 100%),), it.body)
  }
  transformed("letmeout-scale", it, "scale(" + num(x / 100%) + ", " + num(y / 100%) + ")")
}

#let stack-rule(it) = {
  let horizontal = it.dir.axis() == "horizontal"
  // Flex rows follow the text direction; Typst's `ltr` and `rtl` are physical.
  let reverse = if horizontal { (it.dir == rtl) != (direction() == "rtl") } else { it.dir == btt }
  let flow = (if horizontal { "row" } else { "column" }) + if reverse { "-reverse" } else { "" }
  let spacer(amount) = {
    let main = if horizontal { "width" } else { "height" }
    div("letmeout-stack-space", if type(amount) == fraction {
      ("flex: " + num(amount / 1fr) + " 1 0",)
    } else { ("flex: none", main + ": " + size(amount)) }, [], hidden: true)
  }
  let items = ()
  let last-content = false
  for child in it.children {
    if type(child) == content {
      if last-content and it.spacing != none { items.push(spacer(it.spacing)) }
      items.push(div("letmeout-stack-item", ("flex: 0 1 auto", "min-width: 0"), child))
      last-content = true
    } else {
      items.push(spacer(child))
      last-content = false
    }
  }
  div("letmeout-stack", ("display: flex", "flex-direction: " + flow,
    "align-items: " + if horizontal { "flex-start" } else { "stretch" }), items.join())
}

// Like page columns: at least 12em wide, so they collapse on narrow screens.
#let columns-rule(it) = div("letmeout-columns", ("column-count: " + num(it.count),
  "column-width: 12em", "column-gap: " + size(it.gutter)), it.body)

#let colbreak-rule(it) = div("letmeout-colbreak", ("break-after: column",), [], hidden: true)

// A floating figure has no page to float to, so it stays in the flow. Other
// placed content is positioned in the nearest positioned container: a page
// body, shape, or styled box or block. Without a vertical alignment it stays
// at its place in the flow, as in Typst.
#let place-rule(it) = {
  let a = if it.alignment == auto { top + start } else { it.alignment }
  let x = if type(a) == alignment and a.axis() == "horizontal" { a } else if a.x != none { a.x } else { none }
  let y = if type(a) == alignment and a.axis() == "vertical" { a } else if a.y != none { a.y } else { none }
  let shift = "translate: " + size(it.dx) + " " + size(it.dy)
  if it.float {
    let body = if x != none and x != start { html-align((alignment: x, body: it.body)) } else { it.body }
    return div("letmeout-place", ("display: flow-root", "margin-block: " + size(it.clearance), shift), body)
  }
  let rtl = direction() == "rtl"
  let styles = ("position: absolute", shift)
  if x == center { styles += ("left: 0", "right: 0", "margin-inline: auto", "width: fit-content") }
  else if x == left or ((x == start or x == none) and not rtl) or (x == end and rtl) { styles.push("left: 0") }
  else { styles.push("right: 0") }
  if y == top { styles.push("top: 0") }
  else if y == bottom { styles.push("bottom: 0") }
  else if y == horizon { styles += ("top: 0", "bottom: 0", "margin-block: auto", "height: fit-content") }
  div("letmeout-place", styles, it.body)
}

// Polygons and curves have no HTML counterpart, so they become native SVG.
#let frame-rule(it) = html.frame(it)
