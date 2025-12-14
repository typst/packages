#import "../ebnf.typ" : *

== Test: `qualified`

#context qualified(illumination: none, qualifier: "sym-opt")[Hello, World] \
#context qualified(illumination: none, qualifier: "sym-some")[Hello, World] \
#context qualified(illumination: none, qualifier: "sym-any")[Hello, World]
