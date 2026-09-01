// Implementation of drawstring. Only `lib.typ` is public, so nothing here needs
// to be safe to import with a wildcard.
//
// Diagrams are laid out bottom to top: inputs enter at the bottom edge and
// outputs leave at the top edge. Other reading directions are a linear map
// applied to the finished drawing at render time; the layout code works in
// the bottom-to-top frame and consults the direction only to measure labels,
// which stay upright on the page.

#import "@preview/cetz:0.5.2"
#import "style.typ": default-style, no-stroke, use-stroke, resolve-style, group-style, check-style, normalize-style, whole-diagram-keys

// Aliased so that cetz's `line`, `rect`, `circle` and `content` do not shadow
// Typst's own within this file.
#let (_bezier, _circle, _content, _line, _rect) = (
  cetz.draw.bezier, cetz.draw.circle, cetz.draw.content, cetz.draw.line, cetz.draw.rect,
)

// ---------------------------------------------------------------- directions
//
// Where a point `(x, y)` of the bottom-to-top frame lands on the page:
//   up:    (x, y)        down:  (x, -y)     a vertical flip
//   right: (y, -x)       left:  (-y, -x)    the first factor of a `parallel` stays on top

#let _direction-map(dir, p) = {
  let (x, y) = p
  if dir == "up" { (x, y) } else if dir == "down" { (x, -y) } else if dir == "right" { (y, -x) } else { (-y, -x) }
}

#let _direction-transform(dir) = {
  if dir == "down" {
    cetz.draw.scale(x: 1, y: -1)
  } else if dir == "right" {
    cetz.draw.rotate(-90deg)
  } else if dir == "left" {
    cetz.draw.scale(x: -1, y: 1)
    cetz.draw.rotate(-90deg)
  }
}

// A wire label is placed beside its wire in the bottom-to-top frame, but its
// anchor is chosen on the page, so that it stays clear of the wire whichever
// way the diagram is read.
#let _side-anchor(dir, side) = {
  let (dx, dy) = _direction-map(dir, (if side == "right" { 1 } else { -1 }, 0))
  if dx > 0 { "west" } else if dx < 0 { "east" } else if dy > 0 { "south" } else { "north" }
}

/// Wire slot k of an n-wire element, centred within `width`.
#let _slots(n, width) = range(n).map(k => width / 2 + k - (n - 1) / 2)

// Measurement is only possible inside `context`; outside we fall back to a
// nominal layout, which is what the eagerly computed dictionary fields hold.
#let _nominal-env = (style: default-style, unit: 1cm, measured: false)

// Label extents are reported in the layout frame: when the diagram is read
// sideways, the label's width on the page runs along the element's height,
// so the two are swapped and every element sizes itself as usual.
#let _measure(env, st, body) = if env.measured {
  let s = measure(text(size: st.label.size, body))
  let (w, h) = (s.width / env.unit, s.height / env.unit)
  if st.direction in ("right", "left") { (h, w) } else { (w, h) }
} else {
  (0.0, 0.0)
}

#let _label(st, body) = text(size: st.label.size, body)

// ---------------------------------------------------------------- slot kinds
//
// 0  rigid  — the slot sits where the element puts it (a box, a triangle).
// 1  wire   — a plain wire, which may be drawn at any x but prefers its own.
// 2  arm    — the arm of a copy, unbundle or bundle, which goes wherever it is told.
//
// `link` maps an input slot to the output slot it is the same wire as, if any;
// moving one end of such a column moves the other, unless that end is held.

#let _zeros(n) = range(n).map(_ => 0)
#let _nones(n) = range(n).map(_ => none)

#let _mk(inputs, outputs, layout, kind-in: none, kind-out: none, link: none) = {
  let ki = if kind-in == none { _zeros(inputs) } else { kind-in }
  let ko = if kind-out == none { _zeros(outputs) } else { kind-out }
  // A layout that reserves no room beside its slots may leave out `in-labels`
  // and `out-labels`.
  let full = env => (in-labels: _nones(inputs), out-labels: _nones(outputs)) + layout(env)
  (
    inputs: inputs,
    outputs: outputs,
    kind-in: ki,
    kind-out: ko,
    flex-in: ki.map(k => k > 0),
    flex-out: ko.map(k => k > 0),
    flex-link: if link == none { _nones(inputs) } else { link },
    layout: full,
  ) + full(_nominal-env)
}

// The output slot each input slot is linked to, read backwards.
#let _inv-link(d) = {
  let out = _nones(d.outputs)
  for (k, v) in d.flex-link.enumerate() {
    if v != none { out.at(v) = k }
  }
  out
}

// How strong a claim a slot has on its x: rigid slots win over wires, wires
// over arms, and a slot that has already been pinned keeps its source's claim.
#let _offer(kind, auth) = if kind == 0 { 0 } else if auth == 3 { kind } else { auth }

