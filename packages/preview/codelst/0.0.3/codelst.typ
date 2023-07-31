
#let __c_lineno = counter("@codelst-lines")

#let codelst-count-blanks( line, char:"\t" ) = {
	let m = line.match(regex("^" + char + "+"))
	if m != none {
		return m.end
	} else {
		return 0
	}
}
#let codelst-add-blanks( line, spaces:4, gobble:0 ) = {
	if gobble in (none, false) { gobble = 0 }

	if line.len() > 0 {
		line =  line.slice(gobble)
	}

	return line.replace(regex("^\t+"), (m) => " " * (m.end * spaces))
}

#let sourcecode(
	line-numbers: true,
	numbers-format: "1",
	numbers-start: auto,
	numbers-side: left,
	numbers-style: (i) => i, // (i) => i.counter.display((no, ..args) => raw(str(no))),
	continue-numbering: false,

	gutter: 10pt,

	tab-indent: 4,
	gobble: auto,

	highlighted: (),
	highlight-color: rgb(234, 234,189),
	label-regex: regex("// <([a-z-]{3,})>$"),
	highlight-labels: false,

	showrange: none,
	showlines: false,

	code
) = {
	// Find first raw element in body
	if code.func() != raw {
		code = code.children.find((c) => c.func() == raw)
	}
	assert.ne(code, none, message: "Missing raw content.")

	let code-lang  = if code.has("lang") { code.lang } else { "plain" }
	let code-lines = code.text.split("\n")
	let line-count = code-lines.len()

	// Reduce lines to range
	if showrange != none {
		assert.eq(showrange.len(), 2)
		showrange = (
			calc.clamp(calc.min(..showrange), 1, line-count) - 1,
			calc.clamp(calc.max(..showrange), 1, line-count)
		)
		code-lines = code-lines.slice(..showrange)
		if numbers-start == auto {
			numbers-start = showrange.first() + 1
		}
	}
	// Trim blank lines at start and finish
	if not showlines {
		// FIXME: Also trims whitespace on non blank lines
		code-lines = code-lines.join("\n").trim(regex("\s")).split("\n")
		//code-lines = remove-blank-lines(code-lines)
	}

	// Number of lines and starting value
	line-count = code-lines.len()
	if numbers-start == auto {
		numbers-start = 1
	}

	// Get the amount of whitespace to gobble
	if gobble == auto {
		gobble = 9223372036854775807
		let _c = none
		for line in code-lines {
			if line.len() == 0 { continue }
			if not line.at(0) in (" ", "\t") {
				gobble = 0
			} else {
				if _c == none { _c = line.at(0) }
				gobble = calc.min(gobble, codelst-count-blanks(line, char:_c))
			}
			if gobble == 0 { break }
		}
	}

	// Convert tabs to spaces and remove unecessary whitespace
	code-lines = code-lines.map((line) => codelst-add-blanks(line, spaces:tab-indent, gobble:gobble))

	// Parse labels
	let labels = (:)
	for (i, line) in code-lines.enumerate() {
		let m = line.match(label-regex)
		if m != none {
			labels.insert(str(i), m.captures.at(0))
			code-lines.at(i) = line.replace(label-regex, "")
			if highlight-labels {
				highlighted.push(i + numbers-start)
			}
		}
	}

	// Create the rows for the grid holding the code
	let next-lineno() = [#__c_lineno.step()#__c_lineno.display(numbers-format)<lineno>]

	let grid-cont = ()
	for (i, line) in code-lines.enumerate() {
		if line-numbers and numbers-side == left {
			grid-cont.push(next-lineno())
		}

		i = str(i)
		if i in labels {
			grid-cont.push([#raw(lang:code-lang, block:true, line)#label(labels.at(i))])
		} else {
			grid-cont.push(raw(lang:code-lang, block:true, line))
		}

		if line-numbers and numbers-side == right {
			grid-cont.push(next-lineno())
		}
	}

	// Add a blank raw element, to allow use in figure
	raw("", lang:code-lang)
	// Create content table
	style(styles => [
		#show <lineno>: numbers-style
		#set align(left)
		#set par(justify:false)
		#if not continue-numbering { __c_lineno.update(numbers-start - 1) }

		#let ins = 0.3em
		#let lines-width = measure(raw(str(line-count)), styles).width + 2*ins

		#table(
			columns: if line-numbers {
				if numbers-side == left {(lines-width, 1fr)} else {(1fr, lines-width)}
			} else {
				1
			},
			column-gutter: gutter - 2*ins,
			//row-gutter: 0.85em,
			inset: ins,
			stroke: none,
			fill: (col, row) => {
				if row/2 + numbers-start in highlighted { highlight-color } else { none }
			},
			..grid-cont
		)
		<codelst>
	])
}

#let sourcefile( code, file:none, lang:auto, ..args ) = {
	if file != none and lang == auto {
		let m = file.match(regex("\.([a-z0-9]+)$"))
		if m != none {
			lang = m.captures.first()
		}
	} else if lang == "auto" {
		lang = "plain"
	}
	sourcecode( ..args, raw(code, lang:lang, block:true))
}

#let lineref( label, supplement:"line" ) = locate(loc => {
	let lines = query(selector(label), loc)
	assert.ne(lines, (), message: "Label <" + str(label) + "> does not exists.")
	[#supplement #__c_lineno.at(lines.first().location()).first()]
})

#let numbers-style( i ) = align(right, text(
	fill: luma(160),
	size: .8em,
	i
))

#let code-frame(
	fill:      luma(250),
	stroke:    1pt + luma(200),
	inset:	   (x: 5pt, y: 10pt),
	radius:    4pt,
	code
) = block(
	fill: fill,
	stroke: stroke,
	inset: inset,
	radius: radius,
	breakable: true,
	width: 100%,
	code
)

#let codelst-styles( body ) = {
	show <codelst>: code-frame
	show <lineno>: numbers-style
	show figure.where(kind: raw): set block(breakable: true)

	body
}
