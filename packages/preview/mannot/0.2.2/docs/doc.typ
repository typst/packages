#import "@preview/tidy:0.4.0"
#import "@preview/codly:1.0.0": *
#import "/src/lib.typ": *
#import "doc-template.typ": *

#show link: underline

#show: codly-init.with()
#codly(lang-format: none)

// #set text(font: "Noto Serif", size: 10pt)
// #show raw.where(block: false): set text(font: "Noto Sans Mono")

#let package-info = toml("/typst.toml")
#let name = package-info.package.name
#let version = package-info.package.version

#text(2em, weight: "bold", name)
#h(1em)
#text(1.2em, "v" + version)


A package for marking and annotating in math blocks in Typst.

#outline(depth: 1, indent: auto)


= Example
#example-vstack(```typst
#set text(12pt)
#v(2em)
$
  markul(p_i, tag: #<p>)
  = markrect(
    exp(- marktc(beta, tag: #<beta>) marktc(E_i, tag: #<E>, color: #green)),
    tag: #<Boltzmann>, color: #blue,
  ) / mark(sum_j exp(- beta E_j), tag: #<Z>)

  #annot(<p>, pos: left)[Probability of \ state $i$]
  #annot(<beta>, pos: top + left, yshift: 2em)[Inverse temperature]
  #annot(<E>, pos: top + right, yshift: 1em)[Energy]
  #annot(<Boltzmann>, pos: top + left)[Boltzmann factor]
  #annot(<Z>)[Partition function]
$
```)


= Usage
Import the package #raw(name) on the top of your document:
#let usage-code = "#import \"@preview/" + name + ":" + version + "\": *"
#raw(block: true, lang: "typst", usage-code)

To define the target of an annotation within a math block,
use the following marking functions:
- `mark`: marks the content with highlighting;
- `markrect`: marks the content with a rectangular box;
- `markul`: marks the content with an underline;
- `marktc`: marks the content and changes the text color.
#example(```typst
$
mark(x, tag: #<t1>) + markrect(2y, tag: #<t2>)
+ markul(z+1, tag: #<t3>) + marktc(C, tag: #<t4>)
$
```)

You can customize the marking color and other styles:
#example(```typst
$
mark(x, tag: #<t1>, color: #purple)
+ markrect(2y, tag: #<t2>, color: #red, padding: #2pt)
+ markul(z+1, tag: #<t3>, stroke: #1pt)
+ marktc(C, tag: #<t4>, color: #olive)
$
```)

You can also use marking functions solely for styling parts of a math block,
without tags:
#example(```typst
$
mark(x^2 +, color: #blue, radius: #20%)
f(markul(x^2 + 1, color: #red, stroke: #2pt))
$
```)

Once you have marked content with a tag,
you can annotate it using the `annot` function within the same math block:
#example(```typst
$
mark(x, tag: #<t1>, color: #purple)
+ markrect(2y, tag: #<t2>, color: #red, padding: #2pt)
+ markul(z+1, tag: #<t3>, stroke: #1pt)
+ marktc(C, tag: #<t4>, color: #olive)

#annot(<t1>)[annotation]
#annot(<t4>)[another annotation]
$
```)

You can customize the position of the annotation and its vertical distance from the marked content,
using the `pos` and `yshift` parameters of the `annot` function:
#example(```typst
#v(3em)
$
mark(x, tag: #<t1>, color: #purple)
+ markrect(2y, tag: #<t2>, color: #red, padding: #2pt)
+ markul(z+1, tag: #<t3>, stroke: #1pt)
+ marktc(C, tag: #<t4>, color: #olive)

#annot(<t1>, pos: left)[Set pos \ to left.]
#annot(<t2>, pos: top, yshift: 1em)[
  Set pos to top, and yshift to 1em.
]
#annot(<t3>, pos: right, yshift: 1em)[
  Set pos to right,\ and yshift to 1em.
]
#annot(<t4>, pos: top + left, yshift: 3em)[
  Set pos to top+left,\ and yshift to 3em.
]
$
#v(2em)
```)


= Limitations
Marking multi-line inline math content is not supported.
#example(```typst
$mark(x + x + x + x + x + x + x + x)$
```)


= API
#{
  import "/src/lib.typ"
  import "tidy-style.typ"

  let docs = (
    tidy.parse-module(
      read("/src/mark.typ") + read("/src/annot.typ"),
      scope: (lib: lib),
      preamble: "import lib: *\n",
    )
  )
  tidy.show-module(docs, show-outline: true, sort-functions: none, style: tidy-style)
}
