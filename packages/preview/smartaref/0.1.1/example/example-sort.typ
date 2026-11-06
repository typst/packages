#set page(width: 15cm, height: auto)

#import "@preview/smartaref:0.1.1"

#let cref = smartaref.cref.with(sort: true)
#let Cref = smartaref.Cref.with(sort: true)

// Highlight links.
#show link: set text(fill: blue)
#show ref: set text(fill: blue)

// Set heading numbering style.
#set heading(numbering: "1.1")

// === [ figure example ] ======================================================

#let example-fig = rect(fill: aqua)

= Figures example

`ref`: See @fig-qux, @fig-foo, @fig-baz and @fig-bar.

#emph[`sort: false`] \
`cref`: See #cref(sort: false)[@fig-qux @fig-foo @fig-baz @fig-bar].

#emph[`sort: true`] \
`cref`: See #cref[@fig-qux @fig-foo @fig-baz @fig-bar].

#emph[`sort: true, compact: true`] \
`cref`: See #cref(compact: true)[@fig-qux @fig-foo @fig-baz @fig-bar].

#divider()

`ref`: See @fig-qux, @fig-foo and @fig-qux.

// NOTE: remove duplicate references, rather than putting them next to one another when sorting.
#emph[`sort: true` (duplicate references removed)] \
`cref`: See #cref[@fig-qux @fig-foo @fig-qux].

#grid(
	columns: 4,
	gutter: 1.5em,
	[#figure(
		example-fig,
		caption: [foo],
	) <fig-foo>],
	[#figure(
		example-fig,
		caption: [bar],
	) <fig-bar>],
	[#figure(
		example-fig,
		caption: [baz],
	) <fig-baz>],
	[#figure(
		example-fig,
		caption: [qux],
	) <fig-qux>],
)

// === [ sections example ] ====================================================

= Sections example
<sec-sections-example>

`ref`: See @sec-subsection-three, @sec-sections-example, @sec-subsection-two and @sec-subsection-one.

#emph[`sort: false`] \
`cref`: See #cref(sort: false)[@sec-subsection-three @sec-sections-example @sec-subsection-two @sec-subsection-one].

#emph[`sort: true`] \
`cref`: See #cref[@sec-subsection-three @sec-sections-example @sec-subsection-two @sec-subsection-one].

== Subsection one
<sec-subsection-one>

#lorem(10)

== Subsection two
<sec-subsection-two>

#lorem(15)

== Subsection three
<sec-subsection-three>

#lorem(20)

// === [ equations example ] ===================================================

// Set equation numbering style.
#set math.equation(numbering: "(1)")

= Equations example

`ref`: See @eq-de-moivres-formula, @eq-pythagoras and @eq-eulers-identity.

#emph[`sort: false`] \
`cref`: See #cref(sort: false)[@eq-de-moivres-formula @eq-pythagoras @eq-eulers-identity].

#emph[`sort: true`] \
`cref`: See #cref[@eq-de-moivres-formula @eq-pythagoras @eq-eulers-identity].

$ abs(z) = sqrt(x^2 + y^2) $ <eq-pythagoras>

$ e^(i pi) = -1 $ <eq-eulers-identity>

$ (cos x + i sin x)^n = cos(n x) + i sin(n x) $ <eq-de-moivres-formula>

// === [ appendices example ] ==================================================

= Appendices example

// NOTE: sorting compares the couter values, which are integers regardless of
// the numbering pattern used for rendering. Thus, alphabetic and roman
// numbering sort in the same order as decimal numbering.

`ref`: See @app-two, @app-one-c, @app-one and @app-one-b.

#emph[`sort: false`] \
`cref`: See #cref(sort: false)[@app-two @app-one-c @app-one @app-one-b].

#emph[`sort: true`] \
`cref`: See #cref[@app-two @app-one-c @app-one @app-one-b].

#divider()

`ref`: See @app-one-c, @app-one-a and @app-one-b.

#emph[`sort: true, compact: true`] \
`cref`: See #cref(compact: true)[@app-one-c @app-one-a @app-one-b].

#divider()

// NOTE: section counters are reset at the appendices, so "appendix A" and
// "section 1" share the numbering `(1,)`. References spanning such a counter
// reset interleave, since the sort is only based on the couter value. The label
// is used to ensure that distinct references sharing identical counter values
// are kept. Only true duplicates are removed.
`ref`: See @app-one-a, @sec-subsection-one, @app-two and @sec-sections-example.

#emph[`sort: true` (references spanning a counter reset)] \
`cref`: See #cref[@app-one-a @sec-subsection-one @app-two @sec-sections-example].

#counter(heading).update(0)
#set heading(numbering: "A.i")

= Appendix one
<app-one>

== Appendix subsection a
<app-one-a>

#lorem(10)

== Appendix subsection b
<app-one-b>

#lorem(10)

== Appendix subsection c
<app-one-c>

#lorem(10)

= Appendix two
<app-two>

#lorem(15)
