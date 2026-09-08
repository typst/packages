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

#let _visible-implicit-h(atom, show-all-h: false, force: false) = {
  let count = atom.at("implicit_h", default: 0)
  if count == 0 {
    0
  } else if show-all-h or force {
    count
  } else if not _is-carbon(atom) and atom.symbol != "*" {
    count
  } else {
    0
  }
}

#let _has-label(atom, show-all-h: false, force: false) = {
  let has-abbrev = atom.at("abbrev", default: "") != ""
  let has-hetero = (not _is-carbon(atom) and atom.symbol != "*") or (atom.charge != 0)
  let has-isotope = atom.at("isotope", default: 0) > 0
  let has-explicit-h = atom.hcount > 0 and (show-all-h or force or not _is-carbon(atom))
  let has-implicit-h = _visible-implicit-h(
    atom,
    show-all-h: show-all-h,
    force: force,
  ) > 0
  has-abbrev or has-hetero or has-isotope or has-explicit-h or has-implicit-h
}

#let _normalize-show-h(show-h) = {
  if show-h == "all" {
    (all: true, indices: ())
  } else if type(show-h) == array {
    (all: false, indices: show-h)
  } else if type(show-h) == int {
    (all: false, indices: (show-h,))
  } else {
    panic("show-h must be \"all\", an atom index, or an array of atom indices")
  }
}

#let _normalize-atom-annotations(atom-annotations) = {
  if type(atom-annotations) != array {
    panic("atom-annotations must be an array of (index, content) or (index, content, offset) tuples")
  }

  let out = ()
  for entry in atom-annotations {
    if type(entry) != array or (entry.len() != 2 and entry.len() != 3) {
      panic("atom-annotations entries must be (index, content) or (index, content, offset)")
    }
    if type(entry.at(0)) != int {
      panic("atom-annotations index must be an integer")
    }
    out.push((
      index: entry.at(0),
      body: entry.at(1),
      offset: if entry.len() == 3 { entry.at(2) } else { (0, 0) },
    ))
  }
  out
}

// An opacity value is a ratio (40%) or a number in 0..1; both normalize to a
// ratio so color.transparentize can consume it.
#let _opacity-ratio(opacity, what) = {
  if type(opacity) == ratio {
    opacity
  } else if type(opacity) == int or type(opacity) == float {
    opacity * 100%
  } else {
    panic(what + " must be a ratio (e.g. 40%) or a number between 0 and 1")
  }
}

// Per-bond style overrides: a list of (bond(i, j), (..options..)) pairs, with
// a plain (i, j) array accepted in place of the bond() reference. Normalizes
// to a dictionary keyed by the sorted atom-index pair.
#let _normalize-bond-customizations(bond-customizations) = {
  if type(bond-customizations) != array {
    panic("bond-customizations must be an array of (bond(i, j), (..options..)) pairs")
  }
  let out = (:)
  for entry in bond-customizations {
    if type(entry) != array or entry.len() != 2 {
      panic("bond-customizations entries must be (bond(i, j), (..options..)) pairs")
    }
    let (ref, opts) = (entry.at(0), entry.at(1))
    let (i, j) = if type(ref) == dictionary and ref.at("__ref__", default: "") == "bond" {
      (ref.i, ref.j)
    } else if type(ref) == array and ref.len() == 2 {
      (ref.at(0), ref.at(1))
    } else {
      panic("bond-customizations bonds must be bond(i, j) references or (i, j) pairs")
    }
    if type(opts) != dictionary {
      panic("bond-customizations options must be a dictionary")
    }
    for k in opts.keys() {
      if k not in ("color", "stroke", "opacity") {
        panic("unknown bond customization \"" + k + "\" (expected color, stroke, or opacity)")
      }
    }
    if "color" in opts and type(opts.color) != color {
      panic("bond customization color must be a color")
    }
    if "stroke" in opts and type(opts.stroke) != length {
      panic("bond customization stroke must be a length (the bond width)")
    }
    if "opacity" in opts {
      opts.insert("opacity", _opacity-ratio(opts.opacity, "bond customization opacity"))
    }
    out.insert(str(calc.min(i, j)) + "-" + str(calc.max(i, j)), opts)
  }
  out
}

// CPK hues bright enough to read on either background keep one value; the
// dark theme lifts the lightness of the hues that vanish on dark slides
// (N, Br, I; O slightly) without changing their identity.
#let _atom-color(sym, theme: "light", fg: black) = {
  let dark = theme == "dark"
  if sym == "N" or sym == "n"      { if dark { rgb("#7A8CFF") } else { rgb("#3050F8") } }
  else if sym == "O" or sym == "o" { if dark { rgb("#FF5252") } else { rgb("#FF0D0D") } }
  else if sym == "S" or sym == "s" { rgb("#E6C800") }
  else if sym == "P"               { rgb("#FF8000") }
  else if sym == "F"               { rgb("#90E050") }
  else if sym == "Cl"              { rgb("#1FF01F") }
  else if sym == "Br"              { if dark { rgb("#D07C7C") } else { rgb("#A62929") } }
  else if sym == "I"               { if dark { rgb("#DC7CDC") } else { rgb("#940094") } }
  else { fg }
}

#let _label-color(style, theme: "light", fg: black) = {
  let dark = theme == "dark"
  if style == ""                             { fg }
  else if style.starts-with("#")            { rgb(style) }
  else if style == "red"                    { if dark { rgb("#FF5252") } else { rgb("#FF0D0D") } }
  else if style == "blue"                   { if dark { rgb("#7A8CFF") } else { rgb("#3050F8") } }
  else if style == "green"                  { if dark { rgb("#55C455") } else { rgb("#1FA51F") } }
  else if style == "black"                  { fg }
  else if style == "gray" or style == "grey"{ if dark { rgb("#A6A6A6") } else { rgb("#777777") } }
  else if style == "silver"                 { rgb("#C0C0C0") }
  else if style == "white"                  { white }
  else if style == "orange"                 { rgb("#FF8000") }
  else if style == "yellow"                 { rgb("#E6C800") }
  else if style == "brown"                  { if dark { rgb("#C98F5A") } else { rgb("#8B4513") } }
  else if style == "pink"                   { rgb("#FF69B4") }
  else if style == "purple"                 { if dark { rgb("#DC7CDC") } else { rgb("#940094") } }
  else if style == "cyan"                   { rgb("#00B4D8") }
  else if style == "lime"                   { rgb("#32CD32") }
  else if style == "teal"                   { if dark { rgb("#35BDBD") } else { rgb("#008080") } }
  else if style == "maroon"                 { if dark { rgb("#D06A6A") } else { rgb("#800000") } }
  else if style == "navy"                   { if dark { rgb("#8F9BFF") } else { rgb("#000080") } }
  else { _atom-color(style, theme: theme, fg: fg) }
}

// Resolves the fg/theme pair: an `auto` foreground inherits the surrounding
// text color (so molecules recolor with the slide theme), and an `auto`
// theme picks the dark palette when the foreground is light.
#let _resolve-fg-theme(fg, theme) = {
  let resolved-fg = if fg == auto {
    if type(text.fill) == color { text.fill } else { black }
  } else { fg }
  let resolved-theme = if theme == auto {
    if type(resolved-fg) == color and oklab(resolved-fg).components().at(0) > 60% {
      "dark"
    } else {
      "light"
    }
  } else if theme == "light" or theme == "dark" {
    theme
  } else {
    panic("theme must be auto, \"light\", or \"dark\"")
  }
  (resolved-fg, resolved-theme)
}

// ── SMILES renderer ───────────────────────────────────────────────────────────

// Parse a SMILES string into layout JSON via the WASM plugin.
#let _layout(smiles-str) = json(smiles-plugin.layout(bytes(smiles-str)))

/// Computes the molecular weight of a SMILES string in g/mol, summing IUPAC
/// standard atomic weights over all atoms including implicit and explicit
/// hydrogens. Errors on input whose mass is undefined: wildcard `*` atoms,
/// `{label}` abbreviations, and isotope-labeled atoms.
///
/// - smiles-str (str): A valid SMILES string, e.g. "CCO".
/// -> float
#let mol-weight(smiles-str) = json(smiles-plugin.mol_weight(bytes(smiles-str)))

// CeTZ canvas unit: one bond length is 30 pt at scale 1.
#let _canvas-scale(scale, bond-length) = (
  if bond-length == none { scale } else { bond-length }
) * 30pt

// Journal style presets, approximating the corresponding ChemDraw document
// stylesheets with the journals' published drawing settings: bond length
// (in 30 pt units), atom-label size, line width, and a Helvetica/Arial font
// stack. Journal presets default to monochrome line art; "default" applies
// nothing, so typed-smiles' own look is untouched. Presets only fill in
// arguments the caller left unset.
//
// Sources — ACS 1996: 14.4 pt bonds, 0.6 pt lines, 10 pt labels.
// RSC: 12.2 pt bonds, 0.5 pt lines, 7 pt labels.
// Nature Portfolio: 0.381 cm (10.8 pt) bonds, 0.021 cm (0.6 pt) lines,
// 6 pt labels. Wiley/Angewandte: 6 mm (17 pt) bonds, 3 mm element symbols
// (≈12 pt font); its line width and label size are scaled from the bond
// length, as the guideline only fixes a minimum.
#let _sans-stack = ("Helvetica", "Arial")
#let _style-preset(style) = {
  if style == "default" { none }
  else if style == "acs" {
    (bond-length: 14.4 / 30, font-size: 10pt, bond-stroke: 0.6pt, font: _sans-stack, color: false)
  } else if style == "rsc" {
    (bond-length: 12.2 / 30, font-size: 7pt, bond-stroke: 0.5pt, font: _sans-stack, color: false)
  } else if style == "nature" {
    (bond-length: 10.8 / 30, font-size: 6pt, bond-stroke: 0.6pt, font: _sans-stack, color: false)
  } else if style == "wiley" {
    (bond-length: 17.0 / 30, font-size: 12pt, bond-stroke: 0.7pt, font: _sans-stack, color: false)
  } else {
    panic("style must be \"default\", \"acs\", \"rsc\", \"nature\", or \"wiley\"")
  }
}

// Applies the package's coordinate normalization plus optional page-axis
// reflection. Requested mirror axes are resolved after rotation, so a vertical
// mirror always preserves left/right in the rendered drawing.
#let _mirror-layout(layout, mirror, rotation: 0deg) = {
  if mirror != "horizontal" and mirror != "vertical" {
    if mirror != none {
      panic("mirror must be none, \"horizontal\", or \"vertical\"")
    }
  }
  let cos-a = calc.cos(rotation)
  let sin-a = calc.sin(rotation)
  let matmul(a, b) = (
    xx: a.xx * b.xx + a.xy * b.yx,
    xy: a.xx * b.xy + a.xy * b.yy,
    yx: a.yx * b.xx + a.yy * b.yx,
    yy: a.yx * b.xy + a.yy * b.yy,
  )
  let base = (xx: -1.0, xy: 0.0, yx: 0.0, yy: 1.0)
  let mat = if mirror == none {
    base
  } else {
    let rot = (xx: cos-a, xy: -sin-a, yx: sin-a, yy: cos-a)
    let inv-rot = (xx: cos-a, xy: sin-a, yx: -sin-a, yy: cos-a)
    let screen = if mirror == "horizontal" {
      (xx: -1.0, xy: 0.0, yx: 0.0, yy: 1.0)
    } else {
      (xx: 1.0, xy: 0.0, yx: 0.0, yy: -1.0)
    }
    matmul(matmul(matmul(inv-rot, screen), rot), base)
  }
  if mat.xx == 1.0 and mat.xy == 0.0 and mat.yx == 0.0 and mat.yy == 1.0 { return layout }
  let flip-stereo(s) = {
    if s == "wedge_up" { "wedge_down" }
    else if s == "wedge_down" { "wedge_up" }
    else { s }
  }
  let tr(x, y) = (
    x: mat.xx * x + mat.xy * y,
    y: mat.yx * x + mat.yy * y,
  )
  let flips-handedness = mat.xx * mat.yy - mat.xy * mat.yx < 0.0
  let out = layout
  out.atoms = layout.atoms.map(a => {
    let m = a
    m.pos = tr(a.pos.x, a.pos.y)
    if "lone_pair_dirs" in a {
      m.lone_pair_dirs = a.lone_pair_dirs.map(d => tr(d.x, d.y))
    }
    if "stereo_h_dir" in a {
      m.stereo_h_dir = tr(a.stereo_h_dir.x, a.stereo_h_dir.y)
    }
    if flips-handedness and "stereo_h" in a { m.stereo_h = flip-stereo(a.stereo_h) }
    m
  })
  out.bonds = layout.bonds.map(b => {
    let m = b
    let inner = tr(b.inner_x, b.inner_y)
    m.inner_x = inner.x
    m.inner_y = inner.y
    if flips-handedness { m.stereo = flip-stereo(b.stereo) }
    m
  })
  if "aromatic_rings" in layout {
    out.aromatic_rings = layout.aromatic_rings.map(r => {
      let m = r
      m.center = tr(r.center.x, r.center.y)
      m
    })
  }
  if out.atoms.len() > 0 {
    let min-x = out.atoms.fold(out.atoms.first().pos.x, (m, a) => calc.min(m, a.pos.x))
    let max-x = out.atoms.fold(out.atoms.first().pos.x, (m, a) => calc.max(m, a.pos.x))
    let min-y = out.atoms.fold(out.atoms.first().pos.y, (m, a) => calc.min(m, a.pos.y))
    let max-y = out.atoms.fold(out.atoms.first().pos.y, (m, a) => calc.max(m, a.pos.y))
    out.bbox_width = max-x - min-x
    out.bbox_height = max-y - min-y
  }
  out
}

