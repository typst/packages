#let sidebar-button-color-state = state("sidebar-button-color-state", 256)

#let m = 1238433
#let a = 16807
#let next = s => {
  let s2 = if s <= 0 { 1 } else if s >= m { calc.rem(s, m) } else { s }
  calc.rem(s2 * a, m)
}

#let next-rep(s, r) = {
  let fin = next(s)
  for i in range(r) {
    fin = next(fin)
  }
  fin
}

#let pick10 = s => {
  let x = next(s)
  calc.floor((s * 10) / m)
}

#let random-string(seed) = {
  let init = sidebar-button-color-state.get()
  init = next-rep(init, seed)
  let res = (
    str(calc.rem(next-rep(init, 1), 10))
      + "-"
      + str(calc.rem(next-rep(init, 2), 10))
      + str(calc.rem(next-rep(init, 3), 10))
      + str(calc.rem(next-rep(init, 4), 10))
      + str(calc.rem(next-rep(init, 5), 10))
      + str(calc.rem(next-rep(init, 6), 10))
      + str(calc.rem(next-rep(init, 7), 10))
  )
  res
}

#let sidebar-button(height, width, color: none, elem-text: none) = {
  context {
    let theme = state("theme-state").final()
    set text(font: "Antonio", size: 10.5pt, fill: theme.elem-fg)

    let sel-color
    if color == none {
      sidebar-button-color-state.update(curr => next(curr))
      sel-color = theme.accent.at("a-" + str(pick10(sidebar-button-color-state.get())))
    } else {
      sel-color = color
    }

    let sel-text
    if elem-text == none {
      sel-text = random-string(1)
    } else {
      sel-text = elem-text
    }

    box(height: height, width: width, fill: sel-color, inset: 5pt, align(end + bottom, sel-text))
  }
}

