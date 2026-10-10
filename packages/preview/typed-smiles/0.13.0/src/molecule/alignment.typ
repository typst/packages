// Scaffold alignment of molecule series and the aligned-molecule representation
// accepted by the molecule and reaction APIs.

#import "../validation.typ": _angle-type, _invalid-input, _validate-bool, _normalize-show-h
#import "../chemistry.typ": _compute-alignment

#let _is-aligned-molecule(value) = (
  type(value) == dictionary and value.at("__aligned_molecule__", default: false)
)

// Rendered page coordinates are `reflection · rotation · normalization · raw`,
// where the normalization mirrors the layout x axis (see `_mirror-layout`).
#let _layout-normalization = (xx: -1.0, xy: 0.0, yx: 0.0, yy: 1.0)

#let _multiply-transforms(left, right) = (
  xx: left.xx * right.xx + left.xy * right.yx,
  xy: left.xx * right.xy + left.xy * right.yy,
  yx: left.yx * right.xx + left.yy * right.yx,
  yy: left.yx * right.xy + left.yy * right.yy,
)

#let _rotation-transform(rotation) = (
  xx: calc.cos(rotation), xy: -calc.sin(rotation),
  yx: calc.sin(rotation), yy: calc.cos(rotation),
)

#let _page-reflection-transform(mirror) = if mirror == "horizontal" {
  (xx: -1.0, xy: 0.0, yx: 0.0, yy: 1.0)
} else if mirror == "vertical" {
  (xx: 1.0, xy: 0.0, yx: 0.0, yy: -1.0)
} else {
  (xx: 1.0, xy: 0.0, yx: 0.0, yy: 1.0)
}

// Expresses an orthogonal page transform of normalized layout coordinates as
// the rotation and optional horizontal mirror understood by `smiles()`.
#let _rotation-and-mirror(page-transform) = {
  let determinant = (
    page-transform.xx * page-transform.yy - page-transform.xy * page-transform.yx
  )
  if determinant > 0 {
    (
      rotation: calc.atan2(page-transform.xx, page-transform.yx),
      mirror: none,
    )
  } else {
    (
      rotation: calc.atan2(-page-transform.xx, page-transform.yx),
      mirror: "horizontal",
    )
  }
}

#let _validate-alignment-atoms(atoms, molecule-count) = {
  if atoms == none { return }
  if type(atoms) != array or atoms.len() != molecule-count {
    _invalid-input(
      "align-molecules atoms",
      "expected none or an array with one entry per molecule ("
        + str(molecule-count)
        + "), got "
        + repr(atoms),
      "Give auto or an array of atom indices for each molecule, e.g. (auto, (6, 7, 8, 9, 10, 11)).",
    )
  }
  for (molecule-index, entry) in atoms.enumerate() {
    if entry == auto { continue }
    let is-index-list = (
      type(entry) == array
        and entry.len() > 0
        and entry.all(index => type(index) == int and index >= 0)
    )
    if not is-index-list {
      _invalid-input(
        "align-molecules atoms entry " + str(molecule-index),
        "expected auto or a non-empty array of atom indices, got " + repr(entry),
        "List writing-order atom indices, as shown by show-indices: true.",
      )
    }
  }
}

