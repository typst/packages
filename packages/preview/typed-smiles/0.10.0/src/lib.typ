// Typst SMILES Package
// Renders SMILES strings as 2D molecular structure diagrams via a WASM plugin.
// Also re-exports `ce` from chemformula for chemical formula notation.

#import "@preview/cetz:0.5.2"
#import "@preview/chemformula:0.1.3": ch

#let smiles-plugin = plugin("../plugin/typst_smiles_plugin.wasm")
#let _color-type = type(black)
#let _length-type = type(1pt)
#let _angle-type = type(1deg)
#let _stroke-type = type(1pt + black)
#let _content-type = type([])

// Public input failures use one message shape so editor diagnostics state the
// invalid value, the accepted form, and the correction at the call boundary.
#let _invalid-input(input-context, problem, correction) = {
  panic(
    "typed-smiles: "
      + input-context
      + " is invalid: "
      + problem
      + ". "
      + correction,
  )
}

#let _is-number(value) = type(value) == int or type(value) == float

#let _validate-number(value, input-context) = {
  if not _is-number(value) {
    _invalid-input(
      input-context,
      "expected a number, got " + repr(value),
      "Pass an integer or float.",
    )
  }
}

#let _validate-positive-number(value, input-context) = {
  _validate-number(value, input-context)
  if value <= 0 {
    _invalid-input(
      input-context,
      "expected a positive number, got " + repr(value),
      "Pass a value greater than zero.",
    )
  }
}

#let _validate-nonnegative-number(value, input-context) = {
  _validate-number(value, input-context)
  if value < 0 {
    _invalid-input(
      input-context,
      "expected a non-negative number, got " + repr(value),
      "Pass zero or a positive value.",
    )
  }
}

#let _validate-positive-length(value, input-context, allow-auto: false, allow-none: false) = {
  if (allow-auto and value == auto) or (allow-none and value == none) {
    return
  }
  if type(value) != _length-type or value <= 0pt {
    _invalid-input(
      input-context,
      "expected a positive length, got " + repr(value),
      "Pass a length greater than 0pt.",
    )
  }
}

#let _validate-nonnegative-length(value, input-context) = {
  if type(value) != _length-type or value < 0pt {
    _invalid-input(
      input-context,
      "expected a non-negative length, got " + repr(value),
      "Pass 0pt or a positive length.",
    )
  }
}

#let _validate-bool(value, input-context) = {
  if type(value) != bool {
    _invalid-input(
      input-context,
      "expected true or false, got " + repr(value),
      "Pass a boolean value.",
    )
  }
}

#let _validate-offset(offset, input-context) = {
  if type(offset) != array or offset.len() != 2 {
    _invalid-input(
      input-context,
      "expected a two-number array, got " + repr(offset),
      "Pass an offset such as (0.1, -0.2).",
    )
  }
  for coordinate in offset {
    if not _is-number(coordinate) {
      _invalid-input(
        input-context,
        "expected two numbers, got " + repr(offset),
        "Pass an offset such as (0.1, -0.2).",
      )
    }
  }
}

#let _validate-index(index, input-context) = {
  if type(index) != int or index < 0 {
    _invalid-input(
      input-context,
      "expected a non-negative integer, got " + repr(index),
      "Use an index shown by show-indices: true.",
    )
  }
}

#let _available-index-description(count) = {
  if count == 0 {
    "There are no valid indices."
  } else if count == 1 {
    "The only valid index is 0."
  } else {
    "Valid indices are 0 through " + str(count - 1) + "."
  }
}

#let _validate-named-arguments(arguments, allowed, input-context) = {
  for argument-name in arguments.named().keys() {
    if argument-name not in allowed {
      _invalid-input(
        input-context + " argument " + repr(argument-name),
        "the argument is not supported",
        "Supported named arguments are "
          + allowed.map(name => repr(name)).join(", ")
          + ".",
      )
    }
  }
}

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

// Rendered position of an atom after molecular rotation and an optional
// page-space displacement declared by a custom abbreviation label. The
// displacement lives outside the layout data so it cannot influence placement.
#let _rendered-atom-position(atom, rotation, scale: 1.0) = {
  let rotated-x = (
    atom.pos.x * calc.cos(rotation) - atom.pos.y * calc.sin(rotation)
  ) * scale
  let rotated-y = (
    atom.pos.x * calc.sin(rotation) + atom.pos.y * calc.cos(rotation)
  ) * scale
  (
    x: rotated-x + atom.at("abbrev_offset_x", default: 0.0) * scale,
    y: rotated-y + atom.at("abbrev_offset_y", default: 0.0) * scale,
  )
}

#let _normalize-show-h(show-h) = {
  if show-h == "all" {
    (all: true, indices: ())
  } else if type(show-h) == array {
    for atom-index in show-h {
      _validate-index(atom-index, "show-h atom index")
    }
    (all: false, indices: show-h)
  } else if type(show-h) == int {
    _validate-index(show-h, "show-h atom index")
    (all: false, indices: (show-h,))
  } else {
    _invalid-input(
      "show-h",
      "expected \"all\", an atom index, or an array of atom indices, got "
        + repr(show-h),
      "Use \"all\", 2, or (0, 2), for example.",
    )
  }
}

#let _normalize-atom-annotations(atom-annotations) = {
  if type(atom-annotations) != array {
    panic("atom-annotations must be an array of (index, content) or (index, content, offset) tuples")
  }

  let normalized-annotations = ()
  for entry in atom-annotations {
    if type(entry) != array or (entry.len() != 2 and entry.len() != 3) {
      panic("atom-annotations entries must be (index, content) or (index, content, offset)")
    }
    _validate-index(entry.at(0), "atom-annotations atom index")
    if entry.len() == 3 {
      _validate-offset(entry.at(2), "atom-annotations offset")
    }
    normalized-annotations.push((
      index: entry.at(0),
      body: entry.at(1),
      offset: if entry.len() == 3 { entry.at(2) } else { (0, 0) },
    ))
  }
  normalized-annotations
}

// An opacity value is a ratio (40%) or a number in 0..1; both normalize to a
// ratio so color.transparentize can consume it.
#let _opacity-ratio(opacity, what) = {
  let normalized = if type(opacity) == ratio {
    opacity
  } else if type(opacity) == int or type(opacity) == float {
    opacity * 100%
  } else {
    _invalid-input(
      what,
      "expected a ratio or a number from 0 to 1, got " + repr(opacity),
      "Use a value such as 40% or 0.4.",
    )
  }
  if normalized < 0% or normalized > 100% {
    _invalid-input(
      what,
      "expected a value from 0% to 100%, got " + repr(opacity),
      "Use a ratio such as 40% or a number from 0 to 1.",
    )
  }
  normalized
}

// Per-bond style overrides: a list of (bond(i, j), (..options..)) pairs, with
// a plain (i, j) array accepted in place of the bond() reference. Normalizes
// to a dictionary keyed by the sorted atom-index pair.
#let _normalize-bond-customizations(bond-customizations, layout: none) = {
  if type(bond-customizations) != array {
    panic("bond-customizations must be an array of (bond(i, j), (..options..)) pairs")
  }
  let normalized-customizations = (:)
  for entry in bond-customizations {
    if type(entry) != array or entry.len() != 2 {
      panic("bond-customizations entries must be (bond(i, j), (..options..)) pairs")
    }
    let (bond-reference, options) = (entry.at(0), entry.at(1))
    let (first-atom-index, second-atom-index) = if type(bond-reference) == dictionary and bond-reference.at("__ref__", default: "") == "bond" {
      (bond-reference.i, bond-reference.j)
    } else if type(bond-reference) == array and bond-reference.len() == 2 {
      (bond-reference.at(0), bond-reference.at(1))
    } else {
      panic("bond-customizations bonds must be bond(i, j) references or (i, j) pairs")
    }
    _validate-index(first-atom-index, "bond-customizations first atom index")
    _validate-index(second-atom-index, "bond-customizations second atom index")
    if first-atom-index == second-atom-index {
      _invalid-input(
        "bond-customizations bond reference",
        "both endpoints use atom index " + str(first-atom-index),
        "Reference two different atoms joined by a visible bond.",
      )
    }
    if layout != none {
      let atom-count = layout.atoms.len()
      if first-atom-index >= atom-count {
        _invalid-input(
          "bond-customizations first atom index",
          str(first-atom-index) + " does not exist",
          _available-index-description(atom-count),
        )
      }
      if second-atom-index >= atom-count {
        _invalid-input(
          "bond-customizations second atom index",
          str(second-atom-index) + " does not exist",
          _available-index-description(atom-count),
        )
      }
      let matching-bonds = layout.bonds.filter(bond-output => (
        not bond-output.at("virtual_bond", default: false)
          and (
            (
              bond-output.from == first-atom-index
                and bond-output.to == second-atom-index
            )
              or (
                bond-output.from == second-atom-index
                  and bond-output.to == first-atom-index
              )
          )
      ))
      if matching-bonds.len() == 0 {
        _invalid-input(
          "bond-customizations bond reference",
          "atoms "
            + str(first-atom-index)
            + " and "
            + str(second-atom-index)
            + " are not joined by a visible bond",
          "Use show-indices: true and reference the two endpoints of an existing bond.",
        )
      }
    }
    if type(options) != dictionary {
      panic("bond-customizations options must be a dictionary")
    }
    for option-name in options.keys() {
      if option-name not in ("color", "stroke", "opacity") {
        panic("unknown bond customization \"" + option-name + "\" (expected color, stroke, or opacity)")
      }
    }
    if "color" in options and type(options.color) != _color-type {
      panic("bond customization color must be a color")
    }
    if "stroke" in options and type(options.stroke) != _length-type {
      panic("bond customization stroke must be a length (the bond width)")
    }
    if "stroke" in options {
      _validate-positive-length(options.stroke, "bond customization stroke")
    }
    if "opacity" in options {
      options.insert("opacity", _opacity-ratio(options.opacity, "bond customization opacity"))
    }
    let customization-key = (
      str(calc.min(first-atom-index, second-atom-index))
        + "-"
        + str(calc.max(first-atom-index, second-atom-index))
    )
    if customization-key in normalized-customizations {
      _invalid-input(
        "bond-customizations",
        "bond "
          + str(first-atom-index)
          + "-"
          + str(second-atom-index)
          + " is customized more than once",
        "Combine its color, stroke, and opacity into one entry.",
      )
    }
    normalized-customizations.insert(customization-key, options)
  }
  normalized-customizations
}

#let _element-symbols = (
  "H", "He", "Li", "Be", "B", "C", "N", "O", "F", "Ne", "Na", "Mg",
  "Al", "Si", "P", "S", "Cl", "Ar", "K", "Ca", "Sc", "Ti", "V", "Cr",
  "Mn", "Fe", "Co", "Ni", "Cu", "Zn", "Ga", "Ge", "As", "Se", "Br",
  "Kr", "Rb", "Sr", "Y", "Zr", "Nb", "Mo", "Tc", "Ru", "Rh", "Pd",
  "Ag", "Cd", "In", "Sn", "Sb", "Te", "I", "Xe", "Cs", "Ba", "La",
  "Ce", "Pr", "Nd", "Pm", "Sm", "Eu", "Gd", "Tb", "Dy", "Ho", "Er",
  "Tm", "Yb", "Lu", "Hf", "Ta", "W", "Re", "Os", "Ir", "Pt", "Au",
  "Hg", "Tl", "Pb", "Bi", "Po", "At", "Rn", "Fr", "Ra", "Ac", "Th",
  "Pa", "U", "Np", "Pu", "Am", "Cm", "Bk", "Cf", "Es", "Fm", "Md",
  "No", "Lr", "Rf", "Db", "Sg", "Bh", "Hs", "Mt", "Ds", "Rg", "Cn",
  "Nh", "Fl", "Mc", "Lv", "Ts", "Og",
)

#let _validate-atom-colors(atom-colors) = {
  if type(atom-colors) != dictionary {
    _invalid-input(
      "atom-colors",
      "expected a dictionary, got " + repr(atom-colors),
      "Use a dictionary such as (O: red, \"{PPh3}\": purple).",
    )
  }
  for (key, paint) in atom-colors {
    if type(paint) != _color-type {
      _invalid-input(
        "atom-colors entry " + repr(key),
        "expected a color, got " + repr(paint),
        "Assign a Typst color value.",
      )
    }
    let label-key = key.starts-with("{") and key.ends-with("}") and key.len() > 2
    if key not in _element-symbols and not label-key {
      _invalid-input(
        "atom-colors key " + repr(key),
        "expected an element symbol or a brace-quoted custom label",
        "Use a key such as O or \"{PPh3}\".",
      )
    }
  }
}

#let _validate-molecule-options(
  layout,
  scale,
  bond-length,
  font-size,
  font,
  bond-stroke,
  color,
  rotation,
  show-h,
  lone-pairs,
  atom-colors,
  show-indices,
  fg,
  theme,
  aromatic,
  atom-annotations,
  opacity,
  bond-customizations,
) = {
  _validate-positive-number(scale, "smiles scale")
  if bond-length != none {
    _validate-positive-number(bond-length, "smiles bond-length")
  }
  _validate-positive-length(
    font-size,
    "smiles font-size",
    allow-none: true,
  )
  if type(font) != str and type(font) != array {
    _invalid-input(
      "smiles font",
      "expected a font name or array of font names, got " + repr(font),
      "Pass a font such as \"New Computer Modern\".",
    )
  }
  _validate-positive-length(
    bond-stroke,
    "smiles bond-stroke",
    allow-none: true,
  )
  _validate-bool(color, "smiles color")
  if type(rotation) != _angle-type {
    _invalid-input(
      "smiles rotation",
      "expected an angle, got " + repr(rotation),
      "Pass an angle such as 30deg.",
    )
  }
  let show-h-state = _normalize-show-h(show-h)
  for atom-index in show-h-state.indices {
    if atom-index >= layout.atoms.len() {
      _invalid-input(
        "show-h atom index",
        str(atom-index) + " does not exist",
        _available-index-description(layout.atoms.len()),
      )
    }
    if layout.atoms.at(atom-index).at("virtual_h", default: false) {
      _invalid-input(
        "show-h atom index",
        str(atom-index) + " is an explicit bracket-hydrogen fragment",
        "Reference its parent atom instead.",
      )
    }
  }
  if lone-pairs != none and lone-pairs not in ("dots", "lines") {
    _invalid-input(
      "lone-pairs",
      "expected none, \"dots\", or \"lines\", got " + repr(lone-pairs),
      "Choose one of the supported lone-pair styles.",
    )
  }
  _validate-atom-colors(atom-colors)
  _validate-bool(show-indices, "show-indices")
  if type(fg) != _color-type {
    _invalid-input(
      "smiles foreground",
      "expected a color, got " + repr(fg),
      "Pass a Typst color or use fg: auto at the public call.",
    )
  }
  if theme not in ("light", "dark") {
    _invalid-input(
      "smiles theme",
      "expected \"light\" or \"dark\", got " + repr(theme),
      "Choose one of the supported palette themes.",
    )
  }
  if aromatic not in ("kekule", "circle") {
    _invalid-input(
      "aromatic",
      "expected \"kekule\" or \"circle\", got " + repr(aromatic),
      "Choose one of the supported aromatic rendering styles.",
    )
  }
  let normalized-annotations = _normalize-atom-annotations(atom-annotations)
  for annotation in normalized-annotations {
    if annotation.index >= layout.atoms.len() {
      _invalid-input(
        "atom-annotations atom index",
        str(annotation.index) + " does not exist",
        _available-index-description(layout.atoms.len()),
      )
    }
    if layout.atoms.at(annotation.index).at("virtual_h", default: false) {
      _invalid-input(
        "atom-annotations atom index",
        str(annotation.index) + " is an explicit bracket-hydrogen fragment",
        "Reference its parent atom instead.",
      )
    }
  }
  let _ = _opacity-ratio(opacity, "opacity")
  let _ = _normalize-bond-customizations(
    bond-customizations,
    layout: layout,
  )
}

// CPK hues bright enough to read on either background keep one value; the
// dark theme lifts the lightness of the hues that vanish on dark slides
// (N, Br, I; O slightly) without changing their identity.
#let _atom-color(symbol, theme: "light", fg: black) = {
  let dark = theme == "dark"
  if symbol == "N" or symbol == "n"      { if dark { rgb("#7A8CFF") } else { rgb("#3050F8") } }
  else if symbol == "O" or symbol == "o" { if dark { rgb("#FF5252") } else { rgb("#FF0D0D") } }
  else if symbol == "S" or symbol == "s" { rgb("#E6C800") }
  else if symbol == "P"                  { rgb("#FF8000") }
  else if symbol == "F"                  { rgb("#90E050") }
  else if symbol == "Cl"                 { rgb("#1FF01F") }
  else if symbol == "Br"                 { if dark { rgb("#D07C7C") } else { rgb("#A62929") } }
  else if symbol == "I"                  { if dark { rgb("#DC7CDC") } else { rgb("#940094") } }
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
#let _resolve-foreground-theme(fg, theme) = {
  if fg != auto and type(fg) != _color-type {
    _invalid-input(
      "foreground",
      "expected auto or a color, got " + repr(fg),
      "Use fg: auto or pass a Typst color.",
    )
  }
  let resolved-fg = if fg == auto {
    if type(text.fill) == _color-type { text.fill } else { black }
  } else { fg }
  let resolved-theme = if theme == auto {
    if type(resolved-fg) == _color-type and oklab(resolved-fg).components().at(0) > 60% {
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
#let _compute-layout(smiles-str) = {
  if type(smiles-str) != str {
    _invalid-input(
      "SMILES expression",
      "expected a string, got " + repr(smiles-str),
      "Pass a SMILES string such as \"CCO\".",
    )
  }
  if smiles-str.trim() == "" {
    _invalid-input(
      "SMILES expression",
      "the string is empty",
      "Pass at least one atom, such as \"C\".",
    )
  }
  json(smiles-plugin.layout(bytes(smiles-str)))
}

/// Computes the molecular weight of a SMILES string in g/mol, summing IUPAC
/// standard atomic weights over all atoms including implicit and explicit
/// hydrogens. Errors on input whose mass is undefined: wildcard `*` atoms,
/// `{label}` abbreviations, and isotope-labeled atoms.
///
/// - smiles-str (str): A valid SMILES string, e.g. "CCO".
/// -> float
#let mol-weight(smiles-str) = {
  if type(smiles-str) != str {
    _invalid-input(
      "mol-weight SMILES expression",
      "expected a string, got " + repr(smiles-str),
      "Pass a SMILES string such as \"CCO\".",
    )
  }
  if smiles-str.trim() == "" {
    _invalid-input(
      "mol-weight SMILES expression",
      "the string is empty",
      "Pass at least one atom, such as \"C\".",
    )
  }
  json(smiles-plugin.mol_weight(bytes(smiles-str)))
}

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
  let rotation-cosine = calc.cos(rotation)
  let rotation-sine = calc.sin(rotation)
  let multiply-matrices(left, right) = (
    xx: left.xx * right.xx + left.xy * right.yx,
    xy: left.xx * right.xy + left.xy * right.yy,
    yx: left.yx * right.xx + left.yy * right.yx,
    yy: left.yx * right.xy + left.yy * right.yy,
  )
  let coordinate-normalization = (xx: -1.0, xy: 0.0, yx: 0.0, yy: 1.0)
  let transformation = if mirror == none {
    coordinate-normalization
  } else {
    let rotation-matrix = (xx: rotation-cosine, xy: -rotation-sine, yx: rotation-sine, yy: rotation-cosine)
    let inverse-rotation = (xx: rotation-cosine, xy: rotation-sine, yx: -rotation-sine, yy: rotation-cosine)
    let screen-reflection = if mirror == "horizontal" {
      (xx: -1.0, xy: 0.0, yx: 0.0, yy: 1.0)
    } else {
      (xx: 1.0, xy: 0.0, yx: 0.0, yy: -1.0)
    }
    multiply-matrices(
      multiply-matrices(
        multiply-matrices(inverse-rotation, screen-reflection),
        rotation-matrix,
      ),
      coordinate-normalization,
    )
  }
  if transformation.xx == 1.0 and transformation.xy == 0.0 and transformation.yx == 0.0 and transformation.yy == 1.0 {
    return layout
  }
  let flip-stereobond(stereobond) = {
    if stereobond == "wedge_up" { "wedge_down" }
    else if stereobond == "wedge_down" { "wedge_up" }
    else { stereobond }
  }
  let transform-point(x, y) = (
    x: transformation.xx * x + transformation.xy * y,
    y: transformation.yx * x + transformation.yy * y,
  )
  let determinant = (
    transformation.xx * transformation.yy
      - transformation.xy * transformation.yx
  )
  let flips-handedness = determinant < 0.0
  let mirrored-layout = layout
  mirrored-layout.atoms = layout.atoms.map(atom => {
    let transformed-atom = atom
    transformed-atom.pos = transform-point(atom.pos.x, atom.pos.y)
    if "lone_pair_dirs" in atom {
      transformed-atom.lone_pair_dirs = atom.lone_pair_dirs.map(direction => (
        transform-point(direction.x, direction.y)
      ))
    }
    if "stereo_h_dir" in atom {
      transformed-atom.stereo_h_dir = transform-point(atom.stereo_h_dir.x, atom.stereo_h_dir.y)
    }
    if flips-handedness and "stereo_h" in atom {
      transformed-atom.stereo_h = flip-stereobond(atom.stereo_h)
    }
    transformed-atom
  })
  mirrored-layout.bonds = layout.bonds.map(bond-output => {
    let transformed-bond = bond-output
    let inner-direction = transform-point(bond-output.inner_x, bond-output.inner_y)
    transformed-bond.inner_x = inner-direction.x
    transformed-bond.inner_y = inner-direction.y
    if flips-handedness {
      transformed-bond.stereo = flip-stereobond(bond-output.stereo)
    }
    transformed-bond
  })
  if "aromatic_rings" in layout {
    mirrored-layout.aromatic_rings = layout.aromatic_rings.map(ring => {
      let transformed-ring = ring
      transformed-ring.center = transform-point(ring.center.x, ring.center.y)
      transformed-ring
    })
  }
  if mirrored-layout.atoms.len() > 0 {
    let first-position = mirrored-layout.atoms.first().pos
    let min-x = mirrored-layout.atoms.fold(
      first-position.x,
      (minimum, atom) => calc.min(minimum, atom.pos.x),
    )
    let max-x = mirrored-layout.atoms.fold(
      first-position.x,
      (maximum, atom) => calc.max(maximum, atom.pos.x),
    )
    let min-y = mirrored-layout.atoms.fold(
      first-position.y,
      (minimum, atom) => calc.min(minimum, atom.pos.y),
    )
    let max-y = mirrored-layout.atoms.fold(
      first-position.y,
      (maximum, atom) => calc.max(maximum, atom.pos.y),
    )
    mirrored-layout.bbox_width = max-x - min-x
    mirrored-layout.bbox_height = max-y - min-y
  }
  mirrored-layout
}

#let _label-anchor-offset(label, anchor, anchor-length, label-width) = {
  if label == "" or anchor-length == 0 { return 0.0 }
  let prefix = label.slice(0, anchor)
  let glyph = label.slice(anchor, anchor + anchor-length)
  label-width(prefix) + label-width(glyph) / 2 - label-width(label) / 2
}

