// craken.typ — Captain Craken slides for Typst
//
// A slide template for mathematics and computer science talks, built on the
// Captain Craken design system: plenty of paper, a few autumn colours,
// Fraunces for display, Newsreader for reading, DM Mono for code and
// STIX Two Math for mathematics.
//
//   typst init @preview/craken-slides:0.1.0 my-talk
//   typst compile talk.typ                          (Paper)
//   typst compile --input theme=lantern talk.typ    (Lantern, dark)
//
// The fonts are a separate download (see the README); without them the
// slides fall back to Libertinus Serif.

// ─────────────────────────────────────────────────────────────── tokens ──

#let palettes = (
  paper: (
    paper: rgb("#fbf7f0"),
    paper-warm: rgb("#f4eadc"),
    rule: rgb("#e3d5c1"),
    ink: rgb("#2e221b"),
    ink-soft: rgb("#6c5849"),
    rust: rgb("#a63f29"),
    amber: rgb("#8f5e0e"),
    moss: rgb("#55602e"),
    coral: rgb("#e9664e"),
    peach: rgb("#f8c597"),
  ),
  lantern: (
    paper: rgb("#1c1612"),
    paper-warm: rgb("#282019"),
    rule: rgb("#3b3029"),
    ink: rgb("#f0e6d8"),
    ink-soft: rgb("#b9a695"),
    rust: rgb("#f08b6e"),
    amber: rgb("#deac55"),
    moss: rgb("#adba7a"),
    coral: rgb("#e8735b"),
    peach: rgb("#6e4632"),
  ),
)

// The system is specified in screen px for an 18px body. On a 16:9 slide the
// body is 20pt, so every px value is scaled by the same ratio.
#let _k = 20 / 18
#let px(n) = n * _k * 1pt

#let space-1 = px(4)
#let space-2 = px(8)
#let space-4 = px(16)
#let space-6 = px(24)
#let space-8 = px(32)
#let space-12 = px(48)
#let space-24 = px(96)

#let radius-s = px(4)
#let radius-m = px(10)
#let gutter = px(40)
#let margin-column = px(200)
#let measure = 34em
#let hairline = 0.6pt
#let outline-width = px(2)

#let fonts = (
  display: ("Craken Display", "Libertinus Serif"), // Fraunces, SOFT 100, opsz 72
  label: ("Craken Label", "Libertinus Serif"), // Fraunces, SOFT 100, opsz 18
  text: ("Craken Text", "Libertinus Serif"), // Newsreader, opsz 18
  mono: ("DM Mono", "DejaVu Sans Mono"),
  math: ("STIX Two Math", "New Computer Modern Math"),
)

#let _styles = (
  chapter-title: (font: fonts.display, size: px(52), weight: 560, lh: 58 / 52, tracking: -0.01em),
  section-title: (font: fonts.display, size: px(30), weight: 600, lh: 38 / 30),
  subsection-title: (font: fonts.label, size: px(21), weight: 620, lh: 30 / 21),
  label: (font: fonts.label, size: px(15), weight: 650, lh: 22 / 15),
  lede: (font: fonts.text, size: px(22), weight: 380, lh: 34 / 22),
  body: (font: fonts.text, size: px(18), weight: 400, lh: 30 / 18),
  caption: (font: fonts.text, size: px(15), weight: 400, lh: 23 / 15),
  margin-note: (font: fonts.text, size: px(14), weight: 400, lh: 21 / 14),
  code: (font: fonts.mono, size: px(15), weight: 400, lh: 24 / 15),
)

// ──────────────────────────────────────────────────────────── internals ──

#let _theme = state("ck-theme", "paper")
#let _info = state("ck-info", (:))
#let _sec = counter("ck-section")
#let _exercise = counter("ck-exercise")
#let _ex-group = state("ck-exercise-group", false)
#let _code-title = state("ck-code-title", none)

/// The active palette. Call inside `context`.
#let colors() = palettes.at(_theme.get())

#let _paint(c, value) = if type(value) == str { c.at(value) } else { value }

/// Set content in one of the system's type styles, inline.
#let styled(name, fill: auto, body) = {
  let s = _styles.at(name)
  set text(font: s.font, size: s.size, weight: s.weight, tracking: s.at("tracking", default: 0em))
  if fill == auto { body } else { text(fill: fill, body) }
}