#let _label-anchor-offset(label, anchor, anchor-len, label-width) = {
  if label == "" or anchor-len == 0 { return 0.0 }
  let prefix = label.slice(0, anchor)
  let glyph = label.slice(anchor, anchor + anchor-len)
  label-width(prefix) + label-width(glyph) / 2 - label-width(label) / 2
}

// Draws a molecule's bonds, atom labels, and lone pairs into the current CeTZ
// canvas, centered at the local origin. The caller sets the canvas unit to
// `_canvas-scale(scale, bond-length)` and may translate before calling. Atom and
// bond references are resolved separately (see `_atom-pos`) with the same
// rotation, so annotations line up exactly with what is drawn here.
#let _draw-molecule(
  layout,
  scale: 1.0,
  bond-length: none,
  font-size: none,
  font: "New Computer Modern",
  bond-stroke: none,
  color: true,
  rotation: 0deg,
  show-h: (),
  lone-pairs: none,
  atom-colors: (:),
  show-indices: false,
  index-prefix: "",
  fg: black,
  theme: "light",
  aromatic: "kekule",
  atom-annotations: (),
  opacity: 100%,
  bond-customizations: (),
) = {
  if lone-pairs != none and lone-pairs != "dots" and lone-pairs != "lines" {
    panic("lone-pairs must be none, \"dots\", or \"lines\"")
  }
  if aromatic != "kekule" and aromatic != "circle" {
    panic("aromatic must be \"kekule\" or \"circle\"")
  }
  let show-h-state = _normalize-show-h(show-h)
  let show-all-h = show-h-state.all
  let show-h-list = show-h-state.indices
  let atom-annotations = _normalize-atom-annotations(atom-annotations)
  let opacity = _opacity-ratio(opacity, "opacity")
  let bond-custom = _normalize-bond-customizations(bond-customizations)

  // Molecule-level opacity fades every paint the drawing produces — bonds,
  // labels, lone pairs, annotations — so a faded molecule reads as a ghost.
  // Palette lookups receive the unfaded foreground and fade once on the way
  // out, so fallback-to-fg colors are not faded twice.
  let fade(c) = if opacity == 100% { c } else { c.transparentize(100% - opacity) }
  let base-fg = fg
  let fg = fade(fg)

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
  let subscript-size  = actual-font-size * 1.00
  let superscript-size = actual-font-size * 1.00
  let lone-pair-offset = calc.max(0.1, actual-font-size / canvas-scale * 0.6)
  let lone-pair-terminal-offset = calc.max(0.1, actual-font-size / canvas-scale * 0.5)
  let lone-pair-dot-r = calc.max(0.018, stroke-units * 0.75)
  let lone-pair-dot-gap = calc.max(0.050, lone-pair-dot-r * 2)
  let lone-pair-line-half = calc.max(0.055, stroke-units * 2.4)

  let atom-clr = if color {
    (sym) => fade({
      if sym in atom-colors { atom-colors.at(sym) }
      else { _atom-color(sym, theme: theme, fg: base-fg) }
    })
  } else { (sym) => fg }
  let label-clr = if color {
    (style) => fade({
      if style in atom-colors { atom-colors.at(style) }
      else { _label-color(style, theme: theme, fg: base-fg) }
    })
  } else { (style) => fg }
  let display-clr(atom) = {
    let abbrev = atom.at("abbrev", default: "")
    let abbrev-style = atom.at("abbrev_style", default: "")
    if abbrev != "" {
      let label-key = "{" + abbrev + "}"
      if color and label-key in atom-colors { fade(atom-colors.at(label-key)) }
      else { label-clr(abbrev-style) }
    } else {
      atom-clr(atom.symbol)
    }
  }
  let atom-label(body, fill: fg, size: actual-font-size) = text(
    size: size,
    font: font,
    style: "normal",
    weight: "regular",
    fill: fill,
    body,
  )
  let transparent = rgb(0, 0, 0, 0)
  let content-width(body) = measure(body).width / canvas-scale
  let index-marker-name(i, suffix) = index-prefix + "atom-index-marker-" + str(i) + suffix

  let cos-a = calc.cos(rotation)
  let sin-a = calc.sin(rotation)
  let rx(x, y) = x * cos-a - y * sin-a
  let ry(x, y) = x * sin-a + y * cos-a

  // cetz.draw exports a `scale` transform that would shadow the `scale` argument,
  // so import only after all scalar/style values above are computed.
  import cetz.draw: *

  // Virtual bonds connect a heavy atom to its bracket-H atoms. They carry positions
  // for atom() references but must not affect structural computations or rendering.
  let real-bonds = layout.bonds.filter(b => not b.at("virtual_bond", default: false))
  let vh-parent = (:)
  let vh-child = (:)
  let vh-dir = (:)
  for b in layout.bonds {
    if b.at("virtual_bond", default: false) {
      let pi = b.from
      let hi = b.to
      vh-parent.insert(str(hi), pi)
      vh-child.insert(str(pi), hi)
      let p = layout.atoms.at(pi)
      let h = layout.atoms.at(hi)
      let dx = rx(h.pos.x, h.pos.y) - rx(p.pos.x, p.pos.y)
      let dy = ry(h.pos.x, h.pos.y) - ry(p.pos.x, p.pos.y)
      let d = calc.sqrt(dx * dx + dy * dy)
      let ux = if d > 0.001 { dx / d } else { 1.0 }
      let uy = if d > 0.001 { dy / d } else { 0.0 }
      vh-dir.insert(str(pi), (ux, uy))
    }
  }

  let atom-degree(i) = real-bonds.filter(b => b.from == i or b.to == i).len()
    let atom-neighbor-indices(i) = {
      let indices = ()
      for b in real-bonds {
        if b.from == i {
          indices.push(b.to)
        } else if b.to == i {
          indices.push(b.from)
        }
      }
      indices
    }
    // A cumulene-center carbon (two double bonds, collinear neighbors) is
    // drawn as an explicit C label: without it the two double bonds merge
    // into what reads as one long double bond (O=C=O, ketene, allenes).
    let force-linear-carbon-label(i) = {
      let atom = layout.atoms.at(i)
      if not _is-carbon(atom) or atom.at("abbrev", default: "") != "" or atom-degree(i) != 2 {
        false
      } else {
        let bonds = real-bonds.filter(b => b.from == i or b.to == i)
        bonds.filter(b => b.order == 2).len() == 2
      }
    }
    let forced-h(i) = show-h-list.contains(i)
    let has-label(i) = {
      let atom = layout.atoms.at(i)
      _has-label(atom, show-all-h: show-all-h, force: forced-h(i)) or force-linear-carbon-label(i)
    }
    let first-neighbor(i) = {
      let result = none
      for b in real-bonds {
        if result == none and (b.from == i or b.to == i) {
          result = if b.from == i { b.to } else { b.from }
        }
      }
      result
    }
    let visible-h-count(i) = {
      let atom = layout.atoms.at(i)
      let count = atom.hcount + _visible-implicit-h(
        atom,
        show-all-h: show-all-h,
        force: forced-h(i),
      )
      if atom.at("stereo_h", default: "none") != "none" {
        calc.max(0, count - 1)
      } else {
        count
      }
    }
    // How far a bond retreats from a labeled atom, in bond-length units.
    // Bare element symbols centered on the atom trim to the measured glyph
    // extent projected onto the bond direction, so a short label like "C"
    // hugs its bonds instead of eating a fixed margin. Labels with inline
    // hydrogens, charges, or isotopes keep the conservative fixed margin
    // because their content extends off-center. Short abbreviations can use
    // their measured box while longer groups keep the fixed guard.
    let label-trim(atom, i, ux, uy) = {
      let displays-h = visible-h-count(i) > 0 and (show-all-h or forced-h(i) or not _is-carbon(atom))
      if not has-label(i) {
        0.0
      } else if displays-h and atom-degree(i) == 1 and not _is-carbon(atom) {
        0.06
      } else if (
        atom.at("abbrev", default: "") != ""
        and not displays-h
        and atom.charge == 0
        and atom.at("isotope", default: 0) == 0
      ) {
        let m = measure(atom-label(atom.at("abbrev", default: "")))
        let hw = m.width / canvas-scale / 2
        let hh = m.height / canvas-scale / 2
        let extent = hw * calc.abs(ux) + hh * calc.abs(uy) + 0.07
        calc.min(label-margin, calc.max(0.14, extent))
      } else if (
        atom.at("abbrev", default: "") == ""
        and not displays-h
        and atom.charge == 0
        and atom.at("isotope", default: 0) == 0
      ) {
        let m = measure(atom-label(atom.symbol))
        let hw = m.width / canvas-scale / 2
        let hh = m.height / canvas-scale / 2
        let extent = hw * calc.abs(ux) + hh * calc.abs(uy) + 0.07
        calc.min(label-margin, calc.max(0.14, extent))
      } else {
        label-margin
      }
    }

    for bond in real-bonds {
      let af = layout.atoms.at(bond.from)
      let at = layout.atoms.at(bond.to)
      let p1x = rx(af.pos.x, af.pos.y)
      let p1y = ry(af.pos.x, af.pos.y)
      let p2x = rx(at.pos.x, at.pos.y)
      let p2y = ry(at.pos.x, at.pos.y)
      let c1 = display-clr(af)
      let c2 = display-clr(at)

      // Per-bond style overrides. A color override replaces the bicolor
      // halves with one uniform paint; stroke overrides the width for every
      // segment of this bond (double/triple lines, hashes, waves, dashes).
      let bc = bond-custom.at(
        str(calc.min(bond.from, bond.to)) + "-" + str(calc.max(bond.from, bond.to)),
        default: (:),
      )
      if "color" in bc {
        c1 = fade(bc.color)
        c2 = c1
      }
      if "opacity" in bc {
        c1 = c1.transparentize(100% - bc.opacity)
        c2 = c2.transparentize(100% - bc.opacity)
      }
      let stroke-w = if "stroke" in bc { bc.stroke } else { stroke-w }

      let dx = p2x - p1x
      let dy = p2y - p1y
      let len = calc.sqrt(dx * dx + dy * dy)
      let ux = if len > 0.001 { dx / len } else { 1.0 }
      let uy = if len > 0.001 { dy / len } else { 0.0 }

      let af-has-label = has-label(bond.from)
      let at-has-label = has-label(bond.to)
      let s1 = label-trim(af, bond.from, ux, uy)
      let s2 = label-trim(at, bond.to, ux, uy)
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
        for b in real-bonds {
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
      // Explicit drawing wedges/hashes use the written source as the tip.
      // Inferred stereochemical bonds fall back to a local stereocenter
      // heuristic.
      let af-abbr = af.at("abbrev", default: "") != ""
      let at-abbr = at.at("abbrev", default: "") != ""
      let af-is-c = (af.symbol == "C" or af.symbol == "c") and not af-abbr
      let at-is-c = (at.symbol == "C" or at.symbol == "c") and not at-abbr
      let tip-at-from = if bond.at("forced_stereo", default: false) { true }
                        else if af-is-c and not at-is-c { true }
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
        let n-lines = 8
        let half-w = 0.10
        let (sx, sy, ex, ey, near-c, far-c) = if tip-at-from {
          (q1x, q1y, q2x, q2y, c1, c2)
        } else {
          (q2x, q2y, q1x, q1y, c2, c1)
        }
        for i in range(n-lines) {
          let t = i / (n-lines - 1)
          let cx = sx + (ex - sx) * t
          let cy = sy + (ey - sy) * t
          let w  = half-w * calc.max(0.16, t)
          let ox = -uy * w
          let oy =  ux * w
          let c  = if t < 0.5 { near-c } else { far-c }
          line((cx - ox, cy - oy), (cx + ox, cy + oy), stroke: stroke-w + c)
        }

      } else if stereo == "wavy" {
        // Wavy (squiggly) bond: a sine wave along the bond axis, split at the
        // midpoint for bicoloring like a plain bond. A whole number of waves
        // keeps both endpoints on-axis at the atoms.
        let waves = 4
        let amp = 0.075
        let n-seg = 32
        let bx = q2x - q1x
        let by = q2y - q1y
        let pts = range(n-seg + 1).map(i => {
          let t = i / n-seg
          let s = calc.sin(t * waves * 2.0 * calc.pi) * amp
          (q1x + bx * t - uy * s, q1y + by * t + ux * s)
        })
        let half = calc.quo(n-seg, 2)
        let wavy-stroke(c) = (paint: c, thickness: stroke-w, cap: "round", join: "round")
        line(..pts.slice(0, half + 1), stroke: wavy-stroke(c1))
        line(..pts.slice(half), stroke: wavy-stroke(c2))

      } else if stereo == "dashed" {
        // Dashed bond: evenly spaced dashes drawn as explicit segments so the
        // pattern is symmetric about the bond center regardless of length.
        let n-dash = 6
        let duty = 0.62
        let cell = 1.0 / n-dash
        for i in range(n-dash) {
          let t0 = (i + (1.0 - duty) / 2) * cell
          let t1 = (i + (1.0 + duty) / 2) * cell
          let c = if (t0 + t1) / 2 < 0.5 { c1 } else { c2 }
          line(
            (q1x + (q2x - q1x) * t0, q1y + (q2y - q1y) * t0),
            (q1x + (q2x - q1x) * t1, q1y + (q2y - q1y) * t1),
            stroke: stroke-w + c,
          )
        }

      } else if (aromatic == "circle" and bond.at("aromatic", default: false)) or bond.order == 1 {
        // In circle mode an aromatic bond draws as a plain single line; the
        // ring's pi system is shown by the inscribed circle instead.
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
        // Quadruple bond: four parallel lines symmetric about the bond axis,
        // outer pair shortened like the outer lines of a triple bond.
        let trim = calc.min(multiple-bond-trim, len * 0.25)
        for k in (-1.5, -0.5, 0.5, 1.5) {
          let ox = -uy * double-gap * k
          let oy =  ux * double-gap * k
          let t = if calc.abs(k) > 1.0 { trim } else { 0.0 }
          split-line(
            q1x + ux * t + ox, q1y + uy * t + oy,
            q2x - ux * t + ox, q2y - uy * t + oy,
            c1, c2,
          )
        }
      }
    }

    // Aromatic rings as inscribed circles.
    if aromatic == "circle" {
      for ring in layout.at("aromatic_rings", default: ()) {
        circle(
          (rx(ring.center.x, ring.center.y), ry(ring.center.x, ring.center.y)),
          radius: ring.radius,
          stroke: stroke-w + fg,
          fill: none,
        )
      }
    }

    // ── Lone-pair annotation ──────────────────────────────────────────────
    // Non-bonding electron pairs render as either two dots (the two electrons)
    // or a single short line. Hydrogen-bearing heteroatom labels are laid out
    // in screen space so the pairs avoid the bond and the inline hydrogen; all
    // other labeled atoms use the layout directions supplied by the plugin.

    // Unit vector in screen space pointing from atom `i` toward atom `j`,
    // or none when the two atoms coincide.
    let neighbor-screen-dir(i, j) = {
      let a = layout.atoms.at(i).pos
      let b = layout.atoms.at(j).pos
      let vx = rx(b.x, b.y) - rx(a.x, a.y)
      let vy = ry(b.x, b.y) - ry(a.x, a.y)
      let len = calc.sqrt(vx * vx + vy * vy)
      if len > 0.001 { (x: vx / len, y: vy / len) } else { none }
    }

    // Cardinal screen directions for a hydrogen-bearing heteroatom, chosen
    // greedily to stay clear of the bonds, the inline hydrogen, and one another.
    let inline-h-pair-dirs(i, count) = {
      let occupied = ()
      for ni in atom-neighbor-indices(i) {
        let d = neighbor-screen-dir(i, ni)
        if d != none { occupied.push(d) }
      }
      if atom-degree(i) >= 2 {
        // A stacked hydrogen is drawn directly above the symbol.
        occupied.push((x: 0.0, y: 1.0))
      } else {
        // An inline "XH" runs horizontally: the hydrogen sits opposite a
        // horizontal bond, or to the right of a vertical one.
        let ni = first-neighbor(i)
        let d = if ni != none { neighbor-screen-dir(i, ni) } else { none }
        let h-dir = if d == none {
          (x: 1.0, y: 0.0)
        } else if calc.abs(d.x) >= calc.abs(d.y) {
          (x: -d.x, y: 0.0)
        } else {
          (x: 1.0, y: 0.0)
        }
        occupied.push(h-dir)
      }

      let candidates = if count == 1 {
        ((x: 0.0, y: -1.0), (x: 0.0, y: 1.0), (x: -1.0, y: 0.0), (x: 1.0, y: 0.0))
      } else {
        ((x: 0.0, y: 1.0), (x: 0.0, y: -1.0), (x: -1.0, y: 0.0), (x: 1.0, y: 0.0))
      }

      let chosen = ()
      for _ in range(count) {
        let best = none
        let best-score = none
        for cand in candidates {
          let score = 0.0
          for occ in occupied {
            let dot = cand.x * occ.x + cand.y * occ.y
            if dot > 0.85 {
              score += 100.0
            } else if dot > 0.45 {
              score += 8.0
            } else if dot > 0.10 {
              score += 1.0
            }
          }
          for sel in chosen {
            if cand.x * sel.x + cand.y * sel.y > 0.85 { score += 100.0 }
          }
          if best-score == none or score < best-score {
            best = cand
            best-score = score
          }
        }
        if best != none {
          chosen.push(best)
          occupied.push(best)
        }
      }
      chosen
    }

    // Draw each direction in `dirs` (screen-space unit vectors) as one electron
    // pair around `origin`: two dots in "dots" mode, a short line in "lines".
    // `origin` can be a numeric point or a named glyph marker.
    let render-pairs(origin, dirs, fill, offset) = {
      let point-at(dx, dy) = if type(origin) == str or type(origin) == dictionary {
        (to: origin, rel: (dx, dy))
      } else {
        (origin.x + dx, origin.y + dy)
      }
      for dir in dirs {
        let ox = -dir.y
        let oy = dir.x
        if lone-pairs == "dots" {
          circle(
            point-at(
              dir.x * offset + ox * lone-pair-dot-gap / 2,
              dir.y * offset + oy * lone-pair-dot-gap / 2,
            ),
            radius: lone-pair-dot-r,
            fill: fill,
            stroke: none,
          )
          circle(
            point-at(
              dir.x * offset - ox * lone-pair-dot-gap / 2,
              dir.y * offset - oy * lone-pair-dot-gap / 2,
            ),
            radius: lone-pair-dot-r,
            fill: fill,
            stroke: none,
          )
        } else {
          line(
            point-at(
              dir.x * offset - ox * lone-pair-line-half,
              dir.y * offset - oy * lone-pair-line-half,
            ),
            point-at(
              dir.x * offset + ox * lone-pair-line-half,
              dir.y * offset + oy * lone-pair-line-half,
            ),
            stroke: stroke-w + fill,
          )
        }
      }
    }

    let draw-lone-pairs() = {
      if lone-pairs == none { return }
      for i in range(layout.atoms.len()) {
        let atom = layout.atoms.at(i)
        if atom.at("virtual_h", default: false) { continue }
        let count = atom.at("lone_pairs", default: 0)
        if count <= 0 { continue }

        let px = rx(atom.pos.x, atom.pos.y)
        let py = ry(atom.pos.x, atom.pos.y)
        let fill = display-clr(atom)
        let has-inline-h = (
          atom.at("abbrev", default: "") == "" and
          not _is-carbon(atom) and
          visible-h-count(i) > 0
        )

        if not has-inline-h {
          // Use the plugin's layout-space directions, rotated into screen space.
          let dirs = atom
            .at("lone_pair_dirs", default: ())
            .map(d => (x: rx(d.x, d.y), y: ry(d.x, d.y)))
          render-pairs((x: px, y: py), dirs, fill, lone-pair-offset)
        } else {
          let origin = if str(i) in vh-child {
            index-marker-name(i, "-sym") + ".center"
          } else {
            (x: px, y: py)
          }
          let offset = if atom-degree(i) <= 1 { lone-pair-terminal-offset } else { lone-pair-offset }
          render-pairs(origin, inline-h-pair-dirs(i, count), fill, offset)
        }
      }
    }

    // Stereochemical hydrogens are drawn as explicit H labels only when they
    // carry wedge/hash information from a bracket stereocenter.
    for i in range(layout.atoms.len()) {
      let atom = layout.atoms.at(i)
      if atom.at("virtual_h", default: false) { continue }
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
      if atom.at("virtual_h", default: false) { continue }
      if has-label(i) {
        let abbrev = atom.at("abbrev", default: "")
        let fill = display-clr(atom)
        let px = rx(atom.pos.x, atom.pos.y)
        let py = ry(atom.pos.x, atom.pos.y)
        let deg = atom-degree(i)
        let h-count = visible-h-count(i)

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

        let isotope = atom.at("isotope", default: 0)
        let isotope-content = if isotope > 0 {
          super(atom-label(str(isotope), fill: fill, size: superscript-size))
        } else {
          []
        }
        let sym-text = isotope-content + atom-label(atom.symbol, fill: fill)
        let h-text = if abbrev != "" or h-count == 0 or (_is-carbon(atom) and not (show-all-h or forced-h(i))) {
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
          if (show-indices or lone-pairs != none) and str(i) in vh-child {
            let h-child = vh-child.at(str(i))
            let pad-u = pad-bond / canvas-scale
            let sym-marker-x = if sym-anchor == "east" {
              px - pad-u - content-width(if h-at == "west" { charge-content } else { [] })
            } else if sym-anchor == "west" {
              px + pad-u
            } else {
              px
            }
            content(
              (sym-marker-x, py),
              atom-label(atom.symbol, fill: transparent),
              anchor: sym-anchor,
              padding: 0pt,
              name: index-marker-name(i, "-sym"),
            )
            content(
              if h-self == "east" {
                (
                  to: sname + ".north-" + h-at,
                  rel: (content-width(atom-label("H", fill: transparent)) - content-width(h-text), 0),
                )
              } else {
                sname + ".north-" + h-at
              },
              atom-label("H", fill: transparent),
              anchor: "north-" + h-self,
              padding: 0pt,
              name: index-marker-name(h-child, "-h"),
            )
          }
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
          let h-above-marker = none
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
              if (show-indices or lone-pairs != none) and str(i) in vh-child {
                h-above-marker = (
                  child: vh-child.at(str(i)),
                  group: h-text,
                  prefix: [],
                  fragment: atom-label("H", fill: transparent),
                )
              }
              sym-text
            } else if reverse-inline {
              h-text + sym-text
            } else {
              sym-text + h-text
            }
            base-text + charge-content
          }

          let symbol-centered-charge = abbrev == "" and h-text == [] and charge-content != []

          if symbol-centered-charge {
            content(
              (px + (content-width(label-content) - content-width(sym-text)) / 2, py),
              label-content,
              anchor: "center",
              padding: 1pt,
            )
          } else if draw-h-above {
            let h-center = (x: px, y: py + label-margin * 0.95)
            content(
              (h-center.x, h-center.y),
              h-above-content,
              anchor: "center",
              padding: 1pt,
            )
            if h-above-marker != none {
              let sym-marker = atom-label(atom.symbol, fill: transparent)
              let sym-x = (
                px
                - content-width(label-content) / 2
                + content-width(sym-marker) / 2
              )
              content(
                (sym-x, py),
                sym-marker,
                anchor: "center",
                padding: 0pt,
                name: index-marker-name(i, "-sym"),
              )
            }
            if h-above-marker != none {
              let marker-x = (
                h-center.x
                - content-width(h-above-marker.group) / 2
                + content-width(h-above-marker.prefix)
                + content-width(h-above-marker.fragment) / 2
              )
              content(
                (marker-x, h-center.y),
                h-above-marker.fragment,
                anchor: "center",
                padding: 0pt,
                name: index-marker-name(h-above-marker.child, "-h"),
              )
            }
          }

          if (show-indices or lone-pairs != none) and str(i) in vh-child and not draw-h-above {
            let h-child = vh-child.at(str(i))
            let sym-marker = atom-label(atom.symbol, fill: transparent)
            let h-marker = atom-label("H", fill: transparent)
            let h-prefix = if label-content == h-text + sym-text + charge-content {
              []
            } else {
              sym-text
            }
            let sym-prefix = if h-prefix == [] { h-text } else { [] }
            let sym-x = (
              px
              - content-width(label-content) / 2
              + content-width(sym-prefix)
              + content-width(sym-marker) / 2
            )
            let h-x = (
              px
              - content-width(label-content) / 2
              + content-width(h-prefix)
              + content-width(h-marker) / 2
            )
            content(
              (sym-x, py),
              sym-marker,
              anchor: "center",
              padding: 0pt,
              name: index-marker-name(i, "-sym"),
            )
            content(
              (h-x, py),
              h-marker,
              anchor: "center",
              padding: 0pt,
              name: index-marker-name(h-child, "-h"),
            )
          }

          if not symbol-centered-charge {
            let label-x = if abbrev != "" {
              px - _label-anchor-offset(
                abbrev,
                atom.at("abbrev_anchor", default: 0),
                atom.at("abbrev_anchor_len", default: 0),
                text => content-width(atom-label(text, fill: fill)),
              )
            } else {
              px
            }
            content((label-x, py), label-content, anchor: "center", padding: 1pt)
          }
        }
      }
    }

    draw-lone-pairs()

    // Small gray annotations placed on the emptiest side of an atom, offset
    // beyond the label region so they read as side notes rather than as the
    // sub- or superscripts of the chemical label itself.
    let annotation-fill = fade(if theme == "dark" { rgb("#9E9E9E") } else { rgb("#8F8F8F") })
    for ann in atom-annotations {
      let i = ann.index
      let body = ann.body
      let atom = layout.atoms.at(i)
      if not atom.at("virtual_h", default: false) {
        let px = rx(atom.pos.x, atom.pos.y)
        let py = ry(atom.pos.x, atom.pos.y)
        let sxv = atom-neighbor-indices(i)
          .map(ni => neighbor-screen-dir(i, ni))
          .filter(d => d != none)
        let sum = sxv.fold((x: 0.0, y: 0.0), (acc, d) => (x: acc.x + d.x, y: acc.y + d.y))
        let len = calc.sqrt(sum.x * sum.x + sum.y * sum.y)
        let dir = if len > 0.05 {
          (x: -sum.x / len, y: -sum.y / len)
        } else {
          // Symmetric surroundings or isolated atom: place diagonally.
          (x: 0.7071, y: 0.7071)
        }
        let offset = if has-label(i) { label-margin + 0.14 } else { 0.30 }
        let nudge = ann.at("offset", default: (0, 0))
        content(
          (px + dir.x * offset + nudge.at(0), py + dir.y * offset + nudge.at(1)),
          text(size: actual-font-size * 0.62, fill: annotation-fill, body),
          anchor: "center",
          padding: 1pt,
        )
      }
    }

    // Development overlay: stamp each atom's writing-order index so users can
    // read off the numbers used by atom()/bond()/lp() references.
    //
    // Bracket-H labels (e.g. "H₄" in NH₄⁺) are drawn as combined text, while
    // the heavy atom and H remain separate addressable indices. Hidden same-font
    // fragment markers expose the measured glyph centers for the overlay.
    if show-indices {
      let badge-size  = actual-font-size * 0.52
      let badge-bg = if theme == "dark" { rgb(30, 30, 30, 220) } else { rgb(255, 255, 255, 220) }

      for i in range(layout.atoms.len()) {
        let a  = layout.atoms.at(i)
        let ax = rx(a.pos.x, a.pos.y)
        let ay = ry(a.pos.x, a.pos.y)

        let (bx, by, btarget) = if (
          not a.at("virtual_h", default: false) and
          str(i) in vh-child and
          _has-label(a, show-all-h: show-all-h, force: forced-h(i))
        ) {
          (0.0, 0.0, index-marker-name(i, "-sym") + ".center")
        } else if (
          a.at("virtual_h", default: false) and
          str(i) in vh-parent and
          _has-label(
            layout.atoms.at(vh-parent.at(str(i))),
            show-all-h: show-all-h,
            force: forced-h(vh-parent.at(str(i))),
          )
        ) {
          (0.0, 0.0, index-marker-name(i, "-h") + ".center")
        } else {
          (ax, ay, none)
        }

        content(
          if btarget == none { (bx, by) } else { btarget },
          box(
            fill: badge-bg,
            inset: 0.4pt,
            text(size: badge-size, fill: rgb("#C81E6E"), weight: "bold", str(i)),
          ),
          anchor: "center",
          padding: 0pt,
        )
      }
    }
}

