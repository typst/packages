#import "/src/corkscrew.typ" as chx
#set page(height: auto, width: 40em, margin: 2em)
#set box(width: 2em, height: 2em)

// everything below goes in the README example

#let cool-scale = chx.new(
  rotations: -0.5,
  saturate: 1.5,
  gamma: 0.9,
)

#box(fill: cool-scale(0))
#box(fill: cool-scale(0.25))
#box(fill: cool-scale(0.5))
#box(fill: cool-scale(0.75))
#box(fill: cool-scale(3, domain: (0, 4)))

#{
  let body = lorem(54)
  let length = body.len()
  let i = 0
  for char in body {
    text(fill: cool-scale(i, domain: length), char)
    i += 1
  }
}

#pagebreak()

#let wild-scale = chx.new(
  start: 2,
  rotations: 13,
  saturate: 4,
  gamma: 1.1,
  reverse: true,
)

#box(fill: wild-scale(0))
#box(fill: wild-scale(0.25))
#box(fill: wild-scale(0.5))
#box(fill: wild-scale(0.75))
#box(fill: wild-scale(3, domain: (0, 4)))

#{
  let body = lorem(54)
  let length = body.len()
  let i = 0
  for char in body {
    text(fill: wild-scale(i, domain: length), char)
    i += 1
  }
}