// A region `(a, b)` of the x axis, moved by `d`.
#let _shift-region(r, d) = if r == none { none } else { (r.at(0) + d, r.at(1) + d) }

// Whether flexible slot `k` at one end of layer `l` may be moved to `x`. A
// slot may not be moved into a solid shape it does not already sit in, nor
// into the label of another wire; and a labelled wire, which takes its label
// with it, may not put the label onto a solid shape, another slot or another
// label. `labels` are the label regions of that end's slots, `noms` and
// `curs` their nominal and current positions; the layer's own coordinates
// are offset by `dx` from those of `x`.
#let _free-x(l, dx, labels, noms, curs, k, x) = {
  let inside(v, r) = r.at(0) < v and v < r.at(1)
  let overlap(r, s) = r.at(0) < s.at(1) and s.at(0) < r.at(1)
  let clear(r, s) = r == none or s == none or not overlap(r, s)
  let region(j, at) = _shift-region(labels.at(j), dx + at - noms.at(j))
  let (mine, was) = (region(k, x), region(k, noms.at(k)))
  l.spans.all(sp => {
    let s = _shift-region(sp, dx)
    (not inside(x, s) or inside(noms.at(k), s)) and (clear(mine, s) or overlap(was, s))
  }) and range(labels.len()).all(j => j == k or {
    let other = region(j, curs.at(j))
    (other == none or not inside(x, other)) and (mine == none or not inside(curs.at(j), mine)) and clear(mine, other)
  })
}

// ------------------------------------------------------------------ overrides
//
// A flexible slot can be told to end somewhere other than its natural place.
// An override is an array with one entry per slot: either `none`, or a pair
// `(x, reach)` giving the target's x in the element's own coordinates and how
// far beyond the element's edge it lies.

#let _norm(over) = if over == none or over.all(v => v == none) { none } else { over }

#let _shift(over, dx, extra) = if over == none { none } else {
  over.map(v => if v == none { none } else { (v.at(0) - dx, v.at(1) + extra) })
}

#let _slice(over, start, count) = if over == none { none } else {
  _norm(over.slice(start, start + count))
}

#let _prefer(over, fallback) = if over == none { fallback } else if fallback == none { over } else {
  over.enumerate().map(((k, v)) => if v == none { fallback.at(k) } else { v })
}

#let _entry(nominal, x, reach) = if calc.abs(x - nominal) < 1e-6 and reach == 0.0 { none } else { (x, reach) }

// Elements without flexible slots keep the plain `draw(origin)` signature.
#let _draw(l, pos, in-over: none, out-over: none) = {
  let (i, o) = (_norm(in-over), _norm(out-over))
  if i == none and o == none { (l.draw)(pos) } else { (l.draw)(pos, in-over: i, out-over: o) }
}

// ---------------------------------------------------------------- primitives

/// The monoidal unit: no wires, no extent.
#let _empty = _mk(0, 0, _env => (
  width: 0.0, height: 0.0, input-positions: (), output-positions: (), spans: (),
  draw: _o => (),
))

// An S-curve with vertical tangents at both ends.
#let _sbend(a, b, s) = {
  let (ax, ay) = a
  let (bx, by) = b
  if calc.abs(ax - bx) < 1e-6 {
    _line(a, b, stroke: s)
  } else {
    let d = (by - ay) * 0.55
    _bezier(a, b, (ax, ay + d), (bx, by - d), stroke: s)
  }
}

// Where a flexible slot ends up, given an override and its natural place.
#let _target(over, k, x, y, dir) = {
  let v = if over == none { none } else { over.at(k) }
  if v == none { (x, y) } else { (v.at(0), y + dir * v.at(1)) }
}

/// A plain vertical wire, optionally labelled beside it. Both of its ends are
/// flexible: the wire is drawn wherever the diagrams above and below need it,
/// and bends smoothly if the two ends disagree. A labelled wire makes room for
/// its label: beside it, so that `parallel` neighbours keep their distance
/// and `serial` routes nothing through it, and along it, so that a label read
/// sideways fits between the elements before and after.
#let wire(..args, label: none, length: 1, side: "right", stroke: auto) = {
  assert(args.pos().len() <= 1, message: "wire: expected at most one positional argument (the label)")
  assert(args.named().len() == 0, message: "wire: unknown argument(s) " + args.named().keys().map(repr).join(", "))
  assert(side in ("left", "right"), message: "wire: `side` must be \"left\" or \"right\"")
  let label = if args.pos().len() == 1 { args.pos().first() } else { label }
  _mk(1, 1, env => {
    let st = resolve-style(env.style)
    let stroke = if stroke == none { no-stroke } else { stroke }
    let ws = use-stroke(if stroke == auto { st.wire.stroke } else { group-style(st, "wire", (stroke: stroke)).stroke })
    let len = length * 1.0
    let (lw, lh) = if label == none { (0.0, 0.0) } else { _measure(env, st, label) }
    let extra = calc.max(0.0, st.label.sep + lw + st.margin - 0.5)
    let x0 = if side == "left" { 0.5 + extra } else { 0.5 }
    let h = if label == none { len } else { calc.max(len, lh + 2 * st.margin) }
    // The label's side of the wire's width moves with the wire when it is routed.
    let region = if label == none { none } else if side == "right" { (x0, 1.0 + extra) } else { (0.0, x0) }
    (
      width: 1.0 + extra,
      height: h,
      input-positions: (x0,),
      output-positions: (x0,),
      in-labels: (region,),
      out-labels: (region,),
      spans: (),
      draw: (o, in-over: none, out-over: none) => {
        let (ox, oy) = o
        let (bx, by) = _target(in-over, 0, x0, 0.0, -1)
        let (tx, ty) = _target(out-over, 0, x0, h, 1)
        _sbend((ox + bx, oy + by), (ox + tx, oy + ty), ws)
        if label != none {
          let d = if side == "right" { st.label.sep } else { -st.label.sep }
          _content(
            (ox + (bx + tx) / 2 + d, oy + (by + ty) / 2),
            _label(st, label),
            anchor: _side-anchor(st.direction, side),
          )
        }
      },
    )
  }, kind-in: (1,), kind-out: (1,), link: (0,))
}