/// Orients a series of molecules so a shared scaffold overlays the reference
/// molecule's scaffold. Each molecule keeps its own computed layout and is only
/// rotated, or rotated and mirrored; the scaffold geometry itself is not
/// changed, so cores coincide exactly only when they were drawn identically.
///
/// Returns one aligned molecule per input. Pass an aligned molecule wherever
/// a SMILES string is accepted: `smiles()`, `smiles-inline()`, `smiles-cetz()`,
/// `mol()`, `reaction()`, `cycle()`, and `molecule-grid()`. Its fields
/// `smiles`, `rotation`, `mirror`, `atoms` (molecule atoms in scaffold order),
/// and `deviation` (largest scaffold-atom mismatch in bond lengths) can be read.
///
/// - molecules (array): Two or more SMILES strings.
/// - scaffold (none / str): SMARTS pattern present once in every molecule.
///   A symmetric scaffold picks the correspondence that keeps substituents on
///   the reference's side. Default: none.
/// - atoms (none / array): One entry per molecule: `auto`, or an array of atom
///   indices. With a scaffold, an array selects which occurrence of the
///   scaffold to use; without one, the arrays correspond atom by atom across
///   molecules. Default: none.
/// - reference (int): Index of the molecule whose layout orients the series.
///   Default: 0.
/// - rotation (angle): Rotation applied to the reference, and so to the whole
///   series. Default: 0deg.
/// - mirror (none / "horizontal" / "vertical"): Page-axis reflection applied
///   to the reference, and so to the whole series. Default: none.
/// - allow-reflection (bool): Let a molecule be mirrored when that overlays its
///   scaffold better than any rotation. Wedges and hashes are exchanged, so
///   stereochemistry is preserved. Default: true.
/// -> array
#let align-molecules(
  molecules,
  scaffold: none,
  atoms: none,
  reference: 0,
  rotation: 0deg,
  mirror: none,
  allow-reflection: true,
) = {
  if type(molecules) != array or molecules.len() < 2 {
    _invalid-input(
      "align-molecules molecules",
      "expected an array of at least two SMILES strings, got " + repr(molecules),
      "Pass the series as an array, e.g. (\"CC(=O)c1ccccc1\", \"CC(O)c1ccccc1\").",
    )
  }
  for (molecule-index, molecule) in molecules.enumerate() {
    if type(molecule) != str or molecule.trim() == "" {
      _invalid-input(
        "align-molecules molecule " + str(molecule-index),
        "expected a non-empty SMILES string, got " + repr(molecule),
        "Pass SMILES strings; aligned molecules cannot be aligned again.",
      )
    }
  }
  if scaffold != none and (type(scaffold) != str or scaffold.trim() == "") {
    _invalid-input(
      "align-molecules scaffold",
      "expected none or a non-empty SMARTS string, got " + repr(scaffold),
      "Pass a pattern shared by every molecule, such as \"c1ccccc1\".",
    )
  }
  _validate-alignment-atoms(atoms, molecules.len())
  if scaffold == none and (atoms == none or atoms.any(entry => entry == auto)) {
    _invalid-input(
      "align-molecules correspondence",
      "no scaffold is given and not every molecule has an atom list",
      "Pass scaffold: \"...\", or atoms: with an index array for every molecule.",
    )
  }
  if type(reference) != int or reference < 0 or reference >= molecules.len() {
    _invalid-input(
      "align-molecules reference",
      "expected a molecule index from 0 to "
        + str(molecules.len() - 1)
        + ", got "
        + repr(reference),
      "Choose the index of the molecule that sets the orientation.",
    )
  }
  if type(rotation) != _angle-type {
    _invalid-input(
      "align-molecules rotation",
      "expected an angle, got " + repr(rotation),
      "Pass an angle such as 30deg.",
    )
  }
  if mirror not in (none, "horizontal", "vertical") {
    _invalid-input(
      "align-molecules mirror",
      "expected none, \"horizontal\", or \"vertical\", got " + repr(mirror),
      "Choose a supported page-axis reflection.",
    )
  }
  _validate-bool(allow-reflection, "align-molecules allow-reflection")

  let alignments = _compute-alignment((
    molecules: molecules,
    scaffold: scaffold,
    atoms: if atoms == none { () } else { atoms.map(entry => if entry == auto { none } else { entry }) },
    reference: reference,
    allow_reflection: allow-reflection,
  ))
  let reference-page-transform = _multiply-transforms(
    _page-reflection-transform(mirror),
    _rotation-transform(rotation),
  )
  molecules.zip(alignments).map(((molecule, alignment)) => {
    let page-transform = _multiply-transforms(
      _multiply-transforms(reference-page-transform, _layout-normalization),
      _multiply-transforms(alignment.transform, _layout-normalization),
    )
    (
      __aligned_molecule__: true,
      smiles: molecule,
      atoms: alignment.atoms,
      deviation: calc.round(alignment.deviation, digits: 6),
      .._rotation-and-mirror(page-transform),
    )
  })
}

// Resolves an aligned molecule into the SMILES string and the drawing options
// that reproduce its orientation. Options that would reorient one molecule of
// the series, or move its atoms after alignment, are rejected.
#let _aligned-molecule-drawing(aligned-molecule, options, input-context) = {
  let rotation = options.at("rotation", default: 0deg)
  if rotation != 0deg {
    _invalid-input(
      input-context + " rotation",
      "an aligned molecule already carries its rotation, got " + repr(rotation),
      "Rotate the whole series with align-molecules(rotation: ...) instead.",
    )
  }
  let mirror = options.at("mirror", default: none)
  if mirror != none {
    _invalid-input(
      input-context + " mirror",
      "an aligned molecule already carries its reflection, got " + repr(mirror),
      "Mirror the whole series with align-molecules(mirror: ...) instead.",
    )
  }
  let show-h = options.at("show-h", default: ())
  if _normalize-show-h(show-h).skeleton {
    _invalid-input(
      input-context + " show-h",
      "show-h: \"skeleton\" redraws carbon chains and would undo the alignment",
      "Use show-h: \"all\" or atom indices for aligned molecules.",
    )
  }
  let abbreviate = options.at("abbreviate", default: none)
  if abbreviate != none {
    _invalid-input(
      input-context + " abbreviate",
      "automatic abbreviations change the layout that the alignment was computed for, got "
        + repr(abbreviate),
      "Remove abbreviate from aligned molecules, or draw the series without align-molecules().",
    )
  }
  let drawing-options = options
  drawing-options.insert("rotation", aligned-molecule.rotation)
  drawing-options.insert("mirror", aligned-molecule.mirror)
  (smiles: aligned-molecule.smiles, options: drawing-options)
}
