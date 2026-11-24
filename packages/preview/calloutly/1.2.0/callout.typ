#import "code-callout.typ" : *
// --- Color Palettes ---
#let colors = (
  note: rgb("#0969da"),
  tip: rgb("#2e8540"),
  important: rgb("#cc0000"), // Red for important
  warning: rgb("#d97706"), // Deeper orange for warning
  caution: rgb("#fd7e14"), // Lighter orange for caution
  success: rgb("#3d9e28"), // Green for success
  error: rgb("#d92b2a") // Red for error
)

// --- Icons (SVGs) ---
#let icons = (
  note: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16">
  <path d="M8 15A7 7 0 1 1 8 1a7 7 0 0 1 0 14m0 1A8 8 0 1 0 8 0a8 8 0 0 0 0 16"/>
  <path d="m8.93 6.588-2.29.287-.082.38.45.083c.294.07.352.176.288.469l-.738 3.468c-.194.897.105 1.319.808 1.319.545 0 1.178-.252 1.465-.598l.088-.416c-.2.176-.492.246-.686.246-.275 0-.375-.193-.304-.533zM9 4.5a1 1 0 1 1-2 0 1 1 0 0 1 2 0"/>
</svg>`,
  tip: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16">
  <path d="M2 6a6 6 0 1 1 10.174 4.31c-.203.196-.359.4-.453.619l-.762 1.769A.5.5 0 0 1 10.5 13a.5.5 0 0 1 0 1 .5.5 0 0 1 0 1l-.224.447a1 1 0 0 1-.894.553H6.618a1 1 0 0 1-.894-.553L5.5 15a.5.5 0 0 1 0-1 .5.5 0 0 1 0-1 .5.5 0 0 1-.46-.302l-.761-1.77a2 2 0 0 0-.453-.618A5.98 5.98 0 0 1 2 6m6-5a5 5 0 0 0-3.479 8.592c.263.254.514.564.676.941L5.83 12h4.342l.632-1.467c.162-.377.413-.687.676-.941A5 5 0 0 0 8 1"/>
</svg>`,
  important: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16">
  <path d="M8 15A7 7 0 1 1 8 1a7 7 0 0 1 0 14m0 1A8 8 0 1 0 8 0a8 8 0 0 0 0 16"/>
  <path d="M7.002 11a1 1 0 1 1 2 0 1 1 0 0 1-2 0M7.1 4.995a.905.905 0 1 1 1.8 0l-.35 3.507a.552.552 0 0 1-1.1 0z"/>
</svg>`,
  warning: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16">
  <path d="M7.938 2.016A.13.13 0 0 1 8.002 2a.13.13 0 0 1 .063.016.15.15 0 0 1 .054.057l6.857 11.667c.036.06.035.124.002.183a.2.2 0 0 1-.054.06.1.1 0 0 1-.066.017H1.146a.1.1 0 0 1-.066-.017.2.2 0 0 1-.054-.06.18.18 0 0 1 .002-.183L7.884 2.073a.15.15 0 0 1 .054-.057m1.044-.45a1.13 1.13 0 0 0-1.96 0L.165 13.233c-.457.778.091 1.767.98 1.767h13.713c.889 0 1.438-.99.98-1.767z"/>
  <path d="M7.002 12a1 1 0 1 1 2 0 1 1 0 0 1-2 0M7.1 5.995a.905.905 0 1 1 1.8 0l-.35 3.507a.552.552 0 0 1-1.1 0z"/>
</svg>`,
  caution: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16">
  <path d="m9.97 4.88.953 3.811C10.159 8.878 9.14 9 8 9s-2.158-.122-2.923-.309L6.03 4.88C6.635 4.957 7.3 5 8 5s1.365-.043 1.97-.12m-.245-.978L8.97.88C8.718-.13 7.282-.13 7.03.88L6.275 3.9C6.8 3.965 7.382 4 8 4s1.2-.036 1.725-.098m4.396 8.613a.5.5 0 0 1 .037.96l-6 2a.5.5 0 0 1-.316 0l-6-2a.5.5 0 0 1 .037-.96l2.391-.598.565-2.257c.862.212 1.964.339 3.165.339s2.303-.127 3.165-.339l.565 2.257z"/>