// ── Reference resolution and annotation drawing ─────────────────────────────────

// Screen-space position of layout coordinate (x, y) under `rotation`.
#let _rot(x, y, rotation) = (
  x * calc.cos(rotation) - y * calc.sin(rotation),
  x * calc.sin(rotation) + y * calc.cos(rotation),
)

// Absolute canvas position of atom `i` in a placed species. Label references use
// the rendered atom glyph center rather than the full label box.
#let _atom-pos(sp, i) = {
  let a = sp.layout.atoms.at(i)
  let (rxv, ryv) = _rot(a.pos.x, a.pos.y, sp.rotation)
  let base = (sp.origin.at(0) + rxv, sp.origin.at(1) + ryv)

  let cs = sp.at("canvas-scale", default: 30pt)
  let fs = sp.at("actual-font-size", default: 11pt)
  let font = sp.at("font", default: "New Computer Modern")
  let show-h-state = _normalize-show-h(sp.at("show-h", default: ()))
  let show-all-h = show-h-state.all
  let label-margin = calc.max(0.27, fs / cs * 0.70)
  let subscript-size = fs * 1.00
  let superscript-size = fs * 1.00
  let atom-label(body, size: fs) = text(
    size: size,
    font: font,
    style: "normal",
    weight: "regular",
    body,
  )
  let content-width(body) = measure(body).width / cs
  let content-height(body) = measure(body).height / cs
  let real-bonds = sp.layout.bonds.filter(b => not b.at("virtual_bond", default: false))
  let atom-degree(j) = real-bonds.filter(b => b.from == j or b.to == j).len()
  let first-neighbor(j) = {
    let result = none
    for b in real-bonds {
      if result == none and (b.from == j or b.to == j) {
        result = if b.from == j { b.to } else { b.from }
      }
    }
    result
  }
  let charge-content(atom) = {
    let charge-str = if atom.charge == 1        { "+" }
                     else if atom.charge == -1  { "\u{2212}" }
                     else if atom.charge > 1    { str(atom.charge) + "+" }
                     else if atom.charge < -1   { str(-atom.charge) + "\u{2212}" }
                     else                       { "" }
    if charge-str == "" {
      []
    } else {
      h(0.12em) + super(atom-label(charge-str, size: superscript-size))
    }
  }
  let show-h-list = show-h-state.indices
  let h-text(atom, idx) = {
    let force = show-h-list.contains(idx)
    let count = atom.hcount + _visible-implicit-h(atom, show-all-h: show-all-h, force: force)
    if atom.at("abbrev", default: "") != "" or count == 0 or (_is-carbon(atom) and not (show-all-h or force)) {
      []
    } else if count == 1 {
      atom-label("H")
    } else {
      atom-label("H") + sub(atom-label(str(count), size: subscript-size))
    }
  }
  let virtual-child(parent) = {
    let child = none
    for b in sp.layout.bonds {
      if child == none and b.at("virtual_bond", default: false) and b.from == parent {
        child = b.to
      }
    }
    child
  }
  let virtual-parent(child) = {
    let parent = none
    for b in sp.layout.bonds {
      if parent == none and b.at("virtual_bond", default: false) and b.to == child {
        parent = b.from
      }
    }
    parent
  }

  let label-fragment-pos(parent, fragment) = {
    let atom = sp.layout.atoms.at(parent)
    let (pxr, pyr) = _rot(atom.pos.x, atom.pos.y, sp.rotation)
    let px = sp.origin.at(0) + pxr
    let py = sp.origin.at(1) + pyr
    let deg = atom-degree(parent)
    let sym-text = atom-label(atom.symbol)
    let ht = h-text(atom, parent)
    let charge = charge-content(atom)

    if atom.at("abbrev", default: "") != "" or ht == [] {
      return (px, py)
    }

    let hetero-inline = deg == 1 and not _is-carbon(atom)
    if hetero-inline {
      let ni = first-neighbor(parent)
      if ni == none { return (px, py) }
      let nb = sp.layout.atoms.at(ni)
      let (nbx, nby) = _rot(nb.pos.x, nb.pos.y, sp.rotation)
      let dx = nbx - pxr
      let dy = nby - pyr
      let pad-u = 1pt / cs
      let sym-w = content-width(sym-text)
      let h-w = content-width(atom-label("H"))
      let (sym-anchor, h-at) = if calc.abs(dx) >= calc.abs(dy) {
        if dx > 0 { ("east", "west") } else { ("west", "east") }
      } else if dy > 0 {
        ("north", "east")
      } else {
        ("south", "east")
      }

      let sym-center = if sym-anchor == "east" {
        (px - pad-u - content-width(if h-at == "west" { charge } else { [] }) - sym-w / 2, py)
      } else if sym-anchor == "west" {
        (px + pad-u + sym-w / 2, py)
      } else if sym-anchor == "north" {
        (px, py - content-height(sym-text) / 2)
      } else {
        (px, py + content-height(sym-text) / 2)
      }

      if fragment == "sym" {
        return sym-center
      }

      let hx = if h-at == "west" {
        sym-center.at(0) - sym-w / 2 - h-w / 2
      } else {
        sym-center.at(0) + sym-w / 2 + h-w / 2
      }
      return (hx, sym-center.at(1))
    }

    let stacked-h = deg >= 2 and not _is-carbon(atom)
    if stacked-h {
      if fragment == "h" {
        return (px, py + label-margin * 0.95)
      }
      let label-content = sym-text + charge
      return (
        px - content-width(label-content) / 2 + content-width(sym-text) / 2,
        py,
      )
    }

    let reverse-inline = if deg != 1 {
      false
    } else {
      let ni = first-neighbor(parent)
      if ni == none {
        false
      } else {
        let neighbor = sp.layout.atoms.at(ni)
        let (nx, _) = _rot(neighbor.pos.x, neighbor.pos.y, sp.rotation)
        nx - pxr > 0.05
      }
    }
    let label-content = if reverse-inline {
      ht + sym-text + charge
    } else {
      sym-text + ht + charge
    }
    let left = px - content-width(label-content) / 2
    if fragment == "sym" {
      let prefix = if reverse-inline { ht } else { [] }
      (left + content-width(prefix) + content-width(sym-text) / 2, py)
    } else {
      let prefix = if reverse-inline { [] } else { sym-text }
      (left + content-width(prefix) + content-width(atom-label("H")) / 2, py)
    }
  }

  if a.at("virtual_h", default: false) {
    let parent = virtual-parent(i)
    if parent == none { return base }
    return label-fragment-pos(parent, "h")
  }

  if not _has-label(a, show-all-h: show-all-h, force: show-h-list.contains(i)) { return base }
  let child = virtual-child(i)
  if child == none { return base }
  label-fragment-pos(i, "sym")
}

