// Typst SMILES Package
// Renders SMILES strings as 2D molecular structure diagrams via a WASM plugin.
// Also re-exports `ce` from chemformula for chemical formula notation.

#import "@preview/cetz:0.5.2"
#import "@preview/chemformula:0.1.3": ch

#let smiles-plugin = plugin("../plugin/typst_smiles_plugin.wasm")

// Re-export as ce so users only need one import line.
// chemformula uses math mode internally, giving proper operator spacing.
#let ce(chem, font: none, font-size: none, ..args) = {
  if font == none and font-size == none {
    ch(chem, ..args)
  } else if font == none {
    [
      #show math.equation: set text(size: font-size)
      #ch(chem, ..args)
    ]
  } else if font-size == none {
    [
      #show math.equation: set text(font: font)
      #ch(chem, ..args)
    ]
  } else {
    [
      #show math.equation: set text(font: font, size: font-size)
      #ch(chem, ..args)
    ]
  }
}

// ── Internal helpers ──────────────────────────────────────────────────────────

#let _is-carbon(atom) = atom.symbol == "C" or atom.symbol == "c"

#let _visible-implicit-h(atom, show-all-h: false) = {
  let count = atom.at("implicit_h", default: 0)
  if count == 0 {
    0
  } else if show-all-h {
    count
  } else if not _is-carbon(atom) and atom.symbol != "*" {
    count
  } else {
    0
  }
}

#let _has-label(atom, show-all-h: false) = {
  let has-abbrev = atom.at("abbrev", default: "") != ""
  let has-hetero = (not _is-carbon(atom) and atom.symbol != "*") or (atom.charge != 0)
  let has-explicit-h = atom.hcount > 0 and (show-all-h or not _is-carbon(atom))
  let has-implicit-h = _visible-implicit-h(
    atom,
    show-all-h: show-all-h,
  ) > 0
  has-abbrev or has-hetero or has-explicit-h or has-implicit-h
}

#let _atom-color(sym) = {
  if sym == "N" or sym == "n"      { rgb("#3050F8") }
  else if sym == "O" or sym == "o" { rgb("#FF0D0D") }
  else if sym == "S" or sym == "s" { rgb("#E6C800") }
  else if sym == "P"               { rgb("#FF8000") }
  else if sym == "F"               { rgb("#90E050") }
  else if sym == "Cl"              { rgb("#1FF01F") }
  else if sym == "Br"              { rgb("#A62929") }
  else if sym == "I"               { rgb("#940094") }
  else { black }
}

#let _label-color(style) = {
  if style == ""                             { black }
  else if style.starts-with("#")            { rgb(style) }
  else if style == "red"                    { rgb("#FF0D0D") }
  else if style == "blue"                   { rgb("#3050F8") }
  else if style == "green"                  { rgb("#1FA51F") }
  else if style == "black"                  { black }
  else if style == "gray" or style == "grey"{ rgb("#777777") }
  else if style == "silver"                 { rgb("#C0C0C0") }
  else if style == "white"                  { white }
  else if style == "orange"                 { rgb("#FF8000") }
  else if style == "yellow"                 { rgb("#E6C800") }
  else if style == "brown"                  { rgb("#8B4513") }
  else if style == "pink"                   { rgb("#FF69B4") }
  else if style == "purple"                 { rgb("#940094") }
  else if style == "cyan"                   { rgb("#00B4D8") }
  else if style == "lime"                   { rgb("#32CD32") }
  else if style == "teal"                   { rgb("#008080") }
  else if style == "maroon"                 { rgb("#800000") }
  else if style == "navy"                   { rgb("#000080") }
  else { _atom-color(style) }
}

// ── SMILES renderer ───────────────────────────────────────────────────────────

