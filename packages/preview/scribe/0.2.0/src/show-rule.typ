#import "utils.typ": *
#import "deps.typ": *
#import "all-shorthands.typ": *

#let categories = (
  "operations",
  "relations",
  "miscellaneous",
  "logicals",
  "grouping-brackets",
  "caligraphics",
)

#let hands = (
  "operations": operations,
  "relations": relations,
  "miscellaneous": miscellaneous,
  "logicals": logicals,
  "grouping-brackets": grouping-brackets,
  "caligraphics": caligraphics, 
)

#let loads = (
  "operations": did-load-operations,
  "relations": did-load-relations,
  "miscellaneous": did-load-miscellaneous,
  "logicals": did-load-logicals,
  "grouping-brackets": did-load-grouping-brackets,
  "caligraphics": did-load-caligraphics, 
)

#let scribe(..args, content) = {
  for arg in args.pos() {
    if not categories.contains(arg) {
      let msg = "Illegal scribe category '" + arg + "'. Aborting."
      panic(msg)
    }
  }
  let _args = if args == arguments() { categories } else { args.pos() }

  let filtered = for (k,v) in hands {
    if _args.contains(k) {
      v
    }
  }

  for (k,v) in loads {
    if _args.contains(k) {
      v.update(true)
    }
  }
  show: shorthands.with(..filtered)
  content
}