</svg>`,
  success: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16">
  <path d="M8 15A7 7 0 1 1 8 1a7 7 0 0 1 0 14m0 1A8 8 0 1 0 8 0a8 8 0 0 0 0 16"/>
  <path fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" d="M4.9 8.3 6.9 10.3 11.1 5.7"/>
</svg>`,
  error: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16">
  <path d="M8 15A7 7 0 1 1 8 1a7 7 0 0 1 0 14m0 1A8 8 0 1 0 8 0a8 8 0 0 0 0 16"/>
  <path fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" d="M5.5 5.5 10.5 10.5M10.5 5.5 5.5 10.5"/>
</svg>`,
)

// --- GitHub Theme Data ---
#let github-colors = (
  note: rgb("#0969da"),
  tip: rgb("#1a7f37"),
  important: rgb("#8250df"),
  warning: rgb("#9a6700"),
  caution: rgb("#d1242f"),
  success: rgb("#1a7f37"),
  error: rgb("#cf222e"),
)

#let github-icons = (
  note: `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16" width="16" height="16" fill="currentColor"><path d="M0 8a8 8 0 1 1 16 0A8 8 0 0 1 0 8Zm8-6.5a6.5 6.5 0 1 0 0 13 6.5 6.5 0 0 0 0-13ZM6.5 7.75A.75.75 0 0 1 7.25 7h1a.75.75 0 0 1 .75.75v2.75h.25a.75.75 0 0 1 0 1.5h-2a.75.75 0 0 1 0-1.5h.25v-2h-.25a.75.75 0 0 1-.75-.75ZM8 6a1 1 0 1 1 0-2 1 1 0 0 1 0 2Z"/></svg>`,
  tip: `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16" width="16" height="16" fill="currentColor"><path d="M8 1.5c-2.363 0-4 1.69-4 3.75 0 .984.424 1.625.984 2.304l.214.253c.223.264.47.556.673.848.284.411.537.896.621 1.49a.75.75 0 0 1-1.484.211c-.04-.282-.163-.547-.37-.847a8.456 8.456 0 0 0-.542-.68c-.084-.1-.173-.205-.268-.32C3.201 7.75 2.5 6.766 2.5 5.25 2.5 2.31 4.863 0 8 0s5.5 2.31 5.5 5.25c0 1.516-.701 2.5-1.328 3.259-.095.115-.184.22-.268.319-.207.245-.383.453-.541.681-.208.3-.33.565-.37.847a.751.751 0 0 1-1.485-.212c.084-.593.337-1.078.621-1.489.203-.292.45-.584.673-.848.075-.088.147-.173.213-.253.561-.679.985-1.32.985-2.304 0-2.06-1.637-3.75-4-3.75ZM5.75 12h4.5a.75.75 0 0 1 0 1.5h-4.5a.75.75 0 0 1 0-1.5ZM6 15.25a.75.75 0 0 1 .75-.75h2.5a.75.75 0 0 1 0 1.5h-2.5a.75.75 0 0 1-.75-.75Z"/></svg>`,
  important: `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16" width="16" height="16" fill="currentColor"><path d="M0 1.75C0 .784.784 0 1.75 0h12.5C15.216 0 16 .784 16 1.75v9.5A1.75 1.75 0 0 1 14.25 13H8.06l-2.573 2.573A1.458 1.458 0 0 1 3 14.543V13H1.75A1.75 1.75 0 0 1 0 11.25Zm1.75-.25a.25.25 0 0 0-.25.25v9.5c0 .138.112.25.25.25h2a.75.75 0 0 1 .75.75v2.19l2.72-2.72a.749.749 0 0 1 .53-.22h6.5a.25.25 0 0 0 .25-.25v-9.5a.25.25 0 0 0-.25-.25Zm7 2.25v2.5a.75.75 0 0 1-1.5 0v-2.5a.75.75 0 0 1 1.5 0ZM9 9a1 1 0 1 1-2 0 1 1 0 0 1 2 0Z"/></svg>`,
  warning: `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16" width="16" height="16" fill="currentColor"><path d="M6.457 1.047c.659-1.234 2.427-1.234 3.086 0l6.082 11.378A1.75 1.75 0 0 1 14.082 15H1.918a1.75 1.75 0 0 1-1.543-2.575Zm1.763.707a.25.25 0 0 0-.44 0L1.698 13.132a.25.25 0 0 0 .22.368h12.164a.25.25 0 0 0 .22-.368Zm.53 3.996v2.5a.75.75 0 0 1-1.5 0v-2.5a.75.75 0 0 1 1.5 0ZM9 11a1 1 0 1 1-2 0 1 1 0 0 1 2 0Z"/></svg>`,
  caution: `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16" width="16" height="16" fill="currentColor"><path d="M4.47.22A.749.749 0 0 1 5 0h6c.199 0 .389.079.53.22l4.25 4.25c.141.14.22.331.22.53v6a.749.749 0 0 1-.22.53l-4.25 4.25A.749.749 0 0 1 11 16H5a.749.749 0 0 1-.53-.22L.22 11.53A.749.749 0 0 1 0 11V5c0-.199.079-.389.22-.53Zm.84 1.28L1.5 5.31v5.38l3.81 3.81h5.38l3.81-3.81V5.31L10.69 1.5ZM8 4a.75.75 0 0 1 .75.75v3.5a.75.75 0 0 1-1.5 0v-3.5A.75.75 0 0 1 8 4Zm0 8a1 1 0 1 1 0-2 1 1 0 0 1 0 2Z"/></svg>`,
  success: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16">
  <path d="M8 15A7 7 0 1 1 8 1a7 7 0 0 1 0 14m0 1A8 8 0 1 0 8 0a8 8 0 0 0 0 16"/>
  <path fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" d="M4.9 8.3 6.9 10.3 11.1 5.7"/>
