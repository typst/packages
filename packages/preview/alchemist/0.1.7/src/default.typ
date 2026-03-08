#let default = (
  atom-sep: 3em,
	fragment-margin: 0.2em,
	fragment-font: none,
	fragment-color: none,
	link-over-radius: .2,
  angle-increment: 45deg,
  base-angle: 0deg,
	debug: false,
	single: (
		stroke: black
	),
	double: (
		gap: .25em,
		offset: "center",
		offset-coeff: 0.85,
		stroke: black
	),
	triple: (
		gap: .25em,
		stroke: black
	),
	filled-cram: (
		stroke: none,
		fill: black,
		base-length: .8em
	),
	dashed-cram: (
		stroke: black + .05em,
		dash-gap: .3em,
		base-length: .8em,
		tip-length: .1em
	),
	lewis: (
		angle: 0deg,
		radius: 0.2em,
	),
	lewis-single: (
		stroke: black,
		fill: black,
		radius: .1em,
		gap: .25em,
		offset: "top"
	),
	lewis-double: (
		stroke: black,
		fill: black,
		radius: .1em,
		gap: .25em,
	),
	lewis-line: (
		stroke: black,
		length: .7em,
	),
	lewis-rectangle: (
		stroke: .08em + black,
		fill: white,
		height: .7em,
		width: .3em
	)
)