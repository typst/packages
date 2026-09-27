// ===========================================================================
//  sketchbook/blocks.typ — content blocks that size themselves.
//
//  Every block here is a normal Typst element: it takes the available width
//  from `layout()`, measures its own content, and draws a hand-drawn frame at
//  exactly that size. Nothing is positioned in absolute cm, so blocks flow in
//  running text, nest, break across pages, and work in RTL.
// ===========================================================================

#import "@preview/cetz:0.5.2"
#import "engine.typ" as eng
#import "theme.typ": theme-state, heading-weight

#let PT-PER-CM = 28.3465
#let to-cm(l) = l / 1cm

// A per-document seed counter, so consecutive blocks never share a wobble.
#let seed-counter = counter("sketchbook-seed")

/// Resolve the seed for a block: explicit value, or the next auto one.
#let next-seed(seed, base) = context {
  if seed != auto { seed } else { base + seed-counter.get().first() * 17 }
}

// ---------------------------------------------------------------------------
//  internal: draw a canvas of exactly (w, h) with y running downward
// ---------------------------------------------------------------------------
#let canvas-at(w, h, draw-body) = {
  // CeTZ y-up, but we hand it a box of known size: use (0,0) top-left and
  // negative y downward so the caller can think in "layout" coordinates.
  cetz.canvas(length: 1cm, {
    import cetz.draw: *
    draw-body(to-cm(w), to-cm(h))
  })
}

