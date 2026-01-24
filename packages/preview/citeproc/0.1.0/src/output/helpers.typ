// citeproc-typst - Output Helpers Module
//
// Helper functions for CSL output processing.

// =============================================================================
// Node Traversal Helpers
// =============================================================================

/// Get macro definition from a text node if it references one
///
/// - node: Node to check (must be a text node)
/// - macros: Dictionary of macro definitions
/// Returns: (macro-name, macro-def) tuple or none
#let _get-macro-ref(node, macros) = {
  let macro-name = node.at("attrs", default: (:)).at("macro", default: none)
  if macro-name == none { return none }

  let macro-def = macros.at(macro-name, default: none)
  if macro-def == none { return none }

  (name: macro-name, def: macro-def)
}

/// Find first cs:names element in a node tree (recursive)
///
/// CSL spec: "The comparison is limited to the output of the (first) cs:names element"
/// This version follows macro references to find names inside macros.
///
/// - node: Current node to search
/// - macros: Dictionary of macro definitions (from style.macros)
/// Returns: First names node found, or none
#let find-first-names-node(node, macros: (:)) = {
  if type(node) != dictionary { return none }

  let tag = node.at("tag", default: "")
  if tag == "names" { return node }

  // Handle macro references: <text macro="name"/>
  if tag == "text" {
    let macro-ref = _get-macro-ref(node, macros)
    if macro-ref != none {
      for child in macro-ref.def.at("children", default: ()) {
        let found = find-first-names-node(child, macros: macros)
        if found != none { return found }
      }
    }
  }

  for child in node.at("children", default: ()) {
    let found = find-first-names-node(child, macros: macros)
    if found != none { return found }
  }
  none
}

/// Find the first macro that calls cs:names in a layout node
///
/// Returns the macro name (string) if found via <text macro="...">, or none
/// This is used to render the full macro for display (not just the names node).
///
/// - node: Current node to search
/// - macros: Dictionary of macro definitions (from style.macros)
/// Returns: (macro-name, text-node) tuple if found, or none
#let find-first-names-macro(node, macros: (:)) = {
  if type(node) != dictionary { return none }

  let tag = node.at("tag", default: "")

  // Handle macro references: <text macro="name"/>
  if tag == "text" {
    let macro-ref = _get-macro-ref(node, macros)
    if macro-ref != none {
      // Check if this macro contains names
      for child in macro-ref.def.at("children", default: ()) {
        let found = find-first-names-node(child, macros: macros)
        if found != none {
          // This macro contains names - return the macro name and the text node
          return (macro-name: macro-ref.name, text-node: node)
        }
      }
    }
  }

  for child in node.at("children", default: ()) {
    let found = find-first-names-macro(child, macros: macros)
    if found != none { return found }
  }
  none
}

// =============================================================================
// Content Conversion
// =============================================================================

/// Extract plain text from content recursively
#let content-to-string(c) = {
  if c == none or c == [] { return "" }
  if type(c) == str { return c }
  if type(c) == int or type(c) == float { return str(c) }

  // For content, try to get its text representation
  // This handles sequences, text nodes, etc.
  let text-func = c.func()
  let fields = c.fields()

  if text-func == text {
    // Text node - extract the body
    let body = fields.at("body", default: fields.at("text", default: ""))
    if type(body) == str { body } else { content-to-string(body) }
  } else if "children" in fields {
    // Sequence or container with children
    fields.children.map(content-to-string).join("")
  } else if "body" in fields {
    // Container with body
    content-to-string(fields.body)
  } else if "child" in fields {
    // Container with single child
    content-to-string(fields.child)
  } else if "text" in fields {
    // Direct text field
    if type(fields.text) == str { fields.text } else {
      content-to-string(fields.text)
    }
  } else {
    // Fallback: just return empty string for unknown content types
    ""
  }
}

// =============================================================================
// Citation Number Detection
// =============================================================================

/// Check if a node uses citation-number variable (for filtering)
/// Handles both direct <text variable="citation-number"> and <text macro="citation-number">
#let node-uses-citation-number(node) = {
  if type(node) != dictionary { return false }
  if node.at("tag", default: "") != "text" { return false }

  let attrs = node.at("attrs", default: (:))
  (
    attrs.at("variable", default: "") == "citation-number"
      or attrs.at(
        "macro",
        default: "",
      )
        == "citation-number"
  )
}

/// Check if any child in a list uses citation-number
#let _children-use-citation-number(children) = {
  for child in children {
    if node-uses-citation-number(child) { return true }
  }
  false
}

/// Check if style uses citation-number variable
/// Uses simple search on macro definitions instead of recursive AST traversal
/// This avoids stack overflow on deeply nested CSL structures
#let style-uses-citation-number(style) = {
  // Check if any macro definition contains citation-number reference
  let macros = style.at("macros", default: (:))
  for (name, macro-def) in macros {
    if _children-use-citation-number(macro-def.at("children", default: ())) {
      return true
    }
  }

  // Check bibliography layouts directly (first level only)
  let bib = style.at("bibliography", default: none)
  if bib != none {
    let layouts = bib.at("layouts", default: ())
    for layout in layouts {
      if _children-use-citation-number(layout.at("children", default: ())) {
        return true
      }
    }
  }

  false
}
