// ===========================================================================
//  faboxyst/numbox.typ — a numbered question / exercise box.
//
//    #numbox[Find three examples …]
//    #numbox[question][answer]
//    #numbox(number: 7)[forced to 7 — the next auto is 8]
//    #numbox(dash: "dashed")[a dashed frame]
//    #numbox(frame-char: "*")[a starred frame]
//    #numbox-reset()
//
//  The plaque is glued to the top-leading corner (left in LTR, right in
//  RTL). The digits follow the surrounding direction, so RTL prints `.1`.
//
//  HARD RULE: the plaque side is min(badge-size, frame height, frame
//  width). A one-line box is packed tightly so the frame is actually
//  short; the square then shrinks to that height and cannot stick out.
// ===========================================================================

#import "fabox.typ": is-rtl
#import "engine.typ": rounded-rect-pts
#import "antique.typ": vintage-pts
#import "theme.typ": theme-state

#let numbox-counter = counter("faboxyst-numbox")

/// Next automatic number will be `n` (default 1).
#let numbox-reset(n: 1) = numbox-counter.update(n - 1)

#let _fmt(pat, n) = {
  if type(pat) == function { pat(n) } else { numbering(pat, n) }
}

/// Repeat `ch` around a rectangle of size `w` × `h`.
#let _char-frame(w, h, ch, paint, size, skip: none) = {
  let step = size * 0.88
  let nx = calc.max(2, int(calc.round(w / step)))
  let ny = calc.max(2, int(calc.round(h / step)))
  let dx = w / nx
  let dy = h / ny
  let glyph = text(dir: ltr, fill: paint, size: size, ch)
  let clear(x, y) = {
    if skip == none { true } else {
      let (x0, y0, x1, y1) = skip
      x < x0 or x > x1 or y < y0 or y > y1
    }
  }
  let at(x, y) = if clear(x, y) {
    place(top + left, dx: x - size / 2, dy: y - size / 2, glyph)
  }
  for i in range(nx + 1) {
    at(i * dx, 0pt)
    at(i * dx, h)
  }
  for j in range(1, ny) {
    at(0pt, j * dy)
    at(w, j * dy)
  }
}

#let _plaque(ps, colour, title-colour, body, radius, badge-radius, rtl, flush) = {
  let r-out = calc.min(radius, ps / 2)
  let r-in = calc.min(badge-radius, ps / 2)
  let lead-bot = if flush { r-out } else { r-in }
  box(
    width: ps, height: ps,
    fill: colour,
    radius: (
      top-left: if rtl { r-in } else { r-out },
      top-right: if rtl { r-out } else { r-in },
      bottom-left: if rtl { r-in } else { lead-bot },
      bottom-right: if rtl { lead-bot } else { r-in },
    ),
    align(center + horizon,
      text(fill: title-colour, weight: "bold",
        size: 0.55 * ps, body)),
  )
}

