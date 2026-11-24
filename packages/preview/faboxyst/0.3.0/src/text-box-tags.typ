// One reusable notched text tag, adapted from PresentationGO's Text Boxes (Tags).
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

/// A single text tag: a rounded content panel points into a contrasting icon bay.
/// This is the reusable tag itself, not the source's multi-tag slide layout.
#let text-box-tag(
  title: [],
  body: [],
  icon: none,
  width: 8.4cm,
  height: 3.35cm,
  direction: auto,
  icon-side: "end",
  rounded: true,
  dark: false,
  colour: rgb("#0B4058"),
  icon-colour: auto,
  title-colour: auto,
  text-colour: auto,
  shadow-colour: auto,
  icon-panel-width: 2.55cm,
  pointer-depth: 0.52cm,
  pointer-height: 0.86cm,
  icon-size: 1.05cm,
  title-size: 11pt,
  body-size: 9pt,
  radius: 0.28cm,
  inset-x: 0.34cm,
  title-y: 0.32cm,
  body-y: 0.92cm,
  body-offset-x: 0pt,
  body-offset-y: 0pt,
  icon-offset-x: 0pt,
  icon-offset-y: 0pt,
  title-offset-x: 0pt,
  title-offset-y: 0pt,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let rtl = if direction == auto { is-rtl() } else { direction == std.rtl }
  set text(dir: if rtl { std.rtl } else { ltr })

  let icon-on-right = if icon-side == "end" { not rtl } else { rtl }
  let main-fill = if print-mode { luma(170) } else { colour }
  let icon-fill = if print-mode { luma(228) }
    else if icon-colour != auto { icon-colour }
    else { rgb("#F0A02B") }
  let heading-ink = if print-mode { black }
    else if title-colour != auto { title-colour }
    else { white }
  let body-ink = if print-mode { luma(25) }
    else if text-colour != auto { text-colour }
    else { white }
  let shadow-ink = if print-mode { luma(218) }
    else if shadow-colour != auto { shadow-colour }
    else { rgb("#18232A").transparentize(if dark { 72% } else { 84% }) }
  let corner = if rounded { radius } else { 0pt }
  let base-width = width - icon-panel-width
  let content-width = base-width - 2 * inset-x
  let icon-x = if icon-on-right { base-width } else { 0pt }
  let text-x = if icon-on-right { 0pt } else { icon-panel-width }
  let main-corners = if icon-on-right {
    (top-left: corner, bottom-left: corner, top-right: 0pt, bottom-right: 0pt)
  } else {
    (top-left: 0pt, bottom-left: 0pt, top-right: corner, bottom-right: corner)
  }
  let icon-corners = if icon-on-right {
    (top-left: 0pt, bottom-left: 0pt, top-right: corner, bottom-right: corner)
  } else {
    (top-left: corner, bottom-left: corner, top-right: 0pt, bottom-right: 0pt)
  }
  let icon-content = if icon == none { text(size: icon-size, weight: "bold", [✦]) } else { icon }
  let tag-shadow = box(width: width, height: height, radius: corner,
    fill: shadow-ink, inset: 0pt)
  let main-panel = box(width: base-width, height: height,
    radius: main-corners, fill: main-fill, inset: 0pt)
  let icon-panel = box(width: icon-panel-width, height: height,
    radius: icon-corners, fill: icon-fill, inset: 0pt)
  let heading = box(width: content-width, height: 0.42cm,
    align(center + horizon,
      text(size: title-size, weight: "bold", fill: heading-ink, title)))
  let copy = box(width: content-width, height: height - body-y - 0.20cm,
    align(center + horizon,
      text(size: body-size, fill: body-ink, body)))
  let tip-y = (height - pointer-height) / 2
  let tip = if icon-on-right {
    polygon(fill: main-fill, stroke: none,
      (base-width - 0.02cm, tip-y),
      (base-width + pointer-depth, height / 2),
      (base-width - 0.02cm, tip-y + pointer-height))
  } else {
    polygon(fill: main-fill, stroke: none,
      (icon-panel-width + 0.02cm, tip-y),
      (icon-panel-width - pointer-depth, height / 2),
      (icon-panel-width + 0.02cm, tip-y + pointer-height))
  }
  let icon-box = box(width: icon-panel-width, height: height,
    align(center + horizon, icon-content))

  box(width: width, height: height + 0.08cm, inset: 0pt, {
    place(top + left, dx: 0.06cm, dy: 0.08cm, tag-shadow)
    place(top + left, dx: (icon-x) + icon-offset-x, dy: (0pt) + icon-offset-y, icon-panel)
    place(top + left, dx: text-x, dy: 0pt, main-panel)
    place(top + left, tip)
    place(top + left, dx: (icon-x) + icon-offset-x, dy: (0pt) + icon-offset-y, icon-box)
    place(top + left, dx: (text-x + inset-x) + title-offset-x, dy: (title-y) + title-offset-y, heading)
    place(top + left, dx: (text-x + inset-x) + body-offset-x, dy: (body-y) + body-offset-y, copy)
  })
}
