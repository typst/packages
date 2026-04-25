// =============================================================================
// source-to-class-diagram — Grammar Registry
// =============================================================================
// Central registry of available grammars.
// Each grammar must export a `parse(source) -> IR` function.

#import "java.typ"
#import "csharp.typ"

/// Built-in grammars: name → parse function.
#let builtin-grammars = (
  java:   java.parse,
  csharp: csharp.parse,
)

/// Resolve a grammar by name (string) or accept a custom parse function.
///
/// - grammar (str or function): Grammar identifier or custom parser function.
/// Returns: A parse function `(str) -> IR`.
#let resolve-grammar(grammar) = {
  if type(grammar) == str {
    assert(
      grammar in builtin-grammars,
      message: "Grammar '" + grammar + "' not found. Available: " + builtin-grammars.keys().join(", "),
    )
    builtin-grammars.at(grammar)
  } else if type(grammar) == function {
    grammar
  } else {
    panic("Grammar must be a string name or a parse function, got: " + str(type(grammar)))
  }
}
