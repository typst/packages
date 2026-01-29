#import "@preview/vanilla:0.2.0": body, vanilla

// Apply the vanilla style to the document
#show: vanilla.with(
  styles: (
    body: (spacing: "double", first-line-indent: 0.5in),
  ),
)

= Heading 1
== Heading 2
=== Heading 3

#body(spacing: "double")[
  This paragraph will be double-spaced with indent.
  #lorem(50)
]

#body(spacing: "single")[
  This paragraph will be single-spaced.
  #lorem(20)
]
