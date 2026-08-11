#set page(width: 12cm, height: auto)

#import "@preview/hallon:0.1.3" as hallon: subfigure

// Apply subfigure styles.
#show: hallon.style-figures

// Use short supplement for figures and subfigures.
//
// NOTE: place after `hallon.style-subfig` show rule for supplement of
// "subfigure" kind to take effect.
#show figure.where(kind: image): set figure(supplement: "Fig.")
#show figure.where(kind: image): set figure.caption(separator: [. ])

// Highlight links.
#show link: set text(fill: blue)
#show ref: set text(fill: blue)

// === [ subfigure example ] ===================================================

#let example-fig = rect(fill: aqua)

= Subfigure example

See @fig1-example, @subfig1-example-foo, @subfig1-example-bar and @subfig1-example-baz.

#figure(
	grid(
		columns: 3,
		gutter: 1.5em,
		subfigure(
			example-fig,
			caption: [foo],
			label: <subfig1-example-foo>,
		),
		subfigure(
			example-fig,
			caption: [bar],
			label: <subfig1-example-bar>,
		),
		subfigure(
			example-fig,
			caption: [baz],
			label: <subfig1-example-baz>,
		),
	),
	gap: 1em,
	caption: lorem(5),
) <fig1-example>

See @fig2-example, @subfig2-example-foo, @subfig2-example-bar and @subfig2-example-baz.

#figure(
	grid(
		columns: 3,
		gutter: 1.5em,
		subfigure(
			example-fig,
			caption: [foo],
			label: <subfig2-example-foo>,
		),
		subfigure(
			example-fig,
			caption: [bar],
			label: <subfig2-example-bar>,
		),
		subfigure(
			example-fig,
			caption: [baz],
			label: <subfig2-example-baz>,
		),
	),
	gap: 1em,
	caption: lorem(5),
) <fig2-example>

// === [ subtable example ] ====================================================

#let example-tbl = table(
	columns: 2,
	stroke: 0.3pt,
	table.header[*foo*][*bar*],
	[a], [b],
	[a], [b],
)

= Subtable example

See @tbl1-example, @subtbl1-example-foo, @subtbl1-example-bar and @subtbl1-example-baz.

#figure(
	grid(
		columns: 3,
		gutter: 1.5em,
		subfigure(
			example-tbl,
			caption: [foo],
			label: <subtbl1-example-foo>,
		),
		subfigure(
			example-tbl,
			caption: [bar],
			label: <subtbl1-example-bar>,
		),
		subfigure(
			example-tbl,
			caption: [baz],
			label: <subtbl1-example-baz>,
		),
	),
	gap: 1em,
	caption: lorem(5),
) <tbl1-example>

See @tbl2-example, @subtbl2-example-foo, @subtbl2-example-bar and @subtbl2-example-baz.

#figure(
	grid(
		columns: 3,
		gutter: 1.5em,
		subfigure(
			example-tbl,
			caption: [foo],
			label: <subtbl2-example-foo>,
		),
		subfigure(
			example-tbl,
			caption: [bar],
			label: <subtbl2-example-bar>,
		),
		subfigure(
			example-tbl,
			caption: [baz],
			label: <subtbl2-example-baz>,
		),
	),
	gap: 1em,
	caption: lorem(5),
) <tbl2-example>

// === [ sublisting example ] ==================================================

#let example-lst = ```python
print('foo')
```

= Sublisting example

See @lst1-example, @lst1-example-foo, @lst1-example-bar and @lst1-example-baz.

#figure(
	grid(
		columns: 3,
		gutter: 1.5em,
		subfigure(
			example-lst,
			caption: [foo],
			label: <lst1-example-foo>,
		),
		subfigure(
			example-lst,
			caption: [bar],
			label: <lst1-example-bar>,
		),
		subfigure(
			example-lst,
			caption: [baz],
			label: <lst1-example-baz>,
		),
	),
	gap: 1em,
	caption: lorem(5),
) <lst1-example>

See @lst2-example, @lst2-example-foo, @lst2-example-bar and @lst2-example-baz.

#figure(
	grid(
		columns: 3,
		gutter: 1.5em,
		subfigure(
			example-lst,
			caption: [foo],
			label: <lst2-example-foo>,
		),
		subfigure(
			example-lst,
			caption: [bar],
			label: <lst2-example-bar>,
		),
		subfigure(
			example-lst,
			caption: [baz],
			label: <lst2-example-baz>,
		),
	),
	gap: 1em,
	caption: lorem(5),
) <lst2-example>
