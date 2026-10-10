#import "utils.typ": _sourcecraft-to-mastermind

#let wasm = plugin("mastermind-parser.wasm")

/// Parse Java source using the bundled Tree-sitter grammar.
/// -> dictionary
#let parse-java(source) = {
  let result = json(wasm.parse_java(bytes(source)))
  _sourcecraft-to-mastermind(classes: result.classes, relations: result.relations)
}

/// Parse C# source using the bundled Tree-sitter grammar.
#let parse-csharp(source) = {
  let result = json(wasm.parse_csharp(bytes(source)))
  _sourcecraft-to-mastermind(classes: result.classes, relations: result.relations)
}

/// Parse PHP source using the bundled Tree-sitter grammar.
#let parse-php(source, filename: none) = {
  let result = if filename == none {
    json(wasm.parse_php(bytes(source)))
  } else {
    json(wasm.parse_php_named(bytes(source), bytes(filename)))
  }
  _sourcecraft-to-mastermind(classes: result.classes, relations: result.relations)
}
