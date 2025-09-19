#import "@preview/mantys:1.0.2": *
#import "@preview/tidy:0.4.3" as tidy: *

#import "../src/lib.typ" as deckz

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
#let show-module(
  filename,
  submodule: none,
  ..tidy-args,
) = context {
  // Load the module content from the specified filename or array of filenames
  let name = ""
  let content = ""
  if type(filename) == str {
    name = filename
    content = read("../src/" + filename + ".typ")
  } else if type(filename) == array {
    name = filename.join("-")
    content = filename.map((n) => read("../src/" + n + ".typ")).join("\n")
  } else {
    error("Invalid module name: " + (filename))
  }

  let namespace = if submodule == none {
    "deckz"
  } else {
    "deckz." + submodule
  }

  return tidy-module(
    name,
    content,
    //submodule: submodule,
    module: namespace,
    ..tidy-args,
  )
}

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
#let bts-info(body) = {
  info-alert[
    #text(eastern)[
      #octique.octique-inline("telescope", color: eastern)	
      _Behind The Scenes_.
    ]
    #body
  ]
}