// Imports
#import "../../../Template/config.typ": *

#let fig-call-showcase = figure(
  kind: "callout",
  supplement: [Callout],
  align(left,
  textbox("This is a Callout")[
    Callouts can be used to highlight very important information or notes.
  ]),
  caption: "This is an important note", 
)

#let fig-call-wrapped = figure(
  kind: "callout",
  supplement: [Callout],
  align(left,
  textbox("This is a Callout",width:7cm)[
    Callouts can be used to highlight very important information or notes.
  ]),
  caption: "This is an important note", 
)