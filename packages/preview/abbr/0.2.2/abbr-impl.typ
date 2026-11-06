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
	let entry = state("abbr", (:)).get().at(key, default:none)
	return (key, entry)
}

#let warn(short) = [*(?? #short ??)*]

#let style-default(short) = {
	let val = if text.weight <= "medium" { 15% } else { 30% }
	set text(fill: black.lighten(val))
	show: strong
	short
}

#let space-default = sym.space.nobreak.narrow

#let mark-first(key, dct) = {
	if not dct.frst { return }
	dct.frst=false
	state("abbr").update(it=>{
		it.insert(key, dct)
		return it
	})
}

#let mark-used(key, dct) = {
	if dct.list { return }
	dct.list = true
	state("abbr").update(it=>{
		it.insert(key, dct)
		return it
	})
}

/// add single entry
#let add(short, ..entry) = context {
	let long = entry.at(0)
	let plural = entry.at(1, default:none)
	let (key, entry) = get(short)
	if entry == none { // do not update blindly, it'd reset the counter
		state("abbr").update(it => {
			let item = (
				l: long,
				pl: plural,
				lbl: label(short + sym.hyph.point + long),
				frst: true,
				list: false,
			)
			it.insert(short, item)
			return it
		})
	}
}

/// add list of entries
#let make(..lst) = for (..abbr) in lst.pos() { add(..abbr) }

/// add abbreviations from csv file
#let load(..filename, delimiter:",") = {
	let notempty(s) = { return s != "" }
	let entries = read(..filename).split("\n")
		.filter(notempty)
		.map(entry => csv.decode(entry,delimiter:delimiter)
			.flatten().map(str.trim).filter(notempty)
		)
	make(..entries)
}

/// short form of abbreviation with link
#let s(short) = context {
	let (key, dct) = get(short)
	if dct == none { return warn(short) }
	mark-used(key, dct)
	let styleit = state("abbr-style", style-default).get()
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
	mark-first(key, dct)
	dct.l
	state("abbr-space", space-default).get()
	sym.paren.l
	sym.zwj
	s(key)
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
	if dct.frst { l(key) }
	else { s(key) }
}

/// short form plural
#let pls(short) = context {
	let styleit = state("abbr-style", style-default).get()
	[#s(short)#styleit[s]]
}

/// long form plural
#let pll(short) = context {
	let (key, dct) = get(short)
	if dct == none { return warn(short) }
	mark-first(key, dct)
	if dct.pl != none {
		dct.pl
	} else {
		[#dct.l\s]
	}
	state("abbr-space", space-default).get()
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
	if dct == none { return warn(short); }
	if dct.frst { pll(key) }
	else { pls(key) }
}

/// create list of abbreviations
#let list(
	title: [List of Abbreviations],
	columns: 2,
) = context {
	let lst = state("abbr", (:)).final().pairs()
		.filter(it => it.at(1).list)
		.map(pair => (s: pair.at(0), l: pair.at(1).l, lbl: pair.at(1).lbl))
		.sorted(key: it => it.s)
	if lst.len() == 0 { return }
	let styleit = state("abbr-style", style-default).get()
	let make-entry(e) = (styleit[#e.s #e.lbl], e.l)
	if columns == 2 {
		let n = int(lst.len()/2)
		let last = if calc.odd(lst.len()) {lst.remove(n)}
		lst = lst.slice(0, n).zip(lst.slice(n)).flatten()
		if last != none { lst.push(last) }
	} else if columns != 1 {
		panic("abbr.list only supports 1 or 2 columns")
	}
	heading(numbering: none, title)
	table(
		columns: (auto, 1fr)*columns,
		stroke:none,
		..for entry in lst { make-entry(entry) }
	)
}

/// configure styling of abbreviations
#let config(style: auto, space-char: sym.space.nobreak.narrow) = {
	state("abbr-style", style-default).update(it => {
		if style == auto {
			return style-default
		}
		return style
	})
	state("abbr-space", space-default).update(it => space-char)
}
