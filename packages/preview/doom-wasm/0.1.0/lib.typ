// Public package API. Override wad: to supply your own game data.
#import "engine/core.typ": new-game, advance, info, framebuffer, save-game, saved-bytes, load-game
#import "engine/core.typ" as core
#import "engine/controls.typ": default-actions, parse-actions
#let game = core.doom.with(wad: read("assets/freedoom1.wad", encoding: none))
#let doom = game
#let play = core.play.with(wad: read("assets/freedoom1.wad", encoding: none))
