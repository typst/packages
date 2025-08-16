#let _cn = counter("cardnumber")
#let _ch = state("h", "init")
#let _cq = state("q", "init")
#let _ca = state("a", "init")
#let card(question, hint, answer) = [
  #_cn.step()
  #_ch.update(hint)
  #_cq.update(question)
  #_ca.update(answer)
  <card>
]

#let cut = (
  thickness: 0.5pt,
  dash: "dashed",
  cap: "round",
  paint: luma(80%),
)

#let parse-term(it) = {
  let a = it.description

  let h = if it.term.has("children") {
    if it.term.children.contains[---] {
      it
        .term
        .children
        .slice(it.term.children.position(i => { i == [---] }) + 1)
        .join()
      // .dedup()
      // .sum(default: [])
    } else {
      it.term.children.sum()
    }
  } else { it.term }

  let q = if it.term.has("children") {
    if it.term.children.contains[---] {
      it
        .term
        .children
        .slice(0, it.term.children.position(i => { i == [---] }))
        .join()
      // .dedup()
      // .sum()
    }
  } else []

  return (q, h, a)
}

#let resize(body) = layout(container => {
  let size = measure(body)
  let ratio = calc.max(
    calc.min(
      (container.width) / (size.width * 1.3),
      (container.height) / (size.height * 1.3),
    )
      * 100%,
    75%,
  )
  scale(ratio, body, reflow: true)
})

#let front(g, q, h, n, f, d) = box(width: d.w, height: d.h)[
  #g <group>
  #q <question>
  #h <hint>
  #[#n/#f] <cards>
  #n <currentcard>
  #f <finalcard>
]
#let back(a, n, f, d) = box(width: d.w, height: d.h)[
  #a <answer>
  #[#n/#f] <cards>
  #n <currentcard>
  #f <finalcard>
]


#let build(q, a, t) = {
  let q1 = text(fill: white.transparentize(100%), q.first())
  let ao = ()
  let ae = ()
  let up = t.c * t.r
  let rem = calc.rem(q.len(), up)

  if rem != 0 {
    for i in range(up - rem) {
      q.push(q1)
      a.push(q1)
    }
  }

  let a = if t.c == 2 {
    for i in range(a.len()) {
      if calc.even(i) { ao.push(a.at(i)) } else { ae.push(a.at(i)) }
    }

    ae.zip(ao).flatten()
  } else { a }

  grid(
    columns: t.c, stroke: cut,
    ..q.chunks(up).zip(a.chunks(up)).flatten()
  )
}

#let types = (
  a48: (w: 210mm / 2, h: 297mm / 4, c: 2, r: 4, pw: 210mm, ph: 297mm),
  letter8: (w: 8.5in / 2, h: 11in / 4, c: 2, r: 4, pw: 8.5in, ph: 11in),
  business: (w: 3.5in, h: 2in, c: 2, r: 5, pw: 8.5in, ph: 11in),
  index: (w: 5in, h: 3in, c: 1, r: 3, pw: 8.5in, ph: 11in),
)

#let perforate(dimensions: types.letter8, body) = {
  set page(width: dimensions.pw, height: dimensions.ph, margin: (
    y: (dimensions.ph - dimensions.h * dimensions.r) / 2,
    x: (dimensions.pw - dimensions.w * dimensions.c) / 2,
  ))

  show terms.item: it => {
    if it.term.has("children") and it.term.children.contains[---] {
      card(..parse-term(it))
    } else { it }
  }

  show heading: it => []

  context {
    let locs = query(<card>)
    let q = ()
    let a = ()

    for loc in locs {
      let cg = query(selector(heading).before(loc.location())).last().body
      let ch = _ch.at(loc.location())
      let cq = _cq.at(loc.location())
      let ca = _ca.at(loc.location())
      let cn = _cn.at(loc.location()).first()
      let cf = _cn.final().first()
      q.push(front(cg, cq, ch, cn, cf, dimensions))
      a.push(back(ca, cn, cf, dimensions))
    }

    build(q, a, dimensions)
  }

  body
}

#let g(g) = place(top + left, dy: 0.5cm, dx: 0.5cm, text(
  size: 0.85em,
  smallcaps(g),
))
#let nf(nf) = place(top + right, dy: 0.5cm, dx: -0.5cm, text(size: 0.85em, nf))
#let q(q) = place(horizon + center, dy: -1cm, box(inset: 0.5cm, text(
  size: 1.1em,
  strong(q),
)))
#let h(h) = place(bottom + right, dy: -0.5cm, dx: -0.5cm, text(
  size: 0.9em,
  emph(h),
))
#let a(a) = place(horizon + center, align(left, box(inset: 0.5cm, resize(a))))
#let n(n) = { }
#let f(f) = { }

#let latex(body) = {
  set text(font: "New Computer Modern", size: 11pt)
  set par(leading: .6em, linebreaks: "optimized")
  set block(spacing: 1.5em)
  set list(marker: ([•], [◦], [--]))

  show <hint>: it => h(it)
  show <question>: it => q(it)
  show <answer>: it => a(it)
  show <group>: it => g(it)
  show <cards>: it => nf(it)
  show <currentcard>: it => n(it)
  show <finalcard>: it => f(it)
  body
}
