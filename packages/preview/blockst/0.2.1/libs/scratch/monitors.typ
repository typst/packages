#import "options.typ": get-options

// Color palettes (copied from old library's colors.typ)
#let _colors-normal = (
  variables: (primary: rgb("#FF8C1A")),
  lists:     (primary: rgb("#FF661A"), tertiary: rgb("#E64D00")),
)
#let _colors-high-contrast = (
  variables: (primary: rgb("#FFA54C")),
  lists:     (primary: rgb("#FF9966"), tertiary: rgb("#E64D00")),
)
#let _colors-print = (
  variables: (primary: white),
  lists:     (primary: white, tertiary: black),
)

#let _get-colors(options) = {
  let theme = options.at("theme", default: "normal")
  if theme == "high-contrast" { _colors-high-contrast }
  else if theme == "print"    { _colors-print }
  else                        { _colors-normal }
}

// Variable monitor (visual display like in Scratch)
// ------------------------------------------------
#let variable-monitor(name: "Variable", value: 0) = context {
  let options = get-options()
  let colors = _get-colors(options)

  box(
    fill: rgb("#E6F0FF"),
    stroke: (paint: rgb("#CAD1D9"), thickness: 1pt),
    radius: 2pt,
    inset: (left: 6pt, right: 6pt, y: 2pt),
  )[
    #set text(size: 7.85pt, font: ("Helvetica Neue", "Helvetica", "Arial"), weight: "bold", fill: rgb("#575E75"))
    #grid(
      columns: (auto, auto),
      column-gutter: 7pt,
      align: left + horizon,
      name,
      rect(
        fill: colors.variables.primary,
        stroke: none,
        radius: 2pt,
        inset: (x: 3pt, y: 1.5pt),
        grid(
          columns: 1,
          align: center + horizon,
          box(width: 20pt, height: 0pt),
          text(fill: white, size: 10pt, weight: "bold", str(value)),
        ),
      ),
    )
  ]
}

// ------------------------------------------------
// List monitor (visual display like in Scratch)
// ------------------------------------------------
#let list-monitor(name: "List", items: (), width: 5.2cm, height: auto, length-label: auto) = context {
  let length-label = if length-label == auto { "Length" } else { length-label }
  let options = get-options()
  let colors = _get-colors(options)
  let theme = options.at("theme", default: "normal")
  let len = items.len()
  let item-text-color = if theme == "high-contrast" or theme == "print" { black } else { white }
  let spacer-height = if height == auto { 0pt } else { 1fr }
  let content-row-height = if height == auto { auto } else { 1fr }

  let bg-blue = rgb("#E6F0FF")
  let line-color = rgb("#CAD1D9")

  box(
    width: width,
    height: height,
    fill: bg-blue,
    stroke: (paint: line-color, thickness: 1pt),
    radius: 3pt,
    clip: true,
  )[
    #set text(font: ("Helvetica Neue", "Helvetica", "Arial"))
    #grid(
      columns: 1,
      rows: (15pt, auto, content-row-height, 15pt),
      rect(
        width: 100%,
        height: 100%,
        fill: white,
        stroke: (bottom: line-color + 2pt),
        inset: (x: 4pt, y: 0pt),
        align(center + horizon, text(fill: rgb("#575E75"), size: 8pt, weight: "bold", name)),
      ),
      box(
        width: 100%,
        clip: true,
        {
          let needs-scrollbar = false
          let available-h = 0pt
          let content-h = 0pt
          if type(height) == length {
            // Approx 20pt per row. Header and footer take 30pt.
            available-h = height - 30pt
            content-h = len * 20pt
            if content-h > available-h {
              needs-scrollbar = true
            }
          }
          let right-inset = if needs-scrollbar { 14pt } else { 4pt }

          let item-rows = items
            .enumerate()
            .map(((index, item)) => {
              rect(
                width: 100%,
                fill: bg-blue,
                stroke: none,
                inset: (left: -3pt, right: right-inset, top: 1.5pt, bottom: 1.5pt),
                grid(
                  columns: (12pt, 1fr),
                  column-gutter: 4pt,
                  align: (right + horizon, left + horizon),
                  text(fill: rgb("#575E75"), size: 9pt, weight: "bold", str(index + 1)),
                  rect(
                    width: 100%,
                    fill: colors.lists.primary,
                    stroke: colors.lists.tertiary + 1pt,
                    radius: 2pt,
                    inset: (x: 3pt, y: 3.5pt),
                    text(fill: item-text-color, size: 8pt, weight: 500, item),
                  ),
                ),
              )
            })

          stack(dir: ttb, ..item-rows)

          if needs-scrollbar {
            let thumb-h = calc.max(10pt, available-h * (available-h / content-h))
            // Track
            place(
              right + top,
              dx: -2pt,
              dy: 2pt,
              rect(
                width: 7pt,
                height: available-h - 4pt,
                fill: rgb("#DBE4F3"),
                radius: 3.5pt,
                stroke: none,
              ),
            )
            // Thumb
            place(
              right + top,
              dx: -2pt,
              dy: 2pt,
              rect(
                width: 7pt,
                height: thumb-h,
                fill: rgb("#6E737B"),
                radius: 3.5pt,
                stroke: none,
              ),
            )
          }
        },
      ),
      v(spacer-height),
      align(bottom, rect(
        width: 100%,
        height: 100%,
        fill: white,
        inset: (x: 2.5pt, y: 5pt),
        grid(
          columns: (auto, 1fr, auto),
          align: (left + horizon, center + horizon, right + horizon),
          text(fill: rgb("#575E75"), size: 8pt, weight: "bold", "+"),
          text(fill: rgb("#575E75"), size: 8pt, weight: "bold", length-label + ": " + str(len)),
          text(fill: rgb("#575E75"), size: 8pt, weight: "bold", "="),
        ),
      )),
    )
  ]
}
