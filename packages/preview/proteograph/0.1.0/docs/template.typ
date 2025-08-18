#import "@preview/tidy:0.4.3"
#import "../src/ion_series.typ": *

#let code-block(code, language, title: none) = {
  v(6pt)

  if (title != none) {
    text(10pt, style: "italic", title) 
    linebreak()
  }
  raw(code, lang: language)
  v(6pt)
}
