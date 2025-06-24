#import "@preview/scripst:1.1.1": *

#let abstract = [
  Scripst is a simple and easy-to-use Typst language template, suitable for various scenarios such as daily documents, assignments, notes, papers, etc.
]
#let preface = [
  Typst is a simple document generation language with syntax similar to lightweight Markdown markup. Using appropriate `set` and `show` commands, you can highly customise the style of your documents.

  Scripst is a simple and easy-to-use Typst language template, suitable for various scenarios such as daily documents, assignments, notes, papers, etc.
]

#show: scripst.with(
  template: "article",
  title: [Scripst Documentation],
  info: [Article Style Set],
  author: "AnZrew",
  // author: ("AnZrew", "AnZrew"),
  time: datetime.today().display(),
  abstract: abstract,
  keywords: (
    "Scripst",
    "Typst",
    "template",
  ),
  preface: preface,
  /* preface parameter not available if template sets to 'article'*/
  contents: true,
  content-depth: 3,
  matheq-depth: 2,
  lang: "fr",
)

= #lorem(2)

#countblock("thm", subname: [_Fermat's Last Theorem_], lab: "fermat", cb)[

  No three $a, b, c in NN^+$ can satisfy the equation
  $
    a^n + b^n = c^n
  $
  for any integer value of $n$ greater than 2.
]
#proof[Cuius rei demonstrationem mirabilem sane detexi. Hanc marginis exiguitas non caperet.]
Fermat did not provide proof publicly for @fermat.

== #lorem(3)

#grid(columns: (1fr,) * 2)[
  #figure(
    three-line-table[
      | Name | Age | Gender |
      | --- | --- | --- |
      | Jane | 18 | Male |
      | Doe | 19 | Female |
    ],
    caption: [`three-line-table` table example],
  )
][
  $
    i hbar dv(,t) ket(Psi(t)) = hat(H) ket(Psi(t))
  $
]