// ---------------------------------------------------------------------------
//  sketch-box — the workhorse
// ---------------------------------------------------------------------------
/// A hand-drawn box that fits its content.
///
/// - `shape`: "rect" | "round" | "burst" | "ellipse" | "none"
/// - `fill` / `stroke-colour`: default to the theme accent
/// - `width`: `auto` (fill available) or a length/ratio
#let sketch-box(
  body,
  shape: "round",
  fill: none,   // renamed internally to box-fill to avoid shadowing
  stroke-colour: auto,
  stroke-weight: auto,
  radius: auto,
  pad: auto,
  width: auto,
  seed: auto,
  roughness: auto,
  hatch: none,          // e.g. (angle: 45, spacing: 0.16) to hatch the inside
  shadow: none,         // a colour to drop a soft shadow behind
  depth: 0,             // >0 extrudes the box (flat 3D), in cm
  inset-top: 0pt,       // extra room reserved above the content
  passes: 1,            // draw the outline N times (2 = sketched twice)
  pass-offset: 0.06,    // how far apart the passes sit, cm
  curl: 0.42,           // corner curl for shape: "plaque"
  text-fill: auto,      // colour for the content
  breakable: false,     // see the note below
) = context {
  let th = theme-state.get()
  let col = if stroke-colour == auto { th.accent } else { stroke-colour }
  let sw = if stroke-weight == auto { th.stroke-weight } else { stroke-weight }
  let p = if pad == auto { th.pad } else { pad }
  let rad = if radius == auto { th.radius } else { radius }
  let rough = if roughness == auto { th.roughness } else { roughness }
  let box-fill = fill
  let sd = if seed == auto { th.seed + seed-counter.get().first() * 17 } else { seed }
  let opts = (amplitude: 0.5 * rough, wavelength: 100.0 / calc.max(rough, 0.2))

  seed-counter.step()

  // A hand-drawn frame is ONE canvas of a known size, so it cannot be split
  // across pages. When the caller opts into `breakable`, fall back to a
  // native Typst block whose stroke *can* break -- the shape is still themed,
  // it just loses the wobble. Documented in the guide.
  if breakable {
    return block(
      width: if width == auto { 100% } else { width },
      inset: p + 0.10cm,
      radius: rad * 1cm * 0.8,
      fill: box-fill,
      stroke: (paint: col, thickness: sw),
      breakable: true,
      body,
    )
  }

  layout(avail => {
    let outer-w = if width == auto { avail.width } else {
      if type(width) == ratio { avail.width * width } else { width }
    }
    // room the frame itself needs outside the content
    let bleed = if shape == "burst" { 0.55cm }
      else if passes > 1 { sw + pass-offset * 1cm }
      else { sw }
    let ext = if depth > 0 { depth * 1cm } else { 0pt }

    let inner-w = outer-w - 2 * p - 2 * bleed - ext
    // NB: place(top+left) below resets alignment; align(start) keeps RTL
    // content on the right edge (and LTR on the left).
    let inner = box(width: inner-w, align(start, body))
    let m = measure(inner)
    let inner-h = m.height + inset-top
    let outer-h = inner-h + 2 * p + 2 * bleed + ext

    block(width: outer-w, height: outer-h, breakable: breakable, {
      place(top + left, canvas-at(outer-w, outer-h, (W, H) => {
        import cetz.draw: *
        let b = to-cm(bleed)
        let e = to-cm(ext)
        let a = (b, -(H - b))
        let c = (W - b - e, -b)
        let pts = if shape == "round" {
          eng.rounded-rect-pts(a, c, radius: rad)
        } else if shape == "plaque" {
          eng.plaque-pts(a, c, curl: curl)
        } else if shape == "stadium" {
          eng.stadium-pts(a, c)
        } else if shape == "burst" {
          eng.starburst-pts(a, c, spacing: 0.44, spike: 0.40, jitter: 0.9,
            seed: sd)
        } else if shape == "ellipse" {
          eng.ellipse-pts(((a.at(0) + c.at(0)) / 2, (a.at(1) + c.at(1)) / 2),
            (c.at(0) - a.at(0)) / 2, (c.at(1) - a.at(1)) / 2)
        } else {
          eng.rect-pts(a, c)
        }

        if shadow != none {
          let s = pts.map(q => (q.at(0) + 0.10, q.at(1) - 0.10))
          eng.s-line(s, seed: sd + 91, closed: true, fill: shadow,
            stroke: none, opts: opts)
        }
        if depth > 0 {
          eng.extrude-sides(pts, (e, -e), fill: col.lighten(25%),
            stroke: (paint: col, thickness: sw, join: "round"),
            seed: sd + 40, opts: opts)
        }
        if hatch != none {
          eng.s-line(pts, seed: sd, closed: true, fill: box-fill,
            stroke: none, opts: opts)
          let h = (angle: 45, spacing: 0.16, shrink: 0.08) + hatch
          eng.s-hatch((pts,), angle: h.angle, spacing: h.spacing,
            shrink: h.shrink, seed: sd + 300,
            stroke: (paint: col, thickness: 0.7pt))
        }
        if shape != "none" {
          // `stroke-colour: none` => fill only, no outline
          let st = if col == none { none }
            else { (paint: col, thickness: sw, join: "round") }
          eng.s-line(pts, seed: sd, closed: true,
            fill: if hatch == none { box-fill } else { none },
            stroke: st, opts: opts)
          // extra passes: the same outline drawn again, slightly offset, so
          // it reads like a line gone over twice by hand
          for k in range(1, passes) {
            let d = pass-offset * k
            let p2 = pts.map(q => (q.at(0) + d * 0.6, q.at(1) - d))
            if col != none {
              eng.s-line(p2, seed: sd + 137 * k, closed: true, fill: none,
                stroke: (paint: col, thickness: sw, join: "round"),
                opts: opts)
            }
          }
        }
      }))
      place(top + left, dx: p + bleed, dy: p + bleed + inset-top,
        if text-fill == auto { inner } else { text(fill: text-fill, inner) })
    })
  })
}

