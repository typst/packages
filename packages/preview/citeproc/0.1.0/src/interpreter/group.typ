// citeproc-typst - Group and Choose Handlers
//
// Handles <group> and <choose> CSL elements.

#import "../core/mod.typ": apply-formatting, is-empty, join-with-delimiter
#import "../data/conditions.typ": eval-condition, eval-nested-conditions

// =============================================================================
// Module-level regex patterns (avoid recompilation)
// =============================================================================

#let _ends-with-digit-pattern = regex("[0-9][\\]\\)]*$")
#let _starts-with-latin-pattern = regex("^[\\[\\(]*[a-zA-Z]")

// =============================================================================
// CSL-M require/reject helpers (comma-safe locators)
// =============================================================================

/// Check if content ends with a number (for comma-safe detection)
#let _ends-with-number(content) = {
  let s = repr(content)
  s.match(_ends-with-digit-pattern) != none
}

/// Check if content starts with a "romanesque" (latin alphabet) term
#let _starts-with-latin(content) = {
  let s = repr(content)
  s.match(_starts-with-latin-pattern) != none
}

/// Evaluate CSL-M require/reject conditions
///
/// - require: "comma-safe" or "comma-safe-numbers-only"
/// - reject: same values (inverts the logic)
/// - ctx: Context with preceding-ends-with-number info
/// Returns: bool (true if group should render)
#let eval-comma-safe(require-val, reject-val, group-content, ctx) = {
  // Get preceding context info
  let preceding-ends-num = ctx.at("preceding-ends-with-number", default: false)
  let group-starts-latin = _starts-with-latin(group-content)

  let comma-safe-result = if (
    require-val == "comma-safe" or reject-val == "comma-safe"
  ) {
    // comma-safe is true when:
    // 1. Preceded by number AND (starts with latin term OR no term)
    // 2. Preceded by non-number AND starts with latin term
    if preceding-ends-num {
      true // Always comma-safe after number if we have content
    } else {
      group-starts-latin
    }
  } else if (
    require-val == "comma-safe-numbers-only"
      or reject-val == "comma-safe-numbers-only"
  ) {
    // Only true when preceded by a number
    preceding-ends-num
  } else {
    true // No require/reject, always render
  }

  // Apply require (must be true) or reject (must be false)
  if require-val != none {
    comma-safe-result
  } else if reject-val != none {
    not comma-safe-result
  } else {
    true
  }
}

/// Check if a node calls a variable (directly or via macro)
/// Optimized: avoid deep recursion - assume container elements call variables
#let node-calls-variable(node, ctx) = {
  if type(node) != dictionary { return false }
  let tag = node.at("tag", default: "")
  let attrs = node.at("attrs", default: (:))

  // Elements that directly call variables
  if tag == "text" and attrs.at("variable", default: none) != none {
    return true
  }
  if tag == "number" and attrs.at("variable", default: none) != none {
    return true
  }
  if tag == "names" and attrs.at("variable", default: none) != none {
    return true
  }
  if tag == "date" and attrs.at("variable", default: none) != none {
    return true
  }

  // Macro calls - assume they call variables (almost always true)
  if tag == "text" and attrs.at("macro", default: none) != none {
    return true
  }

  // Container elements - assume they may call variables
  // This avoids expensive O(n) recursion; the CSL spec behavior is preserved
  // because we still check if any variable has value via interpret results
  if tag in ("group", "choose", "layout", "if", "else-if", "else") {
    return true
  }

  false
}

