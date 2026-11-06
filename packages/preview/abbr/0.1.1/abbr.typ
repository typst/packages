
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

#let incr(dct) = {
	dct.c+=1
  state("abbr").update(it=>{
    it.insert(dct.s, dct)
    return it
  })
}
#let mark-used(dct) = {
	dct.list = true
  state("abbr").update(it=>{
    it.insert(dct.s, dct)
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
				s: short,
				l: long,
				pl: plural,
				lbl: label(short + sym.hyph.point + long),
				c: 0,
				list: false,
			)
			it.insert(short, item)
			return it
		})
	}
}
/// add list of entries
#let make(..lst) = for (..abbr) in lst.pos() { add(..abbr) }

/// short form of abbreviation with link
#let s(short) = context {
  let dct = get(short).at(1)
  if dct == none { return warn(short) }
	mark-used(dct)
	let styleit = state("abbr-style", style-default).get()
  if query(dct.lbl).len() != 0 {
	  link(dct.lbl, styleit(dct.s))
  } else {
	  styleit(dct.s)
  }
}

/// long form of abbreviation
#let l(short) = context {
  let dct = get(short).at(1)
  if dct == none { return warn(short) }
  incr(dct)
  dct.l
  sym.paren.l
  sym.zwj
  s(dct.s)
  sym.zwj
  sym.paren.r
}
/// automatic short/long form
#let a(short) = context {
  let (key, dct) = get(short)
  if dct == none { return warn(short); }
  if dct.c == 0 { l(key) }
  else { s(key) }
}
/// short form plural
#let pls(short) = context {
	let styleit = state("abbr-style", style-default).get()
	[#s(short)#styleit[s]]
}
/// long form plural
#let pll(short) = context {
	let dct = get(short).at(1)
	if dct == none { return warn(short) }
	incr(dct)
	if dct.pl != none {
		dct.pl
	} else {
		[#dct.l\s]
	}
	sym.paren.l
	sym.zwj
	pls(dct.s)
	sym.zwj
	sym.paren.r
}
/// automatic short/long form plural
#let pla(short) = context {
  let (key, dct) = get(short)
  if dct == none { return warn(short); }
  if dct.c == 0 { pll(key) }
  else { pls(key) }
}
/// create list of abbreviations
#let list(
  title: [List of Abbreviations],
	columns: 2,
) = context {
  let lst = state("abbr", (:)).final().values()
			.filter(it => it.list).sorted(key: it => it.s)
  if lst.len() == 0 { return }
  let styleit = state("abbr-style", style-default).get()
	let make-entry(it) = (styleit[#it.s #it.lbl], it.l)
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
#let style(func) = {
	state("abbr-style", style-default).update(it => {
		if func == auto {
			return style-default
		}
		return func
	})
}
