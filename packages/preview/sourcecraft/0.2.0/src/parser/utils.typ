// =============================================================================
// sourcecraft — Parser Utilities
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

/// Split a parameter list without splitting commas inside generic arguments.
#let split-top-level(text, delimiter: ",") = {
  let parts = ()
  let current = ""
  let angle-depth = 0
  let paren-depth = 0
  let bracket-depth = 0

  for ch in text.clusters() {
    if ch == delimiter and angle-depth == 0 and paren-depth == 0 and bracket-depth == 0 {
      parts.push(current.trim())
      current = ""
    } else {
      current += ch
      if ch == "<" { angle-depth += 1 }
      if ch == ">" { angle-depth = calc.max(0, angle-depth - 1) }
      if ch == "(" { paren-depth += 1 }
      if ch == ")" { paren-depth = calc.max(0, paren-depth - 1) }
      if ch == "[" { bracket-depth += 1 }
      if ch == "]" { bracket-depth = calc.max(0, bracket-depth - 1) }
    }
  }

  if current.trim() != "" { parts.push(current.trim()) }
  parts
}

/// Return the non-primitive named types referenced by a Java/C# parameter.
/// For generic types, inspect their arguments (including nested generics)
/// rather than treating collection/container types as dependencies.
#let parameter-types(parameter) = {
  let declaration = parameter.split("=").at(0).trim()
  let name-match = declaration.match(regex("[A-Za-z_$][\\w$]*\\s*$"))
  if name-match == none { return () }

  let type-text = declaration.slice(0, name-match.start).trim()
  let words = type-text.split(regex("\\s+"))
  let modifiers = ("final", "ref", "out", "in", "params", "this", "scoped", "readonly")
  let first-type = 0
  while first-type < words.len() and words.at(first-type) in modifiers {
    first-type += 1
  }
  type-text = words.slice(first-type).join(" ")

  let targets = ()
  let generic-parts = type-text.matches(regex("<([^<>]*)>"))
  if generic-parts.len() > 0 {
    for generic in generic-parts {
      for argument in split-top-level(generic.captures.at(0)) {
        let names = argument.split(regex("[^A-Za-z0-9_.$]+")).filter(name => name != "")
        if names.len() > 0 {
          let target = names.last()
          if not is-primitive-type(target) and target not in targets {
            targets.push(target)
          }
        }
      }
    }
  } else {
    let cleaned-type = type-text
      .replace("...", "")
      .replace("[]", "")
      .replace("?", "")
      .trim()
    let target = cleaned-type.split(regex("\\s+")).last()
    if target != "" and not is-primitive-type(target) {
      targets.push(target)
    }
  }

  targets
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

/// Remove `//` line comments and `/* ... */` block comments (Javadoc and
/// `///` XML docs included) from Java/C# source.
///
/// - String and char literals are respected, so `"http://x"` or `'/'` never
///   start a comment. Their contents are blanked (`"..."` → `""`), so braces
///   or `new X(` inside a string cannot confuse the brace-based parser.
/// - C# verbatim strings (`@"..."`, where `""` is an escaped quote) are handled.
/// - Newlines are preserved, so the line structure of the source is kept.
#let strip-comments(source) = {
  let out = ()
  let mode = "code" // code | line | block | string | verbatim | char
  let prev = ""     // previous cluster (code mode only)
  let skip = false  // second char of a two-char token already consumed
  let chars = source.clusters()
  let n = chars.len()

  for i in range(n) {
    if skip { skip = false; continue }
    let ch = chars.at(i)
    let next = if i + 1 < n { chars.at(i + 1) } else { "" }

    if mode == "code" {
      if ch == "/" and next == "/" {
        mode = "line"; skip = true
      } else if ch == "/" and next == "*" {
        mode = "block"; skip = true
        out.push(" ") // keep tokens around the comment apart
      } else if ch == "\"" {
        mode = if prev == "@" or (prev == "$" and i >= 2 and chars.at(i - 2) == "@") { "verbatim" } else { "string" }
        out.push(ch)
      } else if ch == "'" {
        mode = "char"; out.push(ch)
      } else {
        out.push(ch)
      }
      prev = ch
    } else if mode == "line" {
      if ch == "\n" or ch == "\r\n" { mode = "code"; prev = ""; out.push(ch) }
    } else if mode == "block" {
      if ch == "*" and next == "/" { mode = "code"; skip = true; prev = "" }
      else if ch == "\n" or ch == "\r\n" { out.push(ch) }
    } else if mode == "string" or mode == "char" {
      let quote = if mode == "string" { "\"" } else { "'" }
      if ch == "\\" {
        // Escape sequence: drop the escaped char too (unless it is a newline)
        if next != "\n" and next != "\r\n" { skip = true }
      } else if ch == quote {
        mode = "code"; prev = ""; out.push(ch)
      } else if ch == "\n" or ch == "\r\n" {
        // Unterminated literal (or Java text block): keep the line structure
        out.push(ch)
      }
    } else if mode == "verbatim" {
      if ch == "\"" and next == "\"" { skip = true }
      else if ch == "\"" { mode = "code"; prev = ""; out.push(ch) }
      else if ch == "\n" or ch == "\r\n" { out.push(ch) }
    }
  }

  out.join()
}
