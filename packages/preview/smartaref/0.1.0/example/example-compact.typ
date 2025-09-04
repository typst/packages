#set page(width: 15cm, height: auto)

#import "@preview/smartaref:0.1.0"

#let cref = smartaref.cref.with(compact: true)
#let Cref = smartaref.Cref.with(compact: true)

// Highlight links.
#show link: set text(fill: blue)
#show ref: set text(fill: blue)

// Set heading numbering style.
#set heading(numbering: "1.1")

// === [ figure example ] ======================================================

#let example-fig = rect(fill: aqua)

= Figures example

// NOTE: skip fig-qux ("Figure 4") reference to showcase compat.
`ref`: See @fig-foo, @fig-bar, @fig-baz and @fig-foob.

#emph[`compact: false`] \
`cref`: See #cref(compact: false)[@fig-foo @fig-bar @fig-baz @fig-foob].

#emph[`compact: true`] \
`cref`: See #cref[@fig-foo @fig-bar @fig-baz @fig-foob].

#grid(
	columns: 5,
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
	[#figure(
		example-fig,
		caption: [foob],
	) <fig-foob>],
)

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

`ref`: See @tbl-foo, @tbl-bar and @tbl-baz.

#emph[`compact: false`] \
`cref`: See #cref(compact: false)[@tbl-foo @tbl-bar @tbl-baz].

#emph[`compact: true`] \
`cref`: See #cref[@tbl-foo @tbl-bar @tbl-baz].

#grid(
	columns: 3,
	gutter: 1.5em,
	[#figure(
		caption: [foo],
		example-table,
	) <tbl-foo>],
	[#figure(
		caption: [bar],
		example-table,
	) <tbl-bar>],
	[#figure(
		caption: [baz],
		example-table,
	) <tbl-baz>],
)

// === [ listings example ] ====================================================

// Position caption of listings on top.
#show figure.where(kind: raw): set figure.caption(position: top)

#let example-raw = ```typst
#set document(title: "meta")
```

= Listings example

`ref`: See @lst-foo, @lst-bar and @lst-baz.

#emph[`compact: false`] \
`cref`: See #cref(compact: false)[@lst-foo @lst-bar @lst-baz].

#emph[`compact: true`] \
`cref`: See #cref[@lst-foo @lst-bar @lst-baz].

#grid(
	columns: 2,
	gutter: 1.5em,
	[#figure(
		caption: [foo],
		example-raw,
	) <lst-foo>],
	[#figure(
		caption: [bar],
		example-raw,
	) <lst-bar>],
	[#figure(
		caption: [baz],
		example-raw,
	) <lst-baz>],
)

// === [ sections example ] ====================================================

= Sections example
<sec-sections-example>

`ref`: See @sec-sections-example, @sec-subsection-one, @sec-subsection-two and @sec-subsection-three.

#emph[`compact: false`] \
`cref`: See #cref(compact: false)[@sec-sections-example @sec-subsection-one @sec-subsection-two @sec-subsection-three].

#emph[`compact: true`] \
`cref`: See #cref[@sec-sections-example @sec-subsection-one @sec-subsection-two @sec-subsection-three].

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

`ref`: See @eq-pythagoras, @eq-eulers-identity and @eq-de-moivres-formula.

#emph[`compact: false`] \
`cref`: See #cref(compact: false)[@eq-pythagoras @eq-eulers-identity @eq-de-moivres-formula].

#emph[`compact: true`] \
`cref`: See #cref[@eq-pythagoras @eq-eulers-identity @eq-de-moivres-formula].

$ abs(z) = sqrt(x^2 + y^2) $ <eq-pythagoras>

$ e^(i pi) = -1 $ <eq-eulers-identity>

$ (cos x + i sin x)^n = cos(n x) + i sin(n x) $ <eq-de-moivres-formula>

// === [ footnotes example ] ===================================================

= Footnotes example

`ref`: See @foot-foo, @foot-bar, @foot-baz and @foot-qux.

#emph[`compact: false`] \
`cref`: See #cref(compact: false, supplement: "footnotes")[@foot-foo @foot-bar @foot-baz @foot-qux].

#emph[`compact: true`] \
`cref`: See #cref(supplement: "footnotes")[@foot-foo @foot-bar @foot-baz @foot-qux].

A few#footnote[foo]<foot-foo> footnotes#footnote[bar]<foot-bar> are present#footnote[baz]<foot-baz> in this sentence.#footnote[qux]<foot-qux>
