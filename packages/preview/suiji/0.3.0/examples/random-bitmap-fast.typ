#set document(date: none)


#import "/src/lib.typ": *


#set page(width: auto, height: auto, margin: 0pt)


#{
  let seed = 0
  let unit = 1mm
  let (width, height) = (200,) * 2

  let rng = gen-rng-f(seed)
  let data = ()
  for i in range(width * height * 3) {
    rng = randi-f(rng)
    data.push(rng.bit-rshift(23))
  }

  grid(columns: (unit,)*width, rows: unit,
    ..data.chunks(3).map(((r,g,b)) => grid.cell(fill: rgb(r,g,b))[])
  )
}
