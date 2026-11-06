// DOOM's actual engine executes in this plugin during Typst compilation.
#let engine = plugin("doom.wasm")
#import "controls.typ": default-actions, bindings, parse-actions, key-hint

#let new-game(wad, skill: 3, episode: 1, map: 1, tics: 4) = {
  assert(type(skill) == int and skill >= 1 and skill <= 5, message: "Skill must be 1–5")
  assert(type(episode) == int and episode >= 1 and episode <= 4, message: "Episode must be 1–4")
  assert(type(map) == int and map >= 1 and map <= 32, message: "Map must be 1–32")
  assert(type(tics) == int and tics >= 1 and tics <= 35, message: "Tics per command must be 1–35")
  plugin.transition(engine.init, wad, bytes((skill, episode, map, tics)))
}

#let advance(game, actions) = plugin.transition(game.advance, bytes(actions))
#let info(game) = json(game.info())
#let framebuffer(game) = game.frame()
#let save-game(game, slot: 0) = {
  assert(type(slot) == int and slot >= 0 and slot <= 5, message: "Save slot must be 0–5")
  plugin.transition(game.save, bytes((slot,)))
}
#let saved-bytes(game, slot: 0) = {
  assert(type(slot) == int and slot >= 0 and slot <= 5, message: "Save slot must be 0–5")
  game.saved(bytes((slot,)))
}
#let load-game(game, data) = plugin.transition(game.load, data)

#let play(input, wad: none, actions: (:), skill: 3, episode: 1, map: 1, tics: 4, save: none, chunk-size: 16) = {
  assert(type(chunk-size) == int and chunk-size >= 1 and chunk-size <= 4096, message: "Chunk size must be 1–4096")
  assert(type(wad) == bytes, message: "Pass WAD bytes with wad: read(\"doom1.wad\", encoding: none)")
  let commands = parse-actions(input, actions: actions)
  let game = new-game(wad, skill: skill, episode: episode, map: map, tics: tics)
  if save != none and not commands.contains("r") { game = load-game(game, save) }
  // Restart discards the preceding history. Whitespace and comments cost no tics.
  let commands = commands.split("r").last()
  // Stable prefixes are cached; short blocks bound replay work per keystroke.
  for start in range(0, commands.len(), step: chunk-size) {
    game = advance(game, commands.slice(start, calc.min(start + chunk-size, commands.len())))
  }
  game
}

// A freshly initialized template compiles even before game data is supplied.
#let setup-screen() = pad(32pt, {
  set text(font: "DejaVu Sans Mono", fill: rgb("d5d7cb"), size: 13pt)
  set par(leading: 8pt)
  text(size: 30pt, weight: "bold", fill: rgb("dca25a"))[DOOM / TYPST]
  parbreak()
  [Your document is the controller. Your preview is the screen.]
  v(16pt)
  [1. Add a DOOM IWAD to this project, e.g. doom1.wad.]
  parbreak()
  [2. Uncomment the wad: read(...) line in main.typ.]
  parbreak()
  [3. Type commands below the show rule to play.]
  v(16pt)
  text(size: 10pt)[Change controls with game.with(actions: (...)).
  Each typed command advances the game. Delete commands to rewind.]
})

#let doom(body, wad: none, actions: (:), skill: 3, episode: 1, map: 1, tics: 4, help: true, save: none, chunk-size: 16) = {
  set page(width: 640pt, height: if help or wad == none { auto } else { 480pt }, margin: 0pt, fill: black)
  let keys = bindings(actions)
  if wad == none { setup-screen() } else {
    let input = sys.inputs.at("actions", default: body)
    let archive = if type(wad) == bytes { wad } else { read(wad, encoding: none) }
    // The document loads saves so its file paths stay relative to the project,
    // even when this function lives in an installed package.
    let game = play(input, actions: keys, wad: archive, skill: skill, episode: episode, map: map, tics: tics, save: save, chunk-size: chunk-size)
    let state = info(game)
    [#metadata(state) <doom-engine>]
    if state.state == 0 and sys.inputs.at("export-save", default: "false") == "true" {
      let data = saved-bytes(save-game(game))
      [#metadata(range(data.len()).map(i => data.at(i))) <doom-save>]
    }
    // DOOM's 320x200 framebuffer was displayed at 4:3 on a CRT: retain that aspect.
    image(framebuffer(game), format: (encoding: "rgb8", width: 320, height: 200),
      width: 640pt, height: 480pt, fit: "stretch", scaling: "pixelated", alt: "DOOM gameplay, rendered during Typst compilation")
    if help {
      set text(font: "DejaVu Sans Mono", size: 9pt, fill: rgb("acb2a0"))
      let hint(action) = key-hint(keys, action)
      pad(x: 12pt, y: 9pt, {
        set par(leading: 4pt)
        if state.quit { [GAME CLOSED · #hint("restart") restart] }
        else if state.menu {
          [#hint("menu-up")/#hint("menu-down") select · #hint("menu-left")/#hint("menu-right") adjust · #hint("confirm") confirm · #hint("back") back · #hint("menu") close]
        } else {
          [#hint("forward")/#hint("backward") move · #hint("strafe-left")/#hint("strafe-right") strafe · #hint("turn-left")/#hint("turn-right") turn · #hint("fire") fire · #hint("use") use]
          parbreak()
          [#hint("automap") map · #hint("menu") menu · #hint("restart") restart · Delete to rewind]
        }
      })
    }
  }
}
