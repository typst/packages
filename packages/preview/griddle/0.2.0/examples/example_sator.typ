#import "../src/lib.typ": *

#let cw = load-crossword(yaml("../examples/data_sator.yaml"))

#show-schema(cw.schema, solved: true)