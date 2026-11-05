// Three nested rounded tiers, moving from broad scope to core priority.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _ctc-card(
  levels, outer-width, outer-height, rtl, print-mode, dark, background,
  colours, middle-inset, middle-top, core-width, core-height,
  title-size, body-size, core-title-size, core-body-size,
  icon-size, core-icon-size, corner-radius, border-width,
  outer-title-x, outer-title-y, outer-title-width, outer-icon-y,
  outer-body-y, middle-title-y, middle-body-y, middle-icon-y,
  core-y, core-title-y, core-body-y,
) = {
  let outer-level = levels.at(0)
  let middle-level = levels.at(1)
  let core-level = levels.at(2)
  let outer-colour = if "colour" in outer-level { outer-level.at("colour") }
    else { colours.at(0) }
  let middle-colour = if "colour" in middle-level { middle-level.at("colour") }
    else { colours.at(1) }
  let core-colour = if "colour" in core-level { core-level.at("colour") }
    else { colours.at(2) }
  let frame-outer = if print-mode { (paint: luma(75), thickness: 0.9pt) }
    else { (paint: outer-colour, thickness: border-width) }
  let frame-middle = if print-mode { (paint: luma(120), thickness: 0.85pt) }
    else { (paint: middle-colour, thickness: border-width) }
  let core-fill = if print-mode { luma(155) } else { core-colour }
  let outer-ink = if print-mode { black } else if dark { white } else { rgb("#09283A") }
  let middle-ink = outer-ink
  let outer-body-ink = if print-mode { rgb("#222222") }
    else if dark { white } else { rgb("#555555") }
  let middle-body-ink = outer-body-ink
  let core-ink = if print-mode { white } else { white }
  let core-body-ink = core-ink
  let outer-frame = box(width: outer-width, height: outer-height,
    radius: corner-radius, fill: none, stroke: frame-outer, inset: 0pt)
  let middle-width = outer-width - 2 * middle-inset
  let middle-height = outer-height - middle-top - 0.42cm
  let middle-frame = box(width: middle-width, height: middle-height,
    radius: corner-radius * 0.88, fill: none, stroke: frame-middle, inset: 0pt)
  let core-panel = box(width: core-width, height: core-height,
    radius: 0.34cm, fill: core-fill, inset: 0pt)
  let title-align = if rtl { right } else { left }
  let outer-title = box(width: outer-title-width, height: 0.48cm,
    align(title-align + horizon,
      text(size: title-size, weight: "bold", fill: outer-ink, outer-level.at("title"))))
  let outer-body = box(width: outer-title-width, height: 0.96cm,
    align(title-align + top,
      text(size: body-size, fill: outer-body-ink, outer-level.at("body"))))
  let middle-title = box(width: outer-title-width - 0.22cm, height: 0.48cm,
    align(title-align + horizon,
      text(size: title-size, weight: "bold", fill: middle-ink, middle-level.at("title"))))
  let middle-body = box(width: outer-title-width - 0.22cm, height: 0.96cm,
    align(title-align + top,
      text(size: body-size, fill: middle-body-ink, middle-level.at("body"))))
  let core-text-width = core-width - 4.00cm
  let core-title = box(width: core-text-width, height: 0.48cm,
    align(title-align + horizon,
      text(size: core-title-size, weight: "bold", fill: core-ink, core-level.at("title"))))
  let core-body = box(width: core-text-width, height: core-height - core-body-y - 0.20cm,
    align(title-align + top,
      text(size: core-body-size, fill: core-body-ink, core-level.at("body"))))
  let outer-icon = if print-mode and "print-icon" in outer-level {
    outer-level.at("print-icon")
  } else if "icon" in outer-level { outer-level.at("icon") } else { [◎] }
  let middle-icon = if print-mode and "print-icon" in middle-level {
    middle-level.at("print-icon")
  } else if "icon" in middle-level { middle-level.at("icon") } else { [⊙] }
  let core-icon = if print-mode and "print-icon" in core-level {
    core-level.at("print-icon")
  } else if "icon" in core-level { core-level.at("icon") } else { [◇] }
  let outer-icon-x = if rtl { outer-width - outer-title-x - icon-size } else { outer-title-x }
  let text-start = outer-title-x + icon-size + 0.42cm
  let outer-text-x = if rtl { outer-width - text-start - outer-title-width } else { text-start }
  let mid-icon-x = outer-icon-x
  let mid-text-x = outer-text-x
  let core-left = (outer-width - core-width) / 2
  let core-icon-x = if rtl { core-width - 0.58cm - core-icon-size } else { 0.58cm }
  let core-text-x = if rtl { 0.55cm } else { 3.45cm }
  let divider-x = if rtl { core-width - 2.95cm } else { 2.80cm }
  let divider = box(width: 0.045cm, height: core-height - 0.88cm,
    fill: if print-mode { luma(230) } else { white.transparentize(8%) }, inset: 0pt)
  let middle-y = middle-top
  let core-icon-y = core-y + (core-height - core-icon-size) / 2
  let outer-panel = if background == auto {
    if print-mode { white } else if dark { rgb("#032A3B") } else { rgb("#F1F1F1") }
  } else { background }
  let erase-height = 1.16cm
  let notch-y = (outer-height - erase-height) / 2
  let dot-fill = if print-mode { luma(105) } else { outer-colour }

  box(width: outer-width, height: outer-height + 0.14cm, inset: 0pt, {
    place(top + left, dy: 0.07cm, outer-frame)
    // Erase short portions of both side rails, then replace with dash-and-dot marks.
    place(top + left, dx: -0.025cm, dy: notch-y,
      box(width: 0.12cm, height: erase-height, fill: outer-panel, inset: 0pt))
    place(top + left, dx: outer-width - 0.095cm, dy: notch-y,
      box(width: 0.12cm, height: erase-height, fill: outer-panel, inset: 0pt))
    for side-x in (0.025cm, outer-width - 0.075cm) {
      for i in range(5) {
        let dot-y = notch-y + 0.16cm + i * 0.18cm
        place(top + left, dx: side-x, dy: dot-y,
          circle(radius: if i == 2 { 0.065cm } else { 0.035cm }, fill: dot-fill))
      }
    }
    place(top + left, dx: middle-inset, dy: middle-y, middle-frame)
    place(top + left, dx: core-left, dy: core-y, core-panel)

    place(top + left, dx: outer-icon-x, dy: outer-icon-y,
      box(width: icon-size, height: icon-size, align(center, outer-icon)))
    place(top + left, dx: outer-text-x, dy: outer-title-y, outer-title)
    place(top + left, dx: outer-text-x, dy: outer-body-y, outer-body)

    place(top + left, dx: mid-icon-x, dy: middle-icon-y,
      box(width: icon-size, height: icon-size, align(center, middle-icon)))
    place(top + left, dx: mid-text-x, dy: middle-title-y, middle-title)
    place(top + left, dx: mid-text-x, dy: middle-body-y, middle-body)

    place(top + left, dx: core-left + core-icon-x, dy: core-icon-y,
      box(width: core-icon-size, height: core-icon-size, align(center, core-icon)))
    place(top + left, dx: core-left + divider-x, dy: core-y + 0.44cm, divider)
    place(top + left, dx: core-left + core-text-x, dy: core-y + core-title-y, core-title)
    place(top + left, dx: core-left + core-text-x, dy: core-y + core-body-y, core-body)
  })
}

