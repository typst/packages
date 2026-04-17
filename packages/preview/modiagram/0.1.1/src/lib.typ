// ─────────────────────────────────────────────────────────────────────────────
// modiagram — Molecular Orbital Diagrams for Typst
// Version: 0.1.0
// License: MIT
//
// Inspired by the LaTeX modiagram package by Clemens Niederberger (v0.3a).
// Requires: @preview/cetz:0.4.2
//
// ── USAGE ─────────────────────────────────────────────────────────────────────
//
//   Recommended — import as a named module to avoid shadowing Typst built-ins:
//
//     #import "@preview/modiagram:0.1.0" as mo
//
//     #figure({
//       import mo: *
//       modiagram(
//         ao(name: "1s-L", x: 0,   energy: 0,     electrons: "pair", label: $1s$),
//         ao(name: "1s-R", x: 3.5, energy: 0,     electrons: "pair", label: $1s$),
//         ao(name: "σ",    x: 1.75, energy: -0.65, electrons: "pair", label: $sigma$),
//         ao(name: "σ*",  x: 1.75, energy:  0.65, electrons: "",     label: $sigma^*$),
//         connect("1s-L & σ", "1s-R & σ", "1s-L & σ*", "1s-R & σ*"),
//         energy-axis(title: [Energy], style: "horizontal"),
//         // optionally add x-axis (connects automatically with energy-axis):
//         // x-axis(title: [x]),
//       )
//     })
//
//   Note: wrapping in a scoped block ({ import mo: * … }) keeps all modiagram
//   names local and prevents them from shadowing Typst built-ins (line, grid, …)
//   in the rest of the document.
//
// ── NAME CONFLICTS WITH TYPST BUILT-INS ──────────────────────────────────────
//
//   modiagram exports wrappers named line, circle, rect, arc, grid, content —
//   these shadow the Typst built-ins of the same name when using star imports.
//
//   Solutions (in order of preference):
//     1. Scoped block import (shown above) — cleanest, zero leakage
//     2. std.grid(...) / std.line(...) — always reaches the Typst built-in
//     3. mo-grid / mo-line / mo-rect / mo-arc / mo-circle / mo-content —
//        alias exports identical to the modiagram wrappers, no collision
//
// ── COORDINATES ───────────────────────────────────────────────────────────────
//
//   x and energy refer to the CENTER of the orbital bar.
//   All coordinates accept: float (implicit cm), or any Typst length (cm, pt, em).
//
// ── ELECTRONS ─────────────────────────────────────────────────────────────────
//
//   Pass a space-separated string of spin tokens to the electrons: parameter:
//     "up"    one spin-up electron    ↑
//     "down"  one spin-down electron  ↓
//     "pair"  paired electrons        ↑↓
//
//   Multiple tokens are valid: electrons: "up down" draws both on the same bar.
//
// ── ORBITAL STYLES ────────────────────────────────────────────────────────────
//
//   "plain"   horizontal line only (default)   → connect defaults to dotted
//   "square"  true square box                  → connect defaults to solid
//   "round"   square box with rounded corners  → connect defaults to solid
//   "circle"  circle with side extensions      → connect defaults to solid
//   "fancy"   rounded box with side extensions → connect defaults to dashed
//
// ── CONNECTION STYLES ─────────────────────────────────────────────────────────
//
//   "dotted"  dotted line  (default for plain)
//   "dashed"  dashed line  (default for fancy)
//   "solid"   solid line   (default for square / round / circle)
//   "gray"    solid gray line
//
// ── POSITION FORMS ────────────────────────────────────────────────────────────
//
//   Accepted by all cetz wrappers (line, content, circle, …):
//
//   (x, y)                        numeric tuple — scaled by x-scale / energy-scale
//   "name"                        center of the orbital named "name"
//   "name.edge"                   named edge: left | right | top | bottom | center
//   ("pos1", percentage%, "pos2") linear interpolation between two positions
//   rel(dx, dy)                   relative offset from the previous point (scaled)
//
//   Extra keyword arguments available on all wrappers:
//     pad:   outward offset along the edge direction (meaningful for string forms)
//     dx:    additional x offset applied after position resolution
//     dy:    additional y offset applied after position resolution
//
// ── PRIORITY CHAIN ────────────────────────────────────────────────────────────
//
//   Per-element parameter → config() inline override → modiagram(config:) dict
//   → modiagram-setup() global → built-in defaults
//
// ── PUBLIC API ────────────────────────────────────────────────────────────────
//
//   Diagram elements (pass as positional arguments to modiagram):
//
//   ao(name, x, energy, electrons, label, color, bar-color, el-color,
//      label-color, style, label-size, label-gap, el-stroke-w, bar-stroke-w,
//      ao-width, up-el-pos, down-el-pos)
//
//   connect(..pairs, style, color, thickness, gap, dash-length)
//     pairs: one or more "nameA & nameB" strings
//
//   connect-label(a, b, body, ratio, pad, size, ..cetz-args)
//
//   config(color, bar-color, el-color, label-color, style, label-size,
//          label-gap, el-stroke-w, bar-stroke-w, ao-width, conn-style,
//          up-el-pos, down-el-pos, x-scale, energy-scale)
//     Affects all subsequent ao() and connect() calls within the diagram.
//     Pass auto to reset a key back to the diagram default.
//
//   energy-axis(title, pad, style)
//     style: "vertical" (default) | "horizontal"
//
//   x-axis(title, pad, style)
//     style: "below" (default) | "above"
//     When used with energy-axis(), the two share an origin corner.
//
//   raw(closure)
//     closure signature: (xs, ys, anchors) => { draw.xxx(...) }
//
//   en-pathway(..energies, color, label-gap, label-size, x-step, electrons,
//              style, conn-style, connect-across-skip, labels, name-prefix, x-start,
//              show-energies, energy-format, energy-size, bar-stroke-w, ao-width)
//     Energies may be int, float, length, or numeric string.
//     Use skip as an energy value to advance x without drawing an orbital.
//
//   ep-annotation(from, to, body, name-prefix, dy, pad, color, size)
//     from / to: orbital index (int) or full name string
//     Draws a double-headed span arrow with a centered label below the diagram.
//
//   en-difference(orb-a, orb-b, body, ratio, pad, color, line-color, label-color,
//                 show-label, thickness, size, title)
//     Arrow at right edge of orb-a, dashed line to left edge of orb-b,
//     optional boxed ΔE label along the arrow, optional title below the label.
//
//   Cetz wrappers (same signature as cetz draw.*, with position forms above):
//   line(..pts, pad, ..cetz-args)                        → also mo-line
//   content(pos, body, pad, dx, dy, size, align, ..args) → also mo-content
//   circle(center, pad, dx, dy, ..cetz-args)             → also mo-circle
//   rect(a, b, pad, ..cetz-args)                         → also mo-rect
//   arc(center, pad, dx, dy, ..cetz-args)                → also mo-arc
//   grid(a, b, pad, ..cetz-args)                         → also mo-grid
//   bezier(..pts, pad, ..cetz-args)
//   catmull(..pts, pad, ..cetz-args)
//   hobby(..pts, pad, ..cetz-args)
//   mark(pos, dir, pad, ..cetz-args)
//   merge-path(body, ..cetz-args)
//   set-style(..cetz-args)
//   on-layer(layer, body)
//   group(body, ..cetz-args)
//   hide(body)
//   intersections(name, ..elements)
//   copy-anchors(element, ..cetz-args)
//
//   Helpers (for use inside raw() closures):
//   at(name, anchors, edge: "center")  — resolve orbital anchor to (x, y)
//   sp(pt, xs, ys)                     — manually scale a (x, y) pair
//   rel(dx, dy)                        — relative offset sentinel
//   skip                               — en-pathway skip sentinel
//
//   Global configuration:
//   modiagram(..items, config: (:))
//   modiagram-setup(..args)     — document-level defaults for modiagram()
//   en-pathway-setup(..args)    — document-level defaults for en-pathway()
//
// ─────────────────────────────────────────────────────────────────────────────

#import "@preview/cetz:0.4.2": canvas, draw
#import "@preview/zero:0.6.1": num as _zero-num


// ═════════════════════════════════════════════════════════════════════════════
// CONSTANTS
// ═════════════════════════════════════════════════════════════════════════════

// One TeX point in cetz units (cm): 1 inch = 2.54 cm, 72.27 pt/inch → 1 pt = 2.54/72.27 cm.
#let _pt = 2.54 / 72.27

// Default orbital bar width: 10 pt (matches the LaTeX modiagram package default).
#let _W = 10 * _pt

// Valid values for enumerated parameters — used in validation throughout.
#let _valid-styles      = ("plain", "square", "round", "circle", "fancy")
#let _valid-conn-styles = ("dotted", "dashed", "solid", "gray")
#let _valid-edges       = ("left", "right", "top", "bottom", "center")
#let _valid-cfg-keys    = (
  "ao-width", "style", "stroke-w", "bar-stroke-w", "el-stroke-w",
  "el-hook-size", "el-sep", "conn-stroke-w", "conn-style", "dot-gap",
  "label-gap", "label-size", "scale", "x-scale", "energy-scale",
  "color", "bar-color", "el-color", "label-color",
)


// ═════════════════════════════════════════════════════════════════════════════
// PRIVATE VALIDATION HELPERS
// ═════════════════════════════════════════════════════════════════════════════

// _assert-style — assert that s is a valid orbital style.
//   ctx: caller name shown in the error message (e.g. "ao", "config")
#let _assert-style(s, ctx) = assert(s in _valid-styles,
  message: ctx + ": invalid style \""
           + s
           + "\"\n  valid styles: "
           + _valid-styles.join(", "))

// _assert-conn-style — assert that s is a valid connection style.
//   allow-none: if true, none is also accepted (used where conn-style: none is valid)
#let _assert-conn-style(s, ctx, allow-none: false) = {
  let ok = (s in _valid-conn-styles) or (allow-none and s == none)
  assert(ok,
    message: ctx + ": invalid conn-style \""
             + repr(s)
             + "\"\n  valid styles: "
             + _valid-conn-styles.join(", ")
             + if allow-none { ", none" } else { "" })
}