/// Handle <group> element
/// Supports CSL-M require/reject for comma-safe locators
///
/// CSL spec: "Groups implicitly act as a conditional: cs:group and its child
/// elements are suppressed if a) at least one rendering element in cs:group
/// calls a variable (directly or via a macro), and b) all variables that are
/// called are empty."
#let handle-group(node, ctx, interpret) = {
  let attrs = node.at("attrs", default: (:))
  let children = node.at("children", default: ())

  // CSL-M require/reject attributes
  let require-val = attrs.at("require", default: none)
  let reject-val = attrs.at("reject", default: none)

  // Collect renderable parts, tracking variable calls and their outputs
  // This combines variable checking and rendering in a single pass
  let collect-parts-with-tracking(nodes, ctx, interpret) = {
    let parts = ()
    let has-variable-call = false
    let any-variable-has-value = false

    for n in nodes {
      if type(n) != dictionary { continue }
      let child-tag = n.at("tag", default: "")
      let child-children = n.at("children", default: ())

      if child-tag == "choose" {
        // Flatten: collect parts from matching branch
        for branch in child-children {
          if type(branch) != dictionary { continue }
          let branch-tag = branch.at("tag", default: "")
          let branch-attrs = branch.at("attrs", default: (:))
          let branch-children = branch.at("children", default: ())

          if branch-tag == "if" or branch-tag == "else-if" {
            if eval-condition(branch-attrs, ctx) {
              let sub = collect-parts-with-tracking(
                branch-children,
                ctx,
                interpret,
              )
              for part in sub.parts { parts.push(part) }
              if sub.has-variable-call { has-variable-call = true }
              if sub.any-variable-has-value { any-variable-has-value = true }
              break
            }
          } else if branch-tag == "else" {
            let sub = collect-parts-with-tracking(
              branch-children,
              ctx,
              interpret,
            )
            for part in sub.parts { parts.push(part) }
            if sub.has-variable-call { has-variable-call = true }
            if sub.any-variable-has-value { any-variable-has-value = true }
            break
          }
        }
      } else {
        // Check if this node calls a variable (fast check, no interpret)
        let calls-var = node-calls-variable(n, ctx)
        if calls-var { has-variable-call = true }

        // Render the node
        let result = interpret(n, ctx)
        if not is-empty(result) {
          parts.push(result)
          if calls-var { any-variable-has-value = true }
        }
      }
    }
    (
      parts: parts,
      has-variable-call: has-variable-call,
      any-variable-has-value: any-variable-has-value,
    )
  }

  let collected = collect-parts-with-tracking(children, ctx, interpret)

  // CSL spec: If group calls variables but all are empty, suppress entire group
  if collected.has-variable-call and not collected.any-variable-has-value {
    return []
  }

  let parts = collected.parts

  if parts.len() == 0 {
    []
  } else {
    let delimiter = attrs.at("delimiter", default: "")
    let prefix = attrs.at("prefix", default: "")
    let suffix = attrs.at("suffix", default: "")
    let joined = join-with-delimiter(parts, delimiter)
    let result = apply-formatting([#prefix#joined#suffix], attrs)

    // Apply CSL-M require/reject check
    if require-val != none or reject-val != none {
      if eval-comma-safe(require-val, reject-val, result, ctx) {
        result
      } else {
        []
      }
    } else {
      result
    }
  }
}

/// Handle <choose> element
/// Supports CSL-M nested cs:conditions
#let handle-choose(node, ctx, interpret) = {
  let children = node.at("children", default: ())

  for branch in children {
    if type(branch) != dictionary { continue }

    let branch-tag = branch.at("tag", default: "")
    let branch-attrs = branch.at("attrs", default: (:))
    let branch-children = branch.at("children", default: ())

    if branch-tag == "if" or branch-tag == "else-if" {
      // CSL-M extension: check for nested cs:conditions element
      let conditions-node = branch-children.find(c => (
        type(c) == dictionary and c.at("tag", default: "") == "conditions"
      ))

      let condition-met = if conditions-node != none {
        // Use nested conditions evaluation (CSL-M)
        eval-nested-conditions(conditions-node, ctx)
      } else {
        // Standard CSL condition evaluation
        eval-condition(branch-attrs, ctx)
      }

      if condition-met {
        // Filter out the conditions node from rendering
        return branch-children
          .filter(c => (
            type(c) != dictionary or c.at("tag", default: "") != "conditions"
          ))
          .map(n => interpret(n, ctx))
          .filter(x => not is-empty(x))
          .join()
      }
    } else if branch-tag == "else" {
      return branch-children
        .map(n => interpret(n, ctx))
        .filter(x => not is-empty(x))
        .join()
    }
  }
  []
}
