// Mirrors upstream src/xyzrender/renderer.py.
//
// SVG-string emission pipeline. All constants, formulas, gradient
// positions, stop offsets, and rendering order are ported verbatim
// from upstream; don't tune them locally.

#import "colors.typ": (
  element-color, display-radius, resolve-color,
  get-gradient-colors, blend-fog, rgb-blend,
  compute-fog-factors, fog-target, raw-vdw-sphere, darken-hex,
  compute-atom-gradients-plugin,
  WHITE,
)
#import "utils.typ": apply-rotation, project, fit-canvas, ref-scale, join-svg, fnum, pca-orient
#import "types.typ": defaults
#import "interlock.typ": compute-interlock-polygons
#import "selectors.typ": resolve-atom-indices
#import "bond_rules.typ": _parse-index-pair

// ---- low-level SVG primitives ----

// Upstream renderer.py:510-511 emits BOTH `viewBox` and explicit
// `width="..." height="..."` user-unit attrs. Without those, an SVG
// importer (e.g. Typst's `image()`) sizes the image via fallback
// rules: at `width: auto` it may interpret the viewBox dimensions
// inconsistently across molecules, so atoms of the same element end
// up at noticeably different sizes when two molecules are placed
// side-by-side. With explicit `width`/`height` matching the
// viewBox, Typst sizes both images at the same pt-per-canvas-unit
// ratio — the relative atom sizes then track the SVG's internal
// scale exactly, matching the look of CLI-exported SVGs imported
// via `#image(...)`.
#let _svg-open(w, h) = (
  "<svg xmlns=\"http://www.w3.org/2000/svg\""
    + " xmlns:xlink=\"http://www.w3.org/1999/xlink\""
    + " viewBox=\"0 0 " + fnum(w) + " " + fnum(h) + "\""
    + " width=\"" + fnum(w) + "\" height=\"" + fnum(h) + "\">"
)

#let _circle(cx, cy, r, fill, stroke, stroke-width) = (
  "<circle cx=\"" + fnum(cx) + "\" cy=\"" + fnum(cy)
    + "\" r=\"" + fnum(r) + "\" fill=\"" + fill + "\""
    + (if stroke-width > 0 {
      " stroke=\"" + stroke + "\" stroke-width=\"" + fnum(stroke-width) + "\""
    } else { "" })
    + "/>"
)

// Upstream `_poly_xy is not None` branch (renderer.py:1605-1611) —
// silhouette polygon for an atom that overlaps a neighbour. `points`
// is a list of (px, py) pixel-space tuples.
#let _polygon(points, fill, stroke, stroke-width) = {
  let pts-str = points.map(p => fnum(p.at(0)) + "," + fnum(p.at(1))).join(" ")
  let stroke-attr = if stroke-width > 0 {
    " stroke=\"" + stroke + "\" stroke-width=\"" + fnum(stroke-width) + "\""
  } else { "" }
  "<polygon points=\"" + pts-str + "\" fill=\"" + fill + "\"" + stroke-attr + "/>"
}

// Upstream `_text_svg` (renderer.py:2014-2031) — bold monospace text
// with optional white halo for legibility over bond lines. The halo
// is a separate stroke-only <text> rendered underneath the fill
// (CairoSVG doesn't honour `paint-order:stroke`). v1 keeps the same
// markup so resvg/Typst's SVG path stays compatible.
// font-family lists a concrete font that ships with Typst before
// the generic. Typst 0.14's PDF translator can't resolve generic
// families (`monospace`) on its own and falls back to the body
// serif font; naming `DejaVu Sans Mono` keeps PDF labels in a
// monospace face. PNG/SVG export honours either form.
#let _text-svg(x, y, text, font-size, color, halo: true) = {
  let attrs = ("x=\"" + fnum(x) + "\" y=\"" + fnum(y) + "\""
    + " font-family=\"DejaVu Sans Mono, monospace\""
    + " font-size=\"" + fnum(font-size) + "px\""
    + " font-weight=\"bold\" text-anchor=\"middle\" dominant-baseline=\"central\"")
  if halo {
    let sw = font-size * 0.35
    ("<text " + attrs + " fill=\"#ffffff\" stroke=\"#ffffff\""
      + " stroke-width=\"" + fnum(sw) + "\" stroke-linejoin=\"round\">" + text + "</text>"
      + "<text " + attrs + " fill=\"" + color + "\">" + text + "</text>")
  } else {
    "<text " + attrs + " fill=\"" + color + "\">" + text + "</text>"
  }
}

// Upstream `_sphere_gradient_def` (renderer.py:60-68) — user-space
// radial gradient centred on the projected sphere, focal upper-left.
// Used inline for polygon-shape atoms (whose bounding box differs from
// the sphere's natural disc, so an objectBoundingBox gradient would
// shift the highlight off-centre).
// Stop offsets use decimal form for the same Typst-PDF reason as
// `_radial-grad` above. `gradientUnits="userSpaceOnUse"` here is
// already explicit; we keep it so the PDF translator never falls
// back to a default it can't parse.
// Upstream `_sphere_gradient_def` (renderer.py:60-68) — user-space
// radial gradient centred on the projected sphere, focal upper-left.
// Used inline next to the shape for polygon-shape atoms (whose
// bounding box differs from the sphere disc, so an
// objectBoundingBox gradient would shift the highlight off-centre)
// and for every VDW overlay atom.
#let _sphere-grad-def(gid, xi, yi, r-px, stops) = {
  let stops-xml = stops.map(s =>
    "<stop offset=\"" + s.at(0) + "\" stop-color=\"" + s.at(1) + "\"/>"
  ).join("")
  ("<defs><radialGradient id=\"" + gid
    + "\" gradientUnits=\"userSpaceOnUse\""
    + " cx=\"" + fnum(xi) + "\" cy=\"" + fnum(yi) + "\""
    + " r=\"" + fnum(r-px * 1.32) + "\""
    + " fx=\"" + fnum(xi - r-px * 0.34) + "\""
    + " fy=\"" + fnum(yi - r-px * 0.34) + "\">"
    + stops-xml + "</radialGradient></defs>")
}

// Upstream uses stroke-linecap="round" on bonds (renderer.py line 1020,
// 1072, 1137). Round caps give the cylinder/pill look.
#let _line(x1, y1, x2, y2, color, width, cap: "round", dash: "") = (
  "<line x1=\"" + fnum(x1) + "\" y1=\"" + fnum(y1)
    + "\" x2=\"" + fnum(x2) + "\" y2=\"" + fnum(y2)
    + "\" stroke=\"" + color + "\" stroke-width=\"" + fnum(width)
    + "\" stroke-linecap=\"" + cap + "\""
    + (if dash != "" { " stroke-dasharray=\"" + dash + "\"" } else { "" })
    + "/>"
)

// Upstream renderer.py:586-590, verbatim:
//   <radialGradient id="g{ai}" cx=".5" cy=".5" fx=".33" fy=".33" r=".66">
//     <stop offset="0%"   stop-color="{hi.hex}"/>
//     <stop offset="40%"  stop-color="{me.hex}"/>
//     <stop offset="100%" stop-color="{lo.hex}"/>
//   </radialGradient>
// Upstream renderer.py:586-590 verbatim.
#let _radial-grad(id, hi-hex, me-hex, lo-hex) = (
  "<radialGradient id=\"" + id
    + "\" cx=\".5\" cy=\".5\" fx=\".33\" fy=\".33\" r=\".66\">"
    + "<stop offset=\"0%\" stop-color=\"" + hi-hex + "\"/>"
    + "<stop offset=\"40%\" stop-color=\"" + me-hex + "\"/>"
    + "<stop offset=\"100%\" stop-color=\"" + lo-hex + "\"/>"
    + "</radialGradient>"
)

