#import "../src/lib.typ" as deckz

#set text(font: "Roboto Slab", weight: "semibold")

#show emoji.suit.club: "A"

#align(center, [
	#deckz.hand(
		angle: 20deg,
		width: 12cm,
		noise: 0.7,
		"AS", "KH", "QD", "JS", "JH", "10C", "9D", "6C"
	)

	#line(length: 60%)

	
	#let my-hand = ("AS", "2H", "3D", "4C", "5S", "6H", "7D", "8C", "9S", "10H")

	#table(
		columns: (1fr, ) * 5,
		stroke: none,
		..my-hand.map((card) => deckz.render(card, format: "medium"))
	)
])
