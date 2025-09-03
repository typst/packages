#import "@preview/suiji:0.3.0": gen-rng, choice, shuffle
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
  extract(body).clusters().map(lower)
}

#let minoes = (("ZZ_", "_ZZ"), ("OO", "OO"), ("_SS", "SS_"), ("IIII",), ("__L", "LLL"), ("J__", "JJJ"), ("_T_", "TTT"))

#let shuffle-minoes(rng) = {
  let indices = range(minoes.len())
  let (rng-after-shuffle, shuffled) = shuffle(rng, indices)
  (rng-after-shuffle, shuffled.map(i => minoes.at(i)))
}

#let create-mino(mino, cols, rows) = {
  let width = calc.max(..mino.map(it => it.len()))
  (
    mino: mino,
    pos: (x: calc.floor(cols / 2) - calc.floor(width / 2) - 1, y: rows + 1),
    height: mino.len(),
    width: width,
    index: minoes.position((value)=>{value==mino})
  )
}

#let new-mino(rng, bag, cols, rows) = {
  let mino-bag = bag
  let rng-before-draw = rng
  let mino = none
  let bag-before-draw = mino-bag
  let rng-after-bag = rng-before-draw
  let bag-after-bag = bag-before-draw
  if mino-bag.len() == 0 {
    let (rng-after-shuffle, new-bag) = shuffle-minoes(rng-before-draw)
    bag-after-bag = new-bag
    rng-after-bag = rng-after-shuffle
  }
  mino = bag-after-bag.at(0)
  let bag-after-draw = bag-after-bag.slice(1, bag-after-bag.len())
  (rng-after-bag, bag-after-draw, create-mino(mino, cols, rows))
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
    index: mino.index,
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

#let hold(state, cols: 10, rows: 20) = {
  if state.can-hold == false {
    return state
  }
  state.can-hold = false
  if state.hold == none {
    state.hold = create-mino(minoes.at(state.current.index), cols, rows)
    state.current = state.next
    (state.rng, state.mino-bag, state.next) = new-mino(state.rng, state.mino-bag, cols, rows)
  } else {
    let hold-mino = state.hold
    state.hold = create-mino(minoes.at(state.current.index), cols, rows)
    state.current = hold-mino
  }
  return state
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
      #pad(top: 2pt, left: 3pt, bottom: 0pt, [*Hold*])
      #if state.hold != none [
        #align(center + horizon)[
          #render-map(state.hold.mino.map(it => it.split("")).rev(), bg-color: white.transparentize(100%))
        ]
      ] else [
        #align(center + horizon)[
          None
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
    state.can-hold = true
    state.current = state.next
    (state.rng, state.mino-bag, state.next) = new-mino(state.rng, state.mino-bag, cols, rows)
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

#let game(body, seed: 2, cols: 10, rows: 20, actions: (
  left: ("a", ),
  right: ("d", ),
  down: ("s", ),
  left-rotate: ("q", ),
  right-rotate: ("e", ),
  half-turn: ("w", ),
  fast-drop: ("f", ),
  hold-mino: ("c", ),
)) = {
  set page(height: auto, width: auto, margin: (top: 0.5in - 30pt, bottom: 0.5in + 40pt, rest: 0.5in))

  let chars = parse-actions(body)

  let rng-initial = gen-rng(seed)
  let (rng-after-initial-bag, bag-after-initial-bag) = shuffle-minoes(rng-initial)
  let state = (
    rng: rng-after-initial-bag,
    mino-bag: bag-after-initial-bag,
    current: none,
    next: none,
    map: range(rows + 4).map(_ => range(cols).map(it => "_")),
    end: false,
    score: 0,
    hold: none,
    can-hold: true,
  )

  (state.rng, state.mino-bag, state.current) = new-mino(rng-after-initial-bag, bag-after-initial-bag, cols, rows)
  (state.rng, state.mino-bag, state.next) = new-mino(state.rng, state.mino-bag, cols, rows)

  for char in chars {
    if actions.left.any(it => it == char) {
      (state, _) = move(state, cols: cols, rows: rows, dx: -1, dy: 0)
    } else if actions.right.any(it => it == char) {
      (state, _) = move(state, cols: cols, rows: rows, dx: 1, dy: 0)
    } else if actions.fast-drop.any(it => it == char) {
      let success = true
      while success {
        (state, success) = move(state, cols: cols, rows: rows, dy: -1)
      }
    } else if actions.right-rotate.any(it => it == char) {
      state = rotate(state, angle: 1, cols: cols, rows: rows)
    } else if actions.left-rotate.any(it => it == char) {
      state = rotate(state, angle: 3, cols: cols, rows: rows)
    } else if actions.half-turn.any(it => it == char) {
      state = rotate(state, angle: 2, cols: cols, rows: rows)
    } else if actions.hold-mino.any(it => it == char) {
      state = hold(state, cols: cols, rows: rows)
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
