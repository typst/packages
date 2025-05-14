#import "deps.typ": *

#let align-odd-even(odd-left, odd-right) = {
  if calc.odd(here().page()) {
    align(right, [#odd-left #h(6fr) #odd-right])
  } else {
    align(right, [#odd-right #h(6fr) #odd-left])
  }
}

#let label-title = <chapter>
#let chapter-title(title, book: "", lang: "en") = {
  let the-title = text(
    24pt,
    title,
    font: config-fonts.family.at(lang).title,
    style: "italic",
    weight: "bold",
  )
  if book == "" {
    the-title
  } else {
    pagebreak(weak: true, to: "odd")

    let title-index = context counter(label-title).display("1")

    let bottom-pad = 10%
    block(
      height: 50%,
      grid(
        columns: (10fr, 1fr, 2fr),
        rows: (2fr, 12fr),
        align: (right + bottom, center, left + bottom),
        place(
          right + bottom,
          dx: -1%,
          pad(
            [#figure(
                the-title,
                kind: "title",
                supplement: none,
                numbering: _ => none,
                caption: none,
              )#label-title],
            bottom: bottom-pad,
          ),
        ),
        line(angle: 90deg, length: 100%),
        pad(text(50pt, title-index, font: config-fonts.family.at(lang).title, weight: "bold")),
      ),
    )
  }
}

#let label-chapimg = <label-chapimg>
#let chapter-img(img, title: "") = {
  block(
    place(
      right + bottom,
      dx: 1%,
      [#figure(
          img,
          placement: top,
          kind: "chapimg",
          supplement: none,
          numbering: _ => none,
          caption: title,
        )#label-chapimg],
    ),
  )
}

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

#let tableq(data, k, inset: 0.3em) = table(
  columns: k,
  inset: inset,
  align: center + horizon,
  stroke: table-three-line(rgb("000")),
  ..data.flatten(),
)

#let ctext(body) = text(body, font: config-fonts.family.at("zh").math)

#let code(text, lang: "python", breakable: true, width: 100%) = block(
  fill: rgb("#F3F3F3"),
  stroke: rgb("#DBDBDB"),
  inset: (x: 1em, y: 1em),
  outset: -.3em,
  radius: 5pt,
  spacing: 1em,
  breakable: breakable,
  width: width,
  raw(
    text,
    lang: lang,
    align: left,
    block: true,
  ),
)

#let tip = tip-box
#let note = note-box
#let quote = quote-box
#let warning = warning-box
#let caution = caution-box
