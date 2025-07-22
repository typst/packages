#import "../src/lib.typ" as deckz

#let player-mat(body) = box(
	stroke: olive.darken(20%),
	fill: olive.lighten(10%),
	radius: (top: 50%, bottom: 5%), 
	inset: 15%,
	body
)

= Who's winning?

#text(white, font: "Roboto Slab", weight: "semibold")[

	#box(fill: olive, 
		width: 100%, height: 12cm, 
		inset: 4mm, radius: 2mm
	)[

		#place(center + bottom)[
			#player-mat[
				#deckz.hand(format: "small", width: 3cm, "9S", "10H", "4C", "4D", "2D")
				Alice
			]
		]

		#place(left + horizon)[
			#rotate(90deg, reflow: true)[
				#player-mat[
					#deckz.hand(format: "small", width: 3cm, "AS", "JH", "JC", "JD", "3D")
					#align(center)[Bob]
				]
			]
		]

		#place(center + top)[
			#rotate(180deg, reflow: true)[
				#player-mat[
					#deckz.hand(format: "small", width: 3cm, "KH", "8H", "7H", "5C", "3C")
					#rotate(180deg)[Carol]
				]
			]
			
		]

		#place(right + horizon)[
			#rotate(-90deg, reflow: true)[
				#player-mat[
					#deckz.hand(format: "small", width: 3cm, "6S", "3H", "2H", "QC", "9C")
					#align(center)[Dave]
				]
			]
		]

		#place(center + horizon)[
			#deckz.deck(format: "small", angle: 80deg, height: 8mm, "AD")
		]
	]
]

In this situation, Alice has a *Pair of Four* (#deckz.inline("4C"), #deckz.inline("4D")). _What should the player do?_