// Shared names and coordinate references for molecular drawing groups.
#let _structure-name = "molchemist-structure"

/// Return the internal CeTZ object name for an atom.
///
/// - index (int): Atom index shown by `show-indices`.
/// -> str
#let atom-ref(index) = _structure-name + ".a" + str(index)

/// Select an anchor on a rendered atom.
///
/// - index (int): Atom index shown by `show-indices`.
/// - anchor (str): CeTZ anchor such as `"mid"`, `"north"`, or `"east"`.
/// -> dictionary
#let atom-anchor(index, anchor: "mid") = (kind: "atom", index: index, anchor: anchor)

/// Return the internal CeTZ object name for a bond.
///
/// - index (int): Bond index shown by `show-indices`.
/// -> str
#let bond-ref(index) = _structure-name + ".b" + str(index)

/// Select an anchor on a rendered bond.
///
/// - index (int): Bond index shown by `show-indices`.
/// - anchor (str): CeTZ path anchor, such as `"50%"`.
/// -> dictionary
#let bond-anchor(index, anchor: "50%") = (kind: "bond", index: index, anchor: anchor)

/// Select an anchor on the complete rendered molecule.
///
/// - anchor (str): CeTZ group anchor such as `"center"`, `"north"`, or `"east"`.
/// -> dictionary
#let molecule-anchor(anchor: "center") = (kind: "molecule", anchor: anchor)

#let _annotation-anchor(name, anchor: "mid") = {
  if type(name) == dictionary {
    let kind = name.at("kind", default: none)
    if kind == "atom" {
      (
        name: _structure-name,
        anchor: "a" + str(name.at("index")) + "." + name.at("anchor", default: anchor),
      )
    } else if kind == "bond" {
      (
        name: _structure-name,
        anchor: "b" + str(name.at("index")) + "." + name.at("anchor", default: anchor),
      )
    } else if kind == "molecule" {
      let resolved-anchor = name.at("anchor", default: anchor)
      if resolved-anchor == "default" {
        resolved-anchor = "center"
      }
      (name: _structure-name, anchor: resolved-anchor)
    } else if "to" in name {
      let coord = name
      coord.insert("to", _annotation-anchor(coord.to, anchor: anchor))
      coord
    } else {
      name
    }
  } else if type(name) == str {
    if anchor == "default" or anchor == "mid" {
      name
    } else {
      name + "." + anchor
    }
  } else {
    (name: str(name), anchor: anchor)
  }
}

#let _ctfile-atom-index(name) = {
  if type(name) == str and name.starts-with("a") {
    int(name.slice(1))
  } else {
    none
  }
}
