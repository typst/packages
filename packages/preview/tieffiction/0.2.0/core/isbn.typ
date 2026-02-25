#import "@preview/tiaoma:0.3.0"

#let render-isbn = isbn => {
  let isbn-value = isbn.replace("-", "")
  tiaoma.ean(isbn-value, options: (scale: 0.6))
}