// Formats the lightweight script notation accepted in abbreviation labels.
// A marker applies to the preceding glyph; writing both forms after that glyph
// keeps its superscript and subscript paired (NH_4^+, rather than 4^+).
#let _abbreviation-label(label, atom-label, subscript-size, superscript-size) = {
  let formatted-label = []
  let character-index = 0
  while character-index < label.len() {
    let base = label.at(character-index)
    if base == "\\" and character-index + 1 < label.len() {
      formatted-label += atom-label(label.at(character-index + 1))
      character-index += 2
      continue
    }

    let subscript = none
    let superscript = none
    let next = character-index + 1
    while next < label.len() and (label.at(next) == "_" or label.at(next) == "^") {
      let marker = label.at(next)
      let start = next + 1
      if start >= label.len() {
        break
      }
      let (script, end) = if label.at(start) == "(" {
        let close = start + 1
        while close < label.len() and label.at(close) != ")" { close += 1 }
        if close >= label.len() {
          (none, next)
        } else {
          (label.slice(start + 1, close), close + 1)
        }
      } else {
        (label.at(start), start + 1)
      }
      if script == none { break }
      if marker == "_" { subscript = script } else { superscript = script }
      next = end
    }

    let base-content = atom-label(base)
    if superscript != none or subscript != none {
      let scripts = (:)
      if superscript != none {
        let body = superscript.replace("-", "\u{2212}")
        scripts.tr = $#atom-label(body, size: superscript-size)$
      }
      if subscript != none {
        let body = subscript.replace("-", "\u{2212}")
        scripts.br = $#atom-label(body, size: subscript-size)$
      }
      formatted-label += math.attach(math.limits($#base-content$), ..scripts)
    } else {
      formatted-label += base-content
    }
    character-index = if next > character-index + 1 { next } else { character-index + 1 }
  }
  formatted-label
}

// Screen-space lone-pair placements for a custom abbreviation label.
//
// The lone pairs belong to the attachment glyph (or the whole label when no `>`
// marker is present), but the entire rendered label is treated as an obstacle so
// pairs are never drawn through the remaining text. Bonds are obstacles too.
// Pairs are placed on the clearest cardinal sides, pushed just outside the label
// box on that side. This is the single source of truth for both the drawn dots
// and the `lp()` reference endpoints: the drawing pass and `_resolve-reference` both call
// it, so an electron-pushing arrow lands exactly on the pair it targets.
//
// Returns an array of `(dir, offset)`: a screen-space unit direction from the
// anchor-glyph center and a radial distance in (unscaled) bond-length units.
// Measurements use the supplied font size and canvas scale, which must share
// the molecule's unscaled coordinate system.
#let _abbreviation-lone-pair-directions(
  abbreviation,
  anchor,
  anchor-length,
  count,
  bond-directions,
  canvas-scale,
  font-size,
  font,
  margin,
) = {
  let make-label(body, size: font-size) = text(
    size: size, font: font, style: "normal", weight: "regular", body,
  )
  let label-width(body) = measure(
    _abbreviation-label(body, make-label, font-size, font-size),
  ).width / canvas-scale
  let full-label-size = measure(
    _abbreviation-label(abbreviation, make-label, font-size, font-size),
  )
  let width = full-label-size.width / canvas-scale
  let half-height = full-label-size.height / canvas-scale / 2
  // Signed distance from the label center to the anchor-glyph center (positive
  // when the glyph sits right of center), so the box edges follow the glyph.
  let anchor-offset = _label-anchor-offset(
    abbreviation,
    anchor,
    anchor-length,
    label-width,
  )
  let box-right = width / 2 - anchor-offset
  let box-left = width / 2 + anchor-offset
  let (glyph-half-width, glyph-half-height) = if anchor-length > 0 {
    let glyph-size = measure(_abbreviation-label(
      abbreviation.slice(anchor, anchor + anchor-length),
      make-label,
      font-size,
      font-size,
    ))
    (glyph-size.width / canvas-scale / 2, glyph-size.height / canvas-scale / 2)
  } else {
    (width / 2, half-height)
  }

  // Each cardinal side carries how far the label protrudes past the glyph on
  // that side (`ext`, the penalty for drawing over text) and how far out a pair
  // must sit to clear the box edge (`off`).
  let cardinals = (
    (
      direction: (x: 0.0, y: 1.0),
      text-extension: half-height - glyph-half-height,
      offset: half-height + margin,
    ),
    (
      direction: (x: 0.0, y: -1.0),
      text-extension: half-height - glyph-half-height,
      offset: half-height + margin,
    ),
    (
      direction: (x: -1.0, y: 0.0),
      text-extension: box-left - glyph-half-width,
      offset: box-left + margin,
    ),
    (
      direction: (x: 1.0, y: 0.0),
      text-extension: box-right - glyph-half-width,
      offset: box-right + margin,
    ),
  )

  let chosen = ()
  for _ in range(calc.min(count, 4)) {
    let best-side = none
    let best-side-index = none
    let best-score = none
    for side-index in range(cardinals.len()) {
      if chosen.any(choice => choice.index == side-index) { continue }
      let side = cardinals.at(side-index)
      let score = calc.max(0.0, side.text-extension) * 4.0
      for bond-direction in bond-directions {
        let dot = (
          side.direction.x * bond-direction.x
            + side.direction.y * bond-direction.y
        )
        if dot > 0.85 { score += 100.0 }
        else if dot > 0.45 { score += 8.0 }
        else if dot > 0.10 { score += 1.0 }
      }
      // Reward placing a pair opposite one already chosen, so two pairs land on
      // well-separated sides rather than crowding together.
      for choice in chosen {
        let chosen-side = cardinals.at(choice.index)
        let separation = (
          side.direction.x * chosen-side.direction.x
            + side.direction.y * chosen-side.direction.y
        )
        if separation < -0.5 {
          score -= 2.0
        }
      }
      if best-score == none or score < best-score {
        best-side = side
        best-side-index = side-index
        best-score = score
      }
    }
    if best-side != none {
      chosen.push((
        index: best-side-index,
        direction: best-side.direction,
        offset: best-side.offset,
      ))
    }
  }
  chosen.map(choice => (
    dir: choice.direction,
    offset: choice.offset,
  ))
}

