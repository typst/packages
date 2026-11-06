// this is needed to make the glossary work
#import "@preview/glossarium:0.5.10": *

= Introduction <introduction>
You can reference sections (_analysis_ for example):
- *By section*: #ref(<analysis>).
- *By page*: #ref(<analysis>, form: "page").

== References
=== Glossary
When using the glossary, only the first reference will be in full form (unless specified).
- *Here is the first reference*: @ai
- *Here is the second reference*: @ai
- *Here is the third reference*: @ai
- *Here is a forced full reference*: #gls("ai", first: true)
- *Here is plural reference*: @ai:pl
- *Here is a forced full plural reference*: #glspl("ai", first: true)

=== Bibliography Explained
You can reference the bibliography in the same way as the glossary.
- *Like this*: @quantum_computing
- *Or like this*: #ref(<quantum_computing>)



== Motivation
#lorem(300)


== Research Questions
#lorem(200)
#parbreak()
#list(
  lorem(10),
  lorem(15),
  lorem(20),
  lorem(7),
  lorem(18),
  lorem(22),
  lorem(10),
)
