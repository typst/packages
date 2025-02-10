#import "../../../src/mantys.typ": *

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

  show-index: false,

  theme: themes.cnltx
)


#heading(depth: 1, "Heading")
#lorem(300)


#heading(depth: 2, "Heading")
#lorem(300)


#heading(depth: 2, "Heading")
#lorem(300)

#heading(depth: 1, "Heading")
#lorem(300)
