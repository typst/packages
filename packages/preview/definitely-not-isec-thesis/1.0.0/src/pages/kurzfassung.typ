#let kurzfassung-page(ku-title, ku-abstract, ku-ktitle, ku-keywords) = [

	= #ku-title

	#ku-abstract

	#v(0.53cm)

	// TODO improve the spacing between keywords and the actual keywords
	// TODO mayube  
	#par(first-line-indent:0pt)[
		*#ku-ktitle:* #h(0.3cm) #ku-keywords.join(" · ")
	]

]

// vim:tabstop=2 softtabstop=2 shiftwidth=2 noexpandtab colorcolumn=81