/// A process box with `inputs` wires entering at the bottom and `outputs`
/// leaving at the top. The box widens to fit its label. An inline `stroke`
/// or `fill` restyles this one box (and its wire stubs).
#let process(label, inputs: 1, outputs: 1, stroke: auto, fill: auto) = _mk(inputs, outputs, env => {
  let st = resolve-style(env.style)
  let stroke = if stroke == none { no-stroke } else { stroke }
  let bst = if stroke == auto and fill == auto { st.box } else {
    group-style(st, "box", (stroke: stroke, fill: fill))
  }
  bst.stroke = use-stroke(bst.stroke)
  let ws = use-stroke(if stroke == auto { st.wire.stroke } else { group-style(st, "wire", (stroke: stroke)).stroke })
  let (lw, lh) = _measure(env, st, label)
  let m = bst.margin
  let w = calc.max(calc.max(inputs, outputs, 1) * 1.0, lw + 2 * (bst.inset + m))
  let bh = calc.max(bst.height, lh + 2 * bst.inset)
  let ins = _slots(inputs, w)
  let outs = _slots(outputs, w)
  (
    width: w,
    height: bh + 2 * st.stub,
    input-positions: ins,
    output-positions: outs,
    spans: ((m, w - m),),
    draw: o => {
      let (ox, oy) = o
      let y0 = oy + st.stub
      let y1 = y0 + bh
      for x in ins { _line((ox + x, oy), (ox + x, y0), stroke: ws) }
      for x in outs { _line((ox + x, y1), (ox + x, y1 + st.stub), stroke: ws) }
      _rect((ox + m, y0), (ox + w - m, y1), fill: bst.fill, stroke: bst.stroke)
      _content((ox + w / 2, (y0 + y1) / 2), _label(st, label))
    },
  )
})

// Geometry shared by `state` and `effect`: a triangle of width `w` and height
// `t` that is wide enough for the label at the level of the label's far edge.
#let _tri-geometry(env, st, tst, label, wires) = {
  let (lw, lh) = _measure(env, st, label)
  let m = tst.margin
  let pad = tst.inset
  let padv = pad * 1.4
  // The label sits just below the flat edge, so the triangle has to be `a` wide
  // at the label's far side, which is `b` away from that edge.
  assert(tst.aspect > 0, message: "`triangle.aspect` must be positive")
  let a = lw + 2 * pad
  let b = lh + padv
  let slots = calc.max(wires, 1) * 1.0 - 2 * m
  // With no label and no inset there is nothing to contain, and the
  // containment terms below would be 0/0.
  let (iw, t) = if st.direction in ("right", "left") {
    // Read sideways, an upright label runs towards the apex, so the triangle
    // grows in length rather than across, and `aspect` is its length over
    // its width.
    let iw = calc.max(slots, a + b / tst.aspect)
    (iw, calc.max(tst.height, if b > 0 { b * iw / (iw - a) } else { 0.0 }))
  } else {
    let t = calc.max(tst.height, b + a / tst.aspect)
    (calc.max(slots, if a > 0 { a * t / (t - b) } else { 0.0 }), t)
  }
  (w: iw + 2 * m, m: m, t: t, lh: lh, pad: padv)
}

#let _tri-style(st, stroke, fill) = {
  let stroke = if stroke == none { no-stroke } else { stroke }
  let (tst, ws) = if stroke == auto and fill == auto {
    (st.triangle, st.wire.stroke)
  } else {
    (
      group-style(st, "triangle", (stroke: stroke, fill: fill)),
      if stroke == auto { st.wire.stroke } else { group-style(st, "wire", (stroke: stroke)).stroke },
    )
  }
  tst.stroke = use-stroke(tst.stroke)
  (tst, use-stroke(ws))
}

