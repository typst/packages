#let plugin = plugin("diagraph.wasm")

#let render(text, engine: "dot", width: auto, height: auto, fit: "contain", background: "transparent") = {
	let render = str(
		plugin.render(
			bytes(text), 
			bytes(engine), 
			bytes(background)
		)
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

#let raw-render(engine: "dot", width: auto, height: auto, fit: "contain", background: "transparent", raw) = {
	if (not raw.has("text")) {
		panic("This function requires a `text` field")
	}
	let text = raw.text
	return render(text, engine: engine, width: width, height: height, fit: fit, background: background)
}
