/// Entry point for the library
/// Author: @uwni 菱華
/// Version: 0.2.1
/// License: MPL-2.0

#let _amlos_dict = state("amlos-dict", ())
#let _desc_label(id) = label("amlos-desc:" + str(id))

#let defsym(group: "default", math: false, symbol, desc) = context {
    if type(group) != str {
      panic("group must be a string")
    }
    // the index of amlos-dict give a unique id to the symbol
    let record = (group, symbol, desc, here())
    _amlos_dict.update(old => old + (record,))

    // for current symbol, we can query the description listed
    let id = _amlos_dict.get().len() 
    let desc = query(_desc_label(id))
    // no description found, may caused by user didn't list the description
    // the cross reference will not be created
    if desc.len() == 0 {
      symbol
    } else {
      link(desc.at(0).location(), symbol)
    }
}

#let use-symbol-list(group: "default", fn) = context {
  let group = if type(group) == str {
    (group,)
  } else if type(group) == array {
    group
  } else {
    panic("group must be a string or an array of string")
  }
  // no symbol definition found
  let res = for (id, record) in _amlos_dict.final().enumerate() {
    let (_group, def, desc, def_loc) = record
    // filter the symbol by group
    if not group.contains(_group) { continue }
    let page_num = counter(page).at(def_loc).at(0)
    let page_num = if def_loc.page-numbering() == none {
      page_num
    } else {
      numbering(def_loc.page-numbering(), page_num)
    }
    (
      def,
      [#desc#_desc_label(id)],
      link(def_loc, [#page_num]),
    )
  }
  if res == none {
    return
  }
  fn(res)
}

