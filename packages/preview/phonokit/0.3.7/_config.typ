// Shared configuration state for phonokit
// This module provides a global font setting that all modules can access.

#let phonokit-font = state("phonokit-font", "Charis SIL")

#let phonokit-init(font: "Charis SIL") = {
  phonokit-font.update(font)
}
