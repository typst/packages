#let plugin = plugin("diagraph.wasm")

#let render(text, engine: "dot", width: auto, height: auto, fit: "contain", background: "transparent") = {
	let render = plugin.render(
		bytes(text), 
		bytes(engine), 
		bytes(background)
	)

	if render.at(0) == 1 {
		return raw(str(render.slice(1)))
	}

	if render.at(0) != 0 {
		panic("First byte of render result must be 0 or 1")
	}

	let integer_size = render.at(1)

	if width != auto or height != auto {
		return image.decode(
			render.slice(2 + integer_size * 2),
			format: "svg",
			height: height,
			width: width,
			fit: fit,
		)
	}

	/// Decodes a big-endian integer from the given bytes.
	let big-endian-decode(bytes) = {
		let result = 0
		for byte in array(bytes) {
			result = result * 256
			result = result + byte
		}
		return result
	}

	/// Returns a `(width, height)` pair corresponding to the dimensions of the SVG stored in the bytes.
	let get-svg-dimensions(svg) = {
	  let point_width = big-endian-decode(render.slice(2, integer_size + 2)) * 1pt
	  let point_height = big-endian-decode(render.slice(integer_size + 3, integer_size * 2 + 2)) * 1pt
		return (point_width, point_height)
	}

	let initial-dimensions = get-svg-dimensions(render)

	let svg-text-size = 14pt // Default font size in Graphviz
	style(styles => {
		let document-text-size = measure(line(length: 1em), styles).width
		let (auto-width, auto-height) = initial-dimensions.map(dimension => {
			dimension / svg-text-size * document-text-size
		})

		let final-width = if width == auto { auto-width } else { width }
		let final-height = if height == auto { auto-height } else { height }

		return image.decode(
			render.slice(2 + integer_size * 2),
			format: "svg",
			width: final-width,
			height: final-height,
			fit: fit,
		)
	})
}

#let raw-render(engine: "dot", width: auto, height: auto, fit: "contain", background: "transparent", raw) = {
	if (not raw.has("text")) {
		panic("This function requires a `text` field")
	}
	let text = raw.text
	return render(text, engine: engine, width: width, height: height, fit: fit, background: background)
}
