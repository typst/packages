#import "../src/lib.typ": *

#let cw = load-crossword(yaml("../examples/data_mini.yaml"))

#show-schema(cw.schema)
== Across
#show-definitions(cw.definitions.across)
== Down
#show-definitions(cw.definitions.down)