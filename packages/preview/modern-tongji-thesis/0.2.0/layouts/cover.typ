#import "../utils/fonts.typ": TJFONT_COVER, TJFONT_COVER_FIELD

// Cover page — matches LaTeX \maketitle
#let make-cover(cover, cover-text: "毕业设计（论文）", fonts: none) = {
  let f = if fonts != none { fonts } else { font-family }
  align(center)[
  #image("../figures/tongji.svg", height: 2.5cm)
  #text(
    "TONGJI UNIVERSITY",
    font: f.hei,
    size: TJFONT_COVER_FIELD,
    weight: "bold",
  )

  #text(cover-text, font: f.hei, size: TJFONT_COVER)
  #v(60pt)

  #set text(font: f.hei, size: TJFONT_COVER_FIELD)
  #grid(
    columns: (5em, auto),
    gutter: 16pt,
    ..cover.enumerate().map(((idx, value)) => {
      set text(size: TJFONT_COVER_FIELD)
      if calc.even(idx) {
        let arr = value.clusters()
        let k = (4 - arr.len()) / (arr.len() - 1)
        arr.join([#h(1em * k)])
      } else {
        block(
          width: 100%,
          inset: 4pt,
          stroke: (bottom: 1pt + black),
          align(center, value),
        )
      }
    }),
  )
]}