// Find the bond record joining atoms i and j in a species' layout.
#let _find-bond(sp, i, j) = {
  for b in sp.layout.bonds {
    if (b.from == i and b.to == j) or (b.from == j and b.to == i) { return b }
  }
  panic("no bond between atoms " + str(i) + " and " + str(j))
}

// Resolve a reference dictionary to an absolute canvas coordinate.
// `species` is the list of placed species records; `lp-offset` is the radial
// distance of a lone pair from its atom (in bond-length units).
#let _resolve(ref, species, lp-offset) = {
  let nudge(p) = {
    let o = ref.at("offset", default: (0, 0))
    (p.at(0) + o.at(0), p.at(1) + o.at(1))
  }
  let kind = ref.__ref__
  if kind == "atom" {
    nudge(_atom-pos(species.at(ref.species), ref.index))
  } else if kind == "bond" {
    let sp = species.at(ref.species)
    let pa = _atom-pos(sp, ref.i)
    let pb = _atom-pos(sp, ref.j)
    nudge(((pa.at(0) + pb.at(0)) / 2, (pa.at(1) + pb.at(1)) / 2))
  } else if kind == "lp" {
    let sp = species.at(ref.species)
    let a = sp.layout.atoms.at(ref.atom)
    let dirs = a.at("lone_pair_dirs", default: ())
    let base = _atom-pos(sp, ref.atom)
    if dirs.len() == 0 {
      nudge(base)
    } else {
      let d = dirs.at(calc.min(ref.pair, dirs.len() - 1))
      let (dx, dy) = _rot(d.x, d.y, sp.rotation)
      nudge((base.at(0) + dx * lp-offset, base.at(1) + dy * lp-offset))
    }
  } else if kind == "species" {
    // Bounding-box center of an opaque item; edge selection happens at draw time.
    let sp = species.at(ref.index)
    nudge(sp.origin)
  } else {
    panic("unknown reference kind: " + kind)
  }
}

// ── Annotation constructors (consumed by smiles() and reaction()) ───────────────

/// References an atom by index. `atom(i)` inside `smiles()`, or `atom(s, i)`
/// inside `reaction()` where `s` is the species (molecule) index. `offset` nudges
/// the point in bond-length units.
#let atom(..a) = {
  let p = a.pos()
  let (s, i) = if p.len() == 1 { (0, p.at(0)) } else { (p.at(0), p.at(1)) }
  (__ref__: "atom", species: s, index: i, offset: a.named().at("offset", default: (0, 0)))
}

/// References the midpoint of the bond between two atoms: `bond(i, j)` or
/// `bond(s, i, j)`.
#let bond(..a) = {
  let p = a.pos()
  let (s, i, j) = if p.len() == 2 { (0, p.at(0), p.at(1)) } else { (p.at(0), p.at(1), p.at(2)) }
  (__ref__: "bond", species: s, i: i, j: j, offset: a.named().at("offset", default: (0, 0)))
}

/// References a lone pair on an atom: `lp(i)` or `lp(s, i)`, with `pair:` selecting
/// which pair (default 0) when an atom carries several.
#let lp(..a) = {
  let p = a.pos()
  let (s, at) = if p.len() == 1 { (0, p.at(0)) } else { (p.at(0), p.at(1)) }
  (
    __ref__: "lp",
    species: s,
    atom: at,
    pair: a.named().at("pair", default: 0),
    offset: a.named().at("offset", default: (0, 0)),
  )
}

/// References a whole placed species (e.g. a `ce()` formula) by its index, snapping
/// to its bounding-box edge. Used when no interior atom is addressable.
#let species(k, offset: (0, 0)) = (__ref__: "species", index: k, offset: offset)

/// A curly electron-pushing arrow between two references.
///
/// - from (dictionary): source reference — `lp()`, `bond()`, `atom()`, `species()`.
/// - to (dictionary): destination reference.
/// - label (content): optional label drawn at the curve apex.
/// - color (color): arrow color. Default: red.
/// - bend (str): "left", "right", or none (straight). Which way the curve bows.
/// - angle (angle): how strongly the curve bows. Default: 15deg.
/// - half (bool): draw a half (fishhook) arrowhead for single-electron flow.
/// -> dictionary  (consumed by smiles()/reaction())
#let arrow(from: none, to: none, label: none, color: red, bend: "left", angle: 15deg, half: false) = (
  __arrow__: true,
  from: from,
  to: to,
  label: label,
  color: color,
  bend: bend,
  angle: angle,
  half: half,
)

/// Highlights an atom (disk) or bond (capsule) behind the structure.
///
/// - ref (dictionary/array): `atom(...)` or `bond(...)` reference, or an array of
///   references to highlight together.
/// - fill (color): highlight color. Default: a soft yellow.
/// - stroke (none/stroke): outline of an atom highlight. Default: none.
/// - radius (auto/float): atom-highlight radius in bond-length units.
/// - include-atoms (bool): for bond highlights, also shade both endpoint atoms.
///   Default: false.
/// -> dictionary  (consumed by smiles()/reaction())
#let highlight(ref, fill: rgb("#FFE45C"), stroke: none, radius: auto, include-atoms: false) = (
  __highlight__: true,
  ref: ref,
  fill: fill,
  stroke: stroke,
  radius: radius,
  include-atoms: include-atoms,
)

// ── Annotation drawing ──────────────────────────────────────────────────────────

// Endpoint coordinate for an arrow; species references snap to the box edge facing
// `toward`.
#let _endpoint(ref, specs, cfg, toward) = {
  let p = _resolve(ref, specs, cfg.lp-offset)
  if ref.__ref__ != "species" { return p }
  let sp = specs.at(ref.index)
  let (w, h) = sp.size
  let dx = toward.at(0) - p.at(0)
  let dy = toward.at(1) - p.at(1)
  if dx == 0 and dy == 0 { return p }
  let tx = if dx != 0 { (w / 2) / calc.abs(dx) } else { 1e9 }
  let ty = if dy != 0 { (h / 2) / calc.abs(dy) } else { 1e9 }
  let t = calc.min(tx, ty)
  (p.at(0) + dx * t, p.at(1) + dy * t)
}

