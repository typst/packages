// One two-tone information card with a centered overlapping icon medallion.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

/// One Information Blocks card: numbered color band, dark text panel, circular icon badge.
/// This function draws a single card, not the source's six-card grid.
#let information-block-box(
  title: [],
  body: [],
  number: "01",
  icon: none,
  print-icon: none,
  width: 8.2cm,
  height: 5.25cm,
  direction: auto,
  colour: rgb("#F15F4B"),
  body-colour: rgb("#00243A"),
  title-colour: auto,
  text-colour: auto,
  number-colour: auto,
  title-size: 14pt,
  body-size: 7.8pt,
  number-size: 15pt,
  icon-size: 0.94cm,
  badge-size: 1.72cm,
  corner-radius: 0.22cm,
  body-offset-x: 0pt,
  body-offset-y: 0pt,
  icon-offset-x: 0pt,
  icon-offset-y: 0pt,
  number-offset-x: 0pt,
  number-offset-y: 0pt,
  title-offset-x: 0pt,
  title-offset-y: 0pt,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let rtl = if direction == auto { is-rtl() } else { direction == std.rtl }
  set text(dir: if rtl { std.rtl } else { std.ltr })

  let header-fill = if print-mode { luma(198) } else { colour }
  let content-fill = if print-mode { luma(82) } else { body-colour }
  let title-ink = if print-mode { white }
    else if title-colour != auto { title-colour }
    else { white }
  let copy-ink = if print-mode { white }
    else if text-colour != auto { text-colour }
    else { white }
  let number-ink = if print-mode { black }
    else if number-colour != auto { number-colour }
    else { rgb("#111111") }

  let base = box(width: width, height: height,
    radius: corner-radius, fill: header-fill, inset: 0pt)
  let lower-radius = (
    top-left: 0pt, top-right: 0pt,
    bottom-left: corner-radius, bottom-right: corner-radius,
  )
  let lower-panel = box(width: width, height: height * 0.734,
    radius: lower-radius, fill: content-fill, inset: 0pt)

  let number-x = if rtl { width * 0.80 } else { width * 0.045 }
  let number-box = box(width: width * 0.16, height: height * 0.15,
    align((if rtl { right } else { left }) + horizon,
      text(size: number-size, weight: "bold", fill: number-ink, number)))

  let title-box = box(width: width * 0.86, height: height * 0.15,
    align(center + horizon,
      text(size: title-size, weight: "bold", fill: title-ink, title)))
  let body-box = box(width: width * 0.88, height: height * 0.27,
    align(center + top, {
      set par(justify: false)
      text(size: body-size, fill: copy-ink, body)
    }))

  let outer-badge = circle(radius: badge-size / 2, fill: header-fill)
  let inner-size = badge-size * 0.88
  let inner-badge = circle(radius: inner-size / 2, fill: white)
  let icon-content = if print-mode and print-icon != none { print-icon }
    else if icon != none { icon }
    else { text(size: icon-size, weight: "bold", fill: black, [✦]) }
  let icon-box = box(width: inner-size, height: inner-size,
    align(center, icon-content))
  let badge-x = (width - badge-size) / 2
  let badge-y = height * 0.105
  let inner-x = (width - inner-size) / 2
  let inner-y = badge-y + (badge-size - inner-size) / 2
  let title-y = height * 0.505
  let body-y = height * 0.685

  box(width: width, height: height, inset: 0pt, {
    place(top + left, dx: 0pt, dy: 0pt, base)
    place(top + left, dx: 0pt, dy: height * 0.266, lower-panel)
    place(top + left, dx: (number-x) + number-offset-x, dy: (height * 0.070) + number-offset-y, number-box)
    place(top + left, dx: badge-x, dy: badge-y, outer-badge)
    place(top + left, dx: inner-x, dy: inner-y, inner-badge)
    place(top + left, dx: (inner-x) + icon-offset-x, dy: (inner-y) + icon-offset-y, icon-box)
    place(top + left, dx: (width * 0.07) + title-offset-x, dy: (title-y) + title-offset-y, title-box)
    place(top + left, dx: (width * 0.06) + body-offset-x, dy: (body-y) + body-offset-y, body-box)
  })
}
