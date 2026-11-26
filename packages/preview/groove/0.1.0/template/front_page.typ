#import "@preview/groove:0.1.0": highlight-text

// frontpage displays the front page of the report.
#let frontpage(
	report-type: none,
	supervisor:  none,
	logo:        none,
) = {
	set page(
		header: align(left)[#highlight-text(size: 16pt)[#report-type]],
		background: place(bottom+right, dx: -1cm, dy: -1cm)[#logo],
	)

	// --- [ Title ] ------------------------------------------------------------

	v(5cm)

	pad(x: 5%)[
		#set align(center)
		#show title: set text(size: 30pt)
		#title()
	]

	// --- [ Authors and supervisor ] -------------------------------------------

	v(3cm)

	pad(x: 15%)[
		#set align(left)

		// ~~~ [ Authors ] ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		#let authors = context document.author.join(", ", last: " and ")
		#highlight-text[Author]
		#v(-3pt)
		#text(size: 14pt, weight: "bold")[#authors]

		// ~~~ [ Supervisor ] ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		#if supervisor != none {
			v(1cm)

			let role = "Supervisor"
			if "role" in supervisor {
				role = supervisor.role
			}
			highlight-text[#role]
			v(-3pt)
			text(size: 14pt, weight: "bold")[#supervisor.name]
			if "affiliation" in supervisor {
				linebreak()
				text(size: 12pt, style: "italic", fill: rgb("#444444"))[#supervisor.affiliation]
			}
		}
	]
}
