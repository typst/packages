#import "@preview/tidy:0.3.0"
#import "@preview/codly:1.0.0": *
#import "/src/lib.typ": *
#import "doc-template.typ": *

#show link: underline

#show: codly-init.with()
#codly(lang-format: none)

#let package-info = toml("/typst.toml")
#let name = package-info.package.name
#let version = package-info.package.version

#text(2em, weight: "bold", name)
#h(1em)
#text(1.2em, "v" + version)


A package for highlighting and annotating in math blocks in Typst.

#outline(depth: 1, indent: auto)

= Usage
Import and initialize the package #raw(name) on the top of your document.
#let usage-code = "#import \"@preview/" + name + ":" + version + "\": *\n" + "#show: mannot-init"
#raw(block: true, lang: "typst", usage-code)

To highlight a part of a math block, use the `mark` function:
#example("$
mark(x)
$")

You can also specify a color for the highlighted part:
#example("$ // Need # before color names.
mark(3, color: #red) mark(x, color: #blue)
+ mark(integral x dif x, color: #green)
$")

To add an annotation to a highlighted part, use the `annot` function.
You need to specify the tag of the marked content:
#example("$
mark(x, tag: #<x>)  // Need # before tags.
#annot(<x>)[Annotation]
$")

You can customize the position of the annotation and the vertical distance from the marked content:
#example("$
mark(integral x dif x, tag: #<i>, color: #green)
+ mark(3, tag: #<3>, color: #red) mark(x, tag: #<x>, color: #blue)

#annot(<i>, pos: left)[Set pos to left.]
#annot(<i>, pos: top + left)[Top left.]
#annot(<3>, pos: top, yshift: 1.2em)[Use yshift.]
#annot(<x>, pos: right, yshift: 1.2em)[Auto arrow.]
$")

For convenience, you can define custom mark functions:
#example("#let rmark = mark.with(color: red)
#let gmark = mark.with(color: green)
#let bmark = mark.with(color: blue)

$
integral_rmark(0, tag: #<i0>)^bmark(1, tag: #<i1>)
mark(x^2 + 1, tag: #<i2>) dif gmark(x, tag: #<i3>)

#annot(<i0>)[Begin]
#annot(<i1>, pos: top)[End]
#annot(<i2>, pos: top + right)[Integrand]
#annot(<i3>, pos: right, yshift: .6em)[Variable]
$")


= Limitations
If you mark a inline math element containing linebreaks,
its layout will be broken:
#example("
$mark(x + x + x + x + x + x + x + x)$
")


= API
#{
  import "/src/lib.typ"
  import "tidy-style.typ"

  let docs = (
    tidy.parse-module(
      read("/src/mark.typ") + read("/src/annot.typ"),
      scope: (lib: lib),
      preamble: "import lib: *;",
    )
  )
  tidy.show-module(docs, show-outline: true, sort-functions: none, style: tidy-style)
}