// ═════════════════════════════════════════════════════════════════════════════
// CONFIGURATION
// ═════════════════════════════════════════════════════════════════════════════

// Default values for every configurable parameter.
// Override globally with modiagram-setup(), or per diagram with config: (:).
#let _defaults = (
  // orbital geometry
  ao-width:      _W,      // orbital bar width (cm)
  style:         "plain", // orbital style: plain | square | round | circle | fancy

  // stroke widths — stroke-w is the shared fallback; each element type can override it
  stroke-w:      0.6pt,   // fallback — applies when bar/el/conn-stroke-w are auto
  bar-stroke-w:  auto,    // orbital bar stroke       (auto → stroke-w)
  el-stroke-w:   auto,    // electron arrow stroke    (auto → stroke-w)
  conn-stroke-w: auto,    // connection line stroke   (auto → stroke-w)

  // electron arrow geometry
  el-hook-size:  auto,    // hook arc radius (auto → 3 × el-stroke-w, TikZ rule)
  el-sep:        auto,    // gap between ↑ and ↓ shafts in a pair
                          //   auto → 0.2 × ao-width
                          //   explicit: float (implicit cm) or Typst length, e.g. 4pt

  // connection lines
  conn-style:    auto,    // line style (auto adapts to orbital style)
  dot-gap:       3pt,     // spacing between dots or dashes

  // labels
  label-gap:     0.28,    // gap between bar bottom edge and label (cm)
  label-size:    7.5pt,   // font size for orbital labels

  // canvas scaling
  scale:         1.4cm,   // 1 cetz unit = this length; scales the whole diagram
  x-scale:       1.0,     // additional multiplier for all x coordinates
  energy-scale:  1.0,     // additional multiplier for all energy (y) coordinates

  // colors
  color:         black,   // base color for bar, electrons and label
  bar-color:     auto,    // bar color only    (auto → color)
  el-color:      auto,    // electron color    (auto → color)
  label-color:   auto,    // label color       (auto → color)
)

// Global mutable state — holds the active configuration.
#let _cfg = state("modiagram-cfg", _defaults)

// modiagram-setup — override defaults for all diagrams in the document.
//   #modiagram-setup(style: "square", scale: 1cm, label-size: 6pt)
#let modiagram-setup(..args) = {
  for key in args.named().keys() {
    assert(key in _valid-cfg-keys,
      message: "modiagram-setup: unknown key \""
               + key
               + "\"\n  valid keys: "
               + _valid-cfg-keys.join(", "))
  }
  if "style" in args.named() { _assert-style(args.named().at("style"), "modiagram-setup") }
  if "conn-style" in args.named() {
    let s = args.named().at("conn-style")
    if s != auto { _assert-conn-style(s, "modiagram-setup") }
  }
  _cfg.update(old => old + args.named())
}


// ═════════════════════════════════════════════════════════════════════════════
// INTERNAL HELPERS
// ═════════════════════════════════════════════════════════════════════════════

// _cm — convert any Typst length to a plain float (cm) for cetz coordinates.
//   float / int  →  returned unchanged
//   length       →  divided by 1cm  (e.g. 14pt → 0.493…, 1.5cm → 1.5)
#let _cm(v) = if type(v) == length { v / 1cm } else { float(v) }

// _resize — resize both text and math content to a given font size.
// text(size:) alone does not propagate to math.equation in Typst;
// a show rule is required to cover both cases uniformly.
#let _resize(size, body) = {
  show math.equation: set text(size: size)
  text(size: size, body)
}

// _resolve-conn-style — pick the effective connection style when auto.
// Matches LaTeX modiagram defaults:
//   square / round / circle  →  solid
//   fancy                    →  dashed
//   plain                    →  dotted
#let _resolve-conn-style(conn-style, diagram-style) = {
  if conn-style != auto { return conn-style }
  if diagram-style in ("square", "round", "circle") { return "solid" }
  if diagram-style == "fancy" { return "dashed" }
  return "dotted"
}

// _conn-stroke — build a cetz stroke dictionary for a connection line.
#let _conn-stroke(s, color, thickness, gap, dash-length) = {
  let paint = if color == auto { black } else { color }
  let th    = if thickness   == auto { 0.5pt   } else { thickness }
  let g     = if gap         == auto { 3pt     } else { gap }
  let dl    = if dash-length != auto { dash-length }
              else if s == "dotted"  { 0.01pt }   // near-zero → round dot
              else                   { 3pt    }

  if s == "dotted" {
    (paint: paint, thickness: th, cap: "round",
     dash: (array: (dl, g), phase: 0pt))
  } else if s == "dashed" {
    (paint: paint, thickness: th,
     dash: (array: (dl, g), phase: 0pt))
  } else if s == "gray" {
    (paint: luma(160), thickness: th)
  } else {
    (paint: paint, thickness: th)
  }
}

// _bar — draw one orbital bar shape at position (x, y).
//   x, y   center of the bar (pre-scaled, cm)
//   W      bar width (cm)
//   style  orbital style string
//   color  stroke paint
//   sw     stroke width
#let _bar(x, y, W, style, color, sw) = {
  let st   = (paint: color, thickness: sw)
  let x0   = x - W / 2
  let x1   = x + W / 2
  let half = (W + 2 * _pt) / 2   // box half-side = (W + 2pt) / 2

  if style == "plain" {
    draw.line((x0, y), (x1, y), stroke: st)
  } else if style == "square" {
    draw.rect((x - half, y - half), (x + half, y + half), stroke: st, fill: none)
  } else if style == "round" {
    draw.rect((x - half, y - half), (x + half, y + half),
      stroke: st, fill: none, radius: 2 * _pt)
  } else if style == "circle" {
    // Radius = √2·(W+2pt)/2  (matches the LaTeX modiagram circle style geometry).
    let r = 1.4142 * (W + 2 * _pt) / 2
    draw.circle((x, y), radius: r, stroke: st, fill: none)
    draw.line((x - r - 0.25*W, y), (x - r, y), stroke: st)
    draw.line((x + r, y), (x + r + 0.25*W, y), stroke: st)
  } else if style == "fancy" {
    // Rounded box with longer side extensions (±0.5W).
    draw.rect((x - half, y - half), (x + half, y + half),
      stroke: st, fill: none, radius: 2 * _pt)
    draw.line((x - half - 0.5*W, y), (x - half, y), stroke: st)
    draw.line((x + half, y), (x + half + 0.5*W, y), stroke: st)
  }
}

// _electron — draw one electron arrow on an orbital bar.
//
// Replicates the TikZ "-left to" arrowhead style used by the LaTeX modiagram package:
//   ↑  shaft runs y−h → y+h,  CCW hook at top
//   ↓  shaft runs y+h → y−h,  CW  hook at bottom
//   hook radius = el-hook-size  (auto → 3 × sw, matching TikZ "-left to" geometry)
//
// Default shaft positions (symmetric around bar center):
//   ↑ at center − sep/2  =  left_edge + 0.4 × ao-width  (when sep = 0.2 × ao-width)
//   ↓ at center + sep/2  =  left_edge + 0.6 × ao-width
// up-pos / down-pos override these when set explicitly.
#let _electron(dir, orb-x, orb-y, W, sep, color, sw, hook-size,
               up-pos, down-pos) = {
  let h  = 0.4 * W
  let r  = if hook-size == auto { 3 * sw / 1pt * _pt } else { _cm(hook-size) }
  let st = (paint: color, thickness: sw, cap: "round", join: "round")

  let ex-up   = if up-pos   != auto { orb-x + _cm(up-pos)   }
                else                 { orb-x - sep / 2       }
  let ex-down = if down-pos != auto { orb-x + _cm(down-pos) }
                else                 { orb-x + sep / 2       }

  if dir == "up" {
    draw.line((ex-up, orb-y - h), (ex-up, orb-y + h), stroke: st)
    draw.arc((ex-up - r, orb-y + h - r),
      start: 270deg, delta: 90deg, radius: r, stroke: st)
  } else if dir == "down" {
    draw.line((ex-down, orb-y + h), (ex-down, orb-y - h), stroke: st)
    draw.arc((ex-down, orb-y - h),
      start: 180deg, delta: -90deg, radius: r, stroke: st)
  }
}

