// citeproc-typst - CSL Interpreter Module
//
// This module provides the recursive reference implementation of the CSL interpreter.
// Production code uses the stack-based interpreter in stack.typ for better performance.
//
// Exports:
// - create-context: Context factory for CSL interpretation
// - interpret-node: Recursive node interpreter (reference implementation only)

#import "../core/mod.typ": is-empty

// Import handlers
#import "text.typ": handle-text
#import "group.typ": handle-choose, handle-group, node-calls-variable
#import "names.typ": handle-names
#import "date.typ": handle-date
#import "number.typ": handle-label, handle-number

// Re-export context creation
#import "../core/mod.typ": create-context

// =============================================================================
// Noop and Unknown Handlers
// =============================================================================

/// Handle ignored child elements (processed by parent)
#let handle-noop(node, ctx, interpret) = []

/// Handle unknown elements (try to interpret children)
#let handle-unknown(node, ctx, interpret) = {
  let children = node.at("children", default: ())
  children.map(n => interpret(n, ctx)).filter(x => not is-empty(x)).join()
}

// =============================================================================
// Dispatch Table
// =============================================================================

/// Map tag names to handler functions
#let _tag-handlers = (
  "text": handle-text,
  "group": handle-group,
  "choose": handle-choose,
  "names": handle-names,
  "date": handle-date,
  "number": handle-number,
  "label": handle-label,
  // Child elements handled by parents
  "substitute": handle-noop,
  "name": handle-noop,
  "name-part": handle-noop,
  "institution": handle-noop,
  "date-part": handle-noop,
  "et-al": handle-noop,
)

// =============================================================================
// Main Interpreter
// =============================================================================

/// Interpret a single CSL node (RECURSIVE - NOT USED IN PRODUCTION)
///
/// This is the recursive reference implementation. For production use,
/// see interpret-children-stack() in stack.typ which provides memoization.
///
/// - node: CSL AST node (dict with tag, attrs, children)
/// - ctx: Interpretation context
/// Returns: Typst content
#let interpret-node(node, ctx) = {
  // String nodes are literal text
  if type(node) == str {
    return node.trim()
  }

  // Skip non-element nodes
  if type(node) != dictionary {
    return []
  }

  let tag = node.at("tag", default: "")

  // Dispatch to handler
  let handler = _tag-handlers.at(tag, default: handle-unknown)
  handler(node, ctx, interpret-node)
}
