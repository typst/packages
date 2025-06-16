// make the PDF reproducible to ease version control
#set document(date: none)

// #import "../src/lib.typ" as prequery
#import "@preview/prequery:0.1.0"

// toggle this comment or pass `--input prequery-fallback=true` to enable fallback
// #prequery.fallback.update(true)

#prequery.image(
  "https://en.wikipedia.org/static/images/icons/wikipedia.png",
  "assets/wikipedia.png")
