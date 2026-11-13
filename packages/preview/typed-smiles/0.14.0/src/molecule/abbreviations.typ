// Automatic abbreviation requests and the reading direction of their labels.

#import "../chemistry.typ": _abbreviation-names, _compute-layout
#import "../validation.typ": _invalid-input
#import "rendering.typ": _rendered-atom-position

// How far right of its label, in bond lengths, the attached atom must sit
// before the label reads toward it. Nearly vertical bonds keep the default
// reading direction.
#let _rightward-attachment-threshold = 0.1

// Normalizes an `abbreviate` argument into the plugin request: none when no
// group should be contracted, "all", or comma-separated catalogue names.
#let _abbreviation-request(abbreviate, input-context) = {
  if abbreviate == none or abbreviate == () {
    return none
  }
  if abbreviate == "all" {
    return "all"
  }
  let available-names = _abbreviation-names()
  let available-description = (
    "Available groups are " + available-names.map(repr).join(", ") + "."
  )
  if type(abbreviate) != str and type(abbreviate) != array {
    _invalid-input(
      input-context,
      "expected none, \"all\", a group name, or an array of group names, got "
        + repr(abbreviate),
      "Pass names such as (\"OMe\", \"CF3\"). " + available-description,
    )
  }
  let names = if type(abbreviate) == str { (abbreviate,) } else { abbreviate }
  let accepted-names = ()
  for name in names {
    if name == "all" {
      _invalid-input(
        input-context,
        "\"all\" appears inside a list of group names",
        "Write abbreviate: \"all\" on its own, or list only catalogue names.",
      )
    }
    if type(name) != str or name not in available-names {
      _invalid-input(
        input-context,
        "unknown group " + repr(name),
        available-description + " Group names are case-sensitive.",
      )
    }
    if name in accepted-names {
      _invalid-input(
        input-context,
        "group " + repr(name) + " is listed more than once",
        "List each group once.",
      )
    }
    accepted-names.push(name)
  }
  accepted-names.join(",")
}

// Lays out a SMILES string with the requested automatic abbreviations. A group
// named explicitly must be contracted at least once; "all" contracts whichever
// catalogue groups occur.
#let _abbreviated-layout(smiles-str, abbreviate, input-context) = {
  let request = _abbreviation-request(abbreviate, input-context)
  let layout = _compute-layout(smiles-str, abbreviation-request: request)
  if request == none or request == "all" {
    return layout
  }
  let contracted-names = layout.abbreviation_groups.map(group => group.name)
  for name in request.split(",") {
    if name not in contracted-names {
      _invalid-input(
        input-context + " group " + repr(name),
        "no terminal " + name + " group in " + repr(smiles-str) + " can be drawn as a label",
        "Remove it from abbreviate, or use abbreviate: \"all\" to contract only the groups that occur."
          + " Groups with isotopes, atom maps, stereo marks, unexpected charges, or bracket hydrogens stay expanded,"
          + " as does a group that overlaps or attaches to a higher-priority group.",
      )
    }
  }
  layout
}

// Chooses each automatic label's reading direction from its rendered
// attachment bond: a label whose bond leaves toward the right reads toward
// that bond (MeO), and any other label reads away from it (OMe). Apply after
// mirroring, with the molecule's rotation.
#let _orient-abbreviation-labels(layout, rotation) = {
  let oriented-layout = layout
  for group in layout.at("abbreviation_groups", default: ()) {
    let attachment-position = _rendered-atom-position(
      layout.atoms.at(group.attachment_atom),
      rotation,
    )
    let external-position = _rendered-atom-position(
      layout.atoms.at(group.external_atom),
      rotation,
    )
    let attaches-on-right = (
      external-position.x - attachment-position.x > _rightward-attachment-threshold
    )
    let label = if attaches-on-right { group.reversed_label } else { group.label }
    let attachment-atom = oriented-layout.atoms.at(group.attachment_atom)
    attachment-atom.abbrev = label.text
    attachment-atom.abbrev_anchor = label.anchor
    attachment-atom.abbrev_anchor_len = label.anchor_len
    oriented-layout.atoms.at(group.attachment_atom) = attachment-atom
  }
  oriented-layout
}
