#import "@preview/tidy:0.4.2"
#import "@preview/wenyuan-campaign:0.1.2" as wenyuan

// #set page(columns: 2)

#show: wenyuan.conf.with()

#set text(size: 9pt)

= Wenyuan-Campaign Generated Documentation


== Main module

#wenyuan.fancy-comment-box()[
  These are the functions for the main campaign module, which is recommended to be imported into the global scope (i.e. with `*`). For initialisation options, see the `conf` function details.

  This documentation was generated using tidy.
]

#let docs = tidy.parse-module(read("campaign.typ"))
#tidy.show-module(docs, style: tidy.styles.default)

#colbreak()
== Statblock Module


#wenyuan.fancy-comment-box[
  All functions required for statblocks.

  #wenyuan.namedpar[Important][
    By default these are imported under the subpackage `stat`. If you import all functions from wenyuan, then you can just call `stat.function` immediately to access.
  ]

  *Section headers* such as _Actions_ or _Reactions_ are done using the second-level header `==`

  *Action names* -- the names that go in front of actions / abilities are done using the third level header `===` (do not leave a blank line between the header and its body text) 

]


#let stats = tidy.parse-module(read("statblock.typ"))
#tidy.show-module(stats, style: tidy.styles.default)

#colbreak()
== Items Module


#wenyuan.fancy-comment-box[
  All functions required for basic items.

  #wenyuan.namedpar[Important][
    By default these are imported under the subpackage `item`. If you import all functions from wenyuan, then you can just call `item.function` immediately to access.
  ]

  *Item Name* is done with the top-level header `=`

  *Section headers* are the second level header `==`

  *Abilities and named paragraphs* are the third level header `===`
]

#let stats = tidy.parse-module(read("dnditem.typ"))
#tidy.show-module(stats, style: tidy.styles.default)


#colbreak()
== Colours Module

#wenyuan.fancy-comment-box[
  A preset list of default colours you can use.

  #wenyuan.namedpar[Important][
    By default these are imported under the subpackage `colour`.
  ]
]

It's all variables so I'll just copy it here:

```typst
// based on https://github.com/rpgtex/DND-5e-LaTeX-Template/blob/dev/lib/dndcolors.sty

// page 
#let bgtan = rgb("#F7F2E5")  // readAloud
#let pagegold = rgb("B89A67")  // numbering
#let clear = rgb("ffffff00")

// type
#let dndred = rgb("#58180d")
#let rulegold = rgb("#C9AD6A")  // subsection rule
#let shadow = rgb("#AAAAAA")

// trim
#let brgreen       = rgb("#E8E6DC")  // Basic Rules
#let phbgreen      = rgb("#E0E5C1")  // PHB Part 1
#let phbcyan       = rgb("#B5CEB8")  // PHB Part 2
#let phbmauve      = rgb("#DCCCC5")  // PHB Part 3
#let phbtan        = rgb("#E5D5AC")  // PHB appendix
#let dmglavender   = rgb("#E3CED3")  // DMG Part 1
#let dmgcoral      = rgb("#F3D7C1")  // DMG Part 2
#let dmgslategrey  = rgb("#DBE4E4")  // DMG Part 3
#let dmglilac      = rgb("#D7D4D6")  // DMG appendix

#let dmgslategray = dmgslategrey
```
