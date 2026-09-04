// Generic content-tree helpers. No CV-specific knowledge lives here.

#let flatten-text(node) = {
  if type(node) == str {
    node
  } else if node.func() == text {
    node.at("text")
  } else if node.has("children") {
    node.children.map(flatten-text).join("")
  } else if node.has("body") {
    flatten-text(node.at("body"))
  } else if repr(node.func()) == "space" {
    " "
  } else if node.has("text") {
    str(node.at("text"))
  } else {
    ""
  }
}

// Splits on the *last* occurrence of `sep`, trimming both sides. Second
// element is `none` if `sep` isn't present. Splitting on the last (not
// first) occurrence guards against a title/org value that itself contains
// `sep`.
#let split-last(s, sep) = {
  if sep in s {
    let parts = s.split(sep)
    (parts.slice(0, -1).join(sep).trim(), parts.last().trim())
  } else {
    (s.trim(), none)
  }
}

// Direct children of a node: its "children", its unwrapped "body", or
// itself wrapped in an array if it's a leaf (e.g. bare text).
#let get-children(node) = {
  if node.has("children") {
    node.children
  } else if node.has("body") {
    get-children(node.at("body"))
  } else {
    (node,)
  }
}
