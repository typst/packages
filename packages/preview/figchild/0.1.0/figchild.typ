// ============================================================================
// figchild.typ — a faithful Typst port of the LaTeX package `figchild`
//                (Figures for Creating Children's Activities), v3.1.2
//
//   Original package (LPPL 1.3c): Fernando de Souza Bastos, UFV, 2021–2026
//   https://ctan.org/pkg/figchild
//
//   This port reproduces the 561 TikZ figures of the original package as
//   data, and renders them with two backends:
//
//     • `render`  — exact reproduction through CeTZ 0.5.2
//     • `scrawl`  — a hand-drawn variant through Scrawl 0.1.0
//
//   The generated figures live in `figures.typ` (do not edit by hand);
//   this file only contains the engine.
//
//   Usage:
//     #import "figchild.typ" as figchild
//     #import "figures.typ": *
//
//     #figchild.canvas(fc-owl-a())                  // exact rendering
//     #figchild.canvas(fc-owl-a(scale: 0.5))        // TikZ-like options
//     #figchild.scrawl(fc-dino(), seed: 2)          // hand-drawn style
//
//   Figures may be combined inside a single canvas:
//     #cetz.canvas({
//       ..figchild.render(fc-owl-a())
//       ..figchild.render(fc-ball(rotate: 30deg))
//     })
// ============================================================================

#import "@preview/cetz:0.5.2"
#import "@preview/scrawl:0.1.0" as sdraw

#let figchild-version = "3.1.2"
#let figchild-date = "2026-05-29"

// ---------------------------------------------------------------------------
// Colours used by the original package (TikZ/xcolor names)
// ---------------------------------------------------------------------------
#let _colors = (
  "black": rgb("#000000"),
  "white": rgb("#ffffff"),
  "gray": rgb("#808080"),
  "red": rgb("#ff0000"),
  "blue": rgb("#0000ff"),
  // xcolor "black!0.8" = 0.8% black
  "black!0.8": rgb("#fdfcfc"),
)

#let _res-color(c) = {
  if type(c) == str {
    if c in _colors { _colors.at(c) } else { rgb(c) }
  } else {
    c
  }
}

// ---------------------------------------------------------------------------
// Figure data
// ---------------------------------------------------------------------------
/// Builds the data of a figure. Not meant to be called directly:
/// the generated functions in `figures.typ` do it for you.
///
/// - name (str): LaTeX command name, e.g. "fcOwlA"
/// - bbox (4-tuple): (x-min, y-min, x-max, y-max) in centimetres
/// - entries (array): list of (style-dictionary, ops) pairs, one per
///   `\draw` statement of the original package
/// - ..style: user options applied like the optional argument of the
///   original macros, e.g. `scale: 0.5, rotate: 45deg, fill: red`

#let figure(name, bbox, entries, ..style) = (
  name: name,
  bbox: bbox,
  entries: entries,
  style: style.named(),
)

// ---------------------------------------------------------------------------
// CeTZ backend — exact reproduction of the TikZ drawings
// ---------------------------------------------------------------------------

/// Renders a figure as a list of CeTZ elements.
///
/// Use inside `cetz.canvas`: `#cetz.canvas({ ..figchild.render(fc-owl-a()) })`
/// or with the convenience wrapper `figchild.canvas(fig, ..style)`.


#let _cm-mat(m) = (
  (m.at(0), m.at(1), 0, m.at(4)),
  (m.at(2), m.at(3), 0, m.at(5)),
  (0, 0, 1, 0),
  (0, 0, 0, 1),
)

// Resolve the stroke for one entry (TikZ: draw=..., line width=...)