// Draws a molecule's bonds, atom labels, and lone pairs into the current CeTZ
// canvas, centered at the local origin. The caller sets the canvas unit to
// `_canvas-scale(scale, bond-length)` and may translate before calling. Atom and
// bond references are resolved separately (see `_atom-position`) with the same
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
  _validate-molecule-options(
    layout,
    scale,
    bond-length,
    font-size,
    font,
    bond-stroke,
    color,
    rotation,
    show-h,
    lone-pairs,
    atom-colors,
    show-indices,
    fg,
    theme,
    aromatic,
    atom-annotations,
    opacity,
    bond-customizations,
  )
  let show-h-state = _normalize-show-h(show-h)
  let show-all-h = show-h-state.all
  let show-h-list = show-h-state.indices
  let atom-annotations = _normalize-atom-annotations(atom-annotations)
  let opacity = _opacity-ratio(opacity, "opacity")
  let bond-custom = _normalize-bond-customizations(
    bond-customizations,
    layout: layout,
  )

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
  let stroke-width        = actual-bond-stroke
  let subscript-size  = actual-font-size * 1.00
  let superscript-size = actual-font-size * 1.00
  let lone-pair-offset = calc.max(0.1, actual-font-size / canvas-scale * 0.6)
  let lone-pair-terminal-offset = calc.max(0.1, actual-font-size / canvas-scale * 0.5)
  let lone-pair-dot-radius = calc.max(0.018, stroke-units * 0.75)
  let lone-pair-dot-gap = calc.max(0.064, lone-pair-dot-radius * 2.6)
  let lone-pair-line-half = calc.max(0.055, stroke-units * 2.4)
  // Clearance between a custom-label lone pair and the edge of the label box.
  let abbrev-lp-margin = calc.max(0.08, actual-font-size / canvas-scale * 0.34)

  let atom-color = if color {
    (symbol) => fade({
      if symbol in atom-colors { atom-colors.at(symbol) }
      else { _atom-color(symbol, theme: theme, fg: base-fg) }
    })
  } else { (symbol) => fg }
  let label-color = if color {
    (style) => fade({
      if style in atom-colors { atom-colors.at(style) }
      else { _label-color(style, theme: theme, fg: base-fg) }
    })
  } else { (style) => fg }
  let display-color(atom) = {
    let abbrev = atom.at("abbrev", default: "")
    let abbrev-style = atom.at("abbrev_style", default: "")
    if abbrev != "" {
      let label-key = "{" + abbrev + "}"
      if color and label-key in atom-colors { fade(atom-colors.at(label-key)) }
      else { label-color(abbrev-style) }
    } else {
      atom-color(atom.symbol)
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
  let index-marker-name(atom-index, suffix) = (
    index-prefix + "atom-index-marker-" + str(atom-index) + suffix
  )

  let rotation-cosine = calc.cos(rotation)
  let rotation-sine = calc.sin(rotation)
  let rotated-x(x, y) = x * rotation-cosine - y * rotation-sine
  let rotated-y(x, y) = x * rotation-sine + y * rotation-cosine
  let atom-screen-position(atom) = _rendered-atom-position(
    atom,
    rotation,
  )

  // cetz.draw exports a `scale` transform that would shadow the `scale` argument,
  // so import only after all scalar/style values above are computed.
  import cetz.draw: *

  // Virtual bonds connect a heavy atom to its bracket-H atoms. They carry positions
  // for atom() references but must not affect structural computations or rendering.
  let structural-bonds = layout.bonds.filter(
    bond-output => not bond-output.at("virtual_bond", default: false),
  )
  let virtual-hydrogen-parent = (:)
  let virtual-hydrogen-child = (:)
  let virtual-hydrogen-direction = (:)
  for bond-output in layout.bonds {
    if bond-output.at("virtual_bond", default: false) {
      let parent-index = bond-output.from
      let hydrogen-index = bond-output.to
      virtual-hydrogen-parent.insert(str(hydrogen-index), parent-index)
      virtual-hydrogen-child.insert(str(parent-index), hydrogen-index)
      let parent-atom = layout.atoms.at(parent-index)
      let hydrogen-atom = layout.atoms.at(hydrogen-index)
      let parent-position = atom-screen-position(parent-atom)
      let hydrogen-position = atom-screen-position(hydrogen-atom)
      let offset-x = hydrogen-position.x - parent-position.x
      let offset-y = hydrogen-position.y - parent-position.y
      let distance = calc.sqrt(offset-x * offset-x + offset-y * offset-y)
      let direction-x = if distance > 0.001 { offset-x / distance } else { 1.0 }
      let direction-y = if distance > 0.001 { offset-y / distance } else { 0.0 }
      virtual-hydrogen-direction.insert(
        str(parent-index),
        (direction-x, direction-y),
      )
    }
  }

  let atom-degree(atom-index) = structural-bonds.filter(
    bond-output => bond-output.from == atom-index
      or bond-output.to == atom-index,
  ).len()
  let atom-neighbor-indices(atom-index) = {
    let indices = ()
    for bond-output in structural-bonds {
      if bond-output.from == atom-index {
        indices.push(bond-output.to)
      } else if bond-output.to == atom-index {
        indices.push(bond-output.from)
      }
    }
    indices
  }
    // A cumulene-center carbon (two double bonds, collinear neighbors) is
    // drawn as an explicit C label: without it the two double bonds merge
    // into what reads as one long double bond (O=C=O, ketene, allenes).
  let force-linear-carbon-label(atom-index) = {
    let atom = layout.atoms.at(atom-index)
    if (
      not _is-carbon(atom)
        or atom.at("abbrev", default: "") != ""
        or atom-degree(atom-index) != 2
    ) {
      false
    } else {
      let bonds = structural-bonds.filter(
        bond-output => bond-output.from == atom-index
          or bond-output.to == atom-index,
      )
      bonds.filter(bond-output => bond-output.order == 2).len() == 2
    }
  }
  let forced-hydrogen(atom-index) = show-h-list.contains(atom-index)
  let has-label(atom-index) = {
    let atom = layout.atoms.at(atom-index)
    _has-label(
      atom,
      show-all-h: show-all-h,
      force: forced-hydrogen(atom-index),
    ) or force-linear-carbon-label(atom-index)
  }
  let first-neighbor(atom-index) = {
    let neighbor-index = none
    for bond-output in structural-bonds {
      if neighbor-index == none and (
        bond-output.from == atom-index or bond-output.to == atom-index
      ) {
        neighbor-index = if bond-output.from == atom-index {
          bond-output.to
        } else {
          bond-output.from
        }
      }
    }
    neighbor-index
  }
  let visible-hydrogen-count(atom-index) = {
    let atom = layout.atoms.at(atom-index)
    let count = atom.hcount + _visible-implicit-h(
      atom,
      show-all-h: show-all-h,
      force: forced-hydrogen(atom-index),
    )
    if atom.at("stereo_h", default: "none") != "none" {
      calc.max(0, count - 1)
    } else {
      count
    }
  }
  let label-trim(atom, atom-index, direction-x, direction-y) = {
    let displays-hydrogen = visible-hydrogen-count(atom-index) > 0 and (
      show-all-h or forced-hydrogen(atom-index) or not _is-carbon(atom)
    )
    if not has-label(atom-index) {
      0.0
    } else if (
      displays-hydrogen
        and atom-degree(atom-index) == 1
        and not _is-carbon(atom)
    ) {
      0.06
    } else if (
      atom.at("abbrev", default: "") != ""
        and not displays-hydrogen
        and atom.charge == 0
        and atom.at("isotope", default: 0) == 0
    ) {
      let label-size = measure(_abbreviation-label(
        atom.at("abbrev", default: ""),
        atom-label,
        subscript-size,
        superscript-size,
      ))
      let half-width = label-size.width / canvas-scale / 2
      let half-height = label-size.height / canvas-scale / 2
      let extent = (
        half-width * calc.abs(direction-x)
          + half-height * calc.abs(direction-y)
          + 0.07
      )
      calc.min(label-margin, calc.max(0.14, extent))
    } else if (
      atom.at("abbrev", default: "") == ""
        and not displays-hydrogen
        and atom.charge == 0
        and atom.at("isotope", default: 0) == 0
    ) {
      let label-size = measure(atom-label(atom.symbol))
      let half-width = label-size.width / canvas-scale / 2
      let half-height = label-size.height / canvas-scale / 2
      let extent = (
        half-width * calc.abs(direction-x)
          + half-height * calc.abs(direction-y)
          + 0.07
      )
      calc.min(label-margin, calc.max(0.14, extent))
    } else {
      label-margin
    }
  }

    for bond in structural-bonds {
      let from-atom = layout.atoms.at(bond.from)
      let to-atom = layout.atoms.at(bond.to)
      let from-position = atom-screen-position(from-atom)
      let to-position = atom-screen-position(to-atom)
      let from-x = from-position.x
      let from-y = from-position.y
      let to-x = to-position.x
      let to-y = to-position.y
      let from-color = display-color(from-atom)
      let to-color = display-color(to-atom)

      // Per-bond style overrides. A color override replaces the bicolor
      // halves with one uniform paint; stroke overrides the width for every
      // segment of this bond (double/triple lines, hashes, waves, dashes).
      let bond-customization = bond-custom.at(
        str(calc.min(bond.from, bond.to)) + "-" + str(calc.max(bond.from, bond.to)),
        default: (:),
      )
      if "color" in bond-customization {
        from-color = fade(bond-customization.color)
        to-color = from-color
      }
      if "opacity" in bond-customization {
        from-color = from-color.transparentize(100% - bond-customization.opacity)
        to-color = to-color.transparentize(100% - bond-customization.opacity)
      }
      let stroke-width = if "stroke" in bond-customization { bond-customization.stroke } else { stroke-width }

      let dx = to-x - from-x
      let dy = to-y - from-y
      let len = calc.sqrt(dx * dx + dy * dy)
      let ux = if len > 0.001 { dx / len } else { 1.0 }
      let uy = if len > 0.001 { dy / len } else { 0.0 }

      let from-atom-has-label = has-label(bond.from)
      let to-has-label = has-label(bond.to)
      let s1 = label-trim(from-atom, bond.from, ux, uy)
      let s2 = label-trim(to-atom, bond.to, ux, uy)
      let e1 = if not from-atom-has-label and atom-degree(bond.from) > 1 { junction-overlap } else { 0.0 }
      let e2 = if not to-has-label and atom-degree(bond.to) > 1 { junction-overlap } else { 0.0 }
      let bond-start-x = from-x + ux * s1 - ux * e1
      let bond-start-y = from-y + uy * s1 - uy * e1
      let bond-end-x = to-x - ux * s2 + ux * e2
      let bond-end-y = to-y - uy * s2 + uy * e2
      let mx = (bond-start-x + bond-end-x) / 2
      let my = (bond-start-y + bond-end-y) / 2

      let stereo = bond.at("stereo", default: "none")
      let split-line(x1, y1, x2, y2, from-color, to-color) = {
        let xmid = (x1 + x2) / 2
        let ymid = (y1 + y2) / 2
        line((x1, y1), (xmid, ymid), stroke: stroke-width + from-color)
        line((xmid, ymid), (x2, y2), stroke: stroke-width + to-color)
      }
      let offset-side(atom-idx, other-idx, px, py) = {
        let side = 1.0
        for b in structural-bonds {
          if (b.from == atom-idx or b.to == atom-idx) and not (b.from == other-idx or b.to == other-idx) {
            let neighbor-index = if b.from == atom-idx { b.to } else { b.from }
            let na = layout.atoms.at(neighbor-index)
            let neighbor-position = atom-screen-position(na)
            let vx = neighbor-position.x - px
            let vy = neighbor-position.y - py
            side = if vx * (-uy) + vy * ux >= 0.0 { 1.0 } else { -1.0 }
          }
        }
        side
      }

      // Per IUPAC: narrow tip at stereocenter, wide base at substituent.
      // Explicit drawing wedges/hashes use the written source as the tip.
      // Inferred stereochemical bonds fall back to a local stereocenter
      // heuristic.
      let from-atom-abbr = from-atom.at("abbrev", default: "") != ""
      let to-is-abbreviation = to-atom.at("abbrev", default: "") != ""
      let from-atom-is-c = (from-atom.symbol == "C" or from-atom.symbol == "c") and not from-atom-abbr
      let to-is-carbon = (to-atom.symbol == "C" or to-atom.symbol == "c") and not to-is-abbreviation
      let tip-at-from = if bond.at("forced_stereo", default: false) { true }
                        else if from-atom-is-c and not to-is-carbon { true }
                        else if to-is-carbon and not from-atom-is-c { false }
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
          (bond-start-x, bond-start-y, bond-end-x, bond-end-y, from-color, to-color)
        } else {
          (bond-end-x, bond-end-y, bond-start-x, bond-start-y, to-color, from-color)
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
        let (start-x, sy, end-x, ey, near-c, far-c) = if tip-at-from {
          (bond-start-x, bond-start-y, bond-end-x, bond-end-y, from-color, to-color)
        } else {
          (bond-end-x, bond-end-y, bond-start-x, bond-start-y, to-color, from-color)
        }
        for i in range(n-lines) {
          let t = i / (n-lines - 1)
          let cx = start-x + (end-x - start-x) * t
          let cy = sy + (ey - sy) * t
          let w  = half-w * calc.max(0.16, t)
          let ox = -uy * w
          let oy =  ux * w
          let segment-color = if t < 0.5 { near-c } else { far-c }
          line(
            (cx - ox, cy - oy),
            (cx + ox, cy + oy),
            stroke: stroke-width + segment-color,
          )
        }

      } else if stereo == "wavy" {
        // Wavy (squiggly) bond: a sine wave along the bond axis, split at the
        // midpoint for bicoloring like a plain bond. A whole number of waves
        // keeps both endpoints on-axis at the atoms.
        let waves = 4
        let amp = 0.075
        let segment-count = 32
        let bx = bond-end-x - bond-start-x
        let by = bond-end-y - bond-start-y
        let points = range(segment-count + 1).map(i => {
          let t = i / segment-count
          let s = calc.sin(t * waves * 2.0 * calc.pi) * amp
          (bond-start-x + bx * t - uy * s, bond-start-y + by * t + ux * s)
        })
        let half = calc.quo(segment-count, 2)
        let wavy-stroke(c) = (paint: c, thickness: stroke-width, cap: "round", join: "round")
        line(..points.slice(0, half + 1), stroke: wavy-stroke(from-color))
        line(..points.slice(half), stroke: wavy-stroke(to-color))

      } else if stereo == "dashed" {
        // Dashed bond: evenly spaced dashes drawn as explicit segments so the
        // pattern is symmetric about the bond center regardless of length.
        let n-dash = 6
        let duty = 0.62
        let cell = 1.0 / n-dash
        for i in range(n-dash) {
          let t0 = (i + (1.0 - duty) / 2) * cell
          let t1 = (i + (1.0 + duty) / 2) * cell
          let segment-color = if (t0 + t1) / 2 < 0.5 {
            from-color
          } else {
            to-color
          }
          line(
            (bond-start-x + (bond-end-x - bond-start-x) * t0, bond-start-y + (bond-end-y - bond-start-y) * t0),
            (bond-start-x + (bond-end-x - bond-start-x) * t1, bond-start-y + (bond-end-y - bond-start-y) * t1),
            stroke: stroke-width + segment-color,
          )
        }

      } else if (aromatic == "circle" and bond.at("aromatic", default: false)) or bond.order == 1 {
        // In circle mode an aromatic bond draws as a plain single line; the
        // ring's pi system is shown by the inscribed circle instead.
        line((bond-start-x, bond-start-y), (mx, my),   stroke: stroke-width + from-color)
        line((mx, my),   (bond-end-x, bond-end-y), stroke: stroke-width + to-color)

      } else if bond.order == 2 {
        let is-ring-bond = bond.inner_x != 0.0 or bond.inner_y != 0.0

        if is-ring-bond {
          split-line(bond-start-x, bond-start-y, bond-end-x, bond-end-y, from-color, to-color)
          let ix  = rotated-x(bond.inner_x, bond.inner_y) * ring-double-gap
          let iy  = rotated-y(bond.inner_x, bond.inner_y) * ring-double-gap
          let lx1 = bond-start-x + ux * inner-trim + ix
          let ly1 = bond-start-y + uy * inner-trim + iy
          let lx2 = bond-end-x - ux * inner-trim + ix
          let ly2 = bond-end-y - uy * inner-trim + iy
          split-line(lx1, ly1, lx2, ly2, from-color, to-color)
        } else {
          let degree-f = atom-degree(bond.from)
          let degree-t = atom-degree(bond.to)
          let has-hidden-simple-continuation = (degree-f == 2 and not from-atom-has-label) or (degree-t == 2 and not to-has-label)

          if has-hidden-simple-continuation {
            // A chain continuation establishes the skeletal bond axis. Keep
            // that line connected to both vertices and draw the second line
            // inset and shortened at each substituted carbon.
            split-line(bond-start-x, bond-start-y, bond-end-x, bond-end-y, from-color, to-color)

            let side = if degree-f == 2 and not from-atom-has-label {
              offset-side(bond.from, bond.to, bond-start-x, bond-start-y)
            } else {
              offset-side(bond.to, bond.from, bond-end-x, bond-end-y)
            }
            let trim = calc.min(multiple-bond-trim, len * 0.25)
            let simple-double-gap = double-gap * 1.12
            let ox = -uy * simple-double-gap * side
            let oy =  ux * simple-double-gap * side
            let trim-f = if degree-f > 1 and not from-atom-has-label { trim } else { 0.0 }
            let trim-t = if degree-t > 1 and not to-has-label { trim } else { 0.0 }
            let lx1 = bond-start-x + ux * trim-f + ox
            let ly1 = bond-start-y + uy * trim-f + oy
            let lx2 = bond-end-x - ux * trim-t + ox
            let ly2 = bond-end-y - uy * trim-t + oy
            split-line(lx1, ly1, lx2, ly2, from-color, to-color)
          } else {
            // At real junctions (3+ bonds) extend slightly to close corner gap.
            let ext = 0.04
            let ox = -uy * double-gap
            let oy =  ux * double-gap
            let e1x = bond-start-x - ux * (if degree-f > 2 { ext } else { 0.0 })
            let e1y = bond-start-y - uy * (if degree-f > 2 { ext } else { 0.0 })
            let e2x = bond-end-x + ux * (if degree-t > 2 { ext } else { 0.0 })
            let e2y = bond-end-y + uy * (if degree-t > 2 { ext } else { 0.0 })
            split-line(e1x + ox, e1y + oy, e2x + ox, e2y + oy, from-color, to-color)
            split-line(e1x - ox, e1y - oy, e2x - ox, e2y - oy, from-color, to-color)
          }
        }

      } else if bond.order == 3 {
        let ox = -uy * double-gap * 1.3
        let oy =  ux * double-gap * 1.3
        let trim = calc.min(multiple-bond-trim, len * 0.25)
        split-line(bond-start-x, bond-start-y, bond-end-x, bond-end-y, from-color, to-color)
        split-line(bond-start-x + ux * trim + ox, bond-start-y + uy * trim + oy, bond-end-x - ux * trim + ox, bond-end-y - uy * trim + oy, from-color, to-color)
        split-line(bond-start-x + ux * trim - ox, bond-start-y + uy * trim - oy, bond-end-x - ux * trim - ox, bond-end-y - uy * trim - oy, from-color, to-color)

      } else if bond.order == 4 {
        // Quadruple bond: four parallel lines symmetric about the bond axis,
        // outer pair shortened like the outer lines of a triple bond.
        let trim = calc.min(multiple-bond-trim, len * 0.25)
        for k in (-1.5, -0.5, 0.5, 1.5) {
          let ox = -uy * double-gap * k
          let oy =  ux * double-gap * k
          let t = if calc.abs(k) > 1.0 { trim } else { 0.0 }
          split-line(
            bond-start-x + ux * t + ox, bond-start-y + uy * t + oy,
            bond-end-x - ux * t + ox, bond-end-y - uy * t + oy,
            from-color, to-color,
          )
        }
      }
    }

    // Aromatic rings as inscribed circles.
    if aromatic == "circle" {
      for ring in layout.at("aromatic_rings", default: ()) {
        circle(
          (rotated-x(ring.center.x, ring.center.y), rotated-y(ring.center.x, ring.center.y)),
          radius: ring.radius,
          stroke: stroke-width + fg,
          fill: none,
        )
      }
    }

    // ── Lone-pair annotation ──────────────────────────────────────────────
    // Non-bonding electron pairs render as either two dots (the two electrons)
    // or a single short line. Hydrogen-bearing heteroatom labels are laid out
    // in screen space so the pairs avoid the bond and the inline hydrogen; all
    // other labeled atoms use the layout directions supplied by the plugin.

    // Unit vector in screen space pointing from one atom toward another,
    // or none when the two atoms coincide.
    let neighbor-screen-direction(atom-index, neighbor-index) = {
      let atom-position = atom-screen-position(layout.atoms.at(atom-index))
      let neighbor-position = atom-screen-position(
        layout.atoms.at(neighbor-index),
      )
      let offset-x = neighbor-position.x - atom-position.x
      let offset-y = neighbor-position.y - atom-position.y
      let distance = calc.sqrt(offset-x * offset-x + offset-y * offset-y)
      if distance > 0.001 {
        (x: offset-x / distance, y: offset-y / distance)
      } else {
        none
      }
    }

    // Cardinal screen directions for a hydrogen-bearing heteroatom, chosen
    // greedily to stay clear of the bonds, the inline hydrogen, and one another.
    let inline-hydrogen-pair-directions(atom-index, count) = {
      let occupied = ()
      for neighbor-index in atom-neighbor-indices(atom-index) {
        let direction = neighbor-screen-direction(atom-index, neighbor-index)
        if direction != none { occupied.push(direction) }
      }
      if atom-degree(atom-index) >= 2 {
        // A stacked hydrogen is drawn directly above the symbol.
        occupied.push((x: 0.0, y: 1.0))
      } else {
        // An inline "XH" runs horizontally: the hydrogen sits opposite a
        // horizontal bond, or to the right of a vertical one.
        let neighbor-index = first-neighbor(atom-index)
        let bond-direction = if neighbor-index != none {
          neighbor-screen-direction(atom-index, neighbor-index)
        } else {
          none
        }
        let hydrogen-direction = if bond-direction == none {
          (x: 1.0, y: 0.0)
        } else if calc.abs(bond-direction.x) >= calc.abs(bond-direction.y) {
          (x: -bond-direction.x, y: 0.0)
        } else {
          (x: 1.0, y: 0.0)
        }
        occupied.push(hydrogen-direction)
      }

      let candidates = if count == 1 {
        ((x: 0.0, y: -1.0), (x: 0.0, y: 1.0), (x: -1.0, y: 0.0), (x: 1.0, y: 0.0))
      } else {
        ((x: 0.0, y: 1.0), (x: 0.0, y: -1.0), (x: -1.0, y: 0.0), (x: 1.0, y: 0.0))
      }

      let chosen = ()
      for _ in range(count) {
        let best-direction = none
        let best-score = none
        for candidate in candidates {
          let score = 0.0
          for occupied-direction in occupied {
            let dot = (
              candidate.x * occupied-direction.x
                + candidate.y * occupied-direction.y
            )
            if dot > 0.85 {
              score += 100.0
            } else if dot > 0.45 {
              score += 8.0
            } else if dot > 0.10 {
              score += 1.0
            }
          }
          for selected-direction in chosen {
            let overlap = (
              candidate.x * selected-direction.x
                + candidate.y * selected-direction.y
            )
            if overlap > 0.85 {
              score += 100.0
            }
          }
          if best-score == none or score < best-score {
            best-direction = candidate
            best-score = score
          }
        }
        if best-direction != none {
          chosen.push(best-direction)
          occupied.push(best-direction)
        }
      }
      chosen
    }

    // Draw each screen-space direction as one electron
    // pair around `origin`: two dots in "dots" mode, a short line in "lines".
    // `origin` can be a numeric point or a named glyph marker.
    let render-pairs(origin, directions, fill, offset) = {
      let point-at(offset-x, offset-y) = if type(origin) == str or type(origin) == dictionary {
        (to: origin, rel: (offset-x, offset-y))
      } else {
        (origin.x + offset-x, origin.y + offset-y)
      }
      for direction in directions {
        let normal-x = -direction.y
        let normal-y = direction.x
        if lone-pairs == "dots" {
          circle(
            point-at(
              direction.x * offset + normal-x * lone-pair-dot-gap / 2,
              direction.y * offset + normal-y * lone-pair-dot-gap / 2,
            ),
            radius: lone-pair-dot-radius,
            fill: fill,
            stroke: none,
          )
          circle(
            point-at(
              direction.x * offset - normal-x * lone-pair-dot-gap / 2,
              direction.y * offset - normal-y * lone-pair-dot-gap / 2,
            ),
            radius: lone-pair-dot-radius,
            fill: fill,
            stroke: none,
          )
        } else {
          line(
            point-at(
              direction.x * offset - normal-x * lone-pair-line-half,
              direction.y * offset - normal-y * lone-pair-line-half,
            ),
            point-at(
              direction.x * offset + normal-x * lone-pair-line-half,
              direction.y * offset + normal-y * lone-pair-line-half,
            ),
            stroke: stroke-width + fill,
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

        let atom-position = atom-screen-position(atom)
        let px = atom-position.x
        let py = atom-position.y
        let fill = display-color(atom)
        let abbrev = atom.at("abbrev", default: "")

        if abbrev != "" {
          // Custom labels place pairs in screen space, avoiding the label box
          // and the bonds. The same helper feeds lp() references.
          let bond-dirs = atom-neighbor-indices(i)
            .map(neighbor-index => neighbor-screen-direction(i, neighbor-index))
            .filter(d => d != none)
          let placements = _abbreviation-lone-pair-directions(
            abbrev,
            atom.at("abbrev_anchor", default: 0),
            atom.at("abbrev_anchor_len", default: 0),
            count,
            bond-dirs,
            canvas-scale,
            actual-font-size,
            font,
            abbrev-lp-margin,
          )
          for pl in placements {
            render-pairs((x: px, y: py), (pl.dir,), fill, pl.offset)
          }
          continue
        }

        let has-inline-h = (
          not _is-carbon(atom) and
          visible-hydrogen-count(i) > 0
        )

        if not has-inline-h {
          // Use the plugin's layout-space directions, rotated into screen space.
          let dirs = atom
            .at("lone_pair_dirs", default: ())
            .map(d => (x: rotated-x(d.x, d.y), y: rotated-y(d.x, d.y)))
          render-pairs((x: px, y: py), dirs, fill, lone-pair-offset)
        } else {
          let origin = if str(i) in virtual-hydrogen-child {
            index-marker-name(i, "-sym") + ".center"
          } else {
            (x: px, y: py)
          }
          let offset = if atom-degree(i) <= 1 { lone-pair-terminal-offset } else { lone-pair-offset }
          render-pairs(origin, inline-hydrogen-pair-directions(i, count), fill, offset)
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
        let atom-position = atom-screen-position(atom)
        let px = atom-position.x
        let py = atom-position.y
        let dir = atom.at("stereo_h_dir", default: (x: 0.0, y: -1.0))
        let ux = rotated-x(dir.x, dir.y)
        let uy = rotated-y(dir.x, dir.y)
        let bond-end-x = px + ux * 0.62
        let bond-end-y = py + uy * 0.62
        let label-x = px + ux * 0.82
        let label-y = py + uy * 0.82
        let h-fill = atom-color("H")

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
            line((cx - ox, cy - oy), (cx + ox, cy + oy), stroke: stroke-width + h-fill)
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
        let fill = display-color(atom)
        let atom-position = atom-screen-position(atom)
        let px = atom-position.x
        let py = atom-position.y
        let degree = atom-degree(i)
        let h-count = visible-hydrogen-count(i)

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
        let symbol-text = isotope-content + atom-label(atom.symbol, fill: fill)
        let h-text = if abbrev != "" or h-count == 0 or (_is-carbon(atom) and not (show-all-h or forced-hydrogen(i))) {
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
        let hetero-inline = abbrev == "" and h-text != [] and degree == 1 and not _is-carbon(atom)

        if hetero-inline {
          let neighbor-index = first-neighbor(i)
          let neighbor-atom = layout.atoms.at(neighbor-index)
          let neighbor-position = atom-screen-position(neighbor-atom)
          let dx = neighbor-position.x - px
          let dy = neighbor-position.y - py
          // Anchor the symbol's bond-facing edge at the atom; the H hangs off the
          // opposite side. Pad only the bond-facing edge so the pair stays tight.
          let pad-bond = 1pt
          let (symbol-anchor, symbol-pad, h-at, h-self) = if calc.abs(dx) >= calc.abs(dy) {
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
          let symbol-content = if h-at == "west" { symbol-text + charge-content } else { symbol-text }
          let h-content = if h-at == "west" { h-text } else { h-text + charge-content }
          let sname = "atom-" + str(i)
          content((px, py), symbol-content, anchor: symbol-anchor, padding: symbol-pad, name: sname)
          if (show-indices or lone-pairs != none) and str(i) in virtual-hydrogen-child {
            let h-child = virtual-hydrogen-child.at(str(i))
            let pad-u = pad-bond / canvas-scale
            let symbol-marker-x = if symbol-anchor == "east" {
              px - pad-u - content-width(if h-at == "west" { charge-content } else { [] })
            } else if symbol-anchor == "west" {
              px + pad-u
            } else {
              px
            }
            content(
              (symbol-marker-x, py),
              atom-label(atom.symbol, fill: transparent),
              anchor: symbol-anchor,
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
          _abbreviation-label(
            abbrev,
            (body, size: actual-font-size) => atom-label(body, fill: fill, size: size),
            subscript-size,
            superscript-size,
          )
          } else {
            let reverse-inline = if h-text == [] or degree != 1 {
              false
            } else {
              let neighbor-index = first-neighbor(i)
              if neighbor-index == none {
                false
              } else {
                let neighbor = layout.atoms.at(neighbor-index)
                let vx = atom-screen-position(neighbor).x - px
                vx > 0.05
              }
            }
            let stacked-h = h-text != [] and degree >= 2 and not _is-carbon(atom)
            let base-text = if stacked-h {
              draw-h-above = true
              h-above-content = h-text
              if (show-indices or lone-pairs != none) and str(i) in virtual-hydrogen-child {
                h-above-marker = (
                  child: virtual-hydrogen-child.at(str(i)),
                  group: h-text,
                  prefix: [],
                  fragment: atom-label("H", fill: transparent),
                )
              }
              symbol-text
            } else if reverse-inline {
              h-text + symbol-text
            } else {
              symbol-text + h-text
            }
            base-text + charge-content
          }

          let symbol-centered-charge = abbrev == "" and h-text == [] and charge-content != []

          if symbol-centered-charge {
            content(
              (px + (content-width(label-content) - content-width(symbol-text)) / 2, py),
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
              let symbol-marker = atom-label(atom.symbol, fill: transparent)
              let symbol-x = (
                px
                - content-width(label-content) / 2
                + content-width(symbol-marker) / 2
              )
              content(
                (symbol-x, py),
                symbol-marker,
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

          if (show-indices or lone-pairs != none) and str(i) in virtual-hydrogen-child and not draw-h-above {
            let h-child = virtual-hydrogen-child.at(str(i))
            let symbol-marker = atom-label(atom.symbol, fill: transparent)
            let h-marker = atom-label("H", fill: transparent)
            let h-prefix = if label-content == h-text + symbol-text + charge-content {
              []
            } else {
              symbol-text
            }
            let symbol-prefix = if h-prefix == [] { h-text } else { [] }
            let symbol-x = (
              px
              - content-width(label-content) / 2
              + content-width(symbol-prefix)
              + content-width(symbol-marker) / 2
            )
            let h-x = (
              px
              - content-width(label-content) / 2
              + content-width(h-prefix)
              + content-width(h-marker) / 2
            )
            content(
              (symbol-x, py),
              symbol-marker,
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
                text => content-width(_abbreviation-label(
                  text,
                  (body, size: actual-font-size) => atom-label(body, fill: fill, size: size),
                  subscript-size,
                  superscript-size,
                )),
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
    for annotation in atom-annotations {
      let atom-index = annotation.index
      let body = annotation.body
      let atom = layout.atoms.at(atom-index)
      if not atom.at("virtual_h", default: false) {
        let atom-position = atom-screen-position(atom)
        let atom-x = atom-position.x
        let atom-y = atom-position.y
        let neighbor-directions = atom-neighbor-indices(atom-index)
          .map(neighbor-index => (
            neighbor-screen-direction(atom-index, neighbor-index)
          ))
          .filter(direction => direction != none)
        let direction-sum = neighbor-directions.fold(
          (x: 0.0, y: 0.0),
          (accumulator, direction) => (
            x: accumulator.x + direction.x,
            y: accumulator.y + direction.y,
          ),
        )
        let direction-length = calc.sqrt(
          direction-sum.x * direction-sum.x
            + direction-sum.y * direction-sum.y,
        )
        let annotation-direction = if direction-length > 0.05 {
          (
            x: -direction-sum.x / direction-length,
            y: -direction-sum.y / direction-length,
          )
        } else {
          // Symmetric surroundings or isolated atom: place diagonally.
          (x: 0.7071, y: 0.7071)
        }
        let offset = if has-label(atom-index) { label-margin + 0.14 } else { 0.30 }
        let nudge = annotation.at("offset", default: (0, 0))
        content(
          (
            atom-x + annotation-direction.x * offset + nudge.at(0),
            atom-y + annotation-direction.y * offset + nudge.at(1),
          ),
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

      for atom-index in range(layout.atoms.len()) {
        let atom = layout.atoms.at(atom-index)
        let atom-position = atom-screen-position(atom)
        let atom-x = atom-position.x
        let atom-y = atom-position.y

        let (badge-x, badge-y, badge-target) = if (
          not atom.at("virtual_h", default: false) and
          str(atom-index) in virtual-hydrogen-child and
          _has-label(
            atom,
            show-all-h: show-all-h,
            force: forced-hydrogen(atom-index),
          )
        ) {
          (0.0, 0.0, index-marker-name(atom-index, "-sym") + ".center")
        } else if (
          atom.at("virtual_h", default: false) and
          str(atom-index) in virtual-hydrogen-parent and
          _has-label(
            layout.atoms.at(virtual-hydrogen-parent.at(str(atom-index))),
            show-all-h: show-all-h,
            force: forced-hydrogen(
              virtual-hydrogen-parent.at(str(atom-index)),
            ),
          )
        ) {
          (0.0, 0.0, index-marker-name(atom-index, "-h") + ".center")
        } else {
          (atom-x, atom-y, none)
        }

        content(
          if badge-target == none { (badge-x, badge-y) } else { badge-target },
          box(
            fill: badge-bg,
            inset: 0.4pt,
            text(
              size: badge-size,
              fill: rgb("#C81E6E"),
              weight: "bold",
              str(atom-index),
            ),
          ),
          anchor: "center",
          padding: 0pt,
        )
      }
    }
}

// ── Reference resolution and annotation drawing ─────────────────────────────────

// Screen-space position of layout coordinate (x, y) under `rotation`.
#let _rotate-point(coordinate-x, coordinate-y, rotation) = (
  coordinate-x * calc.cos(rotation) - coordinate-y * calc.sin(rotation),
  coordinate-x * calc.sin(rotation) + coordinate-y * calc.cos(rotation),
)

// Absolute canvas position of an atom in a placed species. Label references use
// the rendered atom glyph center rather than the full label box.
#let _atom-position(placed-species, atom-index) = {
  // `mol-scale` shrinks or grows one species around its own origin; layout
  // coordinates are stored unscaled, so every read multiplies by it.
  let molecule-scale = placed-species.at("mol-scale", default: 1.0)
  let atom = placed-species.layout.atoms.at(atom-index)
  let rendered-position = _rendered-atom-position(
    atom,
    placed-species.rotation,
    scale: molecule-scale,
  )
  let base = (
    placed-species.origin.at(0) + rendered-position.x,
    placed-species.origin.at(1) + rendered-position.y,
  )

  let canvas-scale = placed-species.at("canvas-scale", default: 30pt)
  let font-size = placed-species.at("actual-font-size", default: 11pt)
  let font = placed-species.at("font", default: "New Computer Modern")
  let show-h-state = _normalize-show-h(placed-species.at("show-h", default: ()))
  let show-all-h = show-h-state.all
  let label-margin = calc.max(0.27 * molecule-scale, font-size / canvas-scale * 0.70)
  let subscript-size = font-size * 1.00
  let superscript-size = font-size * 1.00
  let atom-label(body, size: font-size) = text(
    size: size,
    font: font,
    style: "normal",
    weight: "regular",
    body,
  )
  let content-width(body) = measure(body).width / canvas-scale
  let content-height(body) = measure(body).height / canvas-scale
  let structural-bonds = placed-species.layout.bonds.filter(
    bond-output => not bond-output.at("virtual_bond", default: false),
  )
  let atom-degree(index) = structural-bonds.filter(
    bond-output => bond-output.from == index or bond-output.to == index,
  ).len()
  let first-neighbor(index) = {
    let neighbor-index = none
    for bond-output in structural-bonds {
      if neighbor-index == none and (
        bond-output.from == index or bond-output.to == index
      ) {
        neighbor-index = if bond-output.from == index {
          bond-output.to
        } else {
          bond-output.from
        }
      }
    }
    neighbor-index
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
  let hydrogen-label(atom, index) = {
    let force = show-h-list.contains(index)
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
    for bond-output in placed-species.layout.bonds {
      if (
        child == none
          and bond-output.at("virtual_bond", default: false)
          and bond-output.from == parent
      ) {
        child = bond-output.to
      }
    }
    child
  }
  let virtual-parent(child) = {
    let parent = none
    for bond-output in placed-species.layout.bonds {
      if (
        parent == none
          and bond-output.at("virtual_bond", default: false)
          and bond-output.to == child
      ) {
        parent = bond-output.from
      }
    }
    parent
  }

  let label-fragment-position(parent, fragment) = {
    let atom = placed-species.layout.atoms.at(parent)
    let parent-position = _rendered-atom-position(
      atom,
      placed-species.rotation,
      scale: molecule-scale,
    )
    let rotated-parent-x = parent-position.x
    let rotated-parent-y = parent-position.y
    let px = placed-species.origin.at(0) + rotated-parent-x
    let py = placed-species.origin.at(1) + rotated-parent-y
    let degree = atom-degree(parent)
    let symbol-text = atom-label(atom.symbol)
    let hydrogen-text = hydrogen-label(atom, parent)
    let charge = charge-content(atom)

    if atom.at("abbrev", default: "") != "" or hydrogen-text == [] {
      return (px, py)
    }

    let hetero-inline = degree == 1 and not _is-carbon(atom)
    if hetero-inline {
      let neighbor-index = first-neighbor(parent)
      if neighbor-index == none { return (px, py) }
      let neighbor-atom = placed-species.layout.atoms.at(neighbor-index)
      let neighbor-position = _rendered-atom-position(
        neighbor-atom,
        placed-species.rotation,
        scale: molecule-scale,
      )
      let neighbor-offset-x = neighbor-position.x - rotated-parent-x
      let neighbor-offset-y = neighbor-position.y - rotated-parent-y
      let padding-units = 1pt / canvas-scale
      let symbol-width = content-width(symbol-text)
      let hydrogen-width = content-width(atom-label("H"))
      let (symbol-anchor, hydrogen-side) = if calc.abs(neighbor-offset-x) >= calc.abs(neighbor-offset-y) {
        if neighbor-offset-x > 0 { ("east", "west") } else { ("west", "east") }
      } else if neighbor-offset-y > 0 {
        ("north", "east")
      } else {
        ("south", "east")
      }

      let symbol-center = if symbol-anchor == "east" {
        (
          px
            - padding-units
            - content-width(if hydrogen-side == "west" { charge } else { [] })
            - symbol-width / 2,
          py,
        )
      } else if symbol-anchor == "west" {
        (px + padding-units + symbol-width / 2, py)
      } else if symbol-anchor == "north" {
        (px, py - content-height(symbol-text) / 2)
      } else {
        (px, py + content-height(symbol-text) / 2)
      }

      if fragment == "sym" {
        return symbol-center
      }

      let hydrogen-x = if hydrogen-side == "west" {
        symbol-center.at(0) - symbol-width / 2 - hydrogen-width / 2
      } else {
        symbol-center.at(0) + symbol-width / 2 + hydrogen-width / 2
      }
      return (hydrogen-x, symbol-center.at(1))
    }

    let stacked-h = degree >= 2 and not _is-carbon(atom)
    if stacked-h {
      if fragment == "h" {
        return (px, py + label-margin * 0.95)
      }
      let label-content = symbol-text + charge
      return (
        px - content-width(label-content) / 2 + content-width(symbol-text) / 2,
        py,
      )
    }

    let reverse-inline = if degree != 1 {
      false
    } else {
      let neighbor-index = first-neighbor(parent)
      if neighbor-index == none {
        false
      } else {
        let neighbor = placed-species.layout.atoms.at(neighbor-index)
        let neighbor-position = _rendered-atom-position(
          neighbor,
          placed-species.rotation,
          scale: molecule-scale,
        )
        neighbor-position.x - rotated-parent-x > 0.05
      }
    }
    let label-content = if reverse-inline {
      hydrogen-text + symbol-text + charge
    } else {
      symbol-text + hydrogen-text + charge
    }
    let left = px - content-width(label-content) / 2
    if fragment == "sym" {
      let prefix = if reverse-inline { hydrogen-text } else { [] }
      (left + content-width(prefix) + content-width(symbol-text) / 2, py)
    } else {
      let prefix = if reverse-inline { [] } else { symbol-text }
      (left + content-width(prefix) + content-width(atom-label("H")) / 2, py)
    }
  }

  if atom.at("virtual_h", default: false) {
    let parent = virtual-parent(atom-index)
    if parent == none { return base }
    return label-fragment-position(parent, "h")
  }

  if not _has-label(
    atom,
    show-all-h: show-all-h,
    force: show-h-list.contains(atom-index),
  ) {
    return base
  }
  let child = virtual-child(atom-index)
  if child == none { return base }
  label-fragment-position(atom-index, "sym")
}

// Find the bond record joining two atoms in a species' layout.
#let _find-bond-output(placed-species, first-atom-index, second-atom-index) = {
  for bond-output in placed-species.layout.bonds {
    if (
      bond-output.from == first-atom-index and bond-output.to == second-atom-index
    ) or (
      bond-output.from == second-atom-index and bond-output.to == first-atom-index
    ) {
      return bond-output
    }
  }
  panic(
    "no bond between atoms "
      + str(first-atom-index)
      + " and "
      + str(second-atom-index),
  )
}

// Geometry of the visible bond axis after atom-label trimming. Bond references
// use this same segment as the renderer, so their midpoint follows the painted
// line rather than the atom centers hidden behind labels.
#let _visible-bond-geometry(placed-species, first-atom-index, second-atom-index) = {
  let layout = placed-species.layout
  let bond-output = _find-bond-output(
    placed-species,
    first-atom-index,
    second-atom-index,
  )
  let molecule-scale = placed-species.at("mol-scale", default: 1.0)
  let rotation = placed-species.at("rotation", default: 0deg)
  let origin = placed-species.at("origin", default: (0, 0))
  let canvas-scale = placed-species.at("canvas-scale", default: 30pt)
  let font-size = placed-species.at("actual-font-size", default: 11pt)
  let font = placed-species.at("font", default: "New Computer Modern")
  let show-h-state = _normalize-show-h(
    placed-species.at("show-h", default: ()),
  )
  let show-all-h = show-h-state.all
  let show-h-list = show-h-state.indices
  let structural-bonds = layout.bonds.filter(
    bond => not bond.at("virtual_bond", default: false),
  )
  let atom-degree(atom-index) = structural-bonds.filter(
    bond => bond.from == atom-index or bond.to == atom-index,
  ).len()
  let force-linear-carbon-label(atom-index) = {
    let atom = layout.atoms.at(atom-index)
    if (
      not _is-carbon(atom)
        or atom.at("abbrev", default: "") != ""
        or atom-degree(atom-index) != 2
    ) {
      false
    } else {
      structural-bonds.filter(bond => (
        (bond.from == atom-index or bond.to == atom-index)
          and bond.order == 2
      )).len() == 2
    }
  }
  let forced-hydrogen(atom-index) = show-h-list.contains(atom-index)
  let has-label(atom-index) = {
    _has-label(
      layout.atoms.at(atom-index),
      show-all-h: show-all-h,
      force: forced-hydrogen(atom-index),
    ) or force-linear-carbon-label(atom-index)
  }
  let visible-hydrogen-count(atom-index) = {
    let atom = layout.atoms.at(atom-index)
    let count = atom.hcount + _visible-implicit-h(
      atom,
      show-all-h: show-all-h,
      force: forced-hydrogen(atom-index),
    )
    if atom.at("stereo_h", default: "none") != "none" {
      calc.max(0, count - 1)
    } else {
      count
    }
  }
  let atom-label(body, size: font-size) = text(
    size: size,
    font: font,
    style: "normal",
    weight: "regular",
    body,
  )
  let label-margin = calc.max(
    0.27 * molecule-scale,
    font-size / canvas-scale * 0.70,
  )
  let label-trim(atom, atom-index, direction-x, direction-y) = {
    let displays-hydrogen = visible-hydrogen-count(atom-index) > 0 and (
      show-all-h or forced-hydrogen(atom-index) or not _is-carbon(atom)
    )
    if not has-label(atom-index) {
      0.0
    } else if (
      displays-hydrogen
        and atom-degree(atom-index) == 1
        and not _is-carbon(atom)
    ) {
      0.06 * molecule-scale
    } else if (
      atom.at("abbrev", default: "") != ""
        and not displays-hydrogen
        and atom.charge == 0
        and atom.at("isotope", default: 0) == 0
    ) {
      let label-size = measure(_abbreviation-label(
        atom.at("abbrev", default: ""),
        atom-label,
        font-size,
        font-size,
      ))
      let half-width = label-size.width / canvas-scale / 2
      let half-height = label-size.height / canvas-scale / 2
      let extent = (
        half-width * calc.abs(direction-x)
          + half-height * calc.abs(direction-y)
          + 0.07 * molecule-scale
      )
      calc.min(
        label-margin,
        calc.max(0.14 * molecule-scale, extent),
      )
    } else if (
      atom.at("abbrev", default: "") == ""
        and not displays-hydrogen
        and atom.charge == 0
        and atom.at("isotope", default: 0) == 0
    ) {
      let label-size = measure(atom-label(atom.symbol))
      let half-width = label-size.width / canvas-scale / 2
      let half-height = label-size.height / canvas-scale / 2
      let extent = (
        half-width * calc.abs(direction-x)
          + half-height * calc.abs(direction-y)
          + 0.07 * molecule-scale
      )
      calc.min(
        label-margin,
        calc.max(0.14 * molecule-scale, extent),
      )
    } else {
      label-margin
    }
  }

  let from-atom = layout.atoms.at(bond-output.from)
  let to-atom = layout.atoms.at(bond-output.to)
  let from-local = _rendered-atom-position(
    from-atom,
    rotation,
    scale: molecule-scale,
  )
  let to-local = _rendered-atom-position(
    to-atom,
    rotation,
    scale: molecule-scale,
  )
  let from-position = (
    origin.at(0) + from-local.x,
    origin.at(1) + from-local.y,
  )
  let to-position = (
    origin.at(0) + to-local.x,
    origin.at(1) + to-local.y,
  )
  let offset-x = to-position.at(0) - from-position.at(0)
  let offset-y = to-position.at(1) - from-position.at(1)
  let atom-distance = calc.sqrt(offset-x * offset-x + offset-y * offset-y)
  let direction-x = if atom-distance > 0.001 {
    offset-x / atom-distance
  } else {
    1.0
  }
  let direction-y = if atom-distance > 0.001 {
    offset-y / atom-distance
  } else {
    0.0
  }
  let from-has-label = has-label(bond-output.from)
  let to-has-label = has-label(bond-output.to)
  let from-trim = label-trim(
    from-atom,
    bond-output.from,
    direction-x,
    direction-y,
  )
  let to-trim = label-trim(
    to-atom,
    bond-output.to,
    direction-x,
    direction-y,
  )
  let junction-overlap = 0.006 * molecule-scale
  let from-extension = if (
    not from-has-label and atom-degree(bond-output.from) > 1
  ) {
    junction-overlap
  } else {
    0.0
  }
  let to-extension = if (
    not to-has-label and atom-degree(bond-output.to) > 1
  ) {
    junction-overlap
  } else {
    0.0
  }
  let start = (
    from-position.at(0) + direction-x * (from-trim - from-extension),
    from-position.at(1) + direction-y * (from-trim - from-extension),
  )
  let end = (
    to-position.at(0) - direction-x * (to-trim - to-extension),
    to-position.at(1) - direction-y * (to-trim - to-extension),
  )
  (
    bond: bond-output,
    start: start,
    end: end,
    midpoint: (
      (start.at(0) + end.at(0)) / 2,
      (start.at(1) + end.at(1)) / 2,
    ),
    direction: (direction-x, direction-y),
    normal: (-direction-y, direction-x),
    atom-distance: atom-distance,
    from-position: from-position,
    to-position: to-position,
    from-degree: atom-degree(bond-output.from),
    to-degree: atom-degree(bond-output.to),
    from-has-label: from-has-label,
    to-has-label: to-has-label,
  )
}

// Point just outside the painted line selected by a curved arrow. Single bonds
// stay on their visible axis; multiple bonds use the outer line on the side
// facing the curve so the shaft never begins between parallel strokes.
#let _bond-arrow-attachment(reference, placed-species, toward) = {
  let geometry = _visible-bond-geometry(
    placed-species,
    reference.i,
    reference.j,
  )
  let reference-offset = reference.at("offset", default: (0, 0))
  let base = (
    geometry.midpoint.at(0) + reference-offset.at(0),
    geometry.midpoint.at(1) + reference-offset.at(1),
  )
  let bond-output = geometry.bond
  let aromatic = placed-species.at("aromatic", default: "kekule")
  if (
    bond-output.order <= 1
      or (
        aromatic == "circle"
          and bond-output.at("aromatic", default: false)
      )
  ) {
    return base
  }

  let normal-x = geometry.normal.at(0)
  let normal-y = geometry.normal.at(1)
  let toward-side = (
    (toward.at(0) - base.at(0)) * normal-x
      + (toward.at(1) - base.at(1)) * normal-y
  )
  let side = if toward-side < 0 { -1.0 } else { 1.0 }
  let molecule-scale = placed-species.at("mol-scale", default: 1.0)
  let canvas-scale = placed-species.at("canvas-scale", default: 30pt)
  let bond-stroke = placed-species.at(
    "actual-bond-stroke",
    default: 0.9pt * molecule-scale,
  )
  let stroke-units = bond-stroke / canvas-scale
  let double-gap = calc.max(
    0.065 * molecule-scale,
    stroke-units * 2.30,
  )
  let ring-double-gap = calc.max(
    0.09 * molecule-scale,
    stroke-units * 3.00,
  )
  let multiple-bond-trim = 0.10 * molecule-scale
  let selected-line-offset = 0.0
  let selected-axis-shift = 0.0

  if bond-output.order == 2 {
    let is-ring-bond = (
      bond-output.inner_x != 0.0 or bond-output.inner_y != 0.0
    )
    if is-ring-bond {
      let (inner-x, inner-y) = _rotate-point(
        bond-output.inner_x * molecule-scale,
        bond-output.inner_y * molecule-scale,
        placed-species.at("rotation", default: 0deg),
      )
      let inner-projection = (
        inner-x * normal-x + inner-y * normal-y
      ) * ring-double-gap / molecule-scale
      selected-line-offset = if side > 0 {
        calc.max(0.0, inner-projection)
      } else {
        calc.min(0.0, inner-projection)
      }
    } else {
      let has-hidden-simple-continuation = (
        geometry.from-degree == 2 and not geometry.from-has-label
      ) or (
        geometry.to-degree == 2 and not geometry.to-has-label
      )
      if has-hidden-simple-continuation {
        let structural-bonds = placed-species.layout.bonds.filter(
          bond => not bond.at("virtual_bond", default: false),
        )
        let offset-side(atom-index, other-index, atom-position) = {
          let result = 1.0
          for neighboring-bond in structural-bonds {
            if (
              neighboring-bond.from == atom-index
                or neighboring-bond.to == atom-index
            ) and not (
              neighboring-bond.from == other-index
                or neighboring-bond.to == other-index
            ) {
              let neighbor-index = if neighboring-bond.from == atom-index {
                neighboring-bond.to
              } else {
                neighboring-bond.from
              }
              let neighbor = placed-species.layout.atoms.at(neighbor-index)
              let neighbor-position = _rendered-atom-position(
                neighbor,
                placed-species.at("rotation", default: 0deg),
                scale: molecule-scale,
              )
              let vector-x = (
                placed-species.origin.at(0) + neighbor-position.x
                  - atom-position.at(0)
              )
              let vector-y = (
                placed-species.origin.at(1) + neighbor-position.y
                  - atom-position.at(1)
              )
              result = if (
                vector-x * normal-x + vector-y * normal-y >= 0.0
              ) {
                1.0
              } else {
                -1.0
              }
            }
          }
          result
        }
        let inner-side = if (
          geometry.from-degree == 2 and not geometry.from-has-label
        ) {
          offset-side(
            bond-output.from,
            bond-output.to,
            geometry.from-position,
          )
        } else {
          offset-side(
            bond-output.to,
            bond-output.from,
            geometry.to-position,
          )
        }
        let inner-offset = double-gap * 1.12 * inner-side
        let selected-inner-line = (
          side > 0 and inner-offset > 0
        ) or (
          side < 0 and inner-offset < 0
        )
        if selected-inner-line {
          selected-line-offset = inner-offset
          let trim = calc.min(
            multiple-bond-trim,
            geometry.atom-distance * 0.25,
          )
          let from-trim = if (
            geometry.from-degree > 1 and not geometry.from-has-label
          ) { trim } else { 0.0 }
          let to-trim = if (
            geometry.to-degree > 1 and not geometry.to-has-label
          ) { trim } else { 0.0 }
          selected-axis-shift = (from-trim - to-trim) / 2
        }
      } else {
        selected-line-offset = double-gap * side
        let extension = 0.04 * molecule-scale
        let from-extension = if geometry.from-degree > 2 {
          extension
        } else {
          0.0
        }
        let to-extension = if geometry.to-degree > 2 {
          extension
        } else {
          0.0
        }
        selected-axis-shift = (
          to-extension - from-extension
        ) / 2
      }
    }
  } else if bond-output.order == 3 {
    selected-line-offset = double-gap * 1.3 * side
  } else {
    selected-line-offset = double-gap * 1.5 * side
  }

  let line-clearance = bond-stroke / canvas-scale / 2 + 1pt / canvas-scale
  (
    base.at(0)
      + geometry.direction.at(0) * selected-axis-shift
      + normal-x * (selected-line-offset + side * line-clearance),
    base.at(1)
      + geometry.direction.at(1) * selected-axis-shift
      + normal-y * (selected-line-offset + side * line-clearance),
  )
}

// Visible atom labels attach at the symbol edge; unlabeled skeletal atoms attach
// at their vertex. The shared endpoint gap is applied afterward along the curve.
#let _atom-arrow-attachment(reference, placed-species, toward) = {
  let center = _atom-position(placed-species, reference.index)
  let atom = placed-species.layout.atoms.at(reference.index)
  let canvas-scale = placed-species.at("canvas-scale", default: 30pt)
  let font-size = placed-species.at("actual-font-size", default: 11pt)
  let font = placed-species.at("font", default: "New Computer Modern")
  let show-h-state = _normalize-show-h(
    placed-species.at("show-h", default: ()),
  )
  let structural-bonds = placed-species.layout.bonds.filter(
    bond => not bond.at("virtual_bond", default: false),
  )
  let atom-degree = structural-bonds.filter(
    bond => bond.from == reference.index or bond.to == reference.index,
  ).len()
  let force-linear-carbon-label = (
    _is-carbon(atom)
      and atom.at("abbrev", default: "") == ""
      and atom-degree == 2
      and structural-bonds.filter(bond => (
        (bond.from == reference.index or bond.to == reference.index)
          and bond.order == 2
      )).len() == 2
  )
  let visible-label = (
    atom.at("virtual_h", default: false)
      or _has-label(
        atom,
        show-all-h: show-h-state.all,
        force: show-h-state.indices.contains(reference.index),
      )
      or force-linear-carbon-label
  )
  if not visible-label {
    let offset = reference.at("offset", default: (0, 0))
    return (
      center.at(0) + offset.at(0),
      center.at(1) + offset.at(1),
    )
  }

  let label = if atom.at("virtual_h", default: false) {
    text(size: font-size, font: font, "H")
  } else if atom.at("abbrev", default: "") != "" {
    _abbreviation-label(
      atom.at("abbrev", default: ""),
      (body, size: font-size) => text(
        size: size,
        font: font,
        style: "normal",
        weight: "regular",
        body,
      ),
      font-size,
      font-size,
    )
  } else {
    text(
      size: font-size,
      font: font,
      style: "normal",
      weight: "regular",
      atom.symbol,
    )
  }
  let measured-label = measure(label)
  let half-width = measured-label.width / canvas-scale / 2
  let half-height = measured-label.height / canvas-scale / 2
  let offset = reference.at("offset", default: (0, 0))
  let direction-x = toward.at(0) - center.at(0)
  let direction-y = toward.at(1) - center.at(1)
  if calc.abs(direction-x) < 1e-6 and calc.abs(direction-y) < 1e-6 {
    return (
      center.at(0) + offset.at(0),
      center.at(1) + offset.at(1),
    )
  }
  let horizontal-intersection = if calc.abs(direction-x) < 1e-6 {
    1e9
  } else {
    half-width / calc.abs(direction-x)
  }
  let vertical-intersection = if calc.abs(direction-y) < 1e-6 {
    1e9
  } else {
    half-height / calc.abs(direction-y)
  }
  let intersection = calc.min(
    horizontal-intersection,
    vertical-intersection,
  )
  (
    center.at(0) + direction-x * intersection + offset.at(0),
    center.at(1) + direction-y * intersection + offset.at(1),
  )
}

// Resolve a reference dictionary to an absolute canvas coordinate.
// `placed-species-list` contains the placed species records; `lone-pair-offset`
// is the radial
// distance of a lone pair from its atom (in bond-length units).
#let _resolve-reference(reference, placed-species-list, lone-pair-offset) = {
  let apply-reference-offset(point) = {
    let offset = reference.at("offset", default: (0, 0))
    (point.at(0) + offset.at(0), point.at(1) + offset.at(1))
  }
  let kind = reference.__ref__
  if kind == "atom" {
    apply-reference-offset(_atom-position(
      placed-species-list.at(reference.species),
      reference.index,
    ))
  } else if kind == "bond" {
    let placed-species = placed-species-list.at(reference.species)
    let geometry = _visible-bond-geometry(
      placed-species,
      reference.i,
      reference.j,
    )
    apply-reference-offset(geometry.midpoint)
  } else if kind == "lp" {
    let placed-species = placed-species-list.at(reference.species)
    let molecule-scale = placed-species.at("mol-scale", default: 1.0)
    let atom = placed-species.layout.atoms.at(reference.atom)
    let atom-position = _atom-position(placed-species, reference.atom)
    let abbreviation = atom.at("abbrev", default: "")
    if abbreviation != "" {
      // Custom labels compute pair positions in screen space; mirror the
      // drawing pass exactly by calling the shared helper with the same
      // (mol-scale-free) units, then apply mol-scale once at the end.
      let canvas-scale = placed-species.at("canvas-scale", default: 30pt)
      let font-size = placed-species.at("actual-font-size", default: 11pt) / molecule-scale
      let font = placed-species.at("font", default: "New Computer Modern")
      let abbreviation-position = _atom-position(
        placed-species,
        reference.atom,
      )
      let bond-directions = ()
      for bond-output in placed-species.layout.bonds {
        if bond-output.at("virtual_bond", default: false) { continue }
        let other-index = if bond-output.from == reference.atom {
          bond-output.to
        } else if bond-output.to == reference.atom {
          bond-output.from
        } else {
          none
        }
        if other-index != none {
          let neighbor-position = _atom-position(
            placed-species,
            other-index,
          )
          let offset-x = (
            neighbor-position.at(0) - abbreviation-position.at(0)
          )
          let offset-y = (
            neighbor-position.at(1) - abbreviation-position.at(1)
          )
          let distance = calc.sqrt(offset-x * offset-x + offset-y * offset-y)
          if distance > 0.001 {
            bond-directions.push((
              x: offset-x / distance,
              y: offset-y / distance,
            ))
          }
        }
      }
      let margin = calc.max(0.08, font-size / canvas-scale * 0.34)
      let placements = _abbreviation-lone-pair-directions(
        abbreviation,
        atom.at("abbrev_anchor", default: 0),
        atom.at("abbrev_anchor_len", default: 0),
        atom.at("lone_pairs", default: 1),
        bond-directions,
        canvas-scale,
        font-size,
        font,
        margin,
      )
      if placements.len() == 0 {
        apply-reference-offset(atom-position)
      } else {
        let placement = placements.at(reference.pair)
        apply-reference-offset((
          atom-position.at(0) + placement.dir.x * placement.offset * molecule-scale,
          atom-position.at(1) + placement.dir.y * placement.offset * molecule-scale,
        ))
      }
    } else {
      let directions = atom.at("lone_pair_dirs", default: ())
      if directions.len() == 0 {
        apply-reference-offset(atom-position)
      } else {
        let direction = directions.at(reference.pair)
        let (direction-x, direction-y) = _rotate-point(
          direction.x,
          direction.y,
          placed-species.rotation,
        )
        apply-reference-offset((
          atom-position.at(0) + direction-x * lone-pair-offset * molecule-scale,
          atom-position.at(1) + direction-y * lone-pair-offset * molecule-scale,
        ))
      }
    }
  } else if kind == "species" {
    // Bounding-box center of an opaque item; edge selection happens at draw time.
    let placed-species = placed-species-list.at(reference.index)
    apply-reference-offset(placed-species.origin)
  } else {
    panic("unknown reference kind: " + kind)
  }
}

// ── Annotation constructors (consumed by smiles() and reaction()) ───────────────

/// References an atom by index. `atom(i)` inside `smiles()`, or `atom(s, i)`
/// inside `reaction()` where `s` is the species (molecule) index. `offset` nudges
/// the point in bond-length units.
#let atom(..a) = {
  let arguments = a
  let positional = arguments.pos()
  _validate-named-arguments(arguments, ("offset",), "atom()")
  if positional.len() not in (1, 2) {
    _invalid-input(
      "atom() positional arguments",
      "expected atom(i) or atom(species, i), got "
        + str(positional.len())
        + " values",
      "Pass one local atom index or a species index followed by an atom index.",
    )
  }
  let (species-index, atom-index) = if positional.len() == 1 {
    (0, positional.at(0))
  } else {
    (positional.at(0), positional.at(1))
  }
  _validate-index(species-index, "atom() species index")
  _validate-index(atom-index, "atom() atom index")
  let offset = arguments.named().at("offset", default: (0, 0))
  _validate-offset(offset, "atom() offset")
  (
    __ref__: "atom",
    species: species-index,
    index: atom-index,
    offset: offset,
  )
}

/// References the midpoint of the visible, label-trimmed bond stroke:
/// `bond(i, j)` or `bond(s, i, j)`. Curved arrows attach outside the
/// multiple-bond line facing the curve.
#let bond(..a) = {
  let arguments = a
  let positional = arguments.pos()
  _validate-named-arguments(arguments, ("offset",), "bond()")
  if positional.len() not in (2, 3) {
    _invalid-input(
      "bond() positional arguments",
      "expected bond(i, j) or bond(species, i, j), got "
        + str(positional.len())
        + " values",
      "Pass two local atom indices or a species index followed by two atom indices.",
    )
  }
  let (species-index, first-atom-index, second-atom-index) = if positional.len() == 2 {
    (0, positional.at(0), positional.at(1))
  } else {
    (positional.at(0), positional.at(1), positional.at(2))
  }
  _validate-index(species-index, "bond() species index")
  _validate-index(first-atom-index, "bond() first atom index")
  _validate-index(second-atom-index, "bond() second atom index")
  if first-atom-index == second-atom-index {
    _invalid-input(
      "bond() atom indices",
      "both endpoints use atom index " + str(first-atom-index),
      "Reference two different atoms joined by a visible bond.",
    )
  }
  let offset = arguments.named().at("offset", default: (0, 0))
  _validate-offset(offset, "bond() offset")
  (
    __ref__: "bond",
    species: species-index,
    i: first-atom-index,
    j: second-atom-index,
    offset: offset,
  )
}

/// References a lone pair on an atom: `lp(i)` or `lp(s, i)`, with `pair:` selecting
/// which pair (default 0) when an atom carries several.
#let lp(..a) = {
  let arguments = a
  let positional = arguments.pos()
  _validate-named-arguments(arguments, ("pair", "offset"), "lp()")
  if positional.len() not in (1, 2) {
    _invalid-input(
      "lp() positional arguments",
      "expected lp(i) or lp(species, i), got "
        + str(positional.len())
        + " values",
      "Pass one local atom index or a species index followed by an atom index.",
    )
  }
  let (species-index, atom-index) = if positional.len() == 1 {
    (0, positional.at(0))
  } else {
    (positional.at(0), positional.at(1))
  }
  _validate-index(species-index, "lp() species index")
  _validate-index(atom-index, "lp() atom index")
  let pair-index = arguments.named().at("pair", default: 0)
  _validate-index(pair-index, "lp() pair index")
  let offset = arguments.named().at("offset", default: (0, 0))
  _validate-offset(offset, "lp() offset")
  (
    __ref__: "lp",
    species: species-index,
    atom: atom-index,
    pair: pair-index,
    offset: offset,
  )
}

/// References a whole placed species (e.g. a `ce()` formula) by its index, snapping
/// to its bounding-box edge. Used when no interior atom is addressable.
#let species(k, offset: (0, 0)) = {
  _validate-index(k, "species() index")
  _validate-offset(offset, "species() offset")
  (__ref__: "species", index: k, offset: offset)
}

/// A curly electron-pushing arrow between two references.
///
/// - from (dictionary): source reference — `lp()`, `bond()`, `atom()`, `species()`.
/// - to (dictionary): destination reference.
/// - label (content): optional label drawn at the curve apex.
/// - color (color): arrow color. Default: black.
/// - stroke (auto / length): Shaft width before scaling. `auto` matches the
///   molecule's bond stroke. Default: auto.
/// - bend (str): "left", "right", or none (straight). Which way the curve bows.
/// - angle (angle): how strongly the curve bows. Default: 15deg.
/// - half (bool): draw half (fishhook) arrowheads for single-electron flow;
///   applies to every head selected by `heads`.
/// - heads (str): which ends carry an arrowhead — "end" (default), "both", or
///   "none".
/// - head-length (float): triangle-tip length along the shaft, in bond-length
///   units (before `scale`). Applies to every drawn head. Default: 0.11.
/// - head-width (float): triangle-tip base width, in bond-length units (before
///   `scale`). Applies to every drawn head. Default: 0.07.
/// - style (str): shaft style — "solid" (default), "dashed", or "wavy".
/// -> dictionary  (consumed by smiles()/reaction())
#let arrow(from: none, to: none, label: none, color: black, stroke: auto, bend: "left", angle: 15deg, half: false, heads: "end", head-length: 0.11, head-width: 0.07, style: "solid") = {
  if type(from) != dictionary or from.at("__ref__", default: "") == "" {
    _invalid-input(
      "arrow from",
      "expected atom(), bond(), lp(), or species(), got " + repr(from),
      "Pass a reference constructor as the arrow source.",
    )
  }
  if type(to) != dictionary or to.at("__ref__", default: "") == "" {
    _invalid-input(
      "arrow to",
      "expected atom(), bond(), lp(), or species(), got " + repr(to),
      "Pass a reference constructor as the arrow destination.",
    )
  }
  if type(color) != _color-type {
    _invalid-input(
      "arrow color",
      "expected a color, got " + repr(color),
      "Pass a Typst color value.",
    )
  }
  _validate-positive-length(stroke, "arrow stroke", allow-auto: true)
  if bend != none and bend not in ("left", "right") {
    _invalid-input(
      "arrow bend",
      "expected \"left\", \"right\", or none, got " + repr(bend),
      "Choose a supported bend direction.",
    )
  }
  if type(angle) != _angle-type {
    _invalid-input(
      "arrow angle",
      "expected an angle, got " + repr(angle),
      "Pass an angle such as 15deg.",
    )
  }
  _validate-bool(half, "arrow half")
  if heads not in ("end", "both", "none") {
    _invalid-input(
      "arrow heads",
      "expected \"end\", \"both\", or \"none\", got " + repr(heads),
      "Choose one of the supported arrowhead placements.",
    )
  }
  _validate-positive-number(head-length, "arrow head-length")
  _validate-positive-number(head-width, "arrow head-width")
  if style not in ("solid", "dashed", "wavy") {
    _invalid-input(
      "arrow style",
      "expected \"solid\", \"dashed\", or \"wavy\", got " + repr(style),
      "Choose one of the supported shaft styles.",
    )
  }
  (
    __arrow__: true,
    from: from,
    to: to,
    label: label,
    color: color,
    stroke: stroke,
    bend: bend,
    angle: angle,
    half: half,
    heads: heads,
    head-length: head-length,
    head-width: head-width,
    style: style,
  )
}

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
#let highlight(ref, fill: rgb("#FFE45C"), stroke: none, radius: auto, include-atoms: false) = {
  let references = if type(ref) == array { ref } else { (ref,) }
  if references.len() == 0 {
    _invalid-input(
      "highlight reference",
      "the reference array is empty",
      "Pass at least one atom() or bond() reference.",
    )
  }
  for reference in references {
    if (
      type(reference) != dictionary
        or reference.at("__ref__", default: "") not in ("atom", "bond")
    ) {
      _invalid-input(
        "highlight reference",
        "expected atom() or bond(), got " + repr(reference),
        "Pass one reference or an array of atom()/bond() references.",
      )
    }
  }
  if type(fill) != _color-type {
    _invalid-input(
      "highlight fill",
      "expected a color, got " + repr(fill),
      "Pass a Typst color value.",
    )
  }
  if (
    stroke != none
      and type(stroke) not in (_stroke-type, _color-type, _length-type)
  ) {
    _invalid-input(
      "highlight stroke",
      "expected none or a stroke, got " + repr(stroke),
      "Pass none, a color, a length, or a stroke dictionary.",
    )
  }
  if radius != auto {
    _validate-positive-number(radius, "highlight radius")
  }
  _validate-bool(include-atoms, "highlight include-atoms")
  (
    __highlight__: true,
    ref: ref,
    fill: fill,
    stroke: stroke,
    radius: radius,
    include-atoms: include-atoms,
  )
}

// ── Annotation drawing ──────────────────────────────────────────────────────────

#let _validate-reference(reference, placed-species-list, input-context, allowed-kinds) = {
  if type(reference) != dictionary {
    _invalid-input(
      input-context,
      "expected a reference, got " + repr(reference),
      "Use atom(), bond(), lp(), or species().",
    )
  }
  let kind = reference.at("__ref__", default: "")
  if kind not in allowed-kinds {
    _invalid-input(
      input-context,
      "reference kind " + repr(kind) + " is not supported here",
      "Use "
        + allowed-kinds.map(name => name + "()").join(", ")
        + ".",
    )
  }
  let offset = reference.at("offset", default: (0, 0))
  _validate-offset(offset, input-context + " offset")
  let species-index = if kind == "species" {
    reference.at("index", default: none)
  } else {
    reference.at("species", default: none)
  }
  _validate-index(species-index, input-context + " species index")
  if species-index >= placed-species-list.len() {
    _invalid-input(
      input-context + " species index",
      str(species-index) + " does not exist",
      _available-index-description(placed-species-list.len())
        + " Species indices count mol() and visible content items; rxn-arrow() itself does not count as a species.",
    )
  }
  if kind == "species" {
    return
  }

  let placed-species = placed-species-list.at(species-index)
  if "layout" not in placed-species {
    _invalid-input(
      input-context,
      "species "
        + str(species-index)
        + " is opaque content and has no addressable atoms",
      "Use species("
        + str(species-index)
        + ") for the whole item, or wrap a SMILES string in mol() to address its atoms.",
    )
  }
  let layout = placed-species.layout
  let atom-indices = if kind == "bond" {
    (
      reference.at("i", default: none),
      reference.at("j", default: none),
    )
  } else if kind == "lp" {
    (reference.at("atom", default: none),)
  } else {
    (reference.at("index", default: none),)
  }
  for atom-index in atom-indices {
    _validate-index(atom-index, input-context + " atom index")
    if atom-index >= layout.atoms.len() {
      _invalid-input(
        input-context + " atom index",
        str(atom-index)
          + " does not exist in species "
          + str(species-index),
        _available-index-description(layout.atoms.len())
          + " Enable show-indices: true to inspect this molecule.",
      )
    }
  }

  if kind == "bond" {
    if reference.i == reference.j {
      _invalid-input(
        input-context,
        "bond endpoints both use atom index " + str(reference.i),
        "Reference two different atoms joined by a visible bond.",
      )
    }
    let matching-bonds = layout.bonds.filter(bond-output => (
      not bond-output.at("virtual_bond", default: false)
        and (
          (bond-output.from == reference.i and bond-output.to == reference.j)
            or (
              bond-output.from == reference.j
                and bond-output.to == reference.i
            )
        )
    ))
    if matching-bonds.len() == 0 {
      _invalid-input(
        input-context,
        "atoms "
          + str(reference.i)
          + " and "
          + str(reference.j)
          + " are not joined by a visible bond in species "
          + str(species-index),
        "Enable show-indices: true and reference the endpoints of an existing bond.",
      )
    }
  } else {
    let atom-index = atom-indices.first()
    if kind == "lp" {
      let pair-index = reference.at("pair", default: none)
      _validate-index(pair-index, input-context + " pair index")
      let pair-count = layout.atoms.at(atom-index).at("lone_pairs", default: 0)
      if pair-count == 0 {
        _invalid-input(
          input-context,
          "atom "
            + str(atom-index)
            + " in species "
            + str(species-index)
            + " has no addressable lone pairs",
          "Choose an atom with a lone pair; custom labels must declare lp=N.",
        )
      }
      if pair-index >= pair-count {
        _invalid-input(
          input-context + " pair index",
          str(pair-index)
            + " does not exist on atom "
            + str(atom-index),
          _available-index-description(pair-count),
        )
      }
    }
  }
}

#let _validate-annotation(annotation, placed-species-list, input-context) = {
  if type(annotation) != dictionary {
    _invalid-input(
      input-context,
      "expected arrow() or highlight(), got " + repr(annotation),
      "Pass only annotation constructors in positional annotation slots.",
    )
  }
  if annotation.at("__arrow__", default: false) {
    _validate-reference(
      annotation.at("from", default: none),
      placed-species-list,
      input-context + " from reference",
      ("atom", "bond", "lp", "species"),
    )
    _validate-reference(
      annotation.at("to", default: none),
      placed-species-list,
      input-context + " to reference",
      ("atom", "bond", "lp", "species"),
    )
  } else if annotation.at("__highlight__", default: false) {
    let references = if type(annotation.ref) == array {
      annotation.ref
    } else {
      (annotation.ref,)
    }
    if references.len() == 0 {
      _invalid-input(
        input-context,
        "the highlight reference array is empty",
        "Pass at least one atom() or bond() reference.",
      )
    }
    for reference in references {
      _validate-reference(
        reference,
        placed-species-list,
        input-context + " reference",
        ("atom", "bond"),
      )
    }
  } else {
    _invalid-input(
      input-context,
      "expected arrow() or highlight(), got " + repr(annotation),
      "Pass only annotation constructors in positional annotation slots.",
    )
  }
}

#let _validate-annotations(annotations, placed-species-list, input-context) = {
  for annotation-index in range(annotations.len()) {
    _validate-annotation(
      annotations.at(annotation-index),
      placed-species-list,
      input-context + " " + str(annotation-index),
    )
  }
}

// Endpoint coordinate for an arrow; species references snap to the box edge facing
// `toward`.
#let _arrow-endpoint(reference, placed-species-list, configuration, toward) = {
  let reference-position = _resolve-reference(
    reference,
    placed-species-list,
    configuration.lp-offset,
  )
  if reference.__ref__ == "bond" {
    return _bond-arrow-attachment(
      reference,
      placed-species-list.at(reference.species),
      toward,
    )
  }
  if reference.__ref__ == "atom" {
    return _atom-arrow-attachment(
      reference,
      placed-species-list.at(reference.species),
      toward,
    )
  }
  if reference.__ref__ != "species" { return reference-position }
  let placed-species = placed-species-list.at(reference.index)
  // Intersect the ray from the origin toward the target with the molecule's
  // actual, possibly asymmetric bounds rather than a symmetric half-box.
  let bounds = placed-species.at("bounds", default: (
    left: placed-species.size.at(0) / 2, right: placed-species.size.at(0) / 2,
    bottom: placed-species.size.at(1) / 2, top: placed-species.size.at(1) / 2,
  ))
  let offset-x = toward.at(0) - reference-position.at(0)
  let offset-y = toward.at(1) - reference-position.at(1)
  if offset-x == 0 and offset-y == 0 { return reference-position }
  let horizontal-intersection = if offset-x > 0 {
    bounds.right / offset-x
  } else if offset-x < 0 {
    bounds.left / (-offset-x)
  } else {
    1e9
  }
  let vertical-intersection = if offset-y > 0 {
    bounds.top / offset-y
  } else if offset-y < 0 {
    bounds.bottom / (-offset-y)
  } else {
    1e9
  }
  let intersection = calc.min(horizontal-intersection, vertical-intersection)
  (
    reference-position.at(0) + offset-x * intersection,
    reference-position.at(1) + offset-y * intersection,
  )
}