/// A state: a downward-pointing triangle (apex at the bottom) whose outputs
/// leave the flat top edge. This is a distribution, i.e. a kernel with trivial
/// input.
#let state(label, outputs: 1, stroke: auto, fill: auto) = _mk(0, outputs, env => {
  let st = resolve-style(env.style)
  let (tst, ws) = _tri-style(st, stroke, fill)
  let g = _tri-geometry(env, st, tst, label, outputs)
  let outs = _slots(outputs, g.w)
  (
    width: g.w,
    height: g.t + st.stub,
    input-positions: (),
    output-positions: outs,
    spans: ((g.m, g.w - g.m),),
    draw: o => {
      let (ox, oy) = o
      let top = oy + g.t
      for x in outs { _line((ox + x, top), (ox + x, top + st.stub), stroke: ws) }
      _line(
        (ox + g.m, top), (ox + g.w - g.m, top), (ox + g.w / 2, oy),
        close: true, fill: tst.fill, stroke: tst.stroke,
      )
      _content((ox + g.w / 2, top - g.pad - g.lh / 2), _label(st, label))
    },
  )
})

/// An effect: the mirror image of `state`, apex at the top.
#let effect(label, inputs: 1, stroke: auto, fill: auto) = _mk(inputs, 0, env => {
  let st = resolve-style(env.style)
  let (tst, ws) = _tri-style(st, stroke, fill)
  let g = _tri-geometry(env, st, tst, label, inputs)
  let ins = _slots(inputs, g.w)
  (
    width: g.w,
    height: g.t + st.stub,
    input-positions: ins,
    output-positions: (),
    spans: ((g.m, g.w - g.m),),
    draw: o => {
      let (ox, oy) = o
      let bot = oy + st.stub
      for x in ins { _line((ox + x, oy), (ox + x, bot), stroke: ws) }
      _line(
        (ox + g.m, bot), (ox + g.w - g.m, bot), (ox + g.w / 2, bot + g.t),
        close: true, fill: tst.fill, stroke: tst.stroke,
      )
      _content((ox + g.w / 2, bot + g.pad + g.lh / 2), _label(st, label))
    },
  )
})

// An arm of a fork: it arrives at `b` vertically, and leaves `a` vertically as
// long as the target is roughly overhead, turning towards the target as the
// sideways reach grows.
#let _arm(st, a, b, s) = {
  let (ax, ay) = a
  let (bx, by) = b
  let (dx, dy) = (bx - ax, by - ay)
  if calc.abs(dx) < 1e-6 {
    _line(a, b, stroke: s)
  } else {
    let reach = calc.abs(dx) / calc.max(calc.abs(dy), 1e-6)
    let threshold = st.wire.arm-angle
    let slant = if threshold <= 0 { 1.0 } else { calc.min(1.0, calc.max(0.0, (reach - threshold) / threshold)) }
    _bezier(a, b, (ax + 0.55 * dx * slant, ay + 0.55 * dy), (bx, by - 0.55 * dy), stroke: s)
  }
}

/// Copying: one wire rises to a dot from which two arms curve to the outputs.
/// The outputs are flexible: they go wherever the diagram above needs them.
#let copy = _mk(1, 2, env => {
  let st = resolve-style(env.style)
  let ws = use-stroke(st.wire.stroke)
  (
    width: 2.0, height: 1.0, input-positions: (1.0,), output-positions: (0.5, 1.5), spans: (),
    draw: (o, in-over: none, out-over: none) => {
      let (ox, oy) = o
      let f = (ox + 1, oy + st.dot.height)
      _line((ox + 1, oy), f, stroke: ws)
      for (k, x) in (0.5, 1.5).enumerate() {
        let (tx, ty) = _target(out-over, k, x, 1.0, 1)
        _arm(st, f, (ox + tx, oy + ty), ws)
      }
      _circle(f, radius: st.dot.radius, fill: st.dot.fill, stroke: none)
    },
  )
}, kind-out: (2, 2))

/// Discarding: a wire ending in a dot (or in a ground symbol, with
/// `discard: (kind: "ground")`). Like a wire, it slides sideways to sit over
/// whatever it discards. Its dot sits at the same height as a copy's dot
/// (`dot.height`): arms only ever climb from that height, so no arm crossing
/// this layer can run through the discard's dot.
#let discard = _mk(1, 0, env => {
  let st = resolve-style(env.style)
  assert(st.discard.kind in ("dot", "ground"), message: "discard: `kind` must be \"dot\" or \"ground\"")
  let ws = use-stroke(st.wire.stroke)
  let ground = st.discard.kind == "ground"
  let h = if ground { st.dot.height + 0.25 } else { st.dot.height + st.dot.radius }
  (
    width: 1.0, height: h, input-positions: (0.5,), output-positions: (), spans: (),
    draw: (o, in-over: none, out-over: none) => {
      let (ox, oy) = o
      let (x, by) = _target(in-over, 0, 0.5, 0.0, -1)
      _line((ox + x, oy + by), (ox + x, oy + st.dot.height), stroke: ws)
      if ground {
        for (half, dy) in ((0.26, 0.0), (0.16, 0.13), (0.07, 0.24)) {
          _line((ox + x - half, oy + st.dot.height + dy), (ox + x + half, oy + st.dot.height + dy), stroke: ws)
        }
      } else {
        _circle((ox + x, oy + st.dot.height), radius: st.dot.radius, fill: st.dot.fill, stroke: none)
      }
    },
  )
}, kind-in: (1,))

