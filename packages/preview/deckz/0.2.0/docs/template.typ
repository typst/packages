#import "@preview/mantys:1.0.2": *
#import "@preview/tidy:0.4.3": *
#import "../src/lib.typ" as deckz: *

// Initialization of the Mantys document
#let (doc, mantys) = mantys-init(
  ..toml("../typst.toml"),
  title: "Deckz",
  // subtitle: "for _Deck Visualization_",
  date: datetime.today(),
  examples-scope: (
    scope: (deckz: deckz),
    imports: (:)
  ),
  theme: themes.default,

  abstract: [
    DECKZ is a flexible and customizable package to render and display poker-style playing cards in #link("https://typst.app/")[Typst].
    Use it to visualize individual cards, create stylish examples in documents, or build full decks and hands for games and illustrations.
  ],

)

/// Helper for Tidy-Support
#let show-module(name, ..tidy-args) = tidy-module(
  name,
  read("../src/" + name + ".typ"),
  module: "deckz",
  ..tidy-args.named()
)

/// Helpers for note
#let coming-soon-feature(body) = {
  success-alert[
    #text(olive)[
      #octique.octique-inline("rocket", color: olive)	
      _Coming Soon Feature_.
    ]
    #body
  ]
}