#let _draw-highlight(highlight-specification, placed-species-list, configuration) = {
  import cetz.draw: *
  let references = if type(highlight-specification.ref) == array {
    highlight-specification.ref
  } else {
    (highlight-specification.ref,)
  }
  for reference in references {
    if reference.__ref__ == "bond" {
      let placed-species = placed-species-list.at(reference.species)
      let molecule-scale = placed-species.at("mol-scale", default: 1.0)
      let first-position = _atom-position(placed-species, reference.i)
      let second-position = _atom-position(placed-species, reference.j)
      let offset-x = second-position.at(0) - first-position.at(0)
      let offset-y = second-position.at(1) - first-position.at(1)
      let distance = calc.max(
        1e-6,
        calc.sqrt(offset-x * offset-x + offset-y * offset-y),
      )
      let trim = if highlight-specification.include-atoms {
        0.0
      } else {
        calc.min(configuration.bond-trim * molecule-scale, distance * 0.45)
      }
      let direction-x = offset-x / distance
      let direction-y = offset-y / distance
      line(
        (
          first-position.at(0) + direction-x * trim,
          first-position.at(1) + direction-y * trim,
        ),
        (
          second-position.at(0) - direction-x * trim,
          second-position.at(1) - direction-y * trim,
        ),
        stroke: (
          paint: highlight-specification.fill,
          thickness: configuration.bond-thickness * molecule-scale,
          cap: "round",
        ),
      )
      if highlight-specification.include-atoms {
        let radius = if highlight-specification.radius == auto {
          configuration.atom-radius * molecule-scale
        } else {
          highlight-specification.radius
        }
        circle(
          first-position,
          radius: radius,
          fill: highlight-specification.fill,
          stroke: highlight-specification.stroke,
        )
        circle(
          second-position,
          radius: radius,
          fill: highlight-specification.fill,
          stroke: highlight-specification.stroke,
        )
      }
    } else {
      let reference-position = _resolve-reference(
        reference,
        placed-species-list,
        configuration.lp-offset,
      )
      let placed-species = placed-species-list.at(reference.species)
      let molecule-scale = placed-species.at("mol-scale", default: 1.0)
      let atom = placed-species.layout.atoms.at(reference.index)
      let abbreviation = atom.at("abbrev", default: "")
      if reference.__ref__ == "atom" and abbreviation != "" {
        let canvas-scale = placed-species.at("canvas-scale", default: 30pt)
        let font-size = placed-species.at("actual-font-size", default: 11pt)
        let font = placed-species.at("font", default: "New Computer Modern")
        let atom-label = (body, size: font-size) => text(
          size: size, font: font, style: "normal", weight: "regular", body,
        )
        let label = _abbreviation-label(abbreviation, atom-label, font-size, font-size)
        let label-width-units = measure(label).width / canvas-scale
        let label-width = body => measure(_abbreviation-label(body, atom-label, font-size, font-size)).width / canvas-scale
        let center-x = reference-position.at(0) - _label-anchor-offset(
          abbreviation,
          atom.at("abbrev_anchor", default: 0),
          atom.at("abbrev_anchor_len", default: 0),
          label-width,
        )
        let label-height-units = measure(label).height / canvas-scale
        let horizontal-padding = calc.max(
          0.08 * molecule-scale,
          font-size / canvas-scale * 0.16,
        )
        let thickness = canvas-scale * calc.max(
          label-height-units + font-size / canvas-scale * 0.55,
          configuration.atom-radius * molecule-scale * 1.7,
        )
        line(
          (
            center-x - label-width-units / 2 - horizontal-padding,
            reference-position.at(1),
          ),
          (
            center-x + label-width-units / 2 + horizontal-padding,
            reference-position.at(1),
          ),
          stroke: (
            paint: highlight-specification.fill,
            thickness: thickness,
            cap: "round",
          ),
        )
      } else {
        let radius = if highlight-specification.radius == auto {
          configuration.atom-radius * molecule-scale
        } else {
          highlight-specification.radius
        }
        circle(
          reference-position,
          radius: radius,
          fill: highlight-specification.fill,
          stroke: highlight-specification.stroke,
        )
      }
    }
  }
}

