// layout.typ - Re-export hub for layout utilities
//
// Functions are implemented in focused modules:
//   sizing.typ  — resolve-size, page-grid
//   fonts.typ   — label-fits-inside, density-skip, font-for-space,
//                 try-fit-label, greedy-deconflict, place-cartesian-label
//
// This file re-exports everything so existing imports continue to work.

#import "sizing.typ": *
#import "fonts.typ": *