// _resolve-pos — resolve any position argument to a plain (x, y) float tuple.
//
// Accepted forms:
//   (x, y)                       numeric — multiplied by xs / ys
//   "name"                       center of named orbital in anchors dict
//   "name.edge"                  edge: left | right | top | bottom | center
//   ("pos1", percentage, "pos2") linear interpolation (pad ignored)
//   rel(dx, dy)                  relative offset — resolved by the calling wrapper
//
// pad shifts outward along the edge direction (meaningful for string forms).
#let _resolve-pos(pos, xs, ys, anchors, pad) = {
  let p = _cm(pad)

  // rel() is handled by the calling wrapper; pass through as a cetz (rel:) dict if reached here.
  if type(pos) == dictionary and pos.at("kind", default: none) == "rel" {
    return (rel: (pos.dx * xs, pos.dy * ys))
  }

  // Interpolation: ("pos1", ratio%, "pos2")
  if type(pos) == array and pos.len() == 3 and type(pos.at(1)) == ratio {
    let t = pos.at(1) / 100%
    assert(t >= 0.0 and t <= 1.0,
      message: "modiagram: interpolation percentage must be 0%–100%"
               + " — received: " + repr(pos.at(1)))
    let pa = _resolve-pos(pos.at(0), xs, ys, anchors, 0)
    let pb = _resolve-pos(pos.at(2), xs, ys, anchors, 0)
    return (
      pa.at(0) + (pb.at(0) - pa.at(0)) * t,
      pa.at(1) + (pb.at(1) - pa.at(1)) * t,
    )
  }

  // Numeric tuple: (x, y)
  if type(pos) == array and pos.len() == 2 {
    return (pos.at(0) * xs, pos.at(1) * ys)
  }

  // String: "name" or "name.edge"
  if type(pos) == str {
    let parts = pos.split(".")
    let name  = parts.at(0)
    let edge  = if parts.len() > 1 { parts.at(1) } else { "center" }

    assert(name in anchors,
      message: "modiagram: orbital \""
               + name
               + "\" not found\n  defined orbitals: "
               + if anchors.keys().len() > 0 { anchors.keys().join(", ") }
                 else { "(none)" })
    assert(edge in _valid-edges,
      message: "modiagram: invalid edge \""
               + edge
               + "\" for \""
               + name
               + "\"\n  valid edges: "
               + _valid-edges.join(", "))

    let a    = anchors.at(name)
    let base = if      edge == "left"   { (a.left,   a.y)     }
               else if edge == "right"  { (a.right,  a.y)     }
               else if edge == "top"    { (a.center, a.top)   }
               else if edge == "bottom" { (a.center, a.bottom)}
               else                     { (a.center, a.y)    }
    let dx = if edge == "right"  {  p } else if edge == "left"   { -p } else { 0 }
    let dy = if edge == "top"    {  p } else if edge == "bottom" { -p } else { 0 }
    return (base.at(0) + dx, base.at(1) + dy)
  }

  assert(false,
    message: "modiagram: unrecognised position — received: "
             + repr(pos)
             + "\n  expected: (x, y), \"name\", \"name.edge\","
             + " or (\"pos1\", percentage%, \"pos2\")")
  (0, 0)
}

// _resolve-pts — resolve a list of points, handling rel() in sequence.
// rel() is computed relative to the previously resolved absolute point.
#let _resolve-pts(pts, xs, ys, anchors, pad) = {
  assert(pts.len() >= 2,
    message: "expected at least 2 points — received " + str(pts.len()))
  let resolved = ()
  for pt in pts {
    if type(pt) == dictionary and pt.at("kind", default: none) == "rel" {
      assert(resolved.len() > 0,
        message: "rel() cannot be the first point in a sequence")
      let prev = resolved.last()
      resolved.push((prev.at(0) + pt.dx * xs, prev.at(1) + pt.dy * ys))
    } else {
      resolved.push(_resolve-pos(pt, xs, ys, anchors, pad))
    }
  }
  resolved
}

// _pop — extract one named key from a dict; return (value, remaining-dict).
// Used by cetz wrappers to strip custom params before forwarding to cetz.
#let _pop(named, key, default: none) = {
  let val  = named.at(key, default: default)
  let rest = (:)
  for (k, v) in named.pairs() {
    if k != key { rest.insert(k, v) }
  }
  (val, rest)
}

// _pop-many — extract several named keys from a dict in a single pass.
//   defaults: dict of (key: default-value, ...)
//   Returns (extracted-dict, remaining-dict).
//   Replaces chained _pop calls; cost is one iteration regardless of key count.
#let _pop-many(named, defaults) = {
  let rest = (:)
  for (k, v) in named.pairs() {
    if k not in defaults { rest.insert(k, v) }
  }
  let extracted = (:)
  for (k, d) in defaults.pairs() {
    extracted.insert(k, named.at(k, default: d))
  }
  (extracted, rest)
}


// ═════════════════════════════════════════════════════════════════════════════
// PUBLIC HELPERS
// ═════════════════════════════════════════════════════════════════════════════

// rel — scaled relative offset from the previous point in a sequence.
// Use inside line(), bezier(), catmull(), hobby() wherever a position is accepted.
// The offset is scaled by x-scale and energy-scale, matching ao() coordinates.
//
//   line("σ.right", rel(2, 0), stroke: red)
//   line((0,0), rel(1, 0.5), rel(0, -1), close: true)
#let rel(dx, dy) = (
  kind: "rel",
  dx:   float(dx),
  dy:   float(dy),
)

// sp — manually scale a (x, y) pair by x-scale and energy-scale.
// Use inside raw() closures to match the scaling applied to ao() coordinates.
//   sp((1.5, 0.6), xs, ys)  →  (1.5 * xs, 0.6 * ys)
#let sp(pt, xs, ys) = {
  assert(type(pt) == array and pt.len() == 2,
    message: "sp: expected a 2-element (x, y) array — received: " + repr(pt))
  (pt.at(0) * xs, pt.at(1) * ys)
}

// at — resolve a named orbital to a (x, y) coordinate pair.
// Coordinates are pre-scaled (anchors are built with xs / ys already applied).
//   at("σ", anchors)                 →  center
//   at("σ", anchors, edge: "left")   →  left edge
//   at("σ", anchors, edge: "right")  →  right edge
//   at("σ", anchors, edge: "top")    →  top edge  (box / circle styles)
//   at("σ", anchors, edge: "bottom") →  bottom edge
#let at(name, anchors, edge: "center") = {
  assert(name in anchors,
    message: "at: orbital \""
             + name
             + "\" not found\n  defined orbitals: "
             + if anchors.keys().len() > 0 { anchors.keys().join(", ") }
               else { "(none)" })
  assert(edge in _valid-edges,
    message: "at: invalid edge \""
             + edge
             + "\"\n  valid edges: "
             + _valid-edges.join(", "))
  let a = anchors.at(name)
  if      edge == "left"   { (a.left,   a.y)     }
  else if edge == "right"  { (a.right,  a.y)     }
  else if edge == "top"    { (a.center, a.top)   }
  else if edge == "bottom" { (a.center, a.bottom)}
  else                     { (a.center, a.y)    }
}


// ═════════════════════════════════════════════════════════════════════════════
// PUBLIC API — DIAGRAM ELEMENTS
// ═════════════════════════════════════════════════════════════════════════════

// ao — declare one atomic or molecular orbital.
//
//   name         string identifier used by connect()
//                auto-generated from (x, energy) if omitted
//   x            center x-coordinate  (float cm, or any Typst length)
//   energy       center y-coordinate  (float cm, or any Typst length)
//   electrons    space-separated spin tokens — "up", "down", "pair"
//   label        content below the bar, e.g. $1s$ or $sigma^*$
//   color        base color for bar, electrons and label
//   bar-color    bar color only        (overrides color)
//   el-color     electron arrow color  (overrides color)
//   label-color  label color           (overrides color)
//   style        per-orbital style override: plain|square|round|circle|fancy|auto
//   label-size   font size for this label    (auto → cfg.label-size)
//   label-gap    gap between bar and label   (auto → cfg.label-gap)
//   el-stroke-w  electron stroke for this orbital
//                priority: ao → config() → cfg.el-stroke-w → cfg.stroke-w
//   bar-stroke-w bar stroke for this orbital
//                priority: ao → config() → cfg.bar-stroke-w → cfg.stroke-w
//   ao-width     bar width for this orbital  (auto → config() → cfg.ao-width)
//   up-el-pos    x offset from bar center for ↑ (auto → center − el-sep/2)
//   down-el-pos  x offset from bar center for ↓ (auto → center + el-sep/2)
#let ao(
  name:         auto,
  x:            0,
  energy:       0,
  electrons:    "",
  label:        none,
  color:        black,
  bar-color:    auto,
  el-color:     auto,
  label-color:  auto,
  style:        auto,
  label-size:   auto,
  label-gap:    auto,
  el-stroke-w:  auto,
  bar-stroke-w: auto,
  ao-width:     auto,
  up-el-pos:    auto,
  down-el-pos:  auto,
) = {
  if style != auto { _assert-style(style, "ao") }
  assert(type(x) in (type(0), type(0.0), type(1cm)),
    message: "ao: x must be a number or length — received: " + repr(x))
  assert(type(energy) in (type(0), type(0.0), type(1cm)),
    message: "ao: energy must be a number or length — received: " + repr(energy))

  let tokens = electrons.split(" ").filter(s => s != "")
  for t in tokens {
    assert(t in ("up", "down", "pair"),
      message: "ao: invalid electron token \""
               + t
               + "\"\n  valid tokens: \"up\", \"down\", \"pair\""
               + "\n  electrons string: \""
               + electrons + "\"")
  }

  (
    kind:         "ao",
    name:         if name == auto { repr(x) + "_" + repr(energy) } else { str(name) },
    x:            _cm(x),
    energy:       _cm(energy),
    electrons:    tokens,
    label:        label,
    color:        color,
    bar-color:    bar-color,
    el-color:     el-color,
    label-color:  label-color,
    style:        style,
    label-size:   label-size,
    label-gap:    label-gap,
    el-stroke-w:  el-stroke-w,
    bar-stroke-w: bar-stroke-w,
    ao-width:     ao-width,
    up-el-pos:    up-el-pos,
    down-el-pos:  down-el-pos,
  )
}

// connect — draw lines between pairs of orbitals.
//
//   Positional arguments: one or more "nameA & nameB" strings.
//   style        "dotted" | "dashed" | "solid" | "gray" | auto
//   color        line color  (auto → active config color → black)
//   thickness    stroke width  (auto → conn-stroke-w → stroke-w)
//   gap          dot/dash spacing  (auto → dot-gap)
//   dash-length  dash segment length  (auto → ~0pt dotted, 3pt dashed)
//
//   Examples:
//     connect("1s-L & σ", "1s-R & σ", "1s-L & σ*", "1s-R & σ*")
//     connect("a & b", style: "dashed", color: red, thickness: 1pt, gap: 8pt)
#let connect(..args,
  style:       auto,
  color:       auto,
  thickness:   auto,
  gap:         auto,
  dash-length: auto,
) = {
  if style != auto { _assert-conn-style(style, "connect") }
  assert(args.pos().len() > 0,
    message: "connect: at least one \"nameA & nameB\" string is required")

  args.pos().map(pair => {
    assert(type(pair) == str,
      message: "connect: positional arguments must be strings"
               + " — received: " + repr(pair))
    let parts = pair.split("&").map(s => s.trim())
    assert(parts.len() >= 2 and parts.at(0) != "" and parts.at(1) != "",
      message: "connect: argument must be \"nameA & nameB\""
               + " — received: \"" + pair + "\"")
    (
      kind:        "connect",
      a:           parts.at(0),
      b:           parts.at(1),
      style:       style,
      color:       color,
      thickness:   thickness,
      gap:         gap,
      dash-length: dash-length,
    )
  })
}

