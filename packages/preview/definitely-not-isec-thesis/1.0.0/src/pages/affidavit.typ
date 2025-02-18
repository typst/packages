#let affidavit-page() = [
	#set page(
		margin: (
		bottom: 2.6cm,
		left: 4.1cm,
		right: 4.1cm,
		top: 10.25cm,
	),
		footer: none,
		header: none,
	)

	#align(center)[
		#text(size: 12pt)[
			*AFFIDAVIT*
		]
	]

	#v(0.95cm)
	#block[
		#par[
			I declare that I have authored this thesis independently, that I have not
			used other than the declared sources/resources, and that I have explicitly
			indicated all material which has been quoted either literally or by content
			from the sources used. The text document uploaded to TUGRAZonline is
			identical to the present master's thesis.
		]
	]

	#v(3.07cm)

	#line(length: 100%, stroke: 0.5pt)

	#v(-0.1cm) // TODO: refactor

	#align(center)[
		#text(size: 8pt)[
			Date, Signature
		]
	]

]

// vim:tabstop=2 softtabstop=2 shiftwidth=2 noexpandtab colorcolumn=81
