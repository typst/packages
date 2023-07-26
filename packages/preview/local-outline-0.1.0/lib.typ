#let local_outline(title: none, depth: none, indent: none, fill: repeat([.])) = {
	if depth == none { depth = calc.inf }
	if fill == none { fill = [] }
	let numbering_fn = if indent == auto {
		(t, n, m) => {
			style(s => {
				let acc = 0pt
				for i in range(m + 1, t.len()) {
					acc += measure(numbering(n, ..t.slice(0, i)), s).width + 1mm
				}
				h(acc)
				numbering(n, ..t)
			})
		}
	} else if indent == none {
		(t, n, m) => numbering(n, ..t)
	} else if type(indent) == type(() => {}) {
		(t, n, m) => {
			indent(t.len() - m)
			numbering(n, ..t)
		}
	} else if type(indent) == type(2em) {
		(t, n, m) => {
			h(indent * (n.len() - m))
			numbering(n, ..t)
		}
	} else {
		panic("indent cannot be a " + type(indent) + "type. See the #outline docs for help")
	}
	locate(loc => {
		let pre = query(selector(heading).before(loc), loc)
		if pre == () { return }
		let min_level = pre.last().level
		let max_level = min_level + depth
		let elems = query(selector(heading.where(outlined: true)).after(loc), loc)
		let inner_elems = ()
		for e in elems {
			if e.level <= min_level { break }
			else if e.level <= max_level { inner_elems.push(e) }
		}
		let out = inner_elems.map(i => [#link(i.location(), [#numbering_fn(counter(heading).at(i.location()), i.numbering, min_level) #i.body]) #box(width: 1fr, fill) #i.location().page()]).join("\n")
		if title == none {
			[#out]
		} else {
			[#heading(level: min_level + 1, numbering: none, outlined: false)[#title] #out]
		}
	})
}
