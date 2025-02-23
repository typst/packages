#import "@preview/mantys:1.0.0": *

#import "../src/lib.typ" as arborly

#show: mantys(
  name: "arborly",
  version: "0.1.0",
  authors: (
    "Max Pearce Basman",
  ),
  license: "MIT",
  description: "A library for producing beautiful syntax tree graphs.",
  repository: "https://github.com/pearcebasmanm/arborly",

  title: "Arborly",
  subtitle: "A library for producing beautiful syntax tree graphs.",
  date: datetime.today(),

  examples-scope: (
    scope: (arborly: arborly),
  ),
  show-index: false,
  theme: themes.modern,
  ..toml("../typst.toml"),
)


= Usage

== Importing the Package

#show-import(imports: none)

== Building a Syntax Tree

Each node in the tree is an array of a label and a child node array, with the exception of terminal nodes, which contain content instead.

Be aware that the trailing commas after lone children are _not_ optional, as otherwise they cause ```typc ("NP", (("N", "this")))``` to parse as ```typc ("NP", ("N", "this"))```.

#example(```typ
#let tree = ("TP", (
  ("NP", (
    ("N", "this"),
  )),
  ("VP", (
    ("V", "is"),
    ("NP", (
      ("D", "a"),
      ("N", "wug"),
    )),
  )),
))

#arborly.tree(tree, min-gap-x: 1)
```)

= Arguments
#tidy-module(
  "arborly",
  read("../src/lib.typ"),
  show-outline: false,
)

= Examples

Note that I am not a linguist, so these analyses may be wrong.

== The Quick Brown Fox

#example(```typ
#let tree = ("TP", (
  ("NP", (
    ("D", "The"),
    ("AdjP", (
      ("Adj", ("quick")),
    )),
    ("AdjP", (
      ("Adj", ("brown")),
    )),
    ("N", "fox"),
  )),
  ("VP", (
    ("V", "jumps"),
    ("PP", (
      ("P", "over"),
      ("NP", (
        ("D", "the"),
        ("AdjP", (
          ("Adj", "lazy"),
        )),
        ("N", "dog"),
      )),
    )),
  )),
))

#arborly.tree(tree, label-alignment: "smart")
```)

== Sphinx of Black Quartz
#show raw: set text(8pt)
#show raw: set par(justify: false)
#example(```typ
#let tree = ("TP", (
  ("NP", (
    ("N", "Sphinx"),
    ("PP", (
      ("P", "of"),
      ("NP", (
        ("AdjP", (
          ("Adj", "black"),
        )),
        ("N", "quartz,")
      )),
    )),
  )),
  ("VP", (
    ("V", "judge"),
    ("NP", (
      ("AdjP", (
        ("Adj", "my"),
      )),
      ("N", "vow."),
    )),
  )),
))

#arborly.tree(tree)
```)


== Long Sentence

#example(```typ
#let tree = ("TP",(("NP",(("D","The"),("N","move"),("PP",(("P","from"),("NP",(("D","a"),("AdjP",(("Adj","structuralist"),)),("N","account"),("PP",(("P","in"),("CP",(("C","which"),("TP",(("NP",(("N","capital"),)),("T","is"),("VP",(("V","understood"),("TP",(("T","to"),("VP",(("V","structure"),("NP",(("AdjP",(("Adj","social"),)),("N","relations"),)),("PP",(("P","in"),("NP",(("AdjP",(("AdvP",(("Adv","relatively"),)),("Adj","homologous"),)),("N","ways"),)),)),)),)),)),)),)),)),)),)),("PP",(("P","to"),("NP",(("D","a"),("N","view"),("PP",(("P","of"),("NP",(("N","hegemony"),)),)),("PP",(("P","in"),("CP",(("C","which"),("TP",(("NP",(("AdjP",(("Adj","power"),)),("N","relations"),)),("VP",(("V","are"),("AdjP",(("Adj","subject"),("PP",(("P","to"),("NP",(("N","repetition"),("N","convergence"),("Conj","and"),("N","rearticulation"),)),)),)),)),)),)),)),)),)),)),("VP",(("V","brought"),("NP",(("D","the"),("N","question"),("PP",(("P","of"),("NP",(("N","temporality"),)),)),("PP",(("P","into"),("NP",(("D","the"),("N","thinking"),("PP",(("P","of"),("NP",(("N","structure"),)),)),)),)),)),)),("Conj","and"),("VP",(("V","marked"),("NP",(("D","a"),("N","shift"),)),("PP",(("P","from"),("NP",(("D","a"),("N","form"),("PP",(("P","of"),("NP",(("AdjP",(("Adj","Althusserian"),)),("N","theory"),)),)),("CP",(("C","that"),("TP",(("VP",(("V","takes"),("NP",(("AdjP",(("Adj","structural"),)),("N","totalities"),)),("PP",(("P","as"),("NP",(("AdjP",(("Adj","theoretical"),)),("N","objects"),)),)),)),)),)),)),)),("PP",(("P","to"),("NP",(("N","one"),("PP",(("P","in"),("CP",(("C","which"),("TP",(("NP",(("D","the"),("N","insights"),("PP",(("P","into"),("NP",(("D","the"),("AdjP",(("Adj","contingent"),)),("N","possibility"),("PP",(("P","of"),("NP",(("N","structure"),)),)),)),)),)),("VP",(("V","inaugurate"),("NP",(("D","a"),("AdjP",(("Adj","renewed"),)),("N","conception"),("PP",(("P","of"),("NP",(("N","hegemony"),)),)),("PP",(("P","as"),("AdjP",(("Adj","bound"),("AP",(("Adv","up"),)),("PP",(("P","with"),("NP",(("D","the"),("AdjP",(("Adj","contingent"),)),("N","sites"),("Conj","and"),("N","strategies"),("PP",(("P","of"),("NP",(("D","the"),("N","rearticulation"),("PP",(("P","of"),("NP",(("N","power"),)),)),)),)),)),)),)),)),)),)),)),)),)),)),)),)),))

#scale(11%, reflow: true, arborly.tree(tree, label-alignment: "average", min-space-y: 2))
```)
