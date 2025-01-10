#let kurzfassung_page(ku_title, ku_abstract, ku_ktitle, ku_keywords) = [

	= #ku_title

	#ku_abstract

	#v(0.53cm)

	// TODO improve the spacing between keywords and the actual keywords
	// TODO mayube  
	#par(first-line-indent:0pt)[
		*#ku_ktitle:* #h(0.3cm) #ku_keywords.join(" · ")
	]

]

// vim:tabstop=2 softtabstop=2 shiftwidth=2 noexpandtab colorcolumn=81
