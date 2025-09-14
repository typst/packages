#import "@preview/cetz:0.4.1": *

// Render graph as lines and rectangles,
#let render-layout(graph) = {
	canvas({
		import draw: *
		rect((0, 0), (graph.width, graph.height), stroke: red)
		for n in graph.nodes {
			let tx = n.x - n.width / 2
			let ty = n.y - n.height / 2
			let bx = n.x + n.width / 2
			let by = n.y + n.height / 2
			rect((tx, ty), (bx, by), stroke: blue)
			if n.xlabel != none {
				let ltx = n.xlabel.x - n.xlabel.width / 2
				let lty = n.xlabel.y - n.xlabel.height / 2
				let rtx = n.xlabel.x + n.xlabel.width / 2
				let rty = lty + n.xlabel.height
				rect((ltx, lty), (rtx, rty), stroke: green)
			}
		}
		for e in graph.edges {
			let control-points = for p in e.points { ((p.x, p.y),) }
			line(..control-points, stroke: gray)
			if e.xlabel != none {
				let ltx = e.xlabel.x - e.xlabel.width / 2
				let lty = e.xlabel.y - e.xlabel.height / 2
				let rtx = e.xlabel.x + e.xlabel.width / 2
				let rty = lty + e.xlabel.height
				rect((ltx, lty), (rtx, rty), stroke: orange)
			}
			if e.headlabel != none {
				let ltx = e.headlabel.x - e.headlabel.width / 2
				let lty = e.headlabel.y - e.headlabel.height / 2
				let rtx = e.headlabel.x + e.headlabel.width / 2
				let rty = lty + e.headlabel.height
				rect((ltx, lty), (rtx, rty), stroke: purple)
			}
			if e.taillabel != none {
				let ltx = e.taillabel.x - e.taillabel.width / 2
				let lty = e.taillabel.y - e.taillabel.height / 2
				let rtx = e.taillabel.x + e.taillabel.width / 2
				let rty = lty + e.taillabel.height
				rect((ltx, lty), (rtx, rty), stroke: rgb("#6d3c0b") )
			}
		}
	})
}