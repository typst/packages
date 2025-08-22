#set page(width: 12cm, height: auto)

#import "@preview/subpar:0.2.2"
#import "@preview/smartaref:0.1.0": cref, Cref

// Highlight links.
#show link: set text(fill: blue)
#show ref: set text(fill: blue)

// === [ subpar example ] ======================================================

#let example-fig = rect(fill: aqua)

= Subpar example

`ref`: See @fig-example, @subfig-example-foo and @subfig-example-bar.

// NOTE: incorrect reference. uses "1a" for @subfig-example-bar, should be "1b".
`cref`: See #cref[@fig-example @subfig-example-foo @subfig-example-bar].

`Cref`: #Cref[@fig-example @subfig-example-foo @subfig-example-bar] are ...

#subpar.grid(
	columns: 2,
	figure(
		example-fig,
		caption: [foo],
	), <subfig-example-foo>,
	figure(
		example-fig,
		caption: [bar],
	), <subfig-example-bar>,
	caption: lorem(5),
	label: <fig-example>,
)
