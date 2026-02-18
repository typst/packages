#import "@preview/in-dexter:0.7.2": *
= About Typst

Typst is a newer typesetting alternative to LaTeX that is written using the
programming language Rust and uses its own markup language resembling a mixture 
of (to some extend) both AsciiDoc and Markdown. To learn using Typst and its 
markup language start with the #link("https://typst.app/docs/tutorial/")[online tutorial]. 

== Using Typst

You can either use the #link("https://typst.app/")[typst app] or the #link("https://typst.app/open-source/")[open source offline compiler]. The following commands are useful with the offline compiler.

```
> typst --version                          # output the version
> typst init @preview/uastw-thesis:0.1.1   # init a new project
> typst compile thesis.typ                 # compile the root file
> typst watch thesis.typ                   # compile & update code changes
> typst --help                             # output a help message
```

== Writing in Typst

A simple yet fast way to get accustomed with the syntax of the Typst markup language 
print and checkout the #link("https://github.com/mewmew/typst-cheat-sheet")[Typst Cheat Sheet] that summarizes the essentials on a single page.

=== Lists

#columns(2, gutter: 24pt)[

To create an _unordered list_ #index[unordered list] type ...

```
- unnumbered item
  - subitem 1
  - subitem 2
    - subsubitem
- second unnumbered item  
```
#v(1em)
 #colbreak()

... this yields:

- unnumbered item
  - subitem 1
  - subitem 2
    - subsubitem
- second unnumbered item

]

Advanced for one specific list ...

#grid(columns: (3fr, 1fr), gutter: 24pt,
[
```
#block([#set list(marker: ([#text(emoji.finger.r)], 
                   [#text(green, sym.arrow.r.dashed)], 
                   [#text(rgb("#00689e"), sym.floral)]))     
- one
  - two
    - three
])
```
],
[
#v(3em)

#block([
#set list(marker: ([#text(emoji.finger.r)],  
        [#text(green, sym.arrow.r.dashed)], 
        [#text(rgb("#00689e"), sym.floral)]))
- one
  - two
    - three
    ])
])

#columns(2, gutter: 24pt)[

To create an _ordered list_ #index[ordered list] type ...

```
+ unnumbered item
  + subitem 1
  + subitem 2
    + subsubitem
+ second unnumbered item  
```
#v(2em)
 #colbreak()

... this yields:

+ unnumbered item
  + subitem 1
  + subitem 2
    + subsubitem
+ second unnumbered item

]

=== Headings

#index[header]

#columns(2, gutter: 24pt)[
```


= Top Level Header



== Sub-Header


=== Subsub-Header

```
#colbreak()
    #[
        #counter(heading).update(0)
        = Top Header

        == Sub-Header

        === Subsub-Header
    ]
]

Advanced header styling: The following statement produces a heading without
entry in the table-of-contents, without numbering but with an entry in the PDF
bookmarks. 

```
#heading(outlined: false, bookmarked: true, numbering: none)[Kurzfassung]
```

The next line shows how to reset the header numbering.
```
#counter(heading).update(0)
= Header
```

=== Text

The following example show-case different text styles ... 

#columns(2, gutter: 24pt)[
```
`mono`
*bold*
_italic_
#highlight[highlight]
#underline[underline]
#text(size: 1.5em)[Text Size]

#strike[Strikethrough text]
```

#colbreak()

`mono` \
*bold* \
_italic_ \
#highlight[highlight] \
#underline[underline] \
#text(size: 1.5em)[Text Size] \
#strike[Strikethrough text]

]

Advanced text styling options ... the following code produces #text(rgb("01AB20"), font: "Alex Brush", 18pt)[demo]. 

```
#text(rgb("01AB20"), font: "Alex Brush", 18pt)[demo]
```

=== Figures

@fig-uastw show-cases how to include a figure #index[figure], add a caption, and an anchor `<fig-uastw>` ...
#v(1em)

#columns(2, gutter: 24pt)[
```
#figure(
    image("images/logo.svg", width: 30%),
    caption: [UAS Technikum Wien Logo],
) <fig-uastw>
```
#colbreak()
#figure(
    image("images/logo.svg", width: 30%),
    caption: [UAS Technikum Wien Logo],
) <fig-uastw>
]
#v(1em)

To reference the anchor use `@fig-uastw ` (the name of the anchor prefixed with an `@`).

Typst supports various libraries where you can directly _program_ vector graphics, e.g., the following "code" generates the figure to the right ... 

#grid(columns: (2fr, 1fr), gutter: 24pt,
[
```
#stack(dir: ltr, spacing: 1em,
  rect(width: 20pt, height: 20pt, fill: blue),
  circle(radius: 10pt, stroke: 2pt + red),
  line(start: (0pt, 0pt), end: (20pt, 20pt), 
       stroke: green)
)
```
],
[
    #stack(dir: ltr, spacing: 1em,
      rect(width: 20pt, height: 20pt, fill: blue),
      circle(radius: 10pt, stroke: 2pt + red),
      line(start: (0pt, 0pt), end: (20pt, 20pt), 
           stroke: green)
    )
])
#v(1em)

