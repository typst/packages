// Public API of cubst.
//
// Only names imported here are visible to users. Keep internal helpers
// out of this file so the public surface stays small and stable.

// API 1: build puzzles
#import "cube.typ": cube, case
#import "state.typ": solved, default-scheme, face, sticker, is-solved, is-puzzle
#import "moves.typ": apply, parse, inverse, to-string

// masks (state → state)
#import "state.typ": mask, keep-colors, hide-faces, hide-pieces

// API 2: draw puzzles
#import "draw/views.typ": draw, views
#import "draw/2d.typ": draw-face
#import "draw/3d.typ": draw-3d
#import "draw/net.typ": draw-net
#import "draw/layers.typ": draw-layers
#import "colors.typ": colors
#import "puzzles/registry.typ": puzzles
