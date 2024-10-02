#import "@preview/mantys:0.1.4": *

#let maze(alphabet, width: 20, height: 4) = {
  import "baffle.typ": baffle
  par(leading: 0.50em, {
    for y in range(height) {
      for x in range(width) {
        [#baffle(alphabet: alphabet, [X])]
      }
      [\ ]
    }
  })
}

#let alphabets = yaml("alphabets.yaml")
