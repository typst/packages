#import "../core/rnd.typ": *
#import "sweeps.typ": *

#let sidebar-button-color-state = state("sidebar-button-color-state", 256)
#let sidebar-button-index-state = state("sidebar-button-index-state", 0)

#let sidebar-button(height, width, color: none, elem-text: none) = {
  context {
    let theme = state("theme-state").get()
    set text(fill: theme.elem-fg)

    let sel-color
    if color == none {
      sidebar-button-color-state.update(curr => next(curr))
      sel-color = theme.accent.at("a-" + str(pick10(sidebar-button-color-state.get())))
    } else {
      sel-color = color
    }

    let sel-text
    if elem-text == none {
      sel-text = random-string(1, sidebar-button-color-state.get())
    } else {
      sel-text = elem-text
    }

    box(height: height, width: width, fill: sel-color, inset: 5pt, align(end + bottom, sel-text))
  }
}

#let sidebar-bar(
  height,
  width,
  page-width,
  button-texts: (),
) = {
  context {
    let theme = state("theme-state").get()
    set text(fill: theme.elem-fg)

    box(
      // stroke: (paint: green),
      width: page-width,
      height: height + 5pt,
      [
        // Top Sweep
        #context {
          // Select a new color for top sweep
          sidebar-button-color-state.update(curr => next(curr))
          let sel-color-top = theme.accent.at("a-" + str(pick10(sidebar-button-color-state.get())))

          top-left-sweep(height / 2, width, sel-color-top, sweep-text: button-texts.at(
            sidebar-button-index-state.get(),
            default: random-string(1, sidebar-button-color-state.get()),
          ))

          sidebar-button-index-state.update(c => c + 1)
        }
        #context {
          // Select a new color for bottom sweep
          sidebar-button-color-state.update(curr => next(curr))
          let sel-color-bottom = theme.accent.at("a-" + str(pick10(sidebar-button-color-state.get())))

          place(
            bottom + left,
            bottom-left-sweep(height / 2, width, sel-color-bottom, sweep-text: button-texts.at(
              sidebar-button-index-state.get(),
              default: random-string(1, sidebar-button-color-state.get()),
            )),
          )

          sidebar-button-index-state.update(c => c + 1)
        }
        // Top Sweep extending button
        #context {
          place(
            top + left,
            dy: height / 3,
            dx: (width + width / 1.5) + 5pt,
            sidebar-button(height / 6, width - 5pt, elem-text: button-texts.at(
              sidebar-button-index-state.get(),
              default: random-string(1, sidebar-button-color-state.get()),
            )),
          )
          sidebar-button-index-state.update(c => c + 1)
        }
        // Top Sweep extending bar
        #context {
          // Select a new color
          let sel-color = theme.accent.at("a-" + str(pick10(sidebar-button-color-state.get())))

          place(
            top + left,
            dy: height / 3 + height / 12,
            dx: (width * 2 + width / 1.5) + 5pt,
            box(
              fill: sel-color,
              width: if page-width < 600pt {
                page-width - (width * 2 + width / 1.5) - 5pt
              } else {
                450pt - (width * 2 + width / 1.5) - 5pt
              },
              height: height / 12,
            ),
          )
        }
        #context {
          place(
            bottom + left,
            dy: -height / 3,
            dx: (width + width / 1.5) + 5pt,
            sidebar-button(height / 6, width - 5pt, elem-text: button-texts.at(
              sidebar-button-index-state.get(),
              default: random-string(1, sidebar-button-color-state.get()),
            )),
          )
          sidebar-button-index-state.update(c => c + 1)
        }
        #context {
          // Select a new color
          let sel-color = theme.accent.at("a-" + str(pick10(sidebar-button-color-state.get())))

          place(
            bottom + left,
            dy: -height / 3 - height / 12,
            dx: (width * 2 + width / 1.5) + 5pt,
            box(
              fill: sel-color,
              width: if page-width < 600pt {
                page-width - (width * 2 + width / 1.5) - 5pt
              } else {
                450pt - (width * 2 + width / 1.5) - 5pt
              },
              height: height / 12,
            ),
          )
        }
        #if page-width >= 600pt {
          let n = calc.floor((page-width - 450pt) / (width + 5pt))
          let rem = page-width - (450pt + n * (width + 5pt) + 5pt)
          for i in range(n) {
            context {
              place(
                bottom + left,
                dy: -height / 3,
                dx: 450pt + (i * (width + 5pt)) + 5pt,
                sidebar-button(height / 6, width, elem-text: button-texts.at(
                  sidebar-button-index-state.get(),
                  default: random-string(1, sidebar-button-color-state.get()),
                )),
              )
              sidebar-button-index-state.update(c => c + 1)
            }
            context {
              place(
                top + left,
                dy: height / 3,
                dx: 450pt + (i * (width + 5pt)) + 5pt,
                sidebar-button(height / 6, width, elem-text: button-texts.at(
                  sidebar-button-index-state.get(),
                  default: random-string(1, sidebar-button-color-state.get()),
                )),
              )
              sidebar-button-index-state.update(c => c + 1)
            }
          }
          context {
            place(
              bottom + right,
              dy: -height / 3,
              sidebar-button(height / 6, rem, elem-text: ""),
            )
          }
          context {
            place(
              top + right,
              dy: height / 3,
              sidebar-button(height / 6, rem, elem-text: ""),
            )
          }
        }
      ],
    )
  }
}

#let sidebar(top-height: none, button-texts: ()) = {
  if top-height == none {
    top-height = 3
  }

  let sidebar-bar-height = 200pt
  let sidebar-width = 100pt
  let initial-sidebar-button-height = 5pt
  let spacing = 5pt

  place(top + left, layout(size => {
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
        context {
          let sel-text = button-texts.at(
            sidebar-button-index-state.get(),
            default: random-string(1, sidebar-button-color-state.get()),
          )
          sidebar-button-index-state.update(c => c + 1)
          sidebar-button(40pt, sidebar-width, elem-text: sel-text)
        }
      }),
      sidebar-bar(sidebar-bar-height, sidebar-width, size.width, button-texts: button-texts),
      ..range(remaining-bottom-buttons).map(x => {
        context {
          let sel-text = button-texts.at(
            sidebar-button-index-state.get(),
            default: random-string(1, sidebar-button-color-state.get()),
          )
          sidebar-button-index-state.update(c => c + 1)
          sidebar-button(40pt, sidebar-width, elem-text: sel-text)
        }
      }),
      if last-button-height > 10pt {
        sidebar-button(last-button-height, sidebar-width, elem-text: "")
      },
    )
  }))
}
