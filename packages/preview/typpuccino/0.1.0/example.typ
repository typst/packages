#import "src/lib.typ": latte, frappe, macchiato, mocha

#let relative-luminance(color) = {
  let rgb = rgb(color).components(alpha: false).map(c => {
    c = float(c)
    if c <= 0.03928 { c / 12.92 } else {
      calc.pow((c + 0.055) / 1.055, 2.4)
    }
  })
  (0.2126, 0.7152, 0.0722).zip(rgb).map(e => e.at(0) * e.at(1)).sum()
}

#let determine-text-color(color) = {
  let l = relative-luminance(color)
  let contrast-black = (l + 0.05) / 0.05
  let contrast-white = 1 / (l + 0.05)
  if contrast-black > contrast-white {
    black
  } else {
    white
  }
}

#let show-palette(name, palette) = {
  box[
    == #name

    #grid(
      columns: 7,
      gutter: 1em,
      ..palette.color-entries.pairs().map(
        e => {
          let (name, color) = e
          square(
            fill: color,
            width: 5em,
            align(center + horizon, text(fill: determine-text-color(color), name)),
          )
        },
      ),
    )

    #v(3em)
  ]
}

= Usage

#grid(columns: 2, gutter: 1em, [ ```typst
#import "@preview/typpuccino:0.1.0": latte, frappe, macchiato, mocha
#square(fill: mocha.red)
``` ], [#square(fill: mocha.red)])

= Color Palettes

#show-palette("Latte", latte)
#show-palette("Frappe", frappe)
#show-palette("Macchiato", macchiato)
#show-palette("Mocha", mocha)
