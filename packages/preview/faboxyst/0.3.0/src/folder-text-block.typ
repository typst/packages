// One reusable, editable-style folder card: raised file tab, accent lip, and split lower panel.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

/// A single folder-shaped text block with a tab silhouette, accent lip, number, icon and copy.
/// This is one reusable block, not the source's four-card grid.
#let folder-text-block(
  title: [],
  body: [],
  icon: none,
  print-icon: none,
  number: none,
  width: 7cm,
  height: 4.55cm,
  direction: auto,
  dark: false,
  colour: rgb("#F3A21B"),
  body-colour: auto,
  tab-colour: auto,
  icon-panel-colour: auto,
  title-colour: auto,
  text-colour: auto,
  shadow-colour: auto,
  left-column: auto,
  content-top: 2.17cm,
  header-y: 0.57cm,
  header-height: 0.50cm,
  badge-size: 1.05cm,
  radius: 0.20cm,
  inset-x: 0.24cm,
  icon-size: 1.12cm,
  title-size: 14pt,
  number-size: 18pt,
  body-size: 6.5pt,
  body-y: 2.45cm,
  body-height: 2.00cm,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let rtl = if direction == auto { is-rtl() } else { direction == std.rtl }
  set text(dir: if rtl { std.rtl } else { ltr })

  let column-width = if left-column == auto { width / 3 } else { left-column }
  let top-fill = if print-mode { luma(246) }
    else if tab-colour != auto { tab-colour }
    else { colour.lighten(82%) }
  let body-fill = if print-mode { luma(208) }
    else if body-colour != auto { body-colour }
    else { colour }
  let icon-fill = if print-mode { luma(226) }
    else if icon-panel-colour != auto { icon-panel-colour }
    else { colour.lighten(42%) }
  let stripe-fill = if print-mode { luma(166) } else { colour }
  let heading-ink = if print-mode { black }
    else if title-colour != auto { title-colour }
    else { rgb("#171717") }
  let copy-ink = if print-mode { luma(25) }
    else if text-colour != auto { text-colour }
    else { rgb("#302A22") }
  let badge-fill = if print-mode { luma(88) } else { rgb("#65584E") }
  let badge-ink = white
  let shadow-ink = if print-mode { luma(218) }
    else if shadow-colour != auto { shadow-colour }
    else if dark { rgb("#000000").transparentize(70%) }
    else { rgb("#27313A").transparentize(72%) }

  // The top contour follows the supplied PPTX's folder shoulder: a raised tab
  // on the leading edge, two smooth curves, then the recessed top of the body.
  let shoulder-y = 0.494 * content-top
  let top-points = (
    (0.410 * width, shoulder-y),
    (0.39467 * width, 0.48896 * content-top),
    (0.38039 * width, 0.47453 * content-top),
    (0.36744 * width, 0.45171 * content-top),
    (0.35613 * width, 0.42150 * content-top),
    (0.34673 * width, 0.38492 * content-top),
    (0.33955 * width, 0.34297 * content-top),
    (0.33487 * width, 0.29666 * content-top),
    (0.33300 * width, 0.24700 * content-top),
    (0.33146 * width, 0.19734 * content-top),
    (0.32703 * width, 0.15103 * content-top),
    (0.32003 * width, 0.10908 * content-top),
    (0.31075 * width, 0.07250 * content-top),
    (0.29950 * width, 0.04229 * content-top),
    (0.28659 * width, 0.01947 * content-top),
    (0.27232 * width, 0.00504 * content-top),
    (0.25700 * width, 0pt),
    (0.07600 * width, 0pt),
    (0.06068 * width, 0.00504 * content-top),
    (0.04641 * width, 0.01947 * content-top),
    (0.03350 * width, 0.04229 * content-top),
    (0.02225 * width, 0.07250 * content-top),
    (0.01297 * width, 0.10908 * content-top),
    (0.00597 * width, 0.15103 * content-top),
    (0.00154 * width, 0.19734 * content-top),
    (0pt, 0.24700 * content-top),
    (0pt, content-top),
    (width, content-top),
    (width, shoulder-y),
  )
  let mirror(point) = (width - point.at(0), point.at(1))
  let mirrored-top = if rtl {
    (mirror(top-points.at(0)), mirror(top-points.at(1)),
     mirror(top-points.at(2)), mirror(top-points.at(3)),
     mirror(top-points.at(4)), mirror(top-points.at(5)),
     mirror(top-points.at(6)), mirror(top-points.at(7)),
     mirror(top-points.at(8)), mirror(top-points.at(9)),
     mirror(top-points.at(10)), mirror(top-points.at(11)),
     mirror(top-points.at(12)), mirror(top-points.at(13)),
     mirror(top-points.at(14)), mirror(top-points.at(15)),
     mirror(top-points.at(16)), mirror(top-points.at(17)),
     mirror(top-points.at(18)), mirror(top-points.at(19)),
     mirror(top-points.at(20)), mirror(top-points.at(21)),
     mirror(top-points.at(22)), mirror(top-points.at(23)),
     mirror(top-points.at(24)), mirror(top-points.at(25)),
     mirror(top-points.at(26)), mirror(top-points.at(27)),
     mirror(top-points.at(28)))
  } else { top-points }
  let folder-top = polygon(fill: top-fill, stroke: none, ..mirrored-top)
  let shadow-top = polygon(fill: shadow-ink, stroke: none, ..mirrored-top)
  let lower-radius = if rtl {
    (top-left: 0pt, top-right: 0pt, bottom-left: radius, bottom-right: radius)
  } else {
    (top-left: 0pt, top-right: 0pt, bottom-left: radius, bottom-right: radius)
  }
  let lower-shadow = box(width: width, height: height - content-top,
    radius: lower-radius, fill: shadow-ink, inset: 0pt)
  let lower-panel = box(width: width, height: height - content-top,
    radius: lower-radius, fill: body-fill, inset: 0pt)
  let stripe = box(width: width, height: header-height,
    radius: if rtl {
      (top-left: radius, top-right: 0pt, bottom-left: 0pt, bottom-right: 0pt)
    } else {
      (top-left: 0pt, top-right: radius, bottom-left: 0pt, bottom-right: 0pt)
    }, fill: stripe-fill, inset: 0pt)
  let icon-panel = box(width: column-width, height: height - content-top,
    radius: if rtl {
      (top-left: 0pt, top-right: 0pt, bottom-left: 0pt, bottom-right: radius)
    } else {
      (top-left: 0pt, top-right: 0pt, bottom-left: radius, bottom-right: 0pt)
    }, fill: icon-fill, inset: 0pt)
  let badge = if number == none { none } else {
    ellipse(width: badge-size, height: badge-size, fill: badge-fill, inset: 0pt)
  }
  let badge-text = if number == none { none } else {
    box(width: badge-size, height: badge-size,
      align(center + horizon,
        text(size: number-size, weight: "bold", fill: badge-ink, number)))
  }
  let icon-content = if print-mode and print-icon != none { print-icon }
    else if icon == none {
      text(size: icon-size, weight: "bold", fill: if print-mode { black } else { rgb("#65501F") }, [✦])
    } else { icon }
  let icon-box = box(width: column-width, height: height - content-top,
    align(center + horizon, icon-content))
  let heading-x = if rtl { 0pt } else { column-width - 0.10cm }
  let heading-width = width - column-width + 0.10cm
  let heading-y = header-y + header-height
  let heading = box(width: heading-width, height: content-top - heading-y,
    align(center + horizon,
      text(size: title-size, weight: "bold", fill: heading-ink, title)))
  let copy-width = width - column-width - 2 * inset-x
  let copy-x = if rtl { inset-x } else { column-width + inset-x }
  let copy = box(width: copy-width, height: body-height,
    align((if rtl { right } else { left }) + top,
      text(size: body-size, fill: copy-ink, body)))
  let badge-x = if rtl { width - column-width + (column-width - badge-size) / 2 }
    else { (column-width - badge-size) / 2 }
  let icon-x = if rtl { width - column-width } else { 0pt }

  box(width: width + 0.18cm, height: height + 0.16cm, inset: 0pt, {
    place(top + left, dx: 0.10cm, dy: content-top + 0.12cm, lower-shadow)
    place(top + left, dx: 0.10cm, dy: 0.12cm, shadow-top)
    place(top + left, dy: content-top, lower-panel)
    place(top + left, dy: header-y, stripe)
    place(top + left, folder-top)
    place(top + left, dx: icon-x, dy: content-top, icon-panel)
    if badge != none {
      place(top + left, dx: badge-x, dy: (content-top - badge-size) / 2, badge)
      place(top + left, dx: badge-x, dy: (content-top - badge-size) / 2, badge-text)
    }
    place(top + left, dx: icon-x, dy: content-top, icon-box)
    place(top + left, dx: heading-x, dy: heading-y, heading)
    place(top + left, dx: copy-x, dy: body-y, copy)
  })
}
