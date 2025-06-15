#import "../src/lib.typ": *

#let cw = load-crossword("../examples/data_mini.yaml")

#align(center)[
= Crossword Example
#show-schema(cw.schema, wall: "empty")
]

== Across
#show-definitions(cw.definitions.across)
== Down
#show-definitions(cw.definitions.down)