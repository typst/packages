#import "../../../src/core/document.typ"
#import "../../../src/core/layout.typ"
#import "../../../src/core/themes.typ"
#import "../../../src/api/commands.typ": *
#import "../../../src/api/examples.typ": example

#show: layout.page-init(
  document.create(
    title: "typst-test",
    ..toml("../../../typst.toml"),
  ),
  themes.default,
)
#set page(width: 18cm, height: auto, margin: 1em)


#let headline(color, size: 1.8em, body, ..other-args) = block(
  fill: color,
  width: 100%,
  inset: .5em,
  radius: 4pt,
  heading(..other-args, text(size, white, body)),
)


#command("headline", arg("color"), arg(size: 1.8em), barg("body"), sarg("other-args"))[
  Renders a prominent headline using #builtin[heading].

  #argument("color", types: color)[
    The color of the headline will be used as the background of a block element containing the headline.
  ]
  #argument("size", default: 1.8em)[
    The text size for the headline.
  ]
  #argument("other-args", is-sink: true, types: "any")[
    Other options will get passed directly to #builtin[heading].
  ]
  #argument("body", types: (content, str))[
    The text for the headline.
  ]

  The headline is shown as a prominent colored block to highlight important news articles in the newsletter:
  #example(use-examples-scope: false, scope: (headline: headline))[```
    #headline(blue, size:16pt, level:3, numbering: none)[
      #lorem(4)
    ]
    ```]
]