// connect-label — place content along a connect() line.
//
//   a, b     orbital names (same pair used in connect())
//   body     any Typst content
//   ratio    position along the line  (default: 50%)
//   pad      perpendicular offset — positive = above, negative = below
//   size     font size — scales both text and math
//   All other named args forwarded to draw.content (anchor, frame, …)
//
//   connect-label("a", "σ", $Delta E$, pad: 0.15, anchor: "south", size: 8pt)
//   connect-label("b", "σ", [legame], ratio: 30%, pad: -0.15, anchor: "north")
#let connect-label(a, b, body, ratio: 50%, pad: 0, ..args) = {
  assert(type(a) == str,
    message: "connect-label: first argument must be an orbital name — received: " + repr(a))
  assert(type(b) == str,
    message: "connect-label: second argument must be an orbital name — received: " + repr(b))
  assert(type(ratio) == type(1%),
    message: "connect-label: ratio must be a percentage, e.g. 50% — received: " + repr(ratio))

  let named = args.named()
  let (size, named) = _pop(named, "size", default: auto)

  (kind: "raw", body: (xs, ys, anchors) => {
    assert(a in anchors,
      message: "connect-label: orbital \""
               + a
               + "\" not found\n  defined orbitals: "
               + anchors.keys().join(", "))
    assert(b in anchors,
      message: "connect-label: orbital \""
               + b
               + "\" not found\n  defined orbitals: "
               + anchors.keys().join(", "))

    let na = anchors.at(a)
    let nb = anchors.at(b)

    // Same edge logic as connect().
    let (ax, bx) = if na.center <= nb.center {
      (na.right, nb.left)
    } else {
      (na.left, nb.right)
    }
    let pa = (ax, na.y)
    let pb = (bx, nb.y)

    let t   = ratio / 100%
    let mid = (
      pa.at(0) + (pb.at(0) - pa.at(0)) * t,
      pa.at(1) + (pb.at(1) - pa.at(1)) * t,
    )

    // calc.atan2(x, y) in Typst — x component first.
    let dx    = pb.at(0) - pa.at(0)
    let dy    = pb.at(1) - pa.at(1)
    let angle = calc.atan2(dx, dy)

    let p   = _cm(pad)
    let pos = (
      mid.at(0) + p * calc.cos(angle + 90deg),
      mid.at(1) + p * calc.sin(angle + 90deg),
    )

    let rendered = if size != auto { _resize(size, body) } else { body }
    draw.content(pos, rendered, angle: angle, ..named)
  })
}

// config — override diagram settings for all subsequent ao() and connect() calls.
// Can appear multiple times in a diagram; each call updates the active state.
// Reset a key to the diagram default by passing auto.
//
//   config(color: red)
//   config(style: "square", bar-stroke-w: 1pt)
//   config(color: auto)   // reset color to diagram default
#let config(..args) = {
  let valid-keys = (
    "color", "bar-color", "el-color", "label-color", "style",
    "label-size", "label-gap", "el-stroke-w", "bar-stroke-w",
    "ao-width", "conn-style", "up-el-pos", "down-el-pos",
    "x-scale", "energy-scale"
  )
  for key in args.named().keys() {
    assert(key in valid-keys,
      message: "config: unknown key \""
               + key
               + "\"\n  valid keys: "
               + valid-keys.join(", "))
  }
  if "style" in args.named() {
    let s = args.named().at("style")
    if s != auto { _assert-style(s, "config") }
  }
  if "conn-style" in args.named() {
    let s = args.named().at("conn-style")
    if s != auto { _assert-conn-style(s, "config") }
  }
  (kind: "ao-config", overrides: args.named())
}

// energy-axis — draw a vertical energy arrow at the left of the diagram.
//
//   title    content near the arrowhead (default: none)
//   pad      horizontal gap from the leftmost orbital edge (default: 0.5)
//   style    "vertical" | "horizontal"
//
//   Examples:
//     energy-axis()
//     energy-axis(title: "Energy")
//     energy-axis(title: "Energy", pad: 0.7cm, style: "horizontal")
#let energy-axis(title: none, pad: 0.5, style: "vertical") = {
  assert(style in ("vertical", "horizontal"),
    message: "energy-axis: invalid style \""
             + style
             + "\"\n  valid styles: \"vertical\", \"horizontal\"")
  assert(type(pad) in (type(0), type(0.0), type(1cm)),
    message: "energy-axis: pad must be a number or length — received: "
             + repr(pad))
  (
    kind:  "energy-axis",
    title: title,
    pad:   pad,
    style: style,
  )
}

// x-axis — draw a horizontal axis below the diagram.
//
//   title    content near the arrowhead (default: none)
//   pad      vertical gap from the lowest orbital edge (default: 0.5)
//   style    "above" (label above the arrowhead) | "below" (default)
//
//   When used together with energy-axis(), the two axes share an origin
//   corner — the energy-axis arrow starts from that corner and the x-axis
//   arrow extends to the right from it.
//
//   Examples:
//     x-axis()
//     x-axis(title: [Reaction coordinate])
//     x-axis(title: [x], pad: 0.7cm)
#let x-axis(title: none, pad: 0.5, style: "below") = {
  assert(style in ("above", "below"),
    message: "x-axis: invalid style \""
             + style
             + "\"\n  valid styles: \"above\", \"below\"")
  assert(type(pad) in (type(0), type(0.0), type(1cm)),
    message: "x-axis: pad must be a number or length — received: "
             + repr(pad))
  (
    kind:  "x-axis",
    title: title,
    pad:   pad,
    style: style,
  )
}

// raw — execute arbitrary cetz draw.* calls inside the modiagram canvas.
//
//   Argument: closure (xs, ys, anchors) => { draw.xxx(...) }
//     xs, ys    active x-scale and energy-scale
//     anchors   dict of all orbital anchors — query with at()
//
//   Example:
//     raw((xs, ys, anchors) => {
//       let p = at("σ", anchors, edge: "right")
//       draw.content((p.at(0) + 0.2, p.at(1)), $"bond"$, anchor: "west")
//     })
#let raw(body) = {
  assert(type(body) == function,
    message: "raw: argument must be a closure (xs, ys, anchors) => { ... }"
             + " — received: " + repr(type(body)))
  (kind: "raw", body: body)
}


// ═════════════════════════════════════════════════════════════════════════════
// PUBLIC API — CETZ WRAPPERS
//
// Every cetz draw.* primitive is available as a first-class modiagram argument.
// Positions accept all forms described in the file header and are resolved
// automatically. rel() is supported in all multi-point wrappers.
// All remaining arguments are forwarded verbatim to cetz — full feature parity.
//
// Custom parameters intercepted before forwarding to cetz:
//   pad:   outward offset from edge
//   dx:    additional x shift after resolution
//   dy:    additional y shift after resolution
//   size:  font size (content only)
//   align: text/math alignment (content only)
// ═════════════════════════════════════════════════════════════════════════════

// line — one or more points + all cetz draw.line arguments.
//   Supports rel() for relative offsets from the previous point.
//
//   line("a.right", "b.left", stroke: blue)
//   line("σ.right", rel(1.5, 0), mark: (end: ">", size: 0.15))
//   line((0,0), rel(2,0), rel(0,1), rel(-2,0), close: true)
#let line(..args) = {
  assert(args.pos().len() >= 2,
    message: "line: at least 2 points required"
             + " — received " + str(args.pos().len()))
  let pts   = args.pos()
  let named = args.named()
  let (pad, named) = _pop(named, "pad", default: 0)
  (kind: "raw", body: (xs, ys, anchors) => {
    draw.line(.._resolve-pts(pts, xs, ys, anchors, pad), ..named)
  })
}

// content — Typst content at a resolved canvas position.
//   size  scales text and math together via _resize().
//   align wraps body in std.align() for multi-line text.
//   dx/dy apply additional offset after all position resolution.
//   All other args forwarded to draw.content (anchor, angle, frame, padding,
//   stroke, fill, name, …).
//
//   content("σ.right", $E$, anchor: "west", pad: 0.2)
//   content("σ.right", $Delta E$, anchor: "west", size: 9pt, dx: 0.05)
//   content("σ.top", text(fill: red)[LUMO], anchor: "south", pad: 0.1)
//   content(("a.bottom", 50%, "b.bottom"), $mid$, anchor: "north", dy: -0.2)
#let content(pos, body, ..args) = {
  let (ex, named) = _pop-many(args.named(), (pad: 0, dx: 0, dy: 0, size: auto, align: none))
  (kind: "raw", body: (xs, ys, anchors) => {
    let p     = _resolve-pos(pos, xs, ys, anchors, ex.pad)
    let final = (p.at(0) + _cm(ex.dx), p.at(1) + _cm(ex.dy))
    let r     = body
    if ex.size  != auto { r = _resize(ex.size, r) }
    if ex.align != none { r = std.align(ex.align, r) }
    draw.content(final, r, ..named)
  })
}

// circle — center point + all cetz draw.circle arguments.
//   dx/dy apply additional offset to the center position.
//
//   circle("σ", radius: 0.3, stroke: blue, fill: yellow.lighten(80%))
//   circle("σ", dx: 0.1, dy: 0.1, radius: 0.3)
#let circle(center, ..args) = {
  let (ex, named) = _pop-many(args.named(), (pad: 0, dx: 0, dy: 0))
  (kind: "raw", body: (xs, ys, anchors) => {
    let p     = _resolve-pos(center, xs, ys, anchors, ex.pad)
    let final = (p.at(0) + _cm(ex.dx), p.at(1) + _cm(ex.dy))
    draw.circle(final, ..named)
  })
}

