#assert.eq(sys.version, version(0, 12, 0), message: "this version of mephistypsteles only works for typst 0.12.0")

#let (pf: parse-flat, pm: parse-markup, oi: operator-info) = {
	let p = plugin("./mephi.wasm")

	(
		pf: s => eval(str(p.parse_flat(bytes(s)))),
		pm: s => eval(str(p.parse_markup(bytes(s)))),
		oi: s => eval(str(p.parse_operator(bytes(s)))),
	)
}