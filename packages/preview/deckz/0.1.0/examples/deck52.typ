#import "../src/lib.typ" as deckz

#set page(margin: 5mm)

#text(white, font: "Oldenburg")[

	#box(fill: aqua.darken(40%), 
		inset: 4mm, radius: 2mm
	)[
		#deckz.hand(angle: 270deg, width: 8cm, format: "large", noise: 0.35, ..deckz.deck52)

		#place(center + horizon)[
			#text(size: 30pt)[Deckz]
		]
	]
]