#import "../src/lib.typ" as deckz

#set page(margin: 0.5in, fill: gray.lighten(60%))
#set table(stroke: 1pt + white, fill: white)
#set text(font: "Arvo")

= Comparison Table

== #text(blue)[`inline`]
A minimal format where the rank and suit are displayed directly within the flow of text -- perfect for quick references.
#table(align: center, columns: (1fr,) * 4, 
	deckz.inline("AS"),
	deckz.inline("5H"),
	deckz.inline("10C"),
	deckz.inline("QD")
)

== #text(blue)[`mini`] 
The smallest visual format: a compact rectangle showing the rank at the top and the suit at the bottom.
#table(align: center, columns: (1fr,) * 4, 
	deckz.mini("AS"),
	deckz.mini("5H"),
	deckz.mini("10C"),
	deckz.mini("QD")
)

== #text(blue)[`small`]
A slightly larger card with rank indicators on opposite corners and a central suit symbol -- ideal for tight layouts with better readability.
#table(align: center, columns: (1fr,) * 4, 
	deckz.small("AS"),
	deckz.small("5H"),
	deckz.small("10C"),
	deckz.small("QD")
)

== #text(blue)[`medium`]
A fully structured card layout featuring proper suit placement and figures. Rank and suit appear in two opposite corners, offering a realistic visual.
#table(align: center, columns: (1fr,) * 4, 
	deckz.medium("AS"),
	deckz.medium("5H"),
	deckz.medium("10C"),
	deckz.medium("QD")
)

== #text(blue)[`large`]
The most detailed format, with corner summaries on all four corners and an expanded layout -- great for presentations or printable decks.
#table(align: center, columns: (1fr,) * 4, 
	deckz.large("AS"),
	deckz.large("5H"),
	deckz.large("10C"),
	deckz.large("QD")
)

== #text(blue)[`square`]
A balanced 1:1 card format with rank and suit shown in all four corners and a central figure -- designed for symmetry and visual clarity.
#table(align: center, columns: (1fr,) * 4, 
	deckz.square("AS"),
	deckz.square("5H"),
	deckz.square("10C"),
	deckz.square("KD")
)
