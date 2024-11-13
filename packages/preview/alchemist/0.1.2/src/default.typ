#let default = (
  atom-sep: 3em,
	delta: 0.2em,
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
)