// `#show: letmeout` lets the native `page` APIs shape the HTML document:
// `set page`, `page(..)[..]`, `show: page.with(..)`, and `pagebreak`.
// Set rules run no code and their styles cannot be inspected, so the document
// is probed: an invisible probe under every style node records the page
// settings in effect there. The document is split into page blocks only where
// those settings change, so other set rules never break the content apart.
#import "css.typ": direction
#import "target.typ": resolve
#import "page.typ": kind, visible-count, merge-args, settings, section, html-pagebreak
#import "screen.typ": screen, screen-style
#import "scroll.typ": group-wide

#let probe-label = <letmeout-probe>
// Start and end of a `context` item, and page settings found inside one.
#let opaque-label = <letmeout-opaque>
#let nested-label = <letmeout-nested-page>
// The start of each heading and paragraph in a checked item, to quote in the error.
#let excerpt-label = <letmeout-excerpt>

// The raw page settings. Two places share a page block when these are equal.
#let page-key() = (
  width: std.page.width, height: std.page.height, flipped: std.page.flipped,
  margin: std.page.margin, binding: std.page.binding, columns: std.page.columns,
  fill: std.page.fill, numbering: std.page.numbering, number-align: std.page.number-align,
  header: std.page.header, header-ascent: std.page.header-ascent,
  footer: std.page.footer, footer-descent: std.page.footer-descent,
  background: std.page.background, foreground: std.page.foreground,
)

#let probe-value() = (
  key: page-key(), lang: text.lang, dir: direction(), gutter: std.columns.gutter,
)

#let wrap-all(body, wraps) = wraps.rev().fold(body, (acc, w) => w.at(0)(acc, w.at(1)))

// Style nodes get ids in pre-order. `runs` walks the same nodes in the same order.
#let probes(it, wraps, next) = {
  let k = kind(it)
  if k == "sequence" {
    let items = ()
    for child in it.children {
      let r = probes(child, wraps, next)
      items += r.items
      next = r.next
    }
    return (items: items, next: next)
  }
  if k == "styled" {
    let inner = wraps + ((it.func(), it.styles),)
    let id = next
    let probe = wrap-all(context [#metadata((id: id) + probe-value())#probe-label], inner)
    let r = probes(it.child, inner, next + 1)
    return (items: (probe,) + r.items, next: r.next)
  }
  (items: (), next: next)
}

// A `context` item hides its content, for example when a show rule after
// `#show: letmeout` wraps the rest of the document in `context`. Page settings
// inside one would end up inside an HTML element, which Typst rejects without
// pointing at the cause. So each one is first rendered outside the blocks,
// where page settings are allowed, and checked: a page call leaves a flush
// (see `letmeout`), and a `set page` shows in the settings of its paragraphs.
#let nested-mark = [#metadata(none)#nested-label]

// The plain text of some content, for a short quote.
#let plain(it) = {
  if type(it) == str { return it }
  if type(it) != content { return "" }
  if kind(it) in ("space", "linebreak", "parbreak") { return " " }
  // Math text does not match its source, so it is left out. Paragraph bodies
  // hold MathML already.
  if kind(it) == "equation" or (kind(it) == "elem" and it.tag == "math") { return "…" }
  if it.has("text") { return plain(it.text) }
  if it.has("children") { return it.children.map(plain).join(default: "") }
  if it.has("body") { return plain(it.body) }
  if it.has("child") { return plain(it.child) }
  ""
}

// At most `n` characters, cut at a word where possible.
#let shorten(raw, n: 60) = {
  let s = raw.replace(regex("\\s+"), " ").trim()
  let chars = s.clusters()
  if chars.len() <= n { return s }
  let cut = chars.slice(0, n).join()
  let words = cut.split(" ")
  if words.len() > 1 { cut = words.slice(0, -1).join(" ") }
  cut.trim(regex("[\\s,.;:]+"), at: end) + "…"
}

// Records where a heading or paragraph starts, so the error can quote it.
#let excerpt-rule(it) = {
  let quote = shorten(plain(it.body))
  if quote != "" { [#metadata(quote)#excerpt-label] }
  it
}

// Per item id: whether page settings were found inside, and the start of the
// item's first heading or paragraph. Items the last layout pass has not
// rendered yet are missing.
#let opaque-states() = {
  let any = query(nested-label).len() > 0
  let starts = (:)
  let states = (:)
  for m in query(opaque-label) {
    let id = str(m.value.id)
    if m.value.start { starts.insert(id, m.location()) } else if id in starts {
      let inside(label) = query(selector(label).after(starts.at(id)).before(m.location()))
      let found = any and inside(nested-label).len() > 0
      let excerpt = if found { inside(excerpt-label).at(0, default: none) }
      states.insert(id, (found: found, excerpt: if excerpt != none { excerpt.value }))
    }
  }
  states
}

