#set page(width: 12cm, height: auto)

#import "@preview/hallon:0.1.2" as hallon: subfigure

// Apply multi-level numbering for:
//
// - figures:    "{heading}.{figure}"              (e.g. "1.1")
// - subfigures: "{heading}.{figure}{subfigure}"   (e.g. "1.1a")
#show: hallon.style-figures.with(heading-levels: 1)

// Set heading numbering style.
#set heading(numbering: "1.1")

// Highlight links.
#show link: set text(fill: blue)
#show ref: set text(fill: blue)

// === [ subfigures example ] ==================================================

#let example-fig = rect(fill: aqua)

= Subfigures example

See @fig1, @subfig1-foo and @subfig1-bar.

#figure(
	grid(
		columns: 2,
		gutter: 1.5em,
		subfigure(
			example-fig,
			caption: [foo],
			label: <subfig1-foo>,
		),
		subfigure(
			example-fig,
			caption: [bar],
			label: <subfig1-bar>,
		),
	),
	gap: 1em,
	caption: lorem(5),
) <fig1>

See @fig2, @subfig2-foo and @subfig2-bar.

#figure(
	grid(
		columns: 2,
		gutter: 1.5em,
		subfigure(
			example-fig,
			caption: [foo],
			label: <subfig2-foo>,
		),
		subfigure(
			example-fig,
			caption: [bar],
			label: <subfig2-bar>,
		),
	),
	gap: 1em,
	caption: lorem(5),
) <fig2>

// === [ figure example ] ======================================================

= Figures example

See @fig-foo, @fig-bar and @fig-baz.

#figure(
	example-fig,
	caption: [foo],
) <fig-foo>

#figure(
	example-fig,
	caption: [bar],
) <fig-bar>

#figure(
	example-fig,
	caption: [baz],
) <fig-baz>

// === [ tables example ] ======================================================

// Position caption of tables on top.
#show figure.where(kind: table): set figure.caption(position: top)

#let example-table = table(
	columns: 2,
	stroke: 0.3pt,
	table.header[*asdf*][*qwerty*],
	[a], [b],
	[c], [d],
)

= Tables example

See @tbl-foo, @tbl-bar and @tbl-baz.

#figure(
	caption: [foo],
	example-table,
) <tbl-foo>

#figure(
	caption: [bar],
	example-table,
) <tbl-bar>

#figure(
	caption: [baz],
	example-table,
) <tbl-baz>

// === [ listings example ] ====================================================

// Position caption of listings on top.
#show figure.where(kind: raw): set figure.caption(position: top)

#let example-raw = ```typst
#set document(title: "meta")
```

= Listings example

See @lst-foo, @lst-bar and @lst-baz.

#figure(
	caption: [foo],
	example-raw,
) <lst-foo>

#figure(
	caption: [bar],
	example-raw,
) <lst-bar>

#figure(
	caption: [baz],
	example-raw,
) <lst-baz>
