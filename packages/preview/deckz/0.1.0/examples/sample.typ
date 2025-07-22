#import "../src/lib.typ" as deckz

#let my-hand = ("AS", "KH", "QD", "JS", "JH", "10C", "9D", "6C")

#table(
	columns: (1fr),
	align: center,
	stroke: none,
	deckz.hand(..my-hand),
	deckz.hand(angle: 0deg, width: 4cm, ..my-hand),
	deckz.hand(format: "mini", ..my-hand),
	deckz.hand(width: 5cm, noise: 2, format: "small", ..my-hand),
	deckz.hand(angle: 180deg, width: 3cm, noise: 0.5, format: "large", ..(my-hand + my-hand)),
)