/// Renders a SMILES string as a 2D skeletal molecular diagram.
///
/// - smiles-str (str): A valid SMILES string, e.g. "C1=CC=CC=C1" for benzene.
///   Use Kekulé notation for aromatic rings (C not c) until aromatic support lands.
/// - scale (float): Balanced scale for bond length, atom labels, and bond stroke.
///   Explicit bond-length, font-size, or bond-stroke values override it.
///   Default: 1.0.
/// - bond-length (float): Bond length scale factor; 1.0 = 30 pt per bond.
/// - font-size (length): Font size for atom labels.
/// - font (str): Font for atom labels. Default: "New Computer Modern".
/// - bond-stroke (length): Bond stroke width.
/// - color (bool): Apply Jmol CPK atom colors. Default: true.
/// - rotation (angle): Rotate the molecule by this angle. Atom labels stay upright.
///   Example: rotation: 90deg. Default: 0deg.
/// - show-all-h (bool): Show computed implicit hydrogens on all atoms,
///   including carbon. Default: false.
/// - atom-colors (dictionary): Color overrides that take priority over both the
///   default CPK palette and any `{label|style}` inline style. Two key forms:
///   - Element symbol key (e.g. `O: rgb("#8B4513")`) — overrides that element
///     everywhere, including when used as an inline style (`{label|O}`).
///   - Brace-quoted label key (e.g. `"{PPh3}": purple`) — overrides the color
///     of any abbreviated group whose label text matches, regardless of what
///     style (if any) was written inline.
///   Both forms can appear in the same dictionary.
///   To set defaults project-wide use `#let smiles = smiles.with(atom-colors: (…))`.
/// -> content
#let smiles(
  smiles-str,
  scale: 1.0,
  bond-length: none,
  font-size: none,
  font: "New Computer Modern",
  bond-stroke: none,
  color: true,
  rotation: 0deg,
  show-all-h: false,
  atom-colors: (:),
) = {
  let raw-bytes = smiles-plugin.layout(bytes(smiles-str))
  let layout = json(raw-bytes)

  let actual-bond-length = if bond-length == none { scale } else { bond-length }
  let actual-font-size = if font-size == none { 11pt * scale } else { font-size }
  let actual-bond-stroke = if bond-stroke == none { 0.9pt * scale } else { bond-stroke }
  let canvas-scale = actual-bond-length * 30pt
  let stroke-units = actual-bond-stroke / canvas-scale

  let label-margin    = calc.max(0.27, actual-font-size / canvas-scale * 0.70)
  let double-gap      = calc.max(0.065, stroke-units * 2.30)
  let ring-double-gap = calc.max(0.09, stroke-units * 3.00)
  let junction-overlap = calc.min(0.006, calc.max(0.00875, stroke-units * 0.49))
  let inner-trim      = 0.07
  let multiple-bond-trim = 0.10
  let stroke-w        = actual-bond-stroke
  let subscript-size  = actual-font-size * 0.62
  let superscript-size = actual-font-size * 0.62

  let atom-clr = if color {
    (sym) => { if sym in atom-colors { atom-colors.at(sym) } else { _atom-color(sym) } }
  } else { (sym) => black }
  let label-clr = if color {
    (style) => { if style in atom-colors { atom-colors.at(style) } else { _label-color(style) } }
  } else { (style) => black }
  let display-clr(atom) = {
    let abbrev = atom.at("abbrev", default: "")
    let abbrev-style = atom.at("abbrev_style", default: "")
    if abbrev != "" {
      let label-key = "{" + abbrev + "}"
      if color and label-key in atom-colors { atom-colors.at(label-key) }
      else { label-clr(abbrev-style) }
    } else {
      atom-clr(atom.symbol)
    }
  }
  let atom-label(body, fill: black, size: actual-font-size) = text(
    size: size,
    font: font,
    style: "normal",
    weight: "regular",
    fill: fill,
    body,
  )

  let cos-a = calc.cos(rotation)
  let sin-a = calc.sin(rotation)
  let rx(x, y) = x * cos-a - y * sin-a
  let ry(x, y) = x * sin-a + y * cos-a

  cetz.canvas(length: canvas-scale, {
    import cetz.draw: *

    let atom-degree(i) = layout.bonds.filter(b => b.from == i or b.to == i).len()
    let atom-neighbor-indices(i) = {
      let indices = ()
      for b in layout.bonds {
        if b.from == i {
          indices.push(b.to)
        } else if b.to == i {
          indices.push(b.from)
        }
      }
      indices
    }
    let force-linear-carbon-label(i) = {
      let atom = layout.atoms.at(i)
      if not _is-carbon(atom) or atom.at("abbrev", default: "") != "" or atom-degree(i) != 2 {
        false
      } else {
        let bonds = layout.bonds.filter(b => b.from == i or b.to == i)
        let double-count = bonds.filter(b => b.order == 2).len()
        let has-carbon-neighbor = atom-neighbor-indices(i).any(ni => _is-carbon(layout.atoms.at(ni)))
        double-count == 2 and not has-carbon-neighbor
      }
    }
    let has-label(i) = {
      let atom = layout.atoms.at(i)
      _has-label(atom, show-all-h: show-all-h) or force-linear-carbon-label(i)
    }
    let first-neighbor(i) = {
      let result = none
      for b in layout.bonds {
        if result == none and (b.from == i or b.to == i) {
          result = if b.from == i { b.to } else { b.from }
        }
      }
      result
    }
    let visible-h-count(atom) = {
      let count = atom.hcount + _visible-implicit-h(atom, show-all-h: show-all-h)
      if atom.at("stereo_h", default: "none") != "none" {
        calc.max(0, count - 1)
      } else {
        count
      }
    }
    let label-trim(atom, i) = {
      if not has-label(i) {
        0.0
      } else if visible-h-count(atom) > 0 and atom-degree(i) == 1 and not _is-carbon(atom) {
        0.06
      } else {
        label-margin
      }
    }

    for bond in layout.bonds {
      let af = layout.atoms.at(bond.from)
      let at = layout.atoms.at(bond.to)
      let p1x = rx(af.pos.x, af.pos.y)
      let p1y = ry(af.pos.x, af.pos.y)
      let p2x = rx(at.pos.x, at.pos.y)
      let p2y = ry(at.pos.x, at.pos.y)
      let c1 = display-clr(af)
      let c2 = display-clr(at)

      let dx = p2x - p1x
      let dy = p2y - p1y
      let len = calc.sqrt(dx * dx + dy * dy)
      let ux = if len > 0.001 { dx / len } else { 1.0 }
      let uy = if len > 0.001 { dy / len } else { 0.0 }

      let af-has-label = has-label(bond.from)
      let at-has-label = has-label(bond.to)
      let s1 = label-trim(af, bond.from)
      let s2 = label-trim(at, bond.to)
      let e1 = if not af-has-label and atom-degree(bond.from) > 1 { junction-overlap } else { 0.0 }
      let e2 = if not at-has-label and atom-degree(bond.to) > 1 { junction-overlap } else { 0.0 }
      let q1x = p1x + ux * s1 - ux * e1
      let q1y = p1y + uy * s1 - uy * e1
      let q2x = p2x - ux * s2 + ux * e2
      let q2y = p2y - uy * s2 + uy * e2
      let mx = (q1x + q2x) / 2
      let my = (q1y + q2y) / 2

      let stereo = bond.at("stereo", default: "none")
      let split-line(x1, y1, x2, y2, from-color, to-color) = {
        let xmid = (x1 + x2) / 2
        let ymid = (y1 + y2) / 2
        line((x1, y1), (xmid, ymid), stroke: stroke-w + from-color)
        line((xmid, ymid), (x2, y2), stroke: stroke-w + to-color)
      }
      let offset-side(atom-idx, other-idx, px, py) = {
        let side = 1.0
        for b in layout.bonds {
          if (b.from == atom-idx or b.to == atom-idx) and not (b.from == other-idx or b.to == other-idx) {
            let ni = if b.from == atom-idx { b.to } else { b.from }
            let na = layout.atoms.at(ni)
            let vx = rx(na.pos.x, na.pos.y) - px
            let vy = ry(na.pos.x, na.pos.y) - py
            side = if vx * (-uy) + vy * ux >= 0.0 { 1.0 } else { -1.0 }
          }
        }
        side
      }

      // Per IUPAC: narrow tip at stereocenter, wide base at substituent.
      // Heuristic: if exactly one atom is a plain C, the tip goes there;
      // otherwise fall back to the higher-degree atom.
      let af-abbr = af.at("abbrev", default: "") != ""
      let at-abbr = at.at("abbrev", default: "") != ""
      let af-is-c = (af.symbol == "C" or af.symbol == "c") and not af-abbr
      let at-is-c = (at.symbol == "C" or at.symbol == "c") and not at-abbr
      let tip-at-from = if af-is-c and not at-is-c { true }
                        else if at-is-c and not af-is-c { false }
                        else {
                          let df = atom-degree(bond.from)
                          let dt = atom-degree(bond.to)
                          df >= dt
                        }

      if stereo == "wedge_up" {
        let half-w = 0.10
        let ox = -uy * half-w
        let oy =  ux * half-w
        // Bicolor the wedge at its midpoint, like a plain bond.
        let (tx, ty, bx, by, tip-c, base-c) = if tip-at-from {
          (q1x, q1y, q2x, q2y, c1, c2)
        } else {
          (q2x, q2y, q1x, q1y, c2, c1)
        }
        let mx2 = (tx + bx) / 2
        let my2 = (ty + by) / 2
        line(
          (tx, ty), (mx2 + ox / 2, my2 + oy / 2), (mx2 - ox / 2, my2 - oy / 2),
          close: true, fill: tip-c, stroke: none,
        )
        line(
          (mx2 + ox / 2, my2 + oy / 2), (bx + ox, by + oy),
          (bx - ox, by - oy), (mx2 - ox / 2, my2 - oy / 2),
          close: true, fill: base-c, stroke: none,
        )

      } else if stereo == "wedge_down" {
        // Hashed wedge: perpendicular lines widening from tip to base.
        let n-lines = 7
        let half-w = 0.10
        let (sx, sy, ex, ey, near-c, far-c) = if tip-at-from {
          (q1x, q1y, q2x, q2y, c1, c2)
        } else {
          (q2x, q2y, q1x, q1y, c2, c1)
        }
        for i in range(n-lines) {
          let t = (i + 1) / (n-lines + 1)
          let cx = sx + (ex - sx) * t
          let cy = sy + (ey - sy) * t
          let w  = half-w * t
          let ox = -uy * w
          let oy =  ux * w
          let c  = if t < 0.5 { near-c } else { far-c }
          line((cx - ox, cy - oy), (cx + ox, cy + oy), stroke: stroke-w + c)
        }

      } else if bond.order == 1 {
        line((q1x, q1y), (mx, my),   stroke: stroke-w + c1)
        line((mx, my),   (q2x, q2y), stroke: stroke-w + c2)

      } else if bond.order == 2 {
        let is-ring-bond = bond.inner_x != 0.0 or bond.inner_y != 0.0

        if is-ring-bond {
          split-line(q1x, q1y, q2x, q2y, c1, c2)
          let ix  = rx(bond.inner_x, bond.inner_y) * ring-double-gap
          let iy  = ry(bond.inner_x, bond.inner_y) * ring-double-gap
          let lx1 = q1x + ux * inner-trim + ix
          let ly1 = q1y + uy * inner-trim + iy
          let lx2 = q2x - ux * inner-trim + ix
          let ly2 = q2y - uy * inner-trim + iy
          split-line(lx1, ly1, lx2, ly2, c1, c2)
        } else {
          let deg-f = atom-degree(bond.from)
          let deg-t = atom-degree(bond.to)
          let has-hidden-simple-continuation = (deg-f == 2 and not af-has-label) or (deg-t == 2 and not at-has-label)
          let has-real-junction = deg-f > 2 or deg-t > 2

          if has-hidden-simple-continuation and not has-real-junction {
            split-line(q1x, q1y, q2x, q2y, c1, c2)

            let side = if deg-f == 2 and not af-has-label {
              offset-side(bond.from, bond.to, q1x, q1y)
            } else {
              offset-side(bond.to, bond.from, q2x, q2y)
            }
            let trim = calc.min(multiple-bond-trim, len * 0.25)
            let simple-double-gap = double-gap * 1.12
            let ox = -uy * simple-double-gap * side
            let oy =  ux * simple-double-gap * side
            let lx1 = q1x + ux * (if deg-f == 2 and not af-has-label { trim } else { 0.0 }) + ox
            let ly1 = q1y + uy * (if deg-f == 2 and not af-has-label { trim } else { 0.0 }) + oy
            let lx2 = q2x - ux * (if deg-t == 2 and not at-has-label { trim } else { 0.0 }) + ox
            let ly2 = q2y - uy * (if deg-t == 2 and not at-has-label { trim } else { 0.0 }) + oy
            split-line(lx1, ly1, lx2, ly2, c1, c2)
          } else {
            // At real junctions (3+ bonds) extend slightly to close corner gap.
            let ext = 0.04
            let ox = -uy * double-gap
            let oy =  ux * double-gap
            let e1x = q1x - ux * (if deg-f > 2 { ext } else { 0.0 })
            let e1y = q1y - uy * (if deg-f > 2 { ext } else { 0.0 })
            let e2x = q2x + ux * (if deg-t > 2 { ext } else { 0.0 })
            let e2y = q2y + uy * (if deg-t > 2 { ext } else { 0.0 })
            split-line(e1x + ox, e1y + oy, e2x + ox, e2y + oy, c1, c2)
            split-line(e1x - ox, e1y - oy, e2x - ox, e2y - oy, c1, c2)
          }
        }

      } else if bond.order == 3 {
        let ox = -uy * double-gap * 1.3
        let oy =  ux * double-gap * 1.3
        let trim = calc.min(multiple-bond-trim, len * 0.25)
        split-line(q1x, q1y, q2x, q2y, c1, c2)
        split-line(q1x + ux * trim + ox, q1y + uy * trim + oy, q2x - ux * trim + ox, q2y - uy * trim + oy, c1, c2)
        split-line(q1x + ux * trim - ox, q1y + uy * trim - oy, q2x - ux * trim - ox, q2y - uy * trim - oy, c1, c2)

      } else if bond.order == 4 {
        split-line(q1x, q1y, q2x, q2y, c1, c2)
        let ox = -uy * double-gap
        let oy =  ux * double-gap
        line(
          (q1x + ox, q1y + oy), (mx + ox, my + oy),
          stroke: (paint: c1, thickness: stroke-w, dash: "dashed"),
        )
        line(
          (mx + ox, my + oy), (q2x + ox, q2y + oy),
          stroke: (paint: c2, thickness: stroke-w, dash: "dashed"),
        )
      }
    }

    // Stereochemical hydrogens are drawn as explicit H labels only when they
    // carry wedge/hash information from a bracket stereocenter.
    for i in range(layout.atoms.len()) {
      let atom = layout.atoms.at(i)
      let stereo = atom.at("stereo_h", default: "none")
      if stereo != "none" {
        let px = rx(atom.pos.x, atom.pos.y)
        let py = ry(atom.pos.x, atom.pos.y)
        let dir = atom.at("stereo_h_dir", default: (x: 0.0, y: -1.0))
        let ux = rx(dir.x, dir.y)
        let uy = ry(dir.x, dir.y)
        let bond-end-x = px + ux * 0.62
        let bond-end-y = py + uy * 0.62
        let label-x = px + ux * 0.82
        let label-y = py + uy * 0.82
        let h-fill = atom-clr("H")

        if stereo == "wedge_up" {
          let half-w = 0.085
          let ox = -uy * half-w
          let oy = ux * half-w
          line(
            (px, py), (bond-end-x + ox, bond-end-y + oy), (bond-end-x - ox, bond-end-y - oy),
            close: true, fill: h-fill, stroke: none,
          )
        } else if stereo == "wedge_down" {
          let n-lines = 7
          let half-w = 0.085
          for j in range(n-lines) {
            let t = (j + 1) / (n-lines + 1)
            let cx = px + (bond-end-x - px) * t
            let cy = py + (bond-end-y - py) * t
            let w = half-w * t
            let ox = -uy * w
            let oy = ux * w
            line((cx - ox, cy - oy), (cx + ox, cy + oy), stroke: stroke-w + h-fill)
          }
        }

        content(
          (label-x, label-y),
          atom-label("H", fill: h-fill),
          anchor: "center",
          padding: 1pt,
        )
      }
    }

    // Atom labels — heteroatoms, charged atoms, and literal groups.
    // Positions are rotated; text content stays upright.
    for i in range(layout.atoms.len()) {
      let atom = layout.atoms.at(i)
      if has-label(i) {
        let abbrev = atom.at("abbrev", default: "")
        let fill = display-clr(atom)
        let px = rx(atom.pos.x, atom.pos.y)
        let py = ry(atom.pos.x, atom.pos.y)
        let deg = atom-degree(i)
        let h-count = visible-h-count(atom)

        let charge-str = if atom.charge == 1        { "+" }
                         else if atom.charge == -1  { "\u{2212}" }
                         else if atom.charge > 1    { str(atom.charge) + "+" }
                         else if atom.charge < -1   { str(-atom.charge) + "\u{2212}" }
                         else                       { "" }
        // A small gap before the superscript so the sign sits to the right of a
        // preceding subscript (e.g. the "3" in NH3+) instead of reading as that
        // digit's exponent.
        let charge-content = if charge-str == "" {
          []
        } else {
          h(0.12em) + super(atom-label(charge-str, fill: fill, size: superscript-size))
        }

        let sym-text = atom-label(atom.symbol, fill: fill)
        let h-text = if abbrev != "" or h-count == 0 or (_is-carbon(atom) and not show-all-h) {
          []
        } else if h-count == 1 {
          atom-label("H", fill: fill)
        } else {
          atom-label("H", fill: fill) + sub(atom-label(
            str(h-count),
            fill: fill,
            size: subscript-size,
          ))
        }

        // Terminal heteroatom with an inline H (e.g. -OH, -NH₂): center the heavy
        // symbol on the bond terminus and hang the H off to one side, so the bond
        // always meets the heteroatom and never the trailing H at any angle.
        let hetero-inline = abbrev == "" and h-text != [] and deg == 1 and not _is-carbon(atom)

        if hetero-inline {
          let ni = first-neighbor(i)
          let nb = layout.atoms.at(ni)
          let dx = rx(nb.pos.x, nb.pos.y) - px
          let dy = ry(nb.pos.x, nb.pos.y) - py
          // Anchor the symbol's bond-facing edge at the atom; the H hangs off the
          // opposite side. Pad only the bond-facing edge so the pair stays tight.
          let pad-bond = 1pt
          let (sym-anchor, sym-pad, h-at, h-self) = if calc.abs(dx) >= calc.abs(dy) {
            if dx > 0 {
              ("east", (right: pad-bond), "west", "east")
            } else {
              ("west", (left: pad-bond), "east", "west")
            }
          } else if dy > 0 {
            // No vertical padding: it would skew the top anchor and lift the H
            // out of line with the symbol. The bond trim supplies the gap.
            ("north", 0pt, "east", "west")
          } else {
            ("south", 0pt, "east", "west")
          }
          // Keep the charge on the rightmost element so it reads as the group
          // charge: with the symbol when the H sits to its left, else with the H.
          let sym-content = if h-at == "west" { sym-text + charge-content } else { sym-text }
          let h-content = if h-at == "west" { h-text } else { h-text + charge-content }
          let sname = "atom-" + str(i)
          content((px, py), sym-content, anchor: sym-anchor, padding: sym-pad, name: sname)
          // Attach the H at the symbol's top corner so their baselines align.
          content(
            sname + ".north-" + h-at,
            h-content,
            anchor: "north-" + h-self,
            padding: 0pt,
          )
        } else {
          let draw-h-above = false
          let h-above-content = []
          let label-content = if abbrev != "" {
            atom-label(abbrev, fill: fill)
          } else {
            let reverse-inline = if h-text == [] or deg != 1 {
              false
            } else {
              let ni = first-neighbor(i)
              if ni == none {
                false
              } else {
                let neighbor = layout.atoms.at(ni)
                let vx = rx(neighbor.pos.x, neighbor.pos.y) - px
                vx > 0.05
              }
            }
            let stacked-h = h-text != [] and deg >= 2 and not _is-carbon(atom)
            let base-text = if stacked-h {
              draw-h-above = true
              h-above-content = h-text
              sym-text
            } else if reverse-inline {
              h-text + sym-text
            } else {
              sym-text + h-text
            }
            base-text + charge-content
          }

          if draw-h-above {
            content(
              (px, py + label-margin * 0.95),
              h-above-content,
              anchor: "center",
              padding: 1pt,
            )
          }

          content((px, py), label-content, anchor: "center", padding: 1pt)
        }
      }
    }
  })
}

