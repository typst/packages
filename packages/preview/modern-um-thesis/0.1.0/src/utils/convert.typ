/// Converts a value to a string representation.
///
/// -> str
#let to-str(it) = {
  if type(it) == str {
    it
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

/// Converts a string to camel case format.
///
/// -> str
#let camel-case(body) = {
  to-str(body).split(" ").map(word => upper(word.at(0)) + lower(word.slice(1))).join("")
}

/// Converts a name string/content to format SURNAME, Given Name
/// 
/// -> str
#let format-name(body) = {
  let name_parts = to-str(body).split(" ")
  let surname = name_parts.first()
  let given_name = name_parts.last()
  upper(surname) + ", " + camel-case(given_name)
}