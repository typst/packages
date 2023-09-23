#let plugin = plugin("diagraph.wasm")

#let render(text, engine: "dot", width: auto, height: auto, fit: "contain") = {
	if text.len() != bytes(text).len() {
		return raw("error: text must be utf-8 encoded")
	}

	// add null terminator
	let encodedText = bytes(text) + bytes((0,))
	let encodedEngine = bytes(engine) + bytes((0,))

	let render = str(
		plugin.render(encodedText, encodedEngine)
	)


	if render.slice(0, 6) == "error:" {
		return raw(render)
	} else {
		return image.decode(
			render,
			format: "svg",
			height: height,
			width: width,
			fit: fit,
		)
	}
}

#let raw-render(engine: "dot", width: auto, height: auto, fit: "contain", raw) = {
	if (not raw.has("text")) {
		panic("This function requires a `text` field")
	}
	let text = raw.text
	return render(text, engine: engine, width: width, height: height, fit: fit)
}

#let raw-dotrender-rule(
		engine: "dot",
		width: auto, 
		height: auto, 
		fit: "contain",
		doc
	) = {
	
	show raw.where(lang: "dotrender"): it => {
		let text = it.text
		return render(text, engine: engine, width: width, height: height, fit: fit)
	}

	doc
}

