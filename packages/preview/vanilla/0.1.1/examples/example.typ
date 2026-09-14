#import "@preview/vanilla:0.1.1": vanilla, par-single-spaced, par-double-spaced

// Apply the vanilla style to the document
#show: vanilla.with(
  body-line-spacing: "double",
  body-first-line-indent: 0.5in,
  justified: true,
)

= Heading 1
== Heading 2
=== Heading 3

#par-double-spaced[
  This paragraph will be double-spaced with indent.
  #lorem(50)
]

#par-single-spaced[
  This paragraph will be single-spaced.
  #lorem(20)
]

