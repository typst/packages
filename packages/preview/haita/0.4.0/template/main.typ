#!/usr/bin/env -S typst compile --features bundle,html --format bundle
// The line above compiles the documentation to an HTML bundle.
// Additionally, you can watch the file using this command:
//
// $ typst watch --features bundle,html --format bundle main.typ
//
// You can also build and watch the PDF using the follow commands:
//
// $ typst compile --features bundle,html --format pdf main.typ
// $ typst watch --features bundle,html --format pdf main.typ
//
#import "@preview/haita:0.4.0": * // Always import the package!
#book(
  // Where the site will be deployed. Optional: it is only used for the
  // SEO metadata, everything inside the site is linked relatively.
  // base-url: "https://username.github.io/haita",

  // This sets your html renderer. You can customize the HTML renderer
  // using `html-renderer.with(...)`, or write your own!
  html-renderer: new-hamber.html-renderer,
  // Your document's contents
  tree: (
    // You can add arbitrary content. The content will be displayed
    // in the summary, but will not generate html pages.
    [= Welcome!],
    // This will create index.html. The content of the
    // chapter will be from `index.typ`
    chapter("index", content: include "index.typ"),
    // This will create doc/tutorial.html. In this case,
    // the content of the chapter is not explicitly stated, so it
    // looks into ./doc/tutorial.typ in the current workspace.
    chapter(
      "doc/tutorial",
      content: include "tutorial.typ",
      // you can generate chapters procedurally
      children: range(1, 6).map(num => chapter("doc/" + str(num), content: [
        #title[Chapter #num]
        This page is generated procedurally!
      ])),
    ),
    // You can add dividers, which will separate content in the summary.
    divider(),
    // Alternatively, if you would like to directly include the content
    // without creating a new file, you can write it like this:
    chapter("my-page", content: [
      #title[My Page]
      = Heading 1
      = Heading 2
      foo bar baz
    ]),
    // you can also add arbitrary content
    [Made with Haita.],
    // you can add more chapters afterwards.
  ),
)