/// The symmetry: two wires crossing.
#let swap = _mk(2, 2, env => {
  let ws = use-stroke(resolve-style(env.style).wire.stroke)
  (
    width: 2.0, height: 1.0, input-positions: (0.5, 1.5), output-positions: (0.5, 1.5), spans: (),
    draw: o => {
      let (ox, oy) = o
      _sbend((ox + 0.5, oy), (ox + 1.5, oy + 1), ws)
      _sbend((ox + 1.5, oy), (ox + 0.5, oy + 1), ws)
    },
  )
})

/// Drawing a product wire X (times) Y as two separate wires: a fork with no dot.
#let unbundle = _mk(1, 2, env => {
  let st = resolve-style(env.style)
  let ws = use-stroke(st.wire.stroke)
  (
    width: 2.0, height: 1.0, input-positions: (1.0,), output-positions: (0.5, 1.5), spans: (),
    draw: (o, in-over: none, out-over: none) => {
      let (ox, oy) = o
      let f = (ox + 1, oy + st.dot.height)
      _line((ox + 1, oy), f, stroke: ws)
      for (k, x) in (0.5, 1.5).enumerate() {
        let (tx, ty) = _target(out-over, k, x, 1.0, 1)
        _arm(st, f, (ox + tx, oy + ty), ws)
      }
    },
  )
}, kind-out: (2, 2))

/// The mirror image of `unbundle`: two wires drawn as one product wire.
#let bundle = _mk(2, 1, env => {
  let st = resolve-style(env.style)
  let ws = use-stroke(st.wire.stroke)
  (
    width: 2.0, height: 1.0, input-positions: (0.5, 1.5), output-positions: (1.0,), spans: (),
    draw: (o, in-over: none, out-over: none) => {
      let (ox, oy) = o
      let f = (ox + 1, oy + 1 - st.dot.height)
      for (k, x) in (0.5, 1.5).enumerate() {
        let (tx, ty) = _target(in-over, k, x, 0.0, -1)
        _arm(st, f, (ox + tx, oy + ty), ws)
      }
      _line(f, (ox + 1, oy + 1), stroke: ws)
    },
  )
}, kind-in: (2, 2))

// --------------------------------------------------------------- combinators

/// A copy of a diagram with some style keys overridden, e.g.
/// `styled(copy, stroke: red)` or `styled(d, box: (fill: blue))`.
#let styled(diagram, ..style) = {
  assert(style.pos().len() == 0, message: "styled: style overrides must be named, e.g. `styled(diagram, stroke: red)`")
  let over = style.named()
  check-style(over)
  for k in whole-diagram-keys {
    assert(k not in over, message: "styled: `" + k + "` applies to a whole diagram; pass it to `string-diagram` instead")
  }
  let over = normalize-style(over)
  _mk(
    diagram.inputs, diagram.outputs,
    kind-in: diagram.kind-in, kind-out: diagram.kind-out, link: diagram.flex-link,
    env => (diagram.layout)(env + (style: cetz.styles.merge(env.style, over))),
  )
}

// The optional `style:` argument of `serial` and `parallel`, applied via `styled`.
#let _combinator-style(name, args) = {
  let bad = args.named().keys().filter(k => k != "style")
  assert(bad.len() == 0, message: name + ": unknown named argument(s) " + bad.map(repr).join(", "))
  args.named().at("style", default: (:))
}

#let _apply-style(d, style) = if style == (:) { d } else { styled(d, ..style) }

// An input slot of a `serial` is the same wire as an output slot if the link
// survives every layer in between.
#let _chain-links(ds) = range(ds.first().inputs).map(k => {
  let j = k
  for d in ds {
    if j == none { break }
    j = d.flex-link.at(j)
  }
  j
})

