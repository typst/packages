/// ParType
#let ParType = (
  native: "native",
  default: "default", // paragraph
  parbreak-indented: "parbreak-indented", // paragraph break with indentation
  parbreak-non-indented: "parbreak-non-indented", // paragraph break without indentation
  block-all: "block-all", // block-indent + block-leading
  block-indent: "block-indent", // block-level elements that are included
  block-leading: "block-leading", // block-level elements that are in `block-text-leading`
  block-none: "block-none", // block-level elements that are not included
  non-tight-list-parbreak: "non-tight-list-parbreak", // non-tight list with paragraph break
)

/// ParType state
/// - data: par-type (ParType), below (tract the below spacing of block-level elements), tight (track the tightness of lists), n (the current number of items in the lists), count (the total number of items in the lists)
/// - backup: backup data (used for `place` and `figure.placement != none`)
#let par-type-state = state("__cdl_parize_par_type__", (data: (par-type: ParType.native), backup: ()));

/// For debug: It contains the information of the current paragraph state
#let parize-debug = context par-type-state.get()

/// Update par-type state
#let update-dic(dic: (:), backup: false) = it => {
  if backup == false {
    it.data = dic
  } else if backup == auto {
    // recover, used for `place` and `figure.placement != none`
    it.data = it.backup.pop()
  } else if backup == true {
    // restore, used for `place` and `figure.placement != none`
    it.backup.push(it.data)
    it.data = (par-type: ParType.native)
  }
  return it
}

/// For `parbreak`
#let update-parbreak = it => {
  let par-type = it.data.par-type

  if (
    par-type
      in (ParType.native, ParType.non-tight-list-parbreak, ParType.parbreak-indented, ParType.parbreak-non-indented)
  ) {
    return it
  }
  let is-non-tight-list = it.data.at("tight", default: none) == false
  if is-non-tight-list {
    let count = it.data.at("count", default: 0)
    let n = it.data.at("n", default: 0)
    if count == n {
      it.data = (par-type: ParType.non-tight-list-parbreak)
    }
  } else if par-type in (ParType.block-indent, ParType.block-all) {
    it.data = (par-type: ParType.parbreak-indented)
  } else if par-type == ParType.block-none {
    it.data = (par-type: ParType.parbreak-non-indented)
  } else {
    it.data = (par-type: ParType.native)
  }
  return it
}

/// For item in non-tight lists
#let update-item-count = it => {
  let is-non-tight-list = it.data.at("tight", default: none) == false
  if not is-non-tight-list {
    return it
  }
  let n = it.data.at("n", default: 0)
  it.data.n = n + 1
  return it
}