</svg>`,
  error: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16">
  <path d="M8 15A7 7 0 1 1 8 1a7 7 0 0 1 0 14m0 1A8 8 0 1 0 8 0a8 8 0 0 0 0 16"/>
  <path fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" d="M5.5 5.5 10.5 10.5M10.5 5.5 5.5 10.5"/>
</svg>`,
)


// --- edstem marks ---
//
// The tile is already the container, so a framed icon would be a container
// inside a container and reads thin at that size. These are solid, unframed
// marks with the weight of the bold glyphs used for "note" and "important".
#let edstem-icons = (
  tip: (size: 1.18em, svg: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16">
  <path d="M8 1a4.6 4.6 0 0 0-2.7 8.33c.42.3.7.7.7 1.12v.25h4v-.25c0-.42.28-.82.7-1.12A4.6 4.6 0 0 0 8 1"/>
  <path d="M6 11.85h4v1.3H6zM6.7 14h2.6a.65.65 0 0 1 0 1.3H6.7a.65.65 0 0 1 0-1.3"/>
</svg>`),
  warning: (size: 1.18em, svg: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16">
  <path fill-rule="evenodd" d="M8.87 1.98a1 1 0 0 0-1.74 0L.36 13.72a1 1 0 0 0 .87 1.5h13.54a1 1 0 0 0 .87-1.5zM7.2 5.6h1.6l-.3 4.6H7.5zM8 13.15a1.08 1.08 0 1 1 0-2.15 1.08 1.08 0 0 1 0 2.15"/>
</svg>`),
  caution: (size: 1.18em, svg: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16">
  <path fill-rule="evenodd" d="M8.62 1.72a.66.66 0 0 0-1.24 0L4.5 11.3h7zM2.3 12.5h11.4a.65.65 0 0 1 0 1.3H2.3a.65.65 0 0 1 0-1.3M6.09 6.95h3.82l.55 1.5H5.54z"/>
</svg>`),
  success: (size: 1.3em, svg: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16">
  <path fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" d="M2.8 8.4 6.3 11.9 13.2 4.5"/>
</svg>`),
  error: (size: 1.3em, svg: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16">
  <path fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" d="M4.2 4.2 11.8 11.8M11.8 4.2 4.2 11.8"/>
</svg>`),
)

#import "shell.typ": shell, svg-icon

// --- Helper Functions ---

#let callout-types = ("note", "tip", "warning", "important", "caution", "success", "error")

#let resolve-color(style, type, custom-color) = {
  if custom-color != auto { return custom-color }

  let color-dict = if style == "github" { github-colors } else { colors }
  return color-dict.at(type, default: rgb("#4472c4"))
}

// `auto` and `none` both mean "derive the title from the type".
#let resolve-title(type, custom-title) = {
  if custom-title != auto and custom-title != none { return custom-title }
  return upper(type.slice(0, 1)) + type.slice(1)
}

// "edstem" marks the callout with a bare glyph on the accent tile rather than a
// framed icon: the tile is the container, so an icon that draws its own circle
// reads thin and fussy at that size. The tile colour carries the type, which is
// why the three attention types share an exclamation mark.
#let edstem-glyphs = (note: "i", important: "!")

#let get-edstem-icon(type) = {
  if type in edstem-glyphs {
    return text(fill: white, weight: "bold", size: 1.4em, baseline: 0pt, edstem-glyphs.at(type))
  }
  let mark = edstem-icons.at(type, default: edstem-icons.warning)
  svg-icon(mark.svg.text, white, baseline: 0pt, size: mark.size)
}

#let get-icon(style, type, color, baseline: 0.15em) = {
  let icon-dict = if style == "github" { github-icons } else { icons }
  return svg-icon(icon-dict.at(type, default: icon-dict.note).text, color, baseline: baseline)
}

// --- Main Callout Renderer ---

/// The style used when neither the block nor a show rule asks for one.
#let default-style = "simple"

/// Picks the style for one callout. A style set on the block itself wins, then
/// a style set by a `callout-style` show rule, then the package default -- so a
/// show rule sets the document's default rather than overriding every block.
#let resolve-render-style(block-style, forced-style) = {
  if block-style != auto { return block-style }
  if forced-style != auto { return forced-style }
  default-style
}

#let render-callout(
  type: "note",
  style: "simple", // Options: "simple", "quarto", "github"
  title: auto,
  color: auto,
  icon: auto, // Accept custom content
  body,
) = {
  let c = resolve-color(style, type, color)
  let tiled = style == "edstem"

  let t = resolve-title(type, title)

  let ic = if icon != auto {
    icon
  } else if tiled {
    get-edstem-icon(type)
  } else {
    get-icon(style, type, c)
  }

  let title-style = if style == "quarto" or tiled {
    (fill: c.darken(10%), weight: "bold")
  } else if style == "github" {
    (fill: c, weight: "bold")
  } else {
    (fill: c, weight: "bold", size: 1.1em)
  }

  shell(
    style,
    c,
    ic,
    t,
    body,
    title-style: title-style,
    header-fill: c.transparentize(90%), // tinted header background
    // In "edstem" the tint covers the whole block; the other styles leave the
    // area behind the body unfilled.
    body-fill: if tiled { c.transparentize(90%) } else { none },
  )
}

/// Provides the base callout component for rendering stylized blocks.
///
/// The callout is wrapped in a `figure` so that it can be counted and
/// referenced. The visible body is pre-rendered, so a callout still looks right
/// when the document has no `callout-style` show rule; the arguments are stashed
/// in the supplement as `metadata` so that `callout-style` can re-render it with
/// a different style or a numbered title. Content inside `metadata` is inert --
/// it is never laid out -- so labels and counters in the body fire exactly once.
///
/// - type (string): The category of the callout (e.g. \"note\", \"tip\", \"warning\", \"important\", \"caution\").
/// - style (string, auto): The visual style for this block (e.g. \"simple\", \"quarto\", \"github\", \"edstem\"). If auto, follows any `callout-style` show rule in scope, else the package default.
/// - title (content, auto): A custom title. If auto, inherits based on type.
/// - color (color, auto): The accent color of the callout block.
/// - icon (content, auto): A custom icon. If auto, uses the default built-in SVG.
/// - body (content): The main text or content of the callout.
#let callout(
  type: "note",
  style: auto,
  title: auto,
  color: auto,
  icon: auto,
  body,
) = {
  figure(
    kind: "callout-" + type,
    supplement: metadata((
      style: style,
      title: title,
      color: color,
      icon: icon,
      body: body,
    )),
    caption: none,
    placement: none,
    outlined: false,
    render-callout(
      type: type,
      style: resolve-render-style(style, auto),
      title: title,
      color: color,
      icon: icon,
      body,
    ),
  )
}

#let resolve-callout-options(supplement) = {
  // `body: none` marks "not one of our figures"; callers then fall back to `it.body`.
  let fallback = (style: auto, title: auto, color: auto, icon: auto, body: none)
  if supplement == none or type(supplement) != content { return fallback }
  if supplement.func() != metadata or type(supplement.value) != dictionary {
    return fallback
  }

  let v = supplement.value
  (
    style: v.at("style", default: fallback.style),
    title: v.at("title", default: fallback.title),
    color: v.at("color", default: fallback.color),
    icon: v.at("icon", default: fallback.icon),
    body: v.at("body", default: fallback.body),
  )
}

#let resolve-style(supplement) = resolve-callout-options(supplement).style

#let callout-ref-title(kind) = {
  let type = kind.slice("callout-".len())
  if type in callout-types { return resolve-title(type, auto) }
  return "Callout"
}

#let is-callout-kind(kind) = {
  type(kind) == str and kind.starts-with("callout-") and kind.slice("callout-".len()) in callout-types
}

#let callout-header(type, title, kind, numbering-rule, loc) = {
  if numbering-rule == none { return title }

  let nums = counter(figure.where(kind: kind)).at(loc)
  let prefix = [#resolve-title(type, auto) #numbering(numbering-rule, ..nums)]
  if title == auto or title == none { return prefix }

  [#prefix: #title]
}

#let render-callout-figure(it, type, forced-style: auto) = {
  let opts = resolve-callout-options(it.supplement)
  let style = resolve-render-style(opts.style, forced-style)
  let title = callout-header(type, opts.title, it.kind, it.numbering, it.location())
  let body = if opts.body == none { it.body } else { opts.body }
  render-callout(type: type, style: style, title: title, color: opts.color, icon: opts.icon, body)
}

#let sys-numbering = numbering

/// Applies styling and numbering rules to all callout variants within its scope.
/// Wrap your document with `#show: callout-style.with(...)` to use it globally.
///
/// - style (string, auto): The default visual style for callouts in scope. A block that sets its own `style` keeps it.
/// - numbering (string, function, none): Numbering format to apply to callout blocks automatically.
/// - body (content): The rest of your document.
#let callout-style(style: auto, numbering: none, body) = {
  // Each type gets its own show rules, wrapped from the inside out so that all
  // five end up in scope for `body`.
  let styled = callout-types.fold(body, (acc, t) => [
    #show figure.where(kind: "callout-" + t): set figure(numbering: numbering)
    #show figure.where(kind: "callout-" + t): it => {
      render-callout-figure(it, t, forced-style: style)
    }
    #acc
  ])

  [
    #show ref: it => {
      let el = it.element
      if el == none or el.func() != figure or not is-callout-kind(el.kind) {
        return it
      }

      let label = callout-ref-title(el.kind)
      if el.numbering == none {
        return link(el.location(), [#label])
      }

      let nums = counter(figure.where(kind: el.kind)).at(el.location())
      link(el.location(), [#label #sys-numbering(el.numbering, ..nums)])
    }

    #styled
  ]
}

/// Turns on callout styling and code-block styling in one show rule.
///
/// `#show: calloutly` is the whole setup; `.with(...)` forwards to both halves.
/// Callouts themselves need no show rule at all -- `#note[...]` renders on its
/// own straight after importing. Code blocks do need one, because a package
/// cannot install a `raw` show rule into a document that imports it.
///
/// - style (string, auto): The default style for callouts and code blocks. A callout that sets its own `style` keeps it.
/// - numbering (string, function, none): Numbering format for callout blocks.
/// - line-numbers (boolean): Whether code blocks show line numbers.
/// - body (content): The rest of your document.
#let calloutly(style: auto, numbering: none, line-numbers: false, body) = [
  #show: callout-style.with(style: style, numbering: numbering)
  // Raw fences have nowhere to carry a per-block style, so code blocks always
  // take the show rule's; `auto` there just means the package default.
  #show: code-block-style.with(
    style: resolve-render-style(auto, style),
    line-numbers: line-numbers,
  )
  #body
]

/// Renders a generic note callout.
#let note(..args, body) = callout(type: "note", ..args, body)
/// Renders a helpful tip callout.
#let tip(..args, body) = callout(type: "tip", ..args, body)
/// Renders a warning callout to highlight potential issues.
#let warning(..args, body) = callout(type: "warning", ..args, body)
/// Renders an important callout for critical information.
#let important(..args, body) = callout(type: "important", ..args, body)
/// Renders a caution callout to advise careful action.
#let caution(..args, body) = callout(type: "caution", ..args, body)
/// Renders a success callout to confirm something worked.
#let success(..args, body) = callout(type: "success", ..args, body)
/// Renders an error callout to report a failure.
#let error(..args, body) = callout(type: "error", ..args, body)
