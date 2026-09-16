// Shared validation and normalization for public typed-smiles input.

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

#let _normalize-show-h(show-h) = {
  if show-h == "skeleton" {
    (all: false, skeleton: true, indices: ())
  } else if show-h == "all" {
    (all: true, skeleton: false, indices: ())
  } else if type(show-h) == array {
    for atom-index in show-h {
      _validate-index(atom-index, "show-h atom index")
    }
    (all: false, skeleton: false, indices: show-h)
  } else if type(show-h) == int {
    _validate-index(show-h, "show-h atom index")
    (all: false, skeleton: false, indices: (show-h,))
  } else {
    _invalid-input(
      "show-h",
      "expected \"skeleton\", \"all\", an atom index, or an array of atom indices, got "
        + repr(show-h),
      "Use \"skeleton\", \"all\", 2, or (0, 2), for example.",
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