/// The same, as a block with the style's own line height.
#let styled-block(name, fill: auto, ..args, body) = {
  let s = _styles.at(name)
  block(..args, {
    set par(leading: (s.lh - 1) * s.size)
    styled(name, fill: fill, body)
  })
}

// Section-prefixed numbers: 2.1, 2.2, … (plain 1, 2, … before any section).
#let _fmt(s, n) = if s == 0 { str(n) } else { str(s) + "." + str(n) }
#let _numbering(..nums) = _fmt(_sec.get().first(), nums.pos().last())

// ──────────────────────────────────────────────────────────── ornament ──

/// The sucker: a ring with a dot. `open: true` draws the empty ring.
#let sucker(size: 0.62em, color: "coral", open: false) = context {
  let paint = _paint(colors(), color)
  let w = size * 0.17
  box(width: size, height: size, baseline: size / 2 - 0.34em, {
    place(center + horizon, circle(radius: size / 2 - w / 2, stroke: paint + w))
    if not open { place(center + horizon, circle(radius: size * 0.19, fill: paint)) }
  })
}

/// A break inside a section: three coral suckers.
#let section-break() = align(center, block(above: space-8, below: space-8, stack(
  dir: ltr,
  spacing: space-4,
  ..range(3).map(_ => sucker(size: px(15))),
)))

/// A curl of suckers that shrink towards the tip, like the underside of a
/// tentacle. Decoration for the title and closing slides.
#let tentacle(scale: 1, color: "coral", mirror: false) = context {
  let paint = _paint(colors(), color)
  let (w, h, cx, cy) = (300 * scale, 340 * scale, 150 * scale, 165 * scale)
  let (th0, sweep, q, big) = (60deg, 330deg, 0.22, 175 * scale)
  let pts = ()
  for k in range(601) {
    let t = k / 600
    let th = th0 - sweep * t
    let r = big * calc.pow(q, t)
    let x = cx + r * calc.cos(th)
    pts.push((if mirror { w - x } else { x }, cy + r * calc.sin(th)))
  }
  let cum = (0,)
  for k in range(1, pts.len()) {
    let (a, b) = (pts.at(k - 1), pts.at(k))
    cum.push(cum.last() + calc.sqrt(calc.pow(b.at(0) - a.at(0), 2) + calc.pow(b.at(1) - a.at(1), 2)))
  }
  let total = cum.last()
  box(width: w * 1pt, height: h * 1pt, {
    let (u, k) = (0, 0)
    while u < total * 0.985 {
      while k < cum.len() - 1 and cum.at(k) < u { k += 1 }
      let (x, y) = pts.at(k)
      let s = 40 * scale * (1 - 0.8 * u / total)
      place(top + left, dx: (x - s / 2) * 1pt, dy: (y - s / 2) * 1pt, sucker(size: s * 1pt, color: paint))
      u += s * 1.35
    }
  })
}

// ───────────────────────────────────────────────────────── text helpers ──

/// A new term, introduced once: italic semibold.
#let dfn(body) = text(style: "italic", weight: 600, body)

/// A margin note, for the `aside` column of a slide.
#let note(body) = context styled-block("margin-note", fill: colors().ink-soft, below: space-4, body)

/// Columns side by side, separated by the system's gutter.
#let cols(columns: (1fr, 1fr), ..cells) = grid(columns: columns, column-gutter: gutter, ..cells)

// ───────────────────────────────────────────────────────────── callouts ──

#let _callout(label, paint-name, body) = context {
  let c = colors()
  let paint = c.at(paint-name)
  block(
    fill: c.paper-warm,
    radius: radius-m,
    inset: (x: space-6, y: space-4),
    width: 100%,
    above: space-6,
    below: space-6,
    breakable: false,
    {
      block(below: space-2, styled("label", fill: paint)[#sucker(color: paint)#h(space-2)#label])
      body
    },
  )
}

#let tip(label: [Tip], body) = _callout(label, "amber", body)
#let question(label: [Question], body) = _callout(label, "rust", body)
#let try-this(label: [Try this], body) = _callout(label, "moss", body)

// ─────────────────────────────────────────────── mathematics and practice ──

#let _thm(kind, name, body) = figure(
  kind: "ck-thm",
  supplement: kind,
  caption: name,
  numbering: _numbering,
  outlined: false,
  body,
)

