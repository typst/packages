#import "@preview/suiji:0.3.0": *
#import "@preview/umbra:0.1.1": shadow-path

#set page(width: 13cm, height: 8cm, margin: 0.0cm)

#let torn-paper(
  tear-positions: (40%, 45%),
  alignment: left,
  paper-colour: rgb("ECEBE9"),
  mult: 0.4%,
  seed: auto,
  approx-steps: 100,
) = {
  assert(alignment in (left, right, top, bottom))
  context {
    let tear-positions = tear-positions
    if type(tear-positions) != array {
      tear-positions = (tear-positions, tear-positions)
    } else if tear-positions.len() == 1 {
      tear-positions = tear-positions * 2
    }
    let seed = seed
    if seed == auto {
      seed = counter(page).get().at(0)
      counter(page).step()
    }
    let chunk_size = int(calc.round(approx-steps / (tear-positions.len() - 1)))
    let steps = chunk_size * (tear-positions.len() - 1)
    let rng = gen-rng-f(seed)
    let edge0-vals
    (rng, edge0-vals) = random-f(rng, size: (steps - 1))
    edge0-vals = edge0-vals.fold((0%,), (acc, x) => {
      acc.push(acc.last() + ((x * 2 - 1) * mult))
      acc
    })
    edge0-vals = edge0-vals.chunks(chunk_size).zip(tear-positions, tear-positions.slice(1)).map(
      ((chunk, prev, next)) => {
        chunk.enumerate().map(
          ((i, x)) => {
            let r = i / (chunk.len() - 1)
            assert(r <= 1)
            prev + (next - prev) * r + x - chunk.first() * (1 - r) - chunk.last() * r
          },
        )
      },
    ).flatten()
    assert(edge0-vals.len() == steps)
    assert(edge0-vals.first() == tear-positions.first())
    assert(edge0-vals.last() == tear-positions.last())
    edge0-vals = edge0-vals.enumerate().map(((i, x)) => {
      (x, i * 100% / (steps - 1))
    })

    let edge1-vals
    (rng, edge1-vals) = random-f(rng, size: steps)
    edge1-vals = edge0-vals.rev().zip(edge1-vals).map((((x, y), r)) => (x + r * 0.2% + 2%, y))

    let shadow-vals = edge1-vals
    shadow-vals.insert(0, shadow-vals.first())

    let edge2-vals = edge1-vals
    edge2-vals.insert(0, (100%, 100%))
    edge2-vals.push((100%, 0%))

    edge1-vals = edge1-vals + edge0-vals

    edge0-vals.insert(0, (0%, 0%))
    edge0-vals.push((0%, 100%))

    if alignment == right {
      edge0-vals = edge0-vals.map(((x, y)) => (100% - x, y))
      edge1-vals = edge1-vals.map(((x, y)) => (100% - x, y))
      edge2-vals = edge2-vals.map(((x, y)) => (100% - x, y))
      shadow-vals = shadow-vals.map(((x, y)) => (100% - x, y)).rev()
    } else if alignment == top {
      edge0-vals = edge0-vals.map(((x, y)) => (y, x))
      edge1-vals = edge1-vals.map(((x, y)) => (y, x))
      edge2-vals = edge2-vals.map(((x, y)) => (y, x))
      shadow-vals = shadow-vals.map(((x, y)) => (y, x))
    } else if alignment == bottom {
      edge0-vals = edge0-vals.map(((x, y)) => (y, 100% - x))
      edge1-vals = edge1-vals.map(((x, y)) => (y, 100% - x))
      edge2-vals = edge2-vals.map(((x, y)) => (y, 100% - x))
      shadow-vals = shadow-vals.map(((x, y)) => (y, 100% - x))
    }

    layout(
      size => {
        block(
          width: 100%,
          height: 100%,
          {
            polygon(fill: paper-colour, stroke: none, ..edge2-vals)
            polygon(fill: none, stroke: none, ..edge0-vals)
            place(
              horizon + left,
              polygon(fill: white.transparentize(50%), stroke: none, ..edge1-vals),
            )
            place(top + left, shadow-path(
              ..shadow-vals,
              shadow-stops: (luma(210), paper-colour),
              shadow-radius: 0.15cm,
            ))
          },
        )
      },
    )
  }
}

#set text(size: 36pt, font: "Indie Flower")

#show regex("[a-zA-Z]"): (letter) => {
  context{
    let seed = counter("letters").get().at(0)
    counter("letters").step()
    let rng = gen-rng-f(seed)
    let x
    let y
    (rng, (x, y)) = random-f(rng, size: 2)
    box(move(dx: x * 0.1cm, dy: y * 0.2cm - 0.1cm, letter))
  }
}

#place(horizon + left, [#h(0.8cm) at a quarter to twelve

  #h(3.3cm) learn what

  #h(7.7cm) maybe])

#place(torn-paper(
  tear-positions: (100%, 95%, 86%, 78%, 70%, 50%, 30%, 0%),
  alignment: right,
  approx-steps: 250,
))
