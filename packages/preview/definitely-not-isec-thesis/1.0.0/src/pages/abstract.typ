#let abstract-page(abstract, keywords) = [

	= Abstract

	// TODO add first-line-indent: 1em?
	// In LaTeX the fist one doesn't have it, the rest yes
	// but the first line in the latex one I think its not intended to stay there
	#abstract

	#v(0.53cm)

	// TODO improve the spacing between keywords and the actual keywords
	// TODO mayube  
	#par(first-line-indent:0pt)[
		*Keywords:* #h(0.3cm) #keywords.join(" · ")
	]

]

// vim:tabstop=2 softtabstop=2 shiftwidth=2 noexpandtab colorcolumn=81
