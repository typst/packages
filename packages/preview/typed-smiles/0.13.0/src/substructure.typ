// Named teaching patterns and conversion to the existing highlight annotations.
#import "chemistry.typ": substructure-matches
#import "validation.typ": _invalid-input, _color-type, _validate-bool, _validate-include-hydrogens
#import "mechanism/references.typ": atom, bond
#import "mechanism/annotations.typ": highlight

/// SMARTS definitions for common groups. Recursive clauses are context only:
/// only atoms and bonds outside `$(...)` are shaded. Keys use hyphenated names.
#let functional-groups = (
  carboxylic-acid: "[CX3;H1,$(C-[#6])](=O)[OX2H1;+0]",
  carboxylate: "[CX3;H1,$(C-[#6])](=O)[O-]",
  alcohol: "[OX2H1;+0;$(O-[CX4])]",
  phenol: "[OX2H1;+0;$(O-c)]",
  amine: "[NX3;+0;$(N-[#6]);!$(N-[!#6;!#1]);!$(N-[#6]=[O,N,S]);!$(N-C#N)]",
  ester: "[CX3;H1,$(C-[#6]);!$(C(=O)-O-C=O)](=O)[OX2H0;+0;$(O-[#6])]",
  amide: "[#6X3](=O)[#7X3]",
  carbonyl: "[#6X3]=O",
  aldehyde: "[CX3;H2,H1$(C-[#6])]=O",
  ketone: "[CX3;$(C(-[#6])-[#6])]=O",
  nitrile: "[CX2;H1,$(C-[#6])]#[NX1]",
  ether: "[OX2H0;+0;$(O(-[#6])-[#6]);!$(O-C=O)]",
  thiol: "[SX2H1;+0;$(S-[#6])]",
  nitro: "[N+;X3;$(N-[#6])](=O)[O-]",
  alkene: "C=C",
  alkyne: "C#C",
)

#let _highlight-palette = (
  rgb("#FFE45C"), rgb("#BBE1FA"), rgb("#FFCAD4"), rgb("#B8E0C4"),
  rgb("#D6C2F0"), rgb("#FFD6A5"),
)

// These named groups include attached hydrogen in their displayed fragment.
// Carbon attachments used by recursive predicates remain outside the shading.
#let _group-hydrogen-elements = (
  carboxylic-acid: ("O",), alcohol: ("O",), phenol: ("O",),
  amine: ("N",), amide: ("N",), thiol: ("S",), aldehyde: ("C",),
)

// Resolves a request's hydrogen shading into the highlight() argument and the
// curated element list. Under `auto`, named groups shade only their curated
// elements, since their SMARTS was written around those atoms. Pattern requests
// keep the highlight() default, which shades every selected heteroatom.
#let _request-hydrogen-shading(request) = {
  if request.include-hydrogens == auto and "curated-hydrogen-elements" in request {
    return (
      include-hydrogens: false,
      hydrogen-elements: request.curated-hydrogen-elements,
    )
  }
  (include-hydrogens: request.include-hydrogens, hydrogen-elements: ())
}

#let _highlight-requests(value, field, input-context) = {
  let values = if value == none {
    ()
  } else if type(value) in (str, dictionary) {
    (value,)
  } else {
    value
  }
  if type(values) != array {
    _invalid-input(
      input-context,
      "expected a string, request dictionary, or array, got " + repr(value),
      "Pass a string or a dictionary with " + field + ", include-atoms, and include-hydrogens.",
    )
  }
  let requests = ()
  for value in values {
    let request = if type(value) == str { ((field): value) } else { value }
    if type(request) != dictionary {
      _invalid-input(
        input-context,
        "expected a string or request dictionary, got " + repr(value),
        "Pass a string or a dictionary with " + field + ", include-atoms, and include-hydrogens.",
      )
    }
    for key in request.keys() {
      if key not in (field, "include-atoms", "include-hydrogens") {
        _invalid-input(
          input-context,
          "unknown request option " + repr(key),
          "Use only " + field + ", include-atoms, and include-hydrogens.",
        )
      }
    }
    let name = request.at(field, default: none)
    if type(name) != str or name.trim() == "" {
      _invalid-input(
        input-context,
        "expected a non-empty " + field + " string, got " + repr(name),
        "Pass a string or set the dictionary's " + field + " field.",
      )
    }
    let include-atoms = request.at("include-atoms", default: true)
    _validate-bool(include-atoms, input-context + " include-atoms")
    let include-hydrogens = request.at("include-hydrogens", default: auto)
    _validate-include-hydrogens(include-hydrogens, input-context + " include-hydrogens")
    requests.push((
      name: name,
      include-atoms: include-atoms,
      include-hydrogens: include-hydrogens,
    ))
  }
  requests
}

#let _substructure-highlights(
  smiles-str,
  highlight-smarts: (),
  highlight-groups: (),
  highlight-colors: auto,
  highlight-unmatched: "error",
) = {
  let patterns = _highlight-requests(highlight-smarts, "pattern", "highlight-smarts")
    .map(request => request + (pattern: request.name))
  for request in _highlight-requests(highlight-groups, "group", "highlight-groups") {
    let key = lower(request.name.trim()).replace(" ", "-")
    if key not in functional-groups {
      _invalid-input(
        "highlight-groups",
        "unknown functional group " + repr(request.name),
        "Choose from: " + functional-groups.keys().join(", ") + ".",
      )
    }
    patterns.push(request + (
      pattern: functional-groups.at(key),
      curated-hydrogen-elements: _group-hydrogen-elements.at(key, default: ()),
    ))
  }
  if highlight-unmatched not in ("error", "ignore") {
    _invalid-input(
      "highlight-unmatched",
      "expected \"error\" or \"ignore\", got " + repr(highlight-unmatched),
      "Use \"error\" for a diagnostic or \"ignore\" to skip absent groups.",
    )
  }
  let colors = if highlight-colors == auto { _highlight-palette } else { highlight-colors }
  if type(colors) != array or colors.len() == 0 {
    _invalid-input(
      "highlight-colors",
      "expected a non-empty array of colors",
      "Pass a tuple such as (yellow, blue) or use auto.",
    )
  }
  for color in colors {
    if type(color) != _color-type {
      _invalid-input(
        "highlight-colors",
        "expected a color, got " + repr(color),
        "Pass Typst color values such as rgb(\"#FFE45C\").",
      )
    }
  }
  let annotations = ()
  for request in patterns {
    let matches = substructure-matches(smiles-str, request.pattern)
    if matches.len() == 0 and highlight-unmatched == "error" {
      _invalid-input(
        "substructure highlight",
        "no match for " + repr(request.name) + " in " + repr(smiles-str),
        "Check the pattern and protonation/aromatic notation, or set highlight-unmatched: \"ignore\" to allow absent groups.",
      )
    }
    for match in matches {
      // Bond endpoints are shaded by include-atoms. Keep standalone atom
      // matches addressable even when endpoint shading is disabled.
      let endpoints = match.bonds.flatten()
      let references = match.atoms.filter(index => index not in endpoints)
        .map(index => atom(index))
      references += match.bonds.map(pair => bond(..pair))
      let hydrogen-shading = _request-hydrogen-shading(request)
      let annotation = highlight(
        references,
        fill: colors.at(calc.rem(annotations.len(), colors.len())),
        include-atoms: request.include-atoms,
        include-hydrogens: hydrogen-shading.include-hydrogens,
      )
      annotation.hydrogen-elements = hydrogen-shading.hydrogen-elements
      annotations.push(annotation)
    }
  }
  annotations
}