/// Three nested rounded cards for broad context, a focused scope, and a core
/// priority. `levels:` is an outer-to-inner tuple of three dictionaries, each
/// with `title:` and `body:`; `icon:` and `print-icon:` are optional content.
/// RTL moves icons and aligns text on the opposite side. Set `dark: true` on a
/// dark slide. Print mode uses gray frames and a gray central card. If the
/// page uses a custom background, pass the matching `background:` color so
/// the outer-frame notches blend into it.
///
/// ```typ
/// #concentric-tier-cards(levels: (
///   (title: [Broad scope], body: [The wider context.]),
///   (title: [Focused scope], body: [A narrower focus.]),
///   (title: [Core priority], body: [The central action.]),
/// ))
/// ```
#let concentric-tier-cards(
  levels: (),
  width: auto,
  outer-width: 15.0cm,
  outer-height: 8.55cm,
  direction: auto,
  dark: false,
  background: auto,
  colours: (rgb("#F15E4B"), rgb("#789B71"), rgb("#F15E4B")),
  middle-inset: 1.45cm,
  middle-top: 2.32cm,
  core-width: 9.55cm,
  core-height: 2.65cm,
  title-size: 13.5pt,
  body-size: 8.1pt,
  core-title-size: 14pt,
  core-body-size: 7.6pt,
  icon-size: 1.02cm,
  core-icon-size: 1.35cm,
  corner-radius: 0.72cm,
  border-width: 0.105cm,
  outer-title-x: 3.52cm,
  outer-title-y: 0.36cm,
  outer-title-width: 8.55cm,
  outer-icon-y: 0.67cm,
  outer-body-y: 1.18cm,
  middle-title-y: 2.79cm,
  middle-body-y: 3.52cm,
  middle-icon-y: 3.05cm,
  core-y: 4.70cm,
  core-title-y: 0.42cm,
  core-body-y: 1.23cm,
  icon-offset-x: 0pt,
  icon-offset-y: 0pt,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let rtl = if direction == auto { is-rtl() } else { direction == std.rtl }
  set text(dir: if rtl { std.rtl } else { ltr })

  layout(avail => {
    if levels.len() < 3 { none } else {
      let total-width = if width == auto { avail.width }
        else if type(width) == ratio { avail.width * width }
        else { width }
      let frame-width = if outer-width == auto { calc.min(15cm, total-width * 0.82) }
        else { outer-width }
      let offset = (total-width - frame-width) / 2
      box(width: total-width, height: outer-height + 0.14cm, inset: 0pt, {
        place(top + left, dx: (offset) + icon-offset-x, dy: icon-offset-y, _ctc-card(
            levels, frame-width, outer-height, rtl, print-mode, dark, background,
            colours, middle-inset, middle-top, core-width, core-height,
            title-size, body-size, core-title-size, core-body-size,
            icon-size, core-icon-size, corner-radius, border-width,
            outer-title-x, outer-title-y, outer-title-width, outer-icon-y,
            outer-body-y, middle-title-y, middle-body-y, middle-icon-y,
            core-y, core-title-y, core-body-y,
          ))
      })
    }
  })
}
