// #import "../../theme.typ":*
#import "@preview/touying-flow:1.0.0":*
#show: flow-theme.with(
  aspect-ratio: "16-9",
  footer: self => self.info.title,
  footer-alt: self => self.info.subtitle,
  navigation: "mini-slides",
  config-info(
    title: [Title],
    subtitle: [Subtitle],
    author: [Quaternijkon],
    date: datetime.today(),
    institution: [USTC],
  ),
)

#let primary= rgb("#004098")

#show :show-cn-fakebold // Used to display bold Chinese text

// Set the style for the title
// #set heading(numbering: numbly("{1}.", default: "1.1"))
#show outline.entry.where(
  level: 1
): it => {
  v(1em, weak: true)
  text(primary, it.body)
}


/*
highlighter. Usage:
_Your text_
or
#emph[Your text]
*/
#show emph: it => {  
  underline(stroke: (thickness: 1em, paint: primary.transparentize(95%), cap: "round"),offset: -7pt,background: true,evade: false,extent: -8pt,text(primary, it.body))
}

#title-slide()

= #smallcaps("Slide")

== New slide

```typ
== New slide
```


#pagebreak()

=== page break
```typ
#pagebreak()
```
```typ
#slide[

]
```

== Slide with columns

#slide[
```typ
#slide[

][

]
```
][
```typ
#slide[

][

][

][

][

]
```
]

== Columns with different weights
#slide(composer: (1fr,3fr,1fr))[
first column
][
```typ
#slide(composer: (1fr,3fr,1fr))[

][

][

][

]
```
][
third column
]

= #smallcaps("Layout")

== Align

#align(horizon)[
  ```typ
  #align(horizon)[

  ]
  ```
]

#align(bottom+end)[#link("https://typst.app/docs/reference/layout/align/")

#link("https://typst.app/docs/reference/layout/alignment/")]


== Side by side
Don't want the entire page to follow a column layout? Trt `#side-by-side` !
#side-by-side[
```typ
#side-by-side[

][

]
```
][
```typ
#side-by-side[

][

][

]
```
]
Consider using `#side-by-side` for a more flexible layout.

== Grid

#grid(
  columns: 3, //try columns: (1fr,2fr,60pt)
  rows: 2,    //try rows: (1fr,2fr)
  align: center+horizon,
  gutter: 1em,
  rect[#lorem(20)],
  grid.cell(
    colspan: 2,
    [
```typ
#grid(
  columns: 3, rows: 2, 
  align: center+horizon, gutter: 1em,
  [],[],grid.cell(colspan: 2,),[],[],
  ),      
```
    ],
  ),
  [#lorem(20)],
  rect[#lorem(20)],
  [#lorem(20)]
  )

#align(bottom+end)[#link("https://typst.app/docs/reference/layout/grid/")]

= #smallcaps("Content")

== Text

#side-by-side[
=== Size
```typst
#set text(size: 1.5em)
```
][
=== Font
```typ
#set text(font: "Times New Roman")
```
]

#side-by-side[
*Strong*
```typ
*Strong*
```
```typ
#strong[Strong]
```
][
_emphasis_
```typ
_emphasis_
```
```typ
#emph[emphasis]
```
]

== Image

== Table



== Code

#side-by-side[
//伪代码
][

]

== Math

=== 



=== 

#pagebreak()

=== mi(``)

=== mitex(``)

=== mitext(``)

= #smallcaps("Components")

== 
