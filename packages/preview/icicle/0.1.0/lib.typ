// The tile size.
#let size = 80pt

// The movement described by the given update.
#let deltas = (
  w: (x: 0,  y: -1),
  a: (x: -1, y: 0),
  s: (x: 0,  y: 1),
  d: (x: 1,  y: 0),
)

// The texture map.
#let texture = image(
  "texture.png",
  width: 5 * size,
  height: 5 * size,
)

// Parses a level description.
#let parse-level(text) = {
  // Parses a point from its textual form.
  let parse-point(pos) = {
    let (x, y) = pos.split(",").map(str.trim).map(int)
    (x: x, y: y)
  }

  // Parses a layer from its textual form.
  let parse-layer(text) = {
    text.split("\n").map(line => line.split().map(str.trim))
  }

  let (pos, back, front) = text
    .replace(regex("//.*\n"), "\n")
    .split(regex("\n{2,}"))
    .map(str.trim)
    .filter(s => s != "")
  (
    won: false,
    pos: parse-point(pos),
    back: parse-layer(back),
    front: parse-layer(front),
  )
}

// Parses the document's body into an array of strings containing
// only the four updates "w", "a", "s", and "d".
#let parse-updates(body) = {
  let extract(it) = {
    ""
    if it == [ ] {
      " "
    } else if it.func() == text {
      it.text
    } else if it.func() == [].func() {
      it.children.map(extract).join()
    }
  }
  extract(body).clusters().map(lower).filter(c => c in "wasdx")
}

// Adds two points.
#let add-points(p1, p2) = (x: p1.x + p2.x,  y: p1.y + p2.y)

// Accesses the layer at the given position, returning `none` if the
// position is out of bounds
#let layer-at(layer, p) = {
  if p.x >= 0 and p.y >= 0 {
    layer.at(p.y, default: ()).at(p.x, default: none)
  }
}

// Move an entity from one position to another.
#let move-entity(level, from, to) = {
  let v = level.front.at(from.y).at(from.x)
  level.front.at(from.y).at(from.x) = "_"
  level.front.at(to.y).at(to.x) = v
  level
}

// Update the state of the level
#let update(level, u) = {
  let delta = deltas.at(u)
  let old = level.pos
  let new = add-points(old, delta)
  let new2 = add-points(new, delta)
  let new-back = layer-at(level.back, new)
  let new-front = layer-at(level.front, new)

  // Handle floor.
  if new-back in ("f", "g") {
    // Handle block at new position.
    if new-front == "b" {
      let new-back2 = layer-at(level.back, new2)
      let new-front2 = layer-at(level.front, new2)
      if new-back2 not in ("f", "w", "g") or new-front2 != "_" {
        return level
      }

      level = move-entity(level, new, new2)
    }

    level.pos = new
  }

  // Handle bridge block in water.
  if new-back == "w" and new-front == "b" {
    level.pos = new
  }

  // Handle goal.
  if new-back == "g" {
    level.won = true
  }

  level
}

// Selects a tile from the texture map.
#let tex(x, y) = block(
  width: size,
  height: size,
  fill: white,
  stroke: 1pt + gray,
  clip: true,
  place(
    top + left,
    dx: -size * x,
    dy: -size * y,
    texture,
  ),
)

// Render one cell of the level.
#let render-cell(level, p) = {
  let guy = p == level.pos
  let b = layer-at(level.back, p)
  let f = layer-at(level.front, p)

  // Is the Typst-guy delta-next to the current position.
  let guy-at(delta) = {
    let p2 = add-points(p, delta)
    p2 == level.pos and layer-at(level.back, p2) != "w"
  }

  // Is there a ball delta-next to the player.
  let ball-at(delta) = {
    let p2 = add-points(level.pos, delta)
    layer-at(level.front, p2) == "b" and layer-at(level.back, p2) != "w"
  }

  // Are we next to at most one snowball?
  let solo = deltas.values().filter(ball-at).len() < 2

  // Pick the best tile from the texture.
  if b == "f" {
    if guy {
      if solo and ball-at(deltas.w) { tex(1, 3) }
      else if solo and ball-at(deltas.a) { tex(4, 2) }
      else if solo and ball-at(deltas.s) { tex(2, 2) }
      else if solo and ball-at(deltas.d) { tex(0, 3) }
      else { tex(2, 3)  }
    }
    else if f == "b" {
      if solo and guy-at(deltas.w) { tex(3, 1) }
      else if solo and guy-at(deltas.a) { tex(4, 0) }
      else if solo and guy-at(deltas.s) { tex(1, 0) }
      else if solo and guy-at(deltas.d) { tex(1, 1) }
      else { tex(4, 1) }
    }
    else { tex(4, 4) }
  } else if b == "w" {
    let v = calc.rem(p.x + p.y, 4)
    if f == "b" and guy { tex(3, 4) }
    else if f == "b" { tex(2, 4) }
    else if v == 0 { tex(4, 3) }
    else if v == 1 { tex(3, 3) }
    else if v == 2 { tex(1, 4) }
    else { tex(0, 4) }
  } else if b == "g" {
    if guy { tex(3, 2) }
    else if f == "b" {
      if solo and guy-at(deltas.w) { tex(2, 1) }
      else if solo and guy-at(deltas.a) { tex(3, 0) }
      else if solo and guy-at(deltas.s) { tex(0, 0) }
      else if solo and guy-at(deltas.d) { tex(0, 1) }
      else { tex(2, 0) }
    }
    else { tex(1, 2)  }
  } else if b == "x" {
    tex(0, 2)
  } else {
    panic("unknown back tile", b)
  }
}

// Display the current level.
#let render-level(level) = {
  let h = level.back.len()
  let w = level.back.first().len()

  let cells = ()
  for y in range(level.back.len()) {
    for x in range(level.back.at(y).len()) {
      let p = (x: x, y: y)
      cells.push(render-cell(level, p))
    }
  }

  grid(
    columns: (size,) * w,
    rows: (size,) * h,
    ..cells,
  )
}

// Displays an informative popup.
#let popup(main, sub: none) = place(rect(
  width: 5.7 * size,
  height: 1.7 * size,
  fill: black,
  stroke: 6pt + white,
  text(1em, main) + if sub != none {
    v(0.4em, weak: true)
    text(0.5em, sub)
  }
))

// The game template.
#let game(
  levels: (
    read("levels/level1.txt"),
    read("levels/level2.txt"),
    read("levels/level3.txt"),
  ),
  body,
) = {
  set page(width: auto, height: auto, margin: 1pt, fill: gray.lighten(70%))
  set align(center + horizon)
  set place(center + horizon)
  set text(30pt, fill: white, font: "VG5000")
  let setup(i) = parse-level(levels.at(i))

  let lvl = 0
  let score = 0
  let level = setup(lvl)

  for u in parse-updates(body) {
    if level.won and lvl + 1 < levels.len() and u == "x" {
      lvl += 1
      level = setup(lvl)
    } else if not level.won and u in "wasd" {
      level = update(level, u)
      score += 1
    }
  }

  render-level(level)

  if level.won {
    if lvl + 1 == levels.len() {
      popup([You win!], sub: [(in #score moves)])
    } else {
      popup([Level #(lvl + 1) complete], sub: [(press x to continue)])
    }
  }
}