/// Sequential composition, first argument at the bottom. An optional `style:`
/// argument overrides style keys for this sub-diagram.
#let serial(..args) = {
  let style = _combinator-style("serial", args)
  let ds = args.pos()
  if ds.len() == 0 { return _apply-style(_empty, style) }
  if ds.len() == 1 { return _apply-style(ds.first(), style) }
  for i in range(ds.len() - 1) {
    let (a, b) = (ds.at(i), ds.at(i + 1))
    assert(
      a.outputs == b.inputs,
      message: "serial: argument " + str(i + 1) + " has " + str(a.outputs) + " output(s) but argument "
        + str(i + 2) + " has " + str(b.inputs) + " input(s)",
    )
  }
  _apply-style(_mk(
    ds.first().inputs, ds.last().outputs,
    kind-in: ds.first().kind-in,
    kind-out: ds.last().kind-out,
    link: _chain-links(ds),
    env => {
      let n = ds.len()
      let ls = ds.map(d => (d.layout)(env))
      let ws = use-stroke(resolve-style(env.style).wire.stroke)
      let w = calc.max(..ls.map(l => l.width))
      let dxs = ls.map(l => (w - l.width) / 2)
      let invs = ds.map(_inv-link)
      // Natural slot positions, and the resolved ones with the claim behind them.
      let nb = ls.enumerate().map(((i, l)) => l.input-positions.map(x => x + dxs.at(i)))
      let nt = ls.enumerate().map(((i, l)) => l.output-positions.map(x => x + dxs.at(i)))
      let (bx, tx) = (nb, nt)
      let ba = ds.map(d => d.kind-in.map(k => if k == 0 { 0 } else { 3 }))
      let ta = ds.map(d => d.kind-out.map(k => if k == 0 { 0 } else { 3 }))
      let free-in(i, curs, k, x) = _free-x(ls.at(i), dxs.at(i), ls.at(i).in-labels, nb.at(i), curs, k, x)
      let free-out(i, curs, k, x) = _free-x(ls.at(i), dxs.at(i), ls.at(i).out-labels, nt.at(i), curs, k, x)

      // Bottom-up: every flexible slot adopts the x of the slot below it,
      // unless that slot has a weaker claim; a wire hands the x on to its far
      // end, so a whole wire column follows the box it stands on.
      for i in range(n - 1) {
        for k in range(ds.at(i).outputs) {
          let kb = ds.at(i + 1).kind-in.at(k)
          if kb == 0 { continue }
          let claim = _offer(ds.at(i).kind-out.at(k), ta.at(i).at(k))
          if claim > _offer(kb, ba.at(i + 1).at(k)) { continue }
          let x = tx.at(i).at(k)
          if not free-in(i + 1, bx.at(i + 1), k, x) { continue }
          bx.at(i + 1).at(k) = x
          ba.at(i + 1).at(k) = claim
          let j = ds.at(i + 1).flex-link.at(k)
          if j != none {
            let kf = ds.at(i + 1).kind-out.at(j)
            let af = ta.at(i + 1).at(j)
            let held = af != 3 and claim >= _offer(kf, af)
            if kf != 0 and not held and free-out(i + 1, tx.at(i + 1), j, x) {
              tx.at(i + 1).at(j) = x
              ta.at(i + 1).at(j) = claim
            }
          }
        }
      }
      // Top-down: the same from above, for slots that are not yet held.
      for i in range(n - 1).rev() {
        for k in range(ds.at(i).outputs) {
          let ka = ds.at(i).kind-out.at(k)
          if ka == 0 { continue }
          let claim = _offer(ds.at(i + 1).kind-in.at(k), ba.at(i + 1).at(k))
          if claim > _offer(ka, ta.at(i).at(k)) { continue }
          let x = bx.at(i + 1).at(k)
          if not free-out(i, tx.at(i), k, x) { continue }
          tx.at(i).at(k) = x
          ta.at(i).at(k) = claim
          let j = invs.at(i).at(k)
          if j != none {
            let kf = ds.at(i).kind-in.at(j)
            let af = ba.at(i).at(j)
            let held = af != 3 and claim >= _offer(kf, af)
            if kf != 0 and not held and free-in(i, bx.at(i), j, x) {
              bx.at(i).at(j) = x
              ba.at(i).at(j) = claim
            }
          }
        }
      }

      // Whatever still disagrees is rigid on both sides (or a wire that was not
      // allowed to move) and needs a connector band. Once a band exists, every
      // pair must be carried across it: flexible slots reach through it
      // themselves, and the connector loop below owns all rigid-rigid pairs,
      // straight or not. A band of zero height still gets its connectors,
      // which then degenerate to horizontal jogs.
      let js = range(n - 1).map(i => {
        let mism = range(ds.at(i).outputs).filter(k =>
          calc.abs(tx.at(i).at(k) - bx.at(i + 1).at(k)) > 1e-6)
        let band = if mism.len() > 0 { env.style.bend } else { 0.0 }
        let conn = if mism.len() == 0 { () } else {
          range(ds.at(i).outputs).filter(k => k in mism or (
            ds.at(i).kind-out.at(k) == 0 and ds.at(i + 1).kind-in.at(k) == 0
          ))
        }
        (band: band, mism: mism, conn: conn)
      })
      let ys = ()
      let y = 0.0
      for (i, l) in ls.enumerate() {
        ys.push(y)
        y += l.height + js.at(i, default: (band: 0.0)).band
      }

      // How far each flexible slot has to reach beyond its element's edge to
      // bridge the band, and where it has to land.
      let iovs = range(n).map(i => range(ds.at(i).inputs).map(k => {
        if ds.at(i).kind-in.at(k) == 0 { return none }
        let reach = if i == 0 { 0.0 } else {
          let j = js.at(i - 1)
          if k in j.mism { 0.0 } else if ds.at(i - 1).kind-out.at(k) > 0 { j.band / 2 } else { j.band }
        }
        _entry(nb.at(i).at(k), bx.at(i).at(k), reach)
      }))
      let oovs = range(n).map(i => range(ds.at(i).outputs).map(k => {
        if ds.at(i).kind-out.at(k) == 0 { return none }
        let reach = if i == n - 1 { 0.0 } else {
          let j = js.at(i)
          if k in j.mism { 0.0 } else if ds.at(i + 1).kind-in.at(k) > 0 { j.band / 2 } else { j.band }
        }
        _entry(nt.at(i).at(k), tx.at(i).at(k), reach)
      }))

      (
        width: w,
        height: y,
        input-positions: bx.first(),
        output-positions: tx.last(),
        // The regions follow the slots the sweeps have moved, so that an
        // enclosing serial sees the labels where they are.
        in-labels: ls.first().in-labels.enumerate().map(((k, r)) => _shift-region(r, dxs.first() + bx.first().at(k) - nb.first().at(k))),
        out-labels: ls.last().out-labels.enumerate().map(((k, r)) => _shift-region(r, dxs.last() + tx.last().at(k) - nt.last().at(k))),
        spans: {
          let out = ()
          for (i, l) in ls.enumerate() {
            for sp in l.spans { out.push((sp.at(0) + dxs.at(i), sp.at(1) + dxs.at(i))) }
          }
          out
        },
        draw: (o, in-over: none, out-over: none) => {
          let (ox, oy) = o
          for (i, l) in ls.enumerate() {
            let iov = if i == 0 { _prefer(in-over, iovs.at(0)) } else { iovs.at(i) }
            let oov = if i == n - 1 { _prefer(out-over, oovs.at(i)) } else { oovs.at(i) }
            _draw(
              l, (ox + dxs.at(i), oy + ys.at(i)),
              in-over: _shift(iov, dxs.at(i), 0.0),
              out-over: _shift(oov, dxs.at(i), 0.0),
            )
          }
          for (i, j) in js.enumerate() {
            let y0 = oy + ys.at(i) + ls.at(i).height
            let y1 = oy + ys.at(i + 1)
            for k in j.conn {
              _sbend((ox + tx.at(i).at(k), y0), (ox + bx.at(i + 1).at(k), y1), ws)
            }
          }
        },
      )
    },
  ), style)
}

