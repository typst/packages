#import "../Template-Import.typ": *


= Document Tutorial
== About this Template
This template was created with the intention of offering students who complete work in the UniTyLab of the #link("https://www.hs-heilbronn.de/en")[Heilbronn University] a simple and clean solution for written submissions such as project documentation or theses.

If you are from another university, you are also welcomed to use this template.
Simply change the title images accordingly to your university in the folder "00-Title".

#template-info

== How to Typst
Typst therefore provides extensive #link("https://typst.app/docs/")[Documentation] that explains many of these functions.


=== Getting started 
The folder "90-Document" contains the files "90-Document.typ", "91-Doc-Infos.typ" as well as this tutorial. 
If you open this folder, you can see an open eye on the file "90-Document.typ", indicating that this file is previewed on the right. 
"90-Document.typ" serves as the main file of your project.

To personalize this document, open "91-Doc-Infos.typ" and fill in your data. 
The title screen should now have changed according to your inputs. 

=== Mandatory Chapters
This template contains a number of files/chapters which are mandatory in every project. 
These files are found in the folders 10, 20, and 40.

=== Personal Chapters
The folder "30-Chapters" contains files with your personal chapters. 
Feel free to create new files according to your wishes.
Remember to "\#include" them into the file "30-Main-Doc-Personal.typ" 

=== Bibliography 
Found in the folder "50-Bibliography".
Your bibliography, containing your sources as well as your glossary.
Both must be processed appropriately for a successful submission.

=== Post-Document
Containing the affidavit, which has to be signed!
You can add other pages, such as acknowledgements, dedications or similar.

=== Appendix
Everything belonging to the appendix can be copied into this folder and imported in "70-Appendix.typ".
You are free to create more files, folders, etc.

=== Structure
This folder simply helps structuring the thesis and applying the template of the according sections. 
It is recommended to not touch this folder. 

=== Assets
All your needed assets, like images, can be copied and used from the folder assets.


=== Utilities 
A folder which you can use to store utilities you like.

=== Language
For now, the template only supports English. 


== Management of Sources
+ Download and install #link("https://www.zotero.org/")[Zotero]
+ Download and install #link("https://retorque.re/zotero-better-bibtex/")[Better BibTex] 
+ Open Zotero and go to Settings -> Export
+ Under "Quick Export" set "Format for Entries" to "Better BibLaTex"
+ Now you are able to simply pull Zotero entries into the "sources.bib"
+ Reference the source with an \@

This is a test @choudhryAdolescentIdiopathicScoliosis2016.


== Glossary
For the Glossary, the Typst Universe Package #link("https://typst.app/universe/package/glossarium")[glossarium] is used. \
Click the link to find the documentation.

You can call your entries by using \#gls("") or \#glspl("").

First call: #gls("cpu") \
Second call: #gls("cpu") \
Plural call: #glspl("cpu") \
First call: #gls("gpu") \
Second call: #gls("gpu") \
Plural call: #glspl("gpu") \


== Figures
Images, tables, etc. must be displayed as #link("https://typst.app/docs/reference/model/figure/")[figure] to get outlined in the specific list of contents and to get a numbered caption.

The "placement" of the figures in this document are set to "none", which means that you are responsible for there correct positioning. 
It is possible to set the placement of the figures to "auto". 
If you do that, Typst places them automatically an the top or bottom of a site. 
Often a mixture of placement settings is the best option.

=== Images
#let fig-img-showcase = figure(
  placement: none,
  image("../assets/lights-prisms-effect-close-up.jpg"),
  caption: [Testing Image provided by #link("https://www.freepik.com/free-photo/lights-prisms-effect-close-up_13397854.htm")[www.freepik.com]],
)
#fig-img-showcase<fig-img-showcase>

=== Tables
Typst default tables: #link("https://typst.app/docs/reference/model/table/")[table] \
Markdown like tables: #link("https://typst.app/universe/package/tablem")[tablem] \
More complex tables: #link("https://typst.app/universe/package/tablex")[tablex] \
Big tables: #link("https://typst.app/universe/package/dining-table")[dining-table] \

