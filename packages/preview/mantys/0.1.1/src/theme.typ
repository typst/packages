
#let page = (
  paper: "a4",
	margin: auto
)


#let fonts = (
  serif: ("Linux Libertine", "Liberation Serif"),
  sans: ("Liberation Sans", "Helvetica Neue", "Helvetica"),
  mono: ("Liberation Mono"),

  text: ("Linux Libertine", "Liberation Serif"),
  headings: ("Liberation Sans", "Helvetica Neue", "Helvetica"),
  code: ("Liberation Mono")
)

#let font-sizes = (
  text: 12pt,
  headings: 12pt,   // Used as a base size, scaled by heading level
  code: 9pt
)


#let colors = (
	primary:   eastern,   // rgb(31, 158, 173),
	secondary: teal,      // rgb(18, 120, 133),
	argument:  navy,      // rgb(0, 29, 87),
	option:    rgb(214, 182, 93),
	value:     rgb(181, 2, 86),
	command:   blue,      // rgb(75, 105, 197),
	comment:   gray,      // rgb(128, 128, 128),
  module:    rgb("#8c3fb2"),

  text:      rgb(35, 31, 32),
  muted:     luma(210),

	info:      rgb(23, 162, 184),
	warning:   rgb(255, 193, 7),
	error:     rgb(220, 53, 69),
	success:   rgb(40, 167, 69),

  // Datatypes taken from typst.app
	dtypes: (
		length: rgb(230, 218, 255),
		integer: rgb(230, 218, 255),
		float: rgb(230, 218, 255),
		fraction: rgb(230, 218, 255),
		ratio: rgb(230, 218, 255),
		relative: rgb(230, 218, 255),
		"relative length": rgb(230, 218, 255),
    angle: rgb(230, 218, 255),
		"none": rgb(255, 203, 195),
		"auto": rgb(255, 203, 195),
		"any": rgb(255, 203, 195),
		"regular expression": rgb(239, 240, 243),
		dictionary: rgb(239, 240, 243),
		array: rgb(239, 240, 243),
		stroke: rgb(239, 240, 243),
		location: rgb(239, 240, 243),
		alignment: rgb(239, 240, 243),
		"2d alignment": rgb(239, 240, 243),
		boolean: rgb(255, 236, 193),
		content: rgb(166, 235, 229),
		string: rgb(209, 255, 226),
		function: rgb(249, 223, 255),
    label: rgb(167, 234, 255),
    color: gradient.linear(..color.map.spectral, angle:180deg),
    gradient: gradient.linear(..color.map.spectral, angle:180deg),
		// color: (
		// 	rgb(133, 221, 244),
		// 	rgb(170, 251, 198),
		// 	rgb(214, 247, 160),
		// 	rgb(255, 243, 124),
		// 	rgb(255, 187, 147)
		// )
	)
)