// ---------------------------------------------------------------------------
//  highlighter pill behind inline text
// ---------------------------------------------------------------------------
/// Inline highlighter pen. The stroke is sized and positioned from the
/// measured text box, so it *fills* the words instead of underlining them,
/// and it sits correctly on the baseline for any font size.
#let highlight(
  body,
  colour: auto,
  seed: auto,
  expand: 0.14em,   // how far the ink bleeds past the words
  lift: 0.0em,      // manual vertical nudge, if you want one
) = context {
  let th = theme-state.get()
  let c = if colour == auto { th.palette.hilite } else { colour }
  let sd = if seed == auto { th.seed + 7 } else { seed }

  let m = measure(body)
  // Centre the pen on the glyphs themselves. measure() on the *body* already
  // carries the local text size, so derive everything from it rather than
  // from a 1em probe (which would use the outer size and sit too high).
  // Probed empirically: with place(top+left), dy = m.height * k walks DOWN
  // from the top of the glyph box (k=0 top, k=1 baseline). The optical centre
  // of the x-height band sits a little above the middle.
  let mid = m.height * 0.54
  let thick = m.height * 0.92

  let ex = measure(box(width: expand)).width
  let lf = measure(box(height: lift)).height

  box(baseline: 0pt, {
    // the inline box's top is at dy = -m.height relative to the baseline
    place(top + left, dx: -ex, dy: mid + lf,
      cetz.canvas(length: 1cm, {
        import cetz.draw: *
        let w = to-cm(m.width + 2 * ex)
        eng.s-line(((to-cm(ex) * 0.35, 0), (w - to-cm(ex) * 0.35, 0)),
          seed: sd,
          stroke: (paint: c, thickness: thick, cap: "round"),
          opts: (amplitude: 0.18, wavelength: 300))
      }))
    body
  })
}

// ---------------------------------------------------------------------------
//  definition card: term + body, with an optional examples row
// ---------------------------------------------------------------------------
#let def-card(
  term,
  body,
  examples: none,
  examples-label: auto,
  colour: auto,
  seed: auto,
  open-frame: true,      // the marker frame whose ends never meet
  ..rest,
) = context {
  let th = theme-state.get()
  let col = if colour == auto { th.accent } else { colour }
  let dir = th.dir
  let s = if dir == rtl { -1.0 } else { 1.0 }
  let sd = if seed == auto { th.seed + seed-counter.get().first() * 17 } else { seed }
  let label = if examples-label != auto { examples-label } else {
    if dir == rtl { [أمثلة:] } else { [EXAMPLES:] }
  }
  seed-counter.step()

  let p = th.pad
  layout(avail => {
    let W = avail.width
    let inner-w = W - 2 * p - 0.55cm
    let head = box(width: inner-w, align(start)[
      #text(font: th.fonts.heading, weight: heading-weight(dir),
        size: th.size * 1.15, fill: th.ink, term)
      #h(0.25em)
      #body
    ])
    let ex-block = if examples != none {
      box(width: inner-w, align(start)[
        #box(height: 1.15em)[]
        #text(font: th.fonts.heading, weight: heading-weight(dir),
          size: th.size * 0.98, fill: th.ink, label)
        #h(0.6em)
        #examples
      ])
    } else { none }

    let mh = measure(head)
    let me = if ex-block != none { measure(ex-block) } else { (height: 0pt) }
    // NB: mixing pt and em gives a relative length that cannot be divided,
    // so resolve the gap to an absolute size before using it in arithmetic.
    let gap-h = if examples != none { measure(box(height: 0.5em)).height } else { 0pt }
    let inner-h = mh.height + me.height + gap-h
    let H = inner-h + 2 * p + 0.5cm

    block(width: W, height: H, {
      place(top + left, canvas-at(W, H, (Wc, Hc) => {
        import cetz.draw: *
        let m = to-cm(p) * 0.5
        let x0 = m
        let x1 = Wc - m
        let y0 = -(Hc - m)
        let y1 = -m
        let lx = if dir == rtl { x1 } else { x0 }
        let tx = if dir == rtl { x0 } else { x1 }
        let st = (paint: col, thickness: th.stroke-weight * 2.2,
          join: "round", cap: "round")
        let gap = 0.26
        let pts = if open-frame {
          ((lx, y0 + gap * 2.2), (lx, y1 - 0.08), (lx + 0.08 * s, y1),
           (tx - 0.08 * s, y1), (tx, y1 - 0.08), (tx, y0 + 0.08),
           (tx - 0.10 * s, y0), (lx + gap * 3.0 * s, y0))
        } else {
          eng.rounded-rect-pts((x0, y0), (x1, y1), radius: th.radius)
        }
        eng.s-line(pts, seed: sd, closed: not open-frame, stroke: st,
          opts: (amplitude: 0.3 * th.roughness, wavelength: 200))
      }))
      place(top + left, dx: p + 0.28cm, dy: p + 0.25cm, head)
      if ex-block != none {
        place(top + left, dx: p + 0.28cm, dy: p + 0.25cm + mh.height + gap-h, ex-block)
      }
    })
  })
}

