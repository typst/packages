#import "../src/lib.typ": *

#let cw = load-crossword(yaml("../examples/data_crossword16.yaml"))

#show heading.where(level: 1): set align(center)
#set text(font: "Arial")

#heading(level: 1)[Videogame-themed Crossword]
#v(1em)
Here is the same crossword schema in three different styles: the default one, with rainbow walls, and with a solved state.
#table(columns: (1fr,)*3, rows: 1, stroke: none, align: left, inset: 0pt,
	show-schema(cw.schema), // Default
	show-schema(cw.schema, wall-fill: gradient.conic(..color.map.rainbow, angle: -60deg)), // With fancy rainbow gradient
	show-schema(cw.schema, cell-fill: lime.lighten(80%), solved: true) // solved
	)

#table(columns: 2, rows: 1, stroke: none, inset: 0pt, gutter: 20pt,
	[
		== Across
		#show-definitions(cw.definitions.across)
	],
	[
		== Down
		#show-definitions(cw.definitions.down)
	]
)