// Upstream renderer.py:998-1013 — cylinder shading on a bond stroke.
//   half = w * 0.5
//   mx, my = (lx1 + lx2)/2, (ly1 + ly2)/2
//   gx1, gy1 = mx - lpx*half, my - lpy*half
//   gx2, gy2 = mx + lpx*half, my + lpy*half
//   <linearGradient id="bs{n}" gradientUnits="userSpaceOnUse"
//        x1=gx1 y1=gy1 x2=gx2 y2=gy2>
//     <stop offset="0%"   stop-color="{lo_hex}"/>
//     <stop offset="50%"  stop-color="{hi_hex}"/>
//     <stop offset="100%" stop-color="{lo_hex}"/>
//   </linearGradient>
#let _cylinder-grad(id, x1, y1, x2, y2, lpx, lpy, w, hi-hex, lo-hex) = {
  let half = w * 0.5
  let mx = (x1 + x2) / 2.0
  let my = (y1 + y2) / 2.0
  let gx1 = mx - lpx * half
  let gy1 = my - lpy * half
  let gx2 = mx + lpx * half
  let gy2 = my + lpy * half
  ("<linearGradient id=\"" + id
    + "\" gradientUnits=\"userSpaceOnUse\""
    + " x1=\"" + fnum(gx1) + "\" y1=\"" + fnum(gy1) + "\""
    + " x2=\"" + fnum(gx2) + "\" y2=\"" + fnum(gy2) + "\">"
    + "<stop offset=\"0%\" stop-color=\"" + lo-hex + "\"/>"
    + "<stop offset=\"50%\" stop-color=\"" + hi-hex + "\"/>"
    + "<stop offset=\"100%\" stop-color=\"" + lo-hex + "\"/>"
    + "</linearGradient>")
}

// ---- per-atom gradient with fog (upstream renderer.py:578-590, v0.3.3) ----
//
//   hi, me, lo = get_gradient_colors(colors[ai], acfg, strength=...)
//   t = fog_f[ai]
//   hi, me, lo = (blend_fog(c.hex, fog_col, t) for c in (hi, me, lo))
//
// The fog amount is the per-atom alpha directly (the depth-squaring and
// cap live in `fog-alpha`); each stop blends toward `fog-col`, floored to
// stay legible.
#let _per-atom-grad-colors(hex, config, fog-f, fog-col) = {
  let strength = float(config.at("atom_gradient_strength", default: defaults.atom_gradient_strength))
  let (hi, me, lo) = get-gradient-colors(hex, config, strength: strength)
  if fog-f == 0.0 {
    (hi, me, lo)
  } else {
    (blend-fog(hi, fog-col, fog-f), blend-fog(me, fog-col, fog-f), blend-fog(lo, fog-col, fog-f))
  }
}

// ---- per-section emitters ----

// Per-atom OR per-element gradient defs, matching upstream's
// `use_per_atom_grad = cfg.fog` switch (renderer.py:564).
//
// When fog is on, each atom needs unique fog-blended stops, so we
// emit one gradient per atom (id=`{prefix}-g{ai}`).
//
// When fog is off, all atoms of the same element + colour share a
// single gradient (id=`{prefix}-ge-{element}-{hex}`), matching
// upstream's `g{atomic_num}_{hex_no_hash}` keying. Saves SVG size.
#let _emit-defs(data, config, fog-fs, fog-col, use-per-atom-grad, id-prefix) = {
  let gradient-on = config.at("gradient", default: defaults.gradient)
  if not gradient-on { return "" }
  let parts = ()
  if use-per-atom-grad {
    // Hot-path: per-atom gradient triples (lighten/darken/HSL/blend)
    // are O(n) and call into the colour-math leaves several times per
    // atom. One WASM round-trip into the verbatim port at
    // plugin/src/colors.rs replaces the whole loop body.
    let strength = float(config.at("atom_gradient_strength", default: defaults.atom_gradient_strength))
    let triples = compute-atom-gradients-plugin(
      data.elements,
      fog-fs,
      fog-col,
      config.at("colors", default: (:)),
      config.at("hue_shift_factor", default: defaults.hue_shift_factor),
      config.at("light_shift_factor", default: defaults.light_shift_factor),
      config.at("saturation_shift_factor", default: defaults.saturation_shift_factor),
      strength,
    )
    for ai in range(data.elements.len()) {
      let (hi, me, lo) = triples.at(ai)
      parts.push(_radial-grad(id-prefix + "-g" + str(ai), hi, me, lo))
    }
  } else {
    let strength = float(config.at("atom_gradient_strength", default: defaults.atom_gradient_strength))
    let seen = (:)
    for ai in range(data.elements.len()) {
      let elem = data.elements.at(ai)
      let color = element-color(elem, config)
      let key = elem + "-" + color.slice(1)
      if not (key in seen) {
        seen.insert(key, true)
        let (hi, _, lo) = get-gradient-colors(color, config, strength: strength)
        parts.push(_radial-grad(id-prefix + "-ge-" + key, hi, color, lo))
      }
    }
  }
  join-svg(parts)
}

#let _emit-background(w, h, config) = {
  let bg = config.at("background", default: defaults.background)
  if bg == none or bg == "none" {
    ""
  } else {
    let hex = resolve-color(bg)
    (
      "<rect width=\"" + fnum(w) + "\" height=\"" + fnum(h)
        + "\" fill=\"" + hex + "\"/>"
    )
  }
}

// Which perpendicular side of an aromatic bond faces the ring centre.
//
// Upstream `_ring_side` (renderer.py:2185-2192): scan `aromatic_rings`
// for one containing both `i` and `j`; compute the ring centroid in 3D;
// project to 2D; compare to the bond midpoint along (px, py). Return +1
// when the ring centre lies on the +(px,py) side, -1 otherwise. Returns
// +1 when no ring contains the bond (matches upstream fallback).
#let _ring-side(
  i, j, aromatic-rings, coords-3d,
  scale, center, canvas-w, canvas-h,
  x1, y1, x2, y2, px, py,
) = {
  let result = 1
  let found = false
  for ring in aromatic-rings {
    if not found {
      let ring-ints = ring.map(a => int(a))
      let has-i = ring-ints.position(a => a == i) != none
      let has-j = ring-ints.position(a => a == j) != none
      if has-i and has-j {
        let cx3 = 0.0
        let cy3 = 0.0
        let cz3 = 0.0
        let n = ring-ints.len()
        for a in ring-ints {
          cx3 = cx3 + float(coords-3d.at(a).at(0))
          cy3 = cy3 + float(coords-3d.at(a).at(1))
          cz3 = cz3 + float(coords-3d.at(a).at(2))
        }
        cx3 = cx3 / n
        cy3 = cy3 / n
        cz3 = cz3 / n
        let (rcx, rcy) = project((cx3, cy3, cz3), scale, center, canvas-w, canvas-h)
        let mx = (x1 + x2) / 2.0
        let my = (y1 + y2) / 2.0
        if px * (rcx - mx) + py * (rcy - my) > 0 {
          result = 1
        } else {
          result = -1
        }
        found = true
      }
    }
  }
  result
}

