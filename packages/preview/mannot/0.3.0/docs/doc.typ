#import "@preview/tidy:0.4.2"
#import "@preview/codly:1.2.0": *
#import "/src/lib.typ": *
#import "doc-template.typ": *

#show link: underline
#set heading(numbering: "1.1.1")

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

#outline(depth: 3, indent: auto)


= Example
#example-vstack(```typst
#set text(12pt)
#v(2em)
$
  markul(p_i, tag: #<p>)
  = markrect(
    exp(- mark(beta, tag: #<beta>, color: #red) mark(E_i, tag: #<E>, color: #green)),
    tag: #<Boltzmann>, color: #blue,
  ) / markhl(sum_j exp(- beta E_j), tag: #<Z>)

  #annot(<p>, pos: bottom + left)[Probability of \ state $i$]
  #annot(<beta>, pos: top + left, dy: -1.5em, leader-connect: "elbow")[Inverse temperature]
  #annot(<E>, pos: top + right, dy: -1em)[Energy]
  #annot(<Boltzmann>, pos: top + left)[Boltzmann factor]
  #annot(<Z>)[Partition function]
$
#v(1em)
```)


= Usage
Import the package #raw(name) on the top of your document:
#let usage-code = "#import \"@preview/" + name + ":" + version + "\": *"
#raw(block: true, lang: "typst", usage-code)

== Marking
To decorate content within math blocks, use the following marking functions:
- `mark`: Changes the text color.
- `markhl`: Highlights the content.
- `markrect`: Draws a rectangle around the content.
- `markul`: Underlines the content.
#example(```typst
$
  mark(x, color: #red) + markhl(f(x))
  + markrect(e^x) + markul(x + 1)
$
```)

You can customize the marking color and other styles:
#example(```typst
$
  mark(x, color: #green)
  + markhl(f(x), color: #purple, stroke: #1pt, radius: #10%)
  + markrect(e^x, color: #red, fill: #blue, outset: #.2em)
  + markul(x + 1, color: #gray, stroke: #2pt)
$
```)

== Annotations
If you marked content with a tag,
you can later annotate it using the `annot` function:
#example(```typst
$
  mark(x, tag: #<1>, color: #green)
  + markhl(f(x), tag: #<2>, color: #purple, stroke: #1pt, radius: #10%)
  + markrect(e^x, tag: #<3>, color: #red, fill: #blue, outset: #.2em)
  + markul(x + 1, tag: #<4>, color: #gray, stroke: #2pt)

  #annot(<1>)[Annotation]
  #annot(<3>, pos: top)[Another annotation]
$
```)

Markings and annotations do not affect the layout,
so you might sometimes need to manually insert spacing before and after the equations to achieve the desired visual appearance:
#example(```typst
Text text text text text:
#v(1em)
$
  mark(x, tag: #<1>, color: #green)
  #annot(<1>, pos: top + right)[Annotation]
  #annot(<1>, dy: 1em)[Annotation]
$
#v(2em)
text text text text text.
```)

=== Annotation Positioning
The `annot` function offers the following arguments to control annotation placement:
- `pos`: Where to place the annotation relative to the marked content.
  This can be:
  - A single alignment for simple relative positioning.
  - A pair of alignments, where the first defines the anchor point on the marked content,
    and the second defines the anchor point on the annotation.

  #[
    #show: pad.with(y: 1em)
    #set align(center)
    #let lab(body) = rect(stroke: silver, inset: 2pt, text(size: .7em, font: "DejaVu Sans Mono", body))
    #let annot = annot.with(annot-inset: 0pt)

    #grid(
      columns: 3,
      gutter: (6em, 14em),
      $
        markrect(integral x dif x, tag: #<1>, color: #red)

    #annot(<1>, pos: top, lab[top])
    #annot(<1>, pos: left, lab[left])
    #annot(<1>, pos: bottom, lab[bottom])
    #annot(<1>, pos: right, lab[right])
      $,
      $
        markrect(integral x dif x, tag: #<1>, color: #red)

    #annot(<1>, pos: top + left, lab[top + left])
    #annot(<1>, pos: top + right, lab[top + right])
    #annot(<1>, pos: bottom + left, lab[bottom + left])
    #annot(<1>, pos: bottom + right, lab[bottom + right])
      $,
      $
        markrect(integral x dif x, tag: #<1>, color: #red)

    #annot(<1>, pos: (top + left, bottom + right), lab[(top + left, bottom + right)])
    #annot(<1>, pos: (top + left, top + right), lab[(top + left, top + right)])
    #annot(<1>, pos: (top + left, bottom + left), lab[(top + left, bottom + left)])
    #annot(<1>, pos: (top + left, top + left), lab[(top + left, top + left)])
      $,
    )
  ]

- `dx`, `dy`: the horizontal and vertical displacement of the annotation's anchor
  from the marked content's anchor.

  #example(```typst
  #v(1em)
  $
    markrect(integral x dif x, tag: #<1>, color: #red)
    #annot(<1>, pos: top)[annotation]
  $
  ```)

  #example(```typst
  #v(1em)
  $
    markrect(integral x dif x, tag: #<1>, color: #red)
    #annot(<1>, pos: top, dx: 1em, dy: -1em)[annotation]
  $
  ```)

=== Annotation Leader Line
When the annotation is far from the marked content, a leader line is drawn by default.
You can customize its appearance using the following annot arguments:
- `leader`: Whether to draw a leader line. Set to `auto` to enable automatic drawing based on distance.
- `leader-stroke`: How to stroke the leader line e.g. `1pt + red`.
- `leader-tip`, `leader-toe`: Define the end and start markers of the leader line.
  Leader lines are drawn by package #link("https://typst.app/universe/package/tiptoe/0.3.0")[tiptoe].
  You can specify markers or `none`:
  #example(```typst
  $
    markhl(x, tag: #<1>)

    #annot(
      <1>, pos: bottom + right, dy: 1em,
      leader-tip: tiptoe.circle,
      leader-toe: tiptoe.stealth.with(length: 1000%),
    )[annotaiton]
  $
  #v(2em)
  ```)

  For more options, see the #link("https://typst.app/universe/package/tiptoe/0.3.0")[tiptoe page].

- `leader-connect`: How the leader line connects to the marked content and the annotation.
  This can be:
  - A pair of alignments defining the connection points on the marked content and the annotation.
  - "elbow" to create an elbow-shaped leader line.
  #example(```typst
    $
      markhl(x, tag: #<1>)
      #annot(<1>, pos: bottom + right, dy: 1em)[annotation]
    $
    #v(2em)
  ```)
  #example(```typst
    $
      markhl(x, tag: #<1>)
      #annot(<1>, pos: bottom + right, dy: 1em, leader-connect: (bottom, top))[annotation]
    $
    #v(2em)
  ```)
  #example(```typst
    $
      markhl(x, tag: #<1>)
      #annot(<1>, pos: bottom + right, dy: 1em, leader-connect: "elbow")[annotation]
    $
    #v(2em)
  ```)

== Multi Annotations
You can also annotate multiple marked elements simultaneously
by passing an array of their tags to the `annot` function.
#example(```typst
#v(1em)
$
  mark(x, tag: #<1>, color: #green)
  + markhl(f(x), tag: #<2>, color: #purple, stroke: #1pt, radius: #10%)
  + markrect(e^x, tag: #<3>, color: #red, fill: #blue, outset: #.2em)
  + markul(x + 1, tag: #<4>, color: #gray, stroke: #2pt)

  #annot((<1>, <2>), dy: 1em)[Annotation]
  #annot((<3>, <2>, <4>), pos: top, dy: -1em, leader-connect: "elbow")[Another annotation]
$
#v(1em)
```)

== Annotations using CeTZ
To create annotations using the CeTZ canvas, use the `annot-cetz` function.
This allows you to embed a CeTZ canvas directly onto previously marked content.
Within the CeTZ canvas code block,
you can reference the position and dimensions of the marked content using an anchor with the same name as its tag.
For elements marked with multiple tags, corresponding anchors will be available.
#example(```typst
#import "@preview/cetz:0.3.4"

$
  mark(x, tag: #<x>) + mark(y, tag: #<y>)

  #annot-cetz((<x>, <y>), cetz, {
    import cetz.draw: *
    content((0, -.6), [CeTZ], anchor: "north-west", name: "a")
    line("x", "a") // You can refer the marked content.
    line("y", "a")
  })
$
#v(1em)
```)


= Limitations
Marking multi-line inline math content is not supported.
#example(```typst
$markhl(x + x + x + x + x + x + x + x)$
```)


= API
#set heading(numbering: none)
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