#let _draw-highlight(h, specs, cfg) = {
  import cetz.draw: *
  let refs = if type(h.ref) == array { h.ref } else { (h.ref,) }
  for ref in refs {
    if ref.__ref__ == "bond" {
      let sp = specs.at(ref.species)
      let pa = _atom-pos(sp, ref.i)
      let pb = _atom-pos(sp, ref.j)
      let dx = pb.at(0) - pa.at(0)
      let dy = pb.at(1) - pa.at(1)
      let len = calc.max(1e-6, calc.sqrt(dx * dx + dy * dy))
      let trim = if h.include-atoms { 0.0 } else { calc.min(cfg.bond-trim, len * 0.45) }
      let ux = dx / len
      let uy = dy / len
      line(
        (pa.at(0) + ux * trim, pa.at(1) + uy * trim),
        (pb.at(0) - ux * trim, pb.at(1) - uy * trim),
        stroke: (paint: h.fill, thickness: cfg.bond-thickness, cap: "round"),
      )
      if h.include-atoms {
        let r = if h.radius == auto { cfg.atom-radius } else { h.radius }
        circle(pa, radius: r, fill: h.fill, stroke: h.stroke)
        circle(pb, radius: r, fill: h.fill, stroke: h.stroke)
      }
    } else {
      let p = _resolve(ref, specs, cfg.lp-offset)
      let sp = specs.at(ref.species)
      let atom = sp.layout.atoms.at(ref.index)
      let abbrev = atom.at("abbrev", default: "")
      if ref.__ref__ == "atom" and abbrev != "" {
        let cs = sp.at("canvas-scale", default: 30pt)
        let fs = sp.at("actual-font-size", default: 11pt)
        let font = sp.at("font", default: "New Computer Modern")
        let label = text(size: fs, font: font, style: "normal", weight: "regular", abbrev)
        let w = measure(label).width / cs
        let label-width = body => measure(text(size: fs, font: font, style: "normal", weight: "regular", body)).width / cs
        let center-x = p.at(0) - _label-anchor-offset(
          abbrev,
          atom.at("abbrev_anchor", default: 0),
          atom.at("abbrev_anchor_len", default: 0),
          label-width,
        )
        let h-units = measure(label).height / cs
        let pad-x = calc.max(0.08, fs / cs * 0.16)
        let thick = cs * calc.max(h-units + fs / cs * 0.55, cfg.atom-radius * 1.7)
        line(
          (center-x - w / 2 - pad-x, p.at(1)),
          (center-x + w / 2 + pad-x, p.at(1)),
          stroke: (paint: h.fill, thickness: thick, cap: "round"),
        )
      } else {
        let r = if h.radius == auto { cfg.atom-radius } else { h.radius }
        circle(p, radius: r, fill: h.fill, stroke: h.stroke)
      }
    }
  }
}

#let _draw-arrow(a, specs, cfg) = {
  import cetz.draw: *
  let raw0 = _resolve(a.from, specs, cfg.lp-offset)
  let raw1 = _resolve(a.to, specs, cfg.lp-offset)
  let p0 = _endpoint(a.from, specs, cfg, raw1)
  let p1 = _endpoint(a.to, specs, cfg, raw0)

  let dx = p1.at(0) - p0.at(0)
  let dy = p1.at(1) - p0.at(1)
  let len = calc.max(1e-6, calc.sqrt(dx * dx + dy * dy))
  let ux = dx / len
  let uy = dy / len

  // Pull both ends in slightly so the tail clears its source glyph and the head
  // stops just short of the target.
  let ins = calc.min(cfg.inset, len * 0.3)
  let q0 = (p0.at(0) + ux * ins, p0.at(1) + uy * ins)
  let q1 = (p1.at(0) - ux * ins, p1.at(1) - uy * ins)

  let sign = if a.bend == "right" { -1.0 } else if a.bend == "left" { 1.0 } else { 0.0 }
  let nx = -uy
  let ny = ux
  let mx = (q0.at(0) + q1.at(0)) / 2
  let my = (q0.at(1) + q1.at(1)) / 2
  let mag = (len / 2) * calc.tan(a.angle) * sign
  let apex = (mx + nx * mag, my + ny * mag)

  let mk = (end: ">", fill: a.color, scale: cfg.arrow-scale, harpoon: a.half)
  let strk = (paint: a.color, thickness: cfg.arrow-thickness)
  if sign == 0 {
    line(q0, q1, stroke: strk, mark: mk)
  } else {
    bezier-through(q0, apex, q1, stroke: strk, mark: mk)
  }

  if a.label != none {
    let g = if sign == 0 { cfg.label-gap } else { mag + sign * cfg.label-gap }
    content(
      (mx + nx * g, my + ny * g),
      text(size: cfg.label-size, fill: a.color, a.label),
      anchor: "center",
    )
  }
}

// Annotation styling derived from the shared canvas scale and font size.
#let _annotation-cfg(canvas-scale, font-size, scale) = (
  lp-offset: calc.max(0.1, font-size / canvas-scale * 0.6),
  atom-radius: calc.max(0.12, font-size / canvas-scale * 0.5),
  bond-thickness: canvas-scale * 0.42,
  bond-trim: calc.max(0.42, font-size / canvas-scale * 0.75),
  arrow-thickness: calc.max(0.7pt, 1.0pt * scale),
  arrow-scale: scale,
  label-size: font-size * 0.92,
  inset: 0.16,
  label-gap: 0.34,
)

// ── SMILES renderer ─────────────────────────────────────────────────────────────

/// Renders a SMILES string as a 2D skeletal molecular diagram.
///
/// - smiles-str (str): A valid SMILES string, e.g. "C1=CC=CC=C1" or
///   "c1ccccc1" for benzene.
/// - style ("default" / "acs" / "rsc" / "nature" / "wiley"): Journal style
///   preset filling in bond-length, font-size, bond-stroke, and font from the
///   journal's published drawing settings. Arguments passed explicitly win;
///   "default" applies nothing. Default: "default".
/// - scale (float): Balanced scale for bond length, atom labels, and bond stroke.
///   Explicit bond-length, font-size, or bond-stroke values override it.
///   Default: 1.0.
/// - bond-length (float): Bond length scale factor; 1.0 = 30 pt per bond.
/// - font-size (length): Font size for atom labels.
/// - font (auto / str / array): Font for atom labels. `auto` is
///   "New Computer Modern", or the preset's font when `style` is set.
/// - bond-stroke (length): Bond stroke width.
/// - color (auto / bool): Apply Jmol CPK atom colors. `auto` is true for the
///   default style and false for journal presets. Default: auto.
/// - fg (auto / color): Foreground color for bonds, carbon labels, and other
///   currently-black elements. `auto` inherits the surrounding text color, so
///   molecules recolor automatically on dark slides. Default: auto.
/// - theme (auto / "light" / "dark"): CPK palette variant. "dark" lifts the
///   lightness of hues that vanish on dark backgrounds (N, O, Br, I and the
///   dark named label colors). `auto` picks "dark" when `fg` is light.
///   Default: auto.
/// - rotation (angle): Rotate the molecule by this angle. Atom labels stay upright.
///   Example: rotation: 90deg. Default: 0deg.
/// - mirror (none / "horizontal" / "vertical"): Optional horizontal or vertical
///   page-axis reflection. Wedges and hashes are exchanged so the depicted
///   stereochemistry is preserved.
///   Default: none.
/// - show-h ("all" / int / array): Which implicit hydrogens to label beyond
///   the default heteroatom hydrogens. Use "all" for every atom, an integer for
///   one atom, or an array for selected atoms. Default: ().
/// - aromatic ("kekule" / "circle"): How rings written in aromatic (lowercase)
///   notation are depicted: alternating double bonds, or single bonds with an
///   inscribed circle. Kekulé-written input always draws its explicit bonds.
///   Default: "kekule".
/// - atom-annotations (array): Small gray side labels as tuple entries:
///   (index, content) or (index, content, offset). Default: ().
/// - opacity (ratio / float): Fade the whole drawing — bonds, labels, lone
///   pairs, annotations — e.g. for ghost molecules. Default: 100%.
/// - bond-customizations (array): Per-bond style overrides as
///   (bond(i, j), (..options..)) pairs; options are color, stroke (width),
///   and opacity. Default: ().
/// - lone-pairs (none / "dots" / "lines"): Draw non-bonding electron pairs on
///   skeletal atom labels. Default: none.
/// - atom-colors (dictionary): Color overrides taking priority over the CPK palette
///   and inline `{label|style}` styles. See documentation for the two key forms.
/// - show-indices (bool): Stamp each atom's writing-order index on the diagram, as a
///   development aid for writing atom()/bond()/lp() references. Default: false.
/// - ..annotations: Any number of arrow() / highlight() items referencing atoms of
///   this molecule (single-index form, e.g. atom(2)).
/// -> content
#let smiles(
  smiles-str,
  style: "default",
  scale: 1.0,
  bond-length: none,
  font-size: none,
  font: auto,
  bond-stroke: none,
  color: auto,
  fg: auto,
  theme: auto,
  rotation: 0deg,
  mirror: none,
  show-h: (),
  aromatic: "kekule",
  atom-annotations: (),
  opacity: 100%,
  bond-customizations: (),
  lone-pairs: none,
  atom-colors: (:),
  show-indices: false,
  ..annotations
) = context {
  // A style preset fills in only the sizing arguments the caller left unset,
  // and scales with `scale` like the built-in defaults do.
  let preset = _style-preset(style)
  let color = if color == auto { if preset == none { true } else { preset.color } } else { color }
  if type(color) != bool {
    panic("color must be auto or a bool")
  }
  let (bond-length, font-size, bond-stroke, font) = if preset == none {
    (bond-length, font-size, bond-stroke, font)
  } else {(
    if bond-length == none { preset.bond-length * scale } else { bond-length },
    if font-size == none { preset.font-size * scale } else { font-size },
    if bond-stroke == none { preset.bond-stroke * scale } else { bond-stroke },
    if font == auto { preset.font } else { font },
  )}
  let font = if font == auto { "New Computer Modern" } else { font }

  let (fg, theme) = _resolve-fg-theme(fg, theme)
  let layout = _mirror-layout(_layout(smiles-str), mirror, rotation: rotation)
  let canvas-scale = _canvas-scale(scale, bond-length)
  let actual-font-size = if font-size == none { 11pt * scale } else { font-size }
  let ann = annotations.pos()
  let specs = ((
    kind: "mol",
    layout: layout,
    rotation: rotation,
    origin: (0, 0),
    size: (layout.bbox_width, layout.bbox_height),
    canvas-scale: canvas-scale,
    actual-font-size: actual-font-size,
    font: font,
    show-h: show-h,
  ),)
  let cfg = _annotation-cfg(canvas-scale, actual-font-size, scale)
  let the-scale = scale // cetz.draw `scale` shadows the argument inside the canvas

  cetz.canvas(length: canvas-scale, {
    import cetz.draw: *
    for h in ann {
      if type(h) == dictionary and h.at("__highlight__", default: false) {
        _draw-highlight(h, specs, cfg)
      }
    }
    _draw-molecule(
      layout,
      scale: the-scale,
      bond-length: bond-length,
      font-size: font-size,
      font: font,
      bond-stroke: bond-stroke,
      color: color,
      rotation: rotation,
      show-h: show-h,
      lone-pairs: lone-pairs,
      atom-colors: atom-colors,
      show-indices: show-indices,
      fg: fg,
      theme: theme,
      aromatic: aromatic,
      atom-annotations: atom-annotations,
      opacity: opacity,
      bond-customizations: bond-customizations,
    )
    for ar in ann {
      if type(ar) == dictionary and ar.at("__arrow__", default: false) {
        _draw-arrow(ar, specs, cfg)
      }
    }
  })
}

// Capture Typst transforms before local parameters and CeTZ imports shadow them.
#let _typst-scale = scale
#let _typst-rotate = rotate

/// Renders a molecule sized for running text. The drawing is scaled to a
/// target height and baseline-aligned so it sits inline like a word. Typst
/// grows a line to fit tall inline content, so neighboring lines are never
/// overlapped; the default height keeps ordinary line spacing (nearly)
/// unchanged, and larger heights make only the molecule's own line taller.
///
/// - smiles-str (str): The SMILES string.
/// - height (length): Target height of the drawing. Default: 1.4em.
/// - baseline (auto / length): How far the drawing's vertical center sits
///   above the text baseline. `auto` centers it on the lowercase body of the
///   surrounding text. Default: auto.
/// - ..args: Any #smiles() drawing options (color, fg, show-h, rotation, …).
/// -> content
#let smiles-inline(smiles-str, height: 1.4em, baseline: auto, ..args) = context {
  let body = smiles(smiles-str, ..args)
  let m = measure(body)
  if m.height <= 0pt { return body }
  let target = height.to-absolute()
  // Fit the drawing into the target height, but cap the scale so one bond
  // never exceeds most of that height: a flat, mostly horizontal molecule
  // measures almost no height and would otherwise blow up to fill it.
  let unit = _canvas-scale(
    args.named().at("scale", default: 1.0),
    args.named().at("bond-length", default: none),
  )
  let f = calc.min(target / m.height, target * 0.9 / unit)
  let scaled = _typst-scale(x: f * 100%, y: f * 100%, reflow: true, body)
  let center-above = if baseline == auto { 0.30em.to-absolute() } else { baseline.to-absolute() }
  box(baseline: m.height * f / 2 - center-above, scaled)
}