#let _arrow-curve-geometry(start, end, bend, angle) = {
  let offset-x = end.at(0) - start.at(0)
  let offset-y = end.at(1) - start.at(1)
  let distance = calc.max(
    1e-6,
    calc.sqrt(offset-x * offset-x + offset-y * offset-y),
  )
  let direction-x = offset-x / distance
  let direction-y = offset-y / distance
  let sign = if bend == "right" {
    -1.0
  } else if bend == "left" {
    1.0
  } else {
    0.0
  }
  let normal-x = -direction-y
  let normal-y = direction-x
  let midpoint-x = (start.at(0) + end.at(0)) / 2
  let midpoint-y = (start.at(1) + end.at(1)) / 2
  let bend-magnitude = distance / 2 * calc.tan(angle) * sign
  (
    distance: distance,
    direction: (direction-x, direction-y),
    normal: (normal-x, normal-y),
    midpoint: (midpoint-x, midpoint-y),
    bend-magnitude: bend-magnitude,
    sign: sign,
    apex: (
      midpoint-x + normal-x * bend-magnitude,
      midpoint-y + normal-y * bend-magnitude,
    ),
  )
}

#let _draw-arrow(arrow-specification, placed-species-list, configuration) = {
  import cetz.draw: *
  let heads = arrow-specification.at("heads", default: "end")
  if heads not in ("end", "both", "none") {
    panic("arrow heads must be \"end\", \"both\", or \"none\"")
  }
  let style = arrow-specification.at("style", default: "solid")
  if style not in ("solid", "dashed", "wavy") {
    panic("arrow style must be \"solid\", \"dashed\", or \"wavy\"")
  }
  let raw-start = _resolve-reference(
    arrow-specification.from,
    placed-species-list,
    configuration.lp-offset,
  )
  let raw-end = _resolve-reference(
    arrow-specification.to,
    placed-species-list,
    configuration.lp-offset,
  )
  let initial-geometry = _arrow-curve-geometry(
    raw-start,
    raw-end,
    arrow-specification.bend,
    arrow-specification.angle,
  )
  let start = _arrow-endpoint(
    arrow-specification.from,
    placed-species-list,
    configuration,
    initial-geometry.apex,
  )
  let end = _arrow-endpoint(
    arrow-specification.to,
    placed-species-list,
    configuration,
    initial-geometry.apex,
  )
  let attached-geometry = _arrow-curve-geometry(
    start,
    end,
    arrow-specification.bend,
    arrow-specification.angle,
  )
  let move-toward(point, target, amount) = {
    let offset-x = target.at(0) - point.at(0)
    let offset-y = target.at(1) - point.at(1)
    let distance = calc.sqrt(offset-x * offset-x + offset-y * offset-y)
    if distance <= 1e-6 {
      point
    } else {
      let movement = calc.min(amount, distance * 0.25)
      (
        point.at(0) + offset-x / distance * movement,
        point.at(1) + offset-y / distance * movement,
      )
    }
  }
  let inset-start = (
    move-toward(
      start,
      attached-geometry.apex,
      configuration.endpoint-gap,
    )
  )
  let inset-end = (
    move-toward(
      end,
      attached-geometry.apex,
      configuration.endpoint-gap,
    )
  )
  let geometry = _arrow-curve-geometry(
    inset-start,
    inset-end,
    arrow-specification.bend,
    arrow-specification.angle,
  )
  let distance = geometry.distance
  let direction-x = geometry.direction.at(0)
  let direction-y = geometry.direction.at(1)
  let sign = geometry.sign
  let normal-x = geometry.normal.at(0)
  let normal-y = geometry.normal.at(1)
  let midpoint-x = geometry.midpoint.at(0)
  let midpoint-y = geometry.midpoint.at(1)
  let bend-magnitude = geometry.bend-magnitude
  let apex = geometry.apex

  let arrowhead-options = (
    fill: arrow-specification.color,
    scale: configuration.arrow-scale,
    harpoon: arrow-specification.half,
    length: arrow-specification.at("head-length", default: 0.11),
    width: arrow-specification.at("head-width", default: 0.07),
  )
  let arrowheads = if heads == "none" { none }
           else if heads == "both" { (..arrowhead-options, start: ">", end: ">") }
           else { (..arrowhead-options, end: ">") }
  let arrow-thickness = if arrow-specification.at("stroke", default: auto) == auto {
    configuration.arrow-thickness
  } else {
    arrow-specification.stroke * configuration.arrow-scale
  }
  let arrow-stroke = if style == "dashed" {
    (paint: arrow-specification.color, thickness: arrow-thickness,
     dash: (array: (3pt * configuration.arrow-scale, 2.2pt * configuration.arrow-scale), phase: 0pt))
  } else {
    (paint: arrow-specification.color, thickness: arrow-thickness)
  }

  if style == "wavy" {
    // Parametrize the shaft — the straight segment or the bend's quadratic
    // through the apex — and lay a sine wave along its normals. The wave spans
    // a whole number of half-periods so it meets the ends flat, and each drawn
    // head sits on a short straight lead pointing along the travel direction.
    let control-point = (
      2 * apex.at(0) - (inset-start.at(0) + inset-end.at(0)) / 2,
      2 * apex.at(1) - (inset-start.at(1) + inset-end.at(1)) / 2,
    )
    let point-on-shaft(position) = if sign == 0 {
      (
        inset-start.at(0) + (inset-end.at(0) - inset-start.at(0)) * position,
        inset-start.at(1) + (inset-end.at(1) - inset-start.at(1)) * position,
      )
    } else {
      let remaining = 1 - position
      (
        remaining * remaining * inset-start.at(0)
          + 2 * position * remaining * control-point.at(0)
          + position * position * inset-end.at(0),
        remaining * remaining * inset-start.at(1)
          + 2 * position * remaining * control-point.at(1)
          + position * position * inset-end.at(1),
      )
    }
    let tangent(position) = if sign == 0 {
      (
        inset-end.at(0) - inset-start.at(0),
        inset-end.at(1) - inset-start.at(1),
      )
    } else {
      let remaining = 1 - position
      (
        2 * remaining * (control-point.at(0) - inset-start.at(0))
          + 2 * position * (inset-end.at(0) - control-point.at(0)),
        2 * remaining * (control-point.at(1) - inset-start.at(1))
          + 2 * position * (inset-end.at(1) - control-point.at(1)),
      )
    }
    let lead-length = calc.min(0.3, distance * 0.25)
    let wave-start = if heads == "both" { lead-length / distance } else { 0.0 }
    let wave-end = if heads == "none" { 1.0 } else { 1.0 - lead-length / distance }
    let wave-span = wave-end - wave-start
    let amplitude = 0.075
    let half-wave-count = calc.max(
      2,
      int(calc.round(distance * wave-span / 0.25)),
    )
    let segment-count = calc.max(24, half-wave-count * 6)
    let wave-points = range(segment-count + 1).map(segment-index => {
      let progress = segment-index / segment-count
      let shaft-position = wave-start + wave-span * progress
      let shaft-point = point-on-shaft(shaft-position)
      let tangent-vector = tangent(shaft-position)
      let tangent-length = calc.max(
        1e-6,
        calc.sqrt(
          tangent-vector.at(0) * tangent-vector.at(0)
            + tangent-vector.at(1) * tangent-vector.at(1),
        ),
      )
      let wave-offset = calc.sin(
        progress * half-wave-count * 180deg,
      ) * amplitude
      (
        shaft-point.at(0) - tangent-vector.at(1) / tangent-length * wave-offset,
        shaft-point.at(1) + tangent-vector.at(0) / tangent-length * wave-offset,
      )
    })
    line(..wave-points, stroke: (..arrow-stroke, cap: "round", join: "round"))
    if heads == "end" or heads == "both" {
      line(
        point-on-shaft(wave-end),
        inset-end,
        stroke: arrow-stroke,
        mark: (..arrowhead-options, end: ">"),
      )
    }
    if heads == "both" {
      line(
        point-on-shaft(wave-start),
        inset-start,
        stroke: arrow-stroke,
        mark: (..arrowhead-options, end: ">"),
      )
    }
  } else if sign == 0 {
    line(inset-start, inset-end, stroke: arrow-stroke, mark: arrowheads)
  } else {
    bezier-through(
      inset-start,
      apex,
      inset-end,
      stroke: arrow-stroke,
      mark: arrowheads,
    )
  }

  if arrow-specification.label != none {
    let label-offset = if sign == 0 {
      configuration.label-gap
    } else {
      bend-magnitude + sign * configuration.label-gap
    }
    content(
      (
        midpoint-x + normal-x * label-offset,
        midpoint-y + normal-y * label-offset,
      ),
      text(size: configuration.label-size, fill: arrow-specification.color, arrow-specification.label),
      anchor: "center",
    )
  }
}

