// ilkman — generative cover art. Every art function draws into a w × h box.
#import "../core.typ": *

#let _canvas(w, h, items) = box(width: w, height: h, clip: true, {
  for it in items { it }
})

// ---------------------------------------------------------------- waveform
#let art-waveform(w, h, pal, seed, opts, dark: false) = {
  let o = (bars: 40, shape: "round", mirror: true, accent-every: 5) + opts
  let n = o.bars
  let rnd = rand-seq(seed, n + 4)
  let p1 = rnd.at(n) * 2 + 0.5
  let p2 = rnd.at(n + 1) * 3
  let step = w / n
  let bw = step * 0.55
  let items = ()
  for i in range(n) {
    let env = calc.abs(calc.sin(i * 0.37 * p1 + p2) * calc.cos(i * 0.11 + p2))
    let v = 0.12 + 0.88 * (0.65 * env + 0.35 * rnd.at(i))
    let bh = h * 0.9 * v
    let y = if o.mirror { (h - bh) / 2 } else { h - bh }
    let acc = o.accent-every != none and calc.rem(i, o.accent-every) == 0
    let col = if dark { if acc { pal.accent } else { pal.tint } } else { if acc { pal.primary } else { pal.accent.lighten(30%) } }
    items.push(place(top + left, dx: i * step + (step - bw) / 2, dy: y, rect(width: bw, height: bh, radius: if o.shape == "round" { bw / 2 } else { 0pt }, fill: col)))
  }
  _canvas(w, h, items)
}

// --------------------------------------------------------------------- pcm
#let art-pcm(w, h, pal, seed, opts, dark: false) = {
  let o = (samples: 24, levels: 8, show-wave: true, stems: true) + opts
  let rnd = rand-seq(seed, 4)
  let a = 11 + rnd.at(0) * 7
  let b = 2 + rnd.at(1) * 2.5
  let ph = rnd.at(2) * 6.28
  let f(t) = calc.sin(t * a + ph) * (0.35 + 0.65 * calc.abs(calc.cos(t * b + ph / 2))) * 0.9
  let mid = h / 2
  let amp = h * 0.45
  let items = ()
  let fg = if dark { pal.tint } else { pal.primary }
  let soft = if dark { pal.accent } else { pal.tint }
  items.push(place(top + left, line(start: (0pt, mid), end: (w, mid), stroke: 0.6pt + soft)))
  if o.show-wave {
    let pts = range(121).map(i => {
      let t = i / 120
      (w * t, mid - f(t) * amp)
    })
    items.push(place(top + left, curve(stroke: 1pt + soft, curve.move(pts.first()), ..pts.slice(1).map(p => curve.line(p)))))
  }
  let q = o.levels / 2
  for k in range(o.samples) {
    let t = (k + 0.5) / o.samples
    let v = calc.round(f(t) * q) / q
    let x = w * t
    let y = mid - v * amp
    if o.stems { items.push(place(top + left, line(start: (x, mid), end: (x, y), stroke: 1.6pt + fg))) }
    items.push(place(top + left, dx: x - 3.2pt, dy: y - 3.2pt, circle(radius: 3.2pt, fill: fg)))
  }
  _canvas(w, h, items)
}

// --------------------------------------------------------------------- topo
#let art-topo(w, h, pal, seed, opts, dark: false) = {
  let o = (rings: 9, center: (70%, 30%), wobble: 0.15) + opts
  let rnd = rand-seq(seed, 6)
  let cx = w * o.center.at(0)
  let cy = h * o.center.at(1)
  let unit = calc.max(w, h) / (o.rings * 1.1)
  let items = ()
  for k in range(1, o.rings + 1) {
    let pts = range(97).map(i => {
      let t = i / 96 * 2 * calc.pi
      let r = k * unit * (1 + o.wobble * calc.sin(3 * t + k * 0.5 + rnd.at(0) * 6) + o.wobble * 0.55 * calc.cos(5 * t + rnd.at(1) * 6))
      (cx + r * calc.cos(t), cy + r * 0.9 * calc.sin(t))
    })
    let col = if calc.rem(k, 3) == 0 { if dark { pal.accent } else { pal.primary } } else { if dark { pal.tint.transparentize(30%) } else { pal.accent.lighten(25%) } }
    items.push(place(top + left, curve(stroke: (if calc.rem(k, 3) == 0 { 1.1pt } else { 0.7pt }) + col, curve.move(pts.first()), ..pts.slice(1).map(p => curve.line(p)), curve.close())))
  }
  _canvas(w, h, items)
}

