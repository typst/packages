#import "@preview/typographix-polytechnique-reports:0.1.3" as template

#show:  template.apply

// Specific rules for the guide
#show link: set text(blue)

#let source = s => {
  block(width: 100%)[#{
    set align(left)
    text(font: "New Computer Modern Sans", weight: "bold")[Source code :]
    v(-0.5em)
    pad(left: 5%)[#block(fill: rgb("f5f5f5"), width: 100%, inset: 10pt)[#raw(s, lang: "typ")]]
    set align(center)
    v(0.2em)
    line(length: 50%, stroke: 0.8pt + rgb("d0d0d0"))
    v(0.5em)
  }]
}

#let typst-rendering(d) = {
  block[#text(font: "New Computer Modern Sans", weight: "bold")[Typst rendering :]]
  pad(left: 5%)[#block(fill: rgb("f5f5f5"), inset: 10pt, width: 100%)[#eval(d, mode: "markup")]]
  source(d)
}

// Defining variables for the cover page and PDF metadata
#let title = [guide for typst #linebreak() polytechnique package]
#let subtitle = "A modern alternative to LaTeX"
#let logo = image("assets/logo-x.svg")
#let short_title = "package guide"
#let authors = ("Rémi Germe")
#let date_start = datetime(year: 2024, month: 07, day: 05)
#let date_end = datetime(year: 2024, month: 08, day: 05)

#set text(lang: "en")

// Beginning of the content
#template.cover.cover(title, authors, date_start, date_end, subtitle: subtitle, logo: logo)
#pagebreak()

#outline(title: [Guide content], indent: 1em, depth: 2)
#pagebreak()

= Discovering Typst and the template

#typst-rendering(
  "Typst is a user-friendlier alternative to LaTeX. Check out #link(\"https://github.com/remigerme/typst-polytechnique/blob/main/guide.typ\")[this pdf source] to see how it was generated."
)

== Headings

#typst-rendering("=== Level 3 heading")

Use only one (resp. two) `=` for level 1 (resp. 2) heading (and so on).

#typst-rendering(
  "#heading(level: 3, numbering: none)[Level 3 heading without numbering]
==== Level 4 heading"
)

== Cover page

```typc
// Defining variables for the cover page and PDF metadata
#let title = [guide for typst #linebreak() polytechnique package]
#let subtitle = "A modern alternative to LaTeX"
#let logo = image("path/to/my-logo.png")
#let logo-horizontal = true // set to true if the logo is squared or horizontal, set to false if not
#let short-title = "package guide"
#let authors = ("Rémi Germe")
#let date-start = datetime(year: 2024, month: 07, day: 05)
#let date-end = datetime(year: 2024, month: 08, day: 05)
#let despair-mode = false

#set text(lang: "en")

#template.cover.cover(title, author, date-start, date-end, subtitle: subtitle, logo: logo, logo-horizontal: logo-horizontal)
```

Set text lang to `fr` if you want the months in French. \
You can also specify `short-month: true` in the call to cover to get month abbreviations. 

== Doing some math

#typst-rendering(
  "Inline : $P V = n R T$ and $f : x -> 1/18 x^4$, $forall x in RR, f(x) >= 0$."
)

#typst-rendering(
  "Block (note space after opening \$ and before closing \$) : $ f(b) = sum_(k=0)^n (b-a)^k / k! f^((k))(a) + integral_a^b (b-t)^n / n! f^((n+1))(t) dif t $"
)

== Table of contents

You can generate a table of contents using `#outline()`. Here are useful parameters you can specify :
- `indent`
- `depth`
- `title` (put the title inside brackets : [title])
For example, the previous table of contents was generated using :

```typc
#outline(title: [Guide content], indent: 1em, depth: 2)
```

== Cite an article

#typst-rendering(
  "You can cite an article, a book or something like @example-turing. Just see the `#bibliography` command below - you need a `.bib` file containing the bibliography."
)

== Numbering pages

Useful commands to number pages (learn about #link("https://typst.app/docs/reference/model/numbering/")[numbering patterns]) :

```typc
#set page(numbering: none)     // to disable page numbering
#set page(numbering: "1 / 1")  // or another numbering pattern
#counter(page).update(1)       // to reset the page counter to 1 
```

*Warning* : put these instructions at the very beginning of a page, otherwise it will cause a pagebreak.

#typst-rendering("#lorem(25)")

== Dummy text with lorem

You can generate dummy text with the `#lorem(n)` command. For example : #lower(lorem(10))

#pagebreak()

= Modify the template

== Contribute

Contributions are welcomed ! Check out the #link("https://github.com/remigerme/typst-polytechnique")[source repository].

You can also learn more about #link("https://github.com/typst/packages")[Typst packages] release pipeline.

#pagebreak()

#bibliography("assets/example.bib")
