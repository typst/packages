// Offset abstract text card with a curved upper fold.
#import "@preview/cetz:0.5.2"
#import cetz.draw
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _abstract-canvas(w, h, draw-body) = cetz.canvas(length: 1cm, {
  import cetz.draw: *
  draw-body(w / 1cm, h / 1cm)
})

#let _abstract-arc(cx, cy, r, a0, a1, n: 8) = range(n + 1).map(i => {
  let a = (a0 + (a1 - a0) * i / n) * 1deg
  (cx + r * calc.cos(a), cy - r * calc.sin(a))
})

#let _abstract-cubic(p0, p1, p2, p3, n: 24) = range(n + 1).map(i => {
  let t = i / n
  let u = 1 - t
  (
    u * u * u * p0.at(0) + 3 * u * u * t * p1.at(0)
      + 3 * u * t * t * p2.at(0) + t * t * t * p3.at(0),
    u * u * u * p0.at(1) + 3 * u * u * t * p1.at(1)
      + 3 * u * t * t * p2.at(1) + t * t * t * p3.at(1),
  )
})

#let _abstract-rounded(w, h, r) = {
  let p = ((r, 0), (w - r, 0))
  p += _abstract-arc(w - r, -r, r, 270, 360).slice(1)
  p.push((w, -h + r))
  p += _abstract-arc(w - r, -h + r, r, 0, 90).slice(1)
  p.push((r, -h))
  p += _abstract-arc(r, -h + r, r, 90, 180).slice(1)
  p.push((0, -r))
  p += _abstract-arc(r, -r, r, 180, 270).slice(1)
  p
}

#let _abstract-front(w, h, r, rtl: false) = {
  let p = ((r, 0), (w * 0.54, 0))
  p += _abstract-cubic(
    (w * 0.54, 0),
    (w * 0.68, 0),
    (w * 0.66, -h * 0.31),
    (w, -h * 0.35),
  ).slice(1)
  p.push((w, -h + r))
  p += _abstract-arc(w - r, -h + r, r, 0, 90).slice(1)
  p.push((r, -h))
  p += _abstract-arc(r, -h + r, r, 90, 180).slice(1)
  p.push((0, -r))
  p += _abstract-arc(r, -r, r, 180, 270).slice(1)
  if rtl { p.map(((x, y)) => (w - x, y)).rev() } else { p }
}

#let _abstract-map(pts, dx, dy) = pts.map(((x, y)) => (x + dx, y + dy))

