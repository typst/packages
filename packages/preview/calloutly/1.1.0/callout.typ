#import "code-callout.typ" : *
// --- Color Palettes ---
#let colors = (
  note: rgb("#0969da"),
  tip: rgb("#2e8540"),
  important: rgb("#cc0000"), // Red for important
  warning: rgb("#d97706"), // Deeper orange for warning
  caution: rgb("#fd7e14") // Lighter orange for caution
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
)

// --- Helper Functions ---

// --- GitHub Theme Data ---
#let github-colors = (
  note: rgb("#0969da"),
  tip: rgb("#1a7f37"),
  important: rgb("#8250df"),
  warning: rgb("#9a6700"),
  caution: rgb("#d1242f"),
)

#let github-icons = (
  note: `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16" width="16" height="16" fill="currentColor"><path d="M0 8a8 8 0 1 1 16 0A8 8 0 0 1 0 8Zm8-6.5a6.5 6.5 0 1 0 0 13 6.5 6.5 0 0 0 0-13ZM6.5 7.75A.75.75 0 0 1 7.25 7h1a.75.75 0 0 1 .75.75v2.75h.25a.75.75 0 0 1 0 1.5h-2a.75.75 0 0 1 0-1.5h.25v-2h-.25a.75.75 0 0 1-.75-.75ZM8 6a1 1 0 1 1 0-2 1 1 0 0 1 0 2Z"/></svg>`,
  tip: `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16" width="16" height="16" fill="currentColor"><path d="M8 1.5c-2.363 0-4 1.69-4 3.75 0 .984.424 1.625.984 2.304l.214.253c.223.264.47.556.673.848.284.411.537.896.621 1.49a.75.75 0 0 1-1.484.211c-.04-.282-.163-.547-.37-.847a8.456 8.456 0 0 0-.542-.68c-.084-.1-.173-.205-.268-.32C3.201 7.75 2.5 6.766 2.5 5.25 2.5 2.31 4.863 0 8 0s5.5 2.31 5.5 5.25c0 1.516-.701 2.5-1.328 3.259-.095.115-.184.22-.268.319-.207.245-.383.453-.541.681-.208.3-.33.565-.37.847a.751.751 0 0 1-1.485-.212c.084-.593.337-1.078.621-1.489.203-.292.45-.584.673-.848.075-.088.147-.173.213-.253.561-.679.985-1.32.985-2.304 0-2.06-1.637-3.75-4-3.75ZM5.75 12h4.5a.75.75 0 0 1 0 1.5h-4.5a.75.75 0 0 1 0-1.5ZM6 15.25a.75.75 0 0 1 .75-.75h2.5a.75.75 0 0 1 0 1.5h-2.5a.75.75 0 0 1-.75-.75Z"/></svg>`,
  important: `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16" width="16" height="16" fill="currentColor"><path d="M0 1.75C0 .784.784 0 1.75 0h12.5C15.216 0 16 .784 16 1.75v9.5A1.75 1.75 0 0 1 14.25 13H8.06l-2.573 2.573A1.458 1.458 0 0 1 3 14.543V13H1.75A1.75 1.75 0 0 1 0 11.25Zm1.75-.25a.25.25 0 0 0-.25.25v9.5c0 .138.112.25.25.25h2a.75.75 0 0 1 .75.75v2.19l2.72-2.72a.749.749 0 0 1 .53-.22h6.5a.25.25 0 0 0 .25-.25v-9.5a.25.25 0 0 0-.25-.25Zm7 2.25v2.5a.75.75 0 0 1-1.5 0v-2.5a.75.75 0 0 1 1.5 0ZM9 9a1 1 0 1 1-2 0 1 1 0 0 1 2 0Z"/></svg>`,
  warning: `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16" width="16" height="16" fill="currentColor"><path d="M6.457 1.047c.659-1.234 2.427-1.234 3.086 0l6.082 11.378A1.75 1.75 0 0 1 14.082 15H1.918a1.75 1.75 0 0 1-1.543-2.575Zm1.763.707a.25.25 0 0 0-.44 0L1.698 13.132a.25.25 0 0 0 .22.368h12.164a.25.25 0 0 0 .22-.368Zm.53 3.996v2.5a.75.75 0 0 1-1.5 0v-2.5a.75.75 0 0 1 1.5 0ZM9 11a1 1 0 1 1-2 0 1 1 0 0 1 2 0Z"/></svg>`,
  caution: `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16" width="16" height="16" fill="currentColor"><path d="M4.47.22A.749.749 0 0 1 5 0h6c.199 0 .389.079.53.22l4.25 4.25c.141.14.22.331.22.53v6a.749.749 0 0 1-.22.53l-4.25 4.25A.749.749 0 0 1 11 16H5a.749.749 0 0 1-.53-.22L.22 11.53A.749.749 0 0 1 0 11V5c0-.199.079-.389.22-.53Zm.84 1.28L1.5 5.31v5.38l3.81 3.81h5.38l3.81-3.81V5.31L10.69 1.5ZM8 4a.75.75 0 0 1 .75.75v3.5a.75.75 0 0 1-1.5 0v-3.5A.75.75 0 0 1 8 4Zm0 8a1 1 0 1 1 0-2 1 1 0 0 1 0 2Z"/></svg>`,
)