#let sidebar-bar(height, width, page-width, color-top: none, color-bottom: none, top-text: none, bottom-text: none) = {
  context {
    let theme = state("theme-state").final()
    set text(font: "Antonio", size: 10.5pt, fill: theme.elem-fg)

    box(
      // stroke: (paint: green),
      width: page-width,
      height: height + 5pt,
      [
        // Top Sweep
        #context {
          // Select a new color for top sweep
          let sel-color-top
          if color-top == none {
            sidebar-button-color-state.update(curr => next(curr))
            sel-color-top = theme.accent.at("a-" + str(pick10(sidebar-button-color-state.get())))
          } else {
            sel-color-top = color-top
          }

          // Select a text for top sweep
          let sel-top-text
          if top-text == none {
            sel-top-text = random-string(1)
          } else {
            sel-top-text = top-text
          }

          // Bottom Left rounded corner
          place(top + left, dy: -height / 6, box(
            clip: true,
            width: height / 1.5,
            height: height / 1.5,
            radius: height / 3,
            place(bottom + left, box(fill: sel-color-top, width: height / 3, height: height / 3)),
          ))
          // Right extending box
          place(top + left, dy: height / 3, dx: width, box(fill: sel-color-top, height: height / 6, width: width / 1.5))
          // Fill to right extending box
          place(top + left, dy: height / 3, dx: height / 3, box(
            fill: sel-color-top,
            height: height / 6,
            width: width - height / 3,
          ))
          // Fill for inner rounded corner
          place(top + left, dy: height * 3 / 12, dx: width, box(
            fill: sel-color-top,
            width: height / 12,
            height: height / 12,
          ))
          // Overlay for inner rounded corner
          place(top + left, dy: height / 6, dx: width, box(
            fill: theme.bg,
            width: height / 6,
            height: height / 6,
            radius: height / 12,
          ))
          // Fill to inner rounded corner
          place(top + left, dy: height / 6, dx: height / 6, box(
            fill: sel-color-top,
            height: height / 6,
            width: width - height / 6,
          ))
          // Top box
          place(top + left, box(
            fill: sel-color-top,
            width: width,
            height: height / 6,
            inset: 5pt,
            align(end + bottom, sel-top-text),
          ))
        }
        #context {
          // Select a new color for the bottom sweep
          let sel-color-bottom
          if color-bottom == none {
            sidebar-button-color-state.update(curr => next(curr))
            sel-color-bottom = theme.accent.at("a-" + str(pick10(sidebar-button-color-state.get())))
          } else {
            sel-color-bottom = color-bottom
          }

          // Select a text for the bottom sweep
          let sel-bottom-text
          if bottom-text == none {
            sel-bottom-text = random-string(2)
          } else {
            sel-bottom-text = bottom-text
          }

          // Bottom  box
          place(bottom + left, box(
            fill: sel-color-bottom,
            width: width,
            height: height / 6,
            inset: 5pt,
            align(end + bottom, sel-bottom-text),
          ))
          // Top left rounded corner
          place(
            bottom + left,
            dy: height / 6,
            box(
              clip: true,
              width: height / 1.5,
              height: height / 1.5,
              radius: height / 3,
              place(top + left, box(fill: sel-color-bottom, width: height / 3, height: height / 3)),
            ),
          )
          // Fill to inner rounded corner
          place(bottom + left, dy: -height / 6, dx: height / 6, box(
            fill: sel-color-bottom,
            height: height / 6,
            width: width - height / 6,
          ))
          // Right extending box
          place(bottom + left, dy: -height / 3, dx: width, box(
            fill: sel-color-bottom,
            height: height / 6,
            width: width / 1.5,
          ))
          // Fill to right extending box
          place(bottom + left, dy: -height / 3, dx: height / 3, box(
            fill: sel-color-bottom,
            height: height / 6,
            width: width - height / 3,
          ))
          // Fill for inner rounded corner
          place(bottom + left, dy: -height * 3 / 12, dx: width, box(
            fill: sel-color-bottom,
            width: height / 12,
            height: height / 12,
          ))
          // Overlay for inner rounded corner
          place(bottom + left, dy: -height / 6, dx: width, box(
            fill: theme.bg,
            width: height / 6,
            height: height / 6,
            radius: height / 12,
          ))
        }
        #context {
          place(
            top + left,
            dy: height / 3,
            dx: (width + width / 1.5) + 5pt,
            sidebar-button(height / 6, width - 5pt),
          )
        }
        #context {
          // Select a new color
          let sel-color
          if color-bottom == none {
            sidebar-button-color-state.update(curr => next(curr))
            sel-color = theme.accent.at("a-" + str(pick10(sidebar-button-color-state.get())))
          } else {
            sel-color = color-bottom
          }

          place(
            top + left,
            dy: height / 3 + height / 12,
            dx: (width * 2 + width / 1.5) + 5pt,
            box(
              fill: sel-color,
              width: page-width - (width * 2 + width / 1.5) - 5pt,
              height: height / 12,
            ),
          )
        }
        #context {
          place(
            bottom + left,
            dy: -height / 3,
            dx: (width + width / 1.5) + 5pt,
            sidebar-button(height / 6, width - 5pt),
          )
        }
        #context {
          // Select a new color
          let sel-color
          if color-bottom == none {
            sidebar-button-color-state.update(curr => next(curr))
            sel-color = theme.accent.at("a-" + str(pick10(sidebar-button-color-state.get())))
          } else {
            sel-color = color-bottom
          }

          place(
            bottom + left,
            dy: -height / 3 - height / 12,
            dx: (width * 2 + width / 1.5) + 5pt,
            box(
              fill: sel-color,
              width: page-width - (width * 2 + width / 1.5) - 5pt,
              height: height / 12,
            ),
          )
        }
      ],
    )
  }
}

#let sidebar(top-height: none) = {
  if top-height == none {
    top-height = 3
  }

  let sidebar-bar-height = 200pt
  let sidebar-width = 100pt
  let initial-sidebar-button-height = 5pt
  let spacing = 5pt

  layout(size => {
    let top-part-height = (initial-sidebar-button-height + spacing + (top-height * 45pt) + sidebar-bar-height + spacing)
    let remaining-bottom-buttons-height = (size.height - top-part-height)
    let remaining-bottom-buttons = calc.floor(
      remaining-bottom-buttons-height / 45pt,
    )

    let last-button-height = size.height - (top-part-height + (remaining-bottom-buttons * 45pt)) - spacing

    stack(
      dir: ttb,
      spacing: spacing,
      sidebar-button(initial-sidebar-button-height, sidebar-width, elem-text: ""),
      ..range(top-height).map(x => {
        sidebar-button(40pt, sidebar-width)
      }),
      sidebar-bar(sidebar-bar-height, sidebar-width, size.width),
      ..range(remaining-bottom-buttons).map(x => {
        sidebar-button(40pt, sidebar-width)
      }),
      if last-button-height > 10pt {
        sidebar-button(last-button-height, sidebar-width, elem-text: "")
      },
    )
  })
}