// rect — two corner points + all cetz draw.rect arguments.
//
//   rect("σ.bottom", "σ*.top", stroke: red, fill: none, radius: 2pt)
//   rect((0,-1), (3,1), stroke: (paint: blue, dash: "dashed"))
#let rect(a, b, ..args) = {
  let named = args.named()
  let (pad, named) = _pop(named, "pad", default: 0)
  (kind: "raw", body: (xs, ys, anchors) => {
    draw.rect(
      _resolve-pos(a, xs, ys, anchors, pad),
      _resolve-pos(b, xs, ys, anchors, pad),
      ..named)
  })
}

// arc — center point + all cetz draw.arc arguments.
//   dx/dy apply additional offset to the center position.
//
//   arc("σ", start: 0deg, stop: 180deg, radius: 0.5, stroke: red)
//   arc((0,0), start: 45deg, delta: 90deg, radius: 1, mode: "PIE", fill: blue)
#let arc(center, ..args) = {
  let (ex, named) = _pop-many(args.named(), (pad: 0, dx: 0, dy: 0))
  (kind: "raw", body: (xs, ys, anchors) => {
    let p     = _resolve-pos(center, xs, ys, anchors, ex.pad)
    let final = (p.at(0) + _cm(ex.dx), p.at(1) + _cm(ex.dy))
    draw.arc(final, ..named)
  })
}

// bezier — start, end, control points + all cetz draw.bezier arguments.
//   Supports rel() for all points.
//
//   bezier("a", "b", (1.5, 0.5))                           // quadratic
//   bezier((0,0), (3,0), (1,1), (2,-1), stroke: red)       // cubic
//   bezier("a.right", "b.left", rel(0, 0.8))
#let bezier(..args) = {
  assert(args.pos().len() >= 3,
    message: "bezier: requires at least 3 points (start, end, control)"
             + " — received " + str(args.pos().len()))
  let pts   = args.pos()
  let named = args.named()
  let (pad, named) = _pop(named, "pad", default: 0)
  (kind: "raw", body: (xs, ys, anchors) => {
    draw.bezier(.._resolve-pts(pts, xs, ys, anchors, pad), ..named)
  })
}

// catmull — Catmull-Rom spline through any number of points.
//   Supports rel() for all points.
//
//   catmull("a", "b", "c", tension: 0.5, stroke: blue)
//   catmull((0,0), rel(1,1), rel(1,-1), rel(1,0), close: true)
#let catmull(..args) = {
  assert(args.pos().len() >= 2,
    message: "catmull: at least 2 points required"
             + " — received " + str(args.pos().len()))
  let pts   = args.pos()
  let named = args.named()
  let (pad, named) = _pop(named, "pad", default: 0)
  (kind: "raw", body: (xs, ys, anchors) => {
    draw.catmull(.._resolve-pts(pts, xs, ys, anchors, pad), ..named)
  })
}

// hobby — Hobby spline through any number of points.
//   Supports rel() for all points.
//
//   hobby("a", "b", "c", stroke: red)
//   hobby((0,0), rel(1,0.5), rel(1,-0.5), omega: 1)
#let hobby(..args) = {
  assert(args.pos().len() >= 2,
    message: "hobby: at least 2 points required"
             + " — received " + str(args.pos().len()))
  let pts   = args.pos()
  let named = args.named()
  let (pad, named) = _pop(named, "pad", default: 0)
  (kind: "raw", body: (xs, ys, anchors) => {
    draw.hobby(.._resolve-pts(pts, xs, ys, anchors, pad), ..named)
  })
}

// mark — standalone arrowhead at pos, oriented toward dir.
//
//   mark("a", "b", symbol: ">", size: 0.2, fill: black)
//   mark((0,0), (1,0), symbol: "|", stroke: red)
#let mark(pos, dir, ..args) = {
  let named = args.named()
  let (pad, named) = _pop(named, "pad", default: 0)
  (kind: "raw", body: (xs, ys, anchors) => {
    draw.mark(
      _resolve-pos(pos, xs, ys, anchors, pad),
      _resolve-pos(dir, xs, ys, anchors, pad),
      ..named)
  })
}

// grid — regular grid between two corner points.
//
//   grid((0,-1), (4,1), stroke: (paint: gray, thickness: 0.3pt))
//   grid((0,0), (3,2), step: 0.5)
#let grid(a, b, ..args) = {
  let named = args.named()
  let (pad, named) = _pop(named, "pad", default: 0)
  (kind: "raw", body: (xs, ys, anchors) => {
    draw.grid(
      _resolve-pos(a, xs, ys, anchors, pad),
      _resolve-pos(b, xs, ys, anchors, pad),
      ..named)
  })
}

// merge-path — combine multiple draw calls into one filled/stroked path.
//
//   merge-path(stroke: blue, fill: yellow, {
//     draw.line((0,0), (1,0))
//     draw.arc((1,0), start: 270deg, delta: 180deg, radius: 0.5)
//   })
#let merge-path(body, ..args) = (
  kind: "raw",
  body: (xs, ys, anchors) => { draw.merge-path(body, ..args.named()) }
)

// set-style — set default styles for all subsequent draw calls.
//
//   set-style(stroke: (paint: gray, thickness: 0.5pt), fill: none)
//   set-style(mark: (symbol: ">", size: 0.15, fill: black))
#let set-style(..args) = (
  kind: "raw",
  body: (xs, ys, anchors) => { draw.set-style(..args.named()) }
)

// on-layer — draw content on a specific z-layer to control draw order.
//   Negative = behind, positive = in front.
//
//   on-layer(-1, { draw.rect((0,-1),(4,1), fill: yellow, stroke: none) })
#let on-layer(layer, body) = {
  assert(type(layer) == int,
    message: "on-layer: layer must be an integer — received: " + repr(layer))
  (kind: "raw", body: (xs, ys, anchors) => { draw.on-layer(layer, body) })
}

// group — group draw calls; supports translate, rotate, scale transforms.
//
//   group(translate: (1, 0.5), {
//     draw.circle((0,0), radius: 0.3)
//     draw.line((0,0), (0.5,0))
//   })
#let group(body, ..args) = (
  kind: "raw",
  body: (xs, ys, anchors) => { draw.group(body, ..args.named()) }
)

// hide — draw invisibly; still occupies space and creates named anchors.
//
//   hide(line((0,0),(1,0), name: "guide"))
#let hide(body) = (
  kind: "raw",
  body: (xs, ys, anchors) => {
    draw.hide(if type(body) == type((:)) and "body" in body {
      (body.body)(xs, ys, anchors)
    } else { body })
  }
)

// intersections — compute intersection points between named cetz elements.
// Results accessible as "name.0", "name.1", … inside raw() closures.
//
//   intersections("i", "circle-a", "line-b")
#let intersections(name, ..elements) = {
  assert(type(name) == str,
    message: "intersections: first argument must be a string — received: " + repr(name))
  assert(elements.pos().len() >= 2,
    message: "intersections: at least 2 element names required"
             + " — received " + str(elements.pos().len()))
  (kind: "raw", body: (xs, ys, anchors) => {
    draw.intersections(name, ..elements.pos())
  })
}

// copy-anchors — copy anchors from a named element to the current scope.
//
//   copy-anchors("source", filter: ("north", "south"))
#let copy-anchors(element, ..args) = {
  assert(type(element) == str,
    message: "copy-anchors: element must be a string — received: " + repr(element))
  (kind: "raw", body: (xs, ys, anchors) => {
    draw.copy-anchors(element, ..args.named())
  })
}


// ═════════════════════════════════════════════════════════════════════════════
// EN-PATHWAY
// ═════════════════════════════════════════════════════════════════════════════

// skip — sentinel value for en-pathway(); skips one x position.
//   en-pathway(0, 0.5, skip, 1.5)  →  orbitals at x=0, x=1.2, x=3.6
#let skip = (kind: "en-pathway-skip")

// Default values for en-pathway.
// Use en-pathway-setup() to override these globally.
#let _ep-defaults = (
  color:         black,
  label-gap:     4pt,
  label-size:    8pt,
  x-step:        1.2,      // horizontal distance between orbitals (implicit cm)
  electrons:     "",
  style:         auto,
  conn-style:          "dashed",
  connect-across-skip: true,
  labels:              none,
  name-prefix:   "ep",
  x-start:       0,
  show-energies: false,
  energy-format: auto,
  energy-size:   auto,
  bar-stroke-w:  1.5pt,
  ao-width:      0.75,     // bar width (implicit cm)
)

// Global mutable state for en-pathway defaults — mirrors the _cfg / _defaults
// pattern used by the main diagram so that en-pathway-setup() works correctly.
#let _ep-state = state("modiagram-ep-cfg", _ep-defaults)

// en-pathway-setup — override _ep-defaults for all en-pathway() calls that
// follow in the document (document-order Typst state semantics).
//   #en-pathway-setup(color: blue, conn-style: "solid", show-energies: true)
#let en-pathway-setup(..args) = {
  let valid-keys = _ep-defaults.keys()
  for key in args.named().keys() {
    assert(key in valid-keys,
      message: "en-pathway-setup: unknown key \""
               + key
               + "\"\n  valid keys: "
               + valid-keys.join(", "))
  }
  if "style" in args.named() {
    let s = args.named().at("style")
    if s != auto { _assert-style(s, "en-pathway-setup") }
  }
  if "conn-style" in args.named() {
    let s = args.named().at("conn-style")
    if s != none and s != auto { _assert-conn-style(s, "en-pathway-setup", allow-none: true) }
  }
  // Update the state so all subsequent en-pathway() calls pick up the new defaults.
  _ep-state.update(old => old + args.named())
}