// ----------------------------------------------------------------- halftone
#let art-halftone(w, h, pal, seed, opts, dark: false) = {
  let o = (grid: 20, origin: "top-left", falloff: 1.0) + opts
  let step = w / o.grid
  let rows = calc.ceil(h / step)
  let (ox, oy) = (
    "top-left": (0, 0), "top-right": (1, 0), "center": (0.5, 0.5),
    "bottom-left": (0, 1), "bottom-right": (1, 1),
  ).at(o.origin)
  let maxd = calc.sqrt(calc.pow(calc.max(ox, 1 - ox), 2) + calc.pow(calc.max(oy, 1 - oy) * h / w, 2))
  let items = ()
  let col = if dark { pal.tint } else { pal.primary }
  for y in range(rows) {
    for x in range(o.grid) {
      let fx = (x + 0.5) / o.grid
      let fy = (y + 0.5) * step / w
      let d = calc.sqrt(calc.pow(fx - ox, 2) + calc.pow(fy - oy * h / w, 2)) / maxd
      let r = step * 0.48 * calc.max(0, 1 - d * 1.15 * o.falloff)
      if r > 0.4pt {
        items.push(place(top + left, dx: x * step + step / 2 - r, dy: y * step + step / 2 - r, circle(radius: r, fill: col)))
      }
    }
  }
  _canvas(w, h, items)
}

// ------------------------------------------------------------------- neural
#let art-neural(w, h, pal, seed, opts, dark: true) = {
  let o = (layers: (12, 6, 8, 6, 3), highlight: 2, edges: 0.7) + opts
  let L = o.layers.len()
  let pts = o.layers.enumerate().map(((li, n)) => range(n).map(k => (
    w * (0.08 + 0.84 * li / calc.max(1, L - 1)),
    h * (0.06 + 0.88 * (k + 0.5) / n),
  )))
  let edge-col = (if dark { pal.tint } else { pal.accent }).transparentize(100% - o.edges * 60%)
  let items = ()
  for li in range(L - 1) {
    for a in pts.at(li) {
      for b in pts.at(li + 1) {
        items.push(place(top + left, line(start: a, end: b, stroke: 0.35pt + edge-col)))
      }
    }
  }
  let base-r = calc.min(w, h) * 0.022
  for (li, layer) in pts.enumerate() {
    let r = if li == 0 { base-r * 0.6 } else { base-r }
    let col = if o.highlight != none and li == o.highlight { if dark { pal.wash } else { pal.accent } } else { if dark { pal.tint } else { pal.primary } }
    for p in layer {
      items.push(place(top + left, dx: p.at(0) - r, dy: p.at(1) - r, circle(radius: r, fill: col)))
    }
  }
  _canvas(w, h, items)
}

