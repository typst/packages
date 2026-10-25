// One reusable summary card adapted from PresentationGO's Stacked Summary Cards.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

/// Draw one stacked-summary card with a side accent bar, heading, and supporting copy.
/// Only one card is emitted; the source's five-card stack is not reproduced.
#let stacked-summary-card-box(
  title: [SUMMARY HEADING],
  body: [],
  width: 8.4cm,
  height: auto,
  min-height: 2.35cm,
  direction: auto,
  body-direction: auto,
  colour: rgb("#F26455"),
  panel-colour: auto,
  title-colour: auto,
  text-colour: auto,
  shadow-colour: auto,
  title-size: 13pt,
  body-size: 9pt,
  accent-width: 0.17cm,
  text-inset: 0.30cm,
  title-y: 0.20cm,
  title-body-gap: 0.12cm,
  bottom-padding: 0.24cm,
  corner-radius: 0.04cm,
  shadow-offset: 0.08cm,
  shadow: true,
  body-offset-x: 0pt,
  body-offset-y: 0pt,
  title-offset-x: 0pt,
  title-offset-y: 0pt,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let rtl = if direction == auto { is-rtl() }
    else { direction == "rtl" or direction == std.rtl }
  let body-rtl = if body-direction == auto { rtl }
    else { body-direction == "rtl" or body-direction == std.rtl }
  let title-dir = if rtl { std.rtl } else { std.ltr }
  let body-dir = if body-rtl { std.rtl } else { std.ltr }

  let panel = if print-mode { white }
    else if panel-colour != auto { panel-colour }
    else { rgb("#F9FAFB") }
  let accent = if print-mode { luma(125) } else { colour }
  let title-ink = if print-mode { luma(22) }
    else if title-colour != auto { title-colour }
    else { rgb("#263343") }
  let body-ink = if print-mode { luma(58) }
    else if text-colour != auto { text-colour }
    else { rgb("#677283") }
  let edge = if print-mode { (paint: luma(188), thickness: 0.7pt) }
    else { (paint: rgb("#E7E9EC"), thickness: 0.45pt) }
  let shadow-ink = if shadow-colour != auto { shadow-colour } else { rgb("#38434C") }
  let shadow-fill = if print-mode { luma(225) } else { shadow-ink.transparentize(87%) }

  let content-width = width - accent-width - 2 * text-inset
  let title-content = text(dir: title-dir, size: title-size,
    weight: "bold", fill: title-ink, title)
  let body-content = {
    set par(leading: 0.28em, spacing: 0.30em, justify: false)
    text(dir: body-dir, size: body-size, fill: body-ink, body)
  }
  let title-measure = measure(title-content, width: content-width)
  let body-measure = measure(body-content, width: content-width)
  let title-height = calc.max(0.46cm, title-measure.height)
  let body-y = title-y + title-height + title-body-gap
  let measured-height = body-y + body-measure.height + bottom-padding
  let final-height = if height == auto { calc.max(min-height, measured-height) }
    else { calc.max(height, measured-height) }

  let card = rect(width: width, height: final-height, radius: corner-radius,
    fill: panel, stroke: edge, inset: 0pt)
  let drop = rect(width: width, height: final-height, radius: corner-radius,
    fill: shadow-fill, inset: 0pt)
  let stripe = rect(width: accent-width, height: final-height,
    fill: accent, stroke: none)
  let stripe-x = if rtl { width - accent-width } else { 0pt }
  let content-x = if rtl { text-inset } else { accent-width + text-inset }
  let title-align = if rtl { right + horizon } else { left + horizon }
  let body-align = if body-rtl { right + top } else { left + top }
  let title-box = box(width: content-width, height: title-height,
    align(title-align, title-content))
  let body-box = box(width: content-width,
    height: final-height - body-y - bottom-padding,
    align(body-align, body-content))

  box(width: width + shadow-offset, height: final-height + shadow-offset,
    inset: 0pt, {
      if shadow {
        place(top + left, dx: shadow-offset, dy: shadow-offset, drop)
      }
      place(top + left, dx: 0pt, dy: 0pt, card)
      place(top + left, dx: stripe-x, dy: 0pt, stripe)
      place(top + left, dx: (content-x) + title-offset-x, dy: (title-y) + title-offset-y, title-box)
      place(top + left, dx: (content-x) + body-offset-x, dy: (body-y) + body-offset-y, body-box)
    })
}
