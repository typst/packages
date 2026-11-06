// One reusable horizontal chevron text block adapted from the supplied
// PresentationGO reference. It is an individual segment, not a complete row.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _hcb-icon(size, ink, kind) = {
  let head = "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 96 96\" fill=\"none\" stroke=\"" + ink.to-hex() + "\" stroke-width=\"4.4\" stroke-linecap=\"round\" stroke-linejoin=\"round\">"
  let art = if kind == 0 {
    "<path d=\"M48 16a22 22 0 0 0-13 40c4 3 6 8 7 13h12c1-5 3-10 7-13a22 22 0 0 0-13-40Z M41 74h14M43 81h10M48 5v6M15 21l7 7M81 21l-7 7M7 48h10M79 48h10\"/>"
  } else if kind == 1 {
    "<path d=\"M12 78h72M20 73V53h12v20M42 73V37h12v36M64 73V20h12v53\"/>"
  } else if kind == 2 {
    "<circle cx=\"38\" cy=\"39\" r=\"17\"/><circle cx=\"64\" cy=\"61\" r=\"12\"/><path d=\"M38 14v8M38 56v8M13 39h8M55 39h8M20 21l6 6M50 51l6 6M20 57l6-6M50 27l6-6M64 42v7M64 73v7M45 61h7M76 61h7\"/>"
  } else {
    "<path d=\"M12 72a38 38 0 0 1 72 0M48 67l17-28M48 28v10M27 37l7 8M69 37l-7 8M17 54l9 3M79 54l-9 3M48 67v6\"/>"
  }
  image(bytes(head + art + "</svg>"), format: "svg", width: size, height: size)
}

#let _hcb-art(width, height, accent, tint, stripe, mirror) = {
  let flipped = if mirror { "<g transform=\"translate(1000 0) scale(-1 1)\">" } else { "<g>" }
  let svg = (
    "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 1000 160\" preserveAspectRatio=\"none\">"
    + flipped
    + "<rect x=\"2\" y=\"2\" width=\"996\" height=\"156\" rx=\"30\" fill=\"" + tint.to-hex() + "\"/>"
    + "<path d=\"M 30 2 H 230 L 160 80 L 230 158 H 30 Q 2 158 2 130 V 30 Q 2 2 30 2 Z\" fill=\"" + accent.to-hex() + "\"/>"
    + "<path d=\"M 230 2 H 260 L 190 80 L 260 158 H 230 L 160 80 Z\" fill=\"white\"/>"
    + "<path d=\"M 246 2 H 258 L 188 80 L 258 158 H 246 L 176 80 Z\" fill=\"" + stripe.to-hex() + "\"/>"
    + "</g></svg>"
  )
  image(bytes(svg), format: "svg", width: width, height: height)
}

/// One horizontal text-and-icon block with a layered chevron divider.
///
/// `chevron-side` selects the icon/cap end; `direction: auto` mirrors the
/// component for Arabic RTL. Use this function repeatedly to compose a row or
/// process yourself—the component itself is only one standalone segment.
#let horizontal-chevron-block(
  body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor.],
  icon: none,
  icon-style: 0,
  width: auto,
  height: 1.75cm,
  direction: auto,
  chevron-side: "start",
  accent-colour: rgb("#F05C4B"),
  tint-colour: auto,
  stripe-colour: auto,
  text-colour: auto,
  icon-colour: auto,
  icon-size: 0.88cm,
  body-size: 8pt,
  padding: 0.12cm,
  body-width: auto,
  text-offset-x: 0pt,
  text-offset-y: 0pt,
  icon-offset-x: 0pt,
  icon-offset-y: 0pt,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let rtl = if direction == auto { is-rtl() }
    else { direction == "rtl" or direction == std.rtl }
  if chevron-side != "start" and chevron-side != "end" {
    panic("chevron-side must be start or end")
  }
  if icon-style < 0 or icon-style > 3 { panic("icon-style must be between 0 and 3") }
  if height <= 0pt or icon-size <= 0pt or body-size <= 0pt or padding < 0pt {
    panic("height, icon-size, and body-size must be positive; padding cannot be negative")
  }
  let mirror = if chevron-side == "start" { rtl } else { not rtl }
  let main-colour = if print-mode { luma(150) } else { accent-colour }
  let light-colour = if print-mode { luma(226) }
    else if tint-colour == auto { accent-colour.lighten(56%) } else { tint-colour }
  let stripe = if print-mode { luma(172) }
    else if stripe-colour == auto { accent-colour.lighten(15%) } else { stripe-colour }
  let body-ink = if print-mode { luma(35) }
    else if text-colour == auto { rgb("#615E5C") } else { text-colour }
  let icon-ink = if print-mode { luma(35) }
    else if icon-colour == auto { rgb("#252322") } else { icon-colour }
  let symbol = if icon != none { icon } else { _hcb-icon(icon-size, icon-ink, icon-style) }
  let text-dir = if rtl { std.rtl } else { std.ltr }
  let text-align = if rtl { right } else { left }
  let paragraph = {
    set par(leading: 0.28em, spacing: 0.08em, justify: false)
    text(font: "DejaVu Sans", dir: text-dir, size: body-size,
      fill: body-ink, body)
  }

  layout(avail => {
    let W = if width == auto { calc.min(avail.width / 1cm, 10.8) }
      else { width / 1cm }
    let w = W * 1cm
    let h = height
    if w < 7.8cm { panic("horizontal-chevron-block needs at least 7.8 cm of width") }
    if icon-size + 2 * padding > h { panic("icon-size and padding do not fit within the block height") }
    let art = _hcb-art(w, h, main-colour, light-colour, stripe, mirror)
    let text-width = if body-width == auto { w * 0.66 - 2 * padding } else { body-width }
    if text-width <= 0pt { panic("body-width must be positive") }
    let text-x = (if mirror { w * 0.055 + padding } else { w * 0.285 + padding }) + text-offset-x
    let icon-x = (if mirror { w * 0.88 - icon-size / 2 } else { w * 0.12 - icon-size / 2 }) + icon-offset-x
    let icon-box = box(width: icon-size, height: icon-size,
      align(center + horizon, symbol))
    let text-box = box(width: text-width, height: h - 2 * padding,
      align(text-align + horizon, paragraph))
    if measure(text-box).height > h - 2 * padding {
      panic("body does not fit; increase height or reduce the copy")
    }

    box(width: w, height: h, inset: 0pt, {
      place(top + left, dx: 0pt, dy: 0pt, art)
      place(top + left, dx: icon-x, dy: (h - icon-size) / 2 + icon-offset-y, icon-box)
      place(top + left, dx: text-x, dy: padding + text-offset-y, text-box)
    })
  })
}
