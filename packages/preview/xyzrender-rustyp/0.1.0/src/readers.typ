// Mirrors upstream src/xyzrender/readers.py's dispatch role
// (`load_molecule`). Scope note: upstream `readers.py` also dispatches
// QM inputs, cube files, VASP, CIF, SHELXL, MOL/SDF/MOL2, SMILES — all
// out of scope here (PLAN.md). This file only adds the XYZ/PDB split;
// extending it for a future format means adding another branch to
// `detect-format` plus another `process-*` import, nothing structural.

#import "inputs.typ": resolve-input
#import "parsers.typ": process-pdb, process-xyz

// A real fixed-width PDB record name, checked only against the start of
// a line — never a substring search over the whole file, since an XYZ
// comment line is free-form text and could contain any of these words
// without being PDB.
#let _pdb-records = ("HEADER", "COMPND", "ATOM", "HETATM", "CONECT", "CRYST1")

// Mirrors upstream inputs.py's own bounded content-sniff: only the
// first few lines are worth checking, so a large XYZ trajectory's atom
// coordinate lines (which never start with a PDB record word) don't
// need to be scanned in full.
#let _sniff-line-cap = 50

#let _looks-like-xyz-count-line(line) = {
  line.trim().match(regex("^[0-9]+$")) != none
}

// Sniff XYZ vs PDB from raw text content. Checks the positive XYZ
// signal first (first non-blank line is a bare integer atom count) and
// only falls through to the PDB record-token scan once that has
// already failed — so a PDB-flavored word inside an XYZ comment line
// can never cause a misdetection.
#let detect-format(text) = {
  let lines = text.split("\n")
  for line in lines {
    let t = line.trim()
    if t == "" { continue }
    if _looks-like-xyz-count-line(t) { return "xyz" }
    break
  }
  let cap = calc.min(_sniff-line-cap, lines.len())
  for line in lines.slice(0, cap) {
    let token = upper(line.slice(0, calc.min(6, line.len())).trim())
    if token in _pdb-records { return "pdb" }
  }
  "xyz"
}

// Resolve `source` to raw bytes, determine its format (extension first
// when known, else content-sniffed), and dispatch to the matching
// plugin wrapper. `frame:` is accepted for API-signature parity with
// upstream `load_molecule(..., frame=...)` but is silently unused for
// PDB, matching that same upstream function on its `.pdb` branch (PDB
// parsing doesn't recognize `MODEL`/`ENDMDL`).
#let load-molecule(source, frame: 0, kekule: false, reader: none) = {
  let resolved = resolve-input(source, reader: reader)
  let format = if resolved.ext == "pdb" {
    "pdb"
  } else if resolved.ext == "xyz" {
    "xyz"
  } else {
    detect-format(str(resolved.bytes))
  }

  if format == "pdb" {
    process-pdb(resolved.bytes, kekule: kekule)
  } else {
    process-xyz(resolved.bytes, frame: frame, kekule: kekule)
  }
}