#let theorem(name: none, body) = _thm([Theorem], name, body)
#let lemma(name: none, body) = _thm([Lemma], name, body)
#let proposition(name: none, body) = _thm([Proposition], name, body)
#let corollary(name: none, body) = _thm([Corollary], name, body)
#let definition(name: none, body) = _thm([Definition], name, body)
#let example(name: none, body) = _thm([Example], name, body)

/// A proof. It ends with a sucker instead of a square.
#let proof(label: [Proof], body) = context {
  let c = colors()
  block(above: space-6, below: space-6, width: 100%)[
    #styled("label", fill: c.ink-soft, label)#h(space-2)#body#h(1fr)#sucker(size: 0.66em)
  ]
}

/// An exercise between hairlines, rated one to three suckers.
#let exercise(difficulty: 1, body) = {
  _exercise.step()
  context {
    let c = colors()
    let grouped = _ex-group.get()
    let line = hairline + c.rule
    block(
      width: 100%,
      above: if grouped { 0pt } else { space-6 },
      below: if grouped { 0pt } else { space-6 },
      inset: (y: space-2 + space-1),
      breakable: false,
      stroke: if grouped { (top: line) } else { (top: line, bottom: line) },
      {
        block(below: space-2, styled("label")[
          Exercise #text(fill: c.rust, _numbering(_exercise.get().first()))
          #h(space-4)
          #box(stack(dir: ltr, spacing: space-1, ..range(3).map(i => sucker(size: 0.66em, open: i >= difficulty))))
        ])
        body
      },
    )
  }
}

/// Several exercises in a row, with a single hairline between each.
#let exercises(body) = context {
  let c = colors()
  block(width: 100%, above: space-6, below: space-6, stroke: (bottom: hairline + c.rule), {
    _ex-group.update(true)
    body
    _ex-group.update(false)
  })
}

/// A block of code with a title, and optionally line numbers.
#let code(title: none, numbers: false, body) = {
  _code-title.update(title)
  show raw.line: it => if numbers {
    context box(width: 1.4em, align(right, text(fill: colors().ink-soft, str(it.number))))
    h(space-4)
    it.body
  } else { it }
  body
  _code-title.update(none)
}

// ─────────────────────────────────────────────────── diagrams and plots ──

/// A drawing surface. Coordinates of `node`, `edge` and `tag` are in points
/// from the top-left corner.
#let canvas(width: 400, height: 200, ..items) = box(width: width * 1pt, height: height * 1pt, items.pos().join())

/// A diagram node: a circle of radius `r`, or a rounded rectangle when `w`
/// and `h` are given. Fills: "peach" (default), "paper-warm", or any colour.
#let node(x, y, body, r: 20, w: none, h: none, fill: "peach") = context {
  let c = colors()
  let st = (paint: c.ink, thickness: outline-width, cap: "round", join: "round")
  let (bw, bh) = if w == none { (2 * r, 2 * r) } else { (w, h) }
  let at = (dx: (x - bw / 2) * 1pt, dy: (y - bh / 2) * 1pt)
  let shape = if w == none {
    circle(radius: r * 1pt, fill: _paint(c, fill), stroke: st)
  } else {
    rect(width: bw * 1pt, height: bh * 1pt, radius: radius-m, fill: _paint(c, fill), stroke: st)
  }
  place(top + left, ..at, shape)
  place(top + left, ..at, box(width: bw * 1pt, height: bh * 1pt, align(center + horizon, styled("caption", fill: c.ink, body))))
}

/// Free text on a canvas, left-aligned at (x, y), in the caption style.
#let tag(x, y, body, color: "ink-soft") = context place(
  top + left,
  dx: x * 1pt,
  dy: y * 1pt - 0.62em,
  styled("caption", fill: _paint(colors(), color), body),
)

