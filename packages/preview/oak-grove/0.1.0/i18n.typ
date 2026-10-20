#import "utils.typ"

#let languages = ("en", "es", "ca")

#let files = languages.map(l => (l, json("./lang/" + l + ".json"))).to-dict()

///
/// Gets a localised message from an ID.
/// - id ("problem" | "solution"):
/// - cap (bool): Whether to make the first letter uppercase.
/// -> content
#let m(id, cap) = context {
  let s = files.at(text.lang).at(id)
  return if cap {utils.capitalize(s)} else {s}
}