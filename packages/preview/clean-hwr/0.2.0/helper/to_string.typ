/// Converts arbitrary Typst content into a plain string.
///
/// This function recursively traverses the provided content and extracts
/// textual information. It handles:
/// - Strings: returned as-is
/// - Objects with `text` property: converts recursively
/// - Objects with `children` property: concatenates all children as strings
/// - Objects with `body` property: converts body recursively
/// - Empty content ([]): returns a single space
/// - Anything else: returns an empty string
///
/// Parameters:
/// - content (any Typst content):
///     The input content to convert into a string. Can be a string, array,
///     or structured Typst content object.
///
/// Returns:
/// - str: A plain string representation of the input content.
///
/// Example:
/// ```typst
/// #_to-string([
///   "Title: ", #text("My Thesis")
/// ])
/// // Returns: "Title: My Thesis"
/// ```
#let _to-string(content) = {
  if type(content) == str {
    content
  } else if content.has("text") {
    if type(content.text) == str {
      content.text
    } else {
      _to-string(content.text)
    }
  } else if content.has("children") {
    content.children.map(_to-string).join("")
  } else if content.has("body") {
    _to-string(content.body)
  } else if content == [ ] {
    " "
  } else {
    ""
  }
}
