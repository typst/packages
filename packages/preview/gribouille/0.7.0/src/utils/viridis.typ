// Viridis-family colour ramps.
// 10-stop approximations of the MPL 2.0 tables from matplotlib; sufficient for
// discrete swatches and interpolated continuous fills in CeTZ.
// magma/plasma/inferno/cividis available but not auto-selected.

#let viridis = (
  rgb("#440154"),
  rgb("#482878"),
  rgb("#3e4989"),
  rgb("#31688e"),
  rgb("#26828e"),
  rgb("#1f9e89"),
  rgb("#35b779"),
  rgb("#6ece58"),
  rgb("#b5de2b"),
  rgb("#fde725"),
)

#let magma = (
  rgb("#000004"),
  rgb("#180f3d"),
  rgb("#440f76"),
  rgb("#721f81"),
  rgb("#9e2f7f"),
  rgb("#cd4071"),
  rgb("#f1605d"),
  rgb("#fd9567"),
  rgb("#feca8d"),
  rgb("#fcfdbf"),
)

#let plasma = (
  rgb("#0d0887"),
  rgb("#41049d"),
  rgb("#6a00a8"),
  rgb("#8f0da4"),
  rgb("#b12a90"),
  rgb("#cc4778"),
  rgb("#e16462"),
  rgb("#f2844b"),
  rgb("#fca636"),
  rgb("#fcce25"),
)

#let inferno = (
  rgb("#000004"),
  rgb("#160b39"),
  rgb("#420a68"),
  rgb("#6a176e"),
  rgb("#932667"),
  rgb("#bc3754"),
  rgb("#dd513a"),
  rgb("#f37819"),
  rgb("#fca50a"),
  rgb("#fcffa4"),
)

#let cividis = (
  rgb("#00224e"),
  rgb("#123570"),
  rgb("#3b496c"),
  rgb("#575d6d"),
  rgb("#707173"),
  rgb("#8a8678"),
  rgb("#a59c74"),
  rgb("#c3b369"),
  rgb("#e1cc55"),
  rgb("#fee838"),
)

#let palette(option) = {
  if option == "magma" { magma } else if option == "plasma" { plasma } else if (
    option == "inferno"
  ) { inferno } else if option == "cividis" { cividis } else { viridis }
}