// Emit one bond as 1/2/3 parallel lines. `pass` is "outline" or "fill".
//
// Multi-bond logic (upstream renderer.py:1377-1390):
//   nb = max(1, round(order))
//   w  = bw if nb == 1 else bw * 0.7
//   gap = bond_gap * bw
//   for ib in range(-nb+1, nb, 2):
//     ox, oy = px * ib * gap, py * ib * gap
//
// (x1, y1, x2, y2, px, py) are the precomputed shortened-endpoint
// geometry from bond_geom (upstream renderer.py:1410-1456). `bond-id`
// is the bond's stable index — used to name inline cylinder gradient
// defs when bond_gradient is on.
//
// `style` is "solid" | "dashed" | "dotted" (DASHED = TS overlay,
// DOTTED = NCI overlay). Non-solid styles emit a single line with the
// configured dash pattern (renderer.py:1273-1330); the multi-bond /
// aromatic branches are skipped.
#let _emit-bond-segment(
  pass, bond-id, x1, y1, x2, y2, px, py, order,
  color-i, color-j, base-color,
  ri, rj,
  bw, gap, bond-by-element,
  outline-i, outline-j, outline-width,
  bond-gradient: false,
  bond-gradient-config: (:),
  bond-gradient-strength: 1.0,
  aromatic: false,
  ring-side: 1,
  style: "solid",
  dash-pattern: "",
) = {
  // TS / NCI overlays render as a single dashed/dotted line. Multi-
  // bond / aromatic branches are skipped (upstream renderer.py:
  // 1201-1330 only ever emits one line for DASHED / DOTTED).
  let non-solid = style != "solid"
  let aromatic-eff = aromatic and not non-solid

  // Aromatic bonds: two parallel lines, ring-facing side dashed
  // (upstream renderer.py:1345-1376). Width matches the nb=2 case.
  let nb = if non-solid { 1 } else if aromatic-eff { 2 } else { calc.max(1, calc.round(float(order))) }
  let w = if nb == 1 { bw } else { bw * 0.7 }

  // Upstream `_shaded_stroke` (renderer.py:982-1013): when
  // `bond_gradient` is on, returns a per-line cylinder gradient def +
  // url() reference. Otherwise returns the plain hex colour.
  let shaded-stroke(ax, ay, bx, by, color-hex, segment-id) = {
    if not bond-gradient {
      (def: "", stroke: color-hex)
    } else {
      let (hi, _, lo) = get-gradient-colors(
        color-hex, bond-gradient-config, strength: bond-gradient-strength,
      )
      let sid = "bs-" + segment-id
      let def = "<defs>" + _cylinder-grad(sid, ax, ay, bx, by, px, py, w, hi, lo) + "</defs>"
      (def: def, stroke: "url(#" + sid + ")")
    }
  }

  // Upstream `_emit_line` outline branch (renderer.py:1109-1126):
  // single hex stroke when `stroke_i == stroke_j`, otherwise a
  // linearGradient between the two endpoint colours.
  let outline-stroke(ax, ay, bx, by, segment-id) = {
    if outline-i == outline-j {
      (def: "", stroke: outline-i)
    } else {
      let sid = "bo-" + segment-id
      let def = ("<defs><linearGradient id=\"" + sid + "\""
        + " gradientUnits=\"userSpaceOnUse\""
        + " x1=\"" + fnum(ax) + "\" y1=\"" + fnum(ay) + "\""
        + " x2=\"" + fnum(bx) + "\" y2=\"" + fnum(by) + "\">"
        + "<stop offset=\"0%\" stop-color=\"" + outline-i + "\"/>"
        + "<stop offset=\"100%\" stop-color=\"" + outline-j + "\"/>"
        + "</linearGradient></defs>")
      (def: def, stroke: "url(#" + sid + ")")
    }
  }

  let one-line(ib) = {
    let ox = px * ib * gap
    let oy = py * ib * gap
    let ax = x1 + ox
    let ay = y1 + oy
    let bx = x2 + ox
    let by = y2 + oy
    // Aromatic dashed inner line — upstream renderer.py:1353
    //   dash = f"{w*1.0:.1f},{w*2.0:.1f}" if ib == side else ""
    let dash = if non-solid {
      dash-pattern
    } else if aromatic-eff and ib == ring-side {
      fnum(w * 1.0) + "," + fnum(w * 2.0)
    } else {
      ""
    }
    if pass == "outline" {
      if outline-width > 0.0 {
        let s = outline-stroke(ax, ay, bx, by, bond-id + "-" + str(ib))
        s.def + _line(ax, ay, bx, by, s.stroke, w + 2.0 * outline-width, dash: dash)
      } else {
        ""
      }
    } else {
      // fill pass — upstream renderer.py:1043-1061
      if bond-by-element and color-i != color-j {
        // Width-weighted midpoint (upstream renderer.py:1055):
        //   t = ri / (ri + rj) if (ri + rj) > 0 else 0.5
        let t = if ri + rj > 0 { ri / (ri + rj) } else { 0.5 }
        if dash != "" {
          // Two dashed half-lines would restart the dash phase at the
          // split, so upstream keeps one line and colours it with a
          // hard-stop linearGradient at the split ratio
          // (renderer.py:1050-1061, `_element_line` dash branch).
          let sid = "be-" + bond-id + "-" + str(ib)
          let off = calc.max(0.0, calc.min(100.0, 100.0 * t))
          let off-s = str(calc.round(off * 10000.0) / 10000.0)
          let def = ("<defs><linearGradient id=\"" + sid + "\""
            + " x1=\"" + fnum(ax) + "\" y1=\"" + fnum(ay) + "\""
            + " x2=\"" + fnum(bx) + "\" y2=\"" + fnum(by) + "\""
            + " gradientUnits=\"userSpaceOnUse\">"
            + "<stop offset=\"0%\" stop-color=\"" + color-i + "\"/>"
            + "<stop offset=\"" + off-s + "%\" stop-color=\"" + color-i + "\"/>"
            + "<stop offset=\"" + off-s + "%\" stop-color=\"" + color-j + "\"/>"
            + "<stop offset=\"100%\" stop-color=\"" + color-j + "\"/>"
            + "</linearGradient></defs>")
          def + _line(ax, ay, bx, by, "url(#" + sid + ")", w, dash: dash)
        } else {
          let mx = ax + (bx - ax) * t
          let my = ay + (by - ay) * t
          let lhs = shaded-stroke(ax, ay, mx, my, color-i, bond-id + "-" + str(ib) + "-l")
          let rhs = shaded-stroke(mx, my, bx, by, color-j, bond-id + "-" + str(ib) + "-r")
          (
            lhs.def,
            _line(ax, ay, mx, my, lhs.stroke, w, dash: dash),
            rhs.def,
            _line(mx, my, bx, by, rhs.stroke, w, dash: dash),
          ).join("")
        }
      } else {
        // Same-colour or no-element-split: single line.
        // Upstream `if c1 == c2: _bond_line(...)` branch.
        let stroke-color = if bond-by-element { color-i } else { base-color }
        let s = shaded-stroke(ax, ay, bx, by, stroke-color, bond-id + "-" + str(ib))
        s.def + _line(ax, ay, bx, by, s.stroke, w, dash: dash)
      }
    }
  }

  // ib values: aromatic always uses [-1, +1]; otherwise range(-nb+1, nb, 2).
  let ibs = if aromatic-eff {
    (-1, 1)
  } else {
    let acc = ()
    let i = -nb + 1
    while i < nb {
      acc.push(i)
      i = i + 2
    }
    acc
  }
  ibs.map(ib => one-line(ib)).join("")
}

// Upstream `bond_geom` precomputation (renderer.py:1410-1456).
//
//   _d  = (pos[j] - pos[i]) / |pos[j] - pos[i]|     unit 3D direction
//   _ri, _rj = radii[i], radii[j]                    display radii in Å
//   _start = pos[i] + _d * (_ri * 0.9)               shortened start
//   _end   = pos[j] - _d * (_rj * 0.9)               shortened end
//   valid &= ((_end - _start) . _d) > 0              endpoints not crossed
//   project to 2D, then:
//   ppx = -ddy / ln,  ppy = ddx / ln                 perpendicular
//   valid &= ln >= 1                                 min projected length
//
// Returns either a record dict or `none` when degenerate.
#let _bond-geom(i, j, coords-3d, radii-ang, scale, center, canvas-w, canvas-h) = {
  let pi = (float(coords-3d.at(i).at(0)), float(coords-3d.at(i).at(1)), float(coords-3d.at(i).at(2)))
  let pj = (float(coords-3d.at(j).at(0)), float(coords-3d.at(j).at(1)), float(coords-3d.at(j).at(2)))
  let dx3 = pj.at(0) - pi.at(0)
  let dy3 = pj.at(1) - pi.at(1)
  let dz3 = pj.at(2) - pi.at(2)
  let dist3 = calc.sqrt(dx3 * dx3 + dy3 * dy3 + dz3 * dz3)
  if dist3 < 0.000001 { return none }
  let ux = dx3 / dist3
  let uy = dy3 / dist3
  let uz = dz3 / dist3

  let ri = radii-ang.at(i)
  let rj = radii-ang.at(j)
  let sx3 = pi.at(0) + ux * ri * 0.9
  let sy3 = pi.at(1) + uy * ri * 0.9
  let sz3 = pi.at(2) + uz * ri * 0.9
  let ex3 = pj.at(0) - ux * rj * 0.9
  let ey3 = pj.at(1) - uy * rj * 0.9
  let ez3 = pj.at(2) - uz * rj * 0.9

  // Endpoint integrity (upstream `_dot_check > 0`)
  let dot = (ex3 - sx3) * ux + (ey3 - sy3) * uy + (ez3 - sz3) * uz
  if dot <= 0 { return none }

  let (sx, sy) = project((sx3, sy3, sz3), scale, center, canvas-w, canvas-h)
  let (ex, ey) = project((ex3, ey3, ez3), scale, center, canvas-w, canvas-h)
  let ddx = ex - sx
  let ddy = ey - sy
  let ln = calc.sqrt(ddx * ddx + ddy * ddy)
  if ln < 1.0 { return none }
  (
    x1: sx, y1: sy, x2: ex, y2: ey,
    px: -ddy / ln, py: ddx / ln,
  )
}

