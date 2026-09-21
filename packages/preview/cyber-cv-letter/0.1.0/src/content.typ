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
// itself wrapped in an array if it's a leaf (e.g. bare text). `link` is
// treated as a leaf despite having a "body" field — that body is the link's
// own visible label, not a wrapping layer, and descending into it would
// silently drop the link's `dest` (e.g. a meta line that is nothing but
// `[text](url)`, as in a Projects entry's whole link-only line).
#let get-children(node) = {
  if node.has("children") {
    node.children
  } else if node.func() == link {
    (node,)
  } else if node.has("body") {
    get-children(node.at("body"))
  } else {
    (node,)
  }
}

// Re-joins a node list back into one content value. `nodes` is always an
// array of content (never bare strings) — callers that build replacement
// leaves from a string must wrap them with `text(...)` first.
#let join-nodes(nodes) = nodes.fold([], (acc, node) => acc + node)

// Content-preserving analogue of split-last(string, sep): splits a flat
// child-node list on the last occurrence of `sep`, keeping every other
// node's own markup (links, emphasis, ...) intact on both sides. Only the
// one node that textually contains `sep` is rebuilt as plain text — true for
// every meta line in practice, since "|" only ever appears as a bare
// separator between plain org/location text, never inside a link label.
#let split-last-nodes(nodes, sep) = {
  let sep-idx = none
  for (i, node) in nodes.enumerate() {
    if sep in flatten-text(node) { sep-idx = i }
  }
  if sep-idx == none {
    (join-nodes(nodes), none)
  } else {
    let (before-text, after-text) = split-last(flatten-text(nodes.at(sep-idx)), sep)
    let before = nodes.slice(0, sep-idx) + (if before-text != "" { (text(before-text),) } else { () })
    let after-text = if after-text == none { "" } else { after-text }
    let after = (if after-text != "" { (text(after-text),) } else { () }) + nodes.slice(sep-idx + 1)
    (join-nodes(before), if after.len() == 0 { none } else { join-nodes(after) })
  }
}