// ----------------------------------------------------------------- minimap
#let art-minimap(w, h, pal, seed, opts, dark: false) = {
  let o = (lines: 46, max-indent: 3, viewport: (30%, 50%)) + opts
  let rnd = rand-seq(seed, o.lines * 12)
  let lh = h / o.lines
  let syn = if dark { (pal.wash, pal.tint, pal.accent, pal.tint.darken(10%)) } else { (pal.ink, pal.primary, pal.accent, pal.accent.lighten(40%)) }
  let items = ()
  if o.viewport != none {
    let (a, b) = o.viewport
    items.push(place(top + left, dy: h * a, rect(width: w, height: h * (b - a), fill: (if dark { pal.wash } else { pal.primary }).transparentize(88%))))
  }
  let ind = 0
  for i in range(o.lines) {
    let y = i * lh + lh * 0.25
    let r0 = rnd.at(calc.rem(i * 7, rnd.len()))
    if r0 < 0.12 { continue }
    let r1 = rnd.at(calc.rem(i * 7 + 1, rnd.len()))
    if r1 < 0.25 { ind = calc.min(o.max-indent, ind + 1) } else if r1 < 0.5 { ind = calc.max(0, ind - 1) }
    let x = w * 0.06 + ind * w * 0.07
    let segs = 1 + int(rnd.at(calc.rem(i * 7 + 2, rnd.len())) * 4)
    for s in range(segs) {
      if x > w * 0.9 { break }
      let sw = w * (0.04 + 0.16 * rnd.at(calc.rem(i * 7 + 3 + s, rnd.len())))
      sw = calc.min(sw, w * 0.92 - x)
      let col = syn.at(int(rnd.at(calc.rem(i * 11 + s, rnd.len())) * 4))
      items.push(place(top + left, dx: x, dy: y, rect(width: sw, height: lh * 0.5, radius: lh * 0.25, fill: col)))
      x += sw + w * 0.02
    }
  }
  _canvas(w, h, items)
}

// ---------------------------------------------------------------- gitgraph
#let art-gitgraph(w, h, pal, seed, opts, dark: false) = {
  let o = (branch: "main", lanes: 4, commits: 18, merges: 0.3) + opts
  let rnd = rand-seq(seed, o.commits * 3 + 5)
  let lanes = o.lanes
  let lx(l) = w * (0.15 + 0.7 * l / calc.max(1, lanes - 1))
  let cols = (pal.primary, pal.accent, pal.accent.lighten(35%), pal.ink)
  let lc(l) = if dark { (pal.wash, pal.tint, pal.accent, pal.tint.darken(15%)).at(calc.rem(l, 4)) } else { cols.at(calc.rem(l, 4)) }
  let step = h / (o.commits + 1)
  let r = calc.min(step * 0.32, w * 0.03)
  let sw = calc.max(1.5pt, w * 0.011)
  let active = (0,)
  let last-y = ("0": 0pt)
  let items = ()
  let dots = ()
  for i in range(o.commits) {
    let y = step * (i + 1)
    let ra = rnd.at(i * 3)
    let rb = rnd.at(i * 3 + 1)
    let lane = active.at(int(ra * active.len()))
    let from = last-y.at(str(lane), default: none)
    if from != none {
      items.push(place(top + left, line(start: (lx(lane), from), end: (lx(lane), y), stroke: sw + lc(lane))))
    }
    last-y.insert(str(lane), y)
    dots.push((lx(lane), y, lane))
    // branch off or merge back
    if rb < o.merges and i < o.commits - 2 {
      let free = range(lanes).filter(l => l not in active)
      if free.len() > 0 and rnd.at(i * 3 + 2) < 0.6 {
        let nl = free.first()
        active.push(nl)
        let y2 = y + step
        items.push(place(top + left, curve(stroke: sw + lc(nl), curve.move((lx(lane), y)), curve.cubic((lx(lane), y + step * 0.6), (lx(nl), y2 - step * 0.6), (lx(nl), y2)))))
        last-y.insert(str(nl), y2)
      } else if active.len() > 1 and lane != 0 {
        let target = active.at(0)
        let y2 = y + step
        items.push(place(top + left, curve(stroke: sw + lc(lane), curve.move((lx(lane), y)), curve.cubic((lx(lane), y + step * 0.6), (lx(target), y2 - step * 0.6), (lx(target), y2)))))
        active = active.filter(l => l != lane)
        let _ = last-y.remove(str(lane))
      }
    }
  }
  for l in active {
    let from = last-y.at(str(l), default: none)
    if from != none { items.push(place(top + left, line(start: (lx(l), from), end: (lx(l), h), stroke: sw + lc(l)))) }
  }
  let bg = if dark { pal.primary } else { white }
  for (x, y, l) in dots {
    items.push(place(top + left, dx: x - r, dy: y - r, circle(radius: r, fill: bg, stroke: sw + lc(l))))
  }
  _canvas(w, h, items)
}

