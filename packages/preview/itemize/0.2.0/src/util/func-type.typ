#let func-seq = [].func()
#let func-counter-update = [#counter("_cdl").update(0)].func()
#let func-state-update = [#state("_cdl").update(none)].func()
#let func-styled = [#text(fill: red, [])].func()
#let func-content = [#context none].func()
#let func-layout = [#layout(_ => none)].func()


/// All the text-style functions
#let text-style-func-all = (
  highlight[].func(),
  overline[].func(),
  smallcaps[].func(),
  strike[].func(),
  sub[].func(),
  super[].func(),
  underline[].func(),
  strong[].func(),
  emph[].func(),
)

/// Supported text style functions (excluding sub and super).
#let text-style-func = (
  highlight[].func(),
  overline[].func(),
  smallcaps[].func(),
  strike[].func(),
  // sub[].func(), // do not need to support ?
  // super[].func(), // do not need to support ?
  // lower and upper ?
  underline[].func(),
  strong[].func(),
  emph[].func(),
)

/// The function sof `enum.item`, `list.item`, `enum`, `list`
#let item-func = (enum.item, list.item, enum, list) // ?? enum and list ????

// block-level elements
#let block-level-elem = (
  //
  figure,
  heading,
  par, /**/
  //
  table,
  grid, /**/
  //
  block,
  //
  align,
  columns,
  layout,
  v,
  //
  move,
  pad,
  place,
  //
  repeat,
  //
  rotate,
  scale,
  skew,
  stack,
  //
  outline,
  //
  circle,
  ellipse,
  rect,
  square,
  //
  curve,
  image,
  line,
  polygon,
)


/// blockable-level elements (`raw`, `math.equation`).
#let blockable-level-elem = (
  raw,
  math.equation,
)


/// Checks if the content is blank.
/// - e (content):
#let is_blank-elem(e) = {
  // `pagebreak()` is illegel
  return (
    e in ([ ], parbreak(), colbreak(), auto, none) or e.func() in (func-counter-update, func-state-update, metadata)
  )
}

/// Internal function to test the type of a child element
#let _test_child(child) = {
  if is_blank-elem(child) {
    return "blank"
  } else if child.func() == func-styled {
    return "styled"
  } else if child.func() in text-style-func {
    return "text-styled"
  } else if child.func() == func-seq {
    return "seq"
  } else if child.func() in (list.item, enum.item) {
    return "item"
  } else {
    if child.func() in block-level-elem {
      return "unknown"
    }
    // ?
    let (height, width) = measure(child)
    if (height, width) == (0pt, 0pt) {
      return "blank"
    } else {
      // others ?
      return "unknown"
    }
  }
}


/// Checks if an item in a sequence is blank, an item, or something else.
///
/// - it (content):
/// -> none : blank, true: item or list, false: others
#let item_is_blank_in_seq(it) = {
  let _type = _test_child(it)
  if _type == "seq" {
    // "it" is a sequence
    for child in it.children {
      let child-type = _test_child(child)
      if child-type == "blank" {
        continue
      } else if child-type == "styled" {
        let deep = item_is_blank_in_seq(child.child)
        if deep == none {
          continue
        } else {
          return deep
        }
      } else if child-type == "text-styled" {
        let deep = item_is_blank_in_seq(child.body)
        if deep == none {
          continue
        } else {
          return deep
        }
      } else if child-type == "seq" {
        let deep = item_is_blank_in_seq(child)
        if deep == none {
          continue
        } else {
          return deep
        }
      } else if child-type in ("item", "block") {
        return true
      } else if child-type == "unknown" {
        return false
      }
    }
    return none
  } else {
    if _type == "styled" {
      return item_is_blank_in_seq(it.child)
    } else if _type == "text-styled" {
      return item_is_blank_in_seq(it.body)
    } else if _type in ("item", "block") {
      return true
    } else if _type == "unknown" {
      return false
    }
    return none
  }
}



/// Checks if an element is blank.
#let is_blank(e) = {
  // `pagebreak()` is illegel
  return item_is_blank_in_seq(e) == none
}

/// Checks if an element is styled.
#let is_styled(e) = {
  return e.func() == func-styled
}

/// Checks if an element has a text style.
#let is_text-styled(e) = {
  return e.func() in text-style-func-all
}

/// Checks if an element is an item (i.e. constructed by `enum` or `list`).
#let is_item(e) = {
  return e.func() in item-func
}

