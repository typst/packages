// Page settings become one continuous block: a centred sheet with padding for
// margins, a <header> before the content, a <footer> after it, and
// background/foreground layers. HTML has no page height, so nothing is split
// into artificial pages. A pagebreak is only a print hint.
#import "css.typ": size, paint, direction
#import "align.typ": align
#import "papers.typ": papers

#let kind(it) = repr(it.func())

// Elements that produce no visible output.
#let invisible = ("space", "parbreak", "flush", "counter-update", "state-update",
  "metadata", "pagebreak")

#let visible-count(it) = {
  let k = kind(it)
  if k == "sequence" { it.children.map(visible-count).sum(default: 0) }
  else if k == "styled" { visible-count(it.child) }
  else if k in invisible { 0 }
  else { 1 }
}

// The same parsing as typst-library's `Margin::from_value`.
#let parse-margin(value) = {
  if value == auto { return auto }
  if type(value) != dictionary {
    return (sides: (left: value, top: value, right: value, bottom: value), two-sided: none)
  }
  let pick(..keys) = {
    for key in keys.pos() { if key in value { return value.at(key) } }
    none
  }
  let rest = pick("rest")
  let x = if "x" in value { value.x } else { rest }
  let y = if "y" in value { value.y } else { rest }
  let two-sided = if "inside" in value or "outside" in value { true }
    else if "left" in value or "right" in value { false } else { none }
  (sides: (
    left: { let v = pick("inside", "left"); if v == none { x } else { v } },
    top: { let v = pick("top"); if v == none { y } else { v } },
    right: { let v = pick("outside", "right"); if v == none { x } else { v } },
    bottom: { let v = pick("bottom"); if v == none { y } else { v } },
  ), two-sided: two-sided)
}

// Explicit sides replace inherited sides. Like Typst, the explicit value also
// decides whether `left`/`right` mean `inside`/`outside`.
#let fold-margin(outer, inner) = {
  if inner == auto or outer == auto { return inner }
  let sides = (:)
  for (side, value) in inner.sides {
    sides.insert(side, if value == none { outer.sides.at(side) } else { value })
  }
  (sides: sides, two-sided: inner.two-sided)
}

// A length is an absolute part plus a percentage of the sheet width.
#let metric(abs, pct: 0) = (abs: abs, pct: pct)

#let side-metric(value, reference, fallback) = {
  if value == none or value == auto { return metric(fallback) }
  let rel = if type(value) == ratio { 0pt + value } else { value + 0% }
  let length = rel.length.to-absolute()
  // Typst resolves ratios against the page size. Use the sheet width when that
  // dimension is automatic.
  if reference != auto { metric(length + rel.ratio * reference) }
  else { metric(length, pct: rel.ratio / 1%) }
}

#let fraction-of(rel, of) = {
  let rel = if type(rel) == ratio { 0pt + rel } else { rel + 0% }
  metric(rel.length.to-absolute() + rel.ratio * of.abs, pct: of.pct * (rel.ratio / 100%))
}

// With a fixed width, all geometry scales with the sheet like a zoomed sheet
// of paper. At full width it equals the declared lengths.
#let metric-css(m, width) = {
  let r(v) = str(calc.round(v, digits: 4))
  if width != auto { return r(m.pct + m.abs / width * 100) + "cqi" }
  if m.pct == 0 { size(m.abs) }
  else if m.abs == 0pt { r(m.pct) + "cqi" }
  else { "calc(" + size(m.abs) + " + " + r(m.pct) + "cqi)" }
}

#let counting-symbols = "1①⓵aAiIαΑաԱא一壹あいアイㄱ가١أ۱१༡১ক*".codepoints()

// Combine arguments as successive page set rules would.
#let merge-args(outer, inner) = {
  let result = outer
  if "paper" in inner {
    for key in ("paper", "width", "height") { let _ = result.remove(key, default: none) }
  }
  for (key, value) in inner {
    if key == "margin" {
      let parsed = parse-margin(value)
      result.margin = if "margin" in result { fold-margin(result.margin, parsed) } else { parsed }
    } else { result.insert(key, value) }
  }
  result
}

