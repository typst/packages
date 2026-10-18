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
  "A": rgb("#00C990"),
  "C": rgb("#4D78FF"),
  "D": rgb("#00C990"),
  "E": rgb("#00C990"),
  "F": rgb("#BAC1D2"),
  "G": rgb("#00C990"),
  "H": rgb("#00C990"),
  "I": rgb("#4D78FF"),
  "K": rgb("#00C990"),
  "L": rgb("#4D78FF"),
  "M": rgb("#4D78FF"),
  "N": rgb("#00C990"),
  "P": rgb("#D9DE09"),
  "Q": rgb("#00C990"),
  "R": rgb("#00C990"),
  "S": rgb("#00C990"),
  "T": rgb("#00C990"),
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
  "D": rgb("#E44356"),
  "E": rgb("#E44356"),
  "F": rgb("#BAC1D2"),
  "G": rgb("#F59116"),
  "H": rgb("#FF07B8"),
  "I": rgb("#4D78FF"),
  "K": rgb("#E44356"),
  "L": rgb("#4D78FF"),
  "M": rgb("#4D78FF"),
  "N": rgb("#E44356"),
  "P": rgb("#D9DE09"),
  "Q": rgb("#E44356"),
  "R": rgb("#E44356"),
  "S": rgb("#00C990"),
  "T": rgb("#00C990"),
  "V": rgb("#4D78FF"),
  "W": rgb("#BAC1D2"),
  "Y": rgb("#BAC1D2"),
)

#let _dna-palette = (
  "A": rgb("#00C990"),
  "C": rgb("#4D78FF"),
  "G": rgb("#FF07B8"),
  "T": rgb("#F59116"),
)

#let _rna-palette = (
  "A": rgb("#00C990"),
  "C": rgb("#4D78FF"),
  "G": rgb("#FF07B8"),
  "U": rgb("#F59116"),
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
  ),
  dna: (
    default: _dna-palette,
  ),
  rna: (
    default: _rna-palette,
  ),
)

#let residue-palette = (
  aa: _with-lowercase-palette-group(_canonical-residue-palette.aa),
  dna: _with-lowercase-palette-group(_canonical-residue-palette.dna),
  rna: _with-lowercase-palette-group(_canonical-residue-palette.rna),
)
