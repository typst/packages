// The code lists of the validator (src/zugferd/rules/), which
// tools/zugferd/gen_guard.py compiles from the official validations of the
// profiles into code-lists.json (do not edit it: rerun the generator).
//
// A list is a string of its codes, each between two spaces: a code without
// spaces is in a list when `" " + code + " "` is in the string.

/// Per name (e.g. `currency`) and kind, a list: `every`, the codes all
/// validations accept; `factur-x` and `xrechnung`, the lists of these
/// validations; `newer`, the codes only the newest EN 16931 list has; and
/// `withdrawn`, those it has withdrawn.
///
/// -> dictionary
#let lists = {
  let out = (:)
  for (name, kinds) in json("code-lists.json") {
    if name in ("generated", "fx-rules") { continue }
    let every = " " + kinds.every.join(" ") + " "
    let entry = (:)
    for (kind, lines) in kinds {
      let codes = if lines == () { "" } else { lines.join(" ") + " " }
      // `factur-x` and `xrechnung` hold the codes they have beyond `every`.
      let base = if kind in ("factur-x", "xrechnung") { every } else { " " }
      entry.insert(kind, base + codes)
    }
    out.insert(name, entry)
  }
  out
}

// The profiles with a Factur-X Schematron, in the order of `fx-rules`.
#let _fx-profiles = ("minimum", "basic-wl", "basic", "en16931")
#let _fx-rules = json("code-lists.json").at("fx-rules")

/// The rule of the Factur-X Schematron that checks the code list at a
/// position (e.g. `country/buyer`) in a profile, or `none` where the profile
/// has no Factur-X list there. Since Factur-X 1.09, each position of each
/// profile has a rule id of its own.
///
/// -> none | str
#let fx-id(key, profile) = {
  let index = _fx-profiles.position(p => p == profile.id)
  if index == none { return none }
  _fx-rules.at(key).at(index)
}