/// Draws a molecule as CeTZ elements inside an existing #cetz.canvas and
/// registers named anchors on the group, so arbitrary CeTZ drawing can attach
/// to real molecular positions: dashed hydrogen bonds between molecules,
/// distance labels, coupling arcs, custom arrows into a larger diagram.
///
/// Anchors on `name` (writing-order indices, as shown by `show-indices`):
///  - "atom-<i>" — every atom center,
///  - "bond-<i>-<j>" — every bond midpoint (i < j),
///  - "center" — the molecule origin.
///
/// Coordinates are in bond-length units; give the canvas
/// `length: 30pt * scale` so sizes match #smiles(scale: ...).
///
/// - smiles-str (str): The SMILES string.
/// - name (str): CeTZ group name carrying the anchors.
/// - origin (array): (x, y) placement of the molecule center, in canvas units.
/// - fg (color): Foreground color. `auto` is not resolvable inside a raw
///   canvas and falls back to black. Default: black.
/// - theme ("light" / "dark"): CPK palette variant. Default: "light".
/// - ..opts: #smiles() drawing options — scale, font-size, font, bond-stroke,
///   color, rotation, mirror, show-h, aromatic, atom-annotations, opacity,
///   bond-customizations, lone-pairs, atom-colors, show-indices.
/// -> none  (emits CeTZ draw elements)
#let smiles-cetz(smiles-str, name: none, origin: (0, 0), fg: black, theme: "light", ..opts) = {
  import cetz.draw: *
  let opts = opts.named()
  let fg = if fg == auto { black } else { fg }
  let theme = if theme == auto { "light" } else { theme }
  let mirror = opts.at("mirror", default: none)
  let rotation = opts.at("rotation", default: 0deg)
  let layout = _mirror-layout(_layout(smiles-str), mirror, rotation: rotation)
  let allowed = (
    "scale", "font-size", "font", "bond-stroke", "color", "rotation",
    "show-h", "lone-pairs", "atom-colors", "show-indices", "aromatic",
    "atom-annotations", "opacity", "bond-customizations",
  )
  let draw-opts = (:)
  for (k, v) in opts {
    if k in allowed {
      draw-opts.insert(k, v)
    } else if k != "mirror" {
      panic("smiles-cetz does not accept option \"" + k + "\"")
    }
  }
  if draw-opts.at("font", default: none) == auto {
    draw-opts.insert("font", "New Computer Modern")
  }
  let cos-a = calc.cos(rotation)
  let sin-a = calc.sin(rotation)
  group(name: name, {
    translate(origin)
    _draw-molecule(layout, fg: fg, theme: theme, ..draw-opts)
    for i in range(layout.atoms.len()) {
      let a = layout.atoms.at(i)
      anchor(
        "atom-" + str(i),
        (a.pos.x * cos-a - a.pos.y * sin-a, a.pos.x * sin-a + a.pos.y * cos-a),
      )
    }
    for b in layout.bonds {
      if not b.at("virtual_bond", default: false) {
        let p = layout.atoms.at(b.from).pos
        let q = layout.atoms.at(b.to).pos
        let mx = (p.x + q.x) / 2
        let my = (p.y + q.y) / 2
        anchor(
          "bond-" + str(calc.min(b.from, b.to)) + "-" + str(calc.max(b.from, b.to)),
          (mx * cos-a - my * sin-a, mx * sin-a + my * cos-a),
        )
      }
    }
    anchor("center", (0, 0))
  })
}

// ── Reaction scheme helpers ───────────────────────────────────────────────────

/// Creates a reaction arrow for use inside #reaction().
///
/// - above (content): Label above a horizontal arrow / to the right of a vertical one.
/// - below (content): Label below a horizontal arrow / to the left of a vertical one.
/// - dir (auto / str): Arrow direction — "right", "left", "down", or "up".
///   `auto` follows the enclosing #reaction(flow:) (right for horizontal flows,
///   down for vertical). Default: auto.
/// - kind (str): Arrow style — "single" (default), "equilibrium",
///   "equilibrium-filled", "dashed" (hypothetical/formal step), or "wavy"
///   (e.g. a distorted or non-elementary transformation).
/// - color (auto / color): Arrow color. `auto` inherits the surrounding text
///   color, matching dark slide themes. Default: auto.
/// -> dictionary  (consumed by #reaction)
#let rxn-arrow(above: none, below: none, dir: auto, kind: "single", color: auto) = (
  __rxn_arrow__: true,
  above: above,
  below: below,
  dir: dir,
  kind: kind,
  color: color,
)

// Render a horizontal reaction arrow.
#let _horiz-arrow(above, below, dir, kind, clr) = context {
  let clr = if clr == auto {
    if type(text.fill) == color { text.fill } else { black }
  } else { clr }
  let (sx, ex) = if dir == "left" { (52, 0) } else { (0, 52) }
  let arrow-canvas = cetz.canvas(length: 1pt, {
    import cetz.draw: *
    if kind == "single" {
      line((sx, 0), (ex, 0), mark: (end: ">", fill: clr, size: 5), stroke: 0.8pt + clr)
    } else if kind == "dashed" {
      line(
        (sx, 0), (ex, 0),
        mark: (end: ">", fill: clr, size: 5),
        stroke: (paint: clr, thickness: 0.8pt, dash: (array: (3pt, 2.2pt), phase: 0pt)),
      )
    } else if kind == "wavy" {
      // Sine wave over most of the shaft, then a short straight lead-out so
      // the arrowhead points along the travel direction.
      let sign = if ex > sx { 1 } else { -1 }
      let lead = 8
      let wave-end = ex - sign * lead
      let n-seg = 28
      let pts = range(n-seg + 1).map(i => {
        let t = i / n-seg
        (sx + (wave-end - sx) * t, calc.sin(t * 3.0 * 2.0 * calc.pi) * 2.4)
      })
      line(..pts, stroke: (paint: clr, thickness: 0.8pt, cap: "round", join: "round"))
      line((wave-end, 0), (ex, 0), mark: (end: ">", fill: clr, size: 5), stroke: 0.8pt + clr)
    } else if kind == "equilibrium" or kind == "equilibrium-filled" {
      let sign = if ex > sx { 1 } else { -1 }
      let head-len = 7
      let head-rise = 3.5
      if kind == "equilibrium-filled" {
        let top-base = ex - sign * head-len
        line((sx, 2.2), (ex, 2.2), stroke: 0.8pt + clr)
        line(
          (ex, 2.2), (top-base, 2.2), (top-base, 2.2 + head-rise),
          close: true, fill: clr, stroke: none,
        )
      } else {
        line((sx, 2.2), (ex, 2.2), stroke: 0.8pt + clr)
        line((ex, 2.2), (ex - sign * head-len, 2.2 + head-rise), stroke: 0.8pt + clr)
      }
      if kind == "equilibrium-filled" {
        let bottom-base = sx + sign * head-len
        line((ex, -2.2), (sx, -2.2), stroke: 0.8pt + clr)
        line(
          (sx, -2.2), (bottom-base, -2.2), (bottom-base, -2.2 - head-rise),
          close: true, fill: clr, stroke: none,
        )
      } else {
        line((ex, -2.2), (sx, -2.2), stroke: 0.8pt + clr)
        line((sx, -2.2), (sx + sign * head-len, -2.2 - head-rise), stroke: 0.8pt + clr)
      }
    } else {
      panic("rxn-arrow kind must be \"single\", \"equilibrium\", \"equilibrium-filled\", \"dashed\", or \"wavy\"")
    }
  })
  if above == none and below == none {
    align(center + horizon, arrow-canvas)
  } else {
    let above-label = if above != none { text(size: 8pt, above) } else { [] }
    let below-label = if below != none { text(size: 8pt, below) } else { [] }
    let above-size = if above != none { measure(above-label) } else { (width: 0pt, height: 0pt) }
    let below-size = if below != none { measure(below-label) } else { (width: 0pt, height: 0pt) }
    let arrow-size = measure(arrow-canvas)
    let label-h = calc.max(above-size.height, below-size.height)
    let row-w = calc.max(arrow-size.width, calc.max(above-size.width, below-size.width))
    align(center + horizon, stack(
      spacing: 3pt,
      box(width: row-w, height: label-h, align(center + bottom, above-label)),
      box(width: row-w, align(center + horizon, arrow-canvas)),
      box(width: row-w, height: label-h, align(center + top, below-label)),
    ))
  }
}

// Render a vertical reaction arrow. `above` is shown to the right, `below` to the left.
#let _vert-arrow(above, below, dir, kind, clr) = context {
  let clr = if clr == auto {
    if type(text.fill) == color { text.fill } else { black }
  } else { clr }
  let (from-y, to-y) = if dir == "up" { (0, 52) } else { (52, 0) }
  let arrow-canvas = cetz.canvas(length: 1pt, {
    import cetz.draw: *
    if kind == "single" {
      line((0, from-y), (0, to-y), mark: (end: ">", fill: clr, size: 5), stroke: 0.8pt + clr)
    } else if kind == "dashed" {
      line(
        (0, from-y), (0, to-y),
        mark: (end: ">", fill: clr, size: 5),
        stroke: (paint: clr, thickness: 0.8pt, dash: (array: (3pt, 2.2pt), phase: 0pt)),
      )
    } else if kind == "wavy" {
      let sign = if to-y > from-y { 1 } else { -1 }
      let lead = 8
      let wave-end = to-y - sign * lead
      let n-seg = 28
      let pts = range(n-seg + 1).map(i => {
        let t = i / n-seg
        (calc.sin(t * 3.0 * 2.0 * calc.pi) * 2.4, from-y + (wave-end - from-y) * t)
      })
      line(..pts, stroke: (paint: clr, thickness: 0.8pt, cap: "round", join: "round"))
      line((0, wave-end), (0, to-y), mark: (end: ">", fill: clr, size: 5), stroke: 0.8pt + clr)
    } else if kind == "equilibrium" or kind == "equilibrium-filled" {
      let sign = if to-y > from-y { 1 } else { -1 }
      let head-len = 7
      let head-rise = 3.5
      if kind == "equilibrium-filled" {
        let left-base = to-y - sign * head-len
        line((-2.2, from-y), (-2.2, to-y), stroke: 0.8pt + clr)
        line(
          (-2.2, to-y), (-2.2, left-base), (-2.2 - head-rise, left-base),
          close: true, fill: clr, stroke: none,
        )
      } else {
        line((-2.2, from-y), (-2.2, to-y), stroke: 0.8pt + clr)
        line((-2.2, to-y), (-2.2 - head-rise, to-y - sign * head-len), stroke: 0.8pt + clr)
      }
      if kind == "equilibrium-filled" {
        let right-base = from-y + sign * head-len
        line((2.2, to-y), (2.2, from-y), stroke: 0.8pt + clr)
        line(
          (2.2, from-y), (2.2, right-base), (2.2 + head-rise, right-base),
          close: true, fill: clr, stroke: none,
        )
      } else {
        line((2.2, to-y), (2.2, from-y), stroke: 0.8pt + clr)
        line((2.2, from-y), (2.2 + head-rise, from-y + sign * head-len), stroke: 0.8pt + clr)
      }
    } else {
      panic("rxn-arrow kind must be \"single\", \"equilibrium\", \"equilibrium-filled\", \"dashed\", or \"wavy\"")
    }
  })
  if above == none and below == none {
    align(center + horizon, arrow-canvas)
  } else {
    let right-label = if above != none { text(size: 8pt, above) } else { [] }
    let left-label = if below != none { text(size: 8pt, below) } else { [] }
    let right-w = if above != none { measure(right-label).width } else { 0pt }
    let left-w = if below != none { measure(left-label).width } else { 0pt }
    let side-w = calc.max(left-w, right-w)
    grid(
      columns: (side-w, auto, side-w),
      column-gutter: 4pt,
      align: center + horizon,
      box(width: side-w, align(right + horizon, left-label)),
      arrow-canvas,
      box(width: side-w, align(left + horizon, right-label)),
    )
  }
}

/// A reaction-scheme item: a molecule or any content, with an optional label and
/// position offset. Consumed by #reaction().
///
/// - spec (str / content): A SMILES string (rendered by #reaction with addressable
///   atoms) or any content (e.g. ce(...), smiles(...), text — an opaque block).
/// - label (content): Optional label shown below. Default: none.
/// - offset (array): (dx, dy) page-axis nudge in bond-length units. Positive x
///   moves right and positive y moves up, independent of reaction flow.
/// - ..opts: Molecule drawing options used when `spec` is a string. In mechanism
///   mode, use `reaction(scale: ...)` for bond length; per-molecule options control
///   labels, strokes, colors, rotation, mirroring, hydrogens, lone pairs, opacity,
///   bond customizations, and index overlays.
/// -> dictionary  (consumed by #reaction)
#let mol(spec, label: none, offset: (0, 0), ..opts) = (
  __mol__: true,
  spec: spec,
  label: label,
  offset: offset,
  opts: opts.named(),
)

// Render a mol() item to standalone content (scheme/grid path).
#let _render-mol(m, show-indices-default: false, offset-unit: 30pt) = {
  let opts = m.opts
  if type(m.spec) == str and not ("show-indices" in opts) {
    opts.insert("show-indices", show-indices-default)
  }
  let body = if type(m.spec) == str { smiles(m.spec, ..opts) } else { m.spec }
  let rendered = if m.label == none { body } else { stack(spacing: 4pt, body, align(center, m.label)) }
  if m.offset == (0, 0) {
    rendered
  } else {
    move(dx: m.offset.at(0) * offset-unit, dy: -m.offset.at(1) * offset-unit, rendered)
  }
}

