#let title-page(
	title: [],
	author: (),
	curriculum: [],
	supervisors: (),
	institute: [],
	date: [],
) = [

	#set page(
		margin: (
			// Original LaTeX is 2.7 but with 2.6 we get "Graz, Month Date" lower to
			// get a perfect visual match
			bottom: 2.6cm,
			left: 2.5cm,
			right: 2.5cm,
			top: 1.5cm,
		),
		header: none,
		footer: none,
	)

	#set align(center)

	#set par(
		leading: 12pt, // \linespread{1.2}
	)

	// TODO maybe use absolute positioning
	#v(0.26cm)
	#image(
		// TODO get the proper coloring of the logo, looks different
		"../assets/tuglogo.svg",
		width: 3.2cm,
		height: 1.1cm,
	)

	#set text(font: "New Computer Modern")

	// TODO: impleent the baseline skip
	// Author: 14pt 16pt
	#v(2.83cm)
	#text(size: 14pt)[
		#if type(author) == content [ #author ] else [ #author.join(", ") ]
	]


	// TODO set only for title
	#set par(
		leading: 12pt, // \linespread{1.2}
	)
	// TODO: this text is smaller than in the template!
	// Author: 16pt 20pt
	#v(1.15cm)
	#box(width: 100%, height: 3cm)[
		#par(leading: 12.5pt)[
			#text(size: 17pt)[
				*#title*
			]
		]
	]

	#set par(spacing: 0.80em)

	#v(5.05cm)
	#text(size: 12pt)[*MASTER'S THESIS*]

	#par[
		to achieve the university degree of

		Diplom-Ingenieur(in)

		Master's degree programme: #curriculum
	]

	#v(1.15cm)

	#text(size: 10pt)[
		submitted to
	]

	#v(0.1cm)

	#text(size: 12pt)[
		*Graz University of Technology*
	]

	#v(1.23cm)

	// Display Supervisor/Supervisors text dynamically
	#text(size: 10pt)[
		#if supervisors.len() <= 1 [ *Supervisor* ] else [ *Supervisors* ]
	]

	#v(0.05cm)

	// Display suppervisors dynamically
	#box(width: 100%, height: 0.81cm)[
		#set text(size: 10pt)
		#for sup in supervisors [
			#if type(sup) == content [ #sup ] else [ #sup.join(", ") ]
			#parbreak()
		]
	]

	#v(0.14cm)

	#text(size: 10pt)[
		#institute
	]

	#v(1.51cm)

	#text(size: 8pt)[
		Graz, #date 
	]

	#pagebreak()
]

// vim:tabstop=2 softtabstop=2 shiftwidth=2 noexpandtab colorcolumn=81
