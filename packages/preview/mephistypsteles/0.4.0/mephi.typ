#let (parse, public-api, operator-info) = {
	let p = plugin("./mephi.wasm")

	(
		parse: (s, concrete: false) => {
			assert.eq(type(s), str, message: "positional argument has to be a string")
			assert.eq(type(concrete), bool, message: "`concrete` has to be a boolean")
			let cfg = 0
			if concrete {
				cfg = cfg.bit-or(1)
			}
			eval(str(p.parse(bytes(s), bytes((cfg,)))))
		},
		public-api: s => {
			assert.eq(type(s), str, message: "positional argument has to be a string")
			eval(str(p.public_api(bytes(s))))
		},
		operator-info: s => {
			assert.eq(type(s), str, message: "positional argument has to be a string")
			eval(str(p.operator_info(bytes(s))))
		},
	)
}