/// An arrow between two points, shortened by `pad` at each end so it stops at
/// the edge of a node. A small open head, 2px ink.
#let edge(from, to, pad: 20, pad-end: auto, head: true, color: "ink") = context {
  let c = colors()
  let st = (paint: _paint(c, color), thickness: outline-width, cap: "round", join: "round")
  let (x1, y1) = from
  let (x2, y2) = to
  let pe = if pad-end == auto { pad } else { pad-end }
  let (dx, dy) = (x2 - x1, y2 - y1)
  let len = calc.sqrt(dx * dx + dy * dy)
  let (ux, uy) = (dx / len, dy / len)
  let (sx, sy) = (x1 + ux * pad, y1 + uy * pad)
  let (ex, ey) = (x2 - ux * pe, y2 - uy * pe)
  place(top + left, line(start: (sx * 1pt, sy * 1pt), end: (ex * 1pt, ey * 1pt), stroke: st))
  if head {
    let hl = 8
    let (cs, sn) = (calc.cos(28deg), calc.sin(28deg))
    let (vx, vy) = (-ux, -uy)
    let a = (ex + hl * (vx * cs - vy * sn), ey + hl * (vx * sn + vy * cs))
    let b = (ex + hl * (vx * cs + vy * sn), ey + hl * (-vx * sn + vy * cs))
    place(top + left, curve(
      stroke: st,
      curve.move((a.at(0) * 1pt, a.at(1) * 1pt)),
      curve.line((ex * 1pt, ey * 1pt)),
      curve.line((b.at(0) * 1pt, b.at(1) * 1pt)),
    ))
  }
}

/// A small line chart of functions, with `rule` gridlines and direct labels.
/// Each series is a dictionary: (label: [...], f: x => ..., color: "coral").
/// Colours default to the system order: coral, moss, amber, ink-soft.
#let plot(
  width: 440,
  height: 200,
  x: (0, 1),
  y: (0, 1),
  series: (),
  samples: 80,
  grid-lines: 4,
  x-label: none,
  y-label: none,
  label-room: 110,
) = context {
  let c = colors()
  let order = ("coral", "moss", "amber", "ink-soft")
  let (x0, x1) = x
  let (y0, y1) = y
  let top-room = if y-label == none { 8 } else { 30 }
  let bottom-room = if x-label == none { 0 } else { 26 }
  let pw = width - label-room
  let sx(v) = (v - x0) / (x1 - x0) * pw
  let sy(v) = top-room + height - (v - y0) / (y1 - y0) * height
  box(width: width * 1pt, height: (top-room + height + bottom-room) * 1pt, {
    for i in range(grid-lines + 1) {
      let yy = (top-room + height * i / grid-lines) * 1pt
      place(top + left, line(start: (0pt, yy), end: (pw * 1pt, yy), stroke: hairline + c.rule))
    }
    for (i, s) in series.enumerate() {
      let paint = _paint(c, s.at("color", default: order.at(calc.rem(i, 4))))
      let pts = ()
      for k in range(samples + 1) {
        let xv = x0 + (x1 - x0) * k / samples
        let yv = (s.f)(xv)
        if yv > y1 { break }
        pts.push((sx(xv) * 1pt, sy(yv) * 1pt))
      }
      place(top + left, curve(
        stroke: (paint: paint, thickness: px(2.5), cap: "round", join: "round"),
        curve.move(pts.first()),
        ..pts.slice(1).map(p => curve.line(p)),
      ))
      let (lx, ly) = pts.last()
      place(top + left, dx: lx - 3.5pt, dy: ly - 3.5pt, circle(radius: 3.5pt, fill: paint))
      place(top + left, dx: lx + space-2, dy: ly - 0.62em, styled("caption", fill: c.ink-soft, s.label))
    }
    if x-label != none {
      place(top + left, dy: (top-room + height + 8) * 1pt, box(width: pw * 1pt, align(right, styled("caption", fill: c.ink-soft, x-label))))
    }
    if y-label != none { place(top + left, styled("caption", fill: c.ink-soft, y-label)) }
  })
}

// ─────────────────────────────────────────────────────────────── slides ──

#let _kicker() = {
  let secs = query(selector(<ck-section>).before(here()))
  if secs.len() > 0 {
    let c = colors()
    [#text(fill: c.rust, str(secs.len()))#h(space-2)#text(fill: c.ink-soft, secs.last().value.title)]
  }
}

