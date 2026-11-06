
/// Converts various types of content to a string representation.
///
/// - content (content):
///     The content to be converted to a string. This can be a string, boolean,
///     or a structured content object with text, children, or body properties. 
/// -> str
#let to-str(content) = {
  if type(content) == none {
    return ""
  }
  if type(content) == bool {
    return if content {
      "true"
    } else {
      "false"
    }
  }
  if type(content) == str {
    return content
  }
  if content.has("text") {
    if type(content.text) == str {
      content.text
    } else {
      to-str(content.text)
    }
  } else if content.has("children") {
    content.children.map(to-str).join("")
  } else if content.has("body") {
    to-str(content.body)
  } else if content == [ ] {
    ""
  } else {
    to-str([#content])
  }
}
