#import "@preview/machiatto:0.2.0": *
#let license = [
  #heading("License", outlined: false)
  - The goal of this page is to discuss your licensing or copyright terms, as we usually reccamond publications to be under a creative commons license. Examples are CC BY-NC-SA 4.0 or CC BY-NC-ND 4.0.
  - If you use any AI to help with your work, please add an AI disclosure

  #align(left + bottom)[
    #table(
      stroke: none,
      columns: 2,
      [*Author:*],
      [Mustafif Khan],
      [*Editor:*],
      [Mustafif Khan],
      [*Publish Date:*],
      [#datetime.today().display()],
      [*Published by:*],
      [Mustafif Khan | MoKa Reads],
      [*ISBN:*],
      [A number],
    )
  ]
]

#let preface = [
  #heading("Preface", outlined: false)
  *Chapter 1 Machiatto Template*: #lorem(40)
]

#show: doc.with(
  author: "Mustafif",
  title: "Machiatto Template",
  paper-size: "a4",
  ack: [
    This will contain all of those who you would like to thank
  ],
  license: license,
  preface: preface,
  toc: true,
  bibliography: none,
)

= Machiatto Template

*This is a summary of what will be covered in the summary*:
#lorem(100)
#minitoc()

== A section

#lorem(100)

#def(title: lorem(5), lorem(50))

#lorem(50)

#note(lorem(50))

== Another section

#lorem(40)

#let hello-c = read("hello.c")

#code-file(
  title: "hello.c",
  file-content: hello-c,
  lang: "C",
  fill: color.aqua,
)

#lorem(20)

#terminal(
  title: "Terminal",
  ```bash
  $ clang hello.c
  $ ./a.out
  Hello, World!
  ```
)

#info-box([
  This is an informational note that highlights helpful content.
])
This is useful for code snippets, allowing you to choose the line range to show from your source file.
#code-snippet(
  title: "hello.c",
  file-content: hello-c,
  subtitle: "snippet",
  lang: "C",
  fill: color.aqua,
  to: 3,
)