#let _entry-stroke(s, user) = {
  // user overrides entry; entry overrides the default
  let paint = if "stroke" in user {
    if user.stroke == none { none } else { _res-color(user.stroke) }
  } else if "stroke" in s {
    if s.stroke == "none" { none } else { _res-color(s.stroke) }
  } else {
    _res-color("black")
  }
  if paint == none { return none }

  let thickness = if "stroke-width" in user {
    user.stroke-width
  } else if "line-width" in s {
    s.line-width
  } else {
    0.5pt
  }
  let dash = if "dash" in user {
    user.dash
  } else if "dash" in s {
    if s.dash == "loosely-dotted" { (0.5pt, 4pt) } else { (3pt, 3pt) }
  } else {
    none
  }
  if dash == none {
    (paint: paint, thickness: thickness)
  } else {
    (paint: paint, thickness: thickness, dash: dash)
  }
}


#let _entry-fill(s, user) = {
  if "fill" in user {
    if user.fill == none { none } else { _res-color(user.fill) }
  } else if "fill" in s {
    _res-color(s.fill)
  } else {
    none
  }
}

// Build the CeTZ element for one `\draw` statement.

#let _cetz-ops(ops, fill, stroke) = {
  // NOTE: Typst closures capture outer variables by value and cannot
  // mutate them, so all state flows through explicit arguments/returns.
  // `state` is (out, start, segs, closed).
  let emit(state) = {
    let (out, start, segs, closed) = state
    if start != none and segs.len() > 0 {
      // capture by value: the closure reads only its own arguments
      let (st, sg, cl) = (start, segs, closed)
      out.push((ctx => {
        let d = cetz.drawable.path(
          (cetz.path-util.make-subpath(st, sg, closed: cl),),
          fill: fill,
          fill-rule: "non-zero",
          stroke: stroke,
        )
        // Apply the current canvas transform (scale/rotate/shift/cm):
        // unlike the cetz shape helpers, raw `drawable.path` does NOT do
        // this itself — without it, user transforms are silently lost.
        (ctx: ctx, drawables: cetz.drawable.apply-transform(ctx.transform, d))
      }))
    }
    (out, none, (), false)
  }
  let state = ((), none, (), false)
  for op in ops {
    let k = op.at(0)
    if k == "M" {
      state = emit(state)
      state = (state.at(0), (op.at(1), op.at(2)), state.at(2), state.at(3))
    } else if k == "L" {
      if state.at(1) != none {
        state.at(2).push(("l", (op.at(1), op.at(2))))
      }
    } else if k == "C" {
      if state.at(1) != none {
        state.at(2).push((
          "c",
          (op.at(1), op.at(2)),
          (op.at(3), op.at(4)),
          (op.at(5), op.at(6)),
        ))
      }
    } else if k == "Z" {
      if state.at(1) != none {
        state = (state.at(0), state.at(1), state.at(2), true)
      }
    } else if k == "circle" {
      state = emit(state)
      state.at(0) += cetz.draw.circle(
        (op.at(1), op.at(2)),
        radius: op.at(3),
        fill: fill,
        stroke: stroke,
      )
    } else if k == "ellipse" {
      state = emit(state)
      state.at(0) += cetz.draw.circle(
        (op.at(1), op.at(2)),
        radius: (op.at(3), op.at(4)),
        fill: fill,
        stroke: stroke,
      )
    } else if k == "arc" {
      state = emit(state)
      state.at(0) += cetz.draw.arc(
        (op.at(1), op.at(2)),
        start: op.at(3) * 1deg,
        stop: op.at(4) * 1deg,
        radius: (op.at(5), op.at(6)),
        fill: fill,
        stroke: stroke,
      )
    } else if k == "rect" {
      state = emit(state)
      state.at(0) += cetz.draw.rect(
        (op.at(1), op.at(2)),
        (op.at(3), op.at(4)),
        fill: fill,
        stroke: stroke,
      )
    }
  }
  state = emit(state)
  state.at(0)
}

