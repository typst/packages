#import "preamble.typ": *

= #ugent.i18n.Preface
== #ugent.i18n.Acknowledgements
This is an @ugent template. Search the language key (hint, it's in
`parts-dissertation/preamble.typ` and switch it to Dutch 'nl'.
See how much changes to the correct language!)

Verander de taal naar het Nederlands door "nl" te gebruiken
in `parts-dissertation/preamble.typ`. Geniet!

Een masterproef is meestal rond de 24 @ECTS credits.

== #ugent.i18n.Permission-loan

#pagebreak()
== #ugent.i18n.Remarks-dissertation
Figures can be used, like here.
If you want to wrap them in the text flow, use #code-inline[```typ #import "@preview/wrap-it:0.1.1": wrap-content```].
Here, we're actually already showcasing some advanced concepts!
The figure is made exactly as wide as the caption.
#let human-made-source = "https://hinokodo.itch.io/human-made"
#let caption-human-made = text(luma(70%))[
  #show link: set text(fill: luma(100%, 0%)) // play a bit with color
  Created by #link(human-made-source)[HINOKONDO]
]
#figure(
  context image("../assets/figures/hand_text_horizontal.svg",
        width: measure(caption-human-made).width, //30%,
        alt: "Stylistic hand with right to it the text 'human made'"),
  // Use flex-caption to differentiatie between the caption text under the
  // figure and the text in the outline.
  caption: caption-human-made,
  numbering: none,
  outlined: true,
),

*Only use this figure if your dissertation does #emph[not] contain content created with @AI!*
Those are the conditions by the artist of this image, check-out
#link(human-made-source)[the source].

#let f1 = footnote[
  A response on "A Student’s Guide to Writing with ChatGPT" from OpenAI
  by a university researcher and teacher. @perretStudentsGuideNot2024
]
#let f2 = footnote[
  The \$2 Per Hour Workers Who Made ChatGPT Safer. @ExclusiveHourWorkers2023
]
#let f3 = footnote[
  The exploited workers with PTSD. @haskinsLowPaidHumansAIs
]
#let f4 = footnote[
  Satire with references to ecological research: "@AI is facing a crisis:
  humans are consuming far too many precious resources that @AI needs to thrive."
  @AINeedsYour
]

There are many reasons to *not* use @AI for a dissertation#f1.
There are too many ethical#f2#super[,]#f3 and ecological#f4 reasons to use @AI.
There are even more social problems, but the most import ones for research
or a dissertation are the fact that @AI results are not reproducible
@jazwinskaAISearchHas and cannot be scientifically supported, since it is
a stochastic model without knowledge about what it is producing
@benderDangersStochasticParrots2021.
//@LLMentalistEffectHow2023.

#align(right)[
  #context ugent.info().author \
  City,
  // EDIT: Fix 'juli' manually. Is not yet done by Typst. (It is not worth it to
  // add a dependency on 'datify' or 'icu-datetime' for only this occurence.)
  #datum.display("[day padding:none] juli [year]")
]

// Go ahead, EDIT the order, titles, ... to satisfy your faculty guidelines!
#outline()
#ugent.glossary(title: [Lijst van afkortingen en begrippen])
= Lijsten van figuren, tabellen, formules en codefragmenten
#{
  // If you want outlines on each page, remove the set rule
  set heading(offset: 2)
  outline(target: figure.where(kind: image))
  outline(target: figure.where(kind: table))
  outline(target: ugent.utils.all-math-figures)
  outline(target: figure.where(kind: raw)  )
}

#ugent.dissertation-abstract-info
=== #ugent.i18n.Abstract
#todo-change(pos: "block")[Write abstract]

=== #ugent.i18n.Keywords
Template,
Masterproef,
EDIT

#include "0_extended_abstract.typ"
