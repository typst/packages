#import "@preview/touying-flow:1.2.0":*
// #import "../../theme.typ":*
#show: flow-theme.with(
  aspect-ratio: "16-9",
  footer: self => self.info.title,
  footer-alt: self => self.info.subtitle,
  navigation: "mini-slides",
  primary:rgb("#543795"),//rgb(0,108,57),//rgb("#006c39"),
  secondary:rgb("#a38acb"),//rgb(161,63,61),//rgb("#a13f3d"),
  // text-font: ("Libertinus Serif"),
  // text-size: 20pt,
  // code-font: ("Jetbrains Mono NL","PingFang SC"),
  // code-size: 16pt,

  config-info(
    title: [Title],
    subtitle: [Subtitle],
    author: [Quaternijkon],
    date: datetime.today(),
    institution: [USTC],
  ),
  // config-common(show-notes-on-second-screen: right),
)

#title-slide()

// #outline()

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
Don't want the entire page to follow a column layout? Try `#side-by-side` !
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

= #smallcaps("Tools")

== Pympress

#speaker-note[
  + This is a speaker note.
  + You won't see it unless you use `config-common(show-notes-on-second-screen: right)`
]
