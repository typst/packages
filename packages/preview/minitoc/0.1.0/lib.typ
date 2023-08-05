#let minitoc(
	title: none, target: heading.where(outlined: true),
	depth: none, indent: none, fill: repeat([.])
) = {
	if depth == none { depth = calc.inf }
	locate(loc => {
		let pre = query(selector(heading.where(outlined: true)).before(loc), loc)
		if pre == () { return outline(target: target, title: title, fill: fill, indent: indent) }
		let after = pre.last()
		let min_level = after.level
		let max_level = min_level + depth
		let elems = query(selector(heading.where(outlined: true)).after(loc), loc)
		let last_elem = none
		for e in elems {
			if e.level <= min_level { break }
			last_elem = e
		}
		if last_elem == none {
			outline(target: selector(target).after(after.location()))
		} else {
			outline(
				target: selector(target)
					.after(after.location())
					.before(last_elem.location()),
				fill: fill, title: title, indent: indent
			)
		}
	})
}