#let resolve-color(style, type, custom-color) = {
  if custom-color != auto { return custom-color }
  
  let color-dict = if style == "github" { github-colors } else { colors }
  return color-dict.at(type, default: rgb("#4472c4"))
}

#let resolve-title(type, custom-title) = {
  if custom-title != auto { return custom-title }
  return upper(type.slice(0, 1)) + type.slice(1)
}

#let get-icon(style, type, color) = {
  let icon-dict = if style == "github" { github-icons } else { icons }
  let svg-string = icon-dict.at(type, default: icon-dict.note).text.replace("currentColor", color.to-hex())
  return box(image(bytes(svg-string), height: 1em), baseline: 20%)
}

// --- Main Callout Renderer ---

#let render-callout(
  type: "note",
  style: "simple", // Options: "simple", "quarto", "github"
  title: auto,
  color: auto,
  icon: auto, // Accept custom content
  body
) = {
  let c = resolve-color(style, type, color)
  let t = resolve-title(type, title)
  let ic = if icon != auto { icon } else { get-icon(style, type, c) }
  if style == "github" {
    // Custom/Fallback style
    block(
      width: 100%,
      stroke: (left: 3pt + c),
      inset: 1em,
      [
        #set align(start)
        #text(weight: "bold", fill: c)[#ic #h(0.2em) #t]
        #v(0.5em)
        #body
      ]
    )
  }
  else if style == "quarto" {
    block(
      width: 100%,
      stroke: (left: 4pt + c, rest: 1pt + rgb("#dee2e6")), // Quarto standard border
      inset: 0pt,
      radius: 4pt,
      clip: true,
      [
        #block(
          width: 100%,
          inset: (x: 1em, y: 0.5em),
          fill: c.lighten(90%), // Tinted header background
          [
            #set align(start)
            #text(fill: c.darken(10%), weight: "bold")[#box(baseline: 20%)[#ic] #h(0.3em) #t]
          ]
        )
        #block(
          width: 100%,
          inset: (x: 1em, top: 0.6em, bottom: 1em), // Precise body padding
          above: 0pt, // Remove native paragraph/block spacing
          [
            #set align(start)
            #body
          ]
        )
      ]
    )
  } else if style == "simple" {
    block(
      width: 100%,
      stroke: (left: 0.25em + c),
      inset: (x: 1em, y: 0.8em), // matched spacing
      radius: 4pt,

      [
        #set align(start)
        #text(fill: c, weight: "bold", size: 1.1em)[#ic #h(0.2em) #t]
        #v(1.0em, weak: true)
        #body
      ]
    )
  }
}

/// Provides the base callout component for rendering stylized blocks.
///
/// - type (string): The category of the callout (e.g. \"note\", \"tip\", \"warning\", \"important\", \"caution\").
/// - style (string): The visual style applied to the callout (e.g. \"simple\", \"quarto\", \"github\").
/// - title (content, none): A custom title. If none, inherits based on type.
/// - color (color, auto): The accent color of the callout block.
/// - icon (content, auto): A custom icon. If auto, uses the default built-in SVG.
/// - body (content): The main text or content of the callout.
#let callout(
  type: "note",
  style: "simple",
  title: none,
  color: auto,
  icon: auto,
  body,
) = {
  figure(
    kind: "callout-" + type,
    supplement: style,
    caption: metadata((
      title: title,
      color: color,
      icon: icon,
    )),
    gap: 0pt,
    placement: none,
    outlined: false,
    body,
  )
}

