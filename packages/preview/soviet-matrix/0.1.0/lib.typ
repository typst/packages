#import "@preview/suiji:0.3.0": gen-rng, choice
#import "mino/tetris.typ": render-field

#let parse-actions(body) = {
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
  extract(body).clusters().map(lower).filter(c => c in "wasdfqe")
}

#let minoes = (("ZZ_", "_ZZ"), ("OO", "OO"), ("_SS", "SS_"), ("IIII",), ("__L", "LLL"), ("J__", "JJJ"), ("_T_", "TTT"))

#let new-mino(rng, cols, rows) = {
  let (rng, mino) = choice(rng, minoes)
  let width = calc.max(..mino.map(it => it.len()))
  (rng, (
    mino: mino,
    pos: (x: calc.floor(cols / 2) - calc.floor(width / 2) - 1, y: rows + 1),
    height: mino.len(),
    width: width,
  ))
}

#let render-map(map, bg-color: rgb("#f3f3ed")) = {
  let map = map.map(it => it.join(""))
  render-field(map, rows: map.len(), cols: calc.max(..map.map(it => it.len())), bg-color: bg-color, radius: 0pt)
}

#let check-collision(state, cols: 10, rows: 20) = {
  if state.current.pos.x < 0 or state.current.pos.y - state.current.height + 1 < 0 or state.current.pos.x + state.current.width > cols {
    return true
  }

  for y in range(state.current.mino.len()) {
    for x in range(state.current.mino.at(y).len()) {
      if state.current.mino.at(y).at(x) != "_" and state.map.at(state.current.pos.y - y).at(state.current.pos.x + x) != "_" {
        return true
      }
    }
  }
  false
}

#let try-move(state, cols: 10, rows: 20, dx: 0, dy: 0) = {
  state.current.pos = (x: state.current.pos.x + dx, y: state.current.pos.y + dy)
  not check-collision(state, cols: cols, rows: rows)
}

#let rotate-clockwise(mino) = {
  let center = (x: mino.pos.x + calc.floor(mino.width / 2), y: mino.pos.y - calc.floor(mino.height / 2))

  let new-mino = range(mino.width).map(_ => "")
  for y in range(mino.mino.len() - 1, -1, step: -1) {
    for x in range(mino.mino.at(y).len()) {
      new-mino.at(x) += mino.mino.at(y).at(x)
    }
  }

  (
    mino: new-mino,
    pos: (x: center.x - calc.floor(mino.height / 2), y: center.y + calc.floor(mino.width / 2)),
    height: mino.width,
    width: mino.height,
  )
}

#let rotate(state, cols: 10, rows: 20, angle: 0) = {
  let next-state = state
  for _ in range(angle) {
    next-state.current = rotate-clockwise(next-state.current)
  }
  if check-collision(next-state, cols: cols, rows: rows) {
    state
  } else {
    next-state
  }
}

#let move(state, cols: 10, rows: 20, dx: 0, dy: 0) = {
  if try-move(state, cols: cols, rows: rows, dx: dx, dy: dy) {
    state.current.pos.x += dx
    state.current.pos.y += dy
    (state, true)
  } else {
    (state, false)
  }
}