// _en-pathway-build — internal implementation of en-pathway.
//   Called by modiagram() inside its context block after resolving ep-cfg.
//   All parameters must be fully resolved (no auto) before calling.
#let _en-pathway-build(values, color, label-gap, label-size, x-step, electrons,
                       style, conn-style, connect-across-skip, labels, name-prefix, x-start,
                       show-energies, energy-format, energy-size, bar-stroke-w, ao-width) = {
  // Normalise labels: accept a bare content value in addition to an array.
  // en-pathway(..., labels: $1s$)           → treated as ($1s$,)
  // en-pathway(..., labels: ($1s$, $2s$))   → used as-is
  let labels = if labels == none        { none }
               else if type(labels) == array { labels }
               else                     { (labels,) }

  let result    = ()
  let x         = if type(x-start) == length { x-start / 1cm } else { float(x-start) }
  let step      = if type(x-step)  == length { x-step / 1cm  } else { float(x-step)  }
  let orb-idx   = 0
  let prev-name = none

  for val in values {
    if type(val) == dictionary and val.at("kind", default: none) == "en-pathway-skip" {
      x += step
      if not connect-across-skip { prev-name = none }

    } else {
      assert(type(val) in (type(0), type(0.0), type(1cm), type("")),
        message: "en-pathway: positional arguments must be numbers, lengths, or numeric strings"
                 + " — received: " + repr(val)
                 + "\n  hint: use skip to skip one x position")

      let name   = name-prefix + "-" + str(orb-idx)
      let energy = if type(val) == length { val / 1cm } else { float(val) }
      let lbl    = if labels != none and orb-idx < labels.len() {
                     labels.at(orb-idx)
                   } else { none }

      result.push(ao(
        name:         name,
        x:            x,
        energy:       energy,
        electrons:    electrons,
        label:        lbl,
        color:        color,
        label-gap:    label-gap,
        label-size:   label-size,
        style:        style,
        ao-width:     ao-width,
        bar-stroke-w: bar-stroke-w,
        el-stroke-w:  bar-stroke-w,
      ))

      if show-energies {
        let lgap     = _cm(label-gap)
        let rendered = if energy-format != auto {
          energy-format(energy)
        } else {
          let rs = str(energy)
          _zero-num(
            round: (mode: "places", precision: 2),
            positive-sign: true,
            math: false,
          )[#rs]
        }
        result.push(content(
          (x, energy),
          text(fill: color, rendered),
          anchor: "south",
          dy: lgap,
          size: energy-size,
        ))
      }

      if conn-style != none and prev-name != none {
        result.push(connect(
          prev-name + " & " + name,
          style: conn-style,
          color: color,
        ))
      }

      prev-name  = name
      x         += step
      orb-idx   += 1
    }
  }

  result
}

// en-pathway — generate a sequence of orbitals evenly spaced along x.
//
//   Positional arguments: energy values (float/int/length/string) or skip sentinels.
//   Each value creates one orbital; skip advances x without creating an orbital.
//   Numeric strings like "10.1" or "-0.5" are accepted and parsed automatically.
//
//   color:          base color for bars, electrons, labels and connections
//   label-gap:      gap between bar bottom and label
//   label-size:     font size for labels
//   x-step:         horizontal distance between orbitals (implicit cm)
//   electrons:      electron string applied to all orbitals  (default: "")
//   style:          orbital style
//   conn-style:          connection style between adjacent orbitals
//                        "dashed" | "dotted" | "solid" | "gray" | none
//   connect-across-skip: if true, connect orbitals even when separated by skip (default: true)
//   labels:              array of content, one label per orbital
//   name-prefix:    prefix for auto-generated orbital names  (default: "ep")
//                   change when using multiple en-pathway() in one diagram
//   x-start:        starting x position  (default: 0)
//   show-energies:  if true, place the energy value above each orbital
//   energy-format:  function v => content for custom energy formatting
//                   default: zero num() with 2 decimal places, sign, no math mode
//   energy-size:    font size for energy labels  (auto → label-size)
//   bar-stroke-w:   stroke width for bars and electrons
//   ao-width:       bar width  (implicit cm)
//
//   en-pathway(0, 0.5, 1.0, skip, 1.5, color: red)
//   en-pathway(0, 0.3, 0.7, labels: ($A$, $B$, $C$), conn-style: "solid")
#let en-pathway(..args,
  color:                auto,
  label-gap:            auto,
  label-size:           auto,
  x-step:               auto,
  electrons:            auto,
  style:                auto,
  conn-style:           auto,
  connect-across-skip:  auto,
  labels:               auto,
  name-prefix:          auto,
  x-start:              auto,
  show-energies:        auto,
  energy-format:        auto,
  energy-size:          auto,
  bar-stroke-w:         auto,
  ao-width:             auto,
) = {
  // Early validation of arguments that don't need state resolution.
  if style != auto     { _assert-style(style, "en-pathway") }
  if conn-style != none and conn-style != auto {
    _assert-conn-style(conn-style, "en-pathway", allow-none: true)
  }
  assert(args.pos().len() > 0,
    message: "en-pathway: at least one energy value is required")
  if name-prefix != auto {
    assert(type(name-prefix) == str and name-prefix != "",
      message: "en-pathway: name-prefix must be a non-empty string — received: "
               + repr(name-prefix))
  }

  // Return a deferred descriptor resolved by modiagram() inside its context block,
  // where _ep-state.get() is available and en-pathway-setup() changes are visible.
  (kind: "en-pathway-deferred",
   pos-args:             args.pos(),
   color:                color,
   label-gap:            label-gap,
   label-size:           label-size,
   x-step:               x-step,
   electrons:            electrons,
   style:                style,
   conn-style:           conn-style,
   connect-across-skip:  connect-across-skip,
   labels:               labels,
   name-prefix:          name-prefix,
   x-start:              x-start,
   show-energies:        show-energies,
   energy-format:        energy-format,
   energy-size:          energy-size,
   bar-stroke-w:         bar-stroke-w,
   ao-width:             ao-width,
  )
}


// ep-annotation — span annotation between two en-pathway orbitals.
//
//   from         start orbital: integer index or full name string
//   to           end orbital:   integer index or full name string
//   body         label content, e.g. [Step 1] or $Delta G$
//   name-prefix  must match the en-pathway() name-prefix  (default: "ep")
//   dy           vertical offset below the auto position  (default: 0, negative = further down)
//   pad          extra horizontal margin beyond the orbital edges  (default: 0)
//   color        line and label color  (default: black)
//   size         label font size  (default: auto)
//
//   ep-annotation(0, 2, [Step 1])
//   ep-annotation(2, 4, [Step 2], color: red, pad: 0.1)
//   ep-annotation("ep-0", "ep-3", $Delta G$, dy: -0.3, size: 8pt)
#let ep-annotation(from, to, body,
  name-prefix: "ep",
  dy:          0,
  pad:         0,
  color:       black,
  size:        auto,
) = {
  assert(type(from) in (type(0), type("")),
    message: "ep-annotation: from must be an int or string — received: " + repr(from))
  assert(type(to) in (type(0), type("")),
    message: "ep-annotation: to must be an int or string — received: " + repr(to))

  let name-a = if type(from) == int { name-prefix + "-" + str(from) } else { from }
  let name-b = if type(to)   == int { name-prefix + "-" + str(to)   } else { to   }

  (kind: "raw", body: (xs, ys, anchors) => {
    assert(name-a in anchors,
      message: "ep-annotation: orbital \""
               + name-a + "\" not found"
               + "\n  defined orbitals: " + anchors.keys().join(", "))
    assert(name-b in anchors,
      message: "ep-annotation: orbital \""
               + name-b + "\" not found"
               + "\n  defined orbitals: " + anchors.keys().join(", "))

    let na = anchors.at(name-a)
    let nb = anchors.at(name-b)

    let (xl, xr) = if na.center <= nb.center {
      (na.left, nb.right)
    } else {
      (nb.left, na.right)
    }
    let p   = _cm(pad)
    let xl  = xl - p
    let xr  = xr + p
    let mid = (xl + xr) / 2

    let all-bot = anchors.values().map(a => a.bottom)
    let y-ann   = all-bot.fold(all-bot.first(), (acc, v) => calc.min(acc, v)) - 0.4 + _cm(dy)

    let st = (paint: color, thickness: 0.5pt)
    draw.line((xl, y-ann), (xr, y-ann),
      mark: (
        start: (symbol: ">>", fill: color, scale: 0.75),
        end:   (symbol: ">>", fill: color, scale: 0.75),
      ),
      stroke: st)

    let rendered = if size != auto { _resize(size, text(fill: color, body)) }
                   else            { text(fill: color, body) }
    draw.content((mid, y-ann), rendered, anchor: "north", padding: .5em)
  })
}


