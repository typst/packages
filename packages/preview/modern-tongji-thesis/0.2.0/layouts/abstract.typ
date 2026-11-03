#import "../utils/fonts.typ": TJFONT_COVER_FIELD, TJFONT_INFO, TJFONT_HEADING

// Abstract pages — Chinese and English
#let make-abstract(
  title: "", subtitle: none, abstract: "", keywords: (), prompt: (), is-english: false,
  heading-override: none, fonts: none,
) = {
  let f = if fonts != none { fonts } else { font-family }
  align(center)[
    #v(1em)
    #text(font: f.hei, size: TJFONT_COVER_FIELD, weight: "bold", title)
    #if subtitle != none and subtitle != "" {
      [
        #v(0.2em)
        #text(font: f.hei, size: TJFONT_INFO, weight: "bold", subtitle)
      ]
    }
    #v(1.5em)
  ]
  let h = if heading-override != none { heading-override } else { prompt.at(0) }

  align(center)[
    #text(font: f.hei, size: TJFONT_HEADING, weight: if is-english { "bold" } else { "regular" }, h)
  ]

  set par(first-line-indent: 2em)
  abstract
  v(1.2em)
  set par(first-line-indent: 0em)
  text(weight: "bold", prompt.at(1))
  let keywords-string = if is-english { keywords.join(", ") } else { keywords.join("，") }
  text(keywords-string)
}