#let settings(named) = {
  let get(key, current) = named.at(key, default: current)
  let paper = named.at("paper", default: none)
  let size-of(key, current, index) = {
    let value = if key in named { named.at(key) }
      else if paper != none { papers.at(paper).at(index) } else { current }
    if value == auto { auto } else { value.to-absolute() }
  }
  let width = size-of("width", std.page.width, 0)
  let height = size-of("height", std.page.height, 1)
  let fixed = (width, height).filter(v => v != auto)
  let default = (2.5 / 21) * if fixed.len() == 0 { 210mm } else { calc.min(..fixed) }
  if get("flipped", std.page.flipped) { (width, height) = (height, width) }

  let outer = parse-margin(std.page.margin)
  let margin = if "margin" in named { fold-margin(outer, named.margin) } else { outer }
  let sides = if margin == auto { (left: auto, top: auto, right: auto, bottom: auto) } else { margin.sides }
  let binding = get("binding", std.page.binding)
  if binding == auto { binding = if direction() == "rtl" { right } else { left } }
  // A screen shows one sheet at a time, so every page is treated as the
  // first one. With a right binding, the inside margin is on the right.
  if margin != auto and margin.two-sided == true and binding == right {
    sides = (left: sides.right, top: sides.top, right: sides.left, bottom: sides.bottom)
  }
  let m = (
    left: side-metric(sides.left, width, default),
    right: side-metric(sides.right, width, default),
    top: side-metric(sides.top, height, default),
    bottom: side-metric(sides.bottom, height, default),
  )

  let numbering = get("numbering", std.page.numbering)
  let number-align = get("number-align", std.page.number-align)
  let number = if numbering != none {
    let both = type(numbering) == function or numbering.codepoints().filter(c => c in counting-symbols).len() >= 2
    let display = context counter(page).display(numbering, both: both)
    if number-align.x != none { align(number-align.x, display) } else { display }
  }
  let header = get("header", std.page.header)
  let footer = get("footer", std.page.footer)
  if number-align.y == top {
    if header == auto { header = number }
    if footer == auto { footer = none }
  } else {
    if header == auto { header = none }
    if footer == auto { footer = number }
  }

  let fill = get("fill", std.page.fill)
  (
    width: width, height: height, margin: m,
    ascent: fraction-of(get("header-ascent", std.page.header-ascent), m.top),
    descent: fraction-of(get("footer-descent", std.page.footer-descent), m.bottom),
    columns: get("columns", std.page.columns), gutter: std.columns.gutter,
    fill: if fill == auto { none } else { fill },
    header: header, footer: footer,
    background: get("background", std.page.background),
    foreground: get("foreground", std.page.foreground),
  )
}

#let layer(body, class, z) = html.elem("div", attrs: (
  class: class, "aria-hidden": "true", style: (
    "position: absolute", "inset: 0", "z-index: " + z, "pointer-events: none",
    "overflow: clip", "display: grid", "grid-template: minmax(0, 1fr) / minmax(0, 1fr)",
    "place-items: center", "text-align: center",
  ).join("; "),
), { set std.align(center + horizon); body })

// One part of a page. A page is normally a single part; nested pages split it,
// and then only the first part has the header and the last has the footer.
#let section(s, body, first, last, lang: auto, dir: auto) = {
  let css(m) = metric-css(m, s.width)
  let inline = ("padding-left: " + css(s.margin.left), "padding-right: " + css(s.margin.right))
  let styles = ("box-sizing: border-box", "min-width: 0")
  // Print hints only. On screen the page continues without breaks.
  if first { styles.push("break-before: page") }
  if last { styles.push("break-after: page") }
  if s.fill != none { styles.push("background: " + paint(s.fill)) }
  let sheet = (
    "box-sizing: border-box", "position: relative", "isolation: isolate",
    "width: 100%", "margin-inline: auto", "container-type: inline-size",
  )
  if s.width != auto { sheet.push("max-width: " + size(s.width)) }
  let header = first and s.header != none
  let footer = last and s.footer != none
  // Positioned, so placed content is placed relative to the content area.
  let body-styles = ("box-sizing: border-box", "display: flow-root", "position: relative", "min-width: 0") + inline
  if first and not header { body-styles.push("padding-top: " + css(s.margin.top)) }
  if last and not footer { body-styles.push("padding-bottom: " + css(s.margin.bottom)) }
  if s.columns > 1 {
    // Columns collapse on narrow screens instead of becoming unreadable.
    body-styles += ("column-count: " + str(s.columns), "column-width: 12em",
      "column-gap: " + size(s.gutter))
  }
  let marginal(tag, content, height, gap, y) = html.elem(tag, attrs: (
    class: "letmeout-page-" + tag, style: (
      "box-sizing: border-box", "display: flex", "flex-direction: column",
      "justify-content: " + if y == bottom { "flex-end" } else { "flex-start" },
      "min-height: " + css(height),
      "padding-" + if y == bottom { "bottom" } else { "top" } + ": " + css(gap),
    ).join("; ") + "; " + inline.join("; "),
  ), { set std.align(y); content })

  html.elem("section", attrs: (class: "letmeout-page",
    dir: if dir == auto { direction() } else { dir }, lang: if lang == auto { text.lang } else { lang },
    style: styles.join("; ")),
    html.elem("div", attrs: (class: "letmeout-page-sheet", style: sheet.join("; ")), {
      if s.background != none { layer(s.background, "letmeout-page-background", "-1") }
      if header { marginal("header", s.header, s.margin.top, s.ascent, bottom) }
      html.elem("div", attrs: (class: "letmeout-page-body", style: body-styles.join("; ")), body)
      if footer { marginal("footer", s.footer, s.margin.bottom, s.descent, top) }
      if s.foreground != none { layer(s.foreground, "letmeout-page-foreground", "1") }
    }))
}

// HTML is one continuous document, so a pagebreak adds nothing on screen. A
// strong break stays a print hint. Weak breaks (including the ones a native
// `page` call adds around its body) render nothing, since a page block
// already starts on a new printed sheet.
#let html-pagebreak(it) = if not it.weak {
  html.elem("div", attrs: (
    class: "letmeout-pagebreak", "aria-hidden": "true",
    style: "break-before: " + if it.to == "odd" { "recto" } else if it.to == "even" { "verso" } else { "page" },
  ))
}
