#import "../lib.typ": book, book-contents, book-mainmatter, book-appendix, book-backmatter, book-index
#import "../lib.typ": worked-example, analysis-note, exercise

#show: book.with(
  title: [Mathematics for Data Analysis],
  subtitle: [A short learning workbook],
  author: [Example Author],
  eyebrow: [A practical guide],
  note: [Exercises include space for working],
  date: [2026],
  accent: rgb("#23616B"),
  font: "Libertinus Serif",
  math-font: "New Computer Modern Math",
  running-headers: "bottom",
)

= How to use this book

This unnumbered front matter introduces the reader before the contents page.
The cover, page furniture, and accent color come from the book style; the prose
and chapter structure remain ordinary Typst.

#book-contents()

#book-mainmatter[
  = Reading a formula

  A formula is a compact sentence. Identify its objects and operations before
  substituting values.

  == A worked calculation

  #worked-example[
    If a score is the mean of four values, then
    $ (2 + 4 + 6 + 8) / 4 = 5 $.
  ]

  #analysis-note[
    In your own analysis, write down what each value represents before
    interpreting the result.
  ]

  #exercise[Calculate the mean of 3, 5, and 10.] <exercise:mean>

  == A second section

  An exercise can request a taller answer area when the reader needs more room.
  #exercise(grid: 35mm)[Show each step in your calculation.] <exercise:steps>
]

#book-appendix[
  = Notation

  $x$ denotes a value, and $n$ denotes a count.
]

#book-backmatter[
  = Further reading

  Add references or notes here.
]

#book-index[
  Abstraction, levels of, 14, 19

  Analysis: worked example, 5; interpreting results, 7

  Equations, 4–6

  Mean, arithmetic, 5
]