// ---------------------------------------------------------------------- bits
#let art-bits(w, h, pal, seed, opts, title: "", fonts: none, dark: false) = {
  let o = (text: auto, group: 8, highlight: 9) + opts
  let src = if o.text == auto { title } else { o.text }
  if src == "" { src = "ilkman" }
  let bits = array(bytes(src + " ")).map(b => str(b, base: 2)).map(s => "0" * (8 - s.len()) + s).join("")
  let size = calc.max(9pt, w / 34)
  let font = if fonts != none { fonts.code.font } else { ("DejaVu Sans Mono",) }
  let cw = measure(text(font: font, size: size, "0")).width
  let per-line = int(w / cw) - 1
  let lines = calc.max(1, int(h / (size * 1.25)))
  let total = per-line * lines
  let on = if dark { pal.wash } else { pal.primary }
  let off = if dark { pal.accent.transparentize(30%) } else { color.mix((pal.accent, 35%), (white, 65%), space: rgb) }
  let hi = if dark { pal.accent.lighten(30%) } else { pal.accent }
  let ones = 0
  let out = ()
  let col = 0
  for i in range(total) {
    let b = bits.at(calc.rem(i, bits.len()))
    let c = if b == "1" {
      ones += 1
      if o.highlight != none and calc.rem(ones, o.highlight) == 0 { hi } else { on }
    } else { off }
    out.push(text(fill: c, b))
  }
  let lh = h / lines
  box(width: w, height: h, clip: true, {
    set text(font: font, size: size, weight: "bold")
    for l in range(lines) {
      block(height: lh, spacing: 0pt, width: w, align(horizon, out.slice(l * per-line, (l + 1) * per-line).join()))
    }
  })
}

// -------------------------------------------------------------------- packet
#let art-packet(w, h, pal, opts, c, title: none, author: none, date: none, dark: false) = {
  let o = (fields: ("V=2", "PT", "seq", "SSRC"), bits: 32, ruler: true, footer: auto) + opts
  let line-c = pal.primary
  let mono = font-args(c.fonts, "code")
  let fs = calc.max(9pt, w / 24)
  let cell(body, fill: none, fg: pal.ink, span: 1) = table.cell(colspan: span, fill: fill, inset: (x: 0.6em, y: 0.65em), text(fill: fg, body))
  let nf = o.fields.len()
  let foot = (if o.footer == auto { (author, date).filter(x => x != none) } else { o.footer }).map(x => if type(x) == datetime { x.display() } else { x })
  if foot.len() > nf { foot = foot.slice(0, nf - 1) + (foot.slice(nf - 1).join("  ·  "),) }
  box(width: w, {
    set text(..mono, size: fs)
    if o.ruler {
      grid(columns: (1fr, 1fr, 1fr), text(fill: pal.ink.lighten(50%), "0"), align(center, text(fill: pal.ink.lighten(50%), str(int(o.bits / 2) - 1))), align(right, text(fill: pal.ink.lighten(50%), str(o.bits - 1))))
      v(0.3em)
    }
    table(
      columns: (1fr,) * nf,
      stroke: 0.8pt + line-c,
      ..o.fields.enumerate().map(((i, f)) => cell(f, fill: if i == 0 { pal.wash } else { none })),
      table.cell(colspan: nf, fill: pal.primary, inset: (x: 0.6em, y: 1.6em), text(..font-args(c.fonts, "heading"), weight: c.fonts.heading.weight, size: fs * 1.9, fill: white, title)),
      ..if foot.len() > 0 {
        let span = calc.max(1, int(nf / foot.len()))
        foot.enumerate().map(((i, f)) => table.cell(colspan: if i == foot.len() - 1 { nf - span * (foot.len() - 1) } else { span }, inset: (x: 0.6em, y: 0.65em), text(fill: pal.ink, f)))
      } else { () },
    )
  })
}