/// Lays out a reaction scheme or an electron-pushing mechanism.
///
/// Items are any mix of mol(), content (smiles(), ce(), text…), rxn-arrow()
/// (straight reaction arrows) and — for mechanisms — arrow() (curly electron
/// arrows) and highlight() items.
///
/// Two modes are detected automatically:
///  - Scheme (default): no curly arrow()/highlight(). Items are packed in a grid;
///    rxn-arrow(dir: "right"|"left"|"down"|"up") can wrap the scheme across the
///    page. mol(offset:) nudges content in page coordinates inside its grid cell.
///  - Mechanism: any curly arrow()/highlight(). Species are placed in one shared
///    canvas (left to right, each nudged by its offset) so curly arrows can
///    reference atoms across species. References are atom(s, i),
///    bond(s, i, j), lp(s, i) and species(k), where s/k count mol()/content items in
///    written order (rxn-arrows and annotations are not counted).
///
/// - gap-h (length): Horizontal gap between grid items (scheme mode). Default: 1.5em.
/// - gap-v (length): Vertical gap between grid items (scheme mode). Default: 1.5em.
/// - scale (float): Uniform scale. In mechanism mode it sets the canvas bond length.
/// - breakable (bool): Whether the block may split across pages. Default: false.
/// - show-indices (bool): Default index overlay for string SMILES molecules in
///   this reaction. Individual mol(..., show-indices: ...) calls can override it.
/// -> content
#let reaction(gap-h: 1.5em, gap-v: 1.5em, scale: 1.0, breakable: false, show-indices: false, flow: "right", ..items) = {
  if flow not in ("right", "left", "up", "down") {
    panic("reaction flow must be \"right\", \"left\", \"up\", or \"down\"")
  }
  let steps = items.pos()
  let is-rxn-arrow(it) = type(it) == dictionary and it.at("__rxn_arrow__", default: false)
  let is-curly(it)     = type(it) == dictionary and it.at("__arrow__", default: false)
  let is-highlight(it) = type(it) == dictionary and it.at("__highlight__", default: false)
  let is-mol(it)       = type(it) == dictionary and it.at("__mol__", default: false)

  // An `auto` arrow follows the flow: horizontal flows lay out with rightward
  // arrows (mirrored to point left below), vertical flows with downward ones.
  let base-dir = if flow == "right" or flow == "left" { "right" } else { "down" }
  steps = steps.map(it => {
    if is-rxn-arrow(it) and it.at("dir", default: auto) == auto {
      it + (dir: base-dir)
    } else { it }
  })

  let mechanism = steps.any(it => is-curly(it) or is-highlight(it))

  if not mechanism {
    // ── Scheme (grid) path ──────────────────────────────────────────────────
    // Phase 1: assign each item a (grid-row, grid-col) position.
    // Grid mapping: mol at (lr,lc) → grid (2*lr, 2*lc); arrows slot into gaps.
    let lr = 0
    let lc = 0
    let needs-advance = false
    let placed = ()

    let next-pos(r, c, dir) = {
      if dir == "right"      { (r, c + 1) }
      else if dir == "left"  { (r, c - 1) }
      else if dir == "down"  { (r + 1, c) }
      else                   { (r - 1, c) }
    }

    for item in steps {
      if is-rxn-arrow(item) {
        let dir = item.at("dir", default: "right")
        let (gr, gc) = if dir == "right"     { (2 * lr,     2 * lc + 1) }
                       else if dir == "left"  { (2 * lr,     2 * lc - 1) }
                       else if dir == "down"  { (2 * lr + 1, 2 * lc) }
                       else                   { (2 * lr - 1, 2 * lc) }
        placed.push((gr: gr, gc: gc, kind: "arrow", data: item))
        let pos = next-pos(lr, lc, dir)
        lr = pos.at(0)
        lc = pos.at(1)
        needs-advance = false
      } else {
        if needs-advance {
          let pos = next-pos(lr, lc, base-dir)
          lr = pos.at(0)
          lc = pos.at(1)
        }
        placed.push((gr: 2 * lr, gc: 2 * lc, kind: "mol", data: item))
        needs-advance = true
      }
    }

    if placed.len() == 0 { return [] }

    let min-gr = placed.fold(placed.first().gr, (m, c) => calc.min(m, c.gr))
    let min-gc = placed.fold(placed.first().gc, (m, c) => calc.min(m, c.gc))
    let max-gr = placed.fold(placed.first().gr, (m, c) => calc.max(m, c.gr))
    let max-gc = placed.fold(placed.first().gc, (m, c) => calc.max(m, c.gc))

    let n-rows = max-gr - min-gr + 1
    let n-cols = max-gc - min-gc + 1

    // A "left" or "up" flow lays the scheme out normally, then reflects it along
    // the flow axis and flips the affected arrowheads. The written order then
    // reads leaves-toward the reflected side — natural for a branch that grows
    // out of the left or bottom of a cycle.
    if flow == "left" or flow == "up" {
      let flip-h = ("right": "left", "left": "right")
      let flip-v = ("down": "up", "up": "down")
      placed = placed.map(p => {
        let np = p
        if flow == "left" {
          np.gc = min-gc + max-gc - p.gc
        } else {
          np.gr = min-gr + max-gr - p.gr
        }
        if p.kind == "arrow" {
          let d = p.data.at("dir", default: "right")
          let nd = if flow == "left" { flip-h.at(d, default: d) } else { flip-v.at(d, default: d) }
          np.data = p.data
          np.data.dir = nd
        }
        np
      })
    }

    let lookup = (:)
    for p in placed {
      lookup.insert(str(p.gr - min-gr) + "," + str(p.gc - min-gc), p)
    }

    let flat-cells = ()
    for gr in range(n-rows) {
      for gc in range(n-cols) {
        let p = lookup.at(str(gr) + "," + str(gc), default: none)
        if p == none {
          flat-cells.push([])
        } else if p.kind == "mol" {
          let c = if is-mol(p.data) {
            _render-mol(p.data, show-indices-default: show-indices)
          } else { p.data }
          flat-cells.push(align(center + horizon, c))
        } else {
          let item = p.data
          let d = item.at("dir", default: "right")
          let k = item.at("kind", default: "single")
          flat-cells.push(
            if d == "right" or d == "left" { _horiz-arrow(item.above, item.below, d, k, item.at("color", default: auto)) }
            else                           { _vert-arrow(item.above, item.below, d, k, item.at("color", default: auto)) }
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
  } else {
    // ── Mechanism (shared canvas) path ──────────────────────────────────────
    let canvas-scale = scale * 30pt
    let font-size = 11pt * scale
    let cfg = _annotation-cfg(canvas-scale, font-size, scale)
    let the-scale = scale // cetz.draw `scale` shadows the argument inside the canvas
    let gap = 1.0 // bond-length units between species

    context {
      let specs = ()       // referenceable items (mol/content), in species-index order
      let flow = ()        // positioned but non-referenceable content (rxn-arrows)
      let annotations = () // curly arrows and highlights
      let cursor = 0.0

      for it in steps {
        if is-curly(it) or is-highlight(it) {
          annotations.push(it)
        } else if is-rxn-arrow(it) {
          let body = if it.dir == "right" or it.dir == "left" {
            _horiz-arrow(it.above, it.below, it.dir, it.kind, it.at("color", default: auto))
          } else {
            _vert-arrow(it.above, it.below, it.dir, it.kind, it.at("color", default: auto))
          }
          let w = measure(body).width / canvas-scale
          flow.push((body: body, origin: (cursor + w / 2, 0)))
          cursor += w + gap
        } else {
          let m = if is-mol(it) {
            it
          } else {
            (__mol__: true, spec: it, label: none, offset: (0, 0), opts: (:))
          }
          if type(m.spec) == str {
            let lay = _mirror-layout(
              _layout(m.spec),
              m.opts.at("mirror", default: none),
              rotation: m.opts.at("rotation", default: 0deg),
            )
            let w = lay.bbox_width
            let h = lay.bbox_height
            let mol-fs = m.opts.at("font-size", default: none)
            let mol-actual-fs = if mol-fs == none { 11pt * scale } else { mol-fs }
            specs.push((
              kind: "mol-smiles",
              layout: lay,
              rotation: m.opts.at("rotation", default: 0deg),
              origin: (cursor + w / 2 + m.offset.at(0), m.offset.at(1)),
              size: (w, h),
              label: m.label,
              opts: m.opts,
              canvas-scale: canvas-scale,
              actual-font-size: mol-actual-fs,
              font: m.opts.at("font", default: "New Computer Modern"),
              show-h: m.opts.at("show-h", default: ()),
            ))
            cursor += w + gap
          } else {
            let meas = measure(m.spec)
            let w = meas.width / canvas-scale
            let h = meas.height / canvas-scale
            specs.push((
              kind: "content",
              body: m.spec,
              rotation: 0deg,
              origin: (cursor + w / 2 + m.offset.at(0), m.offset.at(1)),
              size: (w, h),
              label: m.label,
            ))
            cursor += w + gap
          }
        }
      }

      let canvas = cetz.canvas(length: canvas-scale, {
        import cetz.draw: *

        for a in annotations {
          if a.at("__highlight__", default: false) { _draw-highlight(a, specs, cfg) }
        }

        for sp-idx in range(specs.len()) {
          let sp = specs.at(sp-idx)
          if sp.kind == "mol-smiles" {
            group({
              translate((sp.origin.at(0), sp.origin.at(1)))
              let (mol-fg, mol-theme) = _resolve-fg-theme(
                sp.opts.at("fg", default: auto),
                sp.opts.at("theme", default: auto),
              )
              _draw-molecule(
                sp.layout,
                scale: the-scale,
                font-size: sp.opts.at("font-size", default: none),
                font: sp.opts.at("font", default: "New Computer Modern"),
                bond-stroke: sp.opts.at("bond-stroke", default: none),
                color: sp.opts.at("color", default: true),
                rotation: sp.rotation,
                show-h: sp.opts.at("show-h", default: ()),
                lone-pairs: sp.opts.at("lone-pairs", default: none),
                atom-colors: sp.opts.at("atom-colors", default: (:)),
                show-indices: sp.opts.at("show-indices", default: show-indices),
                index-prefix: "species-" + str(sp-idx) + "-",
                fg: mol-fg,
                theme: mol-theme,
                aromatic: sp.opts.at("aromatic", default: "kekule"),
                atom-annotations: sp.opts.at("atom-annotations", default: ()),
                opacity: sp.opts.at("opacity", default: 100%),
                bond-customizations: sp.opts.at("bond-customizations", default: ()),
              )
            })
          } else {
            content((sp.origin.at(0), sp.origin.at(1)), sp.body, anchor: "center")
          }
        }

        for f in flow {
          content((f.origin.at(0), f.origin.at(1)), f.body, anchor: "center")
        }

        for sp in specs {
          if sp.label != none {
            content(
              (sp.origin.at(0), sp.origin.at(1) - sp.size.at(1) / 2 - 0.34),
              sp.label,
              anchor: "north",
            )
          }
        }

        for a in annotations {
          if a.at("__arrow__", default: false) { _draw-arrow(a, specs, cfg) }
        }
      })

      block(breakable: breakable, canvas)
    }
  }
}

// ── Catalytic cycle ───────────────────────────────────────────────────────────

/// A transformation between two species on a catalytic cycle, consumed by
/// #cycle(). Steps alternate with the species (mol()/content) items: the k-th
/// step is the arc from the k-th species to the next one around the ring.
///
/// - label (content): Name of the transformation, placed outside the arc.
/// - into (str / content): A reagent entering at this arc (drawn outside the
///   ring with a small merging arrow pointing inward), e.g. ce("H2") or a
///   mol()/smiles(). Default: none.
/// - out (str / content): A product leaving at this arc (drawn outside the ring
///   with an arrow pointing outward). Any content works, including a nested
///   reaction() to continue a branch from the released molecule. Default: none.
/// - bend (auto / float): Curvature of this step's into/out side arrow. `0`
///   is nearly radial; positive values bow with the cycle direction, negative
///   values flip the bow. Default: auto (uses cycle's reagent-bend).
/// - merge (bool): Draw the into/out arrow tangent to the arc, so it visually
///   fuses with the main cycle arrow instead of pointing at it. Default: false.
/// - rotation ("straight" / "auto" / angle): Cycle label rotation. "auto"
///   follows the step's circle angle while keeping text upright. Default: "straight".
/// - label-offset (array): (dx, dy) nudge for the label, in bond-length units.
/// - into-offset (array): (dx, dy) nudge for the into reagent and its arrow.
/// - out-offset (array): (dx, dy) nudge for the out reagent and its arrow.
/// -> dictionary  (consumed by #cycle)
#let step(
  label: none, into: none, out: none, bend: auto, merge: false, rotation: "straight",
  label-offset: (0, 0), into-offset: (0, 0), out-offset: (0, 0),
) = (
  __cycle_step__: true,
  label: label,
  into: into,
  out: out,
  bend: bend,
  merge: merge,
  rotation: rotation,
  label-offset: label-offset,
  into-offset: into-offset,
  out-offset: out-offset,
)

// Render a reagent spec (SMILES string or content) to content, for the small
// molecules that feed into or out of a cycle arc.
#let _cycle-reagent(spec, scale) = {
  if spec == none { none }
  else if type(spec) == str { smiles(spec, scale: scale) }
  else { spec }
}

#let _upright-angle(angle) = {
  if calc.cos(angle) < 0 { angle + 180deg } else { angle }
}

#let _cycle-label-rotation(rotation, mid-ang, dir) = {
  if rotation == "straight" {
    0deg
  } else if rotation == "auto" {
    _upright-angle(mid-ang)
  } else if type(rotation) == angle {
    rotation
  } else {
    panic("step rotation must be \"straight\", \"auto\", or an angle")
  }
}

