#import "@preview/cob-unofficial:0.1.0" as cob

#show: cob.template.with(
	title:   "Paper Title",
	authors: ("John Doe", "Jane Rue"),
	//article-id:   "123456",
	//article-year: datetime.today().year(), // Copyright year.
	//date:         datetime.today(),        // Received date.
)

// === [ Introduction ] ========================================================

= Introduction

#lorem(30) @takahashi2006induction

// === [ Methods ] =============================================================

= Methods

#lorem(15)#footnote[#lorem(10)]

// === [ Results ] =============================================================

= Results

#lorem(45)

#figure(
	table(
		columns: 3,
		table.hline(),
		table.header[*foo*][*bar*][*baz*],
		table.hline(),
		[a], [b], [c],
		[a], [b], [c],
		[a], [b], [c],
		table.hline(),
	),
	caption: lorem(5),
)

// === [ Discussion ] ==========================================================

= Discussion

#lorem(25)

// === [ Backmatter ] ==========================================================

#cob.data-availability[Data used in this study is available at #link("https://osf.io/xxx").]

#cob.code-availability[Code used in this study is available at #link("https://github.com/xxx").]

// === [ Bibliography ] ========================================================

#bibliography("references.bib")
