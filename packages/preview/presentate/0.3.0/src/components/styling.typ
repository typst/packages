#import "../store.typ": prefix 

#let element(id, func) = (..args, label: none) => {
  let seq = [].func() 
  [#seq(([#func(..args)#label],))#std.label(prefix + "_" + id)]
} 

#let select(id) = selector(label(prefix + "_" + id))

#let resolve-title(title, target-level: 2) = {
  if title == none { return none }
  if title != auto { return box(title) }
  if title == auto {
    let all-headings = query(selector.or(
      heading.where(level: 1, bookmarked: auto), 
      heading.where(level: target-level, bookmarked: auto),
    ).before(here()))
    if all-headings == () { return none } 
    if all-headings.last().level < target-level { return none } 
    all-headings.last()
  }
}