/// A simple numbered box.
///
///   badge-size  *maximum* plaque side. The drawn square is always
///               min(badge-size, frame-height, frame-width).
#let numbox(
  body,
  answer: auto,
  number: auto,
  numbering: "1.",
  colour: rgb("#1E54A8"),
  frame: auto,
  fill: auto,
  stroke: auto,
  dash: none,
  frame-char: none,
  frame-char-size: 0.28cm,
  title-colour: white,
  answer-colour: rgb("#2E8B3A"),
  answer-label: auto,
  radius: 0.20cm,
  badge-radius: 0.11cm,
  badge-size: 0.78cm,
  weight: 1.35pt,
  inset: 0.30cm,
  gap: 0.10cm,
  width: 100%,
  direction: auto,
  vintage: false,      // frame drawn with an engraved elliptical nib
  vintage-pen: none,   // (th, th2, angle) override for the nib
  ..rest,
) = {
  let extra = rest.pos()
  let answer = if answer != auto { answer }
               else if extra.len() > 0 { extra.at(0) }
               else { none }

  if number == auto {
    numbox-counter.step()
  } else if type(number) == int {
    numbox-counter.update(number)
  }

  context {
    let print-mode = theme-state.get().mode == "print"
    if print-mode { set text(fill: black) }
    let rtl = if direction != auto { direction == std.rtl } else { is-rtl() }
    let body-dir = if rtl { std.rtl } else { ltr }
    let fr = if print-mode { black }
      else if frame == auto { colour.lighten(18%) } else { frame }
    let bk = if print-mode { white }
      else if fill == auto { colour.lighten(94%) } else { fill }
    let badge-fill = if print-mode { luma(224) } else { colour }
    let answer-colour = if print-mode { black } else { answer-colour }
    let title-colour = if print-mode { black } else { title-colour }
    let lbl = if answer-label != auto { answer-label }
              else if rtl { [ج:] } else { [Ans.] }

    let st = if stroke != auto { stroke }
             else if dash == none { weight + fr }
             else { (paint: fr, thickness: weight, dash: dash) }

    let show-plaque = number != none
    let plaque-body = if number == none {
      none
    } else if number == auto or type(number) == int {
      _fmt(numbering, numbox-counter.get().first())
    } else {
      number
    }

    let words(it) = {
      set text(dir: body-dir)
      set align(start)
      it
    }

    let stack = {
      words(body)
      if answer != none {
        v(0.42em, weak: true)
        set text(dir: body-dir)
        grid(columns: (auto, 1fr), column-gutter: 0.22cm, align: top,
          text(fill: answer-colour, weight: "bold", lbl),
          words(answer))
      }
    }

    layout(avail => {
      let W = if type(width) == ratio { avail.width * width } else { width }

      // How tall is the text itself? A single line gets a tight frame so
      // the plaque has something small to clamp to.
      let probe-w = calc.max(1cm, W - inset - gap - calc.min(badge-size, 0.6cm))
      let raw = measure(block(width: probe-w, stack)).height
      let one-line = show-plaque and answer == none and raw <= 1.55 * text.size

      let vpad = if one-line { 0.07cm } else { inset }
      let top-pad = if show-plaque and not one-line { 0.08cm } else { vpad }
      let bot-pad = vpad

      let pack(lead, vcenter: false, h: auto) = {
        if vcenter {
          block(
            width: W,
            height: h,
            inset: (
              left: if rtl { inset } else { lead },
              right: if rtl { lead } else { inset },
            ),
            align(horizon, stack),
          )
        } else {
          block(
            width: W,
            inset: (
              top: top-pad,
              bottom: bot-pad,
              left: if rtl { inset } else { lead },
              right: if rtl { lead } else { inset },
            ),
            stack,
          )
        }
      }

      // Provisional lead: assume the plaque will be min(badge, packed height).
      let packed-h = raw + top-pad + bot-pad
      let ps = if show-plaque { calc.min(badge-size, packed-h, W) } else { 0pt }
      let lead = if show-plaque { ps + gap } else { inset }

      let content = pack(lead)
      let H = measure(content).height
      // Final clamp — this is the rule the caller asked for.
      ps = if show-plaque { calc.min(badge-size, H, W) } else { 0pt }
      if show-plaque {
        lead = ps + gap
        content = pack(lead)
        H = measure(content).height
        ps = calc.min(badge-size, H, W)
      }

      let flush = show-plaque and ps + 0.4pt >= H
      if flush {
        content = pack(lead, vcenter: true, h: H)
      }

      let plaque = if show-plaque {
        _plaque(ps, badge-fill, title-colour, plaque-body,
          radius, badge-radius, rtl, flush)
      } else { none }

      block(width: W, height: H, fill: bk,
        stroke: if frame-char != none or vintage { none } else { st },
        radius: if frame-char != none { 0pt } else { radius },
        clip: false,
        {
          set text(dir: body-dir)
          if vintage {
            place(top + left, vintage-pts(
              rounded-rect-pts((0pt, 0pt), (W, H), radius: radius, n: 10),
              fr, weight, closed: true, vintage-pen: vintage-pen))
          }
          if show-plaque {
            place(top + start, plaque)
          }
          content
          if frame-char != none {
            _char-frame(W, H, frame-char, fr, frame-char-size)
          }
        })
    })
  }
}