// A card that floats at the top of the screen while the reader scrolls.
#let nested-error-css = (
  ".letmeout-error { position: sticky; top: 0.75rem; z-index: 2147483647; box-sizing: border-box;"
  + " display: flex; gap: 0.75rem; align-items: flex-start; width: min(46rem, calc(100% - 1.5rem));"
  + " margin: 0.75rem auto; padding: 0.875rem 1rem; border-radius: 0.875rem;"
  + " border: 1px solid light-dark(rgb(220 38 38 / 0.22), rgb(248 113 113 / 0.28));"
  + " background: light-dark(rgb(255 241 242 / 0.82), rgb(60 14 18 / 0.78));"
  + " -webkit-backdrop-filter: blur(14px) saturate(1.6); backdrop-filter: blur(14px) saturate(1.6);"
  + " box-shadow: 0 12px 32px -12px rgb(0 0 0 / 0.28), 0 2px 6px -2px rgb(0 0 0 / 0.12);"
  + " color: light-dark(#7f1d1d, #fecdd3); font: 0.875rem/1.5 system-ui, -apple-system, 'Segoe UI', sans-serif; }"
  + " .letmeout-error-icon { flex: none; display: grid; place-items: center; width: 1.5rem; height: 1.5rem;"
  + " border-radius: 999px; background: light-dark(#dc2626, #f87171); color: light-dark(#fff, #3c0e12);"
  + " font-weight: 700; font-size: 0.875rem; line-height: 1; }"
  + " .letmeout-error-text { min-width: 0; }"
  + " .letmeout-error-excerpt { display: block; margin-top: 0.375rem; color: light-dark(#9f1239, #fda4af); }"
  + " .letmeout-error-excerpt q { font-style: italic; quotes: '\\201C' '\\201D'; }"
  + " .letmeout-error-title { display: block; font-weight: 600; color: light-dark(#991b1b, #fda4af); }"
  + " .letmeout-error code, .letmeout-error code * { font: 0.8125rem/1.4 ui-monospace, SFMono-Regular, Menlo, monospace !important; }"
  + " .letmeout-error code { padding: 0.0625rem 0.3125rem; border-radius: 0.375rem;"
  + " background: light-dark(rgb(220 38 38 / 0.1), rgb(248 113 113 / 0.16)); }"
)

#let nested-error(excerpt) = html.elem("div", attrs: (class: "letmeout-error", role: "alert"), {
  html.elem("style", nested-error-css)
  html.elem("span", attrs: (class: "letmeout-error-icon", "aria-hidden": "true"))[!]
  html.elem("div", attrs: (class: "letmeout-error-text"), {
    html.elem("strong", attrs: (class: "letmeout-error-title"))[letmeout: page settings ignored in HTML]
    html.elem("span")[
      A show rule after `#show: letmeout`, usually a template, wraps the document in
      `context`, so its page settings cannot be read. Move `#show: letmeout` below
      that show rule, or set the page before it.
    ]
    if excerpt != none {
      html.elem("span", attrs: (class: "letmeout-error-excerpt"))[
        Affected content starts at #html.elem("q", excerpt)
      ]
    }
  })
})

// Unlikely page settings for the first check. Any `set page` inside the item
// replaces some of them, even one that repeats the surrounding values.
#let sentinel = {
  let mark = metadata("letmeout-sentinel")
  (width: 1234.5678pt, height: 1234.5678pt, margin: 12.345678pt, columns: 97,
    fill: rgb(1, 2, 3), numbering: "letmeout 1 sentinel", header: mark, footer: mark,
    header-ascent: 12.345678%, footer-descent: 12.345678%, background: mark, foreground: mark)
}

#let opaque-item(it, info, states, id) = {
  let mark(start) = [#metadata((id: id, start: start))#opaque-label]
  let state = states.at(str(id), default: none)
  if state != none and not state.found {
    return (kind: "flow", body: mark(true) + it + mark(false), info: info)
  }
  // Once found, the item keeps its mark. Without the sentinel settings a
  // repeated `set page` would no longer show.
  let body = if state != none {
    let quoted = { show selector.or(heading, par): excerpt-rule; it }
    nested-error(state.excerpt) + mark(true) + nested-mark + quoted + mark(false)
  } else {
    set page(..sentinel)
    mark(true) + context {
      let key = page-key()
      show par: p => {
        context if page-key() != key { nested-mark }
        p
      }
      show selector.or(heading, par): excerpt-rule
      it
    } + mark(false)
  }
  (kind: "content", body: body)
}

#let block-of(item) = {
  if visible-count(item.body) == 0 { return item.body }
  let s = settings(merge-args((:), item.info.key))
  s.gutter = item.info.gutter
  section(s, group-wide(item.body), true, true, lang: item.info.lang, dir: item.info.dir)
}

