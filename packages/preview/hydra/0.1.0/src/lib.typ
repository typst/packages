#import "/src/default.typ"

#let hydra(
  sel: heading,
  getter: default.get-adjacent,
  prev-filter: default.prev-filter,
  next-filter: default.next-filter,
  display: default.display,
  resolve: default.resolve,
  is-footer: false,
) = locate(loc => resolve(
    sel: sel,
    getter: getter,
    prev-filter: prev-filter,
    next-filter: next-filter,
    display: display,
    is-footer: is-footer,
    loc
))
