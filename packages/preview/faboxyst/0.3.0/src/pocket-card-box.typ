// One reusable pocket-style information card, adapted from PresentationGO's Pocket Card Process.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

/// A single card with a raised colored pocket tab and a rounded center lip.
/// This is one reusable box, not the source's four-card process row.
#let pocket-card-box(
  title: [],
  body: [],
  icon: none,
  print-icon: none,
  width: 4.7cm,
  card-height: 3.50cm,
  direction: auto,
  dark: false,
  colour: rgb("#F05D4E"),
  body-colour: auto,
  title-colour: auto,
  text-colour: auto,
  shadow-colour: auto,
  pocket-width: 2.55cm,
  pocket-top: 0.12cm,
  pocket-height: 0.82cm,
  lip-size: 0.84cm,
  card-top: 0.94cm,
  radius: 0.12cm,
  inset-x: 0.32cm,
  icon-size: 0.46cm,
  icon-y: 0.25cm,
  title-y: 1.68cm,
  body-y: 2.28cm,
  title-size: 11pt,
  body-size: 8.5pt,
  body-copy-height: 1.88cm,
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

  let tab-fill = if print-mode { luma(174) } else { colour }
  let card-fill = if print-mode { luma(249) }
    else if body-colour != auto { body-colour }
    else { white }
  let heading-ink = if print-mode { black }
    else if title-colour != auto { title-colour }
    else { rgb("#202020") }
  let copy-ink = if print-mode { luma(35) }
    else if text-colour != auto { text-colour }
    else { rgb("#707070") }
  let rule-ink = if print-mode { luma(110) } else { luma(175) }
  let shadow-ink = if print-mode { luma(225) }
    else if shadow-colour != auto { shadow-colour }
    else if dark { rgb("#000000").transparentize(72%) }
    else { rgb("#31373D").transparentize(82%) }
  let icon-content = if print-mode and print-icon != none { print-icon }
    else if icon == none {
      text(size: icon-size, weight: "bold", fill: if print-mode { black } else { white }, [✦])
    } else { icon }
  let card-width = width
  let total-height = card-top + card-height
  let pocket-x = (width - pocket-width) / 2
  let lip-y = card-top - lip-size / 2
  let icon-box = box(width: icon-size, height: icon-size,
    align(center + horizon, icon-content))
  let pocket-band = box(width: pocket-width, height: pocket-height,
    radius: (top-left: 0.46cm, top-right: 0.46cm, bottom-left: 0pt, bottom-right: 0pt),
    fill: tab-fill, inset: 0pt)
  let card-shadow = box(width: card-width, height: card-height,
    radius: radius, fill: shadow-ink, inset: 0pt)
  let card = box(width: card-width, height: card-height,
    radius: radius, fill: card-fill, inset: 0pt)
  let lip = ellipse(width: lip-size, height: lip-size, fill: tab-fill, inset: 0pt)
  let heading = box(width: width - 2 * inset-x, height: 0.46cm,
    align(center + horizon,
      text(size: title-size, weight: "bold", fill: heading-ink, title)))
  let copy = box(width: width - 2 * inset-x, height: body-copy-height,
    align(center + horizon,
      text(size: body-size, fill: copy-ink, body)))

  box(width: width + 0.08cm, height: total-height + 0.08cm, inset: 0pt, {
    place(top + left, dx: 0.06cm, dy: card-top + 0.07cm, card-shadow)
    place(top + left, dx: 0pt, dy: card-top, card)
    // The pocket lip is a fine line revealed on either side of the tab.
    place(top + left, line(start: (0.16cm, card-top + 0.20cm), end: (pocket-x, card-top + 0.20cm),
      stroke: (paint: rule-ink, thickness: 0.55pt)))
    place(top + left, line(start: (pocket-x + pocket-width, card-top + 0.20cm), end: (width - 0.16cm, card-top + 0.20cm),
      stroke: (paint: rule-ink, thickness: 0.55pt)))
    place(top + left, dx: pocket-x, dy: pocket-top, pocket-band)
    place(top + left, dx: (width - lip-size) / 2, dy: lip-y, lip)
    place(top + left, dx: ((width - icon-size) / 2) + icon-offset-x, dy: (icon-y) + icon-offset-y, icon-box)
    place(top + left, dx: (inset-x) + title-offset-x, dy: (title-y) + title-offset-y, heading)
    place(top + left, dx: (inset-x) + body-offset-x, dy: (body-y) + body-offset-y, copy)
  })
}
