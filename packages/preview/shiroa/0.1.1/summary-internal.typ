
#import "utils.typ": _store-content

/// Internal method to convert summary content nodes
#let _convert-summary(elem) = {

  // The entry point of the metadata nodes
  if metadata == elem.func() {

    // convert any metadata elem to its value
    let node = elem.value

    // Convert the summary content inside the book elem
    if node.at("kind") == "book" {
      let summary = node.at("summary")
      node.insert("summary", _convert-summary(summary))
    }

    return node
  }

  // convert a heading element to a part elem
  if heading == elem.func() {
    return (
      kind: "part",
      level: elem.depth,
      title: _store-content(elem.body),
    )
  }

  // convert a (possibly nested) list to a part elem
  if list.item == elem.func() {

    // convert children first
    let maybe-children = _convert-summary(elem.body)

    if type(maybe-children) == "array" {
      // if the list-item has children, then process subchapters

      if maybe-children.len() <= 0 {
        panic("invalid list-item, no maybe-children")
      }

      // the first child is the chapter itself
      let node = maybe-children.at(0)

      // the rest are subchapters
      let rest = maybe-children.slice(1)
      node.insert("sub", rest)

      return node
    } else {
      // no children, return the list-item itself
      return maybe-children
    }
  }

  // convert a sequence of elements to a list of node
  if [].func() == elem.func() {
    return elem.children.map(_convert-summary).filter(it => it != none)
  }

  // All of rest are invalid
  none
}

/// Internal method to number sections
/// meta: array of summary nodes
/// base: array of section number
#let _numbering-sections(meta, base: ()) = {
  // incremental section counter used in loop
  let cnt = 1
  for c in meta {
    // skip non-chapter nodes or nodes without section number
    if c.at("kind") != "chapter" or c.at("section") == none {
      (c,)
      continue
    }

    // default incremental section
    let idx = cnt
    cnt += 1
    let num = base + (idx,)
    // c.insert("auto-section", num)

    let user-specified = c.at("section")
    // c.insert("raw-section", repr(user-specified))

    // update section number if user specified it by str or array
    if user-specified != none and user-specified != auto {

      // update number
      num = if type(user-specified) == str {
        // e.g. "1.2.3" -> (1, 2, 3)
        user-specified.split(".").map(int)
      } else if type(user-specified) == array {
        for n in user-specified {
          assert(
            type(n) == int,
            message: "invalid type of section counter specified " + repr(user-specified) + ", want number in array",
          )
        }

        // e.g. (1, 2, 3)
        user-specified
      } else {
        panic("invalid type of manual section specified " + repr(user-specified) + ", want str or array")
      }

      // update cnt
      cnt = num.last() + 1
    }

    // update section number
    let auto-num = num.map(str).join(".")
    c.at("section") = auto-num

    // update sub chapters
    if "sub" in c {
      c.sub = _numbering-sections(c.at("sub"), base: num)
    }

    (c,)
  }
}
