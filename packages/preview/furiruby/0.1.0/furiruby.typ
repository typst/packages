// furiruby.typ
// CJK Ruby helper for Typst
// API:
//   #ruby(t: [], b: [], rt: [], lt: [], rb: [], lb: [], body: [])
// Aliases:
//   #rt(_ruby: [], body: []) => { ruby(t: _ruby, body: body) }
//   #rb(_ruby: [], body: []) => { ruby(b: _ruby, body: body) }
//   #rrt(_ruby: [], body: []) => { ruby(rt: _ruby, body: body) }
//   #rlt(_ruby: [], body: []) => { ruby(lt: _ruby, body: body) }
//   #rrb(_ruby: [], body: []) => { ruby(rb: _ruby, body: body) }
//   #rlb(_ruby: [], body: []) => { ruby(lb: _ruby, body: body) }
//
// The implementation follows the "simple ruby" model:
// - t / b: group ruby (over / under)
// - rt / lt / rb / lb: side-position ruby variants
// - body: base text

#let _ruby-default-style = (
  size: 0.5em,
)

#let _ruby-default-layout = (
  top-gap: 0.2em,
  bottom-gap: 0.2em,
  side-gap: 0.2em,
  inline-mode: "expand",
  consistent-leading: false,
  ruby-slot-height: auto,
)

#let _arr(v) = {
  if type(v) == array { v } else { (v,) }
}

#let _join(v) = {
  let a = _arr(v)
  if a.len() == 0 { [] } else {
    let out = a.at(0)
    for i in range(1, a.len()) {
      out += a.at(i)
    }
    out
  }
}

#let _txt(v, style: (:)) = {
  let merged = _ruby-default-style + style
  text(..merged, _join(v))
}

#let _stack(top: none, base: none, bottom: none, gap-top: 0.2em, gap-bottom: 0.2em) = {
  if top == none and bottom == none {
    base
  } else if bottom == none {
    stack(
      dir: ttb,
      spacing: gap-top,
      top,
      base,
    )
  } else if top == none {
    stack(
      dir: ttb,
      spacing: gap-bottom,
      base,
      bottom,
    )
  } else {
    stack(
      dir: ttb,
      spacing: 0pt,
      top,
      box(height: gap-top),
      base,
      box(height: gap-bottom),
      bottom,
    )
  }
}

#let _ruby-row(left-content: none, center-content: none, right-content: none, width: auto) = {
  if left-content == none and center-content == none and right-content == none {
    none
  } else {
    let row-height = 0pt
    if left-content != none {
      row-height = calc.max(row-height, measure(left-content).height)
    }
    if center-content != none {
      row-height = calc.max(row-height, measure(center-content).height)
    }
    if right-content != none {
      row-height = calc.max(row-height, measure(right-content).height)
    }

    box(width: width, height: row-height)[
      #if left-content != none {
        place(left + top)[#left-content]
      }
      #if center-content != none {
        place(center + top)[#center-content]
      }
      #if right-content != none {
        place(right + top)[#right-content]
      }
    ]
  }
}