// Annotation styling derived from the shared canvas scale and font size.
#let _annotation-configuration(canvas-scale, font-size, scale, bond-stroke: none) = (
  lp-offset: calc.max(0.1, font-size / canvas-scale * 0.6),
  atom-radius: calc.max(0.12, font-size / canvas-scale * 0.5),
  bond-thickness: canvas-scale * 0.42,
  bond-trim: calc.max(0.42, font-size / canvas-scale * 0.75),
  arrow-thickness: if bond-stroke == none { 0.9pt * scale } else { bond-stroke },
  arrow-scale: scale,
  label-size: font-size * 0.92,
  endpoint-gap: 2pt / canvas-scale,
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
  _validate-positive-number(scale, "smiles scale")
  if bond-length != none {
    _validate-positive-number(bond-length, "smiles bond-length")
  }
  _validate-positive-length(
    font-size,
    "smiles font-size",
    allow-none: true,
  )
  _validate-positive-length(
    bond-stroke,
    "smiles bond-stroke",
    allow-none: true,
  )
  if type(rotation) != _angle-type {
    _invalid-input(
      "smiles rotation",
      "expected an angle, got " + repr(rotation),
      "Pass an angle such as 30deg.",
    )
  }
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

  let (fg, theme) = _resolve-foreground-theme(fg, theme)
  let layout = _mirror-layout(_compute-layout(smiles-str), mirror, rotation: rotation)
  let canvas-scale = _canvas-scale(scale, bond-length)
  let actual-font-size = if font-size == none { 11pt * scale } else { font-size }
  let annotation = annotations.pos()
  let placed-species-list = ((
    kind: "mol",
    layout: layout,
    mol-scale: 1.0,
    rotation: rotation,
    origin: (0, 0),
    size: (layout.bbox_width, layout.bbox_height),
    canvas-scale: canvas-scale,
    actual-font-size: actual-font-size,
    actual-bond-stroke: if bond-stroke == none { 0.9pt * scale } else { bond-stroke },
    font: font,
    show-h: show-h,
    aromatic: aromatic,
  ),)
  let configuration = _annotation-configuration(canvas-scale, actual-font-size, scale, bond-stroke: bond-stroke)
  let the-scale = scale // cetz.draw `scale` shadows the argument inside the canvas
  _validate-molecule-options(
    layout,
    scale,
    bond-length,
    font-size,
    font,
    bond-stroke,
    color,
    rotation,
    show-h,
    lone-pairs,
    atom-colors,
    show-indices,
    fg,
    theme,
    aromatic,
    atom-annotations,
    opacity,
    bond-customizations,
  )
  _validate-annotations(annotation, placed-species-list, "smiles annotation")

  cetz.canvas(length: canvas-scale, {
    import cetz.draw: *
    for h in annotation {
      if type(h) == dictionary and h.at("__highlight__", default: false) {
        _draw-highlight(h, placed-species-list, configuration)
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
    for ar in annotation {
      if type(ar) == dictionary and ar.at("__arrow__", default: false) {
        _draw-arrow(ar, placed-species-list, configuration)
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
  _validate-positive-length(height, "smiles-inline height")
  if baseline != auto and type(baseline) != _length-type {
    _invalid-input(
      "smiles-inline baseline",
      "expected auto or a length, got " + repr(baseline),
      "Use baseline: auto or pass a length such as 0.3em.",
    )
  }
  let body = smiles(smiles-str, ..args)
  let measured-body = measure(body)
  if measured-body.height <= 0pt { return body }
  let target-height = height.to-absolute()
  // Fit the drawing into the target height, but cap the scale so one bond
  // never exceeds most of that height: a flat, mostly horizontal molecule
  // measures almost no height and would otherwise blow up to fill it.
  let canvas-unit = _canvas-scale(
    args.named().at("scale", default: 1.0),
    args.named().at("bond-length", default: none),
  )
  let scale-factor = calc.min(
    target-height / measured-body.height,
    target-height * 0.9 / canvas-unit,
  )
  let scaled = _typst-scale(
    x: scale-factor * 100%,
    y: scale-factor * 100%,
    reflow: true,
    body,
  )
  let center-above = if baseline == auto { 0.30em.to-absolute() } else { baseline.to-absolute() }
  box(
    baseline: measured-body.height * scale-factor / 2 - center-above,
    scaled,
  )
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
  let options = opts.named()
  if name != none and type(name) != str {
    _invalid-input(
      "smiles-cetz name",
      "expected none or a string, got " + repr(name),
      "Pass a CeTZ group name such as \"substrate\".",
    )
  }
  _validate-offset(origin, "smiles-cetz origin")
  if fg != auto and type(fg) != _color-type {
    _invalid-input(
      "smiles-cetz foreground",
      "expected auto or a color, got " + repr(fg),
      "Pass a Typst color.",
    )
  }
  if theme != auto and theme not in ("light", "dark") {
    _invalid-input(
      "smiles-cetz theme",
      "expected auto, \"light\", or \"dark\", got " + repr(theme),
      "Choose one of the supported palette themes.",
    )
  }
  let fg = if fg == auto { black } else { fg }
  let theme = if theme == auto { "light" } else { theme }
  let mirror = options.at("mirror", default: none)
  let rotation = options.at("rotation", default: 0deg)
  if type(rotation) != _angle-type {
    _invalid-input(
      "smiles-cetz rotation",
      "expected an angle, got " + repr(rotation),
      "Pass an angle such as 30deg.",
    )
  }
  let layout = _mirror-layout(_compute-layout(smiles-str), mirror, rotation: rotation)
  let allowed = (
    "scale", "font-size", "font", "bond-stroke", "color", "rotation",
    "show-h", "lone-pairs", "atom-colors", "show-indices", "aromatic",
    "atom-annotations", "opacity", "bond-customizations",
  )
  let drawing-options = (:)
  for (option-name, option-value) in options {
    if option-name in allowed {
      drawing-options.insert(option-name, option-value)
    } else if option-name != "mirror" {
      panic("smiles-cetz does not accept option \"" + option-name + "\"")
    }
  }
  if drawing-options.at("font", default: none) == auto {
    drawing-options.insert("font", "New Computer Modern")
  }
  group(name: name, {
    translate(origin)
    _draw-molecule(layout, fg: fg, theme: theme, ..drawing-options)
    for atom-index in range(layout.atoms.len()) {
      let atom = layout.atoms.at(atom-index)
      let atom-position = _rendered-atom-position(atom, rotation)
      anchor(
        "atom-" + str(atom-index),
        (atom-position.x, atom-position.y),
      )
    }
    for bond-output in layout.bonds {
      if not bond-output.at("virtual_bond", default: false) {
        let from-position = _rendered-atom-position(
          layout.atoms.at(bond-output.from),
          rotation,
        )
        let to-position = _rendered-atom-position(
          layout.atoms.at(bond-output.to),
          rotation,
        )
        let midpoint-x = (from-position.x + to-position.x) / 2
        let midpoint-y = (from-position.y + to-position.y) / 2
        anchor(
          "bond-"
            + str(calc.min(bond-output.from, bond-output.to))
            + "-"
            + str(calc.max(bond-output.from, bond-output.to)),
          (midpoint-x, midpoint-y),
        )
      }
    }
    anchor("center", (0, 0))
  })
}

// ── Reaction scheme helpers ───────────────────────────────────────────────────

/// Creates a reaction arrow for use inside `reaction()`.
///
/// - above (content / dictionary): Label above a horizontal arrow / to the right
///   of a vertical one. A mol() item renders as a molecule; in mechanism mode it
///   also becomes a referenceable species of its own.
/// - below (content / dictionary): Label below a horizontal arrow / to the left
///   of a vertical one. Accepts the same values as `above`.
/// - dir (auto / str): Arrow direction — "right", "left", "down", or "up".
///   `auto` follows the enclosing `reaction(flow:)` (right for horizontal flows,
///   down for vertical). Default: auto.
/// - kind (str): Arrow style — "single" (default), "equilibrium",
///   "equilibrium-filled", "dashed" (hypothetical/formal step), or "wavy"
///   (e.g. a distorted or non-elementary transformation).
/// - scale (float): Uniform scale applied to the arrow, including condition
///   labels. Default: 1.0.
/// - color (auto / color): Arrow color. `auto` inherits the surrounding text
///   color, matching dark slide themes. Default: auto.
/// - stroke (auto / length): Shaft width before `scale` is applied. `auto`
///   matches the default SMILES bond stroke (0.9pt). Default: auto.
/// -> dictionary  (consumed by `reaction()`)
#let rxn-arrow(above: none, below: none, dir: auto, kind: "single", scale: 1.0, color: auto, stroke: auto) = {
  if dir != auto and dir not in ("right", "left", "down", "up") {
    _invalid-input(
      "rxn-arrow direction",
      "expected auto, \"right\", \"left\", \"down\", or \"up\", got "
        + repr(dir),
      "Choose a supported reaction-arrow direction.",
    )
  }
  if kind not in (
    "single",
    "equilibrium",
    "equilibrium-filled",
    "dashed",
    "wavy",
  ) {
    _invalid-input(
      "rxn-arrow kind",
      "unsupported kind " + repr(kind),
      "Use \"single\", \"equilibrium\", \"equilibrium-filled\", \"dashed\", or \"wavy\".",
    )
  }
  _validate-positive-number(scale, "rxn-arrow scale")
  if color != auto and type(color) != _color-type {
    _invalid-input(
      "rxn-arrow color",
      "expected auto or a color, got " + repr(color),
      "Use color: auto or pass a Typst color.",
    )
  }
  _validate-positive-length(stroke, "rxn-arrow stroke", allow-auto: true)
  for (slot-name, slot-value) in (("above", above), ("below", below)) {
    if type(slot-value) == dictionary and not slot-value.at("__mol__", default: false) {
      _invalid-input(
        "rxn-arrow " + slot-name,
        "a dictionary value must be created with mol()",
        "Pass ordinary content or mol(...) for a referenceable molecule.",
      )
    }
  }
  (
    __rxn_arrow__: true,
    above: above,
    below: below,
    dir: dir,
    kind: kind,
    scale: scale,
    color: color,
    stroke: stroke,
  )
}

/// A reaction-scheme item: a molecule or any content, with an optional label and
/// position offset. Consumed by #reaction() and by the above/below slots of
/// #rxn-arrow().
///
/// - spec (str / content): A SMILES string (rendered by #reaction with addressable
///   atoms) or any content (e.g. ce(...), smiles(...), text — an opaque block).
/// - label (content): Optional label shown below. Default: none.
/// - offset (array): (dx, dy) page-axis nudge in bond-length units. Positive x
///   moves right and positive y moves up, independent of reaction flow.
/// - ..opts: Positional arrow()/highlight() annotations use local atom and bond
///   references for this molecule. Named options control molecule drawing,
///   including per-molecule `scale`, labels, strokes, colors, rotation, mirroring,
///   hydrogens, lone pairs, opacity, bond customizations, and index overlays.
///   `reaction(scale: ...)` scales the complete scheme uniformly.
/// -> dictionary  (consumed by #reaction / #rxn-arrow)
#let mol(spec, label: none, offset: (0, 0), ..opts) = {
  if type(spec) != str and type(spec) != _content-type {
    _invalid-input(
      "mol specification",
      "expected a SMILES string or content, got " + repr(spec),
      "Pass a string such as \"CCO\" or rendered content such as ce(\"H2O\").",
    )
  }
  _validate-offset(offset, "mol offset")
  let annotations = opts.pos()
  for annotation in annotations {
    if (
      type(annotation) != dictionary
        or (
          not annotation.at("__arrow__", default: false)
            and not annotation.at("__highlight__", default: false)
        )
    ) {
      _invalid-input(
        "mol positional annotation",
        "expected arrow() or highlight(), got " + repr(annotation),
        "Pass only local arrow()/highlight() annotations after the molecule specification.",
      )
    }
  }
  let options = opts.named()
  let allowed-options = (
    "style", "scale", "bond-length", "font-size", "font", "bond-stroke",
    "color", "fg", "theme", "rotation", "mirror", "show-h", "aromatic",
    "atom-annotations", "opacity", "bond-customizations", "lone-pairs",
    "atom-colors", "show-indices",
  )
  for option-name in options.keys() {
    if option-name not in allowed-options {
      _invalid-input(
        "mol option " + repr(option-name),
        "the option is not supported",
        "Use an option accepted by smiles().",
      )
    }
  }
  if "scale" in options {
    _validate-positive-number(options.scale, "mol scale")
  }
  if "bond-length" in options and options.at("bond-length") != none {
    _validate-positive-number(options.at("bond-length"), "mol bond-length")
  }
  if "font-size" in options {
    _validate-positive-length(
      options.at("font-size"),
      "mol font-size",
      allow-none: true,
    )
  }
  if "bond-stroke" in options {
    _validate-positive-length(
      options.at("bond-stroke"),
      "mol bond-stroke",
      allow-none: true,
    )
  }
  if "rotation" in options and type(options.rotation) != _angle-type {
    _invalid-input(
      "mol rotation",
      "expected an angle, got " + repr(options.rotation),
      "Pass an angle such as 30deg.",
    )
  }
  if type(spec) != str and (annotations.len() > 0 or options.len() > 0) {
    _invalid-input(
      "mol content options",
      "opaque content has no addressable atoms or molecule drawing options",
      "Apply styling before passing the content, and omit arrow()/highlight() annotations; use species() to reference the whole item.",
    )
  }
  (
    __mol__: true,
    spec: spec,
    label: label,
    offset: offset,
    annotations: annotations,
    opts: options,
  )
}

// Render a mol() item to standalone content (scheme/grid path).
#let _render-molecule-item(molecule-item, show-indices-default: false, offset-unit: 30pt) = context {
  let options = molecule-item.opts
  if type(molecule-item.spec) == str and not ("show-indices" in options) {
    options.insert("show-indices", show-indices-default)
  }
  let body = if type(molecule-item.spec) == str {
    smiles(molecule-item.spec, ..options)
  } else {
    molecule-item.spec
  }
  let rendered = if molecule-item.label == none {
    body
  } else {
    stack(spacing: 4pt, body, align(center, molecule-item.label))
  }
  if molecule-item.offset == (0, 0) {
    rendered
  } else {
    let horizontal-offset = molecule-item.offset.at(0) * offset-unit
    let vertical-offset = -molecule-item.offset.at(1) * offset-unit
    let size = measure(rendered)
    // Keep the visual nudge while shrinking or expanding its layout box by the
    // same amount. A surrounding layout consequently tracks the moved edge.
    box(
      width: calc.max(0pt, size.width + horizontal-offset),
      height: calc.max(0pt, size.height + vertical-offset),
      move(dx: horizontal-offset, dy: vertical-offset, rendered),
    )
  }
}

// An arrow label slot accepts plain content (rendered as small text) or a
// mol() item (rendered as a molecule).
#let _arrow-label-content(label) = {
  if type(label) == dictionary and label.at("__mol__", default: false) {
    _render-molecule-item(label)
  } else {
    text(size: 8pt, label)
  }
}

// Uniformly scales an arrow component while preserving its layout dimensions.
#let _scale-reaction-arrow(body, factor) = {
  if factor <= 0 { panic("rxn-arrow scale must be positive") }
  if factor == 1.0 {
    body
  } else {
    _typst-scale(x: factor * 100%, y: factor * 100%, reflow: true, body)
  }
}

// Render a horizontal reaction arrow.
#let _horizontal-reaction-arrow(above, below, direction, kind, arrow-color, stroke, arrow-scale: 1.0) = context {
  let arrow-color = if arrow-color == auto {
    if type(text.fill) == _color-type { text.fill } else { black }
  } else { arrow-color }
  let stroke-width = if stroke == auto { 0.9pt } else { stroke }
  let span = 52
  let (start-x, end-x) = if direction == "left" { (span, 0) } else { (0, span) }
  let arrow-canvas = cetz.canvas(length: 1pt, {
    import cetz.draw: *
    if kind == "single" {
      line((start-x, 0), (end-x, 0), mark: (end: ">", fill: arrow-color, size: 5), stroke: stroke-width + arrow-color)
    } else if kind == "dashed" {
      line(
        (start-x, 0), (end-x, 0),
        mark: (end: ">", fill: arrow-color, size: 5),
        stroke: (paint: arrow-color, thickness: stroke-width, dash: (array: (3pt, 2.2pt), phase: 0pt)),
      )
    } else if kind == "wavy" {
      // Sine wave over most of the shaft, then a short straight lead-out so
      // the arrowhead points along the travel direction.
      let sign = if end-x > start-x { 1 } else { -1 }
      let lead = 8
      let wave-end = end-x - sign * lead
      let segment-count = 28
      let points = range(segment-count + 1).map(i => {
        let t = i / segment-count
        (start-x + (wave-end - start-x) * t, calc.sin(t * 3.0 * 2.0 * calc.pi) * 2.4)
      })
      line(..points, stroke: (paint: arrow-color, thickness: stroke-width, cap: "round", join: "round"))
      line((wave-end, 0), (end-x, 0), mark: (end: ">", fill: arrow-color, size: 5), stroke: stroke-width + arrow-color)
    } else if kind == "equilibrium" or kind == "equilibrium-filled" {
      let sign = if end-x > start-x { 1 } else { -1 }
      let arrowhead-length = 7
      let head-rise = 3.5
      if kind == "equilibrium-filled" {
        let top-base = end-x - sign * arrowhead-length
        line((start-x, 2.2), (end-x, 2.2), stroke: stroke-width + arrow-color)
        line(
          (end-x, 2.2), (top-base, 2.2), (top-base, 2.2 + head-rise),
          close: true, fill: arrow-color, stroke: none,
        )
      } else {
        line((start-x, 2.2), (end-x, 2.2), stroke: stroke-width + arrow-color)
        line((end-x, 2.2), (end-x - sign * arrowhead-length, 2.2 + head-rise), stroke: stroke-width + arrow-color)
      }
      if kind == "equilibrium-filled" {
        let bottom-base = start-x + sign * arrowhead-length
        line((end-x, -2.2), (start-x, -2.2), stroke: stroke-width + arrow-color)
        line(
          (start-x, -2.2), (bottom-base, -2.2), (bottom-base, -2.2 - head-rise),
          close: true, fill: arrow-color, stroke: none,
        )
      } else {
        line((end-x, -2.2), (start-x, -2.2), stroke: stroke-width + arrow-color)
        line((start-x, -2.2), (start-x + sign * arrowhead-length, -2.2 - head-rise), stroke: stroke-width + arrow-color)
      }
    } else {
      panic("rxn-arrow kind must be \"single\", \"equilibrium\", \"equilibrium-filled\", \"dashed\", or \"wavy\"")
    }
  })
  let body = if above == none and below == none {
    align(center + horizon, arrow-canvas)
  } else {
    let above-label = if above != none { _arrow-label-content(above) } else { [] }
    let below-label = if below != none { _arrow-label-content(below) } else { [] }
    let above-size = if above != none { measure(above-label) } else { (width: 0pt, height: 0pt) }
    let below-size = if below != none { measure(below-label) } else { (width: 0pt, height: 0pt) }
    let arrow-size = measure(arrow-canvas)
    let label-height = calc.max(above-size.height, below-size.height)
    let row-width = calc.max(arrow-size.width, calc.max(above-size.width, below-size.width))
    align(center + horizon, stack(
      spacing: 3pt,
      box(width: row-width, height: label-height, align(center + bottom, above-label)),
      box(width: row-width, align(center + horizon, arrow-canvas)),
      box(width: row-width, height: label-height, align(center + top, below-label)),
    ))
  }
  _scale-reaction-arrow(body, arrow-scale)
}

// Render a vertical reaction arrow. `above` is shown to the right, `below` to the left.
#let _vertical-reaction-arrow(above, below, direction, kind, arrow-color, stroke, arrow-scale: 1.0) = context {
  let arrow-color = if arrow-color == auto {
    if type(text.fill) == _color-type { text.fill } else { black }
  } else { arrow-color }
  let stroke-width = if stroke == auto { 0.9pt } else { stroke }
  let span = 52
  let (from-y, to-y) = if direction == "up" { (0, span) } else { (span, 0) }
  let arrow-canvas = cetz.canvas(length: 1pt, {
    import cetz.draw: *
    if kind == "single" {
      line((0, from-y), (0, to-y), mark: (end: ">", fill: arrow-color, size: 5), stroke: stroke-width + arrow-color)
    } else if kind == "dashed" {
      line(
        (0, from-y), (0, to-y),
        mark: (end: ">", fill: arrow-color, size: 5),
        stroke: (paint: arrow-color, thickness: stroke-width, dash: (array: (3pt, 2.2pt), phase: 0pt)),
      )
    } else if kind == "wavy" {
      let sign = if to-y > from-y { 1 } else { -1 }
      let lead = 8
      let wave-end = to-y - sign * lead
      let segment-count = 28
      let points = range(segment-count + 1).map(i => {
        let t = i / segment-count
        (calc.sin(t * 3.0 * 2.0 * calc.pi) * 2.4, from-y + (wave-end - from-y) * t)
      })
      line(..points, stroke: (paint: arrow-color, thickness: stroke-width, cap: "round", join: "round"))
      line((0, wave-end), (0, to-y), mark: (end: ">", fill: arrow-color, size: 5), stroke: stroke-width + arrow-color)
    } else if kind == "equilibrium" or kind == "equilibrium-filled" {
      let sign = if to-y > from-y { 1 } else { -1 }
      let arrowhead-length = 7
      let head-rise = 3.5
      if kind == "equilibrium-filled" {
        let left-base = to-y - sign * arrowhead-length
        line((-2.2, from-y), (-2.2, to-y), stroke: stroke-width + arrow-color)
        line(
          (-2.2, to-y), (-2.2, left-base), (-2.2 - head-rise, left-base),
          close: true, fill: arrow-color, stroke: none,
        )
      } else {
        line((-2.2, from-y), (-2.2, to-y), stroke: stroke-width + arrow-color)
        line((-2.2, to-y), (-2.2 - head-rise, to-y - sign * arrowhead-length), stroke: stroke-width + arrow-color)
      }
      if kind == "equilibrium-filled" {
        let right-base = from-y + sign * arrowhead-length
        line((2.2, to-y), (2.2, from-y), stroke: stroke-width + arrow-color)
        line(
          (2.2, from-y), (2.2, right-base), (2.2 + head-rise, right-base),
          close: true, fill: arrow-color, stroke: none,
        )
      } else {
        line((2.2, to-y), (2.2, from-y), stroke: stroke-width + arrow-color)
        line((2.2, from-y), (2.2 + head-rise, from-y + sign * arrowhead-length), stroke: stroke-width + arrow-color)
      }
    } else {
      panic("rxn-arrow kind must be \"single\", \"equilibrium\", \"equilibrium-filled\", \"dashed\", or \"wavy\"")
    }
  })
  let body = if above == none and below == none {
    align(center + horizon, arrow-canvas)
  } else {
    let right-label = if above != none { _arrow-label-content(above) } else { [] }
    let left-label = if below != none { _arrow-label-content(below) } else { [] }
    let right-width = if above != none { measure(right-label).width } else { 0pt }
    let left-width = if below != none { measure(left-label).width } else { 0pt }
    let side-width = calc.max(left-width, right-width)
    grid(
      columns: (side-width, auto, side-width),
      column-gutter: 4pt,
      align: center + horizon,
      box(width: side-width, align(right + horizon, left-label)),
      arrow-canvas,
      box(width: side-width, align(left + horizon, right-label)),
    )
  }
  _scale-reaction-arrow(body, arrow-scale)
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
///    bond(s, i, j), lp(s, i) and species(k), where s/k count mol()/content items
///    in written order — including mol() items inside rxn-arrow(above:/below:)
///    slots (above before below, at the arrow's position in the sequence).
///    Plain arrow-label content and annotations are not counted. Positional
///    arrow()/highlight() items inside mol() use local references. Reaction items
///    inside brackets(..items) stay on this same canvas and remain referenceable.
///
// Screen-space bounds of a placed molecule relative to its origin. A complete
// measurement supplies the overall dimensions, while atom and label boxes
// determine how those dimensions are distributed around the molecular origin.
// This preserves asymmetric overhangs from terminal groups and custom labels
// after rotation without changing any layout coordinates.
#let _molecule-bounds(
  molecule-layout,
  rotation,
  molecule-scale,
  measured-width,
  measured-height,
  options: (:),
  canvas-scale: 30pt,
) = {
  let atoms = molecule-layout.atoms.filter(
    atom => not atom.at("virtual_h", default: false),
  )
  if atoms.len() == 0 {
    return (
      left: measured-width / 2,
      right: measured-width / 2,
      bottom: measured-height / 2,
      top: measured-height / 2,
    )
  }

  let structural-bonds = molecule-layout.bonds.filter(
    bond => not bond.at("virtual_bond", default: false),
  )
  let atom-degree(atom-index) = structural-bonds.filter(
    bond => bond.from == atom-index or bond.to == atom-index,
  ).len()
  let first-neighbor(atom-index) = {
    for bond in structural-bonds {
      if bond.from == atom-index { return bond.to }
      if bond.to == atom-index { return bond.from }
    }
    none
  }
  let force-linear-carbon-label(atom-index) = {
    let atom = molecule-layout.atoms.at(atom-index)
    (
      _is-carbon(atom)
        and atom.at("abbrev", default: "") == ""
        and atom-degree(atom-index) == 2
        and structural-bonds.filter(bond => (
          (bond.from == atom-index or bond.to == atom-index)
            and bond.order == 2
        )).len() == 2
    )
  }

  let show-h-state = _normalize-show-h(
    options.at("show-h", default: ()),
  )
  let actual-font-size = options.at("font-size", default: none)
  let actual-font-size = if actual-font-size == none {
    11pt * molecule-scale
  } else {
    actual-font-size
  }
  let font = options.at("font", default: "New Computer Modern")
  let font = if font == auto { "New Computer Modern" } else { font }
  let atom-label(body, size: actual-font-size) = text(
    size: size,
    font: font,
    style: "normal",
    weight: "regular",
    body,
  )
  let content-size(body) = {
    let measured = measure(body)
    (
      width: measured.width / canvas-scale,
      height: measured.height / canvas-scale,
    )
  }
  let padding = 1pt / canvas-scale
  let label-margin = calc.max(
    0.27 * molecule-scale,
    actual-font-size / canvas-scale * 0.70,
  )

  let visible-boxes = ()
  let visual-box(center-x, center-y, width, height) = (
    left: center-x - width / 2,
    right: center-x + width / 2,
    bottom: center-y - height / 2,
    top: center-y + height / 2,
  )

  for atom-index in range(molecule-layout.atoms.len()) {
    let atom = molecule-layout.atoms.at(atom-index)
    if atom.at("virtual_h", default: false) { continue }
    let position = _rendered-atom-position(
      atom,
      rotation,
      scale: molecule-scale,
    )
    visible-boxes.push(visual-box(position.x, position.y, 0.0, 0.0))

    let force-hydrogen = show-h-state.indices.contains(atom-index)
    let displays-label = _has-label(
      atom,
      show-all-h: show-h-state.all,
      force: force-hydrogen,
    ) or force-linear-carbon-label(atom-index)
    if not displays-label { continue }

    let abbreviation = atom.at("abbrev", default: "")
    if abbreviation != "" {
      let label = _abbreviation-label(
        abbreviation,
        atom-label,
        actual-font-size,
        actual-font-size,
      )
      let label-size = content-size(label)
      let label-width = body => content-size(_abbreviation-label(
        body,
        atom-label,
        actual-font-size,
        actual-font-size,
      )).width
      let label-center-x = position.x - _label-anchor-offset(
        abbreviation,
        atom.at("abbrev_anchor", default: 0),
        atom.at("abbrev_anchor_len", default: 0),
        label-width,
      )
      visible-boxes.push(visual-box(
        label-center-x,
        position.y,
        label-size.width + 2 * padding,
        label-size.height + 2 * padding,
      ))
      continue
    }

    let visible-hydrogen-count = {
      let count = atom.hcount + _visible-implicit-h(
        atom,
        show-all-h: show-h-state.all,
        force: force-hydrogen,
      )
      if atom.at("stereo_h", default: "none") != "none" {
        calc.max(0, count - 1)
      } else {
        count
      }
    }
    let charge-string = if atom.charge == 1        { "+" }
                        else if atom.charge == -1  { "\u{2212}" }
                        else if atom.charge > 1    { str(atom.charge) + "+" }
                        else if atom.charge < -1   { str(-atom.charge) + "\u{2212}" }
                        else                       { "" }
    let charge-content = if charge-string == "" {
      []
    } else {
      h(0.12em) + super(atom-label(charge-string))
    }
    let isotope = atom.at("isotope", default: 0)
    let isotope-content = if isotope > 0 {
      super(atom-label(str(isotope)))
    } else {
      []
    }
    let symbol-content = isotope-content + atom-label(atom.symbol)
    let hydrogen-content = if (
      visible-hydrogen-count == 0
        or (
          _is-carbon(atom)
            and not (show-h-state.all or force-hydrogen)
        )
    ) {
      []
    } else if visible-hydrogen-count == 1 {
      atom-label("H")
    } else {
      atom-label("H") + sub(atom-label(str(visible-hydrogen-count)))
    }
    let degree = atom-degree(atom-index)
    let terminal-heteroatom = (
      hydrogen-content != []
        and degree == 1
        and not _is-carbon(atom)
    )

    if terminal-heteroatom {
      let neighbor-index = first-neighbor(atom-index)
      let neighbor-position = _rendered-atom-position(
        molecule-layout.atoms.at(neighbor-index),
        rotation,
        scale: molecule-scale,
      )
      let direction-x = neighbor-position.x - position.x
      let direction-y = neighbor-position.y - position.y
      let complete-label = symbol-content + hydrogen-content + charge-content
      let complete-size = content-size(complete-label)
      let symbol-size = content-size(symbol-content)
      if calc.abs(direction-x) >= calc.abs(direction-y) {
        let away = if direction-x > 0 { -1.0 } else { 1.0 }
        visible-boxes.push(visual-box(
          position.x + away * (complete-size.width + padding) / 2,
          position.y,
          complete-size.width + padding,
          complete-size.height + 2 * padding,
        ))
      } else {
        let vertical-away = if direction-y > 0 { -1.0 } else { 1.0 }
        visible-boxes.push(visual-box(
          position.x + (complete-size.width - symbol-size.width) / 2,
          position.y + vertical-away * (complete-size.height + padding) / 2,
          complete-size.width + 2 * padding,
          complete-size.height + padding,
        ))
      }
      continue
    }

    let stacked-hydrogen = (
      hydrogen-content != []
        and degree >= 2
        and not _is-carbon(atom)
    )
    if stacked-hydrogen {
      let base-content = symbol-content + charge-content
      let base-size = content-size(base-content)
      let symbol-size = content-size(symbol-content)
      visible-boxes.push(visual-box(
        position.x + (base-size.width - symbol-size.width) / 2,
        position.y,
        base-size.width + 2 * padding,
        base-size.height + 2 * padding,
      ))
      let hydrogen-size = content-size(hydrogen-content)
      visible-boxes.push(visual-box(
        position.x,
        position.y + label-margin * 0.95,
        hydrogen-size.width + 2 * padding,
        hydrogen-size.height + 2 * padding,
      ))
      continue
    }

    let complete-label = symbol-content + hydrogen-content + charge-content
    let complete-size = content-size(complete-label)
    let symbol-size = content-size(symbol-content)
    let symbol-centered-charge = (
      hydrogen-content == [] and charge-content != []
    )
    visible-boxes.push(visual-box(
      if symbol-centered-charge {
        position.x + (complete-size.width - symbol-size.width) / 2
      } else {
        position.x
      },
      position.y,
      complete-size.width + 2 * padding,
      complete-size.height + 2 * padding,
    ))
  }

  let minimum-x = visible-boxes.map(box => box.left).fold(
    visible-boxes.first().left,
    calc.min,
  )
  let maximum-x = visible-boxes.map(box => box.right).fold(
    visible-boxes.first().right,
    calc.max,
  )
  let minimum-y = visible-boxes.map(box => box.bottom).fold(
    visible-boxes.first().bottom,
    calc.min,
  )
  let maximum-y = visible-boxes.map(box => box.top).fold(
    visible-boxes.first().top,
    calc.max,
  )
  let horizontal-padding = calc.max(
    0.0,
    measured-width - (maximum-x - minimum-x),
  ) / 2
  let vertical-padding = calc.max(
    0.0,
    measured-height - (maximum-y - minimum-y),
  ) / 2
  (
    left: -minimum-x + horizontal-padding,
    right: maximum-x + horizontal-padding,
    bottom: -minimum-y + vertical-padding,
    top: maximum-y + vertical-padding,
  )
}

