#import "/lib.typ": *

#import "@preview/codly:1.2.0": *
#import "@preview/codly-languages:0.1.1": *
#show: codly-init.with()
#codly(languages: codly-languages)

#show: easy-typography.with(
  fonts: (heading: "Source Sans 3", body: "Source Serif 4"),
)

= Introducing Easy Typography

#set heading(numbering: (..nums) => {
  numbering("1.1.", ..nums.pos().slice(1))
})

The `easy-typography` package transforms complex typographic decisions into
simple choices, letting you focus on your content while ensuring professional
results. By adjusting the settings to match your specific needs, you can refine
the aesthetic or adapt your layout for everything from casual reading to formal
publication.

== Core Typography Features

The package manages:

#columns(2)[
- Precise heading scale with a clear hierarchy
- Optimal line height and paragraph spacing
#colbreak()
- Professional text justification and hyphenation
- Balanced vertical rhythm throughout
]

These features ensure that your document is both visually appealing and easy to
read.

=== Type Formatting

This package automatically adjusts line spacing, paragraph spacing, and
justification to maintain a clean layout. Headings are also carefully weighted
to balance them against the body text, so you can focus on content rather than
tweaking spacing and sizing. Standard formatting like *bold* and _italic_
integrates seamlessly with `easy-typography`'s approach.

=== Heading Levels

The heading scale gracefully steps down, ensuring that each level remains
distinct yet consistent. Behind the scenes, `easy-typography` calculates the
ideal size for each heading, preserving a cohesive visual hierarchy as your
document gets deeper. This approach supports manuals, academic papers, and any
long-form text where structure matters. It also helps in shorter documents,
guaranteeing a crisp layout with minimal effort.

== Why Typography Matters

Good typography isn't just about aesthetics. It's about effective communication.
Well-designed text:

#columns(2)[
- Improves reading comprehension
- Reduces eye strain
- Maintains reader engagement
#colbreak()
- Establishes visual hierarchy
- Conveys professionalism
]

Notice how this document's typography enhances readability. The justified text,
proper hyphenation, and optimized line breaks create a clean, professional
appearance. With each heading level, the user can quickly scan and digest
important information.

== Example Usage and Output

#set heading(numbering: none)
#show raw.where(block: true): set text(size: 7pt)

#grid(
  columns: (55%, auto),
  gutter: 1.0em,
[
  // code
  ```typst
  #import "@preview/easy-typography:0.1.0": *
  #show: easy-typography.with(
    fonts: (
      heading: "Source Sans Pro",
      body: "Source Serif Pro"
    ),
  )

  #lorem(6)
  = Level One
  #lorem(6)
  == Level Two
  #lorem(6)
  === Level Three
  #lorem(6)
  ==== Level Four
  #lorem(6)
  ===== Level Five
  #lorem(6)
  ```
],
box(
    stroke: 0.5pt + silver,
    inset: 0.5em,
    radius: 0.2em,
    [
      #lorem(6)
      = Level One
      #lorem(6)
      == Level Two
      #lorem(6)
      === Level Three
      #lorem(6)
      ==== Level Four
      #lorem(6)
      ===== Level Five
      #lorem(6)
    ]
  ) // box
)