#let resolve-style(supplement) = {
  if type(supplement) == str {
    return supplement
  }

  "quarto"
}

#let resolve-callout-options(caption) = {
  if caption == none {
    return (title: none, color: auto, icon: auto)
  }

  let body = caption.body
  if body.func() == metadata and type(body.value) == dictionary {
    let v = body.value
    return (
      title: v.at("title", default: none),
      color: v.at("color", default: auto),
      icon: v.at("icon", default: auto),
    )
  }

}

#let callout-ref-title(kind) = {
  if kind == "callout-note" {
    return "Note"
  } else if kind == "callout-tip" {
    return "Tip"
  } else if kind == "callout-warning" {
    return "Warning"
  } else if kind == "callout-important" {
    return "Important"
  } else if kind == "callout-caution" {
    return "Caution"
  }

  return "Callout"
}

#let is-callout-kind(kind) = {
  kind == "callout-note" or kind == "callout-tip" or kind == "callout-warning" or kind == "callout-important" or kind == "callout-caution"
}

#let callout-header(type, caption, kind, numbering-rule, loc) = {
  if numbering-rule == none {
    if caption == none {
      return auto
    }
    return caption
  }

  let nums = counter(figure.where(kind: kind)).at(loc)
  let prefix = [#resolve-title(type, auto) #numbering(numbering-rule, ..nums)]
  if caption == none {
    return prefix
  }

  [#prefix: #caption]
}

#let render-callout-figure(it, type, forced-style: auto) = {
  let opts = resolve-callout-options(it.caption)
  let style = if forced-style == auto { resolve-style(it.supplement) } else { forced-style }
  let title = callout-header(type, opts.title, it.kind, it.numbering, it.location())
  render-callout(type: type, style: style, title: title, color: opts.color, icon: opts.icon, it.body)
}



#let sys-numbering = numbering

/// Applies styling and numbering rules to all callout variants within its scope.
/// Wrap your document with `#show: callout-style.with(...)` to use it globally.
///
/// - style (string): The visual style applied to all callouts (e.g. \"simple\", \"quarto\", \"github\").
/// - numbering (string, function, none): Numbering format to apply to callout blocks automatically.
/// - body (content): The rest of your document.
#let callout-style(style: "simple", numbering: none, body) = [
  #show figure.where(kind: "callout-note"): set figure(numbering: numbering)
  #show figure.where(kind: "callout-tip"): set figure(numbering: numbering)
  #show figure.where(kind: "callout-warning"): set figure(numbering: numbering)
  #show figure.where(kind: "callout-important"): set figure(numbering: numbering)
  #show figure.where(kind: "callout-caution"): set figure(numbering: numbering)

  #show figure.where(kind: "callout-note"): it => {
    render-callout-figure(it, "note", forced-style: style)
  }
  #show figure.where(kind: "callout-tip"): it => {
    render-callout-figure(it, "tip", forced-style: style)
  }
  #show figure.where(kind: "callout-warning"): it => {
    render-callout-figure(it, "warning", forced-style: style)
  }
  #show figure.where(kind: "callout-important"): it => {
    render-callout-figure(it, "important", forced-style: style)
  }
  #show figure.where(kind: "callout-caution"): it => {
    render-callout-figure(it, "caution", forced-style: style)
  }

  #show ref: it => {
    let el = it.element
    if el == none or el.func() != figure {
      return it
    }

    if not is-callout-kind(el.kind) {
      return it
    }

    let label = callout-ref-title(el.kind)
    if el.numbering == none {
      return link(el.location(), [#label])
    }

    let nums = counter(figure.where(kind: el.kind)).at(el.location())
    link(el.location(), [#label #sys-numbering(el.numbering, ..nums)])
  }

  #body
]

// figure numbering is enabled by default so we override that here
#show figure.where(kind: "callout-note"): set figure(numbering: none)
#show figure.where(kind: "callout-tip"): set figure(numbering: none)
#show figure.where(kind: "callout-warning"): set figure(numbering: none)
#show figure.where(kind: "callout-important"): set figure(numbering: none)
#show figure.where(kind: "callout-caution"): set figure(numbering: none)

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

