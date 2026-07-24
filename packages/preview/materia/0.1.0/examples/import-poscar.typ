#import "/lib.typ": import-poscar, crystal

// FCC copper straight from a Direct-mode POSCAR.
#crystal(import-poscar(path("/examples/data/cu.poscar")), width: 5cm)

// NaCl from a Cartesian-mode POSCAR with a scale factor.
#crystal(import-poscar(path("/examples/data/nacl-cart.poscar")), width: 5cm)