Specialized libraries are, e.g., #link("https://typst.app/universe/package/fletcher/")[Fletcher] for flowcharts, #link("https://typst.app/universe/package/tdtr/")[tdtr] for drawing tree diagrams, #link("https://typst.app/universe/package/cetz")[cetz] for general purpose drawings (comparable to the LaTeX package TikZ), #link("https://typst.app/universe/package/lilaq")[lilaq] for scientific data visualization etc. .... checkout the #link("https://typst.app/universe/search/?kind=packages")[package universe] on the Typst homepage.

For example @fig-blockdiag is rendered with the help of the fletcher library.

```
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#diagram(
    cell-size: 2cm, node-stroke: 1pt,
    node((0,0), [Input], fill: blue.lighten(80%)),
    edge((0,0), (1,0), "->"),
    node((1,0), [Process], fill: green.lighten(80%)),
    edge((1,0), (2,0), "->"),
    node((2,0), [Output], fill: red.lighten(80%)),
    edge((2,0), (2,1), "-|>-", `waste`),
    edge((1,0), (2,1), `dump`, "-|>-"),
    node((2,1), [Wastebin], fill: rgb("#8bb111")),
    edge((2,1), (0,0), "--|>--", `reset`)
)
```
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#v(2em)
#figure(
    diagram(
      cell-size: 2cm,
      node-stroke: 1pt,
      node((0,0), [Input], fill: blue.lighten(80%)),
      edge((0,0), (1,0), "->"),
      node((1,0), [Process], fill: green.lighten(80%)),
      edge((1,0), (2,0), "->"),
      node((2,0), [Output], fill: red.lighten(80%)),
      edge((2,0), (2,1), "-|>-", `waste`),
      edge((1,0), (2,1), `dump`, "-|>-"),
      node((2,1), [Wastebin], fill: rgb("#8bb111")),
      edge((2,1), (0,0), "--|>--", `reset`)
    ),
    caption: [Example block diagram],
) <fig-blockdiag>

=== Tables

@tab-demo show-cases how to include a table #index[table] ... 

#columns(2, gutter: 24pt)[
```
#figure(
  table(
    columns: 2,
    table.header[*name*][*desc*],
    [a], [b],
    [c], [d],
  ),
  caption: [Demo Table],
)<tab-demo>
```
#colbreak()
#v(2em)
#figure(
  table(
    columns: 2,
    table.header[*name*][*desc*],
    [a], [b],
    [c], [d],
  ),
  caption: [Demo Table],
)<tab-demo>
]

Checkout the #link("https://typst.app/docs/guides/tables/")[Table Guide] in the documentation for all sorts of table variants.

=== Quotes, References and other Clues

The quote #index[quote] from @Schiller1801 states:

#quote(attribution: [F. Schiller], block: true)["Against stupidity the very gods themselves contend in vain."]

Another famous quote from @goethe1999faust1 is:

#quote(attribution: [J.W. Goethe], block: true)["Die Botschaft hör ich wohl, allein mir fehlt der Glaube."]

#import "@preview/gentle-clues:1.3.0": *

#info[References simply use the anchor, e.g. `@goethe1999faust1` as used as key in the BibTeX file ...]

To set clue boxes like INFO, WARNING, TIP, etc. you may use the #link("https://typst.app/universe/package/gentle-clues")[gentle clues] package. The above info box was rendered using:

```
#import "@preview/gentle-clues:1.3.0": *

#info[References simply use the anchor, e.g. `@goethe1999faust1` as used as key in the BibTeX file ...]
```

=== Math

Mathematical #index[math] equations are enclosed with `$` symbols as in LaTeX. Here is a simple example:

$ sum_(k=0)^n k
    &= 1 + ... + n \
    &= (n(n+1)) / 2 $

Below is how you type the formula:

```
$ sum_(k=0)^n k
    &= 1 + ... + n \
    &= (n(n+1)) / 2 $
```

=== Code

To render code listings the Typst universe features various packages - a prominent one is #link("https://typst.app/universe/package/codly")[codly]. The following example show-cases its use by referencing an external source-file `code/demo.c`.


```
#import "@preview/codly:1.2.0": *
#show: codly-init.with()

// Load and display an external C file
#raw(read("code/demo.c"), lang: "c", block: true)
```

The rendered output looks like ...

#{
import "@preview/codly:1.2.0": *
show: codly-init.with()

// Load and display an external C file
raw(read("code/demo.c"), lang: "c", block: true)
}