// Capture before `reaction` shadows the name with its own `scale` parameter.
#let _typst-scale = scale

// ── Reaction scheme helpers ───────────────────────────────────────────────────

/// Creates a reaction arrow for use inside #reaction().
///
/// - above (content): Label above a horizontal arrow / to the right of a vertical one.
/// - below (content): Label below a horizontal arrow / to the left of a vertical one.
/// - dir (str): Arrow direction — "right" (default), "left", "down", or "up".
/// -> dictionary  (consumed by #reaction)
#let rxn-arrow(above: none, below: none, dir: "right") = (
  __rxn_arrow__: true,
  above: above,
  below: below,
  dir: dir,
)

// Render a horizontal arrow (→ or ←)
#let _horiz-arrow(above, below, dir) = {
  let arrow-parts = ()
  if above != none { arrow-parts.push(align(center, text(size: 8pt, above))) }
  let (sx, ex) = if dir == "left" { (52, 0) } else { (0, 52) }
  arrow-parts.push(cetz.canvas(length: 1pt, {
    import cetz.draw: *
    line((sx, 0), (ex, 0), mark: (end: ">", fill: black, size: 5), stroke: 0.8pt + black)
  }))
  if below != none { arrow-parts.push(align(center, text(size: 8pt, below))) }
  align(center + horizon, stack(spacing: 3pt, ..arrow-parts))
}