#let ruby(
  body,
  t: (),
  b: (),
  rt: (),
  lt: (),
  rb: (),
  lb: (),
  ruby-style: (:),
  layout: (:),
) = {
  let l = _ruby-default-layout + layout

  let top-center = if _arr(t).len() > 0 { _txt(t, style: ruby-style) } else { none }
  let bottom-center = if _arr(b).len() > 0 { _txt(b, style: ruby-style) } else { none }

  let right-top = if _arr(rt).len() > 0 { _txt(rt, style: ruby-style) } else { none }
  let left-top = if _arr(lt).len() > 0 { _txt(lt, style: ruby-style) } else { none }
  let right-bottom = if _arr(rb).len() > 0 { _txt(rb, style: ruby-style) } else { none }
  let left-bottom = if _arr(lb).len() > 0 { _txt(lb, style: ruby-style) } else { none }

  context {
    let base = _join(body)
    let base-width = measure(base).width

    let top-left-width = if left-top == none { none } else { measure(left-top).width }
    let top-center-width = if top-center == none { none } else { measure(top-center).width }
    let top-right-width = if right-top == none { none } else { measure(right-top).width }
    let bottom-left-width = if left-bottom == none { none } else { measure(left-bottom).width }
    let bottom-center-width = if bottom-center == none { none } else { measure(bottom-center).width }
    let bottom-right-width = if right-bottom == none { none } else { measure(right-bottom).width }

    let top-left-height = if left-top == none { none } else { measure(left-top).height }
    let top-center-height = if top-center == none { none } else { measure(top-center).height }
    let top-right-height = if right-top == none { none } else { measure(right-top).height }
    let bottom-left-height = if left-bottom == none { none } else { measure(left-bottom).height }
    let bottom-center-height = if bottom-center == none { none } else { measure(bottom-center).height }
    let bottom-right-height = if right-bottom == none { none } else { measure(right-bottom).height }

    let top-height = {
      let h = none
      if top-left-height != none { h = top-left-height }
      if top-center-height != none and (h == none or top-center-height > h) { h = top-center-height }
      if top-right-height != none and (h == none or top-right-height > h) { h = top-right-height }
      if h == none { 0pt } else { h }
    }

    let bottom-height = {
      let h = none
      if bottom-left-height != none { h = bottom-left-height }
      if bottom-center-height != none and (h == none or bottom-center-height > h) { h = bottom-center-height }
      if bottom-right-height != none and (h == none or bottom-right-height > h) { h = bottom-right-height }
      if h == none { 0pt } else { h }
    }

    let span-start = (w, align) => {
      if align == "left" { 0pt }
      else if align == "right" { base-width - w }
      else { (base-width - w) / 2 }
    }

    let min-start = {
      let v = none
      if top-left-width != none {
        let s = span-start(top-left-width, "left")
        if v == none or s < v { v = s }
      }
      if top-center-width != none {
        let s = span-start(top-center-width, "center")
        if v == none or s < v { v = s }
      }
      if top-right-width != none {
        let s = span-start(top-right-width, "right")
        if v == none or s < v { v = s }
      }
      if bottom-left-width != none {
        let s = span-start(bottom-left-width, "left")
        if v == none or s < v { v = s }
      }
      if bottom-center-width != none {
        let s = span-start(bottom-center-width, "center")
        if v == none or s < v { v = s }
      }
      if bottom-right-width != none {
        let s = span-start(bottom-right-width, "right")
        if v == none or s < v { v = s }
      }
      v
    }

    let max-end = {
      let v = none
      if top-left-width != none {
        let s = span-start(top-left-width, "left")
        let e = s + top-left-width
        if v == none or e > v { v = e }
      }
      if top-center-width != none {
        let s = span-start(top-center-width, "center")
        let e = s + top-center-width
        if v == none or e > v { v = e }
      }
      if top-right-width != none {
        let s = span-start(top-right-width, "right")
        let e = s + top-right-width
        if v == none or e > v { v = e }
      }
      if bottom-left-width != none {
        let s = span-start(bottom-left-width, "left")
        let e = s + bottom-left-width
        if v == none or e > v { v = e }
      }
      if bottom-center-width != none {
        let s = span-start(bottom-center-width, "center")
        let e = s + bottom-center-width
        if v == none or e > v { v = e }
      }
      if bottom-right-width != none {
        let s = span-start(bottom-right-width, "right")
        let e = s + bottom-right-width
        if v == none or e > v { v = e }
      }
      v
    }

    let mode = l.inline-mode
    let intrinsic-left-overhang = if min-start == none or min-start >= 0pt { 0pt } else { -min-start }
    let intrinsic-right-overhang = if max-end == none or max-end <= base-width { 0pt } else { max-end - base-width }
    let outer-width = base-width + intrinsic-left-overhang + intrinsic-right-overhang

    let base-metrics = measure(base)
    let base-height = base-metrics.height
    let base-baseline = base-metrics.at("first-baseline", default: base-metrics.at("ascent", default: base-height))
    let base-descent = base-height - base-baseline
    let reserve-ruby-band = l.consistent-leading == true
    let ruby-probe-height = measure(_txt(["あ"], style: ruby-style)).height
    let fixed-slot = if l.ruby-slot-height == auto { ruby-probe-height } else { l.ruby-slot-height }

    let top-band = if reserve-ruby-band {
      fixed-slot + l.top-gap
    } else if top-height == 0pt {
      0pt
    } else {
      top-height + l.top-gap
    }

    let bottom-band = if reserve-ruby-band {
      l.bottom-gap + fixed-slot
    } else if bottom-height == 0pt {
      0pt
    } else {
      l.bottom-gap + bottom-height
    }

    let rendered = box(
      width: outer-width,
      height: top-band + base-height + bottom-band,
      baseline: bottom-band + base-descent,
    )[
      #place(left + top)[#move(dx: intrinsic-left-overhang, dy: top-band, base)]

      #if left-top != none [
        #place(left + top)[#move(dx: intrinsic-left-overhang + span-start(top-left-width, "left"), left-top)]
      ]
      #if top-center != none [
        #place(left + top)[#move(dx: intrinsic-left-overhang + span-start(top-center-width, "center"), top-center)]
      ]
      #if right-top != none [
        #place(left + top)[#move(dx: intrinsic-left-overhang + span-start(top-right-width, "right"), right-top)]
      ]

      #if left-bottom != none [
        #place(left + top)[#move(dx: intrinsic-left-overhang + span-start(bottom-left-width, "left"), dy: top-band + base-height + l.bottom-gap, left-bottom)]
      ]
      #if bottom-center != none [
        #place(left + top)[#move(dx: intrinsic-left-overhang + span-start(bottom-center-width, "center"), dy: top-band + base-height + l.bottom-gap, bottom-center)]
      ]
      #if right-bottom != none [
        #place(left + top)[#move(dx: intrinsic-left-overhang + span-start(bottom-right-width, "right"), dy: top-band + base-height + l.bottom-gap, right-bottom)]
      ]
    ]

    if mode == "float" {
      [#h(-intrinsic-left-overhang)#rendered#h(-intrinsic-right-overhang)]
    } else {
      rendered
    }
  }
}

#let rt(_ruby, body, ruby-style: (:), layout: (:)) = {
  ruby(body, t: _ruby, ruby-style: ruby-style, layout: layout)
}

#let rb(_ruby, body, ruby-style: (:), layout: (:)) = {
  ruby(body, b: _ruby, ruby-style: ruby-style, layout: layout)
}

#let rrt(_ruby, body, ruby-style: (:), layout: (:)) = {
  ruby(body, rt: _ruby, ruby-style: ruby-style, layout: layout)
}

#let rlt(_ruby, body, ruby-style: (:), layout: (:)) = {
  ruby(body, lt: _ruby, ruby-style: ruby-style, layout: layout)
}

#let rrb(_ruby, body, ruby-style: (:), layout: (:)) = {
  ruby(body, rb: _ruby, ruby-style: ruby-style, layout: layout)
}

#let rlb(_ruby, body, ruby-style: (:), layout: (:)) = {
  ruby(body, lb: _ruby, ruby-style: ruby-style, layout: layout)
}
