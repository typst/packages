#import "@preview/mantys:1.0.2": *
#import "@preview/tidy:0.4.3" as tidy: *

#import "../src/lib.typ" as combo

// Initialization of the Mantys document
#let (doc, mantys) = mantys-init(
  ..toml("../typst.toml"),
  title: "Combo",
  // subtitle: "for _Deck Visualization_",
  date: datetime.today(),
  examples-scope: (
    scope: (combo: combo),
    imports: (:)
  ),
  theme: themes.default,

  abstract: [
    COMBO is a library for *combinatorial operations* in #link("https://typst.app/")[Typst].
    Use it to count the number of permutations, get every combination of items in a list, or other similar tasks.
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
    "combo"
  } else {
    "combo." + submodule
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