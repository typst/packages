#import "@preview/showybox:2.0.4"

// Fonts definition
#let mainfont = "Spectral"
#let sansfont = "Marianne"

// Colors definition
#let inerissemigreen   = rgb("#00AB8E")
#let inerissemiblue	= rgb("#003087")
#let inerissemiturq	= rgb("#1CA5D2")
#let inerissemipurple  = rgb("#8F6F95")
#let inerissemiorange  = rgb("#D87263")
#let palettea  = inerissemiblue
#let paletteb  = inerissemigreen
#let palettec  = inerissemiturq
#let paletted  = inerissemipurple
#let palettee  = inerissemiorange
#let palettela = palettea.lighten(40%)
#let palettelb = paletteb.lighten(40%)
#let palettelc = palettec.lighten(40%)
#let paletteld = paletted.lighten(40%)
#let paletteda = palettea.darken(30%)
#let palettedb = paletteb.darken(30%)
#let palettedc = palettec.darken(30%)
#let palettedd = paletted.darken(30%)

// Utility functions
#let to-string(content) = {
	if content.has("text") {
		content.text
	} else if content.has("children") {
		content.children.map(to-string).join("")
	} else if content.has("child") {
		to-string(content.child)
	} else if content.has("body") {
		to-string(content.body)
	} else {
		""
	}
}

#let format-number(value, decimal-separator: ",", thousands-separator: ".", decimal-precision: none) = {
	if decimal-precision != none {
		value = calc.round(value, digits: decimal-precision)
	}
	let tab = str(value).split(".")
	let s = tab.at(0)
	let groups = ()
	for i in range(s.len()-3, -3, step: -3) {
		groups.insert(0, s.slice(calc.max(i, 0), i+3))
	}
	s = groups.join(thousands-separator)
	let t = tab.at(1, default:"")
	if t == "" { s } else { s + decimal-separator + t }
}

// Extended table function
// This function has the same arguments as Typst tables, but you can add new named arguments.
//
// sum-row : when argument is given, an accumulated row is computed and added at the end of the table. The argument is a dictionary with the following values
//   - title : Content, title of the row
//   - text  : Dictionary, options added to text in the cells of the accumulated row
//   - cell  : Dictionary, options added to the cell of the accumulated row
//   - formatter : Function ( float ) => Content ; the function is applied to the accumulated value to display it on the last row. If no function is given, the value is displayed as is.
//   - accumulator : Dictionary (init: any, update: Function ( Content ) => any) ; the function is an accumulator applied on each value in the column. If not set, a sum is computed.
//
// sum-column : when argument is given, an accumulated column is computed and added at the end of the table. The argument is a dictionary with the following values
//   - title : Content, title of the column
//   - text  : Dictionary, options added to text in the cells of the accumulated column
//   - cell  : Dictionary, options added to the cell of the accumulated column
//   - formatter : Function ( float ) => Content ; the function is applied to the accumulated value to display it on the last column. If no function is given, the value is displayed as is.
//   - accumulator : Dictionary (init: any, update: Function ( Content ) => any) ; the function is an accumulator applied on each value in the row. If not set, a sum is computed.
#let tablex(..args)={
	let named = args.named()
	let pos = args.pos()
	let cols = if type(named.at("columns", default: 0))==int { named.at("columns") } else { named.at("columns").len() }

	// Default accumulator
	let sum-accumulator = (
		init: 0.0,
		update: (content,value) => {
			let cell = to-string(content).replace(regex("^\D*"),"").replace(regex("\D*$"),"").replace(".","").replace(",",".")
			if cell.len()>0 { value + float(cell) } else { value }
		}
	)

	// Compute sum column if any is needed
	let scopt = named.remove("sum-column", default: none)
	if scopt != none {
		let i = 0
		let accum = scopt.at("accumulator", default: sum-accumulator)
		let first = true
		while i < pos.len() {
			let tot = accum.at("init")
			let j = 0
			while j < cols {
				if type(pos.at(i)) == content {
				  j = j + 1
				  tot = accum.at("update")(pos.at(i), tot)
				}
				i = i + 1
			}
			if first {
				first = false
				pos.insert(i, table.cell(..scopt.at("cell", default: ()), text(..scopt.at("text", default: ()), scopt.at("title"))))
			} else {
				let scvalue = if scopt.at("formatter", default: none)==none [#tot] else {scopt.at("formatter")(tot)}
				pos.insert(i, table.cell(..scopt.at("cell", default: ()), text(..scopt.at("text", default: ()), scvalue)))
			}
			i = i + 1
		}
		cols = cols + 1
		if type(named.at("columns", default: 0))==int {
			named.at("columns") = cols
		} else {
			named.at("columns").push(auto)
		}
	}

	// Compute sum row if any is needed
	let sropt = named.remove("sum-row", default: none)
	if sropt != none {
		let accum = sropt.at("accumulator", default: sum-accumulator)
		pos.push(table.cell(..sropt.at("cell", default: ()), text(..sropt.at("text", default: ()), sropt.at("title"))))
		for i in range(1, cols) {
			let j = i
			let tot = accum.at("init")
			while j < pos.len() {
				tot = accum.at("update")(pos.at(j), tot)
				let k = 1
				while k <= cols and j < pos.len() {
				  if type(pos.at(j))==content {
					k = k + 1
				  }
				  j = j + 1
				}
			}
			let srvalue = if sropt.at("formatter", default: none)==none [#tot] else {sropt.at("formatter")(tot)}
			pos.push(table.cell(..sropt.at("cell", default: ()), text(..sropt.at("text", default: ()), srvalue)))
		}
	}

	// Typeset the table
	table(
		..named,
		..pos,
	)
}

// Blocks
#let myblock(mytitle,..args)={
	showybox.showybox(
		frame:(
			border-color: palettea,
			title-color: white,
			body-color: palettela.lighten(80%),
			width: 0.75pt,
		),
		title-style:(
			weight: "bold",
			boxed-style: (:),
			color: palettea,
		),
		sep: (dash: none),
		shadow: (offset: 3pt),
		breakable: true,
		title: mytitle,
		..args
	)
}

