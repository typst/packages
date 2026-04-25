// =============================================================================
// source-to-class-diagram — Parser Utilities
// =============================================================================
// Shared string-parsing helpers used by all grammars.

/// Java/C# visibility keyword → IR visibility value.
#let parse-visibility-keyword(word) = {
  if word == "public" { "public" } else if word == "private" { "private" } else if word == "protected" {
    "protected"
  } else { none }
}

/// Check if a type name is a Java/C# primitive (won't generate a relation).
#let is-primitive-type(type-name) = {
  let primitives = (
    "int",
    "float",
    "double",
    "boolean",
    "bool",
    "char",
    "byte",
    "short",
    "long",
    "void",
    "String",
    "string",
    "Integer",
    "Float",
    "Double",
    "Boolean",
    "Character",
    "Byte",
    "Short",
    "Long",
    "Object",
    "object",
    "var",
    "dynamic",
  )
  type-name in primitives
}

/// Extract content between matching delimiters (e.g., "<" and ">").
/// Returns the content string or none.
#let extract-between(text, open, close) = {
  let start = text.match(regex("\\" + open))
  if start == none { return none }
  let after = text.slice(start.end)
  let end = after.match(regex("\\" + close))
  if end == none { return none }
  after.slice(0, end.start)
}

/// Extract stereotype text from <<Name>>.
/// Returns the stereotype string or none.
#let parse-stereotype(text) = {
  let m = text.match(regex("<<([^>]+)>>"))
  if m != none { m.captures.at(0) } else { none }
}

/// Extract generic type from <T> or <T extends Foo>.
/// Returns the generics string or none.
#let parse-generics(text) = {
  let m = text.match(regex("<([^>]+)>"))
  if m != none { m.captures.at(0) } else { none }
}

/// Parse cardinality and class name from a relation side.
/// Input: text like `Class01`, `Class01 "1"`, `"many" Class02`
/// Returns: (name: str, card: str or none)
#let parse-relation-side(text) = {
  let trimmed = text.trim()
  let card = none
  let name = trimmed

  // Check for quoted cardinality
  let card-match = trimmed.match(regex("\"([^\"]+)\""))
  if card-match != none {
    card = card-match.captures.at(0)
    name = trimmed.replace(card-match.text, "").trim()
  }

  (name: name, card: card)
}