// Helper: build a bond record with all info needed for both passes.
//
// `style` is "solid" | "dashed" | "dotted" — DASHED for TS overlays,
// DOTTED for NCI overlays. Non-solid styles ignore bond order and the
// aromatic flag (matches upstream renderer.py:1201-1330 where TS/NCI
// always render as a single dashed/dotted line).
#let _bond-record(
  k, bonds, orders, bond-orders-on,
  coords-3d, radii-ang, scale, center, canvas-w, canvas-h,
  elements, config, fog-fs, fog-col, bond-color-raw, bond-outline-color-raw,
  aromatic-flags, aromatic-rings,
  style: "solid",
) = {
  let pair = bonds.at(k)
  let i = int(pair.at(0))
  let j = int(pair.at(1))
  let geom = _bond-geom(i, j, coords-3d, radii-ang, scale, center, canvas-w, canvas-h)
  if geom == none { return none }

  // Upstream: bo = bo if bcfg.bond_orders else 1.0
  let order = if style != "solid" {
    1
  } else if not bond-orders-on {
    1
  } else if k < orders.len() {
    int(orders.at(k))
  } else {
    1
  }
  // Aromatic flag + ring_side for the dashed-inner pair (renderer.py:1345).
  // Only honoured when bond_orders is on — otherwise upstream renders all
  // bonds as plain singles regardless of order. TS/NCI overlays skip
  // the aromatic path entirely.
  let is-aromatic = style == "solid" and bond-orders-on and k < aromatic-flags.len() and aromatic-flags.at(k)
  let ring-side = if is-aromatic {
    _ring-side(
      i, j, aromatic-rings, coords-3d,
      scale, center, canvas-w, canvas-h,
      geom.x1, geom.y1, geom.x2, geom.y2, geom.px, geom.py,
    )
  } else {
    1
  }
  let ci-raw = element-color(elements.at(i), config)
  let cj-raw = element-color(elements.at(j), config)
  // Upstream renderer.py:1033, 1256 (v0.3.3): bond *fill* colour fog uses
  //   avg_fog = (fi + fj) / 2                        # the ×0.75 fudge is gone
  //   blend_fog(hex, fog_col, avg_fog)
  let fi = fog-fs.at(i)
  let fj = fog-fs.at(j)
  let avg-fog = (fi + fj) / 2.0
  let fog-fill(hex) = if avg-fog > 0.0 { blend-fog(hex, fog-col, avg-fog) } else { hex }
  // Upstream renderer.py:1267-1269: bond *outline* fog is per-endpoint
  //   _si = blend_fog(stroke, fog_col, fi);  _sj = blend_fog(stroke, fog_col, fj)
  // and _emit_line emits a linearGradient when the two differ.
  let fog-out(hex, f) = if f > 0.0 { blend-fog(hex, fog-col, f) } else { hex }
  (
    i: i, j: j, order: order, style: style,
    aromatic: is-aromatic, ring_side: ring-side,
    // Display radii (Å) — used for upstream's width-weighted half-bond
    // split (renderer.py:1055). Upstream passes raw_vdw, but in v1
    // every atom shares the same `atom_scale * 0.075` factor so the
    // ri / (ri + rj) ratio is identical either way.
    ri: radii-ang.at(i), rj: radii-ang.at(j),
    x1: geom.x1, y1: geom.y1, x2: geom.x2, y2: geom.y2,
    px: geom.px, py: geom.py,
    ci: fog-fill(ci-raw), cj: fog-fill(cj-raw),
    base: fog-fill(bond-color-raw),
    oi: fog-out(bond-outline-color-raw, fi),
    oj: fog-out(bond-outline-color-raw, fj),
  )
}

// ---- main entry ----

