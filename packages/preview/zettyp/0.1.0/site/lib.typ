/// Site integration contracts and generic HTML rendering support.

// Layout unsupported by HTML is rendered as SVG; other targets are untouched.

#let frame(body) = context if target() == "html" { html.frame(body) } else {
  body
}

/// Wrap a layout package's constructor, e.g. `framed(fletcher.diagram)`.
/// Package diagrams are opaque `context`, so they must be declared.
#let framed(constructor) = (..args) => frame(constructor(..args))

// Typst's MathML omits these. A frame inside MathML cannot be typeset by
// MathJax, so an equation containing one is framed as a whole instead.
// (`html` exists only when HTML export is enabled, so frames match by name.)
#let paged-only = (
  math.cancel,
  math.underline,
  box,
  block,
  stack,
  grid,
  place,
  scale,
  move,
  rotate,
)
#let needs-frame(value) = if type(value) == array {
  value.any(needs-frame)
} else if type(value) == content {
  (
    value.func() in paged-only
      or repr(value.func()) == "frame"
      or value.fields().values().any(needs-frame)
  )
} else { false }

// Show rules also reach content laid out inside frames, where the target is
// paged again; each rule therefore checks the target where it applies.
#let on-html(rule) = it => context if target() == "html" { rule(it) } else {
  it
}

#let html-rules(body) = {
  // Frames share the page's type size (Forester's 12pt).
  set text(size: 12pt)
  show math.equation: on-html(it => {
    if not needs-frame(it.body) { return it }
    // Inline frames end at the baseline; descenders overflow, so they align.
    if it.block { html.div(class: "zk-frame", html.frame(it)) } else {
      box(html.frame(it))
    }
  })
  // MathML export drops overline; as an overline accent (U+203E) it stays
  // semantic, and the math pipeline makes it stretch.
  show math.overline: on-html(it => math.accent(it.body, "\u{203E}"))
  // Inline layout stays inline: a box around paged-only content is framed whole.
  show box: on-html(it => {
    let body = it.body
    if body == none or repr(body.func()) == "frame" or not needs-frame(body) {
      return it
    }
    box(html.frame(it))
  })
  show selector.or(stack, grid, place, scale, move, rotate): on-html(
    it => html.div(
      class: "zk-frame",
      html.frame(it),
    ),
  )
  show align: on-html(it => {
    let x = it.alignment.x
    let side = if x == center { "center" } else if x in (right, end) {
      "right"
    } else { "left" }
    html.div(style: "text-align: " + side, it.body)
  })
  body
}

#let tree(summary, body, open: true, attrs: (:)) = html.section(
  class: "block",
  html.elem("details", attrs: attrs + if open { (open: "") } else { (:) }, {
    html.summary(summary)
    body
  }),
)

// Content repeated in a view must not advance the document's counters, or all
// numbering after it would shift; each counter is restored after the copy.
#let counted = (
  math.equation,
  heading,
  footnote,
  figure.where(kind: image),
  figure.where(kind: table),
  figure.where(kind: raw),
)
#let isolated(body) = context {
  let saved = counted.map(key => counter(key).get())
  body
  for (key, value) in counted.zip(saved) { counter(key).update(value) }
}

// Links retain the identity of the node in which they were rendered.
#let rendering = state("zettypst.rendering", none)

#let node(id, body) = {
  rendering.update(id)
  html.elem("section", attrs: ("data-zk-node": id), body)
}

#let node-link(target, body) = context html.elem(
  "span",
  attrs: (
    class: "zk-link",
    "data-zk-source": rendering.get(),
    "data-zk-target": target,
  ),
  body,
)

#let unpublished(body) = html.span(class: "zk-unpublished", body)

#let expand-attrs(target) = ("data-zk-expand": target)

/// Resolved views map names to auto (in-place), none (disabled), or content.
#let view-attrs(views) = {
  let names = views
    .pairs()
    .filter(((_, value)) => value == auto)
    .map(((name, _)) => name)
  if names.len() > 0 { ("data-zk-view": names.join(" ")) } else { (:) }
}

// Empty templates explicitly disable views; absent markers allow fallback.
#let view-templates(views) = {
  for (name, value) in views.pairs().filter(((_, value)) => value != auto) {
    html.elem("template", attrs: ("data-zk-view": name), if value != none {
      isolated(value)
    })
  }
}

/// Publish resolved entries with string id, route and title fields.
#let publish-index(entries) = asset("zettypst.json", json.encode(entries))
