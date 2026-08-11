#let fig-supplement = [Figure]
#let text-size = 11pt
#let paper-size = "a4"

#let states = (
  author: state("author", none),
  colors: state("theme-colors"),
  counter-part: counter("part"),
  in-outline: state("in-outline", false),
  isappendix: state("isappendix", false),
  isfrontmatter: state("isfrontmatter", false),
  tufte: state("tufte", false),
  localization: state("localization"),
  num-heading: state("num-heading", "1"),
  num-pattern: state("num-pattern", "1.1."),
  num-pattern-eq: state("num-pattern-eq", "(1.1)"),
  num-pattern-fig: state("num-pattern-fig", "1.1"),
  num-pattern-subfig: state("num-pattern-subfig", "1.1a"),
  page-numbering: state("page-numbering", "1/1"),
  part-numbering: state("part-numbering", "1"),
  sidenotecounter: counter("sidenotecounter"),
  theme: state("theme", "fancy"),
  title: state("title", none),
)

#let default-language = ("en", "de", "fr",  "es", "it", "pt")

#let default-config-options = (
  part-numbering: "1",
)

#let default-fonts = (
  body: "New Computer Modern",
  math: "New Computer Modern Math",
  raw: "Cascadia Code"
)

#let default-colors = (
  primary: rgb("#c1002a"),
  secondary: rgb("#dddddd").darken(15%),
  boxeq: rgb("#dddddd"),
  header: black,
)

// Default Title page
#let default-title-page = context {
  set page(
    paper: paper-size,
    header: none,
    footer: none,
    margin: auto
  )

  align(center + horizon)[
    #text(size: 3em, fill: states.colors.get().primary)[*#states.title.get()*]
    #v(1em)
    #text(size: 1.5em)[#states.author.get()]
  ]
}