#let _conf(doc) = {
	// Main styling
	set text(font: (mainfont, "Libertinus Serif"), size: 10pt, lang: "fr", region: "FR")
	set par(justify: true)
	show strong: set text(weight: "bold", fill: palettea)

	// Page
	set page(
		margin:(bottom: 6%, top: 8%, left: 10%, right: 10%),
	)

	// Lists
	set list(
		indent: 1em,
		tight: false,
		marker: ([--],[#sym.circle.filled],[#sym.star.filled]),
	)
	set enum(
		indent: 1em,
		tight: false,
		numbering: n=>[#n.],
	)

	// Headings
	set heading(numbering: "1.1.1.1 ")
	set par(spacing: 1.5em)
	show heading.where(level:1): it => block(width: 100%, above: 2em, below: 1em)[
		#set text(size: 1.4em, weight: "bold")
		#smallcaps(it)
		#v(0.1em)
	]
	show heading.where(level:2): it => block(width: 100%, above: 2em, below: 1em)[
		#set text(size: 1.2em, weight: "bold")
		#smallcaps(it)
		#v(0.1em)
	]
	show heading.where(level:3): it => block(width: 100%, above: 2em, below: 1em)[
		#set text(weight: "bold")
		#it
		#v(0.1em)
	]

	// Tables
	let origtable = table
	show table.cell.where(y:0): set text(fill:white, weight:"bold")
	show table.where(fill: none): it => {
		align(center, origtable(
			fill: (_,y) => if (y==0) {paletteda} else if calc.odd(y) {palettela.lighten(50%)} else {none},
			stroke: (_,y) => if (y==0) {(right: 0.1pt + paletteda)} else if calc.odd(y) {(right: 0.1pt + palettela.lighten(50%))} else {none},
			align: horizon,
			rows: auto,
			..for (k, v) in it.fields() {
				if k not in ("children", "fill", "stroke", "align", "rows") {(
					(k): v,
				)}
			},
			table.hline(stroke: palettea + 0.5pt),
			..it.children,
			table.hline(stroke: palettea + 0.5pt),
		))
	}

	doc
}
