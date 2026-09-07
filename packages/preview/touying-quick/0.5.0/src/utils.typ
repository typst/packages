#import "deps.typ": *

#let font-for(styles, lang, role) = {
  let win-fonts = styles.fonts.at("windows", default: none)
  let mac-fonts = styles.fonts.at("macos", default: none)
  if win-fonts != none and win-fonts.at(lang, default: none) != none {
    return win-fonts.at(lang).at(role)
  } else if mac-fonts != none and mac-fonts.at(lang, default: none) != none {
    return mac-fonts.at(lang).at(role)
  }

  styles.fonts.at(lang).at(role)
}

// text
#let ctext(
  label,
  size: .8em,
  font: font-for(default-styles, "zh", "math"),
  ..options,
) = text(
  label,
  size: size,
  font: font,
  ..options,
)

// table: three-line
#let table-three-line(stroke-color) = (
  (x, y) => (
    top: if y < 2 {
      stroke-color
    } else {
      0pt
    },
    bottom: stroke-color,
  )
)

// table: grid without left border and right border
#let table-no-left-right(stroke-color) = (
  (x, y) => (
    left: if x > 2 {
      stroke-color
    } else {
      0pt
    },
    top: stroke-color,
    bottom: stroke-color,
  )
)

#let tableq(data, k, inset: 0.3em, stroke-color: rgb("000")) = {
  table(
    columns: k,
    inset: inset,
    align: center + horizon,
    stroke: table-three-line(stroke-color),
    ..data.flatten(),
  )
}

#let code(text, lang: "python", breakable: true, width: 100%) = block(
  fill: rgb("#F3F3F3"),
  stroke: rgb("#DBDBDB"),
  inset: (x: 1em, y: 1em),
  outset: -.3em,
  radius: 5pt,
  spacing: 1em,
  breakable: breakable,
  width: width,
  raw(text, lang: lang, align: left, block: true),
)

#let tip = tip-block
#let note = note-block
#let quote = quote-block
#let warning = warning-block
#let caution = caution-block
