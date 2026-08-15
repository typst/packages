// Host-agnostic parsing bridge: loads the materia-io WASM plugin and turns its
// JSON records into materia structures.
#import "core/structure.typ": structure
#import "core/data.typ": group-data
#import "core/symmetry.typ": expand-general

#let _io = plugin("../plugin/materia_io.wasm")

// A path value keeps the caller's project/package root when it crosses this
// package boundary (Typst 0.15). Bytes are accepted for generated or already
// loaded data. Deliberately reject strings: a relative string would resolve
// inside materia rather than next to the caller's document.
#let _source-bytes(source) = {
  assert(
    type(source) in (path, bytes),
    message: "materia: input must be a path value (use path(\"...\")) or bytes, got "
      + repr(type(source)),
  )
  if type(source) == bytes { source } else { read(source, encoding: none) }
}

/// Plugin version string (smoke check that the binary loads).
#let plugin-version() = str(_io.version())

/// Turn a decoded plugin record into a materia structure.
/// - no lattice            -> molecule (Cartesian atoms)
/// - lattice + spacegroup  -> CIF identifier path: expand the asymmetric unit
///                            through materia's spacegroup tables, then build
///                            an explicit periodic structure
/// - lattice, no spacegroup -> explicit periodic (atoms carry frac)
/// Note: plain-xyz atoms carry only `cart` (no `frac` key), so the molecule
/// branch reads `a.cart`; extended-xyz atoms carry `frac`, read by the periodic branch.
#let record-to-structure(record) = {
  if record.lattice == none {
    // Molecule: the plugin precomputes bonds (indices into this atom set) with
    // the same rule Typst's find-bonds uses, so carry them onto the structure.
    structure(atoms: record.atoms.map(a => (a.element, a.cart)), bonds: record.bonds)
  } else if record.spacegroup != none {
    let group = group-data("3d", record.spacegroup)
    let expanded = expand-general(
      group,
      record.asym_unit.map(a => (a.element, a.frac)),
      (true, true, true),
    )
    structure(
      lattice: record.lattice,
      atoms: expanded.map(a => (a.element, a.frac)),
    )
  } else {
    structure(
      lattice: record.lattice,
      atoms: record.atoms.map(a => (a.element, a.frac)),
    )
  }
}

/// Read .xyz / extended-xyz data from a caller-created path or bytes.
#let import-xyz(source) = {
  let record = json(_io.parse_xyz(_source-bytes(source)))
  record-to-structure(record)
}

/// Read VASP 5 POSCAR/CONTCAR data from a caller-created path or bytes.
/// Direct and Cartesian coordinate modes are supported; the scale factor is
/// applied to the lattice (and, per VASP semantics, to Cartesian positions).
#let import-poscar(source) = {
  let record = json(_io.parse_poscar(_source-bytes(source)))
  record-to-structure(record)
}

/// Read CIF data (pragmatic subset) from a caller-created path or bytes.
/// Symmetry: an explicit op loop is applied by the plugin; a bare spacegroup
/// identifier is expanded here through materia's tables; files with neither
/// are rejected with an error naming the missing tags.
#let import-cif(source) = {
  let record = json(_io.parse_cif(_source-bytes(source)))
  record-to-structure(record)
}