#let render-svg(data, config) = {
  let id-prefix = "xr"
  let n = data.elements.len()

  // Per-atom config resolution for style regions (upstream
  // renderer.py:96-104).
  //
  // `_acfg.at(ai)` is the RenderConfig in effect for atom `ai`. When
  // `style_regions` is empty it's a length-n list of the base config
  // — no overhead at the use sites since the dict identity is shared.
  //
  // Fields that style regions can override (must mirror upstream's
  // per-atom-overrideable surface):
  //   - atom_scale, atom_stroke_width, atom_stroke_color
  //   - gradient, atom_gradient_strength, atom_wash
  //   - colors (element → hex overrides; via element-color)
  //   - h_scale, radius_scale (via display-radius)
  // Bond-side per-atom overrides (renderer.py:953-955, 1169-1170)
  // stay deferred — bond rendering uses the base config.
  let style-regions = config.at("style_regions", default: ())
  let _acfg = if style-regions.len() == 0 {
    range(n).map(_ => config)
  } else {
    let rmap = (:)
    for region in style-regions {
      let rcfg = region.config
      for ai in region.indices {
        rmap.insert(str(int(ai)), rcfg)
      }
    }
    range(n).map(ai => rmap.at(str(ai), default: config))
  }
  let any-region = style-regions.len() > 0

  // 1. Geometry: PCA orientation, user rotation, fit, projection.
  //
  // Upstream renderer.py:110-142 PCA-orients before anything else when
  // `cfg.auto_orient` is on (CLI default true via config.py:400). The
  // user-supplied `rotate: (x:..., y:..., z:...)` then composes on top.
  // Without the PCA pass, molecules whose principal axis isn't already
  // along x render with their long axis vertical / depth-wise, and
  // canvases shaped by `_fit_canvas` come out looking nothing like
  // CLI output (water.xyz lies in the y-z plane → 242×800 sliver).
  let oriented-coords = if config.at("auto_orient", default: defaults.auto_orient) and data.coords.len() > 1 {
    pca-orient(data.coords)
  } else {
    data.coords
  }
  let coords-3d = apply-rotation(
    oriented-coords,
    config.at("rotate", default: (:)),
  )

  // Per-atom display radius in Angstroms, with optional per-element
  // `radius_scale` overrides (upstream renderer.py:165-179).
  // Upstream's selector resolution supports arbitrary selectors; v1
  // only supports element-symbol keys since that's what every
  // upstream preset JSON uses (btube: {"H": 1.2}).
  let radius-scale = config.at("radius_scale", default: (:))
  // Per-atom display radius: when style_regions are active, each atom
  // resolves through its own acfg (so a region with atom_scale=4.0
  // produces a 4× larger sphere than the base). `radius_scale` is a
  // global field (not per-atom) — upstream's selector-based
  // resolution is out of scope; v1 element-keyed only.
  let radii-ang = range(n).map(ai => {
    let e = data.elements.at(ai)
    let r = display-radius(e, _acfg.at(ai))
    if e in radius-scale {
      r * float(radius-scale.at(e))
    } else {
      r
    }
  })

  // VDW overlay set (upstream renderer.py:189-193). `vdw_indices`
  // accepts:
  //   * `none`            — no overlay
  //   * `()`              — overlay every atom
  //   * `(1, 5, 8)`       — explicit integer list (subject to `index_base`)
  //   * `"31-38,M,1,4"`  — selector spec (routed through `resolve-atom-indices`;
  //                        also subject to `index_base`)
  // Resolved here so `fit_radii` can swap the overlay's larger VDW
  // spheres into the bounding-box computation.
  let vdw-indices = config.at("vdw_indices", default: defaults.vdw_indices)
  let index-base = int(config.at("index_base", default: defaults.index_base))
  let vdw-scale-cfg = float(config.at("vdw_scale", default: defaults.vdw_scale))
  let vdw-h-scale = float(config.at("vdw_h_scale", default: defaults.vdw_h_scale))
  let vdw-set = if vdw-indices == none {
    none
  } else if type(vdw-indices) == str {
    // Selector spec — empty string = every atom, matching the `()` sentinel.
    if vdw-indices.trim().len() == 0 {
      range(n)
    } else {
      resolve-atom-indices(
        vdw-indices, data.elements,
        bonds: data.at("bonds", default: ()),
        index-base: index-base,
      )
    }
  } else if vdw-indices.len() == 0 {
    range(n)
  } else {
    vdw-indices.map(i => int(i) - index-base)
  }
  let raw-vdw-3d = data.elements.map(e => raw-vdw-sphere(e, vdw-h-scale))
  let fit-radii-ang = if vdw-set == none {
    radii-ang
  } else {
    let set-lookup = range(n).map(_ => false)
    for i in vdw-set { set-lookup.at(i) = true }
    range(n).map(i => {
      if set-lookup.at(i) {
        raw-vdw-3d.at(i) * vdw-scale-cfg
      } else {
        radii-ang.at(i)
      }
    })
  }

  let (canvas-w, canvas-h, scale, center) = fit-canvas(coords-3d, fit-radii-ang, config)
  let coords-2d = coords-3d.map(p =>
    project(p, scale, center, canvas-w, canvas-h)
  )
  let radii-px = radii-ang.map(r => r * scale)

  // 2. Fog factors (one per atom; all zeros when fog off) + fog target
  //    colour (upstream renderer.py:493-495: fog converges on the
  //    background, or `fog_color` if set; "none"/transparent → white).
  let fog-fs = compute-fog-factors(coords-3d, config)
  let fog-col = fog-target(
    config.at("background", default: defaults.background),
    fog-color: config.at("fog_color", default: defaults.fog_color),
  )

  // 3. Scaled widths (upstream's "reference geometry" system).
  let scale-ratio = scale / ref-scale(config)
  let bw = float(config.at("bond_width", default: defaults.bond_width)) * scale-ratio
  let bond-outline-w = float(config.at("bond_outline_width", default: defaults.bond_outline_width)) * scale-ratio
  let stroke-w = float(config.at("atom_stroke_width", default: defaults.atom_stroke_width)) * scale-ratio
  let gap = float(config.at("bond_gap", default: defaults.bond_gap)) * bw
  // Per-atom stroke widths (upstream renderer.py:271-279). Only
  // populated when any style region overrides atom_stroke_width;
  // otherwise the global `stroke-w` is reused.
  let atom-sw-per = range(n).map(ai => {
    float(_acfg.at(ai).at("atom_stroke_width", default: defaults.atom_stroke_width)) * scale-ratio
  })
  // Upstream renderer.py:260: fs_label = cfg.label_font_size * scale_ratio.
  let fs-label = float(config.at("label_font_size", default: defaults.label_font_size)) * scale-ratio

  // 4. Style switches.
  let gradient-on = config.at("gradient", default: defaults.gradient)
  let bond-by-element = config.at("bond_color_by_element", default: defaults.bond_color_by_element)
  let bond-orders-on = config.at("bond_orders", default: defaults.bond_orders)
  let bond-gradient-on = config.at("bond_gradient", default: defaults.bond_gradient)
  let bond-gradient-strength = float(config.at("bond_gradient_strength", default: defaults.bond_gradient_strength))
  let bond-color-raw = resolve-color(config.at("bond_color", default: defaults.bond_color))
  let bond-outline-color = resolve-color(config.at("bond_outline_color", default: defaults.bond_outline_color))
  let stroke-color-raw = resolve-color(config.at("atom_stroke_color", default: defaults.atom_stroke_color))
  let atom-wash = float(config.at("atom_wash", default: defaults.atom_wash))
  // Upstream renderer.py:564: use_per_atom_grad = cfg.fog.
  let use-per-atom-grad = config.at("fog", default: defaults.fog)
  // Atom index labels (upstream renderer.py:1663-1672).
  let show-indices = config.at("show_indices", default: defaults.show_indices)
  let idx-format = config.at("idx_format", default: defaults.idx_format)
  let label-color = resolve-color(config.at("label_color", default: defaults.label_color))

  // 5. Pre-build per-bond records (geometry + fogged colours).
  //    Degenerate bonds (atoms overlapping in 3D, projection too short)
  //    are filtered out — matches upstream `_valid` mask.
  // Upstream renderer.py:413,487 — `hide_bonds` skips the whole bond dict
  // (incl. the TS/NCI manual overrides at 432-434, which live inside the
  // `if not cfg.hide_bonds:` block) and the aromatic-ring computation, so
  // only atoms are drawn. Mirror that by emptying every bond input up front;
  // the TS/NCI overlay inputs are zeroed below for the same reason.
  let hide-bonds = config.at("hide_bonds", default: defaults.hide_bonds)
  let bonds = if hide-bonds { () } else { data.at("bonds", default: ()) }
  let orders = if hide-bonds { () } else { data.at("bond_orders", default: ()) }
  let aromatic-flags = if hide-bonds { () } else { data.at("aromatic_flags", default: ()) }
  let aromatic-rings = if hide-bonds { () } else { data.at("aromatic_rings", default: ()) }

  // TS / NCI overlay pairs (upstream RenderConfig.ts_bonds /
  // .nci_bonds — types.py:288-289). Each entry is either an explicit
  // `(i, j)` integer pair or a `"1-4"` pair-spec string; both forms are
  // subject to `index_base` (default 1), matching `bond`/`unbond`
  // (bond_rules.typ) and `vdw_indices`/`hy` so every index-accepting
  // keyword shares one document-wide numbering, switchable via
  // `xyzrender.with(index_base: 0)`. A bare string (`ts_bonds: "1-4"`)
  // is treated as a one-element list, same convenience as `bond`/
  // `unbond`/`vdw_indices`.
  // Build a canonical "i,j" -> style lookup so pairs already in `bonds`
  // get restyled in place (upstream renderer.py:430-433
  // `bonds.get(...)._replace(style=...)`); pairs not already present
  // are appended as new entries with parallel orders / aromatic_flags
  // so the three arrays stay aligned.
  let _index-base = int(config.at("index_base", default: defaults.index_base))
  let _as-pair-list(x) = if type(x) == str { (x,) } else { x }
  let _ts-input = _as-pair-list(if hide-bonds { () } else { config.at("ts_bonds", default: defaults.ts_bonds) })
  let _nci-input = _as-pair-list(if hide-bonds { () } else { config.at("nci_bonds", default: defaults.nci_bonds) })
  let _normalize-pair(pair) = {
    let (i, j) = if type(pair) == str {
      let parsed = _parse-index-pair(pair, index-base: _index-base)
      if parsed == none {
        panic("xyzrender: ts_bonds/nci_bonds pair strings must look like \"1-4\" (index_base: " + str(_index-base) + "), got \"" + pair + "\"")
      }
      parsed
    } else {
      (int(pair.at(0)) - _index-base, int(pair.at(1)) - _index-base)
    }
    if i < j { (i, j) } else { (j, i) }
  }
  let style-overrides = (:)  // "i,j" -> "dashed" | "dotted"
  let extra-pairs = ()        // pairs not already in `bonds`, append below
  let extra-styles = ()
  // Track existence with a canonical-key map
  let _present = (:)
  for k in range(bonds.len()) {
    let p = bonds.at(k)
    let i = int(p.at(0))
    let j = int(p.at(1))
    let key = if i < j { str(i) + "," + str(j) } else { str(j) + "," + str(i) }
    _present.insert(key, true)
  }
  // NCI first so TS wins on conflict (mirrors upstream's "TS overrides"
  // ordering — renderer.py applies ts_bonds after nci_bonds).
  for pair in _nci-input {
    let (i, j) = _normalize-pair(pair)
    if i < 0 or j < 0 or i >= n or j >= n or i == j { continue }
    let key = str(i) + "," + str(j)
    style-overrides.insert(key, "dotted")
    if not (key in _present) {
      extra-pairs.push((i, j))
      extra-styles.push("dotted")
      _present.insert(key, true)
    }
  }
  for pair in _ts-input {
    let (i, j) = _normalize-pair(pair)
    if i < 0 or j < 0 or i >= n or j >= n or i == j { continue }
    let key = str(i) + "," + str(j)
    style-overrides.insert(key, "dashed")
    if not (key in _present) {
      extra-pairs.push((i, j))
      extra-styles.push("dashed")
      _present.insert(key, true)
    }
  }
  let combined-bonds = bonds + extra-pairs
  let combined-orders = orders + extra-pairs.map(_ => 1)
  let combined-aromatic = aromatic-flags + extra-pairs.map(_ => false)
  let bond-styles = range(bonds.len()).map(k => {
    let p = bonds.at(k)
    let i = int(p.at(0))
    let j = int(p.at(1))
    let key = if i < j { str(i) + "," + str(j) } else { str(j) + "," + str(i) }
    style-overrides.at(key, default: "solid")
  }) + extra-styles

  // Hidden-atom set (upstream renderer.py:467-483).
  //   if cfg.hide_h:
  //       show = set(cfg.show_h_indices)
  //       for ai in range(n):
  //           if symbols[ai] == "H" and ai not in show:
  //               neighbours = list(graph.neighbors(ai))
  //               if neighbours and all(symbols[nb] == "C" for nb in neighbours):
  //                   hidden.add(ai)
  // We hide ONLY C-H hydrogens (preserving O-H, N-H, free H) to mirror
  // upstream's auto-hide behaviour. `show_h_indices` is the carve-out
  // that the `hy` API kwarg routes into.
  //
  // Stored as a boolean LUT keyed by atom index so the painter's loop
  // can branch in O(1).
  let hide-h = config.at("hide_h", default: defaults.hide_h)
  let show-h-set = range(n).map(_ => false)
  for i in config.at("show_h_indices", default: defaults.show_h_indices) {
    let ii = int(i)
    if 0 <= ii and ii < n { show-h-set.at(ii) = true }
  }
  // Auto-show H atoms involved in manual TS / NCI pairs (upstream
  // renderer.py:471-478). Without this guard, an H referenced by an
  // overlay pair but bonded only to C would be hidden by the C-only
  // neighbour check below, orphaning the dashed/dotted line.
  for pair in extra-pairs {
    let i = int(pair.at(0))
    let j = int(pair.at(1))
    if 0 <= i and i < n and data.elements.at(i) == "H" { show-h-set.at(i) = true }
    if 0 <= j and j < n and data.elements.at(j) == "H" { show-h-set.at(j) = true }
  }
  let hidden-lut = range(n).map(_ => false)
  if hide-h {
    // Per-atom neighbour element list (mirrors upstream's
    // `list(graph.neighbors(ai))` lookup).
    // Use the RAW connectivity (data.bonds), not the possibly-emptied
    // draw list: upstream hides H via `graph.neighbors`, which is
    // independent of `hide_bonds` (that only skips drawing). Otherwise
    // `hide_bonds` presets (bubble/vdw) would stop hiding H.
    let neighbour-elements = range(n).map(_ => ())
    for pair in data.at("bonds", default: ()) {
      let p = int(pair.at(0))
      let q = int(pair.at(1))
      neighbour-elements.at(p).push(data.elements.at(q))
      neighbour-elements.at(q).push(data.elements.at(p))
    }
    for ai in range(n) {
      if data.elements.at(ai) == "H" and not show-h-set.at(ai) {
        let nbs = neighbour-elements.at(ai)
        if nbs.len() > 0 and nbs.all(e => e == "C") {
          hidden-lut.at(ai) = true
        }
      }
    }
  }
  let bond-records = range(combined-bonds.len())
    .map(k => _bond-record(
      k, combined-bonds, combined-orders, bond-orders-on,
      coords-3d, radii-ang, scale, center, canvas-w, canvas-h,
      data.elements, config, fog-fs, fog-col, bond-color-raw, bond-outline-color,
      combined-aromatic, aromatic-rings,
      style: bond-styles.at(k),
    ))
    .filter(r => r != none)

  // 6. Painter's algorithm — interleaved per atom, ported verbatim
  //    from upstream renderer.py:1465-1700:
  //
  //    z_order = argsort(z)            # ascending z = back to front
  //    for idx, ai in enumerate(z_order):
  //        outgoing = [(aj, k) for aj in bond_adj[ai] if z_rank[aj] > idx]
  //        outgoing.sort(key=lambda b: z_rank[b[0]])  # shallowest-last
  //        # Phase 1: outlines for interleaved bonds (both scales > 0)
  //        for (aj, k) in outgoing:
  //            if interleaved(ai, aj): emit outline
  //        # Atom disc
  //        emit_atom(ai)
  //        # Phase 2: fills (and outline+fill for non-interleaved bonds)
  //        for (aj, k) in outgoing:
  //            if interleaved(ai, aj): emit fill
  //            else:                   emit outline + fill

  let z-order = range(n).sorted(key: i => float(coords-3d.at(i).at(2)))
  // z-rank[ai] = idx where z-order[idx] == ai.  Built immutably via
  // position() to dodge Typst array-mutation quirks.
  let z-rank = range(n).map(ai => z-order.position(j => j == ai))

  // Upstream `_bond_interleaved` (renderer.py:1451-1452):
  //   return _atom_scale_per[ai_b] > 0 and _atom_scale_per[aj_b] > 0
  // Configured atom_scale, not the dot-fallback bumped radius. v1 has
  // no per-atom atom_scale override, so this is a single global flag.
  let atom-scale-cfg = float(config.at("atom_scale", default: defaults.atom_scale))
  let interleaved(_ai, _aj) = atom-scale-cfg > 0.0

  // Interlocked silhouette polygons (upstream renderer.py:1453-1461).
  // Computed only when `atom_interlocking` is on (the `vdw` preset).
  // Each entry is either `none` (atom emits as plain <circle>) or a
  // list of (x, y) tuples in Angstrom-xy space, projected here.
  let atom-interlocking = config.at("atom_interlocking", default: defaults.atom_interlocking)
  let interlock-samples = int(config.at("vdw_interlock_samples", default: defaults.vdw_interlock_samples))
  let atom-polys-px = if atom-interlocking and n > 0 {
    let polys-ang = compute-interlock-polygons(
      coords-3d, radii-ang, samples: interlock-samples,
    )
    polys-ang.map(poly => {
      if poly == none {
        none
      } else {
        poly.map(p => project((p.at(0), p.at(1), 0.0), scale, center, canvas-w, canvas-h))
      }
    })
  } else {
    range(n).map(_ => none)
  }

  // Atom-dot fallback (upstream renderer.py:1599-1606). Atoms with
  // radius < _dot_r that have NO solid bond passing through them
  // (only NCI/TS edges, or no bonds at all) get bumped to a small
  // dot so they remain visible. For basic XYZ with all-solid bonds
  // this only triggers on isolated atoms. Polygon atoms keep their
  // sphere radius — they're never dots (renderer.py:1597).
  let dot-r = if bw > 0 { (bw / 2.0) * 1.2 } else { 0.0 }
  // Upstream renderer.py:461-465 only counts SOLID bonds — TS/NCI
  // overlays are dashed/dotted overlays, not load-bearing covalent
  // bonds, so atoms touching only TS/NCI edges still fall back to a
  // dot. Walk bond-records (which carry the per-edge style) instead
  // of the raw bond list.
  let has-solid-bond = range(n).map(_ => false)
  for b in bond-records {
    if b.style == "solid" {
      has-solid-bond.at(b.i) = true
      has-solid-bond.at(b.j) = true
    }
  }
  let is-dot-fallback = range(n).map(ai => {
    radii-px.at(ai) < dot-r and bw > 0 and not has-solid-bond.at(ai) and atom-polys-px.at(ai) == none
  })
  let render-r-px = range(n).map(ai => {
    if is-dot-fallback.at(ai) { dot-r } else { radii-px.at(ai) }
  })

  // TS / NCI overlay styling (upstream RenderConfig — types.py:259-266
  // and renderer.py:1273-1330). Defaults match upstream so presets that
  // don't override these still render at the canonical look.
  let ts-color-cfg = config.at("ts_color", default: defaults.ts_color)
  let ts-element-cfg = config.at("ts_element", default: defaults.ts_element)
  let ts-dash-cfg = config.at("ts_dash", default: defaults.ts_dash)
  let ts-width-cfg = float(config.at("ts_width", default: defaults.ts_width))
  let nci-color-cfg = config.at("nci_color", default: defaults.nci_color)
  let nci-element-cfg = config.at("nci_element", default: defaults.nci_element)
  let nci-dash-cfg = config.at("nci_dash", default: defaults.nci_dash)
  let nci-width-cfg = float(config.at("nci_width", default: defaults.nci_width))

  let emit-bond-pass(pass, k) = {
    let b = bond-records.at(k)
    // Style-specific overrides: width multiplier, dash pattern, base
    // colour, and the element-split switch (upstream renderer.py:
    // 1201-1330). Width is capped at `20 * scale_ratio` to mirror
    // upstream's `_bw = min(_bw, 20.0 * scale_ratio)` (renderer.py:1202),
    // re-deriving scale_ratio from `bw / defaults.bond_width`.
    let style-bw = bw
    let style-gap = gap
    let style-base = b.base
    let style-ci = b.ci
    let style-cj = b.cj
    let style-by-element = bond-by-element
    let dash-pat = ""
    if b.style == "dashed" {
      let _sr = bw / float(defaults.bond_width)
      style-bw = calc.min(bw, 20.0 * _sr) * ts-width-cfg
      style-gap = float(config.at("bond_gap", default: defaults.bond_gap)) * style-bw
      let (dm, gm) = (float(ts-dash-cfg.at(0)), float(ts-dash-cfg.at(1)))
      dash-pat = fnum(style-bw * dm) + "," + fnum(style-bw * gm)
      if ts-color-cfg != none {
        let hex = resolve-color(ts-color-cfg)
        style-base = hex
        // Flat colour suppresses by-element split (upstream
        // renderer.py:1247 — `ts_element and ts_color is None`).
        style-by-element = false
      } else {
        // Honour ts_element only when no flat ts_color and bond
        // colouring is on for the base config.
        style-by-element = bond-by-element and ts-element-cfg
      }
    } else if b.style == "dotted" {
      let _sr = bw / float(defaults.bond_width)
      style-bw = calc.min(bw, 20.0 * _sr) * nci-width-cfg
      style-gap = float(config.at("bond_gap", default: defaults.bond_gap)) * style-bw
      let (dm, gm) = (float(nci-dash-cfg.at(0)), float(nci-dash-cfg.at(1)))
      dash-pat = fnum(style-bw * dm) + "," + fnum(style-bw * gm)
      if nci-color-cfg != none {
        let hex = resolve-color(nci-color-cfg)
        style-base = hex
        style-by-element = false
      } else {
        style-by-element = bond-by-element and nci-element-cfg
      }
    }
    _emit-bond-segment(
      pass, "b" + str(k), b.x1, b.y1, b.x2, b.y2, b.px, b.py, b.order,
      style-ci, style-cj, style-base,
      b.ri, b.rj,
      style-bw, style-gap, style-by-element,
      b.oi, b.oj, bond-outline-w,
      bond-gradient: bond-gradient-on,
      bond-gradient-config: config,
      bond-gradient-strength: bond-gradient-strength,
      aromatic: b.aromatic,
      ring-side: b.ring_side,
      style: b.style,
      dash-pattern: dash-pat,
    )
  }

  let emit-atom-disc(ai) = {
    let acfg = _acfg.at(ai)
    let elem = data.elements.at(ai)
    let (cx, cy) = coords-2d.at(ai)
    let r = render-r-px.at(ai)
    // Per-atom config reads (upstream renderer.py:1558, 1582-1583).
    // Style regions can override colour, gradient, stroke colour/width,
    // wash, and gradient strength.
    let base = element-color(elem, acfg)
    let atom-gradient-on = acfg.at("gradient", default: defaults.gradient)
    // Upstream renderer.py:1580-1581 — `atom_stroke_color == "atom"` is a
    // sentinel meaning "stroke with the atom's own element colour", not a
    // literal colour. Resolve it to `base` (the resolved element colour, incl.
    // config.colors overrides); otherwise resolve as a normal colour. Without
    // this, the graph preset (`atom_stroke_color: "atom"`) fell through to
    // resolve-color's `#ff1493` unresolved-colour sentinel on every atom.
    let atom-stroke-src = acfg.at("atom_stroke_color", default: defaults.atom_stroke_color)
    let atom-stroke-color-raw = if atom-stroke-src == "atom" { base } else { resolve-color(atom-stroke-src) }
    let atom-wash-cfg = float(acfg.at("atom_wash", default: defaults.atom_wash))
    let dot = is-dot-fallback.at(ai)
    let poly = atom-polys-px.at(ai)

    // Upstream renderer.py:1601-1603: when dot fallback triggers AND
    // the existing stroke width is smaller than bond_outline_width,
    // both the width and the colour swap together. If the atom stroke
    // is already wider than the bond outline, neither changes.
    let stroke-w-this = atom-sw-per.at(ai)
    let dot-bump = dot and stroke-w-this < bond-outline-w
    let sw-atom = if dot-bump { bond-outline-w } else { stroke-w-this }
    let stroke-base = if dot-bump { bond-outline-color } else { atom-stroke-color-raw }

    // Upstream renderer.py:1621-1635: polygon-shape atoms (and any
    // style-region atom that overrides `gradient` /
    // `atom_gradient_strength`, since the shared <defs> entries
    // are emitted from the base config) need a per-atom inline
    // userSpaceOnUse gradient anchored at the sphere centre.
    // Plain <circle> atoms reuse the shared per-atom or
    // per-element gradient from `_emit-defs`.
    let inline-grad-id = id-prefix + "-pg" + str(ai)
    let inline-grad-def = ""
    let needs-inline-grad = poly != none or (any-region and atom-gradient-on)
    let gradient-id = if needs-inline-grad and atom-gradient-on {
      let (hi, me, lo) = _per-atom-grad-colors(base, acfg, fog-fs.at(ai), fog-col)
      inline-grad-def = _sphere-grad-def(
        inline-grad-id, cx, cy, r,
        (("0%", hi), ("40%", me), ("100%", lo)),
      )
      inline-grad-id
    } else if use-per-atom-grad {
      id-prefix + "-g" + str(ai)
    } else {
      id-prefix + "-ge-" + elem + "-" + base.slice(1)
    }

    let fill = if atom-gradient-on {
      "url(#" + gradient-id + ")"
    } else {
      // Upstream renderer.py:1664 — atom_wash blends base toward
      // WHITE, only in the flat-fill case (not gradient).
      let washed = if atom-wash-cfg > 0.0 {
        rgb-blend(base, WHITE, atom-wash-cfg)
      } else {
        base
      }
      if fog-fs.at(ai) > 0.0 {
        blend-fog(washed, fog-col, fog-fs.at(ai))
      } else {
        washed
      }
    }

    // Upstream renderer.py:1656 — atom stroke is fogged whenever
    // `cfg.fog` is on, gradient or flat.
    let stroke = if fog-fs.at(ai) > 0.0 {
      blend-fog(stroke-base, fog-col, fog-fs.at(ai))
    } else {
      stroke-base
    }

    let shape = if poly != none {
      _polygon(poly, fill, stroke, sw-atom)
    } else {
      _circle(cx, cy, r, fill, stroke, sw-atom)
    }
    inline-grad-def + shape
  }

  let body-parts = ()
  // Upstream `_bond_outline_layer` (renderer.py:1128, 1697-1698):
  // outlines for NON-interleaved bonds (phase == "both") are deferred
  // into a back layer that gets spliced in at `_molecule_insert_idx`,
  // i.e. below every atom and bond fill. Interleaved outlines stay
  // inline so the next atom disc masks the central join.
  let bond-outline-layer = ()
  // Upstream `_deferred_atom_layers` (renderer.py:961,1671-1674,1712-1713):
  // when `atoms_above_bonds` is set, an atom's disc+label are pulled out of
  // the interleaved stream and appended after every bond, so atoms draw on
  // top (still z-ordered among themselves). Used by the `graph` preset.
  let atoms-above-bonds = config.at("atoms_above_bonds", default: defaults.atoms_above_bonds)
  let deferred-atom-parts = ()
  for idx in range(z-order.len()) {
    let ai = z-order.at(idx)
    // Hidden C-H atoms (upstream renderer.py:1490 `if ai in hidden:
    // continue`) — skip the disc, the label, AND every outgoing bond.
    if hidden-lut.at(ai) { continue }

    // outgoing bonds to atoms NOT YET rendered (deeper-rank atoms).
    // Scan bond-records directly so we don't need a mutable adj list.
    // Upstream renderer.py:1504 also drops bonds whose `aj` is hidden;
    // mirror that with the hidden-lut check here.
    let outgoing = ()
    for k in range(bond-records.len()) {
      let b = bond-records.at(k)
      let other = if b.i == ai {
        b.j
      } else if b.j == ai {
        b.i
      } else {
        -1
      }
      if other != -1 and z-rank.at(other) > idx and not hidden-lut.at(other) {
        outgoing.push((other, k))
      }
    }
    // sort by other-atom's z_rank (shallowest-last, matching upstream).
    outgoing = outgoing.sorted(key: e => z-rank.at(e.at(0)))

    // Phase 1: outlines for interleaved bonds.
    for entry in outgoing {
      let aj = entry.at(0)
      let k = entry.at(1)
      if interleaved(ai, aj) {
        body-parts.push(emit-bond-pass("outline", k))
      }
    }

    // Atom disc. Skip if render-r-px is 0 (atom_scale=0 + no dot
    // fallback). With dot fallback (isolated atom in tube/wire),
    // render-r-px is dot_r so the atom appears as a small dot.
    if render-r-px.at(ai) > 0.5 {
      let disc = emit-atom-disc(ai)
      if atoms-above-bonds { deferred-atom-parts.push(disc) } else { body-parts.push(disc) }
    }

    // Atom index label — depth-sorted with the atom so nearer atoms
    // occlude (upstream renderer.py:1663-1672). `idx_format`:
    //   "sn" -> "{sym}{ai+1}"  (e.g. C1)
    //   "s"  -> "{sym}"        (e.g. C)
    //   "n"  -> "{ai+1}"       (e.g. 1)
    if show-indices {
      let sym = data.elements.at(ai)
      let idx-text = if idx-format == "sn" {
        sym + str(ai + 1)
      } else if idx-format == "s" {
        sym
      } else {
        str(ai + 1)
      }
      let (lx, ly) = coords-2d.at(ai)
      let label = _text-svg(lx, ly, idx-text, fs-label, label-color, halo: false)
      if atoms-above-bonds { deferred-atom-parts.push(label) } else { body-parts.push(label) }
    }

    // Phase 2: fills inline; non-interleaved outlines pushed to the
    // back layer (upstream `_bond_outline_layer`, renderer.py:1128).
    for entry in outgoing {
      let aj = entry.at(0)
      let k = entry.at(1)
      if interleaved(ai, aj) {
        body-parts.push(emit-bond-pass("fill", k))
      } else {
        bond-outline-layer.push(emit-bond-pass("outline", k))
        body-parts.push(emit-bond-pass("fill", k))
      }
    }
  }
  // Drain deferred atom layers on top of every bond (upstream
  // renderer.py:1712-1713 `svg.extend(_deferred_atom_layers)`).
  body-parts += deferred-atom-parts

  // 7. VDW overlay (upstream renderer.py:1766-1816). Wrapped in a
  //    single <g opacity=...> so overlapping spheres composite as one
  //    semi-transparent layer instead of stacking opacities. Rendered
  //    after the molecule body and after all surfaces (out of scope
  //    in v1), so it sits on top.
  let vdw-overlay = if vdw-set == none {
    ""
  } else {
    let vdw-opacity = float(config.at("vdw_opacity", default: defaults.vdw_opacity))
    let vdw-grad-strength = float(config.at("vdw_gradient_strength", default: defaults.vdw_gradient_strength))
    let vdw-interlocking = config.at("vdw_interlocking", default: defaults.vdw_interlocking)
    // Independent overlay outline: vdw_outline_width / vdw_outline_color
    // fall back to atom_stroke_width / atom_stroke_color when None
    // (renderer.py:1782-1785).
    let vdw-ow-raw = config.at("vdw_outline_width", default: defaults.vdw_outline_width)
    let vdw-ow = if vdw-ow-raw == none {
      float(config.at("atom_stroke_width", default: defaults.atom_stroke_width))
    } else {
      float(vdw-ow-raw)
    } * scale-ratio
    let vdw-oc-raw = config.at("vdw_outline_color", default: defaults.vdw_outline_color)
    let vdw-oc = if vdw-oc-raw == none {
      config.at("atom_stroke_color", default: defaults.atom_stroke_color)
    } else {
      vdw-oc-raw
    }

    // Membership LUT and active sorted subset (upstream
    // renderer.py:1774). The subset is filtered to valid indices so
    // out-of-range entries from a future selector layer can't crash
    // the interlock array, and to drop any hidden C-H atoms so the
    // overlay doesn't reveal hydrogens the primary layer is hiding.
    let set-lookup = range(n).map(_ => false)
    for i in vdw-set {
      if 0 <= i and i < n and not hidden-lut.at(i) { set-lookup.at(i) = true }
    }
    let active = range(n).filter(i => set-lookup.at(i)).sorted()

    // Interlocking polygons for the overlay subset. compute-
    // interlock-polygons takes the active centers/radii and returns
    // polys indexed BY POSITION IN THE SUBSET, so we scatter them
    // back into a length-n list keyed by atom index
    // (renderer.py:1777-1780). Polys are in Angstrom-xy and projected
    // here to pixel space, matching the atom_interlocking path.
    let overlay-polys-px = if vdw-interlocking and active.len() > 0 {
      let sub-centers = active.map(i => coords-3d.at(i))
      let sub-radii = active.map(i => raw-vdw-3d.at(i) * vdw-scale-cfg)
      let polys-sub = compute-interlock-polygons(
        sub-centers, sub-radii,
        samples: int(config.at("vdw_interlock_samples", default: defaults.vdw_interlock_samples)),
      )
      let out = range(n).map(_ => none)
      for k in range(active.len()) {
        let ai = active.at(k)
        let poly-ang = polys-sub.at(k)
        if poly-ang != none {
          out.at(ai) = poly-ang.map(p => project(
            (p.at(0), p.at(1), 0.0), scale, center, canvas-w, canvas-h,
          ))
        }
      }
      out
    } else {
      range(n).map(_ => none)
    }

    let emit-vdw(ai) = {
      let elem = data.elements.at(ai)
      let base = element-color(elem, config)
      let lo = darken-hex(
        base,
        strength: vdw-grad-strength,
        hue-shift: float(config.at("hue_shift_factor", default: defaults.hue_shift_factor)),
        light-shift: float(config.at("light_shift_factor", default: defaults.light_shift_factor)),
        sat-shift: float(config.at("saturation_shift_factor", default: defaults.saturation_shift_factor)),
      )
      let (xi, yi) = coords-2d.at(ai)
      let vr = raw-vdw-3d.at(ai) * vdw-scale-cfg * scale
      // Inline user-space radial gradient anchored at the sphere
      // centre (renderer.py:1805). Two stops: base at the
      // highlight, darkened at the rim.
      let gid = id-prefix + "-vgi" + str(ai)
      let grad-def = _sphere-grad-def(gid, xi, yi, vr, (("0%", base), ("100%", lo)))
      // Stroke: "atom" sentinel means the per-atom element colour;
      // anything else is a literal hex (renderer.py:1792).
      let stroke-col = if vdw-oc == "atom" { base } else { resolve-color(vdw-oc) }
      let poly = overlay-polys-px.at(ai)
      let shape = if poly != none {
        _polygon(poly, "url(#" + gid + ")", stroke-col, vdw-ow)
      } else {
        _circle(xi, yi, vr, "url(#" + gid + ")", stroke-col, vdw-ow)
      }
      grad-def + shape
    }

    let overlay-parts = ()
    overlay-parts.push("<g opacity=\"" + fnum(vdw-opacity) + "\">")
    // Painter order = molecule's z-order, restricted to the active
    // subset (renderer.py:1787-1815).
    for ai in z-order {
      if set-lookup.at(ai) {
        overlay-parts.push(emit-vdw(ai))
      }
    }
    overlay-parts.push("</g>")
    join-svg(overlay-parts)
  }

  // 8. Assemble. Back-layer bond outlines go below the molecule body
  //    so non-interleaved joints stay hidden by their own fills.
  let parts = (
    _svg-open(canvas-w, canvas-h),
    "<defs>", _emit-defs(data, config, fog-fs, fog-col, use-per-atom-grad, id-prefix), "</defs>",
    _emit-background(canvas-w, canvas-h, config),
    join-svg(bond-outline-layer),
    join-svg(body-parts),
    vdw-overlay,
    "</svg>",
  )
  join-svg(parts)
}
