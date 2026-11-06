// Formula labels expose element-and-count fragments without renumbering atoms.

#let _formula-label-fragments(layout, group, label) = {
  let pattern = regex("[CNOSFH](_[0-9]+)?")
  let remainder = label.text.replace(pattern, "").replace(regex("\\^[+-]"), "")
  if remainder != "" { return () }
  let fragments = ()
  for token in label.text.matches(pattern) {
    let element = token.text.at(0)
    let covers-attachment = token.start <= label.anchor and label.anchor < token.end
    let candidates = (group.atoms + group.at("hydrogens", default: ())).filter(index => layout.atoms.at(index).symbol == element)
    if covers-attachment {
      candidates = (group.attachment_atom,) + candidates.filter(index => index != group.attachment_atom)
    }
    if candidates.len() == 0 { return () }
    fragments.push((index: candidates.first(), atoms: candidates, text: token.text, start: token.start, end: token.end))
  }
  fragments
}

#let _prepare-abbreviation-fragments(layout) = {
  let prepared = layout
  for (group-index, group) in layout.at("abbreviation_groups", default: ()).enumerate() {
    let prepared-group = group
    prepared-group.fragments = _formula-label-fragments(layout, group, group.label)
    prepared-group.reversed_fragments = _formula-label-fragments(layout, group, group.reversed_label)
    prepared.abbreviation_groups.at(group-index) = prepared-group
  }
  prepared
}

#let _abbreviation-fragment(layout, atom-index) = {
  let group-index = layout.atoms.at(atom-index).at("abbreviation_group", default: none)
  if group-index == none { return none }
  let group = layout.abbreviation_groups.at(group-index)
  let attachment = layout.atoms.at(group.attachment_atom)
  let fragments = if attachment.abbrev == group.reversed_label.text {
    group.at("reversed_fragments", default: ())
  } else {
    group.at("fragments", default: ())
  }
  fragments.find(fragment => fragment.index == atom-index)
}

#let _abbreviation-fragment-representative(layout, atom-index) = {
  let group-index = layout.atoms.at(atom-index).at("abbreviation_group", default: none)
  if group-index == none { return none }
  let group = layout.abbreviation_groups.at(group-index)
  group.at("fragments", default: ()).find(fragment => fragment.atoms.contains(atom-index))
}
