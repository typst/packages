/// inserts preface
/// - preface (content): The actual preface content to insert
/// - authors (array): Array of authors
/// - lang (string): The language of the preface, should be "en" or "nl"
/// -> content
#let insert-preface(preface, authors, lang: "en") = {
  // preface
  if preface != none {
    heading(
      level: 1,
      numbering: none,
      outlined: true,
      if lang == "en" {
        "Preface"
      } else {
        "Voorwoord"
      },
    )
    block[#sym.zws#label("start-of-preamble")]
    v(-2em)

    // let spacing = 0.5em
    // set par(leading: spacing, spacing: spacing)
    preface
    v(1em)
    let auth = authors.join("\n")
    align(right)[_ #auth _]
  } else {
    let t = if lang == "nl" {
      "PLAATSHOUDER VOOR VOORWOORD"
    } else {
      "PLACEHOLDER FOR PREFACE"
    }
    text(purple, size: 3em)[#t]
    set text(red)
    lorem(200)
  }
}

