#import "../../src/mantys.typ": *

#show: mantys(
  name: "mantys",
  version: "1.0.0",
  authors: (
    "Jonas Neugebauer",
  ),
  license: "MIT",
  description: "Helpers to build manuals for Typst packages.",
  repository: "https://github.com/jneug/typst-mantys",

  /// Uncomment to load the above package information
  /// directly from the typst.toml file
  // ..toml("../typst.toml"),

  title: "Manual title",
  // subtitle: "Tagline",
  date: datetime.today(),

  // url: "",

  abstract: [
    #lorem(50)
  ],

  // examples-scope: ()

  show-index: false,

  theme: themes.create-theme(
    title-page: (doc, theme) => {
      let default-title = (themes.default.title-page)(doc, theme).child.children
      // Remove pagebreak
      let _ = default-title.remove(-1)
      {
        set align(center)
        set block(spacing: 2em)
        default-title.join([])
      }
    }
  )
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
