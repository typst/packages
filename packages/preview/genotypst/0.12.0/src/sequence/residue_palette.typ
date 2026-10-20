#let _with-lowercase-aliases(palette) = {
  let expanded = (:)
  for (residue, color) in palette.pairs() {
    expanded.insert(residue, color)
    let lowercase-residue = lower(residue)
    if lowercase-residue != residue {
      expanded.insert(lowercase-residue, color)
    }
  }
  expanded
}

#let _with-lowercase-palette-group(group) = {
  let expanded = (:)
  for (name, palette) in group.pairs() {
    expanded.insert(name, _with-lowercase-aliases(palette))
  }
  expanded
}

#let _aa-palette-default = (
  "A": rgb("#4D78FF"),
  "C": rgb("#494E5B"),
  "D": rgb("#FF07B8"),
  "E": rgb("#FF07B8"),
  "F": rgb("#BAC1D2"),
  "G": rgb("#F59116"),
  "H": rgb("#4D78FF"),
  "I": rgb("#4D78FF"),
  "K": rgb("#E44356"),
  "L": rgb("#4D78FF"),
  "M": rgb("#4D78FF"),
  "N": rgb("#00C990"),
  "P": rgb("#D9DE09"),
  "Q": rgb("#00C990"),
  "R": rgb("#E44356"),
  "S": rgb("#00C990"),
  "T": rgb("#00C990"),
  "V": rgb("#4D78FF"),
  "W": rgb("#BAC1D2"),
  "Y": rgb("#BAC1D2"),
)

#let _aa-palette-dayhoff = (
  "A": rgb("#00C990"),
  "C": rgb("#494E5B"),
  "D": rgb("#FF07B8"),
  "E": rgb("#FF07B8"),
  "F": rgb("#BAC1D2"),
  "G": rgb("#00C990"),
  "H": rgb("#E44356"),
  "I": rgb("#4D78FF"),
  "K": rgb("#E44356"),
  "L": rgb("#4D78FF"),
  "M": rgb("#4D78FF"),
  "N": rgb("#FF07B8"),
  "P": rgb("#00C990"),
  "Q": rgb("#FF07B8"),
  "R": rgb("#E44356"),
  "S": rgb("#00C990"),
  "T": rgb("#00C990"),
  "V": rgb("#4D78FF"),
  "W": rgb("#BAC1D2"),
  "Y": rgb("#BAC1D2"),
)

#let _aa-palette-zappo = (
  "A": rgb("#4D78FF"),
  "C": rgb("#494E5B"),
  "D": rgb("#FF07B8"),
  "E": rgb("#FF07B8"),
  "F": rgb("#BAC1D2"),
  "G": rgb("#D9DE09"),
  "H": rgb("#E44356"),
  "I": rgb("#4D78FF"),
  "K": rgb("#E44356"),
  "L": rgb("#4D78FF"),
  "M": rgb("#4D78FF"),
  "N": rgb("#00C990"),
  "P": rgb("#D9DE09"),
  "Q": rgb("#00C990"),
  "R": rgb("#E44356"),
  "S": rgb("#00C990"),
  "T": rgb("#00C990"),
  "V": rgb("#4D78FF"),
  "W": rgb("#BAC1D2"),
  "Y": rgb("#BAC1D2"),
)

#let _aa-palette-takabatake4 = (
  "A": rgb("#FF07B8"),
  "C": rgb("#4D78FF"),
  "D": rgb("#FF07B8"),
  "E": rgb("#FF07B8"),
  "F": rgb("#BAC1D2"),
  "G": rgb("#FF07B8"),
  "H": rgb("#FF07B8"),
  "I": rgb("#4D78FF"),
  "K": rgb("#FF07B8"),
  "L": rgb("#4D78FF"),
  "M": rgb("#4D78FF"),
  "N": rgb("#FF07B8"),
  "P": rgb("#D9DE09"),
  "Q": rgb("#FF07B8"),
  "R": rgb("#FF07B8"),
  "S": rgb("#FF07B8"),
  "T": rgb("#FF07B8"),
  "V": rgb("#4D78FF"),
  "W": rgb("#BAC1D2"),
  "Y": rgb("#BAC1D2"),
)

#let _aa-palette-takabatake5 = (
  "A": rgb("#00C990"),
  "C": rgb("#4D78FF"),
  "D": rgb("#FF07B8"),
  "E": rgb("#FF07B8"),
  "F": rgb("#BAC1D2"),
  "G": rgb("#FF07B8"),
  "H": rgb("#FF07B8"),
  "I": rgb("#4D78FF"),
  "K": rgb("#FF07B8"),
  "L": rgb("#4D78FF"),
  "M": rgb("#4D78FF"),
  "N": rgb("#FF07B8"),
  "P": rgb("#D9DE09"),
  "Q": rgb("#FF07B8"),
  "R": rgb("#FF07B8"),
  "S": rgb("#00C990"),
  "T": rgb("#00C990"),
  "V": rgb("#4D78FF"),
  "W": rgb("#BAC1D2"),
  "Y": rgb("#BAC1D2"),
)

#let _aa-palette-takabatake6 = (
  "A": rgb("#00C990"),
  "C": rgb("#4D78FF"),
  "D": rgb("#FF07B8"),
  "E": rgb("#FF07B8"),
  "F": rgb("#BAC1D2"),
  "G": rgb("#F59116"),
  "H": rgb("#FF07B8"),
  "I": rgb("#4D78FF"),
  "K": rgb("#FF07B8"),
  "L": rgb("#4D78FF"),
  "M": rgb("#4D78FF"),
  "N": rgb("#FF07B8"),
  "P": rgb("#D9DE09"),
  "Q": rgb("#FF07B8"),
  "R": rgb("#FF07B8"),
  "S": rgb("#00C990"),
  "T": rgb("#00C990"),
  "V": rgb("#4D78FF"),
  "W": rgb("#BAC1D2"),
  "Y": rgb("#BAC1D2"),
)

