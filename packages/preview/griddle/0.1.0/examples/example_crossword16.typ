#import "../src/lib.typ": *

#let cw = load-crossword(yaml("../examples/data_crossword16.yaml"))

#show heading.where(level: 1): set align(center)
#set text(font: "Helvetica")

#heading(level: 1)[Videogame-themed Crossword]
#v(1em)
Here is the same crossword schema in three different styles: the default one, with rainbow walls, and with a solved state.
#table(columns: (1fr,)*3, rows: 1, stroke: none, align: left, inset: 0pt,
	show-schema(cw.schema), 
	show-schema(cw.schema, wall: "rainbow"), 
	show-schema(cw.schema, solved: true)
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