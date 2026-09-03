#import "@preview/palimpsest:0.1.0": *

#set page(width: 16.6cm, height: auto, margin: 12pt)
#set text(size: 10.5pt)
#set heading(numbering: "1.")
#set-revisions(require-exchange: false, authors: (bob: "Bobby Fischer"))

#change-list()

= Introduction

#added(<r1-1>)[A reviewer's addition.]
#deleted(<bob-1>)[Bobby's own deletion.]

== Background

#replaced(<r1-2>)[A second reviewer comment, addressed in this subsection.][A second reviewer comment, revised in this subsection.]

= Methods

#added(<e1>)[An editor's addition.]
#added(none)[An anonymous typo fix, no anchor attached.]
#touched(<r9-9>)[This paragraph is unchanged --- never listed below.]
