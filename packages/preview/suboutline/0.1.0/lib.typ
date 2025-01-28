#let suboutline(
  title: none,
  target: heading.where(outlined: true),
  depth: none,
  indent: none,
  fill: repeat([.]),
) = {
  if depth == none { depth = calc.inf }
  context {
    let loc = here()
    let pre = query(selector(heading.where(outlined: true)).before(loc))
    if pre == () { return outline(target: target, title: title, fill: fill, indent: indent) }
    let after = pre.last()
    let min_level = after.level
    let max_level = min_level + depth
    let elems = query(selector(heading.where(outlined: true)).after(loc))
    let last_elem = none
    for e in elems {
      if e.level <= min_level { break }
      last_elem = e
    }
    max_level = if max_level == calc.inf { calc.max(..elems.map(e => e.level)) } else { max_level }
    if last_elem == none {
      outline(target: selector(target).after(after.location()), depth: max_level)
    } else {
      outline(
        target: selector(target).after(after.location()).before(last_elem.location()),
        fill: fill,
        title: title,
        indent: indent,
        depth: max_level,
      )
    }
  }
}
