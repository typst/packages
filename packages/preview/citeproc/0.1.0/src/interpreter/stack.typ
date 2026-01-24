// citeproc-typst - Stack-based Interpreter with Memoization
//
// This is the PRODUCTION interpreter for CSL AST interpretation.
// Uses an explicit stack instead of recursion to enable mutable macro cache.
// This reduces O(calls * depth) to O(unique macros) for macro expansion.
//
// For a clearer recursive reference implementation, see mod.typ.

#import "../core/mod.typ": finalize, is-empty
#import "../data/conditions.typ": eval-condition
#import "../data/variables.typ": get-variable
#import "../parsing/locales.typ": lookup-term
#import "../text/ranges.typ": format-page-range
#import "../text/quotes.typ": apply-quotes
#import "names.typ": handle-names
#import "date.typ": handle-date
#import "number.typ": handle-label, handle-number

/// Stack item states
/// - "pending": Node not yet processed
/// - "children-pending": Waiting for children to complete
/// - "macro-pending": Waiting for macro children to complete

/// Process a leaf node (text variable/value/term, number, label)
#let process-leaf(node, ctx) = {
  let tag = node.at("tag", default: "")
  let attrs = node.at("attrs", default: (:))

  if tag == "text" {
    let result = if "variable" in attrs {
      let var-name = attrs.variable
      let val = get-variable(ctx, var-name)
      if val != "" {
        if var-name == "page" or var-name == "page-first" {
          let page-format = ctx.style.at("page-range-format", default: none)
          format-page-range(val, format: page-format, ctx: ctx)
        } else { val }
      } else { [] }
    } else if "value" in attrs {
      attrs.value
    } else if "term" in attrs {
      let form = attrs.at("form", default: "long")
      let plural = attrs.at("plural", default: "false") == "true"
      lookup-term(ctx, attrs.term, form: form, plural: plural)
    } else { [] }

    // Apply quotes if requested
    let quoted = if (
      attrs.at("quotes", default: "false") == "true" and not is-empty(result)
    ) {
      apply-quotes(result, ctx, level: 0)
    } else { result }

    finalize(quoted, attrs)
  } else if tag == "number" {
    handle-number(node, ctx, n => []) // Simple fallback
  } else if tag == "label" {
    handle-label(node, ctx, n => [])
  } else if tag == "names" {
    // Names handler uses stack interpreter internally
    handle-names(node, ctx)
  } else if tag == "date" {
    // Date handler doesn't need interpreter
    handle-date(node, ctx)
  } else {
    []
  }
}

/// Check if a node is a simple leaf (can be processed immediately)
#let is-leaf(node) = {
  if type(node) != dictionary { return true }
  let tag = node.at("tag", default: "")
  let attrs = node.at("attrs", default: (:))

  // Macro calls are not leaves
  if tag == "text" and "macro" in attrs { return false }
  // Groups and choose are not leaves
  if tag in ("group", "choose") { return false }
  // Everything else is a leaf
  true
}

