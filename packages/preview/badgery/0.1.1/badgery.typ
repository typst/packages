#let base-fill-color = rgb("#F2F2F2")
#let base-stroke-color = rgb("#828282")
#let base-text-color = rgb("#333333")

#let badge-colors = (
  gray: (
    bg: rgb("#f9fafb"),
    border: rgb("#ebedee"),
    text: rgb("#4b5563")
  ),
  red: (
    bg: rgb("#fef2f2"),
    border: rgb("#fcdedd"),
    text: rgb("#b91c1b")
  ),
  yellow: (
    bg: rgb("#fefce8"),
    border: rgb("#f5e5c1"),
    text: rgb("#854d0f")
  ),
  green: (
    bg: rgb("#effdf4"),
    border: rgb("#cbebd3"),
    text: rgb("#17803d"),
  ),
  blue: (
    bg: rgb("#eff6ff"),
    border: rgb("#dae5fb"),
    text: rgb("#1c4ed8")
  ),
  purple: (
    bg: rgb("#faf5ff"),
    border: rgb("#efdffa"),
    text: rgb("#7e22ce")
  )
)

#let ui-action(content) = box(
  radius: 2pt,
  inset: 4pt,
  fill: base-fill-color,
  stroke: base-stroke-color,
  width: auto,
  height: auto,
  content
)


#let badge(content, fill: base-fill-color, stroke: base-stroke-color, text-color: base-text-color) = box(
  radius: 2pt,
  inset: 4pt,
  fill: fill,
  stroke: stroke,
  width: auto,
  height: auto,

  if type(content) == str {
    text(fill: text-color, content)
  } else {
    content
  }
)

#let badge-gray(content) = badge(content, fill: badge-colors.gray.bg, stroke: badge-colors.gray.border, text-color: badge-colors.gray.text)
#let badge-red(content) = badge(content, fill: badge-colors.red.bg, stroke: badge-colors.red.border, text-color: badge-colors.red.text)
#let badge-yellow(content) = badge(content, fill: badge-colors.yellow.bg, stroke: badge-colors.yellow.border, text-color: badge-colors.yellow.text)
#let badge-green(content) = badge(content, fill: badge-colors.green.bg, stroke: badge-colors.green.border, text-color: badge-colors.green.text)
#let badge-blue(content) = badge(content, fill: badge-colors.blue.bg, stroke: badge-colors.blue.border, text-color: badge-colors.blue.text)
#let badge-purple(content) = badge(content, fill: badge-colors.purple.bg, stroke: badge-colors.purple.border, text-color: badge-colors.purple.text)


#let menu-begin-stroke = (
  top: base-stroke-color,
  left: base-stroke-color,
  bottom: base-stroke-color,
  right: none,
)

#let menu-end-stroke = (
  top: base-stroke-color,
  right: base-stroke-color,
  bottom: base-stroke-color,
  left: none,
)

#let menu-middle-stroke = (
  top: base-stroke-color,
  right: none,
  bottom: base-stroke-color,
  left: none,
)

#let menu-path-output(height: 14.6pt, xStart: -2pt, xEnd: 5pt) = path(
  fill: base-fill-color,
  stroke: base-stroke-color,
  (xStart, 0pt),
  (0pt, 0pt),
  (xEnd, height / 2),
  (0pt, height),
  (xStart, height)
)


#let menu-path-input(height: 14.6pt) = path(
  fill: base-fill-color,
  stroke: base-stroke-color,
  closed: false,
  (9pt, 0pt),
  (0pt, 0pt),
  (4pt, height / 2),
  (0pt, height),
  (9pt,  height),
)

#let menu-begin(content) = context {
  let height = (measure(content).height + 8pt).abs
  return stack(
    dir: ltr,
    box(
      radius: 2pt,
      inset: 4pt,
      fill: base-fill-color,
      width: auto,
      height: auto,
      stroke: menu-begin-stroke,
      content
    ),
    menu-path-output(height: height)
  )
}

#let menu-end(content) = context {
  let height = (measure(content).height + 8pt).abs
  stack(
    dir: ltr,
    menu-path-input(height: height),
    move(
      dx: -4pt,
      dy: 0pt,
      box(
        radius: 2pt,
        inset: 4pt,
        fill: base-fill-color,
        stroke: menu-end-stroke,
        width: auto,
        height: auto,
        content
      )
    )
  )
}

#let menu-middle(content) = context {
  let height = (measure(content).height + 8pt).abs
  stack(
    dir: ltr,
    menu-path-input(height: height),
    move(
      dx: -4pt,
      dy: 0pt,
      box(
        radius: 2pt,
        inset: 4pt,
        fill: base-fill-color,
        stroke: menu-middle-stroke,
        width: auto,
        height: auto,
        content
      )
    ),
    menu-path-output(height: height, xStart: -6pt, xEnd: 5pt)
  )
}

#let menu(..items) = {
  let positionalItems = items.pos()
  let count = positionalItems.len()
  if(count == 1) {
    ui-action(positionalItems.at(0))
  }
  else {
    let mapped-items = ()
    for (idx, value) in positionalItems.enumerate() {
      if (idx + 1) == count {
        mapped-items.push(menu-end(value))
      } else if idx < 1 {
        mapped-items.push(menu-begin(value))
      } 
      else {
        mapped-items.push(menu-middle(value))
      }
    }
    stack(
      dir: ltr,
      .. mapped-items
    )
  }
}
