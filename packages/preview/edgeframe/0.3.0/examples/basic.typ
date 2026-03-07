/*
  File: example.typ
  Author: neuralpain
  Date Modified: 2025-12-10

  Description: A general example document to showcase edgeframe functionality.
*/

#import "@preview/edgeframe:0.3.0": *

#let list-spacing = 1em

#show: ef-document.with(
  ..ef-defaults,
  draft: true,
  paper: "us-letter",
  margin: margin.normal,
  header: (
    content: ([Lorem], [Ipsum], [Dolor]),
    // first-page: "This is first page.",
    last-page: ([This is], [], [Last page]),
    // odd-page: "This is odd page.",
    even-page: "This is even page.",
  ),
  footer: (
    content: ([Consecteur], [Adipiscing], [Elit]),
    first-page: "This is first page.",
    last-page: ([This is], [], [Last page]),
    odd-page: "This is odd page.",
    // even-page: "This is even page.",
  ),
  page-count: true,
  page-count-first-page: false,
  bullet-list: (
    indent: list-spacing,
  ),
  number-list: (
    indent: list-spacing,
  ),
)

#let ipsum = [
  #lorem(50)

  #lorem(20)

  #lorem(100)

  + #lorem(15)
    - #lorem(5)
    - #lorem(8)
    - #lorem(6)

  + #lorem(25)
    - #lorem(5)
    - #lorem(8)
    - #lorem(6)

  + #lorem(10)
    - #lorem(5)
    - #lorem(8)
    - #lorem(6)

  + #lorem(15)
    - #lorem(5)
    - #lorem(8)
    - #lorem(6)

  + #lorem(50)
    - #lorem(5)
    - #lorem(8)
    - #lorem(6)

  #lorem(50)

  #lorem(30)

  #lorem(15)
]

#title[A basic document example using Edgeframe.]

= #lorem(2)

#ipsum

= #lorem(6)

#ipsum

#ipsum

= #lorem(4)

#ipsum
