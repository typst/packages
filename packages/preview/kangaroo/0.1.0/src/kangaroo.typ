#let _has-metadata(elem, kind) = {
  let kind = if type(kind) == array { kind } else { (kind,) }

  if type(elem) != content {
    return false
  }

  if elem.func() == metadata and type(elem.value) == dictionary {
    if elem.value.at("kind", default: none) in kind {
      return true
    }
  }

  if elem.has("children") {
    for child in elem.children {
      if _has-metadata(child, kind) { return true }
    }
  }

  return false
}

/// Security parameter.
#let secpar = $lambda$
#let secpar-unary = $1^lambda$

/// Adversary.
#let adv = $cal(A)$

/// Library names.
#let lib(name, subject: none) = {
  if name in (none, [], "") {
    panic("kangaroo: lib: empty name is not allowed")
  }
  if subject != none {
    $cal(L)_sans(upright(name))^(subject)$
    return
  }
  $cal(L)_sans(upright(name))$
}

/// Distinguishing advantage.
#let advantage(notion, subject, adversary: adv) = {
  let op = $op(sans(upright("Adv")))$
  let notion = $sans(upright(notion))$
  if adversary != none {
    adversary = $(adversary)$
  }
  $op_(subject)^(notion) adversary$
}

/// Negligible function.
#let negl(param: secpar) = {
  let op = $op("negl")$
  $op(param)$
}

/// Polynomial function.
#let poly(param: secpar) = {
  let op = $op("poly")$
  $op(param)$
}

/// Bad event.
#let bad = $sans(upright("bad"))$

/// Interchangeability.
#let interc = (
  // TODO: declare as symbol with variant.
  // See https://github.com/typst/typst/issues/6028.
  "is": $equiv$,
  "not": $cancel(angle: #20deg, stroke: #(thickness: 0.045em, cap: "round"), equiv)$,
)

/// Indistinguishability.
#let indist = (
  // TODO: declare as symbol with variant.
  // See https://github.com/typst/typst/issues/6028.
  "is": $approx.eq$,
  "not": $cancel(angle: #20deg, stroke: #(thickness: 0.045em, cap: "round"), approx.eq)$,
)

/// Link library pair.
#let linked = $diamond.small$

/// Box and symbols chaining.
#let chain(..elems, spacing: 0.32em) = {
  grid(
    columns: elems.pos().len(),
    column-gutter: spacing,
    align: horizon,
    ..elems,
  )
}

#let _raw(body) = {
  if type(body) in (str, symbol) {
    return raw(body)
  }

  if body.has("children") {
    for (i, child) in body.children.enumerate() {
      if child == [ ] {
        if i > 0 and i < body.children.len() - 1 { raw(" ") }
        continue
      }
      if child == linebreak() {
        raw("\n")
        continue
      }
      assert(
        child.has("text"),
        message: "kangaroo: bit: only plain text content is supported",
      )
      raw(child.text)
    }
    return
  }

  assert(
    body.has("text"),
    message: "kangaroo: bit: only plain text content is supported",
  )
  raw(body.text)
}

/// Bit strings and literals.
#let bit(body, fill: auto) = context {
  if type(body) not in (str, content, symbol) {
    panic("kangaroo: bit: expected string or content, found " + str(type(body)))
  }

  // TODO: ignore emph (maybe, still unsure).
  // See https://github.com/typst/typst/issues/6172.

  let fill-color = fill
  if fill == auto {
    // NOTE: default with black text is #a91616.
    let base = rgb("#ff2727")
    if oklch(text.fill).components().at(0) > 50% {
      fill-color = base.mix((text.fill, 0.64))
    } else {
      fill-color = base.mix((text.fill, 0.36))
    }
  }
  show raw: set text(fill: fill-color)

  _raw(body)
}

/// Set of bits.
#let bits = ${#bit[0], #bit[1]}$

/// Algorithm names.
#let algo(name) = $sans(upright(name))$

/// Subroutine names.
#let subr(name) = {
  // TODO: always use text font.
  // See https://github.com/typst/typst/issues/366.
  set text(font: "Libertinus Serif", style: "normal")
  smallcaps(name)
}

/// End-of-time subroutine.
///
/// It executes once, just as the calling program terminates.
#let end-of-time = {
  subr[end of time]
  metadata((kind: "kangaroo-end-of-time"))
}

