#set page(width: 12cm, height: auto)

#import "@preview/hallon:0.1.3" as hallon: subfigure

// custom caption style for figures.
#let custom-figure-caption(it, supplement: none) = context {
	let sup = it.supplement
	if supplement != none {
		sup = supplement
	}
	emph[#sup~#it.counter.display(it.numbering)#it.separator]
	[ ]
	it.body
}

// custom caption style for subfigures.
#let custom-subfigure-caption(it, parent: none) = context {
	let fig-nums = parent.counter.get()
	let sub-nums = it.counter.get()
	// figure
	strong(std.numbering("1a)", fig-nums.last(), sub-nums.last()))
	[ ]
	it.body
}

// Apply subfigure styles with custom captions.
#show: hallon.style-figures.with(
	figure-caption: custom-figure-caption.with(supplement: "Figure"),
	subfigure-caption: custom-subfigure-caption,
)

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
