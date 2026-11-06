#import "@preview/mantys:1.0.0": *

#show: mantys(
  name: "mantys",
  version: "1.0.0",
  authors: (
    "Jonas Neugebauer",
  ),
  license: "MIT",
  description: "Helpers to build manuals for Typst packages.",
  repository: "https://github.com/jneug/typst-mantys",

  /// Uncomment one of the following lines to load the above
  /// package information directly from the typst.toml file
  // ..toml("../typst.toml"),
  // ..toml("typst.toml"),

  title: "Manual title",
  // subtitle: "Tagline",
  date: datetime.today(),

  // url: "",

  abstract: [
    #lorem(50)
  ],

  // examples-scope: (
  //   scope: (:),
  //   imports: (:)
  // )

  // theme: themes.modern
)

/// Helper for Tidy-Support
/// Uncomment, if you are using Tidy for documentation
// #let show-module(name, scope: (:), outlined: true) = tidy-module(
//   read(name + ".typ"),
//   name: name,
//   show-outline: outlined,
//   include-examples-scope: true,
//   extract-headings: 3,
// )
