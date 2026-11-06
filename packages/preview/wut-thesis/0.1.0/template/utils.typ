#import "@preview/drafting:0.2.2": inline-note
#import "@preview/glossarium:0.5.7": print-glossary
#import "@preview/lovelace:0.3.0": *

#let glossary-outline(glossary) = {
  context {
    let lang = text.lang
    let glossary-text = if lang == "en" { "List of Symbols and Abbreviations" } else { "Wykaz symboli i skrótów" }
    heading(numbering: none, glossary-text)
    
    show figure: it => [#v(-1em) #it #v(-1em)]
    print-glossary(glossary, show-all: true, disable-back-references: true)
  }
}

#let todo(it) = [
  #let caution-rect = rect.with(inset: 1em, radius: 0.5em)
  #inline-note(rect: caution-rect, stroke: color.fuchsia, fill: color.fuchsia.lighten(80%))[
    #align(center + horizon)[#text(fill: color.fuchsia, weight: "extrabold")[TODO:] #it]
  ]
]

#let silentheading(level, body) = [
  #heading(outlined: false, level: level, numbering: none, bookmarked: true)[#body]
]

#let in-outline = state("in-outline", false)

#let flex-caption-styles = rest => {
  show outline: it => {
    in-outline.update(true)
    it
    in-outline.update(false)
  }
  rest
}

#let flex-caption(long, short) = (
  context (
    if in-outline.get() {
      short
    } else {
      long
    }
  )
)

#let code-listing-figure(caption: none, content) = {
  figure(
    caption: caption,
    rect(
      stroke: (y: 1pt + black),
      align(left, content),
    ),
  )
}

#let code-listing-file(filename, caption: none, listings-directory: "listings/") = {
  let extension = filename.split(".").last()
  code-listing-figure(raw(block: true, lang: extension, read(listings-directory + filename)), caption: caption)
}

#let algorithm(content, caption: none, ..args) = {
  figure(
    pseudocode-list(..args, booktabs: true, hooks: .5em, content),
    caption: caption,
    kind: "algorithm",
    supplement: context { if text.lang == "en" [Algorithm] else if text.lang == "pl" [Algorytm] },
  )
}

#let comment(body) = {
  text(size: .85em, fill: gray.darken(30%), sym.triangle.stroked.r + sym.space + body)
}