// en-difference — draw a ΔE annotation between two orbitals.
//
//   orb-a         first orbital name — the arrow is placed at its right edge
//   orb-b         second orbital name — the dashed line ends at its left edge
//   body          label content, e.g. $Delta E$ or auto (computes |ΔE| from orbital energies)
//   ratio         label position along the arrow, 0% = bottom, 100% = top  (default: 50%)
//   pad           extra offset from the right edge of orb-a to the arrow  (default: 0)
//   color         combined color for arrow, dashed line, and label
//   line-color    color for the arrow and dashed line only  (overrides color)
//   label-color   color for the label only  (overrides color)
//   show-label    whether to show the ΔE label  (default: true)
//   thickness     stroke width for the arrow and dashed line  (default: 0.5pt)
//   size          font size for the ΔE label and title  (default: auto → cfg label-size)
//   title         content rendered below the energy value, inside the same box  (default: none)
//   title-gap     vertical space between the energy value and the title  (default: 0.2em)
//
//   The function draws:
//     • a vertical double-headed solid arrow at the right edge of orb-a
//     • a horizontal dashed line from the arrow tip to the left edge of orb-b
//     • an optionally boxed ΔE label at the given ratio position along the arrow
//
//   Note: to reposition orbital labels above/below instead of below (default), set
//   label: none on the ao() calls and draw labels manually with content().
//
//   en-difference("σ", "σ*")
//   en-difference("HOMO", "LUMO", ratio: 40%, color: green, pad: 0.15)
//   en-difference("a", "b", $Delta G$, show-label: false)
#let en-difference(orb-a, orb-b,
  body:        auto,
  ratio:       50%,
  pad:         0,
  color:       black,
  line-color:  auto,
  label-color: auto,
  show-label:  true,
  thickness:   0.5pt,
  size:        8pt,
  title:       none,
  title-gap:   0.4em,
) = {
  assert(type(orb-a) == str,
    message: "en-difference: orb-a must be an orbital name string — received: " + repr(orb-a))
  assert(type(orb-b) == str,
    message: "en-difference: orb-b must be an orbital name string — received: " + repr(orb-b))
  assert(type(ratio) == type(1%),
    message: "en-difference: ratio must be a percentage, e.g. 50% — received: " + repr(ratio))

  (kind: "raw", body: (xs, ys, anchors) => {
    assert(orb-a in anchors,
      message: "en-difference: orbital \""
               + orb-a + "\" not found"
               + "\n  defined orbitals: " + anchors.keys().join(", "))
    assert(orb-b in anchors,
      message: "en-difference: orbital \""
               + orb-b + "\" not found"
               + "\n  defined orbitals: " + anchors.keys().join(", "))

    let na = anchors.at(orb-a)
    let nb = anchors.at(orb-b)

    // Resolve colors: line-color / label-color override the shared color.
    let lc = if line-color  != auto { line-color  } else { color }
    let tc = if label-color != auto { label-color } else { color }

    // Arrow is anchored to the RIGHT side of orb-a.
    // The dashed line connects to the LEFT side of orb-b.
    let arrow-x = nb.right + _cm(pad)

    // Separate strokes: horizontal connecting line is dashed, arrow is solid.
    let st-dash  = (paint: lc, thickness: thickness, dash: "dashed")
    let st-solid = (paint: lc, thickness: thickness)

    // Horizontal dashed line from right edge of orb-a to the arrow (only when pad > 0).
    if calc.abs(arrow-x - na.right) > 0.001 {
      draw.line((na.right, na.y), (arrow-x, na.y), stroke: st-dash)
    }
    // Horizontal dashed line from the arrow to the left edge of orb-b.
    if calc.abs(arrow-x - nb.left) > 0.001 {
      draw.line((arrow-x, nb.y), (nb.right, nb.y), stroke: st-dash)
    }

    // Vertical double-headed solid arrow spanning na.y ↔ nb.y.
    let (y-bot, y-top) = if na.y <= nb.y { (na.y, nb.y) } else { (nb.y, na.y) }
    draw.line(
      (arrow-x, y-bot),
      (arrow-x, y-top),
      mark: (
        start: (symbol: ">>", fill: lc, scale: 0.5),
        end:   (symbol: ">>", fill: lc, scale: 0.5),
      ),
      stroke: st-solid,
    )

    // ΔE label — drawn only when show-label is true.
    if show-label {
      let t       = ratio / 100%
      let label-y = y-bot + (y-top - y-bot) * t

      // Auto-compute |ΔE| from the scaled y coordinates.
      // anchors store pre-scaled values; divide by ys to recover the original energy.
      let b = if body != auto {
        body
      } else {
        let delta = calc.abs(na.y - nb.y) / ys
        let rs    = str(delta)
        _zero-num(
          round: (mode: "places", precision: 2),
          positive-sign: true,
          math: false,
        )[#rs]
      }

      let rendered = if size != auto { _resize(size, text(fill: tc, b)) }
                     else            { text(fill: tc, b) }

      // Label box centered on the arrow at label-y.
      // When a title is provided it is stacked below the energy value,
      // both center-aligned, inside the same rounded rectangle.
      let box-body = if title != none {
        let title-rendered = if size != auto { _resize(size, text(fill: tc, title)) }
                             else            { text(fill: tc, title) }
        std.align(center, stack(dir: ttb, rendered, title-gap, title-rendered))
      } else {
        rendered
      }
      draw.content(
        (arrow-x, label-y),
        box(
          box-body,
          inset: 0.3em,
          fill:   white,
          stroke: (paint: tc, thickness: thickness),
          radius: 30%,
        ),
      )
    }
  })
}


// ═════════════════════════════════════════════════════════════════════════════
// MO- ALIASES — collision-free names for cetz wrappers that shadow Typst builtins
//
// Use these when star-importing modiagram and needing Typst's native built-ins
// in the same file.  They are identical to their unprefixed counterparts.
//
//   #import "modiagram.typ": *
//   #mo-grid(...)    ← modiagram cetz grid wrapper
//   #grid(...)       ← still shadowed; use std.grid(...) for native Typst grid
//
// The six shadowed names and their aliases:
//   line    → mo-line
//   circle  → mo-circle
//   rect    → mo-rect
//   arc     → mo-arc
//   grid    → mo-grid
//   content → mo-content
// ═════════════════════════════════════════════════════════════════════════════
#let mo-line    = line
#let mo-circle  = circle
#let mo-rect    = rect
#let mo-arc     = arc
#let mo-grid    = grid
#let mo-content = content


// ═════════════════════════════════════════════════════════════════════════════
// modiagram — render the complete diagram
//
//   Positional arguments: any combination of ao(), connect(), connect-label(),
//   config(), energy-axis(), x-axis(), en-pathway(), raw(), and cetz wrappers — in any order.
//
//   config: (...)  override any _defaults key for this diagram only.
//   Priority: per-element → config() → modiagram(config:) → modiagram-setup() → defaults
//
//   Examples:
//     #modiagram(ao(...), ao(...), connect(...))
//
//     #modiagram(
//       config: (style: "square", scale: 1cm, energy-scale: 1.5),
//       config(color: red),
//       ao(...), connect(...), energy-axis(title: "E"),
//     )
// ═════════════════════════════════════════════════════════════════════════════
#let modiagram(..items, config: (:)) = context {

  for key in config.keys() {
    assert(key in _valid-cfg-keys,
      message: "modiagram config: unknown key \""
               + key
               + "\"\n  valid keys: "
               + _valid-cfg-keys.join(", "))
  }
  if "style" in config { _assert-style(config.at("style"), "modiagram config") }
  if "conn-style" in config and config.at("conn-style") != auto {
    _assert-conn-style(config.at("conn-style"), "modiagram config")
  }

  let cfg = _cfg.get() + config
  let W   = cfg.ao-width
  let xs  = cfg.x-scale
  let ys  = cfg.energy-scale

  // Flatten: connect() returns an array of dicts; everything else is one dict
  // or a bare function (anonymous closure passed directly).
  let raw-items = items.pos().flatten()

  // ── Expand deferred en-pathway() items ───────────────────────────────────
  // en-pathway() returns a deferred descriptor so that _ep-state can be read
  // here, inside the context block, where Typst state is accessible.
  let ep-cfg = _ep-state.get()
  let all = ()
  for item in raw-items {
    if type(item) == dictionary and item.at("kind", default: none) == "en-pathway-deferred" {
      // Resolve each parameter: per-call → ep-state → _ep-defaults fallback.
      let resolve(val, key) = if val != auto { val } else { ep-cfg.at(key) }
      let resolved-label-size = resolve(item.label-size, "label-size")
      let expanded = _en-pathway-build(
        item.pos-args,
        resolve(item.color,                "color"),
        resolve(item.label-gap,            "label-gap"),
        resolved-label-size,
        resolve(item.x-step,               "x-step"),
        resolve(item.electrons,            "electrons"),
        resolve(item.style,                "style"),
        resolve(item.conn-style,           "conn-style"),
        resolve(item.connect-across-skip,  "connect-across-skip"),
        resolve(item.labels,               "labels"),
        resolve(item.name-prefix,          "name-prefix"),
        resolve(item.x-start,              "x-start"),
        resolve(item.show-energies,        "show-energies"),
        resolve(item.energy-format,        "energy-format"),
        if item.energy-size != auto { item.energy-size } else { resolved-label-size },
        resolve(item.bar-stroke-w,         "bar-stroke-w"),
        resolve(item.ao-width,             "ao-width"),
      )
      all = all + expanded.flatten()
    } else {
      all.push(item)
    }
  }

  // ── Single categorization pass — avoids 5 separate filter() calls ───────
  let dicts   = ()
  let fns     = ()
  let aos     = ()
  let eaxes   = ()
  let xaxes   = ()
  let has-raw = false
  for i in all {
    if type(i) == function {
      fns.push(i)
    } else if type(i) == type((:)) {
      dicts.push(i)
      let k = i.kind
      if      k == "ao"           { aos.push(i) }
      else if k == "energy-axis"  { eaxes.push(i) }
      else if k == "x-axis"       { xaxes.push(i) }
      else if k == "raw"          { has-raw = true }
    }
  }

  assert(aos.len() > 0 or has-raw or fns.len() > 0,
    message: "modiagram: no content — add at least one ao() call")

  // ── Diagram-level stroke widths ───────────────────────────────────────────
  let conn-sw = if cfg.conn-stroke-w != auto { cfg.conn-stroke-w } else { cfg.stroke-w }
  let el-sep  = if cfg.el-sep        != auto { _cm(cfg.el-sep)   } else { 0.2 * W }

  // ── Build orbital anchor table ────────────────────────────────────────────
  // Two-pass approach: first pass mirrors the rendering loop so that each
  // orbital's anchor reflects its actual ao-width (from ao(), config(), or cfg).
  // eff-pre: merged cfg + active overrides; rebuilt only when overrides change.
  let anchors           = (:)
  let _ao-overrides-pre = (:)
  let eff-pre           = cfg

  for item in dicts {
    if item.kind == "ao-config" {
      for (k, v) in item.overrides.pairs() {
        if v == auto { _ao-overrides-pre.remove(k, default: none) }
        else         { _ao-overrides-pre.insert(k, v) }
      }
      // Rebuild merged config once per override change, not per orbital.
      eff-pre = cfg
      for (k, v) in _ao-overrides-pre.pairs() { eff-pre.insert(k, v) }
    } else if item.kind == "ao" {
      let a         = item
      let xs-l      = eff-pre.x-scale
      let ys-l      = eff-pre.energy-scale
      let bar-style = if a.style != auto { a.style } else { eff-pre.style }
      let ax        = a.x * xs-l
      let ay        = a.energy * ys-l
      let W-a       = if a.ao-width != auto { _cm(a.ao-width) } else { _cm(eff-pre.ao-width) }

      let half-x = if bar-style in ("square", "round") { (W-a + 2 * _pt) / 2 }
                   else if bar-style == "fancy"  { (W-a + 2 * _pt) / 2 + 0.5 * W-a }
                   else if bar-style == "circle" { 1.4142 * (W-a + 2 * _pt) / 2 + 0.25 * W-a }
                   else                          { W-a / 2 }

      let half-y = if bar-style in ("square", "round", "fancy") { (W-a + 2 * _pt) / 2 }
                   else if bar-style == "circle" { 1.4142 * (W-a + 2 * _pt) / 2 }
                   else                          { 0.0 }

      anchors.insert(a.name, (
        left:   ax - half-x,
        right:  ax + half-x,
        center: ax,
        y:      ay,
        top:    ay + half-y,
        bottom: ay - half-y,
      ))
    }
  }

  canvas(length: cfg.scale, {

    // ── Single ordered pass ────────────────────────────────────────────────
    // Processes ao(), connect(), config(), label-like raws in document order
    // so that config() affects all subsequent elements correctly.
    //
    // eff: merged cfg + active _ao-overrides; rebuilt only when overrides
    // change (once per config() call) rather than re-queried per property
    // per orbital. Reduces ~25 dict lookups/orbital to ~9.
    let _ao-overrides = (:)
    let eff           = cfg

    for item in dicts {

      // ── config() inline override ─────────────────────────────────────────
      if item.kind == "ao-config" {
        for (k, v) in item.overrides.pairs() {
          if v == auto { _ao-overrides.remove(k, default: none) }
          else         { _ao-overrides.insert(k, v) }
        }
        // Rebuild merged config once per override change, not per orbital.
        eff = cfg
        for (k, v) in _ao-overrides.pairs() { eff.insert(k, v) }

      // ── connect() ────────────────────────────────────────────────────────
      } else if item.kind == "connect" {
        assert(item.a in anchors,
          message: "connect: orbital \""
                   + item.a
                   + "\" not found\n  defined orbitals: "
                   + anchors.keys().join(", "))
        assert(item.b in anchors,
          message: "connect: orbital \""
                   + item.b
                   + "\" not found\n  defined orbitals: "
                   + anchors.keys().join(", "))

        let na = anchors.at(item.a)
        let nb = anchors.at(item.b)
        let (ax, bx) = if na.center <= nb.center {
          (na.right, nb.left)
        } else {
          (na.left, nb.right)
        }

        // Color priority: per-connection → eff.color → black
        let conn-color = if item.color != auto    { item.color }
                         else if eff.color != black { eff.color }
                         else                       { auto }

        let s = if item.style != auto { item.style }
                else { _resolve-conn-style(eff.conn-style, eff.style) }

        // Thickness priority: per-connection → eff.bar-stroke-w → conn-sw
        let conn-th = if item.thickness != auto         { item.thickness }
                      else if eff.bar-stroke-w != auto  { eff.bar-stroke-w }
                      else                              { conn-sw }

        draw.line((ax, na.y), (bx, nb.y),
          stroke: _conn-stroke(s, conn-color, conn-th, item.gap, item.dash-length))

      // ── ao() orbital ──────────────────────────────────────────────────────
      } else if item.kind == "ao" {
        let a         = item
        let bar-style = if a.style != auto { a.style } else { eff.style }

        // Color resolution — ao param → eff (already merges override + cfg)
        let base-color  = if a.color      != black { a.color      } else { eff.color }
        let bar-color   = if a.bar-color  != auto  { a.bar-color  } else if eff.bar-color  != auto { eff.bar-color  } else { base-color }
        let el-color    = if a.el-color   != auto  { a.el-color   } else if eff.el-color   != auto { eff.el-color   } else { base-color }
        let label-color = if a.label-color != auto { a.label-color } else if eff.label-color != auto { eff.label-color } else { bar-color }

        // Stroke widths
        let el-sw  = if a.el-stroke-w  != auto { a.el-stroke-w  } else if eff.el-stroke-w  != auto { eff.el-stroke-w  } else { eff.stroke-w }
        let bar-sw = if a.bar-stroke-w != auto { a.bar-stroke-w } else if eff.bar-stroke-w != auto { eff.bar-stroke-w } else { eff.stroke-w }

        // Label properties
        let lsize   = if a.label-size != auto { a.label-size      } else { eff.label-size }
        let lgap    = if a.label-gap  != auto { _cm(a.label-gap)  } else { _cm(eff.label-gap) }

        // Bar width
        let W-local = if a.ao-width != auto { _cm(a.ao-width) } else { _cm(eff.ao-width) }

        // x/y-scale: from eff so that config(x-scale/energy-scale) applies in
        // document order, consistent with every other config() key.
        let ax = a.x * eff.x-scale
        let ay = a.energy * eff.energy-scale

        _bar(ax, ay, W-local, bar-style, bar-color, bar-sw)

        // Hoist electron position resolution out of the per-electron loop —
        // these values are identical for every electron on the same orbital.
        let up-pos   = if a.up-el-pos   != auto { a.up-el-pos   } else { eff.at("up-el-pos",   default: auto) }
        let down-pos = if a.down-el-pos != auto { a.down-el-pos } else { eff.at("down-el-pos", default: auto) }

        for el in a.electrons {
          if el == "pair" {
            _electron("up",   ax, ay, W-local, el-sep, el-color, el-sw, cfg.el-hook-size, up-pos, down-pos)
            _electron("down", ax, ay, W-local, el-sep, el-color, el-sw, cfg.el-hook-size, up-pos, down-pos)
          } else if el in ("up", "down") {
            _electron(el, ax, ay, W-local, el-sep, el-color, el-sw, cfg.el-hook-size, up-pos, down-pos)
          }
        }

        // Label — placed below the actual bottom edge of the orbital shape.
        if a.label != none {
          let y-offset = if bar-style == "circle" {
            0.4 * (W-local + 2 * _pt) / 2 + lgap
          } else if bar-style in ("square", "round", "fancy") {
            0.2 * (W-local + 2 * _pt) / 2 + lgap
          } else {
            lgap
          }
          draw.content(
            (ax, ay - y-offset),
            _resize(lsize, text(fill: label-color, a.label)),
            anchor: "north",
          )
        }

      // ── raw() closures ────────────────────────────────────────────────────
      } else if item.kind == "raw" {
        (item.body)(eff.x-scale, eff.energy-scale, anchors)
      }
    }

    // Anonymous closures passed directly (not wrapped in raw()).
    for f in fns { f(xs, ys, anchors) }

    // ── Energy axis and x-axis (optionally connected at origin) ───────────
    if eaxes.len() > 0 or xaxes.len() > 0 {
      assert(aos.len() > 0,
        message: "energy-axis / x-axis: no orbitals defined — add at least one ao() call")

      // Single pass over anchor values to compute all four bounds at once.
      let av     = anchors.values()
      let first  = av.first()
      let bounds = av.fold(
        (ymin: first.y, ymax: first.y, xleft: first.left, xright: first.right),
        (b, a) => (
          ymin:   calc.min(b.ymin,   a.y),
          ymax:   calc.max(b.ymax,   a.y),
          xleft:  calc.min(b.xleft,  a.left),
          xright: calc.max(b.xright, a.right),
        )
      )
      let y-min   = bounds.ymin
      let y-max   = bounds.ymax
      let x-left  = bounds.xleft
      let x-right = bounds.xright

      let margin = 0.2

      // When both axes are present they share a common origin corner.
      let both = eaxes.len() > 0 and xaxes.len() > 0

      for eax in eaxes {
        let pad  = _cm(eax.pad)
        let ax-x = x-left - pad
        // If paired with x-axis, start from the shared origin (bottom of range);
        // otherwise leave the normal bottom margin.
        let y0   = if both {
          let xpad = _cm(xaxes.first().pad)
          y-min - xpad
        } else {
          y-min - margin
        }
        let y1   = y-max + margin

        draw.line(
          (ax-x, y0), (ax-x, y1),
          mark: (end: (symbol: ">>", fill: black, scale: 0.75, size: 0.2)),
          stroke: (thickness: cfg.stroke-w),
        )

        if eax.title != none {
          if eax.style == "horizontal" {
            draw.content(
              (ax-x - 0.25, (y0 + y1) / 2),
              _resize(cfg.label-size, eax.title),
              anchor: "center", angle: 90deg,
            )
          } else {
            draw.content(
              (ax-x, y1 + 0.15),
              _resize(cfg.label-size, eax.title),
              anchor: "south",
            )
          }
        }
      }

      for xax in xaxes {
        let epad  = if eaxes.len() > 0 { _cm(eaxes.first().pad) } else { 0 }
        let xpad  = _cm(xax.pad)
        // Origin x: same as the energy-axis line when both are present,
        // otherwise left edge minus a small margin.
        let ax-x0 = if both  { x-left - epad } else { x-left - margin }
        let ay    = y-min - xpad
        let x1    = x-right + margin

        draw.line(
          (ax-x0, ay), (x1, ay),
          mark: (end: (symbol: ">>", fill: black, scale: 0.75, size: 0.2)),
          stroke: (thickness: cfg.stroke-w),
        )

        if xax.title != none {
          if xax.style == "below" {
            draw.content(
              ((ax-x0 + x1) / 2, ay - 0.15),
              _resize(cfg.label-size, xax.title),
              anchor: "north",
            )
          } else {
            draw.content(
              (x1 + 0.15, ay),
              _resize(cfg.label-size, xax.title),
              anchor: "west",
            )
          }
        }
      }
    }

  }) // end canvas
}
