#import "./preamble.typ": *

// main class
#show: bmim.article(
  title: [Control of controllable Continua],
  subtitle: [A very demanding task],
  authors: ("John William Frederick Antony McGainson", "Jane Susan Margaret Feed-Back"),
  lang: "en",

)

// various environments
#import "@preview/theorion:0.6.0": *
#import cosmos.clouds: *
#show: show-theorion


#abstract[
  #lorem(60)
]

= Headings


== Subsection with number

#lorem(50)

=== Paragraph
This one will be shown as inline heading.
#lorem(75)

=== Paragraph
#lorem(90)

== Subsection without number <bmim:nonumber>

#lorem(80)



= Typographic Structures

== Citations

This sentence is important @netwok2020.
#lorem(80)

== Formulas

Some inline math like $2x + 3r = 10$ should suffice
but sometimes you need a block display:
$
x + y = z.
$
#lorem(40)

== Listings

We have different listings. Bullet lists:
- element
- another
Enumerations:
+ Solve the equation for $x$
+ Solve the equation for $y$

== Figures & Tables

At first, have a look at the very nice image in @fig:test. 
#lorem(40)

#figure(
  image("../assets/background_bettelwurf.jpg", width: 100%),
  caption: [This is a very long figure caption. It will appear below the image.
  ],
) <fig:test>


After that you should find the correct number in @tab:try.
#lorem(20)

#figure(
  table(
    columns: 4,
    ..(context{counter("a").step(); str(counter("a").get().first())},)*8,
  ),
  caption: [This is a very long table caption. It will appear above the table.],
) <tab:try>

== Admonitions

#warning-block[#lorem(20)]

#caution-block[#lorem(20)]

#tip-block[#lorem(20)]

#note-block[#lorem(40)]

Find even more environments in the `theorion` package: https://typst.app/universe/package/theorion/.

= A section without number <bmim:nonumber>

#lorem(20)

#bibliography("sources.bib", title: "Bibliography")