/// Stack-based interpreter with memoization
/// - children: List of nodes to interpret
/// - ctx: Interpretation context
/// - delimiter: Optional delimiter for joining top-level results
/// Returns: Joined content from all children
#let interpret-children-stack(children, ctx, delimiter: none) = {
  if children.len() == 0 { return [] }

  // Work stack: (node, state, meta)
  // Result stack: stores results as they complete
  // Macro cache (mutable within this function!)
  let macro-cache = (:)
  let results = ()

  // Initialize stack with children (reversed for correct order)
  let stack = children.rev().map(c => (node: c, state: "pending", meta: (:)))

  // Process stack
  while stack.len() > 0 {
    let item = stack.pop()
    let node = item.node
    let state = item.state
    let meta = item.meta

    // Handle string nodes
    if type(node) == str {
      results.push(node.trim())
      continue
    }

    // Handle non-dict nodes
    if type(node) != dictionary {
      results.push([])
      continue
    }

    let tag = node.at("tag", default: "")
    let attrs = node.at("attrs", default: (:))
    let node-children = node.at("children", default: ())

    if state == "pending" {
      // Check for macro call
      if tag == "text" and "macro" in attrs {
        let macro-name = attrs.macro

        // Check cache first!
        if macro-name in macro-cache {
          // Cache hit - use cached result with formatting
          let cached = macro-cache.at(macro-name)
          results.push(finalize(cached, attrs))
        } else {
          // Cache miss - need to compute
          let macro-def = ctx.macros.at(macro-name, default: none)
          if macro-def != none and macro-def.children.len() > 0 {
            // Push marker for when children complete
            stack.push((
              node: node,
              state: "macro-pending",
              meta: (
                macro-name: macro-name,
                child-count: macro-def.children.len(),
                attrs: attrs,
              ),
            ))
            // Push macro children (reversed)
            for c in macro-def.children.rev() {
              stack.push((node: c, state: "pending", meta: (:)))
            }
          } else {
            // Empty or missing macro
            macro-cache.insert(macro-name, [])
            results.push([])
          }
        }
      } else if tag == "group" {
        if node-children.len() > 0 {
          // Push marker for when children complete
          stack.push((
            node: node,
            state: "group-pending",
            meta: (child-count: node-children.len(), attrs: attrs),
          ))
          // Push children (reversed)
          for c in node-children.rev() {
            stack.push((node: c, state: "pending", meta: (:)))
          }
        } else {
          results.push([])
        }
      } else if tag == "choose" {
        // Choose: evaluate conditions and process matching branch
        let matched = false
        for branch in node-children {
          if type(branch) != dictionary { continue }
          let branch-tag = branch.at("tag", default: "")
          let branch-attrs = branch.at("attrs", default: (:))
          let branch-children = branch.at("children", default: ())

          let should-take = if branch-tag == "if" or branch-tag == "else-if" {
            eval-condition(branch-attrs, ctx)
          } else if branch-tag == "else" {
            true
          } else {
            false
          }

          if should-take {
            if branch-children.len() > 0 {
              stack.push((
                node: node,
                state: "choose-pending",
                meta: (child-count: branch-children.len()),
              ))
              for c in branch-children.rev() {
                stack.push((node: c, state: "pending", meta: (:)))
              }
            } else {
              results.push([])
            }
            matched = true
            break
          }
        }
        // If no branch matched, push empty result
        if not matched {
          results.push([])
        }
      } else {
        // Leaf node - process immediately
        results.push(process-leaf(node, ctx))
      }
    } else if state == "macro-pending" {
      // Macro children completed - collect last N results (already in correct order)
      let child-count = meta.child-count
      let ordered = results.slice(-child-count)
      results = results.slice(0, results.len() - child-count)

      // Join non-empty results
      let joined = ordered.filter(x => not is-empty(x)).join()

      // Cache the raw result (without formatting)
      macro-cache.insert(meta.macro-name, joined)

      // Apply formatting and push
      results.push(finalize(joined, meta.attrs))
    } else if state == "group-pending" {
      // Group children completed - collect last N results (already in correct order)
      let child-count = meta.child-count
      let ordered = results.slice(-child-count)
      results = results.slice(0, results.len() - child-count)

      // Join with delimiter
      let group-delimiter = meta.attrs.at("delimiter", default: "")
      let parts = ordered.filter(x => not is-empty(x))
      let joined = if group-delimiter != "" and parts.len() > 1 {
        parts.join(group-delimiter)
      } else {
        parts.join()
      }

      // Apply prefix/suffix
      let prefix = meta.attrs.at("prefix", default: "")
      let suffix = meta.attrs.at("suffix", default: "")
      if not is-empty(joined) {
        results.push([#prefix#joined#suffix])
      } else {
        results.push([])
      }
    } else if state == "choose-pending" {
      // Choose branch completed - collect last N results (already in correct order)
      let child-count = meta.child-count
      let ordered = results.slice(-child-count)
      results = results.slice(0, results.len() - child-count)

      let joined = ordered.filter(x => not is-empty(x)).join()
      results.push(joined)
    }
  }

  // Final result: join all top-level results with optional delimiter
  let final-results = results.filter(x => not is-empty(x))
  if delimiter != none {
    final-results.join(delimiter)
  } else {
    final-results.join()
  }
}

/// Convenience function to interpret a single node with stack
#let interpret-node-stack(node, ctx) = {
  interpret-children-stack((node,), ctx)
}
