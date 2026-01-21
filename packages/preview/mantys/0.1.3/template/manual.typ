#import "@preview/mantys:0.1.3": *

#show: mantys.with(
  name: "mantys",
  version: "0.1.0",
  authors: (
    "Jonas Neugebauer",
  ),
  license: "MIT",
  description: "Helpers to build manuals for Typst packages.",
  repository:"https://github.com/jneug/typst-mantys",

  /// Uncomment to load the above package information
  /// directly from the typst.toml file
  // ..toml("typst.toml"),

  title: "Manual title",
  // subtitle: "Tagline",
  date: datetime.today(),

  // url: "",

  abstract: [
    #lorem(50)
  ],

  // examples-scope: ()

  // toc: false
)

/// Helper for Tidy-Support
/// Uncomment, if you are using Tidy for documentation
// #let show-module(name, scope: (:), outlined: true) = tidy-module(
//   read(name + ".typ"),
//   name: name,
//   show-outline: outlined,
//   include-examples-scope: true,
//   extract-headings: 3,
//   tidy: tidy
// )
