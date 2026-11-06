#let find(elmt, tag) = {
  if not "children" in elmt {
    return none
  }

  return elmt.children.find(e => "tag" in e and e.tag == tag)
}

#let find-all(elmt, tag) = {
  if not "children" in elmt {
    return ()
  }

  return elmt.children.filter(e => "tag" in e and e.tag == tag)
}

#let parse-values(elmt) = {
  let values = (:)
  let case-elmts = find-all(elmt, "case")

  for case-elmt in case-elmts {
    let val = case-elmt.attrs.value
    let desc = case-elmt.children.first()
    let struct = none
    if "structure" in case-elmt.attrs {
      struct = case-elmt.attrs.structure
    }

    values.insert(val, 
      if struct != none {
        (
          description: desc,
          structure: struct
        )
      } else {
        desc
      }
    )
  }

  return values
}

#let parse-range(elmt) = {
  let range_ = (
    name: elmt.attrs.name
  )
  let desc = none
  if "children" in elmt {
    desc = find(elmt, "description")
  }

  if desc != none {
    range_.insert("description", desc.children.first())
  }

  let values-elmt = find(elmt, "values")
  if values-elmt != none {
    range_.insert("values", parse-values(values-elmt))
  }

  if "depends-on" in elmt.attrs {
    range_.insert("depends-on", elmt.attrs.depends-on)
  }

  return range_
}

#let parse-structure(elmt) = {
  let ranges = (:)
  let range-elmts = elmt.children.filter(e => "tag" in e and e.tag == "range")

  for range-elmt in range-elmts {
    let span = range-elmt.attrs.end + "-" + range-elmt.attrs.start
    ranges.insert(span, parse-range(range-elmt))
  }

  return (
    bits: elmt.attrs.bits,
    ranges: ranges
  )
}

#let parse(content) = {
  let struct-elmts = content.children.filter(e => "tag" in e and e.tag == "structure")
  let color-elmts = content.children.filter(e => "tag" in e and e.tag == "color")

  let structures = (:)
  let colors = (:)

  for struct-elmt in struct-elmts {
    structures.insert(
      struct-elmt.attrs.id,
      parse-structure(struct-elmt)
    )
  }

  for color-elmt in color-elmts {
    let struct = color-elmt.attrs.structure
    if not struct in colors {
      colors.insert(struct, (:))
    }

    let span = color-elmt.attrs.end + "-" + color-elmt.attrs.start
    colors.at(struct).insert(span, color-elmt.attrs.color)
  }

  return (
    structures: structures,
    colors: colors
  )
}

#let load(path) = {
  let content = xml(path).first()
  return parse(content)
}