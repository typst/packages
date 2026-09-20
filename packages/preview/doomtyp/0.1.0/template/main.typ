// SPDX-License-Identifier: MIT-0
#import "@preview/doomtyp:0.1.0": game
#show: game.with(
  save: if "save" in sys.inputs { bytes(json(sys.inputs.save)) } else { none },
  // Freedoom is included. To use your own DOOM IWAD instead:
  // wad: read("doom1.wad", encoding: none),
  // skill: 3, map: 1, tics: 4,
  // actions: (fire: ("v",), use: ("u",)),
)

// Open live preview and type below. Delete commands to rewind.
// w/s move · a/d strafe · j/l turn · f fire · e use · r restart
// x wait · 1–7 weapons · m map · p menu · i/k select · c confirm
// Keys are case-sensitive: uppercase WASD runs.
// @typstyle off

