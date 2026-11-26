#import "@preview/groove:0.1.0": template, highlight-text, abstract, appendices
#import "/front_page.typ": frontpage

#show: template.with(
	title:   "Report Title",
	authors: ("John Doe", "Jane Rue"),
)

// === [ Front page ] ==========================================================

#let report-type = "Research Proposal"

#frontpage(
	report-type: report-type,
	supervisor: (
		//role: "Project Supervisor",
		name: "John Smith",
		affiliation: [
			Department of Foo \
			Foo University
		],
	),
	//logo: image("/inc/logo.pdf", width: 4cm),
)
#pagebreak(weak: true)

// === [ Table of Contents ] ===================================================

#set page(
	header: align(left)[#highlight-text(size: 8pt)[#report-type]],
)

#outline(title: "Table of Contents")
#pagebreak(weak: true)

// === [ Title ] ===============================================================

#set page(
	numbering: "1 / 1",
)
#counter(page).update(1) // reset page numbering

#pad(x: 20%)[
	#set align(center)
	#title()
]

// === [ Abstract ] ============================================================

#abstract(
	keywords: ("stem cell", "Yamanaka factors"),
)[
	#lorem(30)
]

// === [ Introduction ] ========================================================

= Introduction

#lorem(10)

== Research problem

#lorem(25)

== Rationale

#lorem(5)

== Background

#lorem(10) @2006_induced_pluripotent_stem_cells_yamanaka

== Hypothesis

#lorem(20)

== Aims

#lorem(10)

// === [ Experimental design ] =================================================

= Experimental design

#lorem(25)

As seen in @app-figures, #lorem(5)

== Limitations

#lorem(5)

// === [ Significance of the study ] ===========================================

= Significance of the study

#lorem(10)

// === [ Ethical considerations ] ==============================================

= Ethical considerations

#lorem(10)

// === [ Conclusions ] =========================================================

= Conclusions

#lorem(10)

// === [ References ] ==========================================================

#pagebreak(weak: true)

#[
	#set page(columns: 2)

	#heading(numbering: none)[References]

	#set text(size: 10pt)

	#bibliography("references.bib", title: none)
]

// === [ Appendices ] ==========================================================

#pagebreak(weak: true)

#set page(
	header: align(left)[#highlight-text(size: 8pt)[Appendices]],
)

#show: appendices

== Supplementary Figures
<app-figures>

#figure(
	rect(fill: aqua),
	caption: lorem(10),
) <fig-foo>