/// An abstract textbox card with an offset backing, curved upper fold,
/// optional icon and trailing accent number.
///
/// Compose several cards in a grid. The backing and number/icon positions
/// mirror in RTL; print mode switches all text to black ink and the card faces
/// to white with black outlines. `backing-offset` accepts one length for equal
/// x/y spacing, or `(x: ..., y: ...)` for independent control of the backing.
///
/// ```typ
/// #abstract-textbox(
///   title: [Lorem Ipsum], body: [A compact explanation.],
///   number: [01], icon: [⚙], colour: rgb("#F3921B"),
///   width: 100%,
/// )
/// ```
#let _abstract-counter = counter("faboxyst-abstract-textbox")
#let abstract-textbox(
  title: [],
  body: [],
  number: auto,
  icon: none,
  colour: auto,
  backing-colour: rgb("#0B4055"),
  width: auto,
  height: auto,
  min-height: 6.3cm,
  direction: auto,
  padding: 0.34cm,
  title-size: 11pt,
  body-size: 7.5pt,
  number-size: 16pt,
  icon-size: 24pt,
  number-colour: auto,
  icon-colour: auto,
  text-colour: auto,
  backing-offset: 0.34cm,
  corner-radius: 0.24cm,
  header-space: 2.28cm,
  body-gap: 0.12cm,
  body-offset-x: 0pt,
  body-offset-y: 0pt,
  icon-offset-x: 0pt,
  icon-offset-y: 0pt,
  number-offset-x: 0pt,
  number-offset-y: 0pt,
  title-offset-x: 0pt,
  title-offset-y: 0pt,
) = context {
  let th = theme-state.get()
  let print-mode = th.mode == "print"
  let rtl = if direction == auto { is-rtl() } else { direction == std.rtl }
  set text(dir: if rtl { std.rtl } else { ltr })

  let colours = (
    rgb("#F3921B"), rgb("#4ABCE6"), rgb("#A5BF6A"), rgb("#FFD04A"),
  )
  let idx = _abstract-counter.get().first()
  let next = _abstract-counter.step()
  let source-colour = if colour == auto { colours.at(calc.rem(idx, colours.len())) } else { colour }
  let face = if print-mode { white } else { source-colour }
  let back = if print-mode { white } else { backing-colour }
  let ink = if print-mode { black } else if text-colour == auto { black } else { text-colour }
  let no-ink = if print-mode { black }
    else if number-colour == auto { source-colour } else { number-colour }
  let ico-ink = if print-mode { black }
    else if icon-colour == auto { black } else { icon-colour }
  let edge = if print-mode { (paint: black, thickness: 0.8pt) } else { none }

  let title-text = text(size: title-size, weight: "bold", fill: ink, title)
  let body-text = text(size: body-size, fill: ink, body)
  let shown-number = if number == auto {
    context _abstract-counter.display("01")
  } else { number }
  let number-text = text(size: number-size, fill: no-ink, shown-number)
  let icon-content = if icon == none { none }
    else { text(size: icon-size, fill: ico-ink, icon) }

  next + layout(avail => {
    let offsets = if type(backing-offset) == dictionary {
      (backing-offset.at("x", default: 0.34cm), backing-offset.at("y", default: 0.34cm))
    } else if type(backing-offset) == array {
      backing-offset
    } else { (backing-offset, backing-offset) }
    let offset-x = calc.max(0, offsets.at(0) / 1cm)
    let offset-y = calc.max(0, offsets.at(1) / 1cm)
    let outer-w = if width == auto { avail.width / 1cm }
      else if type(width) == ratio { avail.width * width / 1cm }
      else { width / 1cm }
    let w = calc.max(3.2, outer-w - offset-x)
    let inner-w = calc.max(0.8, w - 2 * padding / 1cm)
    let title-box = box(width: inner-w * 1cm, align(start, title-text))
    let body-box = box(width: inner-w * 1cm, align(start, body-text))
    let title-h = measure(title-box).height / 1cm
    let body-h = measure(body-box).height / 1cm
    let gap = body-gap / 1cm
    let header = header-space / 1cm
    let min-h = min-height / 1cm
    let needed = header + title-h + gap + body-h + padding / 1cm
    let first-h = calc.max(min-h, needed)
    let title-y = calc.max(header, first-h * 0.36)
    let h = if height == auto { calc.max(first-h, title-y + title-h + gap + body-h + padding / 1cm) }
      else { calc.max(height / 1cm, title-y + title-h + gap + body-h + padding / 1cm) }
    let radius = calc.min(corner-radius / 1cm, w * 0.11, h * 0.06)
    let front-x = if rtl { offset-x } else { 0 }
    let back-x = if rtl { 0 } else { offset-x }
    let outer-width = w + offset-x
    let outer-height = h + offset-y
    let number-w = w * 0.24
    let number-x = if rtl { front-x + w * 0.06 } else { front-x + w * 0.70 }
    let number-y = h * 0.10
    let icon-w = calc.min(1.05, w * 0.26)
    let icon-x = if rtl { front-x + w - padding / 1cm - icon-w }
      else { front-x + padding / 1cm }
    let icon-y = offset-y + h * 0.13
    let title-y-layout = offset-y + title-y
    let body-y-layout = title-y-layout + title-h + gap

    box(width: outer-width * 1cm, height: outer-height * 1cm, {
      place(top + left, _abstract-canvas(outer-width * 1cm, outer-height * 1cm,
        (Wc, Hc) => {
          import cetz.draw: *
          let back-shape = _abstract-rounded(w, h, radius)
          let front-shape = _abstract-front(w, h, radius, rtl: rtl)
          let front-shape = _abstract-map(front-shape, front-x, -offset-y)
          let back-shape = _abstract-map(back-shape, back-x, 0)
          draw.line(..back-shape, close: true, fill: back, stroke: edge)
          draw.line(..front-shape, close: true, fill: face, stroke: edge)
        }))

      // Leading icon and trailing number occupy the exposed upper area.
      if icon-content != none {
        place(top + left, dx: (icon-x * 1cm) + icon-offset-x, dy: (icon-y * 1cm) + icon-offset-y, box(width: icon-w * 1cm, height: 0.95cm,
            align(center + horizon, icon-content)))
      }
      place(top + left, dx: (number-x * 1cm) + number-offset-x, dy: (number-y * 1cm) + number-offset-y, box(width: number-w * 1cm, height: 0.62cm,
          align(center + horizon, number-text)))

      place(top + left, dx: ((front-x + padding / 1cm) * 1cm) + title-offset-x, dy: (title-y-layout * 1cm) + title-offset-y, title-box)
      place(top + left, dx: ((front-x + padding / 1cm) * 1cm) + body-offset-x, dy: (body-y-layout * 1cm) + body-offset-y, body-box)
    })
  })
}
