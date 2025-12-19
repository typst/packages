#import "parse_util.typ": string_lit

#let types = (
  Root: "root",
  NameSelector: "name_selector",
  IndexSelector: "index_selector",
  SliceSelector: "slice_selector",
  WildcardSelector: "wildcard_selector",
  DescendantSegment: "descendant_segment",
  ChildSegment: "child_segment",
  FilterSelector: "filter_selector",
)

#let node(type, dict, start, end) = {
  return (
    dict
      + (
        type: type,
        pos: (
          start: start,
          end: end,
        ),
      )
  )
}

#let Root(start, end) = {
  return node(
    types.Root,
    (:),
    start,
    end,
  )
}

#let NameSelector(name, start, end) = {
  return node(
    types.NameSelector,
    (
      name: name,
    ),
    start,
    end,
  )
}
#let WildcardSelector(start, end) = {
  return node(
    types.WildcardSelector,
    (:),
    start,
    end,
  )
}

#let IndexSelector(index, start, end) = {
  return node(
    types.IndexSelector,
    (
      index: index,
    ),
    start,
    end,
  )
}


#let FilterSelector(index, start, end) = {
  return node(
    types.FilterSelector,
    (
      index: index,
    ),
    start,
    end,
  )
}

#let SliceSelector(slice_start, slice_end, slice_step, start, end) = {
  return node(
    types.SliceSelector,
    (
      start: slice_start,
      end: slice_end,
      step: slice_step,
    ),
    start,
    end,
  )
}

#let ChildSegment(selectors, start, end) = {
  return node(
    types.ChildSegment,
    (
      selectors: selectors,
    ),
    start,
    end,
  )
}
#let DescendantSegment(selector, start, end) = {
  return node(
    types.DescendantSegment,
    (selector: selector),
    start,
    end,
  )
}

#let indent_str(indent, level) = {
  let r = ""
  let i = 0
  let j = 0
  while i < level * indent {
    r += " "
    i += 1
  }
  return r
}

#let node_str(node, ..level) = {
  let lvl = 0
  level = level.pos()
  if level.len() > 0 {
    lvl = level.first()
  }
  let indent = indent_str(2, lvl)
  if node.type == types.Root {
    return indent + types.Root + "()"
  }
  if node.type == types.NameSelector {
    return indent + types.NameSelector + "(" + string_lit(node.name) + ")"
  }
  if node.type == types.WildcardSelector {
    return indent + types.WildcardSelector + "()"
  }
  if node.type == types.IndexSelector {
    return indent + types.IndexSelector + "(" + str(node.index) + ")"
  }
  if node.type == types.SliceSelector {
    let start = "null"
    let end = "null"
    let step = "null"
    if node.start != none {
      start = str(node.start)
    }
    if node.end != none {
      end = str(node.end)
    }
    if node.step != none {
      step = str(node.step)
    }
    return indent + types.SliceSelector + "(" + start + ", " + end + ", " + step + ")"
  }
  if node.type == types.FilterSelector {
    return indent + types.FilterSelector + "(" + str(node.index) + ")"
  }
  if node.type == types.ChildSegment {
    let children = node.selectors.map(s => node_str(s, lvl + 1))
    if children.len() == 0 {
      return indent + types.ChildSegment + "()"
    }
    return indent + types.ChildSegment + "(\n" + children.join("\n") + indent + "\n)"
  }
  if node.type == types.DescendantSegment {
    return (
      indent + types.DescendantSegment + "(\n" + node_str(node.selector, lvl + 1) + indent + "\n)"
    )
  }
}
