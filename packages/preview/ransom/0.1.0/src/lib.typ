// ransom-note: cut-out ransom-note letters for Typst.
//
// This file is the package's public front. The work happens in:
//
//   rng.typ        seeded, deterministic pseudo-randomness
//   presets.typ    kinds of paper (`palettes`, `scrap`) and typefaces (`faces`, `face`)
//   tile.typ       one tile: its random look, its ragged cut, its drawing
//   note.typ       `ransom`: text in, cut-out letters out
//   template.typ   `ransom-note`: page surfaces and the whole-document template

#import "note.typ": ransom
#import "template.typ": ransom-note
#import "presets.typ": palettes, scrap, faces, face