/// Parallel composition, left to right. An optional `style:` argument
/// overrides style keys for this sub-diagram.
#let parallel(..args) = {
  let style = _combinator-style("parallel", args)
  let ds = args.pos()
  if ds.len() == 0 { return _apply-style(_empty, style) }
  if ds.len() == 1 { return _apply-style(ds.first(), style) }
  let links = {
    let (out, oi) = ((), 0)
    for d in ds {
      for v in d.flex-link { out.push(if v == none { none } else { v + oi }) }
      oi += d.outputs
    }
    out
  }
  _apply-style(_mk(
    ds.map(d => d.inputs).sum(default: 0),
    ds.map(d => d.outputs).sum(default: 0),
    kind-in: ds.map(d => d.kind-in).flatten(),
    kind-out: ds.map(d => d.kind-out).flatten(),
    link: links,
    env => {
      let ls = ds.map(d => (d.layout)(env))
      let ws = use-stroke(resolve-style(env.style).wire.stroke)
      let h = calc.max(..ls.map(l => l.height))
      let dxs = ()
      let x = 0.0
      for l in ls {
        dxs.push(x)
        x += l.width + env.style.gap
      }
      let w = x - env.style.gap
      // A child with no outputs connects only below, so it hugs the bottom
      // edge (and one with no inputs the top edge) instead of floating in the
      // middle, where its loose end would stray into a neighbour's wires.
      let dys = ls.enumerate().map(((i, l)) => {
        let d = ds.at(i)
        if d.outputs == 0 and d.inputs > 0 { 0.0 } else if d.inputs == 0 and d.outputs > 0 { h - l.height } else { (h - l.height) / 2 }
      })
      (
        width: w,
        height: h,
        input-positions: ls.enumerate().map(((i, l)) => l.input-positions.map(v => v + dxs.at(i))).flatten(),
        output-positions: ls.enumerate().map(((i, l)) => l.output-positions.map(v => v + dxs.at(i))).flatten(),
        in-labels: ls.enumerate().map(((i, l)) => l.in-labels.map(r => _shift-region(r, dxs.at(i)))).sum(default: ()),
        out-labels: ls.enumerate().map(((i, l)) => l.out-labels.map(r => _shift-region(r, dxs.at(i)))).sum(default: ()),
        spans: {
          let out = ()
          for (i, l) in ls.enumerate() {
            for sp in l.spans { out.push((sp.at(0) + dxs.at(i), sp.at(1) + dxs.at(i))) }
          }
          out
        },
        draw: (o, in-over: none, out-over: none) => {
          let (ox, oy) = o
          let (ii, oi) = (0, 0)
          for (i, l) in ls.enumerate() {
            let (bx, by) = (ox + dxs.at(i), oy + dys.at(i))
            let top = h - dys.at(i) - l.height
            // A child's own wires run to its edges; the gap to the parallel's
            // edges is bridged here, unless the slot is aimed somewhere else.
            let iov = _shift(_slice(in-over, ii, l.input-positions.len()), dxs.at(i), dys.at(i))
            let oov = _shift(_slice(out-over, oi, l.output-positions.len()), dxs.at(i), top)
            _draw(l, (bx, by), in-over: iov, out-over: oov)
            for (k, v) in l.input-positions.enumerate() {
              if dys.at(i) > 1e-6 and (iov == none or iov.at(k) == none) {
                _line((bx + v, oy), (bx + v, by), stroke: ws)
              }
            }
            for (k, v) in l.output-positions.enumerate() {
              if top > 1e-6 and (oov == none or oov.at(k) == none) {
                _line((bx + v, by + l.height), (bx + v, oy + h), stroke: ws)
              }
            }
            ii += l.input-positions.len()
            oi += l.output-positions.len()
          }
        },
      )
    },
  ), style)
}

