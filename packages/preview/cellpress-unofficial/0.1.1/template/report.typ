#import "@preview/cellpress-unofficial:0.1.1" as cellpress

#show: cellpress.template.with(
	journal:    "Neuron",  // "Cell Reports"
	supertitle: "Article", // "Resource"
	title:      "Paper Title",
	authors:    ("John Doe", "Jane Rue"),
	//doi:      "10.1016/j.cell.2006.07.024",
)

// === [ Summary ] =============================================================

#cellpress.summary[
	#lorem(30)
]

// === [ Introduction ] ========================================================

= Introduction

#lorem(30) @takahashi2006induction

// === [ Results ] =============================================================

= Results

#lorem(45)

As seen in @tbl-foo ...

#figure(
	caption: lorem(5),
	table(
		columns: 3,
		cellpress.toprule(),
		table.header[*foo*][*bar*][*baz*],
		cellpress.midrule(),
		[a], [b], [c],
		[a], [b], [c],
		[a], [b], [c],
		cellpress.bottomrule(),
	),
) <tbl-foo>

// === [ Discussion ] ==========================================================

= Discussion

#lorem(25)

// === [ Bibliography ] ========================================================

#bibliography("references.bib")

// === [ Methods ] =============================================================

#set page(columns: 1)

= Methods

#lorem(15)
