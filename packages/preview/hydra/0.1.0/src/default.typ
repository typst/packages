// get the adjacent headings
#let get-adjacent(is-footer: false, sel, loc) = {
  import "/src/util.typ": into-sel-filter-pair
  let (sel, filter) = into-sel-filter-pair(sel)

  if is-footer {
    loc = query(selector(<hydra>).before(loc), loc).last().location()
  }

  let prev = query(sel.before(loc), loc).filter(x => filter(x, loc))
  let next = query(sel.after(loc), loc).filter(x => filter(x, loc))

  let prev = if prev != () { prev.last() }
  let next = if next != () { next.first() }

  (prev, next)
}

// check if the previous heading is numbered
#let prev-filter(element, loc) = {
  import "/src/util.typ": assert-element
  assert-element(element, heading)
  element.numbering != none
}

// check if the next heading is on the curent page
#let next-filter(top-margin: 2.5cm, element, loc) = {
  import "/src/util.typ": assert-element
  assert-element(element, heading)
  (element.numbering != none
    and element.location().page() == loc.page()
    and element.location().position().y <= top-margin)
}

// display the heading as closely as it occured at the given loc
#let display(element, loc) = {
  import "/src/util.typ": assert-element
  assert-element(element, heading)
  if element.numbering != none {
    numbering(element.numbering, ..counter(heading).at(element.location()))
    [ ]
  }
  element.body
}

#let resolve(
  sel: heading,
  getter: get-adjacent,
  prev-filter: prev-filter,
  next-filter: next-filter,
  display: display,
  is-footer: false,
  loc,
) = {
  let (last, next) = getter(sel, is-footer: is-footer, loc)

  let last-eligible = last != none and prev-filter(last, loc)
  let next-eligible = next != none and next-filter(next, loc)

  if last-eligible and not next-eligible {
    display(last, loc)
  }
 }