/// Code procedure.
#let proc(name, args: none) = context {
  box(
    stroke: (bottom: 0.05em + text.fill),
    inset: (bottom: 0.225em),
    outset: (bottom: 0.225em),
    if _has-metadata(name, "kangaroo-end-of-time") {
      [$#name$:]
    } else {
      [$#name;(args)$:]
    },
  )
}

#let _has-subscript(body) = {
  let outer = body
  while outer.func() == math.equation {
    let inner = outer.body
    while inner.func() == math.attach {
      if inner.has("b") and inner.b.child != [] {
        return true
      }
      inner = inner.base
    }
    outer = inner
  }
  return false
}

#let _code(body, title: none, fill: (luma(230), white), border: false) = context {
  let is-sequence = false
  if type(body) == content and body.has("children") {
    for child in body.children {
      if type(child) == content and child.func() in (list.item, enum.item) {
        is-sequence = true
        break
      }
    }
  }
  set list(marker: none, indent: 1em, body-indent: 0pt)
  set enum(numbering: (..nums) => none, indent: 1em, body-indent: 0pt)
  set par(leading: 0.7em, spacing: 1.65em)
  if title == none {
    box(block(
      fill: fill.at(1),
      stroke: if border { 0.045em + text.fill },
      inset: (
        left: if is-sequence { -1em + 0.48em } else { 0.48em },
        rest: 0.48em,
      ),
      align(left, box(inset: (y: 0.2em), body)),
    ))
  } else {
    let header = title
    if type(title) == content and _has-subscript(title) {
      header = $ title $
    }
    box(grid(
      rows: 2,
      inset: (_, y) => if y == 0 { 0.36em } else { 0.48em },
      align: (_, y) => if y == 0 { center } else { left },
      fill: (_, y) => fill.at(y),
      stroke: (_, y) => if border {
        if y == 0 {
          (bottom: none, rest: 0.045em + text.fill)
        } else {
          (top: none, rest: 0.045em + text.fill)
        }
      },
      header,
      block(
        inset: if is-sequence { (left: -1em) } else { 0pt },
        box(inset: (y: 0.2em), body),
      ),
    ))
  }
}

/// Code box.
#let code(body, fill: white) = {
  if type(body) not in (str, content, symbol) {
    panic("kangaroo: code: expected string or content, found " + str(type(body)))
  }
  if fill != none and type(fill) not in (color, gradient, tiling) {
    panic("kangaroo: code: expected color, gradient, tiling, or none, found " + str(type(fill)))
  }
  _code(body, fill: (none, fill))
  metadata((kind: "kangaroo-code"))
}

/// Library box.
#let library(body, title: none, fill: (luma(230), white)) = {
  if type(body) not in (str, content, symbol) {
    panic("kangaroo: library: expected string or content, found " + str(type(body)))
  }

  let fill = if type(fill) == array { fill } else { (fill,) }
  if fill.len() not in (1, 2) {
    panic("kangaroo: library: fill must have 1 or 2 colors, found " + str(fill.len()))
  }
  for v in fill {
    if v != none and type(v) not in (color, gradient, tiling) {
      panic("kangaroo: library: expected color, gradient, tiling, or none, found " + str(type(v)))
    }
  }
  if fill.len() == 1 {
    fill = (luma(230), fill.at(0))
  }

  _code(body, title: title, fill: fill, border: true)
  metadata((kind: "kangaroo-library"))
}

/// Code comment.
#let comment(body, fill: luma(128)) = {
  set text(fill: fill)
  show raw: it => {
    set text(fill: fill)
    emph(it)
  }
  "// "
  emph(if body.has("children") {
    for (i, child) in body.children.enumerate() {
      if i == 0 and child == [ ] { continue }
      child
    }
  } else {
    body
  })
}

/// Shape highlighting.
#let hl(body, fill: rgb("#f5f574").desaturate(37.5%)) = {
  if type(body) not in (str, content, symbol) {
    panic("kangaroo: hl: expected string or content, found " + str(type(body)))
  }
  if _has-metadata(body, ("kangaroo-code", "kangaroo-library")) {
    box(fill: fill, inset: 0.216em, body)
    return
  }
  let result = [
    // TODO: make copies non-selectable.
    // See https://github.com/typst/typst/issues/2249.
    #for i in range(32) {
      place(
        dx: 0.108em * calc.cos(i / 16 * calc.pi),
        dy: 0.108em * calc.sin(i / 16 * calc.pi),
        text(fill: fill, {
          show text: set text(fill: fill) // HACK: fixes hl(bits).
          show raw: set text(fill: fill)
          show math.equation: set text(fill: fill)
          body
        }),
      )
    }
    #text(body)
  ]
  if type(body) == content and body.func() == math.equation and body.block {
    set align(center)
    block(result)
    return
  }
  box(result)
}
