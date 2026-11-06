#let style-default(short) = {
	let val = if text.weight <= "medium" { 15% } else { 30% }
	set text(fill: black.lighten(val))
	show: strong
	short
}

#let abbr = state("abbr", (:))
#let abbr-first = state("abbr-first", ())
#let abbr-list = state("abbr-list", ())
#let default = (
	space-char: sym.space.nobreak.narrow,
	style: style-default,
	pluralize-short: true,
	alt-supplement: [or],
)
#let cfg = state("abbr-config", default)

#let stringify(text) = {
	if type(text) == str {
		return text
	}
	if "text" in text.fields() {
		return text.text
	}
	panic("Cannot stringify")
}

#let get(short) = {
	let key = stringify(short)
	let entry = abbr.get().at(key, default:none)
	return (key, entry)
}

#let warn(short) = [*(?? #short ??)*]

#let mark-first(key) = {
	if not key in abbr-first.get() { return }
	abbr-first.update(lst => {
		return lst.filter(el => el != key)
	})
}

#let mark-used(key) = {
	if key in abbr-list.get() { return }
	abbr-list.update(lst => {
		lst.push(key)
		return lst
	})
}

/// add single entry
#let add(short, ..entry) = context {
	let long = entry.at(0)
	let plural = entry.at(1, default:none)
	let (key, entry) = get(short)
	if entry == none { // do not update blindly
		let item = (
			l: long,
			pl: plural,
			lbl: label(short + sym.hyph.point + long),
		)
		abbr.update(dct => {
			dct.insert(short, item)
			return dct
		})
		abbr-first.update(lst => {
			lst.push(key)
			return lst
		})
	}
}

/// add an alternate definition to a single entry
#let add-alt(short, alternate, supplement: default.alt-supplement) = context {
	let key = stringify(short)
	let abbr-entry = abbr.get().at(key, default: none)

		// Avoid overwriting an already-defined alternate
		// definition
		if abbr-entry != none and not "alt" in abbr-entry {
			let new = (alt: [#supplement #emph(alternate)])
			abbr.update(dct => {
				dct.insert(key, abbr-entry + new)
				return dct
			})
		}
}

/// add list of entries
#let make(..lst) = for (..abbr) in lst.pos() { add(..abbr) }

/// read data from csv file
#let read-csv(..filename, delimiter) = {
	let notempty(s) = { return s != "" }
	read(..filename).split("\n")
		.filter(notempty)
		.map(entry => csv(bytes(entry),delimiter:delimiter)
			.flatten().map(str.trim).filter(notempty)
		)
}

/// add abbreviations from csv file
#let load(..filename, delimiter:",") = {
	let entries = read-csv(..filename, delimiter)
	make(..entries)
}


/// add alternate definitions from csv file
#let load-alt(..filename, delimiter:",", supplement: default.alt-supplement) = {
	let entries = read-csv(..filename, delimiter)

	for entry in entries {
		let key = stringify(entry.at(0))
		let suppl = entry.at(2, default: supplement)
		add-alt(key, entry.at(1), supplement: suppl)
	}
}

/// short form of abbreviation with link
#let s(short) = context {
	let (key, dct) = get(short)
	if dct == none { return warn(short) }
	mark-used(key)
	let styleit = cfg.get().style
	if query(dct.lbl).len() != 0 {
		link(dct.lbl, styleit(key))
	} else {
		styleit(key)
	}
}

/// long form of abbreviation
#let l(short) = context {
	let (key, dct) = get(short)
	if dct == none { return warn(short) }
	mark-first(key)

	// Only show alternate definition on the first appearance
	let short-content = if "alt" in dct and key in abbr-first.get() {
		[#s(key),~#dct.alt]
	} else { s(key) }

	dct.l
	cfg.get().space-char
	sym.paren.l
	sym.zwj
	short-content
	sym.zwj
	sym.paren.r
}

/// long form of abbreviation, long-with-alt short form first
#let lsf(short) = context {
	let (key, dct) = get(short)
	if dct == none { return warn(short) }
	mark-first(key)

	// Only show alternate definition on the first appearance
	let long-content = if "alt" in dct and key in abbr-first.get() {
		[#dct.l,~#dct.alt]
	} else { dct.l }

	s(key)
	cfg.get().space-char
	sym.paren.l
	sym.zwj
	long-content
	sym.zwj
	sym.paren.r
}

/// long form _only_
#let lo(short) = context {
	let dct = get(short).at(1)
	if dct == none { return warn(short) }
	dct.l
}

/// automatic short/long form
#let a(short) = context {
	let (key, dct) = get(short)
	if dct == none { return warn(short); }
	if key in abbr-first.get() { l(key) }
	else { s(key) }
}

/// automatic short/long form, show short form first
#let asf(short) = context {
	let (key, dct) = get(short)
	if dct == none { return warn(short) }
	if key in abbr-first.get() { lsf(key) } else { s(key) }
}

/// short form plural
#let pls(short) = context {
	let styleit = cfg.get().style
	s(short)
	if cfg.get().pluralize-short { styleit[s] }
}

/// long form plural
#let pll(short) = context {
	let (key, dct) = get(short)
	if dct == none { return warn(short) }
	mark-first(key)
	if dct.pl != none {
		dct.pl
	} else {
		[#dct.l\s]
	}
	cfg.get().space-char
	sym.paren.l
	sym.zwj
	pls(key)
	sym.zwj
	sym.paren.r
}

/// long form plural _only_
#let pllo(short) = context {
	let dct = get(short).at(1)
	if dct == none { return warn(short) }
	if dct.pl != none {
		dct.pl
	} else {
		[#dct.l\s]
	}
}

/// automatic short/long form plural
#let pla(short) = context {
	let (key, dct) = get(short)
	// repr(dct)
	// repr(abbr-first.get())
	if dct == none { return warn(short); }
	if key in abbr-first.get() { pll(key) }
	else { pls(key) }
}

/// create list of abbreviations
#let list(
	title: [List of Abbreviations],
	columns: 2,
) = context {
	heading(title)
	let lst = abbr.final().pairs()
		.filter(it => it.at(0) in abbr-list.final())
		.map(((key, entry)) => {
			entry.s = key
			entry
		})
		.sorted(key: it => it.s)
	if lst.len() == 0 { return }
	let styleit = cfg.get().style

	let make-entry(e) = {
		let alt = if "alt" in e { [,~#e.alt] } else { none }
		(styleit[#e.s #e.lbl], [#e.l#alt])
	}

	if columns == 2 {
		let n = int(lst.len()/2)
		let last = if calc.odd(lst.len()) {lst.remove(n)}
		lst = lst.slice(0, n).zip(lst.slice(n)).flatten()
		if last != none { lst.push(last) }
	} else if columns != 1 {
		panic("abbr.list only supports 1 or 2 columns")
	}
	table(
		columns: (auto, 1fr)*columns,
		stroke:none,
		..for entry in lst { make-entry(entry) }
	)
}

/// configure styling of abbreviations
#let config(..args) = {
	let supported = ("style", "space-char", "pluralize-short")
	assert(
		args.pos().len() == 0,
		message: "'config' only accepts named parameters",
	)
	for (arg, value) in args.named() {
		if arg not in supported {
			panic("'config' only accepts " + supported.join(",") + " as parameters")
		}
	}

	cfg.update(old => {
		let update = args.named()
		for (key, value) in update {
			if value == none {
				update.remove(key)
			} else if value == auto {
				update.at(key) = default.at(key)
			}
		}
		old + update
	})
}