/// - gap-h (length): Horizontal gap between grid items (scheme mode). Default: 1.5em.
/// - gap-v (length): Vertical gap between grid items (scheme mode). Default: 1.5em.
/// - scale (float): Uniform scale. In mechanism mode it sets the shared canvas
///   bond length, which each mol(scale: ...) multiplies for its own species.
/// - breakable (bool): Whether the block may split across pages. Default: false.
/// - show-indices (bool): Default index overlay for string SMILES molecules in
///   this reaction. Individual mol(..., show-indices: ...) calls can override it.
/// -> content
#let reaction(gap-h: 1.5em, gap-v: 1.5em, scale: 1.0, breakable: false, show-indices: false, flow: "right", ..items) = {
  _validate-nonnegative-length(gap-h, "reaction gap-h")
  _validate-nonnegative-length(gap-v, "reaction gap-v")
  _validate-positive-number(scale, "reaction scale")
  _validate-bool(breakable, "reaction breakable")
  _validate-bool(show-indices, "reaction show-indices")
  if flow not in ("right", "left", "up", "down") {
    _invalid-input(
      "reaction flow",
      "expected \"right\", \"left\", \"up\", or \"down\", got " + repr(flow),
      "Choose one of the supported layout directions.",
    )
  }
  if items.pos().len() == 0 {
    _invalid-input(
      "reaction items",
      "the reaction is empty",
      "Pass at least one molecule, content item, or reaction arrow.",
    )
  }
  let is-reaction-arrow(item) = (
    type(item) == dictionary and item.at("__rxn_arrow__", default: false)
  )
  let is-electron-arrow(item) = (
    type(item) == dictionary and item.at("__arrow__", default: false)
  )
  let is-highlight(item) = (
    type(item) == dictionary and item.at("__highlight__", default: false)
  )
  let is-molecule-item(item) = (
    type(item) == dictionary and item.at("__mol__", default: false)
  )
  let is-bracket-group(item) = (
    type(item) == dictionary and item.at("__bracket_group__", default: false)
  )
  let is-bracket-marker(item) = (
    type(item) == dictionary and item.at("__bracket_marker__", default: false)
  )

  // Transparent bracket groups become marker-delimited runs on this reaction's
  // canvas. Their molecule items consequently keep their ordinary species
  // indices and remain addressable by annotations on either side.
  let steps = ()
  let next-bracket-group-index = 0
  for item in items.pos() {
    let recognized-item = (
      is-bracket-group(item)
        or is-reaction-arrow(item)
        or is-electron-arrow(item)
        or is-highlight(item)
        or is-molecule-item(item)
        or type(item) == _content-type
        or type(item) == str
    )
    if not recognized-item {
      _invalid-input(
        "reaction item",
        "expected content, mol(), rxn-arrow(), arrow(), highlight(), or brackets(), got "
          + repr(item),
        "Pass one of the supported reaction item types.",
      )
    }
    if is-bracket-group(item) {
      let group-index = next-bracket-group-index
      next-bracket-group-index += 1
      steps.push((
        __bracket_marker__: true,
        edge: "start",
        group: group-index,
        sup: item.sup,
        sub: item.sub,
        stroke: item.stroke,
        gap: item.gap,
      ))
      for child in item.items {
        if is-bracket-group(child) {
          panic("nested transparent bracket groups are not supported")
        }
        steps.push(child)
      }
      steps.push((
        __bracket_marker__: true,
        edge: "end",
        group: group-index,
      ))
    } else {
      steps.push(item)
    }
  }

  // An `auto` arrow follows the flow: horizontal flows lay out with rightward
  // arrows (mirrored to point left below), vertical flows with downward ones.
  let base-direction = if flow == "right" or flow == "left" { "right" } else { "down" }
  steps = steps.map(item => {
    if is-reaction-arrow(item) and item.at("dir", default: auto) == auto {
      item + (dir: base-direction)
    } else {
      item
    }
  })

  let mechanism = steps.any(
    item => (
      is-electron-arrow(item)
        or is-highlight(item)
        or is-bracket-marker(item)
        or (
          is-molecule-item(item)
            and item.at("annotations", default: ()).len() > 0
        )
    ),
  )

  if not mechanism {
    // ── Scheme (grid) path ──────────────────────────────────────────────────
    // Phase 1: assign each item a (grid-row, grid-col) position.
    // Grid mapping: mol at (lr,lc) → grid (2*lr, 2*lc); arrows slot into gaps.
    let logical-row = 0
    let logical-column = 0
    let needs-advance = false
    let placed = ()

    let next-logical-position(row, column, direction) = {
      if direction == "right" { (row, column + 1) }
      else if direction == "left" { (row, column - 1) }
      else if direction == "down" { (row + 1, column) }
      else { (row - 1, column) }
    }

    for item in steps {
      if is-reaction-arrow(item) {
        let direction = item.at("dir", default: "right")
        let (grid-row, grid-column) = if direction == "right" {
          (2 * logical-row, 2 * logical-column + 1)
        } else if direction == "left" {
          (2 * logical-row, 2 * logical-column - 1)
        } else if direction == "down" {
          (2 * logical-row + 1, 2 * logical-column)
        } else {
          (2 * logical-row - 1, 2 * logical-column)
        }
        placed.push((
          gr: grid-row,
          gc: grid-column,
          kind: "arrow",
          data: item,
        ))
        let next-position = next-logical-position(
          logical-row,
          logical-column,
          direction,
        )
        logical-row = next-position.at(0)
        logical-column = next-position.at(1)
        needs-advance = false
      } else {
        if needs-advance {
          let next-position = next-logical-position(
            logical-row,
            logical-column,
            base-direction,
          )
          logical-row = next-position.at(0)
          logical-column = next-position.at(1)
        }
        placed.push((
          gr: 2 * logical-row,
          gc: 2 * logical-column,
          kind: "mol",
          data: item,
        ))
        needs-advance = true
      }
    }

    if placed.len() == 0 { return [] }

    let minimum-grid-row = placed.fold(
      placed.first().gr,
      (minimum, item) => calc.min(minimum, item.gr),
    )
    let minimum-grid-column = placed.fold(
      placed.first().gc,
      (minimum, item) => calc.min(minimum, item.gc),
    )
    let maximum-grid-row = placed.fold(
      placed.first().gr,
      (maximum, item) => calc.max(maximum, item.gr),
    )
    let maximum-grid-column = placed.fold(
      placed.first().gc,
      (maximum, item) => calc.max(maximum, item.gc),
    )

    let row-count = maximum-grid-row - minimum-grid-row + 1
    let column-count = maximum-grid-column - minimum-grid-column + 1

    // A "left" or "up" flow lays the scheme out normally, then reflects it along
    // the flow axis and flips the affected arrowheads. The written order then
    // reads leaves-toward the reflected side — natural for a branch that grows
    // out of the left or bottom of a cycle.
    if flow == "left" or flow == "up" {
      let horizontal-direction-flips = ("right": "left", "left": "right")
      let vertical-direction-flips = ("down": "up", "up": "down")
      placed = placed.map(placed-item => {
        let reflected-item = placed-item
        if flow == "left" {
          reflected-item.gc = (
            minimum-grid-column + maximum-grid-column - placed-item.gc
          )
        } else {
          reflected-item.gr = (
            minimum-grid-row + maximum-grid-row - placed-item.gr
          )
        }
        if placed-item.kind == "arrow" {
          let direction = placed-item.data.at("dir", default: "right")
          let reflected-direction = if flow == "left" {
            horizontal-direction-flips.at(direction, default: direction)
          } else {
            vertical-direction-flips.at(direction, default: direction)
          }
          reflected-item.data = placed-item.data
          reflected-item.data.dir = reflected-direction
        }
        reflected-item
      })
    }

    let lookup = (:)
    for placed-item in placed {
      lookup.insert(
        str(placed-item.gr - minimum-grid-row)
          + ","
          + str(placed-item.gc - minimum-grid-column),
        placed-item,
      )
    }

    let flat-cells = ()
    for grid-row in range(row-count) {
      for grid-column in range(column-count) {
        let placed-item = lookup.at(
          str(grid-row) + "," + str(grid-column),
          default: none,
        )
        if placed-item == none {
          flat-cells.push([])
        } else if placed-item.kind == "mol" {
          let content-item = if is-molecule-item(placed-item.data) {
            _render-molecule-item(
              placed-item.data,
              show-indices-default: show-indices,
            )
          } else {
            placed-item.data
          }
          flat-cells.push(align(center + horizon, content-item))
        } else {
          let item = placed-item.data
          let direction = item.at("dir", default: "right")
          let kind = item.at("kind", default: "single")
          flat-cells.push(
            if direction == "right" or direction == "left" {
              _horizontal-reaction-arrow(
                item.above,
                item.below,
                direction,
                kind,
                item.at("color", default: auto),
                item.at("stroke", default: auto),
                arrow-scale: item.at("scale", default: 1.0),
              )
            } else {
              _vertical-reaction-arrow(
                item.above,
                item.below,
                direction,
                kind,
                item.at("color", default: auto),
                item.at("stroke", default: auto),
                arrow-scale: item.at("scale", default: 1.0),
              )
            }
          )
        }
      }
    }

    let reaction-grid = grid(
      columns: (auto,) * column-count,
      rows: (auto,) * row-count,
      column-gutter: gap-h / 2,
      row-gutter:    gap-v / 2,
      align: center + horizon,
      ..flat-cells,
    )

    let scaled = if scale == 1.0 {
      reaction-grid
    } else {
      _typst-scale(
        x: scale * 100%,
        y: scale * 100%,
        reflow: true,
        reaction-grid,
      )
    }

    block(breakable: breakable, scaled)
  } else {
    // ── Mechanism (shared canvas) path ──────────────────────────────────────
    // Draw at a neutral physical scale, then scale the completed canvas. This
    // keeps absolute content, strokes, labels, reaction arrows, and molecular
    // geometry in the same scaling model.
    let canvas-scale = 30pt
    let font-size = 11pt
    let configuration = _annotation-configuration(canvas-scale, font-size, 1.0)
    let the-scale = 1.0 // cetz.draw `scale` shadows names inside the canvas
    let gap = 1.0 // bond-length units between species

    context {
      let placed-species-list = ()       // referenceable items (mol/content), in species-index order
      let reaction-arrow-items = () // positioned but non-referenceable content
      let annotations = () // curly arrows and highlights
      let bracket-items = ()
      let bracket-starts = (:)
      let layout-cursor = 0.0
      let lift-clearance = 0.15  // gap between an arrow and a species lifted from its label slot

      // Build a placed-species record for a mol() item, centered at (0, 0) plus
      // its own offset. `position-species` shifts it to its final canvas position.
      let build-placed-species(molecule-item) = {
        if type(molecule-item.spec) == str {
          let molecule-scale = float(
            molecule-item.opts.at("scale", default: 1.0),
          )
          if molecule-scale <= 0 { panic("mol scale must be positive") }
          let molecule-layout = _mirror-layout(
            _compute-layout(molecule-item.spec),
            molecule-item.opts.at("mirror", default: none),
            rotation: molecule-item.opts.at("rotation", default: 0deg),
          )
          let molecule-font-size = molecule-item.opts.at(
            "font-size",
            default: none,
          )
          let molecule-bond-stroke = molecule-item.opts.at(
            "bond-stroke",
            default: none,
          )
          let rotation = molecule-item.opts.at("rotation", default: 0deg)
          // Measure the rotated/mirrored/scaled molecule the same way the grid
          // path does, so wide-after-rotation species get accurate extents.
          // Combine that total with the exact rotated-atom asymmetry so the
          // bounds are stored relative to the molecular origin, not its box
          // center (layout coordinates are centroid-centered).
          let measurement-options = molecule-item.opts
          measurement-options.insert("scale", the-scale * molecule-scale)
          if "show-indices" not in measurement-options {
            measurement-options.insert("show-indices", show-indices)
          }
          let measured-molecule = measure(
            smiles(molecule-item.spec, ..measurement-options),
          )
          let bounds = _molecule-bounds(
            molecule-layout,
            rotation,
            molecule-scale,
            measured-molecule.width / canvas-scale,
            measured-molecule.height / canvas-scale,
            options: measurement-options,
            canvas-scale: canvas-scale,
          )
          (
            kind: "mol-smiles",
            layout: molecule-layout,
            mol-scale: molecule-scale,
            rotation: rotation,
            origin: (
              molecule-item.offset.at(0),
              molecule-item.offset.at(1),
            ),
            bounds: bounds,
            size: (bounds.left + bounds.right, bounds.top + bounds.bottom),
            label: molecule-item.label,
            annotations: molecule-item.at("annotations", default: ()),
            opts: molecule-item.opts,
            canvas-scale: canvas-scale,
            actual-font-size: if molecule-font-size == none {
              11pt * the-scale * molecule-scale
            } else {
              molecule-font-size
            },
            actual-bond-stroke: if molecule-bond-stroke == none {
              0.9pt * molecule-scale
            } else {
              molecule-bond-stroke
            },
            font: molecule-item.opts.at(
              "font",
              default: "New Computer Modern",
            ),
            show-h: molecule-item.opts.at("show-h", default: ()),
            aromatic: molecule-item.opts.at("aromatic", default: "kekule"),
          )
        } else {
          let measured-content = measure(molecule-item.spec)
          let width = measured-content.width / canvas-scale
          let height = measured-content.height / canvas-scale
          (
            kind: "content",
            body: molecule-item.spec,
            rotation: 0deg,
            origin: (
              molecule-item.offset.at(0),
              molecule-item.offset.at(1),
            ),
            bounds: (
              left: width / 2,
              right: width / 2,
              bottom: height / 2,
              top: height / 2,
            ),
            size: (width, height),
            label: molecule-item.label,
            annotations: molecule-item.at("annotations", default: ()),
          )
        }
      }
      let position-species(placed-species, center-x, center-y) = (
        placed-species
          + (
            origin: (
              placed-species.origin.at(0) + center-x,
              placed-species.origin.at(1) + center-y,
            ),
          )
      )

      let scope-reference-to-species(reference, species-index) = {
        if type(reference) != dictionary or "__ref__" not in reference {
          return reference
        }
        let scoped-reference = reference
        if reference.__ref__ in ("atom", "bond", "lp") {
          scoped-reference.species = species-index
        } else if reference.__ref__ == "species" {
          scoped-reference.index = species-index
        }
        scoped-reference
      }
      let scope-local-annotation(annotation, species-index) = {
        let scoped-annotation = annotation
        if is-electron-arrow(annotation) {
          scoped-annotation.from = scope-reference-to-species(
            annotation.from,
            species-index,
          )
          scoped-annotation.to = scope-reference-to-species(
            annotation.to,
            species-index,
          )
        } else if is-highlight(annotation) {
          scoped-annotation.ref = if type(annotation.ref) == array {
            annotation.ref.map(reference => (
              scope-reference-to-species(reference, species-index)
            ))
          } else {
            scope-reference-to-species(annotation.ref, species-index)
          }
        } else {
          panic("mol positional items must be arrow() or highlight()")
        }
        scoped-annotation
      }
      let register-species(placed-species, species-list, annotation-list) = {
        let species-index = species-list.len()
        let local-annotations = placed-species.at(
          "annotations",
          default: (),
        ).map(annotation => (
          scope-local-annotation(annotation, species-index)
        ))
        (
          species-list: species-list + (placed-species,),
          annotations: annotation-list + local-annotations,
        )
      }

      for item in steps {
        if is-electron-arrow(item) or is-highlight(item) {
          annotations.push(item)
        } else if is-bracket-marker(item) and item.edge == "start" {
          let bracket-gap = item.gap.to-absolute() / canvas-scale
          let tick-length = (0.18em).to-absolute() / canvas-scale
          bracket-starts.insert(str(item.group), (
            left: layout-cursor,
            species-start: placed-species-list.len(),
            arrow-start: reaction-arrow-items.len(),
            sup: item.sup,
            sub: item.sub,
            stroke: item.stroke,
            gap: bracket-gap,
            tick: tick-length,
          ))
          layout-cursor += tick-length + bracket-gap
        } else if is-bracket-marker(item) and item.edge == "end" {
          let bracket-start = bracket-starts.at(str(item.group))
          let grouped-species = placed-species-list.slice(
            bracket-start.species-start,
            placed-species-list.len(),
          )
          let grouped-arrows = reaction-arrow-items.slice(
            bracket-start.arrow-start,
            reaction-arrow-items.len(),
          )
          if grouped-species.len() == 0 and grouped-arrows.len() == 0 {
            panic("transparent brackets require at least one visible reaction item")
          }
          let bottom = 0.0
          let top = 0.0
          for grouped-species-item in grouped-species {
            bottom = calc.min(
              bottom,
              grouped-species-item.origin.at(1) - grouped-species-item.bounds.bottom,
            )
            top = calc.max(
              top,
              grouped-species-item.origin.at(1) + grouped-species-item.bounds.top,
            )
          }
          for grouped-arrow in grouped-arrows {
            let arrow-height = measure(grouped-arrow.body).height / canvas-scale
            bottom = calc.min(bottom, grouped-arrow.origin.at(1) - arrow-height / 2)
            top = calc.max(top, grouped-arrow.origin.at(1) + arrow-height / 2)
          }
          let content-right = calc.max(
            bracket-start.left + bracket-start.tick + bracket-start.gap,
            layout-cursor - gap,
          )
          let left-line = bracket-start.left + bracket-start.tick
          let right-line = content-right + bracket-start.gap
          let bracket-bottom = bottom - bracket-start.gap
          let bracket-top = top + bracket-start.gap
          let script-gap = (0.12em).to-absolute() / canvas-scale
          let script-content = if bracket-start.sup == none and bracket-start.sub == none {
            none
          } else {
            stack(
              dir: ttb,
              spacing: 1fr,
              if bracket-start.sup != none {
                box(text(size: 0.85em, bracket-start.sup))
              } else { box() },
              if bracket-start.sub != none {
                box(text(size: 0.85em, bracket-start.sub))
              } else { box() },
            )
          }
          let script-width = if script-content == none {
            0.0
          } else {
            measure(script-content).width / canvas-scale + script-gap
          }
          bracket-items.push((
            left-line: left-line,
            right-line: right-line,
            bottom: bracket-bottom,
            top: bracket-top,
            tick: bracket-start.tick,
            stroke: bracket-start.stroke,
            script: script-content,
            script-gap: script-gap,
          ))
          layout-cursor = right-line + bracket-start.tick + script-width + gap
        } else if is-reaction-arrow(item) {
          // mol() items in the arrow's above/below slots are lifted out of the
          // arrow body and registered as species of their own (above before
          // below), so their atoms stay addressable; any other label content
          // stays part of the arrow.
          let lift-above = if is-molecule-item(item.above) {
            build-placed-species(item.above)
          } else {
            none
          }
          let lift-below = if is-molecule-item(item.below) {
            build-placed-species(item.below)
          } else {
            none
          }
          let above = if lift-above == none { item.above } else { none }
          let below = if lift-below == none { item.below } else { none }
          let horizontal = item.dir == "right" or item.dir == "left"
          let body = if horizontal {
            _horizontal-reaction-arrow(
              above,
              below,
              item.dir,
              item.kind,
              item.at("color", default: auto),
              item.at("stroke", default: auto),
              arrow-scale: item.at("scale", default: 1.0),
            )
          } else {
            _vertical-reaction-arrow(
              above,
              below,
              item.dir,
              item.kind,
              item.at("color", default: auto),
              item.at("stroke", default: auto),
              arrow-scale: item.at("scale", default: 1.0),
            )
          }
          let arrow-width = measure(body).width / canvas-scale
          let arrow-height = measure(body).height / canvas-scale
          if horizontal {
            // Lifted species sit above/below the arrow inside a slot wide
            // enough for all three.
            let slot-width = calc.max(
              arrow-width,
              if lift-above == none { 0.0 } else { lift-above.size.at(0) },
              if lift-below == none { 0.0 } else { lift-below.size.at(0) },
            )
            let center-x = layout-cursor + slot-width / 2
            reaction-arrow-items.push((body: body, origin: (center-x, 0)))
            // Center each lifted box horizontally on the arrow; its bottom/top
            // edge clears the arrow by `lift-clearance`, using the rotated extents.
            if lift-above != none {
              let origin-x = (
                center-x
                  + (lift-above.bounds.left - lift-above.bounds.right) / 2
              )
              let registered = register-species(position-species(
                lift-above,
                origin-x,
                arrow-height / 2 + lift-clearance + lift-above.bounds.bottom,
              ), placed-species-list, annotations)
              placed-species-list = registered.species-list
              annotations = registered.annotations
            }
            if lift-below != none {
              let origin-x = (
                center-x
                  + (lift-below.bounds.left - lift-below.bounds.right) / 2
              )
              let registered = register-species(position-species(
                lift-below,
                origin-x,
                -(arrow-height / 2 + lift-clearance + lift-below.bounds.top),
              ), placed-species-list, annotations)
              placed-species-list = registered.species-list
              annotations = registered.annotations
            }
            layout-cursor += slot-width + gap
          } else {
            // A vertical arrow shows `above` on its right and `below` on its left.
            let left-width = if lift-below == none { 0.0 } else { lift-below.size.at(0) + lift-clearance }
            let right-width = if lift-above == none { 0.0 } else { lift-above.size.at(0) + lift-clearance }
            let center-x = layout-cursor + left-width + arrow-width / 2
            reaction-arrow-items.push((body: body, origin: (center-x, 0)))
            if lift-above != none {
              let registered = register-species(position-species(
                lift-above,
                center-x
                  + arrow-width / 2
                  + lift-clearance
                  + lift-above.bounds.left,
                0,
              ), placed-species-list, annotations)
              placed-species-list = registered.species-list
              annotations = registered.annotations
            }
            if lift-below != none {
              let registered = register-species(position-species(
                lift-below,
                center-x
                  - arrow-width / 2
                  - lift-clearance
                  - lift-below.bounds.right,
                0,
              ), placed-species-list, annotations)
              placed-species-list = registered.species-list
              annotations = registered.annotations
            }
            layout-cursor += left-width + arrow-width + right-width + gap
          }
        } else {
          let molecule-item = if is-molecule-item(item) {
            item
          } else {
            (__mol__: true, spec: item, label: none, offset: (0, 0), annotations: (), opts: (:))
          }
          let placed-species = build-placed-species(molecule-item)
          // Place the origin so the molecule's actual left edge lands at the
          // layout-cursor, then advance by its full rotated width plus the gap.
          let registered = register-species(position-species(
            placed-species,
            layout-cursor + placed-species.bounds.left,
            0,
          ), placed-species-list, annotations)
          placed-species-list = registered.species-list
          annotations = registered.annotations
          layout-cursor += placed-species.bounds.left + placed-species.bounds.right + gap
        }
      }

      _validate-annotations(
        annotations,
        placed-species-list,
        "reaction annotation",
      )

      let canvas = cetz.canvas(length: canvas-scale, {
        import cetz.draw: *

        for annotation in annotations {
          if annotation.at("__highlight__", default: false) {
            _draw-highlight(
              annotation,
              placed-species-list,
              configuration,
            )
          }
        }

        for bracket-item in bracket-items {
          line(
            (bracket-item.left-line + bracket-item.tick, bracket-item.bottom),
            (bracket-item.left-line, bracket-item.bottom),
            (bracket-item.left-line, bracket-item.top),
            (bracket-item.left-line + bracket-item.tick, bracket-item.top),
            stroke: bracket-item.stroke,
          )
          line(
            (bracket-item.right-line - bracket-item.tick, bracket-item.bottom),
            (bracket-item.right-line, bracket-item.bottom),
            (bracket-item.right-line, bracket-item.top),
            (bracket-item.right-line - bracket-item.tick, bracket-item.top),
            stroke: bracket-item.stroke,
          )
          if bracket-item.script != none {
            content(
              (
                bracket-item.right-line + bracket-item.tick + bracket-item.script-gap,
                (bracket-item.bottom + bracket-item.top) / 2,
              ),
              box(
                height: (bracket-item.top - bracket-item.bottom) * canvas-scale,
                bracket-item.script,
              ),
              anchor: "west",
            )
          }
        }

        for placed-species-index in range(placed-species-list.len()) {
          let placed-species = placed-species-list.at(placed-species-index)
          if placed-species.kind == "mol-smiles" {
            // A per-species scale is a canvas transform around the species
            // origin plus a matching factor on the drawing scale, so strokes
            // and labels (which transforms leave untouched) shrink in step
            // with the geometry.
            let molecule-scale = placed-species.at("mol-scale", default: 1.0)
            group({
              translate((placed-species.origin.at(0), placed-species.origin.at(1)))
              if molecule-scale != 1.0 { scale(molecule-scale) }
              let (molecule-foreground, molecule-theme) = _resolve-foreground-theme(
                placed-species.opts.at("fg", default: auto),
                placed-species.opts.at("theme", default: auto),
              )
              _draw-molecule(
                placed-species.layout,
                scale: the-scale * molecule-scale,
                font-size: placed-species.opts.at("font-size", default: none),
                font: placed-species.opts.at("font", default: "New Computer Modern"),
                bond-stroke: placed-species.opts.at("bond-stroke", default: none),
                color: placed-species.opts.at("color", default: true),
                rotation: placed-species.rotation,
                show-h: placed-species.opts.at("show-h", default: ()),
                lone-pairs: placed-species.opts.at("lone-pairs", default: none),
                atom-colors: placed-species.opts.at("atom-colors", default: (:)),
                show-indices: placed-species.opts.at("show-indices", default: show-indices),
                index-prefix: "species-" + str(placed-species-index) + "-",
                fg: molecule-foreground,
                theme: molecule-theme,
                aromatic: placed-species.opts.at("aromatic", default: "kekule"),
                atom-annotations: placed-species.opts.at("atom-annotations", default: ()),
                opacity: placed-species.opts.at("opacity", default: 100%),
                bond-customizations: placed-species.opts.at("bond-customizations", default: ()),
              )
            })
          } else {
            content((placed-species.origin.at(0), placed-species.origin.at(1)), placed-species.body, anchor: "center")
          }
        }

        for reaction-arrow-item in reaction-arrow-items {
          content(
            (
              reaction-arrow-item.origin.at(0),
              reaction-arrow-item.origin.at(1),
            ),
            reaction-arrow-item.body,
            anchor: "center",
          )
        }

        for placed-species in placed-species-list {
          if placed-species.label != none {
            content(
              (placed-species.origin.at(0), placed-species.origin.at(1) - placed-species.bounds.bottom - 0.34),
              placed-species.label,
              anchor: "north",
            )
          }
        }

        for annotation in annotations {
          if annotation.at("__arrow__", default: false) {
            _draw-arrow(
              annotation,
              placed-species-list,
              configuration,
            )
          }
        }
      })

      let scaled-canvas = if scale == 1.0 {
        canvas
      } else {
        _typst-scale(
          x: scale * 100%,
          y: scale * 100%,
          reflow: true,
          canvas,
        )
      }
      block(breakable: breakable, scaled-canvas)
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
) = {
  if bend != auto {
    _validate-number(bend, "step bend")
  }
  _validate-bool(merge, "step merge")
  if (
    rotation not in ("straight", "auto")
      and type(rotation) != _angle-type
  ) {
    _invalid-input(
      "step rotation",
      "expected \"straight\", \"auto\", or an angle, got " + repr(rotation),
      "Choose a supported label rotation.",
    )
  }
  _validate-offset(label-offset, "step label-offset")
  _validate-offset(into-offset, "step into-offset")
  _validate-offset(out-offset, "step out-offset")
  for (argument-name, argument-value) in (("into", into), ("out", out)) {
    if (
      argument-value != none
        and type(argument-value) != str
        and type(argument-value) != _content-type
    ) {
      _invalid-input(
        "step " + argument-name,
        "expected none, a SMILES string, or content, got "
          + repr(argument-value),
        "Pass a SMILES string directly or render the reagent before passing it.",
      )
    }
  }
  (
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
}

// Render a reagent spec (SMILES string or content) to content, for the small
// molecules that feed into or out of a cycle arc.
#let _render-cycle-reagent(spec, scale) = {
  if spec == none { none }
  else if type(spec) == str { smiles(spec, scale: scale) }
  else { spec }
}

#let _upright-angle(angle) = {
  if calc.cos(angle) < 0 { angle + 180deg } else { angle }
}

