#let _exports = {
	let xorshift_plugin = plugin("xorshift_plugin.wasm")

	let to_le_bytes(n) = {
		// assumption: n is an unsigned integer

		let res = ()
		while n > 0 {
			res += (calc.rem(n, 256),)
			n = calc.quo(n, 256)
		}
		res
	}
	let from_le_bytes(b) = {
		let res = 0
		let mul = 1
		for byte in b {
			res += mul * byte
			mul *= 256
		}

		res
	}

	let gen_u32(seed, mod) = {
		assert(type(seed) == array, message: "seed needs to be an array")
		assert(seed.len() == 16, message: "seed needs to have length 16")
		for x in seed {
			assert(type(x) == int, message: "seed needs to consist of ints")
			assert(x >= 0, message: "seed components need to be non-negative")
			assert(x < 256, message: "seed components need to fit in 8 bits each")
		}
		assert(type(mod) == int, message: "mod needs to be an int")
		assert(mod >= 0, message: "mod needs to be non-negative")
		assert(mod < calc.pow(2, 32), message: "mod needs to fit into 32 bits")

		let seed = bytes(seed)
		let mod = bytes(to_le_bytes(mod))
		let res = xorshift_plugin.rand(seed, mod)
		let res = array(res)

		from_le_bytes(res)
	}

	let seed_from_int(n) = {
		assert(type(n) == int, message: "input needs to be an int")	

		// note: 251 is the largest prime < 256, so this mod-mult gives some VERY basic rng based on the number
		// (which can then be used as a seed for the real rng)
		(1, 210, 211, 230, 130, 206, 155, 111, 194, 201, 164, 92, 21, 219, 73, 169)
			.map(mult => calc.rem(mult * calc.rem(n, 251), 251))
	}

	let inc_seed(seed) = {
		let carry = 1
		for i in range(16) {
			let i = -1 - i

			seed.at(i) += carry
			carry = 0
			if seed.at(i) == 256 {
				seed.at(i) = 0
				carry = 1
			}
		}
		seed
	}

	let gen_index(seed, len, excluded) = {
		let leftover = range(len).filter(x => x not in excluded)
		if seed == none {
			(none, leftover.first())
		} else {
			let idx_idx = gen_u32(seed, leftover.len())
			let idx = leftover.at(idx_idx)
			(inc_seed(seed), idx)
		}
	}

	let fruits = "🍇🍒🍍🍋🍉🍎🥝🥥🍌🥭🫐🍊🫒🍅🍏🍐🍓🍈🍑".codepoints()

	let the-state = state("fruitify.state", (
		symbols: fruits,
		reuse: false,
		seed: none,
		used: (:),
	))

	let setup(..args) = {
		let _no_pos() = {}
		_no_pos(..args.pos())

		let args = args.named()
		the-state.update(st => {
			// note: this needs to happen BEFORE setting the `reuse` option
			// so that `used` DOES get cleared once when setting `reuse: true`
			// (it should only work into the future)
			if not st.reuse {
				st.used = (:)
			}

			// straight-forward arguments
			for k in ("symbols", "reuse") {
				if k in args {
					st.at(k) = args.at(k)
				}
			}

			if "random-seed" in args {
				let rs = args.random-seed
				st.at("seed") = if type(rs) == int {
					seed_from_int(rs)
				} else {
					rs
				}
			}
			st
		})
	}

	let reset() = the-state.update(st => st + (used: (:)))

	let fruitify(eq, ..args) = {
		setup(..args)

		show regex("\b\pL\b"): it => {
			let c = it.text
			the-state.update(st => {
				let symbols = st.symbols
				let seed = st.seed
				let used = st.used

				assert(used.len() < symbols.len(), message: "equation has more characters than possible symbols")
				if c not in used {
					let used_idcs = used.values().map(v => symbols.position(w => v == w))
					let (next_seed, idx) = gen_index(seed, symbols.len(), used_idcs)
					st.used.insert(c, symbols.at(idx))
					st.seed = next_seed
				}
				st
			})
			if sys.version >= version(0, 11) {
				context the-state.get().used.at(c)
			} else {
				the-state.display(st => {
					st.used.at(c)
				})
			}
		}

		eq
	}

	(setup, fruitify, reset, fruits)
}
#let (fruitify-setup, fruitify, reset-symbols, fruits) = _exports

#let vegetables = "🌽🥔🥑🥜🫚🧅🥕🫑🧄🥒🌶🫛🌰🥬🍄🥦🍆🫘".codepoints()