/// Lays out a catalytic cycle: species arranged on a circle with arc arrows
/// between them. Items alternate species and step()s, like #reaction()
/// alternates molecules and rxn-arrow()s, but the sequence closes into a ring
/// (the last step returns to the first species). Species are mol() items or any
/// content (SMILES strings are rendered by #smiles); a mol(label:) is drawn
/// under its species.
///
/// step(label:) names the transformation on an arc; step(into:) adds a reagent
/// merging into the arc from outside the ring, and step(out:) a product leaving
/// it. Because step(out:) accepts any content, passing a reaction() there grows
/// a full linear branch out of a released molecule.
///
/// - radius (auto / float): Ring radius in bond-length units. `auto` fits the
///   species without overlap. Default: auto.
/// - start (angle): Angle of the first species (0deg is east, 90deg north).
///   Default: 90deg.
/// - clockwise (bool): Travel direction around the ring. Default: true.
/// - scale (float): Uniform scale; sets the canvas bond length. Default: 1.0.
/// - reagent-scale (float): Scale of into/out reagents relative to `scale`.
///   Default: 0.8.
/// - reagent-bend (float): Default curvature of into/out side arrows. `0`
///   is nearly radial. Default: 0.12.
/// - arc-gap (float): Clearance between a molecule and the arc-arrow ends, in
///   bond-length units beyond the molecule's radius. Smaller (even negative)
///   brings arrows closer to the species. Default: 0.15.
/// - arrow-color (color): Arc and merge arrow color. Default: black.
/// - label-color (auto / color): Step label color. Default: the maroon accent.
/// - breakable (bool): Whether the block may split across pages. Default: false.
/// - ..items: Species (mol()/content) and step()s in ring order.
/// -> content
#let cycle(
  radius: auto,
  start: 90deg,
  clockwise: true,
  scale: 1.0,
  reagent-scale: 0.8,
  reagent-bend: 0.12,
  arc-gap: 0.15,
  arrow-color: black,
  label-color: rgb("#8B2942"),
  breakable: false,
  ..items,
) = {
  let steps-in = items.pos()
  let is-step(it) = type(it) == dictionary and it.at("__cycle_step__", default: false)
  let is-mol(it)  = type(it) == dictionary and it.at("__mol__", default: false)

  // Split into species (in ring order) and the step that follows each species.
  let species = ()
  let arc-steps = ()
  for it in steps-in {
    if is-step(it) {
      if arc-steps.len() < species.len() {
        arc-steps.push(it)
      }
    } else {
      // Pad a missing step for the previous species before starting a new one.
      while arc-steps.len() < species.len() {
        arc-steps.push(step())
      }
      species.push(it)
    }
  }
  while arc-steps.len() < species.len() { arc-steps.push(step()) }

  let n = species.len()
  if n == 0 { return [] }

  let canvas-scale = scale * 30pt
  let mol-scale = scale
  let step-ang = 360deg / n
  let dir = if clockwise { -1 } else { 1 }
  let angle-of(i) = start + dir * i * step-ang

  context {
    // Measure each species so the ring can be sized and molecules centered.
    let placed = ()
    let max-diag = 0.0
    for sp in species {
      let m = if is-mol(sp) { sp } else { (__mol__: true, spec: sp, label: none, offset: (0, 0), opts: (:)) }
      let (w, h, kind, payload) = if type(m.spec) == str {
        let lay = _mirror-layout(
          _layout(m.spec),
          m.opts.at("mirror", default: none),
          rotation: m.opts.at("rotation", default: 0deg),
        )
        (lay.bbox_width, lay.bbox_height, "mol", lay)
      } else {
        let meas = measure(m.spec)
        (meas.width / canvas-scale, meas.height / canvas-scale, "content", m.spec)
      }
      max-diag = calc.max(max-diag, calc.sqrt(w * w + h * h))
      placed.push((m: m, w: w, h: h, kind: kind, payload: payload))
    }

    // Fit the ring: adjacent species centers must clear their bounding boxes.
    let r = if radius != auto {
      radius
    } else if n == 1 {
      0.0
    } else {
      calc.max(2.0, (max-diag + 1.1) / (2 * calc.sin(calc.pi / n)))
    }

    let pt(ang, rad) = (rad * calc.cos(ang), rad * calc.sin(ang))
    let shift(p, by) = (p.at(0) + by.at(0), p.at(1) + by.at(1))
    // Per-species angular clearance: an arc retreats from each molecule by that
    // molecule's own reach in the tangential (arc-approach) direction, plus
    // arc-gap. This keeps the visible gap uniform whether a wide molecule sits
    // at the top (approached across its width) or the side (across its height).
    let clearance-at(i) = if r > 0.01 {
      let p = placed.at(i)
      let a = angle-of(i)
      let reach = (p.w / 2) * calc.abs(calc.sin(a)) + (p.h / 2) * calc.abs(calc.cos(a))
      calc.min(step-ang * 0.45, calc.max(0deg, 1.0rad * (reach + arc-gap) / r))
    } else { 0deg }

    let canvas = cetz.canvas(length: canvas-scale, {
      import cetz.draw: *

      // Arc arrows between consecutive species, with labels and reagents.
      for i in range(n) {
        let a0 = angle-of(i)
        let a1 = angle-of(i + 1)
        let st = arc-steps.at(i)
        let from-ang = a0 + dir * clearance-at(i)
        let to-ang = a1 - dir * clearance-at(calc.rem(i + 1, n))
        let n-seg = 24
        let pts = range(n-seg + 1).map(k => {
          let ang = from-ang + (to-ang - from-ang) * (k / n-seg)
          pt(ang, r)
        })
        line(
          ..pts,
          mark: (end: ">", fill: arrow-color, size: 0.16),
          stroke: 0.9pt + arrow-color,
        )

        let mid-ang = a0 + dir * step-ang / 2
        let bend = if st.bend == auto { reagent-bend } else { st.bend }
        // Unit tangent along the arc's travel direction at its midpoint.
        let travel = (dir * -calc.sin(mid-ang), dir * calc.cos(mid-ang))
        if st.label != none {
          let has-reagent = st.into != none or st.out != none
          let label-r = if has-reagent and r > 1.3 { calc.max(0.55, r - 1.05) } else { r + 0.95 }
          let label-body = text(size: 9pt, fill: if label-color == auto { black } else { label-color }, st.label)
          let label-rotation = _cycle-label-rotation(st.rotation, mid-ang, dir)
          if label-rotation != 0deg {
            label-body = _typst-rotate(label-rotation, reflow: false, label-body)
          }
          content(
            shift(pt(mid-ang, label-r), st.label-offset),
            label-body,
            anchor: "center",
          )
        }

        // Metrics for an into/out reagent placed radially outward from the
        // arc, offset by its own measured extent so wide content (even a
        // nested reaction) clears the ring, then nudged by a per-step offset.
        // Pure: returns coords, draws nothing.
        let reagent-metrics(spec, extra) = {
          let body = _cycle-reagent(spec, mol-scale * reagent-scale)
          if body == none {
            none
          } else {
            let m = measure(body)
            let w = m.width / canvas-scale
            let h = m.height / canvas-scale
            let half = 0.5 * (calc.abs(w * calc.cos(mid-ang)) + calc.abs(h * calc.sin(mid-ang)))
            // Floor keeps small reagents at a fixed clearance; large content
            // (e.g. a nested reaction) is pushed out by its own extent.
            let dist = r + calc.max(2.05, 1.0 + half)
            (
              body: body,
              center: shift(pt(mid-ang, dist), extra),
              w: w,
              h: h,
            )
          }
        }

        let reagent-anchor-for(ang) = {
          let ux = calc.cos(ang)
          let uy = calc.sin(ang)
          let eps = 0.12
          let x = if ux > eps { "west" } else if ux < -eps { "east" } else { "" }
          let y = if uy > eps { "south" } else if uy < -eps { "north" } else { "" }
          if x != "" and y != "" { y + "-" + x }
          else if x != "" { x }
          else if y != "" { y }
          else { "center" }
        }

        let anchor-point(center, w, h, anchor) = {
          let x = center.at(0)
          let y = center.at(1)
          if anchor == "west" { (x - w / 2, y) }
          else if anchor == "east" { (x + w / 2, y) }
          else if anchor == "north" { (x, y + h / 2) }
          else if anchor == "south" { (x, y - h / 2) }
          else if anchor == "north-west" { (x - w / 2, y + h / 2) }
          else if anchor == "north-east" { (x + w / 2, y + h / 2) }
          else if anchor == "south-west" { (x - w / 2, y - h / 2) }
          else if anchor == "south-east" { (x + w / 2, y - h / 2) }
          else { center }
        }

        // Reagent merging in: arrow from the reagent toward the arc. In merge
        // mode the arrow ends on the arc pointing along the travel direction,
        // so it fuses with the main cycle arrow; otherwise it points radially.
        let into-m = reagent-metrics(st.into, st.into-offset)
        if into-m != none {
          let into-anchor = reagent-anchor-for(mid-ang)
          let into-attach = anchor-point(into-m.center, into-m.w, into-m.h, into-anchor)
          content(into-attach, into-m.body, anchor: into-anchor)
          if st.merge {
            // Fuse smoothly into the main arc: the curve arrives tangent to the
            // arc with no arrowhead, so it reads as one continuous stroke.
            let tip = pt(mid-ang, r)
            bezier(
              into-attach, tip, (tip.at(0) - travel.at(0) * 0.5, tip.at(1) - travel.at(1) * 0.5),
              stroke: 0.8pt + arrow-color,
            )
          } else {
            bezier(
              into-attach, pt(mid-ang, r + 0.28), pt(mid-ang + dir * step-ang * bend, r + 1.05),
              mark: (end: ">", fill: arrow-color, size: 0.14),
              stroke: 0.8pt + arrow-color,
            )
          }
        }

        // Product leaving: arrow from the arc outward to the reagent. In merge
        // mode it peels off the arc tangentially.
        let out-m = reagent-metrics(st.out, st.out-offset)
        if out-m != none {
          let out-anchor = reagent-anchor-for(mid-ang)
          let out-attach = anchor-point(out-m.center, out-m.w, out-m.h, out-anchor)
          content(out-attach, out-m.body, anchor: out-anchor)
          if st.merge {
            // Peel off the arc tangentially, keeping the arrowhead on the
            // departing product.
            let base = pt(mid-ang, r)
            bezier(
              base, out-attach, (base.at(0) + travel.at(0) * 0.5, base.at(1) + travel.at(1) * 0.5),
              mark: (end: ">", fill: arrow-color, size: 0.14),
              stroke: 0.8pt + arrow-color,
            )
          } else {
            bezier(
              pt(mid-ang, r + 0.28), out-attach, pt(mid-ang - dir * step-ang * bend, r + 1.05),
              mark: (end: ">", fill: arrow-color, size: 0.14),
              stroke: 0.8pt + arrow-color,
            )
          }
        }
      }

      // Species on the ring, drawn on top of the arcs.
      for i in range(n) {
        let p = placed.at(i)
        let center = pt(angle-of(i), r)
        if p.kind == "mol" {
          group({
            translate(center)
            let (mfg, mtheme) = _resolve-fg-theme(
              p.m.opts.at("fg", default: auto),
              p.m.opts.at("theme", default: auto),
            )
            _draw-molecule(
              p.payload,
              scale: mol-scale,
              font-size: p.m.opts.at("font-size", default: none),
              font: p.m.opts.at("font", default: "New Computer Modern"),
              bond-stroke: p.m.opts.at("bond-stroke", default: none),
              color: p.m.opts.at("color", default: true),
              rotation: p.m.opts.at("rotation", default: 0deg),
              show-h: p.m.opts.at("show-h", default: ()),
              lone-pairs: p.m.opts.at("lone-pairs", default: none),
              atom-colors: p.m.opts.at("atom-colors", default: (:)),
              show-indices: p.m.opts.at("show-indices", default: false),
              fg: mfg,
              theme: mtheme,
              aromatic: p.m.opts.at("aromatic", default: "kekule"),
              atom-annotations: p.m.opts.at("atom-annotations", default: ()),
              opacity: p.m.opts.at("opacity", default: 100%),
              bond-customizations: p.m.opts.at("bond-customizations", default: ()),
            )
          })
        } else {
          content(center, p.payload, anchor: "center")
        }
        if p.m.label != none {
          content((center.at(0), center.at(1) - p.h / 2 - 0.34), p.m.label, anchor: "north")
        }
      }
    })

    block(breakable: breakable, canvas)
  }
}

/// Wraps content in drawn square brackets, e.g. for a transition state or reactive
/// intermediate. `sup` / `sub` are typeset at the top-right / bottom-right (a charge,
/// a ‡ for a transition state, …).
///
/// - body (content): The content to enclose.
/// - sup (content): Optional superscript outside the right bracket. Default: none.
/// - sub (content): Optional subscript outside the right bracket. Default: none.
/// - stroke (stroke): Bracket stroke. Default: 0.6pt black.
/// - gap (length): Padding between the brackets and the body. Default: 0.3em.
/// -> content
#let brackets(body, sup: none, sub: none, stroke: 0.6pt + black, gap: 0.3em) = context {
  let body-height = measure(body).height
  let gp = gap.to-absolute()
  let tk = (0.18em).to-absolute()
  let total = body-height + 2 * gp
  let bstroke = stroke // cetz.draw exports `stroke`, which would shadow the argument
  let bracket(left) = {
    let dir = if left { 1 } else { -1 }
    box(height: total, cetz.canvas(length: 1pt, {
      import cetz.draw: *
      let hp = total / 1pt
      let tp = tk / 1pt
      line((dir * tp, 0), (0, 0), (0, hp), (dir * tp, hp), stroke: bstroke)
    }))
  }
  // Stack the marks against the closing bracket: sup pinned to the top corner,
  // sub to the bottom, by filling the bracket height.
  let supsub = if sup == none and sub == none {
    none
  } else {
    box(height: total, stack(
      dir: ttb,
      spacing: 1fr,
      if sup != none { box(text(size: 0.85em, sup)) } else { box() },
      if sub != none { box(text(size: 0.85em, sub)) } else { box() },
    ))
  }
  box(baseline: 50% + 0.3em)[#bracket(true)#h(gp)#box(baseline: 50% - body-height / 2, body)#h(gp)#bracket(false)#if supsub != none { h(0.12em); supsub }]
}