#let _cycle-label-rotation(rotation, midpoint-angle) = {
  if rotation == "straight" {
    0deg
  } else if rotation == "auto" {
    _upright-angle(midpoint-angle)
  } else if type(rotation) == _angle-type {
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
  let cycle-items = items.pos()
  if radius != auto {
    _validate-positive-number(radius, "cycle radius")
  }
  if type(start) != _angle-type {
    _invalid-input(
      "cycle start",
      "expected an angle, got " + repr(start),
      "Pass an angle such as 90deg.",
    )
  }
  _validate-bool(clockwise, "cycle clockwise")
  _validate-positive-number(scale, "cycle scale")
  _validate-positive-number(reagent-scale, "cycle reagent-scale")
  _validate-number(reagent-bend, "cycle reagent-bend")
  _validate-number(arc-gap, "cycle arc-gap")
  if type(arrow-color) != _color-type {
    _invalid-input(
      "cycle arrow-color",
      "expected a color, got " + repr(arrow-color),
      "Pass a Typst color.",
    )
  }
  if label-color != auto and type(label-color) != _color-type {
    _invalid-input(
      "cycle label-color",
      "expected auto or a color, got " + repr(label-color),
      "Use label-color: auto or pass a Typst color.",
    )
  }
  _validate-bool(breakable, "cycle breakable")
  if cycle-items.len() == 0 {
    _invalid-input(
      "cycle items",
      "the cycle is empty",
      "Pass at least one molecular species or content item.",
    )
  }
  let is-step(item) = (
    type(item) == dictionary and item.at("__cycle_step__", default: false)
  )
  let is-molecule-item(item) = (
    type(item) == dictionary and item.at("__mol__", default: false)
  )

  // Split into species (in ring order) and the step that follows each species.
  let species = ()
  let arc-steps = ()
  for item in cycle-items {
    if is-step(item) {
      if species.len() == 0 {
        _invalid-input(
          "cycle step",
          "a step appears before the first species",
          "Place each step() after the species where its arc begins.",
        )
      }
      if arc-steps.len() >= species.len() {
        _invalid-input(
          "cycle step",
          "more than one step follows the same species",
          "Place at most one step() between consecutive species.",
        )
      }
      arc-steps.push(item)
    } else {
      if (
        type(item) != str
          and type(item) != _content-type
          and not is-molecule-item(item)
      ) {
        _invalid-input(
          "cycle species",
          "expected a SMILES string, content, or mol(), got " + repr(item),
          "Pass a renderable species item.",
        )
      }
      // Pad a missing step for the previous species before starting a new one.
      while arc-steps.len() < species.len() {
        arc-steps.push(step())
      }
      species.push(item)
    }
  }
  while arc-steps.len() < species.len() { arc-steps.push(step()) }

  let species-count = species.len()

  let canvas-scale = scale * 30pt
  let molecule-scale = scale
  let step-angle = 360deg / species-count
  let direction = if clockwise { -1 } else { 1 }
  let species-angle(index) = start + direction * index * step-angle

  context {
    // Measure each species so the ring can be sized and molecules centered.
    let placed = ()
    let maximum-diagonal = 0.0
    for species-item in species {
      let molecule-item = if is-molecule-item(species-item) {
        species-item
      } else {
        (
          __mol__: true,
          spec: species-item,
          label: none,
          offset: (0, 0),
          opts: (:),
        )
      }
      let (width, height, kind, payload) = if type(molecule-item.spec) == str {
        let molecule-layout = _mirror-layout(
          _compute-layout(molecule-item.spec),
          molecule-item.opts.at("mirror", default: none),
          rotation: molecule-item.opts.at("rotation", default: 0deg),
        )
        (molecule-layout.bbox_width, molecule-layout.bbox_height, "mol", molecule-layout)
      } else {
        let measured-content = measure(molecule-item.spec)
        (
          measured-content.width / canvas-scale,
          measured-content.height / canvas-scale,
          "content",
          molecule-item.spec,
        )
      }
      maximum-diagonal = calc.max(
        maximum-diagonal,
        calc.sqrt(width * width + height * height),
      )
      placed.push((
        m: molecule-item,
        w: width,
        h: height,
        kind: kind,
        payload: payload,
      ))
    }

    // Fit the ring: adjacent species centers must clear their bounding boxes.
    let cycle-radius = if radius != auto {
      radius
    } else if species-count == 1 {
      0.0
    } else {
      calc.max(
        2.0,
        (maximum-diagonal + 1.1)
          / (2 * calc.sin(calc.pi / species-count)),
      )
    }

    let point-on-circle(angle, radial-distance) = (
      radial-distance * calc.cos(angle),
      radial-distance * calc.sin(angle),
    )
    let offset-point(point, offset) = (
      point.at(0) + offset.at(0),
      point.at(1) + offset.at(1),
    )
    // Per-species angular clearance: an arc retreats from each molecule by that
    // molecule's own reach in the tangential (arc-approach) direction, plus
    // arc-gap. This keeps the visible gap uniform whether a wide molecule sits
    // at the top (approached across its width) or the side (across its height).
    let angular-clearance(index) = if cycle-radius > 0.01 {
      let placed-item = placed.at(index)
      let angle = species-angle(index)
      let tangential-reach = (
        placed-item.w / 2 * calc.abs(calc.sin(angle))
          + placed-item.h / 2 * calc.abs(calc.cos(angle))
      )
      calc.min(
        step-angle * 0.45,
        calc.max(
          0deg,
          1.0rad * (tangential-reach + arc-gap) / cycle-radius,
        ),
      )
    } else { 0deg }

    let canvas = cetz.canvas(length: canvas-scale, {
      import cetz.draw: *

      // Arc arrows between consecutive species, with labels and reagents.
      for step-index in range(species-count) {
        let from-species-angle = species-angle(step-index)
        let to-species-angle = species-angle(step-index + 1)
        let cycle-step = arc-steps.at(step-index)
        let from-angle = (
          from-species-angle + direction * angular-clearance(step-index)
        )
        let to-angle = (
          to-species-angle
            - direction * angular-clearance(
              calc.rem(step-index + 1, species-count),
            )
        )
        let segment-count = 24
        let points = range(segment-count + 1).map(segment-index => {
          let angle = (
            from-angle
              + (to-angle - from-angle) * (segment-index / segment-count)
          )
          point-on-circle(angle, cycle-radius)
        })
        line(
          ..points,
          mark: (end: ">", fill: arrow-color, size: 0.16),
          stroke: 0.9pt + arrow-color,
        )

        let midpoint-angle = (
          from-species-angle + direction * step-angle / 2
        )
        let bend = if cycle-step.bend == auto {
          reagent-bend
        } else {
          cycle-step.bend
        }
        // Unit tangent along the arc's travel direction at its midpoint.
        let travel-direction = (
          direction * -calc.sin(midpoint-angle),
          direction * calc.cos(midpoint-angle),
        )
        if cycle-step.label != none {
          let has-reagent = cycle-step.into != none or cycle-step.out != none
          let label-radius = if has-reagent and cycle-radius > 1.3 {
            calc.max(0.55, cycle-radius - 1.05)
          } else {
            cycle-radius + 0.95
          }
          let label-body = text(
            size: 9pt,
            fill: if label-color == auto { black } else { label-color },
            cycle-step.label,
          )
          let label-rotation = _cycle-label-rotation(
            cycle-step.rotation,
            midpoint-angle,
          )
          if label-rotation != 0deg {
            label-body = _typst-rotate(label-rotation, reflow: false, label-body)
          }
          content(
            offset-point(
              point-on-circle(midpoint-angle, label-radius),
              cycle-step.label-offset,
            ),
            label-body,
            anchor: "center",
          )
        }

        // Metrics for an into/out reagent placed radially outward from the
        // arc, offset by its own measured extent so wide content (even a
        // nested reaction) clears the ring, then nudged by a per-step offset.
        // Pure: returns coords, draws nothing.
        let reagent-metrics(specification, extra-offset) = {
          let body = _render-cycle-reagent(
            specification,
            molecule-scale * reagent-scale,
          )
          if body == none {
            none
          } else {
            let measured-body = measure(body)
            let width = measured-body.width / canvas-scale
            let height = measured-body.height / canvas-scale
            let radial-half-extent = 0.5 * (
              calc.abs(width * calc.cos(midpoint-angle))
                + calc.abs(height * calc.sin(midpoint-angle))
            )
            // Floor keeps small reagents at a fixed clearance; large content
            // (e.g. a nested reaction) is pushed out by its own extent.
            let distance = (
              cycle-radius + calc.max(2.05, 1.0 + radial-half-extent)
            )
            (
              body: body,
              center: offset-point(
                point-on-circle(midpoint-angle, distance),
                extra-offset,
              ),
              w: width,
              h: height,
            )
          }
        }

        let reagent-anchor-for(angle) = {
          let direction-x = calc.cos(angle)
          let direction-y = calc.sin(angle)
          let axis-threshold = 0.12
          let horizontal-anchor = if direction-x > axis-threshold {
            "west"
          } else if direction-x < -axis-threshold {
            "east"
          } else {
            ""
          }
          let vertical-anchor = if direction-y > axis-threshold {
            "south"
          } else if direction-y < -axis-threshold {
            "north"
          } else {
            ""
          }
          if horizontal-anchor != "" and vertical-anchor != "" {
            vertical-anchor + "-" + horizontal-anchor
          }
          else if horizontal-anchor != "" { horizontal-anchor }
          else if vertical-anchor != "" { vertical-anchor }
          else { "center" }
        }

        let anchor-point(center, width, height, anchor) = {
          let center-x = center.at(0)
          let center-y = center.at(1)
          if anchor == "west" { (center-x - width / 2, center-y) }
          else if anchor == "east" { (center-x + width / 2, center-y) }
          else if anchor == "north" { (center-x, center-y + height / 2) }
          else if anchor == "south" { (center-x, center-y - height / 2) }
          else if anchor == "north-west" {
            (center-x - width / 2, center-y + height / 2)
          }
          else if anchor == "north-east" {
            (center-x + width / 2, center-y + height / 2)
          }
          else if anchor == "south-west" {
            (center-x - width / 2, center-y - height / 2)
          }
          else if anchor == "south-east" {
            (center-x + width / 2, center-y - height / 2)
          }
          else { center }
        }

        // Reagent merging in: arrow from the reagent toward the arc. In merge
        // mode the arrow ends on the arc pointing along the travel direction,
        // so it fuses with the main cycle arrow; otherwise it points radially.
        let incoming-reagent = reagent-metrics(
          cycle-step.into,
          cycle-step.into-offset,
        )
        if incoming-reagent != none {
          let incoming-anchor = reagent-anchor-for(midpoint-angle)
          let incoming-attachment = anchor-point(
            incoming-reagent.center,
            incoming-reagent.w,
            incoming-reagent.h,
            incoming-anchor,
          )
          content(
            incoming-attachment,
            incoming-reagent.body,
            anchor: incoming-anchor,
          )
          if cycle-step.merge {
            // Fuse smoothly into the main arc: the curve arrives tangent to the
            // arc with no arrowhead, so it reads as one continuous stroke.
            let tip = point-on-circle(midpoint-angle, cycle-radius)
            bezier(
              incoming-attachment,
              tip,
              (
                tip.at(0) - travel-direction.at(0) * 0.5,
                tip.at(1) - travel-direction.at(1) * 0.5,
              ),
              stroke: 0.8pt + arrow-color,
            )
          } else {
            bezier(
              incoming-attachment,
              point-on-circle(midpoint-angle, cycle-radius + 0.28),
              point-on-circle(
                midpoint-angle + direction * step-angle * bend,
                cycle-radius + 1.05,
              ),
              mark: (end: ">", fill: arrow-color, size: 0.14),
              stroke: 0.8pt + arrow-color,
            )
          }
        }

        // Product leaving: arrow from the arc outward to the reagent. In merge
        // mode it peels off the arc tangentially.
        let outgoing-reagent = reagent-metrics(
          cycle-step.out,
          cycle-step.out-offset,
        )
        if outgoing-reagent != none {
          let outgoing-anchor = reagent-anchor-for(midpoint-angle)
          let outgoing-attachment = anchor-point(
            outgoing-reagent.center,
            outgoing-reagent.w,
            outgoing-reagent.h,
            outgoing-anchor,
          )
          content(
            outgoing-attachment,
            outgoing-reagent.body,
            anchor: outgoing-anchor,
          )
          if cycle-step.merge {
            // Peel off the arc tangentially, keeping the arrowhead on the
            // departing product.
            let arc-point = point-on-circle(midpoint-angle, cycle-radius)
            bezier(
              arc-point,
              outgoing-attachment,
              (
                arc-point.at(0) + travel-direction.at(0) * 0.5,
                arc-point.at(1) + travel-direction.at(1) * 0.5,
              ),
              mark: (end: ">", fill: arrow-color, size: 0.14),
              stroke: 0.8pt + arrow-color,
            )
          } else {
            bezier(
              point-on-circle(midpoint-angle, cycle-radius + 0.28),
              outgoing-attachment,
              point-on-circle(
                midpoint-angle - direction * step-angle * bend,
                cycle-radius + 1.05,
              ),
              mark: (end: ">", fill: arrow-color, size: 0.14),
              stroke: 0.8pt + arrow-color,
            )
          }
        }
      }

      // Species on the ring, drawn on top of the arcs.
      for species-index in range(species-count) {
        let placed-item = placed.at(species-index)
        let center = point-on-circle(
          species-angle(species-index),
          cycle-radius,
        )
        if placed-item.kind == "mol" {
          group({
            translate(center)
            let (molecule-foreground, molecule-theme) = _resolve-foreground-theme(
              placed-item.m.opts.at("fg", default: auto),
              placed-item.m.opts.at("theme", default: auto),
            )
            _draw-molecule(
              placed-item.payload,
              scale: molecule-scale,
              font-size: placed-item.m.opts.at("font-size", default: none),
              font: placed-item.m.opts.at(
                "font",
                default: "New Computer Modern",
              ),
              bond-stroke: placed-item.m.opts.at("bond-stroke", default: none),
              color: placed-item.m.opts.at("color", default: true),
              rotation: placed-item.m.opts.at("rotation", default: 0deg),
              show-h: placed-item.m.opts.at("show-h", default: ()),
              lone-pairs: placed-item.m.opts.at("lone-pairs", default: none),
              atom-colors: placed-item.m.opts.at("atom-colors", default: (:)),
              show-indices: placed-item.m.opts.at(
                "show-indices",
                default: false,
              ),
              fg: molecule-foreground,
              theme: molecule-theme,
              aromatic: placed-item.m.opts.at("aromatic", default: "kekule"),
              atom-annotations: placed-item.m.opts.at(
                "atom-annotations",
                default: (),
              ),
              opacity: placed-item.m.opts.at("opacity", default: 100%),
              bond-customizations: placed-item.m.opts.at(
                "bond-customizations",
                default: (),
              ),
            )
          })
        } else {
          content(center, placed-item.payload, anchor: "center")
        }
        if placed-item.m.label != none {
          content(
            (
              center.at(0),
              center.at(1) - placed-item.h / 2 - 0.34,
            ),
            placed-item.m.label,
            anchor: "north",
          )
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
/// - ..body (content / reaction items): One content value to enclose, or a list
///   of mol(), rxn-arrow(), arrow(), and highlight() items consumed directly by
///   an enclosing reaction(). Reaction items remain referenceable across the
///   bracket boundary.
/// - sup (content): Optional superscript outside the right bracket. Default: none.
/// - sub (content): Optional subscript outside the right bracket. Default: none.
/// - stroke (stroke): Bracket stroke. Default: 0.6pt black.
/// - gap (length): Padding between the brackets and the body. Default: 0.3em.
/// -> content / dictionary (consumed by #reaction)
#let _render-brackets(body, sup: none, sub: none, stroke: 0.6pt + black, gap: 0.3em) = context {
  let body-height = measure(body).height
  let absolute-gap = gap.to-absolute()
  let bracket-tick-length = (0.18em).to-absolute()
  let bracket-height = body-height + 2 * absolute-gap
  let bracket-stroke = stroke // cetz.draw exports `stroke`, which would shadow the argument
  let bracket(left) = {
    let horizontal-direction = if left { 1 } else { -1 }
    box(height: bracket-height, cetz.canvas(length: 1pt, {
      import cetz.draw: *
      let height-units = bracket-height / 1pt
      let tick-units = bracket-tick-length / 1pt
      line(
        (horizontal-direction * tick-units, 0),
        (0, 0),
        (0, height-units),
        (horizontal-direction * tick-units, height-units),
        stroke: bracket-stroke,
      )
    }))
  }
  // Stack the marks against the closing bracket: sup pinned to the top corner,
  // sub to the bottom, by filling the bracket height.
  let script-content = if sup == none and sub == none {
    none
  } else {
    box(height: bracket-height, stack(
      dir: ttb,
      spacing: 1fr,
      if sup != none { box(text(size: 0.85em, sup)) } else { box() },
      if sub != none { box(text(size: 0.85em, sub)) } else { box() },
    ))
  }
  box(baseline: 50% + 0.3em)[#bracket(true)#h(absolute-gap)#box(baseline: 50% - body-height / 2, body)#h(absolute-gap)#bracket(false)#if script-content != none { h(0.12em); script-content }]
}

#let brackets(..arguments) = {
  let body-items = arguments.pos()
  let options = arguments.named()
  if body-items.len() == 0 {
    _invalid-input(
      "brackets body",
      "no content or reaction items were provided",
      "Pass one content value or one or more reaction items.",
    )
  }
  for option-name in options.keys() {
    if option-name not in ("sup", "sub", "stroke", "gap") {
      _invalid-input(
        "brackets option " + repr(option-name),
        "the option is not supported",
        "Use sup, sub, stroke, or gap.",
      )
    }
  }
  let sup = options.at("sup", default: none)
  let sub = options.at("sub", default: none)
  let stroke = options.at("stroke", default: 0.6pt + black)
  let gap = options.at("gap", default: 0.3em)
  if type(stroke) != _stroke-type {
    _invalid-input(
      "brackets stroke",
      "expected a stroke, got " + repr(stroke),
      "Pass a stroke such as 0.6pt + black.",
    )
  }
  _validate-nonnegative-length(gap, "brackets gap")
  let is-reaction-item(item) = (
    type(item) == dictionary and (
      item.at("__mol__", default: false)
        or item.at("__rxn_arrow__", default: false)
        or item.at("__arrow__", default: false)
        or item.at("__highlight__", default: false)
        or item.at("__bracket_group__", default: false)
    )
  )
  if body-items.len() > 1 and body-items.any(item => not is-reaction-item(item)) {
    _invalid-input(
      "brackets body",
      "multiple body values are only supported for reaction items",
      "Pass one ordinary content value, or pass mol()/rxn-arrow()/arrow()/highlight() items inside reaction().",
    )
  }
  if body-items.len() == 1 and not is-reaction-item(body-items.first()) {
    _render-brackets(
      body-items.first(),
      sup: sup,
      sub: sub,
      stroke: stroke,
      gap: gap,
    )
  } else {
    (
      __bracket_group__: true,
      items: body-items,
      sup: sup,
      sub: sub,
      stroke: stroke,
      gap: gap,
    )
  }
}