// Render runs of equal page settings as blocks. A style node whose subtree
// changes the page settings is kept outside the blocks and wraps them: Typst
// does not allow page styles inside an HTML element.
// `next` counts style nodes (as in `probes`) and `context` items.
#let parts(it, info, found, states, next) = {
  let k = kind(it)
  if k == "sequence" {
    let items = ()
    for child in it.children {
      let r = parts(child, info, found, states, next)
      next = r.next
      for item in r.items {
        if (item.kind == "flow" and items.len() > 0 and items.last().kind == "flow"
          and items.last().info.key == item.info.key) {
          let last = items.pop()
          items.push(last + (body: last.body + item.body))
        } else { items.push(item) }
      }
    }
    return (items: items, next: next)
  }
  if k == "styled" {
    // Before the probes are measured, assume that every node changes the
    // page settings, so no page style ever lands inside a block.
    let probed = found.at(str(next.style), default: none)
    let own = if probed == none { info } else { probed }
    let r = parts(it.child, own, found, states, next + (style: next.style + 1))
    if probed != none and r.items.all(i => i.kind == "flow" and i.info.key == info.key) {
      // One node, so its set rules stay inside one block. Rebuilt from the
      // items rather than reused: `context` items inside carry marks that
      // the next layout pass reads back.
      let body = it.func()(r.items.map(i => i.body).join(default: []), it.styles)
      return (items: ((kind: "flow", body: body, info: own),), next: r.next)
    }
    let rendered = r.items.map(i => if i.kind == "flow" { block-of(i) } else { i.body }).join()
    return (items: ((kind: "content", body: it.func()(rendered, it.styles)),), next: r.next)
  }
  if k == "context" {
    return (items: (opaque-item(it, info, states, next.ctx),), next: next + (ctx: next.ctx + 1))
  }
  (items: ((kind: "flow", body: it, info: info),), next: next)
}

#let html-document(body, options) = {
  let root = probe-value()
  // After the hoisted set rules, so their font and color are the document's.
  let text-root = (font: text.font, fill: text.fill, size: text.size, weight: text.weight, style: text.style, tracking: text.tracking)
  screen-style(text-root, options)
  show: screen.with(text-root)
  // Probes render nothing. Their values are read back below.
  probes(body, (), 0).items.join()
  context {
    let found = (:)
    for m in query(probe-label) { found.insert(str(m.value.id), m.value) }
    let items = parts(body, root, found, opaque-states(), (style: 0, ctx: 0)).items
    if items.len() == 0 { items = ((kind: "flow", body: [], info: root),) }
    for item in items {
      if item.kind == "flow" { block-of(item) } else { item.body }
    }
  }
}

// Leading set rules stay outermost. Typst requires `set document` before any
// content, so it must not end up inside a page block.
#let hoist(body, options) = {
  let k = kind(body)
  if k == "sequence" {
    let children = body.children
    while children.len() > 0 and kind(children.first()) in ("space", "parbreak") {
      children = children.slice(1)
    }
    if children.len() == 1 { return hoist(children.first(), options) }
  }
  if k == "styled" { return body.func()(hoist(body.child, options), body.styles) }
  context html-document(body, options)
}

/// Adapts native page settings and screen styling for continuous HTML.
/// Paged output returns the document body unchanged.
///
/// #quote(block: true)[*Note:* In HTML, also adapts elements that Typst's HTML
/// export ignores or strips: `rect`, `square`, `circle`, `ellipse`, `polygon`,
/// `curve`, styled `box` and `block`, `h`, `v`, `pad`, `hide`, `move`, `rotate`,
/// `scale`, `skew`, `stack`, `columns`, `colbreak`, `place`, and the strokes of
/// `underline`, `overline`, `strike`, and `highlight`. What CSS cannot express
/// keeps Typst's native output.]
///
/// - body (content): The show rule's body. In HTML, resolves target-specific
///   rules, reads native page settings, and renders continuous blocks with
///   selectable content. Also preserves text fonts/colors and native MathML.
/// - color-scheme (string, none): Default `"light dark"` follows the reader's
///   preference; `"light"` or `"dark"` fixes the scheme. Sets CSS `color-scheme`
///   and the Canvas background. `none` omits these and the dark frame/visibility
///   rules, leaving the scheme to the host browser styles.
/// - dark-colors (array): Default `()`. `(light, dark)` color pairs replace the
///   automatic dark variant via CSS properties, including gradient stops.
///   Nested themes override individual mappings. Frame internals keep their own
///   colors. Example: `((rgb("fbf8f1"), rgb("23211c")),)`.
/// - dark-frames (string, none): Default `"invert"` adds an inversion and hue
///   rotation to native framed SVG in dark mode; `none` preserves frame colors.
///   Scoped themes can override the inherited policy.
/// - css (string): Default `""`. CSS appended to the document stylesheet.
///
/// See docs/html-semantics.md for every native page/pagebreak field and the
/// individual screen adapters. Page support requires this show rule before
/// document content. Optional wrappers in `letmeout-extras` also work without it.
///
/// -> content
#let letmeout(body, color-scheme: "light dark", dark-colors: (), dark-frames: "invert", css: "") = context {
  assert(dark-frames in (none, "invert"), message: "letmeout: dark-frames is \"invert\" or none")
  let options = (color-scheme: color-scheme, dark-colors: dark-colors, dark-frames: dark-frames, css: css)
  if target() != "html" { return body }
  show std.pagebreak: it => context {
    if target() == "html" { html-pagebreak(it) } else { it }
  }
  // Native `page` calls add an invisible flush. Blocks already end the page.
  // A flush inside a `context` item reveals a page call there.
  show place.flush: it => context { if target() != "html" { it } else { nested-mark } }
  hoist(resolve(body), options)
}