#let fig-tab-showcase = figure(
  table(
    columns: 4,
    [t], [1], [2], [3],
    [y], [0.3], [0.7], [0.5],
  ),
  caption: [Testing Table],
)
#fig-tab-showcase<fig-tab-showcase>

=== Code

For code the Typst Universe Packages #link("https://typst.app/universe/package/codly")[codly] and #link("https://typst.app/universe/package/codly-languages/")[codly-languages] are used. \
Click the link to find the documentation.

#let fig-code-showcase = figure(
  caption: "Codeblock Example", 
  supplement: [Code Snippet],
)[```rust
pub fn main() {
    println!("Hello, world!");
}
```]
#fig-code-showcase<fig-code-showcase>

=== Callouts

#let fig-call-showcase = figure(
  kind: "callout",
  supplement: [Callout],
  align(left,
  textbox("This is a Callout")[
    Callouts can be used to highlight very important information or notes.
  ]),
  caption: "This is an important note", 
)

#fig-call-showcase<fig-call-showcase>

=== Diagrams
Multiple options are available for charts and diagrams, like #link("https://typst.app/universe/package/fletcher")[fletcher], #link("https://typst.app/universe/package/cetz")[cetz], #link("https://typst.app/universe/package/timeliney")[timeliney], #link("https://typst.app/universe/package/chronos")[chronos], #link("https://typst.app/universe/package/circuiteria")[circuiteria].

If you miss the right tools for your ideas you are free to import them.

#let diag-flecher = fletcher.diagram(
  node-stroke: 1pt,
  edge-stroke: 1pt,
  node((0,0), [Start], corner-radius: 2pt, extrude: (0, 3)),
  edge("-|>"),
  node((0,1), align(center)[
    Hey, wait,\ this flowchart\ is a trap!
  ], shape: diamond),
  edge("d,r,u,l", "-|>", [Yes], label-pos: 0.1)
)

#let fig-diag-flecher = figure(
  kind: "diagram",
  supplement: [Diagram],
  diag-flecher,
  caption: "Fletcher Example", 
)
#fig-diag-flecher<fig-diag-flecher>

#let diag-chronos = chronos.diagram({
  import chronos: *
  _par("Alice")
  _par("Bob")

  _seq("Alice", "Bob", comment: "Hello")
  _seq("Bob", "Bob", comment: "Think")
  _seq("Bob", "Alice", comment: "Hi")
})
#let fig-diag-chronos = figure(
  kind: "diagram",
  supplement: [Diagram],
  diag-chronos,
  caption: "Chronos Example", 
)
#fig-diag-chronos<fig-diag-chronos>


=== Equations
We define:

#let eq-ratio = $ phi.alt := (1 + sqrt(5)) / 2 $

#let eq-fol = $ F_n = floor(1 / sqrt(5) phi.alt^n) $

#eq-ratio<eq-ratio>

With @eq-ratio, we get:

#eq-fol<eq-fol>

=== Wrapping
For the Glossary, the Typst Universe Package #link("https://typst.app/universe/package/wrap-it")[wrap-it] is used. \
Click the link to find the documentation.

#let fig-call-wrapped = figure(
  kind: "callout",
  supplement: [Callout],
  align(left,
  textbox("This is a Callout",width:7cm)[
    Callouts can be used to highlight very important information or notes.
  ]),
  caption: "This is an important note", 
)

#wrap-content(
  fig-call-wrapped,
  align: top + right,
)[
  #lorem(70)
]

== Useful Links
+ List of available #link("https://typst.app/docs/reference/visualize/color/")[colors] 
+ List of available #link("https://typst.app/docs/reference/symbols/sym/")[symbols] \u{2713} \u{2300} \u{2190} \u{0394}


== Reviews
=== From supervisors
#supervisor1[Feedback]
#supervisor2[Feedback]

=== From friends and others
#reviewer1()[Feedback]
#reviewer2()[Feedback]
#reviewer3()[Feedback]
#reviewer4()[Feedback]