/// A content slide. `kicker` defaults to the current section; `aside` puts
/// margin notes in a column on the right.
#let slide(title: none, kicker: auto, aside: none, body) = {
  pagebreak(weak: true)
  context {
    let c = colors()
    let k = if kicker == auto { _kicker() } else { kicker }
    if k != none { block(below: space-2, styled("label", k)) }
    if title != none { styled-block("section-title", below: space-4, title) }
    if aside == none {
      block(width: measure, body)
    } else {
      grid(
        columns: (1fr, margin-column),
        column-gutter: gutter,
        body,
        styled-block("margin-note", fill: c.ink-soft, aside),
      )
    }
  }
}

/// A section opener: a big coral numeral and the section's title.
#let section-slide(title, lede: none) = {
  pagebreak(weak: true)
  _sec.step()
  for kind in (image, table, raw, "ck-thm") { counter(figure.where(kind: kind)).update(0) }
  counter(math.equation).update(0)
  _exercise.update(0)
  [#metadata((title: title)) <ck-section>]
  context {
    let c = colors()
    let n = _sec.get().first()
    let total = _sec.final().first()
    block(height: 100%, width: 100%, {
      place(bottom + left, dx: -space-2, text(
        font: fonts.display,
        weight: 560,
        size: px(290),
        fill: c.coral,
        top-edge: "cap-height",
        bottom-edge: "baseline",
        str(n),
      ))
      place(horizon + left, dx: px(250), block(width: 100% - px(250), {
        block(below: space-4, styled("label", fill: c.ink-soft)[Part #n of #total])
        styled-block("chapter-title", title)
        if lede != none { styled-block("lede", above: space-6, width: 24em, lede) }
      }))
    })
  }
}

/// The opening slide, built from the details given to `craken-slides`.
#let title-slide() = page(footer: none, context {
  let c = colors()
  let info = _info.get()
  place(bottom + right, dx: space-4, dy: space-12 + space-2, tentacle())
  if info.logo != none {
    let mark = box(width: px(76), info.logo)
    place(top + right, if _theme.get() == "lantern" {
      circle(radius: px(50), fill: palettes.paper.paper, align(center + horizon, mark))
    } else { mark })
  }
  block(height: 100%, width: 66%, {
    v(1fr)
    if info.event != none { block(below: space-6, styled("label", fill: c.rust, info.event)) }
    styled-block("chapter-title", info.title)
    if info.subtitle != none { styled-block("lede", above: space-6, width: 24em, info.subtitle) }
    v(space-12)
    styled("caption", fill: c.ink-soft)[
      #if info.author != none { text(fill: c.ink, info.author) }
      #if info.date != none [#h(space-2)·#h(space-2)#info.date]
    ]
    v(1.2fr)
  })
})

/// A map of the talk, listing every section.
#let outline-slide(title: [Where we're going]) = slide(title: title, kicker: none, context {
  let c = colors()
  let secs = query(<ck-section>)
  v(space-4)
  grid(
    columns: (px(44), 1fr),
    column-gutter: space-4,
    row-gutter: space-6 + space-2,
    align: (right + bottom, left + bottom),
    ..secs
      .enumerate()
      .map(((i, s)) => (
        text(font: fonts.display, weight: 560, size: px(32), fill: c.coral, top-edge: "cap-height", str(i + 1)),
        styled("subsection-title", s.value.title),
      ))
      .flatten(),
  )
})

/// One idea, large, with room to breathe.
#let idea-slide(kicker: [The idea], body) = {
  pagebreak(weak: true)
  context {
    let c = colors()
    block(height: 100%, width: 100%, {
      v(1fr)
      if kicker != none { block(below: space-6, styled("label", fill: c.rust, kicker)) }
      block(width: 82%, {
        set text(font: fonts.text, size: px(38), weight: 380)
        set par(leading: 0.32em)
        body
      })
      v(1.4fr)
    })
  }
}

