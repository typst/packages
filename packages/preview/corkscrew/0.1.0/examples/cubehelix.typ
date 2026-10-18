#import "/src/corkscrew.typ" as chx
#set page(height: auto, width: 40em, margin: 2em)
#set box(width: 2em, height: 2em)

// everything below goes in the README example

#box(fill: chx.cubehelix(0))
#box(fill: chx.cubehelix(0.25))
#box(fill: chx.cubehelix(0.5))
#box(fill: chx.cubehelix(0.75))
#box(fill: chx.cubehelix(3, domain: (0, 4)))

#{
  let body = lorem(54)
  let length = body.len()
  let i = 0
  for char in body {
    text(fill: chx.cubehelix(i, domain: length), char)
    i += 1
  }
}