// ---------------------------------------------------------------------------
//  banner: an open frame with an optional icon and speech tail / hook arrow
// ---------------------------------------------------------------------------
#let banner(
  title,
  icon: none,
  icon-size: 26pt,
  tail: "speech",        // "speech" | "hook" | "none"
  sparks: true,
  colour: auto,
  title-fill: auto,
  title-size: auto,
  seed: auto,
  drop: 1.25,            // how far a hook arrow reaches below the frame
) = context {
  let th = theme-state.get()
  let col = if colour == auto { th.accent } else { colour }
  let tf = if title-fill == auto { th.palette.red } else { title-fill }
  let ts = if title-size == auto { th.size * 2.0 } else { title-size }
  let dir = th.dir
  let s = if dir == rtl { -1.0 } else { 1.0 }
  let sd = if seed == auto { th.seed + seed-counter.get().first() * 17 } else { seed }
  seed-counter.step()

  let has-icon = icon != none
  let use-tail = if not has-icon { "none" } else { tail }

  layout(avail => {
    let W = avail.width
    let side = if has-icon { 1.7cm } else { 0.35cm }
    // shrink the title until it fits the available width on one line
    let avail-text = W - 2 * side - 0.6cm
    let ttl = text(font: th.fonts.heading, weight: heading-weight(dir),
      size: ts, fill: tf, title)
    let m = measure(box(ttl))
    if m.width > avail-text and m.width > 0pt {
      let k = avail-text / m.width
      ttl = text(font: th.fonts.heading, weight: heading-weight(dir),
        size: ts * calc.max(k, 0.35), fill: tf, title)
      m = measure(box(ttl))
    }
    let H = m.height + 2 * th.pad + 0.45cm
    let below = if use-tail == "hook" { drop * 1cm + 0.9cm } else { 0pt }

    block(width: W, height: H + below, {
      place(top + left, canvas-at(W, H + below, (Wc, Hc) => {
        import cetz.draw: *
        let bh = to-cm(H)
        let sw = to-cm(side)
        let x0 = if dir == rtl { 0.18 } else { sw }
        let x1 = if dir == rtl { Wc - sw } else { Wc - 0.18 }
        let y1 = -0.18
        let y0 = -(bh - 0.18)
        let lx = if dir == rtl { x1 } else { x0 }
        let tx = if dir == rtl { x0 } else { x1 }
        let st = (paint: col, thickness: th.stroke-weight * 2.6,
          join: "round", cap: "round")
        let op = (amplitude: 0.55 * th.roughness, wavelength: 190)

        if use-tail == "speech" {
          eng.s-line(
            ((tx - 0.30 * s, y1), (lx, y1), (lx, y0),
             (lx - 0.30 * s, y0 - 0.42), (lx + 0.46 * s, y0 + 0.02),
             (tx - 0.10 * s, y0)),
            seed: sd, stroke: st, opts: op)
          eng.s-line(((tx, y1 - 0.12), (tx, y0 + 0.30)), seed: sd + 1,
            stroke: st, opts: op)
        } else {
          eng.s-line(((tx - 0.35 * s, y1), (lx, y1), (lx, y0),
            (tx - 0.35 * s, y0)), seed: sd, stroke: st, opts: op)
          if use-tail == "hook" {
            let ax = tx + 0.55 * s
            eng.s-line(((tx - 0.42 * s, y1 - 0.18), (ax, y1 - 0.14),
              (ax, y0 - drop + 0.30)), seed: sd + 1, stroke: st, opts: op)
            let hy = y0 - drop + 0.34
            eng.s-line(((ax - 0.30, hy + 0.22), (ax, hy - 0.30),
              (ax + 0.30, hy + 0.22)), seed: sd + 2, stroke: st, opts: op)
          }
        }

        if has-icon and sparks and use-tail == "speech" {
          let ix = lx - 1.05 * s
          let iy = (y0 + y1) / 2 - 0.28
          for k in range(6) {
            let ang = 118deg - k * 26deg
            eng.s-line((
              (ix + 0.60 * calc.cos(ang) * s, iy + 0.60 * calc.sin(ang)),
              (ix + 0.80 * calc.cos(ang) * s, iy + 0.80 * calc.sin(ang)),
            ), seed: sd + 20 + k,
              stroke: (paint: th.palette.cyan, thickness: 2.2pt, cap: "round"))
          }
        }
      }))

      // the icon, placed in layout space so it never clips
      if has-icon {
        let ix = if use-tail == "hook" {
          if dir == rtl { 0.1cm } else { W - 1.5cm }
        } else {
          if dir == rtl { W - 1.55cm } else { 0.15cm }
        }
        let iy = if use-tail == "hook" { H + drop * 1cm - 0.5cm }
                 else { H / 2 - 0.55cm }
        place(top + left, dx: ix, dy: iy,
          text(font: th.fonts.emoji, size: icon-size, icon))
      }
      place(top + left, dx: 0pt, dy: th.pad + 0.10cm,
        box(width: W, align(center, ttl)))
    })
  })
}