#let _entry-cetz(entry, user) = {
  let (s, ops) = entry
  let body = ()

  // Figure-level (user) transforms first: TikZ applies `[figchild/default,
  // #1]` at picture level, so user options wrap each statement.
  // Note: cetz 0.5.2 elements are 1-element arrays, so we concatenate.
  if "rotate" in user { body += cetz.draw.rotate(user.rotate) }
  if "scale" in user { body += cetz.draw.scale(user.scale) }
  if "shift" in user { body += cetz.draw.translate(user.shift) }
  if "transform" in user { body += cetz.draw.transform(user.transform) }

  // Statement-level transforms (TikZ: rotate=, shift=, cm=)
  // `rotate` is stored as a plain degree number in the generated data.
  if "rotate" in s { body += cetz.draw.rotate(s.rotate * 1deg) }
  if "shift" in s { body += cetz.draw.translate(s.shift) }
  if "cm" in s { body += cetz.draw.transform(_cm-mat(s.cm)) }

  let fill = _entry-fill(s, user)
  let stroke = _entry-stroke(s, user)

  body += _cetz-ops(ops, fill, stroke)
  cetz.draw.group(body)
}


#let render(fig, ..style) = {
  // Merge the options given to the `fc-…` call (fig.style, e.g.
  // `fc-owl-a(scale: 0.5)`) with the options given to `render`/`canvas`
  // (the latter take precedence).
  let user = fig.style + style.named()
  let out = ()
  for entry in fig.entries {
    out += _entry-cetz(entry, user)
  }
  out
}

/// Convenience wrapper: renders a figure inside a full CeTZ canvas.
/// - padding (length): extra space around the drawing (CeTZ's bounds do
///   not include the stroke thickness, TikZ's do; 0.15cm keeps the 0.5pt
///   default stroke — and even 5pt strokes — comfortably inside)
#let canvas(fig, padding: 0.15cm, ..style) = cetz.canvas(
  padding: padding,
  render(fig, ..style),
)



// ---------------------------------------------------------------------------
// Point sampling (used by the Scrawl backend)
// ---------------------------------------------------------------------------

#let _sample-cubic(p0, p1, p2, p3, n: 16) = {
  range(n + 1).map(i => {
    let t = i / n
    let mt = 1 - t
    (
      mt * mt * mt * p0.at(0) + 3 * mt * mt * t * p1.at(0)
        + 3 * mt * t * t * p2.at(0) + t * t * t * p3.at(0),
      mt * mt * mt * p0.at(1) + 3 * mt * mt * t * p1.at(1)
        + 3 * mt * t * t * p2.at(1) + t * t * t * p3.at(1),
    )
  })
}

// Convert one figure's op list into (points, closed) polylines.

// Trigonometry on plain numbers interpreted as degrees.
#let _cos(x) = calc.cos(x * 1deg)
#let _sin(x) = calc.sin(x * 1deg)

// Apply the user-level and statement-level affine transforms to a point.
// Same composition order as the CeTZ backend: user transforms are applied
// first (outermost), then the statement transforms of the original `\draw`.
#let _apply-transforms(p, s, user) = {
  let (x, y) = p
  let apply-rotate(a) = {
    let c = _cos(a)
    let sn = _sin(a)
    (x * c - y * sn, x * sn + y * c)
  }
  // user-level
  if "rotate" in user {
    (x, y) = apply-rotate(user.rotate / 1deg)
  }
  if "scale" in user {
    x = x * user.scale
    y = y * user.scale
  }
  if "shift" in user {
    x = x + user.shift.at(0)
    y = y + user.shift.at(1)
  }
  // statement-level
  if "rotate" in s {
    (x, y) = apply-rotate(s.rotate)
  }
  if "shift" in s {
    x = x + s.shift.at(0)
    y = y + s.shift.at(1)
  }
  if "cm" in s {
    let m = s.cm
    let (nx, ny) = (
      m.at(0) * x + m.at(1) * y + m.at(4),
      m.at(2) * x + m.at(3) * y + m.at(5),
    )
    (x, y) = (nx, ny)
  }
  (x, y)
}


