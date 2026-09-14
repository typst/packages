#let glossary_entries = state("glossary_entries", (:))

#let set-glossary-table(gls) = {
  for item in gls {
    glossary_entries.update((tbl) => {
      tbl.insert(item.key, (short: item.short, long: item.long, appeared: false, description: item.description))
      tbl})
  }
}

#let gloss(key) = context {
  let itm = glossary_entries.get().at(key, default: (appeared: false, short: [*???*], long: [*???*], description: text(fill:red)[*没有找到 #key 对应的术语*]))
  if itm.appeared {
    [#itm.short]
  } else {
    glossary_entries.update((tbl) => {
      tbl.insert(key, itm + (appeared: true))
      tbl
    })
    [#itm.description (#itm.long, #itm.short) ]
  }
}
