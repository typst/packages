#import "@preview/ornamentalyst:0.1.0": ornament, fit-to-dim

#set grid.cell(breakable: false)


#let symbol_range(low,high,collection) = {
  range(low,high+1).map(
    (i) => [
      #align(center)[#i]
      #box(height:4cm)[
      #fit-to-dim(
        ornament(i, collection: collection)
      )
    ]
  ]
  )
}

#let symbol_grid(..rges) = [
  #let symbol_arr = array.flatten(
    rges.pos().map((r) => symbol_range(r.at(0),r.at(1),r.at(2)))
  )
  #align(center+horizon)[
    #grid(
      columns:(1fr,1fr,1fr),
      column-gutter: 1cm,
      row-gutter: 0.5cm,
      ..symbol_arr
    )
  ]
]


#show title: (it) => {
  set text(size: 30pt)
  align(center+horizon)[
    #it
  ]
  place(top+left,ornament(63))
  place(top+right,ornament(64))
  place(bottom+left,ornament(63,symmetry: "h"))
  place(bottom+right,ornament(64,symmetry: "h"))
  pagebreak()
}
#show heading.where(level: 1): set text(24pt) 
#set text(12pt)

#title("ornamentalyst")

= Introduction

The `ornamentalyst` package is a reimplementation of the LaTeX package #link("https://ctan.org/pkg/pgfornament")[`pgfornament`] by Alain Matthes, which allows to render vector images of various ornaments.

Its main entry point is the `ornament` function, which renders a specific ornament based on its number. The package currently features 3 collections:
- `vectorian`, containing a collection of Victorian symbols, originally designed by Vincent Le Moign at #link("http://www.vectorian.net")[vectorian.net].
- `pgfhan`, containing a collection of Chinese traditional motifs compiled by LianTze Lim based on designs by Chenna Zhang.
- `am`, containing two example symbols
An ornament can be rendered with ```typst #ornament(<number id>,collection: <collection name>)```, e.g. ```typst #ornament(1,collection: "vectorian")``` gives:\ #ornament(1,collection: "vectorian")\
It wraps the more general function `symbol-from-pgf-string`, which renders an arbitrary symbol defined in the .pgf file format (the string would typically be read from a file directly using `read`).

The collection is `"vectorian"` by default, and could thus have been omitted in the example above. The rendered object is placed inline; one will often want to use `place` to render it in the desired position:
```typst
#rect(width:6cm,height:6cm)[
  #place(top+left,ornament(31))
  #place(top+right,ornament(32))
  #place(bottom+left,ornament(31,symmetry: "h"))
  #place(bottom+right,ornament(32,symmetry: "h"))
]
```
#rect(width:6cm,height:6cm)[
  #place(top+left,ornament(31))
  #place(top+right,ornament(32))
  #place(bottom+left,ornament(31,symmetry: "h"))
  #place(bottom+right,ornament(32,symmetry: "h"))
]

Options include:
- `fill`: defines a fill color for the ornament (ex: ```typst #ornament(1, fill: red)```)
- `symmetry`: applies a symmetry to the ornament. Can be `h` (horizontal), `v` (vertical) or `c` (center)

== Usage

#[
  #set list(marker: [#ornament(152, height: 8pt)])
  - Ornaments are placed inline by default.
  - In order to handle their size, you may use the `height` and `width` parameters. If only one is provided, the ornament will be resized to the desired width/height while keeping the same aspect ratio. If both are provided, the symbol will be rescaled accordingly ignoring the original aspect ratio.
  - The `place` function from the standard library can be very useful for putting the ornaments in the desired position. You may also want to consider using the set function ```typst #set page(background: ...)``` when making a page template.
   
]

= List of `vectorian` symbols

== Decorative symbols

#symbol_grid(
  (1,30,"vectorian"),
  (65,79,"vectorian"),
  (97,98,"vectorian"),
  (140,141,"vectorian"),
)

== Corners

#symbol_grid(
  (31,42,"vectorian"),
  (61,64,"vectorian"),
  (131,132,"vectorian"),
  (194,195,"vectorian"),
)

== Lines

#symbol_grid(
  (80,80,"vectorian"),
  (89,89,"vectorian"),
)

== Animals

#symbol_grid(
  (90,91,"vectorian"),
  (100,100,"vectorian"),
  (102,102,"vectorian"),
  (104,104,"vectorian"),
  (106,113,"vectorian"),
  (122,124,"vectorian"),
  (133,137,"vectorian"),
  (156,159,"vectorian"),
  (190,190,"vectorian"),
)

== Hands

#symbol_grid(
  (152,155,"vectorian")
)

== Humans

#symbol_grid(
  (103,103,"vectorian"),
  (105,105,"vectorian"),
  (125,125,"vectorian"),
  (143,144,"vectorian"),
  (160,160,"vectorian"),
  (164,164,"vectorian"),
)

== Objects

#symbol_grid(
  (92,95,"vectorian"),
  (114,114,"vectorian"),
  (126,126,"vectorian"),
  (147,148,"vectorian"),
  (151,151,"vectorian"),
  (162,162,"vectorian"),
  (173,173,"vectorian"),
  (184,184,"vectorian"),
  (191,192,"vectorian"),
)

= List of `pgfhan` symbols

== Simple corners

#symbol_grid((1,8,"pgfhan"))

== Double corners

#symbol_grid((9,18,"pgfhan"))

== Miscellaneous corners

#symbol_grid((19,28,"pgfhan"))

== Lines

#symbol_grid((29,32,"pgfhan"))

== Other symbols

#symbol_grid((33,78,"pgfhan"))
