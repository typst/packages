// Mirrors upstream src/xyzrender/parsers.py.
//
// Scope note: upstream `parsers.py` covers MOL / SDF / MOL2 / PDB /
// SMILES / CIF (`parse_mol`, `parse_sdf`, `parse_mol2`, `parse_pdb`,
// `parse_smiles`, `parse_cif`, dispatcher `parse(path, frame)`). XYZ
// parsing itself lives in the external `xyzgraph` package
// (`read_xyz_file` + `build_graph`), called from upstream
// `readers.py:load_molecule`.
//
// v1 handles XYZ and PDB (PLAN.md); MOL/SDF/MOL2/SMILES/CIF remain out
// of scope. The Rust WASM plugin (`assets/xyzrender.wasm`) consolidates
// upstream `xyzgraph`'s `read_xyz_file` + `build_graph` (file parsing +
// distance-based bond detection) and exposes them via `process_xyz` /
// `process_xyz_frame` / `process_pdb`. This file is the Typst-side
// wrapper for those plugin calls; `src/readers.typ` dispatches between
// them by format.
//
// Shape of the dict returned by `process-xyz` / `process-pdb`:
//   ( elements:       array<str>,
//     coords:         array<array<float, 3>>,
//     bonds:          array<array<int, 2>>,
//     bond_orders:    array<int>,    // 1.5 aromatic encoded as 1+flag
//     aromatic_flags: array<bool>,   // per-bond
//     aromatic_rings: array<array<int>>,  // ring atom-index lists
//     n_frames:       int )          // process-pdb always reports 1

// Plugin is loaded lazily so importing this module doesn't fail before
// `plugin/build.sh` has produced the .wasm. Typst caches the load
// internally; calling `plugin(...)` per render is not measurable.
#let process-xyz(xyz-bytes, frame: 0, kekule: false) = {
  let p = plugin("assets/xyzrender.wasm")
  let raw = if kekule or frame != 0 {
    // process_xyz_full handles both args; use it whenever either is
    // non-default to avoid a second wasm export for the (frame, kekule)
    // pair.
    p.process_xyz_full(
      xyz-bytes,
      bytes(str(frame)),
      bytes(if kekule { "true" } else { "false" }),
    )
  } else {
    p.process_xyz(xyz-bytes)
  }
  cbor(raw)
}

// PDB has no frame concept — `MODEL`/`ENDMDL` aren't recognized, matching
// upstream `parsers.py::parse_pdb` (a straight sequential scan of every
// `ATOM`/`HETATM` line in the file).
#let process-pdb(pdb-bytes, kekule: false) = {
  let p = plugin("assets/xyzrender.wasm")
  let raw = if kekule {
    p.process_pdb_full(pdb-bytes, bytes("true"))
  } else {
    p.process_pdb(pdb-bytes)
  }
  cbor(raw)
}
