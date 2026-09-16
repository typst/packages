#import "/lib.typ": import-cif, crystal

// The same NaCl cell through both CIF symmetry sub-paths:
// an explicit op loop (applied in Rust) ...
#crystal(import-cif(path("/examples/data/nacl-ops.cif")), width: 5cm)

// ... and a spacegroup identifier (expanded via materia's tables).
#crystal(import-cif(path("/examples/data/nacl-sg.cif")), width: 5cm)
