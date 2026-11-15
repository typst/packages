#import "tud-color-rgb.typ": *

#let tud-logo(
  full: true,
  U: tud-blue,
  font: none,
  fill: black,
  ..args
) = {
  let original = read("tudelft.svg")
  let original = if font == none {
    original.replace(
      "id='Tvector'",
      "id='Tvector' fill='black'",
    ).replace(
      "id='Delftvector'",
      "id='Delftvector' fill='black'",
    )
  } else {
    original.replace(
      "id='Tvector'",
      "id='Tvector' fill='none'",
    ).replace(
      "id='Uvector' fill='#00AEEF'",
      "id='Uvector' fill='none'",
    ).replace(
      "id='Delftvector'",
      "id='Delftvector' fill='none'",
    ).replace(
      "id='text' fill='none' font-family='Roboto'",
      "id='text' fill='black' font-family='" + font + "'"
    ).replace(
      "id='Utext'",
      "id='Utext' fill='#00AEEF'",
    )
  }
  original = if full {
    if font == none {
      original.replace(
        "id='TUDvector'",
        "id='TUDvector' fill='black'",
      ).replace(
        "id='TUDtext'",
        "id='TUDtext' fill='none'"
      )
    } else {
      original.replace(
        "id='TUDvector'",
        "id='TUDvector' fill='none'",
      ).replace(
        "id='TUDtext'",
        "id='TUDtext' fill='black'"
      )
    }
  } else {
    original.replace(
      "id='TUDvector'",
      "id='TUDvector' fill='none'",
    ).replace(
      "id='TUDtext'",
      "id='TUDtext' fill='none'"
    )
  }
  original = original.replace(
    "fill='#00AEEF'",
    "fill='" + if U == none { fill.to-hex() } else { U.to-hex() } + "'"
  )
  original = original.replace(
    "fill='black'",
    "fill='" + fill.to-hex() + "'"
  )
  {
    box(move(
      dy: 0.06em,
      image(bytes(original), height: 1.5em, ..args)
    ))
    if not full {h(-1.6em)}
  }
}

#let svg = "<svg xmlns='http://www.w3.org/2000/svg' viewBox='57 -400 181 180'>   <path
      id='flame' fill='black'
      d='m 192.4,-301.5
         c -12.9,   4.1 -26.3,   0.8 -26.2, -16.5
             0.0, -26.4  61.9, -48.5  70.5, -71.5
             2.1,  -5.7   2.3, -10.5  -0.5, -10.3
            -2.0,   0.1  -0.4,   3.0  -4.8,   7.3
         C 205.8,-366.8 162.8,-366.9 129.8,-352.1
           108.2,-342.4  44.9,-312.6  59.4,-246.1
         c   0.7,   3.1   2.6,  13.7   4.5,  13.7
             2.3,   0     2.2,  -6.3   2.2, -13.9
            -0.5, -39.6  46.4, -50.6  61.7, -76.5
             1.8,  -3.1   5.0,  -7.4   5.7,  -5.4
             0.4,   1.0   0.1,   2.4  -0.5,   5.2
            -4.8,  21.3 -27.0,  34.9 -20.7,  50.1
             8.2,  19.7  31.7,   5.0  39.0,  -7.7
             1.9,  -3.5   3.0,  -5.7   4.3,  -5.3
             1.0,   0.3   0.9,   4.3   0.3,   7.9
            -3.9,  22.9  -9.1,  35.7 -25.9,  48.8
            -5.3,   4.2 -13.8,   5.0 -12.7,   8.2
             0.3,   0.8   3.9,   0.7   6.8,   0.5
            44.6,  -2.9  81.9, -55.4  91.8, -89.8
             1.0,  -2.4   1.3,  -4.7   0.3,  -5.5
            -1.4,  -1.0  -3.3,   1.3  -5.3,   3.1
            -5.1,   4.5 -12.1,   9.1 -18.5,  11.2'
   /></svg>"
#let flame(fill: black, ..args) = {
  box(image(bytes(
    svg.replace("black", fill.to-hex())
  ), format: "svg", ..args))}