#let _scrawl-shapes(ops) = {
  // State flows through explicit arguments/returns (Typst closures cannot
  // mutate captured variables). state = (out, cur, closed).
  let emit(state) = {
    let (out, cur, closed) = state
    if cur.len() >= 2 {
      out.push((cur, closed))
    }
    (out, (), false)
  }
  let state = ((), (), false)
  for op in ops {
    let kind = op.at(0)
    if kind == "M" {
      state = emit(state)
      state = (state.at(0), ((op.at(1), op.at(2)),), state.at(2))
    } else if kind == "L" {
      state.at(1).push((op.at(1), op.at(2)))
    } else if kind == "C" {
      state.at(1) += _sample-cubic(
        state.at(1).last(),
        (op.at(1), op.at(2)),
        (op.at(3), op.at(4)),
        (op.at(5), op.at(6)),
      ).slice(1)
    } else if kind == "Z" {
      state = (state.at(0), state.at(1), true)
    } else if kind == "circle" {
      state = emit(state)
      let (x, y, r) = (op.at(1), op.at(2), op.at(3))
      state.at(0).push((
        range(40).map(i => {
          let a = i / 40 * 360
          (x + r * _cos(a), y + r * _sin(a))
        }),
        true,
      ))
    } else if kind == "ellipse" {
      state = emit(state)
      let (x, y, rx, ry) = (op.at(1), op.at(2), op.at(3), op.at(4))
      state.at(0).push((
        range(40).map(i => {
          let a = i / 40 * 360
          (x + rx * _cos(a), y + ry * _sin(a))
        }),
        true,
      ))
    } else if kind == "arc" {
      state = emit(state)
      let (x, y, a0, a1, rx, ry) = (
        op.at(1), op.at(2), op.at(3), op.at(4), op.at(5), op.at(6),
      )
      let d = calc.abs(a1 - a0)
      let n = calc.max(8, calc.ceil(d / 15))
      state.at(0).push((
        range(n + 1).map(i => {
          let a = a0 + (a1 - a0) * i / n
          let (cx, cy) = (x - rx * _cos(a0), y - ry * _sin(a0))
          (cx + rx * _cos(a), cy + ry * _sin(a))
        }),
        false,
      ))
    } else if kind == "rect" {
      state = emit(state)
      let (x1, y1, x2, y2) = (op.at(1), op.at(2), op.at(3), op.at(4))
      state.at(0).push((((x1, y1), (x2, y1), (x2, y2), (x1, y2)), true))
    }
  }
  state = emit(state)
  state.at(0)
}


#let scrawl(fig, margin: 0.3, seed: 1, roughness: 1.0, hand: true, ..style) = {
  let user = fig.style + style.named()
  let (x0, y0, x1, y1) = fig.bbox
  // Apply user-level transforms (scale/rotate/shift) to the bounding box so
  // the canvas size matches the transformed drawing.
  let corners = ((x0, y0), (x1, y0), (x1, y1), (x0, y1)).map(
    p => _apply-transforms(p, (:), user)
  )
  let xs = corners.map(p => p.at(0))
  let ys = corners.map(p => p.at(1))
  (x0, y0, x1, y1) = (
    calc.min(..xs), calc.min(..ys), calc.max(..xs), calc.max(..ys),
  )
  let w = (x1 - x0) + 2 * margin
  let h = (y1 - y0) + 2 * margin

  // scrawl passes its helpers as positional arguments of the body function:
  // body(shape, lines, region, rough, label, arrow)
  sdraw.scrawl(
    width: w * 1cm,
    height: h * 1cm,
    hand: hand,
    seed: seed,
    roughness: roughness,
    (shape, lines, region, rough, label, arrow) => {
      for entry in fig.entries {
        let (s, ops) = entry
        let fill = _entry-fill(s, user)
        let stroke = _entry-stroke(s, user)
        let paint = if stroke == none { none } else { stroke.paint }
        let weight = if stroke == none { 0pt } else { stroke.thickness }

        for shp in _scrawl-shapes(ops) {
          let (pts, closed) = shp
          // apply transforms of this statement
          let tpts = pts.map(p => _apply-transforms(p, s, user))
          if tpts.len() >= 2 {
            shape(
              tpts,
              fill: if fill == none { none } else { fill },
              paint: paint,
              weight: weight,
              closed: closed,
            )
          }
        }
      }
    },
  )
}