#let render(state, cols: 10, rows: 20) = {
  let map = state.map

  if not state.end {
    let pos = state.current.pos

    while true {
      if try-move(state, cols: cols, rows: rows, dy: -1) {
        state.current.pos.y -= 1
      } else {
        break
      }
    }

    for y in range(state.current.mino.len()) {
      for x in range(state.current.mino.at(y).len()) {
        if state.current.mino.at(y).at(x) != "_" {
          map.at(state.current.pos.y - y).at(state.current.pos.x + x) = lower(state.current.mino.at(y).at(x))
        }
      }
    }

    for y in range(state.current.mino.len()) {
      for x in range(state.current.mino.at(y).len()) {
        if state.current.mino.at(y).at(x) != "_" {
          map.at(pos.y - y).at(pos.x + x) = state.current.mino.at(y).at(x)
        }
      }
    }
  }

  let main = state.map.slice(0, state.map.len() - 2)

  grid(columns: 2, gutter: 5pt, block(height: rows * 10pt, width: cols * 10pt, {
    place(
      top + left,
      dy: 40pt,
      dx: 2pt,
      block(stroke: luma(80%) + 0.5pt, radius: 2pt, inset: 0pt, fill: pattern(size: (10pt, 10pt))[
        #box(stroke: 0.1pt + luma(50%), width: 100%, height: 100%, fill: rgb("#f3f3ed")),
      ], height: rows * 10pt, width: cols * 10pt),
    )
    place(top + left, render-map(map, bg-color: white.transparentize(100%)))
  }), pad(top: 40pt, [
    #set block(spacing: 3pt)
    #block(height: 6em, width: 6em, stroke: luma(80%) + 0.5pt, radius: 2pt, [
      #set block(spacing: 0pt)
      #if state.end [
        #align(center + horizon)[
          *Game Over*
        ]
      ] else [
        #pad(top: 2pt, left: 3pt, bottom: 0pt, [*Next*])
        #align(center + horizon)[
          #render-map(state.next.mino.map(it => it.split("")).rev(), bg-color: white.transparentize(100%))
        ]
      ]
    ])
    #block(height: 4em, width: 6em, stroke: luma(80%) + 0.5pt, radius: 2pt, [
      #set block(spacing: 0pt)
      #pad(top: 2pt, left: 3pt, bottom: 0pt, [*Score*])
      #align(center + horizon)[
        #state.score
      ]
    ])
  ]))
}

#let next-tick(state, cols: 10, rows: 10) = {
  if try-move(state, dy: -1, cols: cols, rows: rows) {
    state.current.pos.y -= 1
  } else {
    for y in range(state.current.mino.len()) {
      for x in range(state.current.mino.at(y).len()) {
        if state.current.mino.at(y).at(x) != "_" {
          state.map.at(state.current.pos.y - y).at(state.current.pos.x + x) = state.current.mino.at(y).at(x)
        }
      }
    }
    state.current = state.next
    (state.rng, state.next) = new-mino(state.rng, cols, rows)
  }
  state
}

#let eliminate(state, cols: 10, rows: 20) = {
  let new-map = state.map.filter(row => row.filter(it => it != "_").len() != row.len())
  let eliminated = state.map.len() - new-map.len()
  state.map = new-map + range(eliminated).map(_ => range(cols).map(it => "_"))
  let level = (-2, 40, 100, 300, 1200)
  state.score += level.at(eliminated)
  state
}

#let game(body, seed: 2, cols: 10, rows: 20) = {
  set page(height: auto, width: auto, margin: (top: 0.5in - 30pt, bottom: 0.5in + 40pt, rest: 0.5in))

  let actions = parse-actions(body)

  let state = (
    rng: gen-rng(seed),
    current: none,
    next: none,
    map: range(rows + 4).map(_ => range(cols).map(it => "_")),
    end: false,
    score: 0,
  )

  (state.rng, state.current) = new-mino(state.rng, cols, rows)
  (state.rng, state.next) = new-mino(state.rng, cols, rows)

  for action in actions {
    if action == "a" {
      (state, _) = move(state, cols: cols, rows: rows, dx: -1, dy: 0)
    } else if action == "d" {
      (state, _) = move(state, cols: cols, rows: rows, dx: 1, dy: 0)
    } else if action == "f" or action == " " {
      let success = true
      while success {
        (state, success) = move(state, cols: cols, rows: rows, dy: -1)
      }
    } else if action == "e" {
      state = rotate(state, angle: 1, cols: cols, rows: rows)
    } else if action == "q" {
      state = rotate(state, angle: 3, cols: cols, rows: rows)
    } else if action == "w" {
      state = rotate(state, angle: 2, cols: cols, rows: rows)
    }
    state = next-tick(state, cols: cols, rows: rows)
    state = eliminate(state, cols: cols, rows: rows)

    if check-collision(state, cols: cols, rows: rows) {
      state.end = true
      break
    }
  }

  render(state, cols: cols, rows: rows)
}
