// Compile with PPI=300
#set page(height: auto, width: 90em, margin: 3cm)
#let content = read("showcase.typ").split("\n\n").slice(1).join("\n\n")
#set align(center + horizon)
#show grid.cell: set align(left)
#set grid(columns: 3, gutter: 1cm)
#block(fill: luma(95%), outset: 6pt, radius: 3pt, raw(content, block: true, lang: "typst"))
#let alert(text) = align(center + horizon, block(fill: red.mix(white), stroke: red + 2pt, inset: 3pt, radius: 4pt, text))

#import "@preview/mephistypsteles:0.4.0": *

#grid[
	#let newton = `$ F = m a $`.text
	#parse(newton)
][
	#let accidental-double-whitespace = `[Lorem ipsum dolor  sit amet]`.text
	#if parse(accidental-double-whitespace, concrete: true).children.any(it => it.kind == "space" and it.text.find("  ") != none) {
		alert[You accidentally inserted a double space!!]
	}
][
	#let my-module = ```typst
	/// Greet the reader
	#let say-hello() = {
		[Hello, dear Reader]
	}

	/// A controversial answer
	#let is-water-wet = true
	```.text

	#public-api(my-module)
]