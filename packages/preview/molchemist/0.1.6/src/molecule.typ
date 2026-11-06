// Molecule input inspection, coordinate generation and rendering entry points.
#import "plugins.typ": mol-plugin, smiles-plugin, _mol-data-to-bytes, _config-source
#import "render.typ": _render-graphic, _render-with-stereo-annotations

/// Inspect one Molfile/SDF record without discarding non-depiction data.
///
/// The returned dictionary contains stable source IDs, atoms, bonds, enhanced
/// stereo groups, SGroups, collections, ordered SDF properties, the exact raw
/// record, and diagnostics for features the current renderer cannot depict.
///
/// - data (any): Molfile/SDF text, bytes, or a Typst 0.15.0+ path.
/// - record (int): One-based record number for multi-record SDF input.
/// -> dictionary
#let inspect-mol(data, record: 1) = {
  if type(record) != int or record < 1 {
    panic("record must be a positive integer")
  }
  cbor(mol-plugin.sdf_record_to_inspection(
    _mol-data-to-bytes(data),
    bytes(str(record)),
  ))
}

#let _check-fidelity(inspection, fidelity) = {
  if fidelity != "ignore" and fidelity != "strict" {
    panic("fidelity must be \"ignore\" or \"strict\"")
  }
  if fidelity == "strict" and inspection.diagnostics.len() > 0 {
    let messages = inspection.diagnostics.map(diagnostic => diagnostic.message)
    panic("faithful depiction is not available: " + messages.join("; "))
  }
}

/// Render a molecule from Molfile or SDF data.
///
/// Input geometry is retained with measured-label spacing by default. Records
/// with collapsed or numerically unstable coordinates are laid out with
/// Coordgen. On Typst 0.15.0 and later, `data` may be a `path`; earlier versions
/// should pass the result of `read`.
///
/// - data (any): Molfile/SDF text, bytes, or a Typst 0.15.0+ path.
/// - record (int): One-based record number for multi-record SDF input.
/// - abbreviate (bool): Fold common hydrogens and terminal groups into labels.
/// - skeletal (bool): Draw a skeletal formula; overrides `abbreviate`.
/// - dump (bool): Show generated Alchemist source instead of rendering.
/// - config (dictionary): Alchemist configuration plus optional `ctfile` overlay styling.
/// - annotations (dictionary, array, none): Overlay annotation or annotation array.
/// - show-indices (bool, str): Show `"atoms"`, `"bonds"`, or `"all"` indices for authoring.
/// - fidelity (str): `"ignore"` or `"strict"` handling of remaining depiction gaps.
/// -> content
#let render-mol(data, record: 1, abbreviate: false, skeletal: false, dump: false, config: (:), annotations: none, show-indices: false, fidelity: "ignore") = {
  if type(record) != int or record < 1 {
    panic("record must be a positive integer")
  }

  let mode = "full"
  if skeletal {
    mode = "skeletal"
  } else if abbreviate {
    mode = "abbreviate"
  }

  let base-sep = config.at("atom-sep", default: 3em)
  let source = _mol-data-to-bytes(data)
  let mol-data = if config.at("sgroups", default: "source") == "expanded" { mol-plugin.expand_superatoms(source, bytes(str(record))) } else { source }
  let record-data = bytes(str(if config.at("sgroups", default: "source") == "expanded" { 1 } else { record }))
  if fidelity != "ignore" {
    _check-fidelity(cbor(mol-plugin.sdf_record_to_inspection(mol-data, record-data)), fidelity)
  }
  let layout = config.at("layout", default: "avoid")
  assert(layout in ("coordinates", "avoid", "reflow"), message: "layout must be coordinates, avoid, or reflow")
  let layout-input = if config.at("infer-stereo", default: false) {
    mol-plugin.sdf_stereo3d_layout_input(mol-data, record-data)
  } else if layout == "reflow" {
    mol-plugin.sdf_force_layout_input(mol-data, record-data)
  } else { mol-plugin.sdf_record_to_layout_input(mol-data, record-data) }
  let fallback-coords = if layout-input.len() > 0 {
    smiles-plugin.layout_coordinates(layout-input)
  } else {
    none
  }

  let ast-data = if config.at("infer-stereo", default: false) {
    mol-plugin.sdf_stereo3d_ast(mol-data, if fallback-coords == none { bytes(()) } else { fallback-coords }, bytes(mode), record-data)
  } else if fallback-coords == none {
    mol-plugin.sdf_record_to_ast(mol-data, bytes(mode), record-data)
  } else if layout == "reflow" {
    mol-plugin.sdf_reoriented_ast(mol-data, fallback-coords, bytes(mode), record-data)
  } else { mol-plugin.sdf_record_to_ast_with_coords(mol-data, fallback-coords, bytes(mode), record-data) }
  let config = config + (positions: cbor(mol-plugin.sdf_depiction_positions(mol-data, if fallback-coords == none { bytes(()) } else { fallback-coords }, record-data)))
  if dump {
    return raw(str(mol-plugin.coordinate_code(ast-data, cbor.encode(_config-source(config)), bytes(repr(base-sep)))), block: true, lang: "typst")
  }
  let ast = cbor(ast-data)
  return _render-with-stereo-annotations(ast, _render-graphic(ast, base-sep, config: config, overlay-annotations: annotations, show-indices: show-indices))
}

