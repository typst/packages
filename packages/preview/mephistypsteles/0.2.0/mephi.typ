#assert.eq(sys.version, version(0, 12, 0), message: "this version of mephistypsteles only works for typst 0.12.0")

#let (p: parse, oi: operator-info) = {
	let p = plugin("./mephi.wasm")

	(
		p: (s, flat: false) => {
			assert.eq(type(flat), bool, message: "`flat` has to be a boolean")
			let cfg = 0
			if flat {
				cfg = cfg.bit-or(1)
			}
			eval(str(p.parse(bytes(s), bytes((cfg,)))))
		},
		oi: s => eval(str(p.operator_info(bytes(s)))),
	)
}