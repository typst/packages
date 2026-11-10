// integrated from https://github.com/typst-things/sourcecraft

// =============================================================================
// sourcecraft — Parser Utilities
// =============================================================================
// Shared string-parsing helpers used by all grammars.

#import "../classes.typ": class
#import "../relationships.typ": *

/// Java/C\# visibility keyword → IR visibility value.
/// -> content
#let parse-visibility-keyword(word) = {
  if word == "public" { "public" } else if word == "private" { "private" } else if word == "protected" {
    "protected"
  } else { none }
}

/// Check if a type name is a Java/C\# primitive (won't generate a relation).
/// -> bool
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
/// -> string | none
#let extract-between(text, open, close) = {
  let start = text.match(regex("\\" + open))
  if start == none { return none }
  let after = text.slice(start.end)
  let end = after.match(regex("\\" + close))
  if end == none { return none }
  after.slice(0, end.start)
}

/// Extract stereotype text from `<<Name>>`.
/// -> string | none
#let parse-stereotype(text) = {
  let m = text.match(regex("<<([^>]+)>>"))
  if m != none { m.captures.at(0) } else { none }
}

/// Extract generic type from `<T>` or `<T extends Foo>`.
/// -> string | none
#let parse-generics(text) = {
  let m = text.match(regex("<([^>]+)>"))
  if m != none { m.captures.at(0) } else { none }
}

/// Parse cardinality and class name from a relation side.
/// Input: text like `Class01`, `Class01 "1"`, `"many" Class02`
/// -> dictionary
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

/// Get the visibility of the class
/// -> string
#let _get-visibility(e) = if e.visibility == "private" {
  return "-"
} else if e.visibility == "public" {
  return "+"
} else if e.visibility == "protected" {
  return "#"
} else {
  return "~"
}

/// Map sourcecraft types to mastermind's
/// -> content
#let _sourcecraft-to-mastermind(classes: (:), relations: (:)) = {
  let mastermind-classes = classes.map(e => {
    return class(
      e.name,
      type: e.type,
      attributes: e
        .members
        .filter(e => e.kind == "field")
        .map(e => {
          let out
          out += _get-visibility(e) + " "
          out += e.name
          if e.return-type != none { out += ": " + e.return-type }
          return out
        }),
      methods: e
        .members
        .filter(e => e.kind == "method")
        .map(e => {
          let out
          out += _get-visibility(e) + " "
          out += e.name + "()"
          if e.return-type != none { out += ": " + e.return-type }
          return out
        }),
    )
  })

  let mastermind-relations = relations.map(e => {
    let (from, to) = (e.from, e.to)
    if e.type == "inheritance" {
      inheritance(from, to)
    } else if e.type == "dependency" {
      dependency(from, to)
    } else if e.type == "association" {
      association(from, to)
    } else if e.type == "aggregation" {
      aggregation(from, to)
    } else if e.type == "composition" {
      composition(from, to)
    } else if e.type == "implementation" {
      implementation(from, to)
    } else {
      panic("Relationship not found.")
    }
  })

  return (classes: mastermind-classes, relations: mastermind-relations)
}
