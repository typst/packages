#import "../layout/geometry.typ": _deixis-region-bounds
#import "../core/html.typ": _deixis-html-anchor, _deixis-html-link
#import "../core/internal.typ": *
#import "pin.typ": *
#import "../core/native.typ": *

// Detached note measurement needs the native flow footprint, not page-position
// lookup or painting. A private label lets the shared renderer replace only
// this wrapper before its deferred geometry is evaluated.
#let _deixis-immediate-region(content, inline) = {
  if inline { [#box(width: 0pt, height: 0pt, content)<deixis-immediate-region>] }
  else { [#place(content)<deixis-immediate-region>] }
}

// HTML export has no page geometry or layers: keep the passage, followed by
// its return destinations and a marker linked to the body, like an inline mark.
#let _deixis-html-region-marker(sys, reg) = {
  let anchor = if reg.mark-lbl != none {
    [#metadata((internal-id: reg.internal-id))<deixis-mark-destination>#metadata(none)#reg.mark-lbl#_deixis-html-anchor(reg.mark-lbl)]
  }
  let origin = if reg.at("occurrence-owner", default: none) != none {
    [#metadata((owner: reg.occurrence-owner))<deixis-occurrence-destination>]
  }
  let marker = if _deixis-is-hidden(reg) or reg.marker-str == none { none } else {
    let style = _deixis-resolve-typed-param(sys, reg.at("marker-style", default: auto),
      "marker-style", "region-mark", component: "mark")
    let body-exists = reg.body-lbl != none and query(reg.body-lbl).len() > 0
    if body-exists { _deixis-html-link(reg.body-lbl, style(reg.marker-str)) } else { style(reg.marker-str) }
  }
  [#origin#anchor#marker]
}

// Shared Region Rendering Engine
#let _deixis-render-region-shape(
  sys,
  reg,
  pin-index,
  current-page,
  base-pos: none,
  draw-shape: true,
  draw-marker: true,
) = {
  let hidden = _deixis-is-hidden(reg)
  let draw-shape = draw-shape and not hidden
  let has-marker = draw-marker and (reg.mark-lbl != none or reg.marker-str != none)
  let has-origin = draw-marker and reg.at("occurrence-owner", default: none) != none
  if not draw-shape and not has-marker and not has-origin { return none }
  let active-pins = _deixis-pins-for(pin-index, reg.pins)

  if active-pins.len() == 0 { return none }

  let bounds = _deixis-region-bounds(active-pins, current-page, padding: reg.styles.at("padding", default: 0pt))
  let first-page = bounds.first-page
  let last-page = bounds.last-page
  if reg.layer == "flow" and first-page != last-page {
    panic("deixis: Cannot render multi-page region with layer: \"flow\". Use \"foreground\" or \"background\".")
  }
  if current-page < first-page or current-page > last-page { return none }
  let min-x = bounds.left
  let max-x = bounds.right
  let min-y = bounds.top
  let max-y = bounds.bottom

  let box-w = max-x - min-x
  let box-h = max-y - min-y

  // Cross-page style adjustments
  let c-styles = reg.styles
  if first-page != last-page {
    let c-rad = deixis-utils.get-radius(reg.styles.at("radius", default: 0pt))
    let c-stroke = deixis-utils.get-stroke(reg.styles.at("stroke", default: none))

    if current-page == first-page {
      c-rad.bottom-left = 0pt
      c-rad.bottom-right = 0pt
      if c-stroke != none { c-stroke.bottom = none }
    } else if current-page == last-page {
      c-rad.top-left = 0pt
      c-rad.top-right = 0pt
      if c-stroke != none { c-stroke.top = none }
    } else {
      c-rad = (top-left: 0pt, top-right: 0pt, bottom-left: 0pt, bottom-right: 0pt)
      if c-stroke != none {
        c-stroke.top = none
        c-stroke.bottom = none
      }
    }
    c-styles.radius = c-rad
    c-styles.stroke = c-stroke
  }

  let active-shape-func = reg.at("shape-func", default: deixis-rect-region)
  let highlight-box = if draw-shape {
    _deixis-inherited-content(reg, context active-shape-func(width: box-w, height: box-h, ..c-styles))
  }

  let body-exists = has-marker and reg.marker-str != none and reg.body-lbl != none and query(reg.body-lbl).len() > 0

  let anchor = if current-page == first-page and reg.mark-lbl != none {
    [#metadata((internal-id: reg.internal-id))<deixis-mark-destination>#metadata(none)#reg.mark-lbl]
  } else { none }

  let mark-marker-style = _deixis-resolve-typed-param(
    sys,
    reg.at("marker-style", default: auto),
    "marker-style",
    "region-mark",
    component: "mark",
  )

  let marker = if has-marker { _deixis-inherited-content(reg, context {
    if hidden or reg.marker-str == none { anchor }
    else if body-exists { [#anchor#_std-link(reg.body-lbl)[#mark-marker-style(reg.marker-str)]] }
    else { [#anchor#mark-marker-style(reg.marker-str)] }
  }) }

  let c-mark-pos = reg.styles.at("marker-position", default: top + right)
  let pos-dict = if type(c-mark-pos) == dictionary { c-mark-pos } else { (align: c-mark-pos, dx: 0pt, dy: 0pt) }

  let m-align = pos-dict.at("align", default: top + left)

  let resolve-relative(val, base-len) = {
    if type(val) == length { return val }
    if type(val) == ratio { return val * base-len }
    if type(val) == relative { return val.length + (val.ratio * base-len) }
    return 0pt
  }

  let m-dx = resolve-relative(pos-dict.at("dx", default: 0pt), box-w)
  let m-dy = resolve-relative(pos-dict.at("dy", default: 0pt), box-h)

  // Coordinate Relativity
  let offset-x = min-x
  let offset-y = min-y
  if base-pos != none {
    offset-x -= deixis-utils.resolve-signed-len(base-pos.x)
    offset-y -= deixis-utils.resolve-signed-len(base-pos.y)
  }

  place(top + left, dx: offset-x, dy: offset-y, box(width: box-w, height: box-h, {
    if draw-shape { highlight-box }
    // One return destination for the whole occurrence, at its first painted
    // frame. It remains independent of marker visibility and public naming.
    if has-origin and current-page == first-page {
      place(top + left, [#metadata((owner: reg.occurrence-owner))<deixis-occurrence-destination>])
    }

    if draw-marker and marker != none {
      let m-size = measure(_deixis-inherited-content(reg, context {
        if hidden or reg.marker-str == none { [] } else { mark-marker-style(reg.marker-str) }
      }))
      let m-str = repr(m-align)

      let align-x = if "left" in m-str { -1 } else if "right" in m-str { 1 } else { 0 }
      let align-y = if "top" in m-str { -1 } else if "bottom" in m-str { 1 } else { 0 }

      let out-dx = (m-size.width / 2.0) * align-x + m-dx
      let out-dy = (m-size.height / 2.0) * align-y + m-dy

      place(m-align, dx: out-dx, dy: out-dy, marker)
    }
  }))
}

// Anonymous and registered regions use the same wrapper and padding contract.
#let _deixis-region-content(body, pins, padding, inline, prefix) = {
  if body == none {
    return (body: none, pins: pins,
      padding: deixis-utils.resolve-padding(if padding == "text" { text-padding } else { padding }))
  }
  // Four native corners also enclose rotated/skewed content. A diagonal pair
  // alone can miss the transformed left/right or top/bottom extrema.
  let corners = (("tl", 0%, 0%), ("tr", 100%, 0%), ("bl", 0%, 100%), ("br", 100%, 100%))
  let top-padding = if padding == "text" {
    (top: text-padding.top - measure([T]).height, bottom: text-padding.bottom, x: text-padding.x)
  } else { padding }
  let bottom-padding = if padding == "text" { text-padding } else { padding }
  let attachments = corners.map(((edge, dx, dy)) => {
    let name = if type(prefix) == location { (owner: prefix, edge: edge) } else { prefix + "-" + edge }
    (name, (dx: dx, dy: dy, padding: if dy == 0% { top-padding } else { bottom-padding }))
  })
  let rendered = _deixis-attach(body, inline: inline, pins: attachments)
  (body: rendered, pins: attachments.map(pair => pair.first()), padding: 0pt)
}
