#let (p: parse, oi: operator-info) = {
	let p = plugin("./mephi.wasm")

	(
		p: (s, flat: false) => {
			assert.eq(type(s), str, message: "positional argument has to be a string")
			assert.eq(type(flat), bool, message: "`flat` has to be a boolean")
			let cfg = 0
			if flat {
				cfg = cfg.bit-or(1)
			}
			eval(str(p.parse(bytes(s), bytes((cfg,)))))
		},
		oi: s => {
			assert.eq(type(s), str, message: "positional argument has to be a string")
			eval(str(p.operator_info(bytes(s))))
		},
	)
}