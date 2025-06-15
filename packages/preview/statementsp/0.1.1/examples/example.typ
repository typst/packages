#import "../statementsp.typ": *
#set heading(numbering: "1.")
#show heading: reset-counter(statementnum, levels: 1)

//  This is an example of the statementsp package.
#newstatementsp(
  box-name: "axiom",
  box-display: "Axiom",
  title-color: black,
  box-color: rgb("#FFCCCC"),
)

#newstatementsp(
  box-name: "def",
  box-display: "Def",
  title-color: black,
  box-color: rgb("#FFCCCC"),
)

#newstatementsp(
  box-name: "th",
  box-display: "Th",
  title-color: black,
  box-color: rgb("#B380FF"),
)

#newstatementsp(
  box-name: "prop",
  box-display: "Prop",
  title-color: black,
  box-color: rgb("#CCCCFF"),
)

#newstatementsp(
  box-name: "lem",
  box-display: "Lem",
  title-color: black,
  box-color: rgb("#CCCCFF"),
)

#newstatementsp(
  box-name: "cor",
  box-display: "Cor",
  title-color: black,
  box-color: rgb("#CCCCFF"),
)

#newstatementsp(
  box-name: "rem",
  box-display: "Rem",
  title-color: black,
  box-color: rgb("#FFFF99"),
)

#newstatementsp(
  box-name: "ex",
  box-display: "Ex",
  title-color: black,
  box-color: rgb("#CCCCCC"),
)

#newstatementsp(
  box-name: "exer",
  box-display: "演習",
  title-color: black,
  box-color: rgb("#CCCCCC"),
)


= Section one
Some sentences. 
#statementsp(
  box-name: "axiom",
  box-label: "axiomlabel",
  box-title: "Title of Axiom",
  number: true,
)[
  Some statements.
]

#statementsp(
  box-name: "def",
  box-label: "deflabel",
  box-title: "Title of Definition",
  number: true,
)[
  some sentences.
]

You can set your favourite color for the box.
#statementsp(
  box-name: "th",
  box-label: "thlabel",
  box-title: "Title of Theorem",
  number: true,
)[
  Some sentences.
]

= Section two
Some sentences.\
If you step into the next section, the top numbering will be reset.
#statementsp(
  box-name: "prop",
  box-label: "proplabel",
  box-title: "Title of Proposition",
  number: true,
)[
  Some sentences.
]

And if you need, you can omit the title. If you set so, ":" will not be added automatically.
#statementsp(
  box-name: "lem",
  box-label: "lemlabel",
  box-title: "",
  number: true,
)[
  Some sentences.
]

you can even omit the numbering. If you set number to false, the label will not be shown, and the counter will not be incremented.
#statementsp(
  box-name: "cor",
  box-label: "",
  box-title: "Title of Corollary",
  number: false,
)[
  Some sentences.
]

However, you can not set box-label without number. If you set box-label, you should set number to true. Otherwise, an error will be raised like\
`Error: This is statementsp. If you want to use label, you should set number to true.`

#pagebreak()

If you want to reffer to the statement, you can use `#linksp` function.

You can reffer #linksp(<def:deflabel>). If you change the displaystyle of the link, you should write proper codes like\
`#show link: set text(fill: blue)`