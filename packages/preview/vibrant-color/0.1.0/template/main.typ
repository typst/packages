#import "@preview/vibrant-color:0.1.0": *

// IMPORTANT : IF YOU WANT TO USE THE ORIGINAL FONTS 
// - Download the font from https://github.com/SHAfoin/shafoin-typst-template/tree/main/font
// - On your PC : install them
// - On typst.app : just  upload them in the "Explore files" section, it will be automatically installed

#show: doc => vibrant-color(
  theme: "green-theme",
  title: "My Report",
  authors: (
    "DOE John",
    "SMITH Alice",
  ),
  lang: "fr",
  sub-authors: "TEAM 1",
  description: "This is an example of how to use this template.",
  date: datetime(day: 10, month: 3, year: 2025),
  subject: "Mathematics",
  // bib-yaml: "./refs.yaml",
  // logo: "./my_logo.png",
  doc
)

= Title 1

== Title 2

=== Title 3

==== Title 4

You can #strike[strike text], put it in *bold*, int italic, or *_both_*. 
Subtext #sub[too], super #super[text] also, #underline[underline] some, #overline[overline] others and #highlight[highlight] in the color of the theme. Equations are supported too, like $a^2 + b^2 = c^2$. 

Summary is made automatically, bibliography too as long as you specify a bib-yaml file. 
Customs blocks and a customized code block are available with the functions below.

#warning("Warning block, to warn about something important.")

#info("Info block, to inform about something.")

#comment("Comment block, to add a comment.")

Quote, image, table, footnote, custom caption, reference and many more are available and customized to this template : please refer to the official documentation or #link("https://github.com/SHAfoin/shafoin-typst-template/blob/main/example/example.typ")[
  this example
] of everything in this template for more information. 
