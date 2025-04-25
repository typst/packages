/// Entry point for the library
/// Author: @uwni 菱華
/// Version: 0.1.0
/// License: MPL-2.0

#let _amlos_desc = label("amlos-desc")
#let _amlos_def = label("amlos-def")

#let defsym(group: "default", math: false, symbol, desc) = context {
  // the index of amlos-dict give a unique id to the symbol
  let id = counter(_amlos_def).get().at(0)
  let symbol = [
    #metadata((
      group: group,
      def: symbol,
      desc: desc,
    ))#_amlos_def
    #symbol
  ]
  // for current symbol, we can query the description listed
  let desc = query(_amlos_desc).filter(it => {
    let (id: _id, group: _group) = it.value
    id == _id and group == _group
  })
  // no description found, may caused by user didn't list the description
  // the cross reference will not be created
  if desc.len() == 0 {
    return symbol
  }
  link(desc.at(0).location(), symbol)
}

#let use-symbol-list(group: "default", fn) = context {
  let res = for (id, meta) in query(_amlos_def).enumerate() {
    let (group: _group, def: def, desc: desc) = meta.value
    // filter the symbol by group
    if group != _group { continue }
    let def_loc = meta.location()
    let page_num = counter(page).at(def_loc).at(0)
    let page_num = if def_loc.page-numbering() == none {
      page_num
    } else {
      numbering(def_loc.page-numbering(), page_num)
    }
    (
      def,
      [
        #metadata((id: id, group: group))#_amlos_desc
        #desc
      ],
      link(def_loc, [#page_num]),
    )
  }
  // no symbol definition found
  if res == none or res.len() == 0 {
    return
  }
  fn(res)
}

