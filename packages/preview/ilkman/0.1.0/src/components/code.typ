// ilkman — im-code
#import "../core.typ": *
#import "@preview/touying:0.8.0": alternatives

/// Find the first raw element inside a value.
#let find-raw(b) = {
  if type(b) == content {
    if b.func() == raw { return b }
    if b.has("children") {
      for c in b.children {
        let r = find-raw(c)
        if r != none { return r }
      }
    }
    if b.has("body") { return find-raw(b.body) }
  }
  none
}

#let _render-code(r, c, numbering, title, hl, width, align, inset) = {
  let pal = light-pal(c)
  let hl = if type(hl) == int { (hl,) } else { hl }
  let n-lines = r.text.split("\n").len()
  let num-w = if numbering { measure(text(..font-args(c.fonts, "code"), size: raw-em(c.sizes.code), str(n-lines))).width + 2pt } else { 0pt }

  let code = {
    show raw.line: it => {
      let on = it.number in hl
      box(
        width: 100%,
        fill: if on { pal.tint.transparentize(35%) } else { none },
        outset: (x: inset, y: 0.18em),
        {
          if numbering {
            box(width: num-w, std.align(right, text(fill: pal.ink.lighten(55%), str(it.number))))
            h(1em)
          }
          it.body
        },
      )
    }
    raw(r.text, lang: r.at("lang", default: none), block: true)
  }

  let head = if title != none {
    block(
      width: 100%,
      fill: pal.tint.transparentize(40%),
      inset: (x: inset, y: 0.45em),
      below: 0pt,
      text(..font-args(c.fonts, "code"), size: raw-em(c.sizes.code * 0.95), fill: pal.ink, weight: 600, raw(title)),
    )
  }

  let w = width
  if width == auto {
    let natural = measure(raw(r.text, lang: r.at("lang", default: none), block: true)).width
    w = natural + num-w + (if numbering { 1em.to-absolute() } else { 0pt }) + 2 * inset + 2pt
    if title != none { w = calc.max(w, measure(text(..font-args(c.fonts, "code"), size: raw-em(c.sizes.code * 0.95), weight: 600, raw(title))).width + 2 * inset + 2pt) }
  }
  set text(fill: pal.ink)
  let box-content = block(
    width: w,
    fill: pal.wash,
    stroke: 0.5pt + pal.tint,
    radius: 4pt,
    clip: true,
    breakable: true,
    {
      head
      block(inset: (x: inset, y: 0.7em), above: 0pt, width: 100%, code)
    },
  )
  block(width: 100%, std.align(to-align(align), box-content))
}

/// Code block.
///
/// ```typst
/// #im-code(numbering: false, title: "hello.py")[```py
/// print("hello")
/// ```]
/// ```
///
/// - numbering (bool): line numbers.
/// - title (str, none): file-name bar above the code.
/// - hl (array, int): highlighted lines, e.g. (3, 5) or range(3, 7).
/// - width (relative, auto): box width; `auto` shrinks to the longest line.
/// - align (str): position of the box when narrower than the line: "left", "center", "right".
/// - caption (content, none): numbered caption ("Kod 2.1").
/// - hl-steps (array, none): slides only — highlight a different line set at each step.
#let im-code(
  numbering: true,
  title: none,
  hl: (),
  width: 100%,
  align: "left",
  caption: none,
  hl-steps: none,
  ..body,
) = {
  let r = find-raw(body.pos().join())
  assert(r != none, message: "ilkman: im-code expects a raw block, e.g. im-code[```py ... ```]")
  let one(h) = {
    let out = context _render-code(r, ctx(), numbering, title, h, width, align, 10pt)
    if caption != none {
      figure(out, kind: raw, supplement: context tr(ctx(), "listing"), caption: caption)
    } else { out }
  }
  if hl-steps != none {
    alternatives(..hl-steps.map(h => one(h)))
  } else {
    one(hl)
  }
}
