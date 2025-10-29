#let fig-supplement = [Figure]
#let text-size = 11pt
#let paper-size = "a4"

#let states = (
  localization: state("localization"),
  in-outline: state("in-outline", false),
  num-pattern: state("num-pattern", "1.1."),
  num-pattern-fig: state("num-pattern-fig", "1.1"),
  num-pattern-subfig: state("num-pattern-subfig", "1.1a"),
  num-pattern-eq: state("num-pattern-eq", "(1.1)"),
  num-heading: state("num-heading", "1"),
  page-numbering: state("page-numbering", "1/1"),
  isappendix: state("isappendix", false),
  isbackcover: state("isbackcover", false),
  author: state("author", none),
  title: state("title", none),
  counter-part: state("counter-part", 0),
  colors: state("theme-colors"),
  theme: state("theme", "fancy")
)

// Book config
#let default-book-config = (
  theme: "fancy",
  logo: none,
  lang: "fr",
  fonts: (
    body: "New Computer Modern",
    math: "New Computer Modern Math",
  ),
  colors: (
    primary: rgb("#c1002a"),
    secondary: rgb("#dddddd").darken(15%),
    boxeq: rgb("#dddddd"),
    header: rgb("#dddddd").darken(25%),
  ),
  title-page: none,
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