// Define and sort the initial hand
#let my-hand = deckz.arr.sort-by-score(("8S", "9S", "10S", "JS", "QS", "9H", "9D", "9C", "QD", "3D", "4D", "5D"))

#set text(font: "Roboto Slab")
My current *hand*: 

#deckz.hand(..my-hand,
	format: "small",
	angle: 10deg,
	width: 12cm,
)

#let show-combination(combination) = [
	
	Which *#combination* can I make?

	#let combinations = deckz.val.extract(combination, my-hand)
	#if combinations.len() == 0 {
	 	[None.]
	} else {
		for combo in combinations {
			box(
				fill: eastern,
				inset: 6pt, 
				radius: 35%,
			)[
				#combo.map(deckz.mini).join([#h(3pt)])
			]
			h(1mm)
		}
	}
]
 
#show-combination("high-card")
#show-combination("pair")
#show-combination("two-pairs")
#show-combination("three-of-a-kind")
#show-combination("straight")
#show-combination("flush")
#show-combination("full-house")
#show-combination("four-of-a-kind")
#show-combination("straight-flush")
#show-combination("five-of-a-kind")
