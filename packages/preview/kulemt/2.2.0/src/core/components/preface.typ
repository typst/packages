#import "../utils/placeholder.typ": placeholder

/// inserts preface
/// - preface (content): The actual preface content to insert
/// - authors (array): Array of authors
/// - lang (string): The language of the preface, should be "en" or "nl"
/// -> content
#let insert-preface(preface, authors, lang: "en") = {
  heading(
    level: 1,
    numbering: none,
    outlined: true,
    if lang == "en" { "Preface" } else { "Voorwoord" },
  )
  block[#sym.zws#label("start-of-preamble")]
  v(-2em)

  if preface != none {
    preface
    v(1em)
    align(right, emph(authors.join(linebreak())))
  } else {
    placeholder(if lang == "nl" {
      "Plaatshouder. Vul het voorwoord in via de parameter `preface`."
    } else {
      "Placeholder. Supply the preface through the `preface` parameter."
    })
  }
}
