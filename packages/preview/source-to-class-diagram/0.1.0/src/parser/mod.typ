// =============================================================================
// source-to-class-diagram — Parser Orchestrator
// =============================================================================
// Routes source text through the appropriate grammar parser.

#import "../grammars/mod.typ" as grammars

/// Parse source text using the specified grammar.
/// Returns a validated IR dictionary.
///
/// - source (str): The source text to parse
/// - grammar (str or function): Grammar name or custom parse function
#let parse(source, grammar: "java") = {
  let parse-fn = grammars.resolve-grammar(grammar)
  let ir = parse-fn(source)

  // Validate IR structure
  assert(type(ir) == dictionary, message: "Parser must return a dictionary")
  assert("classes" in ir, message: "IR missing 'classes' field")
  assert("relations" in ir, message: "IR missing 'relations' field")

  ir
}
