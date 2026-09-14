#import "@preview/linguify:0.4.2": *

#let abstract-page(title, body, keywords, lang, database) = {
  align(center, text(1.4em, weight: 600, hyphenate: false, title))
  v(.3fr)
  align(center, text(1.2em, weight: 600, linguify(
    "abstract",
    from: database,
    lang: lang,
  )))
  body
  v(2em)
  context {
    let keys = text(weight: "bold")[#linguify("keywords", from: database, lang: lang):~]
    par(
      justify: false,
      first-line-indent: 0em,
      hanging-indent: measure(keys).width,
      align(center, {
        keys
        text(hyphenate: false, keywords.join(", "))
      }),
    )
  }

  v(1fr)

  pagebreak(weak: true)
}
