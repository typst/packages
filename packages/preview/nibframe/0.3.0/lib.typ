// nibframe — decorative frames around a page (or any box), drawn with nibart.
//
//   #import "@preview/nibframe:0.3.0": *
//   #show: framed.with(style: "celtic")
//
// Styles: see `frame-styles`. Everything is vector geometry computed by the nibart plugin (Hobby splines, pen envelopes,
// knots): no images, no fonts.
#import "@preview/nibart:0.3.0" as nib
#import "styles.typ": frame-styles, _cfg, _draw, _pt, _extras

/// Package version.
#let nibframe-version = "0.3.0"

// ───────────────────────────────────────────────────────────────── public API
/// The drawing items of a frame of size `width × height` (for `nibart.mp-fig`). Origin: bottom-left corner.
#let frame-items(width, height, style: "classic", ..opts) = {
  let c = _cfg(style, opts)
  let (w, h) = (_pt(width), _pt(height))
  let (under, over) = _extras(c, w, h)
  under + (_draw.at(c.style))(c, w, h) + over
}

/// A frame of size `width × height` as content (no body); the box has exactly that size.
#let frame-graphic(width, height, style: "classic", ..opts) = nib.mp-fig(
  ..frame-items(width, height, style: style, ..opts), width: width, height: height, origin: (0pt, 0pt), pad: 0pt)

/// Margin that keeps the text clear of the frame: `inset + band + gap`.
#let frame-margin(style: "classic", gap: 6mm, ..opts) = {
  let c = _cfg(style, opts)
  c.inset + c.band + gap
}

/// A page background that draws the frame (use as `set page(background: frame-background(..))`).
#let frame-background(style: "classic", ..opts) = context {
  let (w, h) = (page.width, page.height)
  assert(type(w) == length and type(h) == length, message: "nibframe: the page needs a fixed size (not auto)")
  place(top + left, frame-graphic(w, h, style: style, ..opts))
}

/// Show rule: frames every page of the document (put it first, before any content).
/// `#show: framed.with(style: "celtic")`. `gap`: space between band and text; `margin: false` keeps your own margins.
#let framed(style: "classic", gap: 6mm, margin: true, ..opts, body) = {
  if margin { set page(margin: frame-margin(style: style, gap: gap, ..opts), background: frame-background(style: style, ..opts)); body }
  else { set page(background: frame-background(style: style, ..opts)); body }
}

/// A frame around arbitrary content (certificate, card, poster…): the body is centred inside the band.
/// `width` / `height`: size of the whole box (`auto`: fits the body plus `gap`).
#let frame-box(body, width: auto, height: auto, style: "classic", gap: 6mm, ..opts) = context {
  let c = _cfg(style, opts)
  let pad = c.inset + c.band + gap
  let sz = measure(body)
  let w = if width == auto { sz.width + 2 * pad } else { width }
  let h = if height == auto { sz.height + 2 * pad } else { height }
  box(width: w, height: h, {
    place(top + left, frame-graphic(w, h, style: style, ..opts))
    place(center + horizon, box(width: w - 2 * pad, height: h - 2 * pad, align(center + horizon, body)))
  })
}
