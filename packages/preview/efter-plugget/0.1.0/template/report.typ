#import "@preview/efter-plugget:0.1.0"

#let todo = highlight

// hallon is an optional library for subfigures.
#import "@preview/hallon:0.1.2": subfigure
// cellpress is an optional library for Cell Press table style.
#import "@preview/cellpress-unofficial:0.1.0" as cellpress: toprule, midrule, bottomrule
// smartaref is an optional library for handling consecutive references.
#import "@preview/smartaref:0.1.0": cref, Cref

#show: efter-plugget.template.with(
	logo:              image("inc/logo.png"),
	title:             todo[Lab 1 -- Stem Cells],
	subtitle:          todo[An investigation into the effects of morphogens on differentiation],
	page-header-title: todo("Lab 1"),
	course-name:       todo("Course Name"),
	course-code:       todo("AA1234"),
	//course-part:     "",
	lab-name:          todo("Stem cell differentiation"),
	authors:           todo("Jane Rue"),
	lab-partners:      (todo("John Doe"), todo("Eve Smith")),
	//lab-supervisor:  "",
	lab-group:         todo("Group 1"),
	lab-date:          datetime.today().display(), // "2025-09-19"
)

#show: cellpress.style-table

// === [ quote ] ===============================================================

#quote(
	block: true,
	attribution: [anonymous],
)[
	#emph["Chemistry is all around us."]
]

// === [ Introduction ] ========================================================

= Introduction

#lorem(35)

== Purpose

#lorem(10)

== Theory

#lorem(10) @2020_molecular_biology_principles_of_genome_function_craig

#pagebreak(weak: true)

// === [ Methods ] =============================================================

= Methods

#lorem(10)

#pagebreak(weak: true)

// === [ Results ] =============================================================

= Results

#lorem(10)

As seen in #cref[@subfig-foo @subfig-bar] ...

#figure(
	grid(
		columns: 2,
		gutter: 1em,
		subfigure(
			rect(fill: aqua), // image("/inc/foo.png"),
			caption: lorem(3),
			label: <subfig-foo>
		),
		subfigure(
			rect(fill: teal), // image("/inc/bar.png"),
			caption: lorem(3),
			label: <subfig-bar>
		),
	),
	gap: 1em,
	caption: lorem(5),
) <fig-baz>

The results of the experiment are presented in @tbl-bar ...

#figure(
	caption: lorem(5),
	table(
		columns: 3,
		toprule(),
		table.header[*foo*][*bar*][*baz*],
		midrule(),
		[a], [b], [c],
		[a], [b], [c],
		[a], [b], [c],
		bottomrule(),
	),
) <tbl-bar>

#pagebreak(weak: true)

// === [ Discussion ] ==========================================================

= Discussion

#lorem(10)

#pagebreak(weak: true)

// === [ Bibliography ] ========================================================

#bibliography("references.bib")

#pagebreak(weak: true)
