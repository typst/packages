#import "@preview/babel:0.1.1": *
#import "../src/alphabets.typ": alphabets
#import "../assets/logo.typ": logo

#set page(
  fill: gradient.linear(
    angle: 90deg,
    // ..color.map.vlag.map(it => it.lighten(50%))
    ..(
      white,
      rgb("#2369bd").mix(white),
      rgb("#2369bd"),
      rgb("#2369bd").mix(white),
      rgb("#a9373b")
    ).map(it => it.lighten(50%))
  ),
  width: 100em,
  height: auto,
  margin: (top: 3cm),
)

#set text(font: (("Gentium Plus", "Noto Emoji")))
#show raw: set text(font: "Iosevka")

#layout(size => {
  scale(
    x: size.width,
    y: auto,
    origin: top+left,
    text(fill: black.transparentize(50%))[#box(baseline: 10%, text(size: 6pt, logo(transparentize: 50%))) _Tower of `Babel`_])
})

#v(4.5cm)

#let sample = "Ni malleviĝu do, kaj Ni konfuzu tie ilian lingvon, por ke unu ne komprenu la parolon de alia. Kaj la Eternulo disigis ilin de tie sur la supraĵon de la tuta tero, kaj ili ĉesis konstrui la urbon."//Tial oni donis al ĝi la nomon Babel, ĉar tie la Eternulo konfuzis la lingvon de la tuta tero kaj de tie la Eternulo disigis ilin sur la supraĵon de la tuta tero."

#set align(center)
#let alphabet-counter = 0
#grid(
  columns: 1,
  ..for alphabet in alphabets {
    alphabet-counter = alphabet-counter + 1
    (grid.cell([
      #block(
        width: (alphabet-counter/alphabets.len())*100%, height: 1.5em, clip: true,
        // TODO Make less hackish and ugly
        box(width: 100000%, baseline: 1.2em)[
          #set text(lang: alphabet.last().at("lang")) if "lang" in alphabet.last().keys()
          #baffle(
            sample,
            alphabet: alphabet.first(),
            punctuate: if "punctuate" in alphabet.last().keys() {alphabet.last().at("punctuate")} else {true},
            output-word-divider: if "word-divider" in alphabet.last().keys() {alphabet.last().at("word-divider")} else {" "},
            as-string: true,
          )
        ]
      )
    ]),)
  }
)

#layout(size => {
  scale(
    x: size.width,
    y: auto,
    origin: top+center,
  )[#text(
    font: "SBL Hebrew",
    lang: "hbo",
    fallback: false,
    script: "hebr",
    dir: rtl,
  )[עַל־כֵּ֞ן קָרָ֤א שְׁמָהּ֙ בָּבֶ֔ל כִּי־שָׁ֛ם בָּלַ֥ל יְהֹוָ֖ה שְׂפַ֣ת כׇּל־הָאָ֑רֶץ]]
})
