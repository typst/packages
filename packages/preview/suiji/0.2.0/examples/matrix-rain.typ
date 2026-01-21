#import "/src/lib.typ": *
#import "@preview/cetz:0.2.2"

#set page(width: auto, height: auto, margin: 0pt)

#cetz.canvas(length: 1pt, {
  import cetz.draw: *

  let font-size = 10
  let num-col = 80
  let num-row = 32
  let text-len = 16
  let seq = "abcdefghijklmnopqrstuvwxyz!@#$%^&*".split("").slice(1, 35).map(it => raw(it))
  let rng = gen-rng(42)
  let num-cnt = 0
  let val = 0
  let chars = ()

  rect((-10, -10), (font-size * (num-col - 1) * 0.6 + 10, font-size * (num-row - 1) + 10), fill: black)

  for c in range(num-col) {
    (rng, num-cnt) = integers(rng, low: 1, high: 3)
    for cnt in range(num-cnt) {
      (rng, val) = integers(rng, low: -10, high: num-row - 2)
      (rng, chars) = choice(rng, seq, size: text-len)
      for i in range(text-len) {
        let y = i + val
        if y >= 0 and y < num-row {
          let col = green.transparentize((i / text-len) * 100%)
          content(
            (c * font-size * 0.6, y * font-size),
            text(size: font-size * 1pt, fill:col, stroke: (text-len - i) * 0.04pt + col, chars.at(i))
          )
        }
      }
    }
  }
})
