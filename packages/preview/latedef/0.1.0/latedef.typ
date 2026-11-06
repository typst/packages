/// Obtain a pair `(undef, def)` (see the README for more details).
/// -> pair
#let latedef-setup(
	/// Disambiguator to allow parallel usage for multiple purposes.
	/// -> none | str
	group: none,
	/// Disable id-based definitions to avoid having to call `undef` as a function.
	/// -> bool
	simple: false,
	/// What to display when there is no matching definition.
	/// -> (none | str) -> content
	stand-in: id => text(red)[\<undefined#if id != none [ #repr(id)]\>],
	/// Whether to wrap `undef` in `footnote`.
	/// Sets `group` to `"footnote"` if it was `none`.
	/// -> bool
	footnote: false
) = {
	let group = group
	if footnote and group == none {
		group = "footnote"
	}

	let mangle(x) = "__:latedef:" + x + if group != none { "." + group }

	let get-id(..args) = {
		if args.pos().len() >= 1 {
			let verify-args(pos-id, id: none) = {}
			verify-args(..args)
			if args.named().len() == 1 {
				// `id` was given as named too
				let either-pos-or-named = false
				assert(either-pos-or-named,
					message: "ID has to be given as either positional or named argument, not both"
				)
			}
			let (id,) = args.pos()
			assert.eq(type(id), str, message: "ID has to be a string")
			id
		} else {
			let verify-args(id: none) = {}
			verify-args(..args)
			if "id" in args.named() {
				let id = args.named().at("id")
				assert.eq(type(id), str, message: "ID has to be a string")
				id
			} else {
				none
			}
		}
	}

	let ldef = label(mangle("def"))
	let num-undef = counter(mangle("num-undef"))
	let num-def = counter(mangle("num-def"))
	let by-id = state(mangle("by-id"), (:))

	let anon-undef = context {
		let arr = query(ldef)
		let idx = num-undef.get().first()
		if idx < arr.len() {
			arr.at(idx).value
		} else {
			stand-in(none)
		}
	} + num-undef.step()
	let anon-def(x) = [#metadata(x)#ldef#num-def.step()]

	let undef = if simple { anon-undef } else {
		(..args) => {
			let id = get-id(..args)
			if id == none {
				anon-undef
			} else {
				context {
					let d = by-id.final()
					if id in d.keys() {
						d.at(id)
					} else {
						stand-in(id)
					}
				}
			}
		}
	}
	let def = if simple { anon-def } else {
		(..args) => {
			let (..prev, value) = args.pos()
			let id = get-id(..prev, ..args.named())
			if id == none {
				anon-def(value)
			} else {
				by-id.update(d => d + ((id): value))
			}
		}
	}

	if footnote {
		undef = if simple { std.footnote(undef) } else { (..args) => std.footnote(undef(..args)) }
	}

	(undef, def)
}
