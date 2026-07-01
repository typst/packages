#let acronyms-page(acros) = context [
	#let acronym = acros.get()
	#if acronym != none [

		= Acronyms<sec:acronyms>

		#v(0.4cm)
		#context [
			#show grid: set block(above: 0cm, below: 0.5cm)
			
			#let pad = acronym.keys().map(a => {
										(measure(a).width).cm()
								  }).sorted().last() * 1cm

			#for a in acronym [
				#let acr = a.at(0)

				#let state-key = "acronym-state-" + acr
				#let locs = query(label(state-key))
				
				#let cmp = a.at(1).at(0)
				#grid(gutter: 0pt, columns: (1.4cm, pad, 0.4cm, 8.6cm, 0.65cm, auto),
					block[
						// Spacing
					],
					block[
						#acr
					],
					block[
						// Spacing
					],
					block[
						#cmp
					],
					block[

					],
					block[
							#if not (locs == none or locs == ()) [
								#locs.map(
									l => counter(page).at(l.location())).flatten().map(
										l => str(l)
									).join(", ")
							]
					],
				)
			]
		]
	]
]

// vim:tabstop=2 softtabstop=2 shiftwidth=2 noexpandtab colorcolumn=81
