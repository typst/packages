/// Converts a value to a string representation.
///
/// -> str
#let to-str(it) = {
  if type(it) == str {
    it
  } else if type(it) == array {
    it.join(", ", last: " and ")
  } else if type(it) != content {
    str(it)
  } else if it.has("text") {
    it.text
  } else if it.has("children") {
    it.children.map(to-str).join()
  } else if it.has("body") {
    to-str(it.body)
  } else if it == [ ] {
    " "
  }
}