#let _aa-palette-takabatake7 = (
  "A": rgb("#00C990"),
  "C": rgb("#494E5B"),
  "D": rgb("#FF07B8"),
  "E": rgb("#FF07B8"),
  "F": rgb("#BAC1D2"),
  "G": rgb("#F59116"),
  "H": rgb("#FF07B8"),
  "I": rgb("#4D78FF"),
  "K": rgb("#FF07B8"),
  "L": rgb("#4D78FF"),
  "M": rgb("#4D78FF"),
  "N": rgb("#FF07B8"),
  "P": rgb("#D9DE09"),
  "Q": rgb("#FF07B8"),
  "R": rgb("#FF07B8"),
  "S": rgb("#00C990"),
  "T": rgb("#00C990"),
  "V": rgb("#4D78FF"),
  "W": rgb("#BAC1D2"),
  "Y": rgb("#BAC1D2"),
)

#let _aa-palette-takabatake8 = (
  "A": rgb("#00C990"),
  "C": rgb("#494E5B"),
  "D": rgb("#FF07B8"),
  "E": rgb("#FF07B8"),
  "F": rgb("#BAC1D2"),
  "G": rgb("#F59116"),
  "H": rgb("#E44356"),
  "I": rgb("#4D78FF"),
  "K": rgb("#FF07B8"),
  "L": rgb("#4D78FF"),
  "M": rgb("#4D78FF"),
  "N": rgb("#FF07B8"),
  "P": rgb("#D9DE09"),
  "Q": rgb("#FF07B8"),
  "R": rgb("#FF07B8"),
  "S": rgb("#00C990"),
  "T": rgb("#00C990"),
  "V": rgb("#4D78FF"),
  "W": rgb("#BAC1D2"),
  "Y": rgb("#BAC1D2"),
)

#let _aa-palette-charge = (
  "A": rgb("#BAC1D2"),
  "C": rgb("#BAC1D2"),
  "D": rgb("#E44356"),
  "E": rgb("#E44356"),
  "F": rgb("#BAC1D2"),
  "G": rgb("#BAC1D2"),
  "H": rgb("#4D78FF"),
  "I": rgb("#BAC1D2"),
  "K": rgb("#4D78FF"),
  "L": rgb("#BAC1D2"),
  "M": rgb("#BAC1D2"),
  "N": rgb("#BAC1D2"),
  "P": rgb("#BAC1D2"),
  "Q": rgb("#BAC1D2"),
  "R": rgb("#4D78FF"),
  "S": rgb("#BAC1D2"),
  "T": rgb("#BAC1D2"),
  "V": rgb("#BAC1D2"),
  "W": rgb("#BAC1D2"),
  "Y": rgb("#BAC1D2"),
)

#let _aa-palette-hydropathy = (
  "A": rgb("#4D78FF"),
  "C": rgb("#00C990"),
  "D": rgb("#FF07B8"),
  "E": rgb("#FF07B8"),
  "F": rgb("#4D78FF"),
  "G": rgb("#00C990"),
  "H": rgb("#E44356"),
  "I": rgb("#4D78FF"),
  "K": rgb("#E44356"),
  "L": rgb("#4D78FF"),
  "M": rgb("#4D78FF"),
  "N": rgb("#00C990"),
  "P": rgb("#4D78FF"),
  "Q": rgb("#00C990"),
  "R": rgb("#E44356"),
  "S": rgb("#00C990"),
  "T": rgb("#00C990"),
  "V": rgb("#4D78FF"),
  "W": rgb("#4D78FF"),
  "Y": rgb("#00C990"),
)

#let _nt-palette-default = (
  "A": rgb("#00C990"),
  "C": rgb("#4D78FF"),
  "G": rgb("#FF07B8"),
  "T": rgb("#F59116"),
  "U": rgb("#494E5B"),
)

#let _nt-palette-gc = (
  "A": rgb("#4D78FF"),
  "C": rgb("#E44356"),
  "G": rgb("#E44356"),
  "T": rgb("#4D78FF"),
  "U": rgb("#4D78FF"),
)

#let _nt-palette-purine-pyrimidine = (
  "A": rgb("#BAC1D2"),
  "C": rgb("#494E5B"),
  "G": rgb("#BAC1D2"),
  "T": rgb("#494E5B"),
  "U": rgb("#494E5B"),
)

#let _canonical-residue-palette = (
  aa: (
    default: _aa-palette-default,
    dayhoff: _aa-palette-dayhoff,
    zappo: _aa-palette-zappo,
    takabatake4: _aa-palette-takabatake4,
    takabatake5: _aa-palette-takabatake5,
    takabatake6: _aa-palette-takabatake6,
    takabatake7: _aa-palette-takabatake7,
    takabatake8: _aa-palette-takabatake8,
    charge: _aa-palette-charge,
    hydropathy: _aa-palette-hydropathy,
  ),
  nt: (
    default: _nt-palette-default,
    gc: _nt-palette-gc,
    purine-pyrimidine: _nt-palette-purine-pyrimidine,
  ),
)

#let residue-palette = (
  aa: _with-lowercase-palette-group(_canonical-residue-palette.aa),
  dna: _with-lowercase-palette-group(_canonical-residue-palette.nt),
  rna: _with-lowercase-palette-group(_canonical-residue-palette.nt),
)