// ---------------------------------------------------------------------------
//  numbered answer item: highlighted badge + value
// ---------------------------------------------------------------------------
#let answer(number, value, colour: auto, value-fill: auto, seed: auto) = context {
  let th = theme-state.get()
  let c = if colour == auto { th.palette.hilite } else { colour }
  let vf = if value-fill == auto { th.palette.navy } else { value-fill }
  let sd = if seed == auto { th.seed + 5 } else { seed }
  block(spacing: 0.55em)[
    #highlight(colour: c, seed: sd,
      text(weight: "bold", fill: th.ink, number))
    #h(0.45em)
    #text(size: th.size * 1.1, fill: vf, value)
  ]
}

// ---------------------------------------------------------------------------
//  extras: fraction, sticky note, page decoration
// ---------------------------------------------------------------------------
#let frac(num, den, colour: auto, size: auto, seed: 1) = context {
  let th = theme-state.get()
  let c = if colour == auto { th.palette.navy } else { colour }
  let sz = if size == auto { th.size } else { size }
  // `frac(3, 4)` is the obvious way to write a fraction, but CeTZ's
  // `content` only takes content — a bare integer reaches `text(.., num)`
  // and the compile dies. Accept numbers and strings too.
  let as-content(v) = if type(v) == content { v } else { [#v] }
  let num = as-content(num)
  let den = as-content(den)
  box(baseline: 38%, cetz.canvas(length: 1cm, {
    import cetz.draw: *
    content((0, 0.31), text(size: sz, fill: c, num))
    eng.s-line(((-0.25, 0.13), (0.25, 0.13)), seed: seed,
      stroke: (paint: c, thickness: 0.9pt),
      opts: (amplitude: 0.25, wavelength: 200))
    content((0, -0.05), text(size: sz, fill: c, den))
  }))
}

#let sticky(body, width: 4cm, angle: -3deg, colour: auto, seed: 1) = context {
  let th = theme-state.get()
  let c = if colour == auto { th.palette.cream } else { colour }
  layout(_ => {
    let inner = box(width: width - 0.8cm, align(start, body))
    let m = measure(inner)
    let H = m.height + 0.8cm
    rotate(angle, reflow: true, block(width: width, height: H, {
      place(top + left, canvas-at(width, H, (W, Hc) => {
        import cetz.draw: *
        let pts = eng.rect-pts((0.06, -(Hc - 0.06)), (W - 0.06, -0.06))
        eng.s-line(pts.map(q => (q.at(0) + 0.07, q.at(1) - 0.07)),
          seed: seed + 3, closed: true, fill: luma(232), stroke: none,
          opts: (amplitude: 0.3, wavelength: 280))
        eng.s-line(pts, seed: seed, closed: true, fill: c,
          stroke: (paint: luma(214), thickness: 0.7pt),
          opts: (amplitude: 0.32, wavelength: 280))
      }))
      place(top + left, dx: 0.4cm, dy: 0.4cm, inner)
    }))
  })
}
