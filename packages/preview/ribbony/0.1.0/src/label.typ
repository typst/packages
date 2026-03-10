#import "@preview/cetz:0.4.2"

/*
Label drawers
*/

#let default-linear-label-drawer = (
	snap: auto,
	offset: auto, // auto | (x, y)
	width-limit: auto, // auto | false | value,
	styles: (
		inset: 0.2em,
		fill: white.transparentize(50%),
		radius: 2pt
	),
	draw-content: (properties, formatter: (val) => val) => [
		#set par(leading: 0.5em)
		#text(properties.name, size: 0.8em) \
		#text(str(formatter(properties.size)), size: 1em)
	],
	formatter: (val) => val
) => {
	(
		node-name,
		properties,
		layer-gap: none,
		vertical-layout: false,
		..args
	) => {
		import cetz.draw: *

		let _snap = snap

		let snap = if (_snap == auto) {
			if (vertical-layout) { bottom } else { right }
		} else {
			_snap
		}

		assert(snap in (left, right, top, bottom, center), message: "Invalid snap value: " + repr(snap))
		assert((snap in (left, right) and not vertical-layout) or
			   (snap in (top, bottom) and vertical-layout) or
			   (snap == center),
			   message: "Snap value " + repr(snap) + " is incompatible with layout direction")

		let rel = if (offset != auto) { offset } else {
			if (snap in (right, bottom)) {
				(0.05, 0)
			} else if (snap in (left, top)) {
				(-0.05, 0)
			} else {
				(0, 0)
			}
		}

		let (content-anchor, rel-to-anchor) = if (snap == left) { ("east", "west") }
			else if (snap == right) { ("west", "east") }
			else if (snap == top) { ("south", "west") }
			else if (snap == bottom) { ("north", "east") }
			else { ("center", "center") }

		let outer-box-width = if (width-limit == auto) {
			if (layer-gap != none) {
				layer-gap * 0.95cm
			} else { auto }
		} else if (width-limit == false) {
			auto
		} else {
			width-limit
		}
		let outer-box-constraints = if (vertical-layout) {
			(width: auto, height: outer-box-width)
		} else {
			(width: outer-box-width, height: auto)
		}

		content(
			anchor: content-anchor, (rel: rel, to: node-name + "." + rel-to-anchor),
			box(..outer-box-constraints)[
				#set align(
					if (snap == right) { left }
					else if (snap == left) { right }
					else { center } +
					if (snap == top) { bottom }
					else if (snap == bottom) { top }
					else { horizon }
				)
				#box(..styles)[
					#draw-content(properties, formatter: formatter)
				]
			]
		)
	}
}


#let default-circular-label-drawer = (
	offset: 0.2,
	styles: (
		inset: 0.2em,
		fill: white.transparentize(50%),
		radius: 2pt
	),
	draw-content: (properties, formatter: (val) => val) => [
		#set par(leading: 0.5em)
		#text(properties.name, size: 0.8em) \
		#text(str(formatter(properties.size)), size: 1em)
        // #text(repr(properties))
	],
	formatter: (val) => val
) => {
	(
		node-name,
		properties,
		radius: 4,
		node-width: 0.5,
		directed: false,
		..args
	) => {
		import cetz.draw: *

		set-transform(cetz.matrix.mul-mat(
				cetz.matrix.transform-rotate-z(-properties.angle + 90deg),
				cetz.matrix.transform-scale((1, -1))
		))
	
		content(
			anchor: "center", (rel: (0, offset), to: (0, radius + node-width)),
			box()[
				#set align(center + horizon)
				#box(..styles)[
					#draw-content(properties, formatter: formatter)
				]
			]
		)
        
		set-transform(cetz.matrix.mul-mat(
				cetz.matrix.transform-scale((1, -1))
		))
	}
}