// Render a vertical arrow (↓ or ↑). `above` is shown to the right, `below` to the left.
#let _vert-arrow(above, below, dir) = {
  let (from-y, to-y) = if dir == "up" { (0, 52) } else { (52, 0) }
  let arrow-canvas = cetz.canvas(length: 1pt, {
    import cetz.draw: *
    line((0, from-y), (0, to-y), mark: (end: ">", fill: black, size: 5), stroke: 0.8pt + black)
  })
  if above == none and below == none {
    align(center + horizon, arrow-canvas)
  } else {
    grid(
      columns: (auto, auto, auto),
      column-gutter: 4pt,
      align: center + horizon,
      if below != none { text(size: 8pt, below) } else { [] },
      arrow-canvas,
      if above != none { text(size: 8pt, above) } else { [] },
    )
  }
}

/// Wraps any content with an optional centred label below it.
///
/// - content (content): The molecule or formula to display.
/// - label (content): Optional label shown below. Default: none.
/// -> content
#let mol(content, label: none) = {
  if label == none { content }
  else { stack(spacing: 4pt, content, align(center, label)) }
}

/// Lays out a reaction scheme supporting multi-directional arrows.
///
/// Items are any mix of content (smiles(), ce(), text…) and rxn-arrow()
/// dictionaries.  rxn-arrow() accepts dir: "right"|"left"|"down"|"up" so
/// schemes can wrap across the page.
///
/// - gap-h (length): Gap between items in horizontal direction. Default: 1.5em.
/// - gap-v (length): Gap between items in vertical direction. Default: 1.5em.
/// - scale (float): Uniform scale applied to the entire scheme — molecules,
///   arrows, labels, and plus signs all scale together. 1.0 = no scaling.
/// - breakable (bool): Whether the scheme may be split across pages.
///   Default: false (the whole block moves to the next page as a unit).
/// -> content
#let reaction(gap-h: 1.5em, gap-v: 1.5em, scale: 1.0, breakable: false, ..items) = {
  let steps = items.pos()

  // ── Phase 1: assign each item a (grid-row, grid-col) position ────────────
  // Logical positions: molecules at (lr, lc), arrows in between.
  // Grid mapping: mol at (lr,lc) → grid (2*lr, 2*lc)
  //   horizontal arrow after (lr,lc) going right → grid (2*lr, 2*lc+1)
  //   horizontal arrow after (lr,lc) going left  → grid (2*lr, 2*lc-1)
  //   vertical   arrow after (lr,lc) going down  → grid (2*lr+1, 2*lc)
  //   vertical   arrow after (lr,lc) going up    → grid (2*lr-1, 2*lc)

  let lr = 0
  let lc = 0
  let placed = ()

  for item in steps {
    if type(item) == dictionary and item.at("__rxn_arrow__", default: false) {
      let dir = item.at("dir", default: "right")
      // Each non-arrow item increments lc, so arrows slot into the gap
      // just before the current lc position:
      //   right → gap at 2*lc-1 (between prev mol and next mol)
      //   left  → gap at 2*lc-3 (going backward two slots)
      //   down/up → gap at row ±1, same col as last mol (2*lc-2)
      let (gr, gc) = if dir == "right"     { (2 * lr,     2 * lc - 1) }
                     else if dir == "left"  { (2 * lr,     2 * lc - 3) }
                     else if dir == "down"  { (2 * lr + 1, 2 * lc - 2) }
                     else                   { (2 * lr - 1, 2 * lc - 2) }
      placed.push((gr: gr, gc: gc, kind: "arrow", data: item))
      if dir == "left"      { lc -= 2 }
      else if dir == "down" { lr += 1; lc -= 1 }
      else if dir == "up"   { lr -= 1; lc -= 1 }
      // right: lc unchanged — next mol lands exactly at 2*lc
    } else {
      placed.push((gr: 2 * lr, gc: 2 * lc, kind: "mol", data: item))
      lc += 1
    }
  }

  // ── Phase 2: normalise to 0-based ────────────────────────────────────────
  if placed.len() == 0 { return [] }

  let min-gr = placed.fold(placed.first().gr, (m, c) => calc.min(m, c.gr))
  let min-gc = placed.fold(placed.first().gc, (m, c) => calc.min(m, c.gc))
  let max-gr = placed.fold(placed.first().gr, (m, c) => calc.max(m, c.gr))
  let max-gc = placed.fold(placed.first().gc, (m, c) => calc.max(m, c.gc))

  let n-rows = max-gr - min-gr + 1
  let n-cols = max-gc - min-gc + 1

  // ── Phase 3: build sparse lookup ─────────────────────────────────────────
  let lookup = (:)
  for p in placed {
    let key = str(p.gr - min-gr) + "," + str(p.gc - min-gc)
    lookup.insert(key, p)
  }

  // ── Phase 4: render as Typst grid ────────────────────────────────────────
  let flat-cells = ()
  for gr in range(n-rows) {
    for gc in range(n-cols) {
      let key = str(gr) + "," + str(gc)
      let p = lookup.at(key, default: none)
      if p == none {
        flat-cells.push([])
      } else if p.kind == "mol" {
        flat-cells.push(align(center + horizon, p.data))
      } else {
        let item = p.data
        let d = item.at("dir", default: "right")
        flat-cells.push(
          if d == "right" or d == "left" { _horiz-arrow(item.above, item.below, d) }
          else                           { _vert-arrow(item.above, item.below, d) }
        )
      }
    }
  }

  let result = grid(
    columns: (auto,) * n-cols,
    rows:    (auto,) * n-rows,
    column-gutter: gap-h / 2,
    row-gutter:    gap-v / 2,
    align: center + horizon,
    ..flat-cells,
  )

  let scaled = if scale == 1.0 {
    result
  } else {
    _typst-scale(x: scale * 100%, y: scale * 100%, reflow: true, result)
  }

  block(breakable: breakable, scaled)
}