/// A question, then the same slide again with its answer revealed. The
/// toggle follows the system: open ring while hidden, filled once shown.
#let reveal-slide(title: none, aside: none, label: [Answer], prompt, answer) = {
  let toggle(shown) = context {
    let c = colors()
    block(above: space-6, below: space-4, styled("label", fill: c.moss)[
      #sucker(color: c.moss, open: not shown)#h(space-2)#label
    ])
  }
  slide(title: title, aside: aside)[#prompt #toggle(false) #hide(answer)]
  slide(title: title, aside: aside)[#prompt #toggle(true) #answer]
}

/// The last slide.
#let closing-slide(title: [Thanks for listening], body) = page(footer: none, context {
  let c = colors()
  place(bottom + right, dx: space-2, dy: space-12 + space-2, tentacle(scale: 0.9, mirror: true))
  block(height: 100%, width: 66%, {
    v(1fr)
    styled-block("chapter-title", title)
    if body != none { styled-block("lede", above: space-6, width: 24em, body) }
    v(1.3fr)
  })
})

// ──────────────────────────────────────────────────────────── the theme ──

#let _code-theme(c) = {
  let hex(col) = col.to-hex()
  let rule(scope, fg, italic: false) = (
    "<dict><key>scope</key><string>" + scope + "</string><key>settings</key><dict>"
      + "<key>foreground</key><string>" + hex(fg) + "</string>"
      + "<key>fontStyle</key><string>" + (if italic { "italic" } else { "" }) + "</string>"
      + "</dict></dict>"
  )
  let rules = (
    rule("keyword, storage, storage.type, storage.modifier, keyword.control, keyword.other, keyword.operator.word, keyword.operator.logical.python, constant.language, variable.language, support.type.builtin", c.rust),
    rule("keyword.operator, punctuation", c.ink),
    rule("string, string.quoted, punctuation.definition.string, constant.character", c.moss),
    rule("constant.numeric", c.amber),
    rule("comment, punctuation.definition.comment", c.ink-soft, italic: true),
  )
  bytes(
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?><plist version=\"1.0\"><dict>"
      + "<key>name</key><string>Captain Craken</string><key>settings</key><array>"
      + "<dict><key>settings</key><dict><key>foreground</key><string>" + hex(c.ink)
      + "</string><key>background</key><string>" + hex(c.paper-warm) + "</string></dict></dict>"
      + rules.join()
      + "</array></dict></plist>",
  )
}

