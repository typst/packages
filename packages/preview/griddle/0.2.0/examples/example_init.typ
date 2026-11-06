#import "../src/lib.typ": *

#let cw = load-crossword(yaml("../examples/data_init.yaml"))

= #h(10pt) A Simple Crossword Example

#table(columns: (auto, 1fr), stroke: none, inset: 10pt,
	[
		#show-schema(cw.schema, 
		cell-fill: auto, 
		wall-fill: gradient.linear(..color.map.crest, relative: "parent", angle: -15deg),
		)
	],
	[
		#v(2em)
		== Across
		#show-definitions(cw.definitions.across)
		== Down
		#show-definitions(cw.definitions.down)
	]
)
	
