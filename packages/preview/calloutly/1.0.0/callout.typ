// callout.typ

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

#let resolve-color(style, type, custom-color) = {
  if custom-color != auto { return custom-color }
  

  return colors.at(type, default: rgb("#4472c4"))
  
}

#let resolve-title(type, custom-title) = {
  if custom-title != auto { return custom-title }
  return upper(type.slice(0, 1)) + type.slice(1)
}

#let get-icon(type, color) = {
  let svg-string = icons.at(type, default: icons.note).text.replace("currentColor", color.to-hex())
  return box(image(bytes(svg-string), height: 1em), baseline: 20%)
}

// --- Main Callout Renderer ---

#let render-callout(
  type: "note",
  style: "quarto", // Options: "simple", "quarto"
  title: auto,
  color: auto,
  icon: auto, // Accept custom content
  body
) = {
  let c = resolve-color(style, type, color)
  let t = resolve-title(type, title)
  let ic = if icon != auto { icon } else { get-icon(type, c) }
  
  if style == "simple" {
    block(
      width: 100%,
      stroke: (left: 0.25em + c),
      inset: (x: 1em, y: 0.8em), // matched spacing
      radius: 4pt,

      [
        #set align(start)
        #text(fill: c, weight: "bold", size: 1.1em)[#ic #h(0.2em) #t]
        #v(0.5em, weak: true)
        #body
      ]
    )
  } else if style == "quarto" {
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
  } else {
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
}

// --- Figure-backed Callout API ---

// Emit a marker `figure` element so users can target callouts with show rules.
#let callout(
  type: "note",
  style: "quarto",
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
  link(el.location(), [#label #numbering(el.numbering, ..nums)])
}

// Convenience helper for applying both style and numbering to all callout variants.
// Use it as a show-rule transform, for example:
// #show: callout-style.with(style: "simple", numbering: "1")
#let callout-style(style: "quarto", numbering: none, body) = [
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

  #body
]

// figure numbering is enabled by default so we override that here
#show figure.where(kind: "callout-note"): set figure(numbering: none)
#show figure.where(kind: "callout-tip"): set figure(numbering: none)
#show figure.where(kind: "callout-warning"): set figure(numbering: none)
#show figure.where(kind: "callout-important"): set figure(numbering: none)
#show figure.where(kind: "callout-caution"): set figure(numbering: none)


// Render the marker figures into final callout blocks.
// These are the default rendering rules when callout-style is NOT used.
// When callout-style IS used, those rules override these at the document level.
#show figure.where(kind: "callout-note"): it => {
  render-callout-figure(it, "note")
}

#show figure.where(kind: "callout-tip"): it => {
  render-callout-figure(it, "tip")
}

#show figure.where(kind: "callout-warning"): it => {
  render-callout-figure(it, "warning")
}

#show figure.where(kind: "callout-important"): it => {
  render-callout-figure(it, "important")
}

#show figure.where(kind: "callout-caution"): it => {
  render-callout-figure(it, "caution")
}

// --- Shorthand Helpers ---
#let note(..args, body) = callout(type: "note", ..args, body)
#let tip(..args, body) = callout(type: "tip", ..args, body)
#let warning(..args, body) = callout(type: "warning", ..args, body)
#let important(..args, body) = callout(type: "important", ..args, body)
#let caution(..args, body) = callout(type: "caution", ..args, body)