/// The template. Apply with `#show: craken-slides.with(...)`.
#let craken-slides(
  title: [Untitled talk],
  subtitle: none,
  author: none,
  date: none,
  event: none,
  short-title: auto,
  logo: none,
  theme: "paper",
  body,
) = {
  let c = palettes.at(theme)
  let short = if short-title == auto { title } else { short-title }

  set document(title: title, author: if type(author) == str { author } else { () })

  set page(
    paper: "presentation-16-9",
    fill: c.paper,
    margin: (x: space-12, top: space-6 + space-1, bottom: space-12 + space-2),
    footer-descent: space-6,
    footer: context {
      let cur = _sec.get().first()
      let total = _sec.final().first()
      styled("margin-note", fill: c.ink-soft, grid(
        columns: (1fr, auto),
        align: (left + horizon, right + horizon),
        [#if author != none [#author#h(space-2)·#h(space-2)]#short],
        stack(
          dir: ltr,
          spacing: space-2,
          ..range(1, total + 1).map(i => sucker(size: px(9), open: i > cur)),
          h(space-4),
          box(width: 2.2em, align(right, text(fill: c.rust, number-width: "tabular", str(counter(page).get().first())))),
        ),
      ))
    },
  )

  set text(
    font: fonts.text,
    size: px(18),
    fill: c.ink,
    lang: "en",
    top-edge: 0.8em,
    bottom-edge: -0.2em,
    hyphenate: false,
  )
  set par(leading: px(30 - 18), spacing: space-4, justify: false)
  set strong(delta: 200)
  set block(spacing: space-4)

  // Lists: ink-soft dashes; numbers are the author pointing, so rust.
  set list(marker: text(fill: c.ink-soft)[–], indent: 0pt, body-indent: 0.6em, spacing: space-2 + space-1)
  set enum(
    numbering: n => text(font: fonts.label, weight: 650, size: 0.9em, fill: c.rust, str(n) + "."),
    indent: 0pt,
    body-indent: 0.6em,
    spacing: space-2 + space-1,
  )

  // Headings inside a slide read as subsection titles.
  show heading: it => styled-block("subsection-title", above: space-6, below: space-2, it.body)

  // Links to the web are rust and underlined.
  show link: it => if type(it.dest) == str {
    underline(offset: 2.5pt, stroke: 0.7pt + c.rust, text(fill: c.rust, it))
  } else { it }

  // Cross-references are rust, and always carry the section of their target.
  show ref: it => {
    let el = it.element
    if el == none or el.func() not in (math.equation, figure) { return text(fill: c.rust, it) }
    let loc = el.location()
    let s = _sec.at(loc).first()
    let (n, sup) = if el.func() == math.equation {
      (counter(math.equation).at(loc).first(), [Equation])
    } else {
      (counter(figure.where(kind: el.kind)).at(loc).first(), el.supplement)
    }
    if it.supplement != auto { sup = it.supplement }
    let num = if el.func() == math.equation { "(" + _fmt(s, n) + ")" } else { _fmt(s, n) }
    link(loc, text(fill: c.rust)[#sup~#num])
  }

  // Mathematics: STIX Two Math, 1.06× the text around it. Display equations
  // are numbered (section.n) only when they carry a label.
  show math.equation: set text(font: fonts.math, size: 1.06em, top-edge: "bounds", bottom-edge: "bounds")
  set math.equation(numbering: n => text(fill: c.ink-soft, "(" + _numbering(n) + ")"))
  show math.equation.where(block: true): set block(above: space-6, below: space-6)
  show math.equation.where(block: true): it => {
    if it.numbering != none and not it.has("label") [
      #counter(math.equation).update(v => v - 1)
      #math.equation(it.body, block: true, numbering: none)<ck-unnumbered>
    ] else { it }
  }

  // Code: DM Mono on paper-warm, four colour roles.
  set raw(theme: _code-theme(c))
  show raw: set text(font: fonts.mono)
  show raw.where(block: false): it => box(
    fill: c.paper-warm,
    radius: radius-s,
    inset: (x: space-1),
    outset: (y: 0.28em),
    text(size: 0.86em / 0.8, it),
  )
  show raw.where(block: true): it => context block(
    fill: c.paper-warm,
    radius: radius-m,
    inset: (x: space-6, y: space-4),
    width: 100%,
    above: space-6,
    below: space-6,
    breakable: false,
    {
      let t = _code-title.get()
      if t != none {
        block(
          width: 100%,
          below: space-4,
          inset: (bottom: space-2),
          stroke: (bottom: hairline + c.rule),
          styled("caption", fill: c.ink-soft, t),
        )
      }
      set text(size: _styles.code.size)
      set par(leading: (_styles.code.lh - 1) * _styles.code.size)
      it
    },
  )

  // Figures on open paper; the label ("Figure 2.1") in rust.
  set figure(numbering: _numbering, gap: space-4)
  show figure: set block(above: space-6, below: space-6)
  show figure.caption: it => styled-block("caption", fill: c.ink-soft)[
    #styled("label", fill: c.rust)[#it.supplement #context it.counter.display(it.numbering)]#h(space-2)#it.body
  ]

  // Theorem-like statements: label in ink, number in rust, name in ink-soft.
  show figure.where(kind: "ck-thm"): it => {
    set align(left)
    block(width: 100%, above: space-6, below: space-6, {
      block(below: space-2, styled("label")[
        #it.supplement #text(fill: c.rust, it.counter.display(it.numbering))
        #if it.caption != none {
          h(space-2)
          text(font: fonts.text, weight: 400, style: "italic", fill: c.ink-soft, it.caption.body)
        }
      ])
      it.body
    })
  }

  // Tables: hairlines between rows, tabular numbers, label-style header.
  set table(
    stroke: (_, y) => (bottom: hairline + c.rule),
    inset: (x: space-2 + space-1, y: space-2 + space-1),
    align: left + horizon,
  )
  show table: set text(number-width: "tabular")
  show table.cell.where(y: 0): set text(font: fonts.label, weight: 650, size: _styles.label.size)

  _theme.update(theme)
  _info.update((title: title, subtitle: subtitle, author: author, date: date, event: event, logo: logo))
  body
}
