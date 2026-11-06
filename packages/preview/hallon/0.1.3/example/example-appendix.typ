#set page(width: 12cm, height: auto)

#import "@preview/hallon:0.1.3" as hallon: subfigure

#show: hallon.style-figures.with(heading-levels: 1)

// === [ Main matter ] =========================================================

#set heading(numbering: "1.1")

#let example-fig = rect(fill: aqua)

See @fig1, @subfig1-foo and @subfig1-bar.

See @fig2, @subfig2-foo and @subfig2-bar.

See @fig3, @subfig3-foo and @subfig3-bar.

See @fig4, @subfig4-foo and @subfig4-bar.

See @fig-app1, @subfig-app1-foo and @subfig-app1-bar.

See @fig-app2, @subfig-app2-foo and @subfig-app2-bar.

See @fig-app3, @subfig-app3-foo and @subfig-app3-bar.

See @fig-app4, @subfig-app4-foo and @subfig-app4-bar.

= Section one

See @fig1, @subfig1-foo and @subfig1-bar.

See @fig2, @subfig2-foo and @subfig2-bar.

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

= Section two

See @fig3, @subfig3-foo and @subfig3-bar.

See @fig4, @subfig4-foo and @subfig4-bar.

#figure(
	grid(
		columns: 2,
		gutter: 1.5em,
		subfigure(
			example-fig,
			caption: [foo],
			label: <subfig3-foo>,
		),
		subfigure(
			example-fig,
			caption: [bar],
			label: <subfig3-bar>,
		),
	),
	gap: 1em,
	caption: lorem(5),
) <fig3>

#figure(
	grid(
		columns: 2,
		gutter: 1.5em,
		subfigure(
			example-fig,
			caption: [foo],
			label: <subfig4-foo>,
		),
		subfigure(
			example-fig,
			caption: [bar],
			label: <subfig4-bar>,
		),
	),
	gap: 1em,
	caption: lorem(5),
) <fig4>

// === [ Appendix example ] ====================================================

#set heading(numbering: "①.1")

#counter(heading).update(0) // reset heading counter for appendices.

= Appendix one

See @fig-app1, @subfig-app1-foo and @subfig-app1-bar.

See @fig-app2, @subfig-app2-foo and @subfig-app2-bar.

#figure(
	grid(
		columns: 2,
		gutter: 1.5em,
		subfigure(
			example-fig,
			caption: [foo],
			label: <subfig-app1-foo>,
		),
		subfigure(
			example-fig,
			caption: [bar],
			label: <subfig-app1-bar>,
		),
	),
	gap: 1em,
	caption: lorem(5),
) <fig-app1>

#figure(
	grid(
		columns: 2,
		gutter: 1.5em,
		subfigure(
			example-fig,
			caption: [foo],
			label: <subfig-app2-foo>,
		),
		subfigure(
			example-fig,
			caption: [bar],
			label: <subfig-app2-bar>,
		),
	),
	gap: 1em,
	caption: lorem(5),
) <fig-app2>

= Appendix two

See @fig-app3, @subfig-app3-foo and @subfig-app3-bar.

See @fig-app4, @subfig-app4-foo and @subfig-app4-bar.

#figure(
	grid(
		columns: 2,
		gutter: 1.5em,
		subfigure(
			example-fig,
			caption: [foo],
			label: <subfig-app3-foo>,
		),
		subfigure(
			example-fig,
			caption: [bar],
			label: <subfig-app3-bar>,
		),
	),
	gap: 1em,
	caption: lorem(5),
) <fig-app3>

#figure(
	grid(
		columns: 2,
		gutter: 1.5em,
		subfigure(
			example-fig,
			caption: [foo],
			label: <subfig-app4-foo>,
		),
		subfigure(
			example-fig,
			caption: [bar],
			label: <subfig-app4-bar>,
		),
	),
	gap: 1em,
	caption: lorem(5),
) <fig-app4>

See @fig1, @subfig1-foo and @subfig1-bar.

See @fig2, @subfig2-foo and @subfig2-bar.

See @fig3, @subfig3-foo and @subfig3-bar.

See @fig4, @subfig4-foo and @subfig4-bar.

See @fig-app1, @subfig-app1-foo and @subfig-app1-bar.

See @fig-app2, @subfig-app2-foo and @subfig-app2-bar.

See @fig-app3, @subfig-app3-foo and @subfig-app3-bar.

See @fig-app4, @subfig-app4-foo and @subfig-app4-bar.