// ---------------------------------------------------------- custom elements

// The resolved style as handed to a custom primitive: disabled strokes are
// already `none`, so every stroke in it can be passed to cetz as it is.
#let _drawing-style(st) = {
  for k in ("wire", "box", "triangle") {
    let g = st.at(k)
    g.stroke = use-stroke(g.stroke)
    st.insert(k, g)
  }
  st
}

/// A custom rigid element, drawn with cetz. `draw` is called as
/// `draw(style, geometry)` and returns cetz elements in unit coordinates, with
/// the origin at the bottom-left corner; `geometry` holds `width`, `height`,
/// `input-positions`, `output-positions` and a `measure` function. `width`, `height`, `input-positions` and
/// `output-positions` may each be a value or a function `(style, measure) => value`, so
/// that an element can size itself to a label. `measure(label)` reports the
/// label's extent along the element's width and height, whichever way the
/// diagram is read.
#let primitive(inputs: 1, outputs: 1, width: auto, height: 1, input-positions: auto, output-positions: auto, draw: none) = {
  assert(type(draw) == function, message: "primitive: `draw` must be a function `(style, geometry) => elements`")
  _mk(inputs, outputs, env => {
    let st = _drawing-style(resolve-style(env.style))
    let measure = body => {
      let (w, h) = _measure(env, st, body)
      (width: w, height: h)
    }
    let value(v) = if type(v) == function { v(st, measure) } else { v }
    let w = value(width)
    let w = if w == auto { calc.max(inputs, outputs, 1) * 1.0 } else { w * 1.0 }
    let h = value(height) * 1.0
    let ins = value(input-positions)
    let ins = if ins == auto { _slots(inputs, w) } else { ins.map(x => x * 1.0) }
    let outs = value(output-positions)
    let outs = if outs == auto { _slots(outputs, w) } else { outs.map(x => x * 1.0) }
    assert(ins.len() == inputs, message: "primitive: `input-positions` must have one entry per input")
    assert(outs.len() == outputs, message: "primitive: `output-positions` must have one entry per output")
    let geometry = (width: w, height: h, input-positions: ins, output-positions: outs, measure: measure)
    (
      width: w,
      height: h,
      input-positions: ins,
      output-positions: outs,
      spans: ((0.0, w),),
      draw: o => cetz.draw.group({
        cetz.draw.translate(o)
        draw(st, geometry)
      }),
    )
  })
}

// ----------------------------------------------------------------- rendering

/// Render a diagram as content, sized so that its vertical centre sits on the
/// math axis.
#let string-diagram(diagram, style: (:), baseline: auto) = context {
  check-style(style)
  let st = cetz.styles.merge(default-style, normalize-style(style))
  let u = st.unit.to-absolute()
  assert(u > 0pt, message: "`unit` must be positive")
  let l = (diagram.layout)((style: st, unit: u, measured: true))
  box(
    baseline: if baseline == auto { 50% - 0.25em } else { baseline },
    cetz.canvas(length: u, padding: st.padding, {
      _direction-transform(st.direction)
      // The canvas is at least as large as the layout, even where an element
      // draws less than its declared size.
      cetz.draw.hide(_rect((0.0, 0.0), (l.width, l.height)), bounds: true)
      (l.draw)((0.0, 0.0))
    }),
  )
}
