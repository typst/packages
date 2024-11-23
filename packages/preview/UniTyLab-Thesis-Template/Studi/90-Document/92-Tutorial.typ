// Imports
#import "../../Template/config.typ": *

// Import Figures
#import "../figures/callouts/example.typ": *
#import "../figures/code/example.typ": *
#import "../figures/diagrams/example.typ": *
#import "../figures/equations/example.typ": *
#import "../figures/images/example.typ": *
#import "../figures/tables/example.typ": *


= Document Tutorial
== About this Template
This template was created with the intention of offering students who complete work in the UniTyLab of the #link("https://www.hs-heilbronn.de/en")[Heilbronn University] a simple and clean solution for written submissions such as project documentation or theses.

#template-info

== How to Typst
Typst behaves very similarly to Markdown, so writing should be very easy. 
Typst also offers the option of more complex functions.
Typst therefore provides extensive #link("https://typst.app/docs/")[Documentation] that explains many of these functions.

Typst allows the use of #link("https://typst.app/docs/reference/symbols/sym/")[symbols]. \u{2713} \u{2300} \u{2190} \u{0394}

== How to use this Template
=== Files and Left Sidebar
=== What you should do
- Write down your information in the file "doc-info"
- Use the folder "chapters - mandatory" to write down the mandatory chapters of your document
- Use the folder "chapters - personal" to add own chapters
- Create diagrams in the folder "diagrams"
- Upload images in the folder "images"
- Use the "bib" folder for references, glossary and else

=== What you should not do
- Touch anything in the folder "template"

=== What you can do
- Use the utilities in the folder "utilities"
- Add chapters in-between in the folder "structure" (not recommended)

==== dsfgdsfgertte
eertzertzertzertz

=== Language
The template is in English, but you can also write in German.
A full German support is not realized yet.

== Management of Sources
+ Download and install #link("https://www.zotero.org/")[Zotero]
+ Download and install #link("https://retorque.re/zotero-better-bibtex/")[Better BibTex] 
+ Go to Settings -> Export
+ Under "Quick Export" set "Format for Entries" to "Better BibLaTex"
+ Simply pull Zotero entries into the "bib/sources.bib"
+ Reference the source with an \@

This is a test @choudhryAdolescentIdiopathicScoliosis2016.


== Figures
Images, tables, etc. have to be displayed as #link("https://typst.app/docs/reference/model/figure/")[figure] to get outlined in the specific list of contents and to get a numbered caption.

The "placement" of the figures in this document are set to "none", which means that you are responsible for there correct positioning. 
It is possible to set the placement of the figures to "auto". 
If you do that, Typst places them automatically an the top or bottom of a site. 
Often a mixture of placement settings is the best option.

It is recommended to use the figures folder to organize your figures.
Some examples are given, but how you organize them is up to you.

=== Images

#fig-img-showcase<fig-img-showcase>

=== Tables

#fig-tab-showcase<fig-tab-showcase>

=== Code
For the Code, the Typst Universe Package #link("https://typst.app/universe/package/codly")[codly] is used. \
Click the link to find the documentation.

#fig-code-showcase<fig-code-showcase>

=== Callouts
Uses "textbox" from utilities/textbox.typ

#fig-call-showcase<fig-call-showcase>

=== Diagrams
For the Glossary, the Typst Universe Package #link("https://typst.app/universe/package/fletcher")[fletcher] is used. \
Click the link to find the documentation.

#fig-dia-showcase<fig-dia-showcase>

For Drawings, the Typst Universe Package #link("https://typst.app/universe/package/cetz")[cetz] is used. \
Click the link to find the documentation.

For Gantt Charts, the Typst Universe Package #link("https://typst.app/universe/package/timeliney")[timeliney] is used. \
Click the link to find the documentation.

=== Equations
We define:

#eq-ratio<eq-ratio>

With @eq-ratio, we get:

#eq-fol<eq-fol>

=== Wrapping
For the Glossary, the Typst Universe Package #link("https://typst.app/universe/package/wrap-it")[wrap-it] is used. \
Click the link to find the documentation.

#wrap-content(
  fig-call-wrapped,
  align: top + right,
)[
  #lorem(70)
]


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

== Reviews
=== From supervisors
#supervisor1[Feedback]
#supervisor2[Feedback]

=== From friends and others
List of available #link("https://typst.app/docs/reference/visualize/color/")[colors] \
Do not use red, orange and blue.
#reviewer("Friend", color: green)[Feedback]
#reviewer("Grandmother", color: purple)[Feedback]
