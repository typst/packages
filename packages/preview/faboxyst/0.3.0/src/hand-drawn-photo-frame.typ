// A standalone editable hand-drawn photo frame adapted from the supplied
// Freepik Business Brochure reference. Free-license attribution: Designed by Freepik.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _hdpf-art(width, height, fill-colour, ink, stroke-width) = {
  let sw = stroke-width / 1cm * 540 / (width / 1cm)
  let frame = "M 24 24 C 149 18 342 24 514 21 C 519 118 512 255 517 373 C 365 378 176 370 25 376 C 20 283 27 134 22 26 C 22 25 23 24 24 24 Z"
  let echo = "M 31 31 C 154 26 344 31 507 28 C 512 124 506 252 510 366 C 362 371 180 364 32 369 C 27 278 34 139 29 33 C 29 32 30 31 31 31 Z"
  let marks = "M 39 9 L 14 9 Q 10 9 10 13 L 10 39 M 500 391 L 529 391 L 529 362 M 23 305 l 2 -17 m 3 12 l 2 -21 M 491 18 l 1 18 m 4 -15 l 1 11"
  let svg = (
    "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 540 400\" preserveAspectRatio=\"none\">"
    + "<path d=\"" + frame + "\" fill=\"" + fill-colour.to-hex() + "\" stroke=\"" + ink.to-hex() + "\" stroke-width=\"" + str(sw) + "\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/>"
    + "<path d=\"" + echo + "\" fill=\"none\" stroke=\"" + ink.lighten(25%).to-hex() + "\" stroke-width=\"" + str(sw * 0.56) + "\" stroke-linecap=\"round\" stroke-linejoin=\"round\" opacity=\"0.76\"/>"
    + "<path d=\"" + marks + "\" fill=\"none\" stroke=\"" + ink.to-hex() + "\" stroke-width=\"" + str(sw * 0.9) + "\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/>"
    + "</svg>"
  )
  image(bytes(svg), format: "svg", width: width, height: height)
}

/// One reusable, hand-drawn photo frame with an editable content slot.
///
/// Pass an image or other content with `content`; when omitted, a localized
/// placeholder is shown. The frame and loose corner marks scale with its size.
#let hand-drawn-photo-frame(
  content: none,
  placeholder: [Your photo here],
  width: auto,
  height: 5.2cm,
  direction: auto,
  colour: rgb("#C8EAF5"),
  stroke-colour: auto,
  stroke-width: 1.5pt,
  placeholder-colour: auto,
  padding: 0.16cm,
  placeholder-size: 14pt,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let rtl = if direction == auto { is-rtl() }
    else { direction == "rtl" or direction == std.rtl }
  if height <= 0pt or stroke-width <= 0pt or padding < 0pt or placeholder-size <= 0pt {
    panic("height, stroke-width, and placeholder-size must be positive; padding cannot be negative")
  }
  let text-dir = if rtl { std.rtl } else { std.ltr }
  let fill-ink = if print-mode { luma(224) } else { colour }
  let edge-ink = if print-mode { luma(52) }
    else if stroke-colour == auto { rgb("#242222") } else { stroke-colour }
  let label-ink = if print-mode { luma(102) }
    else if placeholder-colour == auto { rgb("#78838A") } else { placeholder-colour }

  layout(avail => {
    let W = if width == auto { calc.min(avail.width / 1cm, 7.6) }
      else { width / 1cm }
    let w = W * 1cm
    let h = height
    let frame-left = w * 22 / 540
    let frame-top = h * 20 / 400
    let frame-width = w * 496 / 540
    let frame-height = h * 358 / 400
    let inner-width = frame-width - 2 * padding
    let inner-height = frame-height - 2 * padding
    if inner-width <= 0pt or inner-height <= 0pt {
      panic("padding leaves no usable photo area")
    }
    let label = if content == none {
      text(font: "DejaVu Sans", dir: text-dir, size: placeholder-size,
        weight: "semibold", fill: label-ink, placeholder)
    } else {
      text(dir: text-dir, content)
    }
    let label-box = box(width: inner-width, height: inner-height,
      align(center + horizon, label))
    let art = _hdpf-art(w, h, fill-ink, edge-ink, stroke-width)

    box(width: w, height: h, inset: 0pt, {
      place(top + left, dx: 0pt, dy: 0pt, art)
      place(top + left, dx: frame-left + padding,
        dy: frame-top + padding, label-box)
    })
  })
}