/// Parse, lay out, and render a molecule from a SMILES string.
///
/// The generated 2D coordinates are passed through the same Alchemist rendering
/// pipeline as Molfile/SDF input.
///
/// - smiles (str): SMILES notation for one molecule.
/// - abbreviate (bool): Fold common hydrogens and terminal groups into labels.
/// - skeletal (bool): Draw a skeletal formula; overrides `abbreviate`.
/// - dump (bool): Show generated Alchemist source instead of rendering.
/// - config (dictionary): Visual configuration passed to Alchemist.
/// - annotations (dictionary, array, none): Overlay annotation or annotation array.
/// - show-indices (bool, str): Show `"atoms"`, `"bonds"`, or `"all"` indices for authoring.
/// -> content
#let render-smiles(smiles, abbreviate: false, skeletal: false, dump: false, config: (:), annotations: none, show-indices: false) = {
  let mode = "full"
  if skeletal {
    mode = "skeletal"
  } else if abbreviate {
    mode = "abbreviate"
  }

  let base-sep = config.at("atom-sep", default: 3em)
  let layout-input = if mode == "full" {
    mol-plugin.smiles_to_full_layout_input(bytes(smiles))
  } else {
    mol-plugin.smiles_to_layout_input(bytes(smiles))
  }
  let coords = smiles-plugin.layout_coordinates(layout-input)

  let layout = config.at("layout", default: "avoid")
  assert(layout in ("coordinates", "avoid", "reflow"), message: "layout must be coordinates, avoid, or reflow")
  if dump {
    let ast = mol-plugin.smiles_to_ast(bytes(smiles), coords, bytes(mode))
    return raw(str(mol-plugin.coordinate_code(ast, cbor.encode(_config-source(config)), bytes(repr(base-sep)))), block: true, lang: "typst")
  }

  let ast = cbor(mol-plugin.smiles_to_ast(bytes(smiles), coords, bytes(mode)))
  let rendered = _render-graphic(ast, base-sep, config: config, overlay-annotations: annotations, show-indices: show-indices)
  _render-with-stereo-annotations(ast, rendered)
}

/// Render a Tripos MOL2 record. Partial charges and source atom types remain
/// available in the normalized record's MOL2_SOURCE property.
#let render-mol2(data, record: 1, ..options) = {
  let sdf = mol-plugin.mol2_to_sdf(_mol-data-to-bytes(data), bytes(str(record)))
  render-mol(sdf, ..options)
}

#let inspect-mol2(data, record: 1) = {
  inspect-mol(mol-plugin.mol2_to_sdf(_mol-data-to-bytes(data), bytes(str(record))))
}
