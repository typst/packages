// citrus - Stack-based Interpreter with Memoization
//
// This is the PRODUCTION interpreter for CSL AST interpretation.
// Uses an explicit stack instead of recursion to enable mutable macro cache.
// This reduces O(calls * depth) to O(unique macros) for macro expansion.
//
// Results are stored as (content, var-state, done-vars) tuples:
// - content: The rendered content
// - var-state: One of "var", "no-var", or "none" (for group suppression)
// - done-vars: Array of variable names that were rendered (for substitute quashing)
//
// var-state values:
//   - "var": Has variable output (variables were referenced and produced content)
//   - "no-var": Referenced variables but all were empty
//   - "none": No variable references (only terms/values/conditions)
//
// CSL Group Suppression rule:
//   - If any child has "var" state: render group normally
//   - If all children have "no-var" state: suppress entire group
//   - If all children have "none" state: render group normally (no variables involved)
//
// CSL Substitute Quashing rule:
//   - Variables rendered through <substitute> are added to done-vars
//   - Subsequent references to those variables produce no output

#import "../core/mod.typ": (
  apply-text-case, capitalize-first-char, finalize, fold-superscripts, is-empty,
)

// Module-level regex patterns (avoid recompilation in hot loops)
#let _re-quote-chars = regex("[\"\u{201C}\u{201D}]")
#let _re-single-quotes = regex("[\u{2018}\u{2019}']")
#let _re-double-quotes = regex("[\u{201C}\u{201D}\"]")
#let _re-single-quote-pair = regex(
  "(^|[\\s\\(\\[])[\u{2018}\u{2019}']([^'\u{2018}\u{2019}]+)[\u{2018}\u{2019}']",
)
#let _re-rsq-rdq-end = regex("\u{2019}\u{201D}$")
#let _re-rsq-end = regex("\u{2019}$")
#let _re-rdq-end = regex("\u{201D}$")
#let _re-digit = regex("\\d")

#let _attr-true(val) = if type(val) == bool { val } else { val == "true" }
#import "../data/conditions.typ": eval-condition
#import "../data/variables.typ": get-variable
#import "../parsing/mod.typ": lookup-term
#import "../text/ranges.typ": format-number-range, format-page-range
#import "../text/quotes.typ": apply-quotes, transform-quotes-at-level
#import "../output/punctuation.typ": get-punctuation-in-quote

#let _fix-inner-quotes(text, ctx, quote-level, has-quotes) = {
  if not has-quotes { return text }
  if type(text) != str {
    let fields = text.fields()
    if text.func() == text {
      let body = fields.at("text", default: fields.at("body", default: none))
      if (
        type(body) == str and body.match(_re-quote-chars) != none
      ) {
        let normalized = transform-quotes-at-level(body, ctx, 1)
        return text(normalized)
      }
    }
    return text
  }
  if text.match(_re-quote-chars) == none { return text }
  transform-quotes-at-level(text, ctx, 1)
}
#import "../text/names.typ": _resolve-et-al-settings, names-end-flag
#import "../output/helpers.typ": content-to-string
#import "names.typ": handle-names
#import "date.typ": handle-date
#import "number.typ": handle-label, handle-number

/// Merge var-states from multiple children
/// Priority: "var" > "no-var" > "none"
#let merge-var-state(states) = {
  if states.any(s => s == "var") { "var" } else if states.any(s => (
    s == "no-var"
  )) { "no-var" } else { "none" }
}

/// Check if group should be suppressed based on var-states
///
/// CSL spec: "cs:group and its child elements are suppressed if
/// a) at least one rendering element in cs:group calls a variable, and
/// b) all variables that are called are empty."
///
/// This means: if group contains any variable call AND all variables are empty,
/// suppress the entire group INCLUDING terms/values.
#let should-suppress-group(states) = {
  let has-any-var = states.any(s => s == "var")
  let has-any-no-var = states.any(s => s == "no-var")

  // Condition a): at least one element calls a variable (either "var" or "no-var")
  let has-variable-call = has-any-var or has-any-no-var

  // If no variable calls at all, don't suppress (pure term/value group)
  if not has-variable-call { return false }

  // Condition b): all called variables are empty (no "var" state)
  // If any variable produced output, don't suppress
  if has-any-var { return false }

  // Both conditions met: has variable calls, but all are empty -> suppress
  true
}

/// Process a leaf node (text variable/value/term, number, label)
/// Returns: (content, var-state, done-vars)
#let process-leaf(node, ctx) = {
  let tag = node.at("tag", default: "")
  let attrs = node.at("attrs", default: (:))
  let done-vars = ctx.at("done-vars", default: ())

  if tag == "text" {
    if "variable" in attrs {
      let var-name = attrs.variable

      // CSL Substitute Quashing: skip if variable already rendered via substitute
      if var-name in done-vars {
        return ([], "none", (), false)
      }

      let form = attrs.at("form", default: "long")

      // CSL form="short": try variable-short first, fallback to variable
      let val = if form == "short" {
        let short-name = var-name + "-short"
        let short-val = get-variable(ctx, short-name)
        if short-val != "" { short-val } else { get-variable(ctx, var-name) }
      } else {
        get-variable(ctx, var-name)
      }

      if val != "" {
        let result = if var-name == "page" or var-name == "page-first" {
          let page-format = ctx.style.at("page-range-format", default: none)
          format-page-range(val, format: page-format, ctx: ctx)
        } else if var-name == "locator" {
          format-page-range(val, format: "expanded", ctx: ctx)
        } else if var-name == "issue" {
          format-number-range(val, ctx: ctx)
        } else { val }

        // Apply text-case FIRST while content is still a string
        // CSL spec: text-case transformation happens before quotes are added
        // CSL spec: title case only applies to English content
        let cased = apply-text-case(result, attrs, ctx: ctx)
        let folded = fold-superscripts(cased)

        // Normalize embedded quotes in content
        // CSL spec: quotes in field content should be normalized to proper level
        // - At level 0 (not inside quotes): single quotes -> double quotes
        // - At level 1 (inside outer quotes): double quotes -> single quotes
        let quote-level = ctx.at("quote-level", default: 0)
        let has-single = folded.match(_re-single-quotes) != none
        let has-double = folded.match(_re-double-quotes) != none
        let effective-level = if (
          not _attr-true(attrs.at("quotes", default: "false"))
            and quote-level == 1
            and has-single
            and not has-double
        ) { 0 } else { quote-level }
        let normalized = if type(folded) == str {
          // Always normalize quotes, even without quotes="true"
          // The target level depends on whether we're adding outer quotes
          let has-quotes = _attr-true(attrs.at("quotes", default: "false"))
          if has-quotes {
            // Will add outer quotes, so embedded quotes go to level+1
            transform-quotes-at-level(folded, ctx, effective-level + 1)
          } else {
            // No outer quotes, normalize to current level
            transform-quotes-at-level(folded, ctx, effective-level)
          }
        } else { folded }
        let normalized = if type(normalized) == str {
          normalized.replace(
            _re-single-quote-pair,
            m => (
              m.captures.at(0) + "\"" + m.captures.at(1) + "\""
            ),
          )
        } else { normalized }

        // Apply quotes if requested (after normalization)
        let has-quotes = _attr-true(attrs.at("quotes", default: "false"))
        let fixed = _fix-inner-quotes(normalized, ctx, quote-level, has-quotes)
        let quoted = if has-quotes {
          apply-quotes(fixed, ctx, level: quote-level)
        } else { fixed }
        if type(quoted) != str and quoted.func() == text {
          let body = quoted
            .fields()
            .at(
              "text",
              default: quoted.fields().at("body", default: ""),
            )
          if type(body) == str and body != "" {
            quoted = body
          }
        }

        // punctuation-in-quote: move period/comma inside quotes
        let suffix = attrs.at("suffix", default: "")
        let piq = if "style" in ctx {
          get-punctuation-in-quote(ctx.style)
        } else { false }
        let adjusted-attrs = if (
          _attr-true(attrs.at("quotes", default: "false"))
            and piq
            and suffix.len() > 0
            and suffix.first() in (".", ",")
        ) {
          if type(quoted) == str {
            if suffix.first() == "." and quoted.ends-with("\u{2019}\u{201D}") {
              quoted = quoted.replace(
                _re-rsq-rdq-end,
                ".\u{2019}\u{201D}",
              )
            } else if suffix.first() == "." and quoted.ends-with("\u{2019}") {
              quoted = quoted.replace(_re-rsq-end, ".\u{2019}")
            } else if not quoted.ends-with(suffix.first()) {
              quoted = quoted + suffix.first()
            }
          } else if quoted.func() == text {
            let fields = quoted.fields()
            let body = fields.at("text", default: fields.at(
              "body",
              default: none,
            ))
            if type(body) == str and body.ends-with("\u{201D}") {
              let updated = if (
                suffix.first() == "." and body.ends-with("\u{2019}\u{201D}")
              ) {
                body.replace(_re-rsq-rdq-end, ".\u{2019}\u{201D}")
              } else {
                body.replace(_re-rdq-end, suffix.first() + "\u{201D}")
              }
              quoted = text(updated)
            }
          }
          (..attrs, suffix: suffix.slice(1))
        } else { attrs }

        let final-attrs = if type(quoted) == str {
          (..adjusted-attrs, "_ends-with-period": quoted.ends-with("."))
        } else { adjusted-attrs }
        let ends = if type(quoted) == str { quoted.ends-with(".") } else {
          false
        }
        (finalize(quoted, final-attrs), "var", (), ends) // Variable has output
      } else if var-name == "year-suffix" {
        let suffix = ctx.at("year-suffix", default: none)
        if suffix != none and suffix != "" {
          import "../data/collapsing.typ": num-to-suffix
          let suffix-str = if type(suffix) == int {
            num-to-suffix(suffix)
          } else {
            str(suffix)
          }
          let cased = apply-text-case(suffix-str, attrs, ctx: ctx)
          let quote-level = ctx.at("quote-level", default: 0)
          let normalized = if type(cased) == str {
            let has-quotes = _attr-true(attrs.at("quotes", default: "false"))
            if has-quotes {
              transform-quotes-at-level(cased, ctx, quote-level + 1)
            } else {
              transform-quotes-at-level(cased, ctx, quote-level)
            }
          } else { cased }
          let has-quotes = _attr-true(attrs.at("quotes", default: "false"))
          let fixed = _fix-inner-quotes(
            normalized,
            ctx,
            quote-level,
            has-quotes,
          )
          let quoted = if has-quotes {
            apply-quotes(fixed, ctx, level: quote-level)
          } else { fixed }
          let final-attrs = if type(quoted) == str {
            (..attrs, "_ends-with-period": quoted.ends-with("."))
          } else { attrs }
          let ends = if type(quoted) == str { quoted.ends-with(".") } else {
            false
          }
          (finalize(quoted, final-attrs), "var", (), ends)
        } else {
          ([], "var", (), false) // citeproc-js compat: year-suffix always counts
        }
      } else {
        ([], "no-var", (), false) // Variable referenced but empty
      }
    } else if "value" in attrs {
      let result = attrs.value
      let quote-level = ctx.at("quote-level", default: 0)

      // Normalize embedded quotes in value (same as variables)
      let has-quotes = _attr-true(attrs.at("quotes", default: "false"))
      let folded = fold-superscripts(result)
      let normalized = if type(folded) == str and not is-empty(folded) {
        if has-quotes {
          transform-quotes-at-level(folded, ctx, quote-level + 1)
        } else {
          transform-quotes-at-level(folded, ctx, quote-level)
        }
      } else { folded }

      let fixed = _fix-inner-quotes(normalized, ctx, quote-level, has-quotes)
      let quoted = if (
        has-quotes and not is-empty(fixed) and type(fixed) == str
      ) {
        apply-quotes(fixed, ctx, level: quote-level)
      } else { fixed }
      if type(quoted) != str and quoted.func() == text {
        let body = quoted
          .fields()
          .at(
            "text",
            default: quoted.fields().at("body", default: ""),
          )
        if type(body) == str and body != "" {
          quoted = body
        }
      }

      // punctuation-in-quote for literal values
      let suffix = attrs.at("suffix", default: "")
      let piq = if "style" in ctx {
        get-punctuation-in-quote(ctx.style)
      } else { false }
      let adjusted-attrs = if (
        has-quotes and piq and suffix.len() > 0 and suffix.first() in (".", ",")
      ) {
        if type(quoted) == str {
          if suffix.first() == "." and quoted.ends-with("\u{2019}\u{201D}") {
            quoted = quoted.replace(
              _re-rsq-rdq-end,
              ".\u{2019}\u{201D}",
            )
          } else if suffix.first() == "." and quoted.ends-with("\u{2019}") {
            quoted = quoted.replace(_re-rsq-end, ".\u{2019}")
          } else if not quoted.ends-with(suffix.first()) {
            quoted = quoted + suffix.first()
          }
        } else if quoted.func() == text {
          let fields = quoted.fields()
          let body = fields.at("text", default: fields.at(
            "body",
            default: none,
          ))
          if type(body) == str and body.ends-with("\u{201D}") {
            let updated = if (
              suffix.first() == "." and body.ends-with("\u{2019}\u{201D}")
            ) {
              body.replace(_re-rsq-rdq-end, ".\u{2019}\u{201D}")
            } else {
              body.replace(_re-rdq-end, suffix.first() + "\u{201D}")
            }
            quoted = text(updated)
          }
        }
        (..attrs, suffix: suffix.slice(1))
      } else { attrs }

      let final-attrs = if type(quoted) == str {
        (..adjusted-attrs, "_ends-with-period": quoted.ends-with("."))
      } else { adjusted-attrs }
      let ends = if type(quoted) == str { quoted.ends-with(".") } else { false }
      (finalize(quoted, final-attrs), "none", (), ends) // Literal value, no variable reference
    } else if "term" in attrs {
      let form = attrs.at("form", default: "long")
      let plural = attrs.at("plural", default: "false") == "true"
      let result = lookup-term(ctx, attrs.term, form: form, plural: plural)
      // Term can be none (undefined) or "" (defined as empty)
      // Both render as empty, but the distinction matters for substitute logic
      let term-str = if result != none { result } else { "" }
      if attrs.term == "ibid" and term-str != "" {
        let pos = ctx.at("position", default: none)
        if pos in ("ibid", "ibid-with-locator") {
          term-str = capitalize-first-char(term-str)
        }
      }
      let final-attrs = if type(term-str) == str {
        (..attrs, "_ends-with-period": term-str.ends-with("."))
      } else { attrs }
      let ends = term-str.ends-with(".")
      (finalize(term-str, final-attrs), "none", (), ends) // Term, no variable reference
    } else {
      ([], "none", (), false)
    }
  } else if tag == "number" {
    let result = handle-number(node, ctx, n => [])
    if is-empty(result) {
      ([], "no-var", (), false) // Number variable referenced but empty
    } else {
      let ends = if type(result) == str { result.ends-with(".") } else { false }
      (result, "var", (), ends) // Number variable has output
    }
  } else if tag == "label" {
    let result = handle-label(node, ctx, n => [])
    let ends = if type(result) == str { result.ends-with(".") } else { false }
    (result, "none", (), ends) // Label is a term, not a variable
  } else if tag == "names" {
    // handle-names now returns (content, done-vars) for substitute quashing
    let (result, names-done-vars) = handle-names(node, ctx)
    if is-empty(result) {
      if (
        names-done-vars.contains("__substitute-term__")
          or names-done-vars.contains("__suppress-author__")
      ) {
        ([], "var", names-done-vars, false)
      } else {
        ([], "no-var", names-done-vars, false)
      }
    } else {
      let node-children = node.at("children", default: ())
      let name-node = node-children.find(c => (
        type(c) == dictionary and c.at("tag", default: "") == "name"
      ))
      let name-attrs = if name-node != none {
        name-node.at("attrs", default: (:))
      } else { (:) }

      let name-parts = (:)
      if name-node != none {
        let name-children = name-node.at("children", default: ())
        for child in name-children {
          if (
            type(child) == dictionary
              and child.at("tag", default: "") == "name-part"
          ) {
            let part-attrs = child.at("attrs", default: (:))
            let part-name = part-attrs.at("name", default: "")
            if part-name in ("family", "given") {
              name-parts.insert(part-name, part-attrs)
            }
          }
        }
      }

      let et-al-node = node-children.find(c => (
        type(c) == dictionary and c.at("tag", default: "") == "et-al"
      ))
      let et-al-attrs = if et-al-node != none {
        et-al-node.at("attrs", default: (:))
      } else { (:) }
      let et-al-term = et-al-attrs.at("term", default: "et-al")
      let et-al = _resolve-et-al-settings(name-attrs, ctx)

      let var-names = attrs.at("variable", default: "author").split(" ")
      let last-names = none
      for var-name in var-names {
        let candidate = ctx.parsed-names.at(var-name, default: ())
        if candidate.len() > 0 { last-names = candidate }
      }
      let ends = if last-names != none {
        names-end-flag(
          last-names,
          name-attrs,
          name-parts,
          ctx,
          et-al-term,
          et-al,
        )
      } else { false }

      (result, "var", names-done-vars, ends)
    }
  } else if tag == "date" {
    let var-name = attrs.at("variable", default: "issued")
    if var-name in done-vars {
      return ([], "none", (), false)
    }
    let result = handle-date(node, ctx)
    if is-empty(result) {
      ([], "no-var", (), false) // Date variable referenced but empty
    } else {
      let ends = if type(result) == str { result.ends-with(".") } else { false }
      let suffix = ctx.at("year-suffix", default: none)
      let has-explicit = ctx.at("has-explicit-year-suffix", default: false)
      let mark-suffix = (
        suffix != none
          and suffix != ""
          and not has-explicit
          and "__year-suffix-done" not in done-vars
      )
      let date-done = if mark-suffix { ("__year-suffix-done",) } else { () }
      (result, "var", date-done, ends) // Date variable has output
    }
  } else {
    ([], "none", (), false)
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
  // Result stack: stores results as (content, var-state, done-vars, ends-with-period) tuples
  // Macro cache (mutable within this function!)
  // Accumulated done-vars for substitute quashing (mutable)
  let macro-cache = (:)
  let results = ()
  let accumulated-done-vars = ctx.at("done-vars", default: ())

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
      let text = node.trim()
      results.push((text, "none", (), text.ends-with("."))) // String literal, no variable
      continue
    }

    // Handle non-dict nodes
    if type(node) != dictionary {
      results.push(([], "none", (), false))
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
        if accumulated-done-vars.len() == 0 and macro-name in macro-cache {
          // Cache hit - use cached result with formatting
          let cached = macro-cache.at(macro-name)
          let cached-done-vars = cached.at(2, default: ())
          let cached-ends = cached.at(3, default: false)
          let quote-level = ctx.at("quote-level", default: 0)
          let has-quotes = _attr-true(attrs.at("quotes", default: "false"))
          let macro-content = cached.at(0)
          let normalized = if type(macro-content) == str {
            // Apply text-case + quote normalization on string content
            let cased = apply-text-case(macro-content, attrs, ctx: ctx)
            if has-quotes {
              transform-quotes-at-level(cased, ctx, quote-level + 1)
            } else {
              transform-quotes-at-level(cased, ctx, quote-level)
            }
          } else { macro-content }
          let fixed = _fix-inner-quotes(
            normalized,
            ctx,
            quote-level,
            has-quotes,
          )
          let quoted = if has-quotes {
            apply-quotes(fixed, ctx, level: quote-level)
          } else { fixed }
          let ends = if type(quoted) == str { quoted.ends-with(".") } else {
            cached-ends
          }
          // Accumulate done-vars from cached macro
          accumulated-done-vars = accumulated-done-vars + cached-done-vars
          results.push((
            finalize(quoted, (..attrs, "_ends-with-period": ends)),
            cached.at(1),
            cached-done-vars,
            ends,
          ))
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
            macro-cache.insert(macro-name, ([], "none", (), false))
            results.push(([], "none", (), false))
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
          results.push(([], "none", (), false))
        }
      } else if tag == "choose" {
        // Choose: evaluate conditions and process matching branch
        let matched = false
        let saw-variable-cond = false
        for branch in node-children {
          if type(branch) != dictionary { continue }
          let branch-tag = branch.at("tag", default: "")
          let branch-attrs = branch.at("attrs", default: (:))
          let branch-children = branch.at("children", default: ())

          if branch-tag == "if" or branch-tag == "else-if" {
            if "variable" in branch-attrs { saw-variable-cond = true }
          }

          let should-take = if branch-tag == "if" or branch-tag == "else-if" {
            eval-condition(branch-attrs, ctx)
          } else if branch-tag == "else" {
            true
          } else {
            false
          }

          if should-take {
            let force-var = (
              (
                (branch-tag == "if" or branch-tag == "else-if")
                  and "variable" in branch-attrs
              )
                or (branch-tag == "else" and saw-variable-cond)
            )
            if branch-children.len() > 0 {
              stack.push((
                node: node,
                state: "choose-pending",
                meta: (
                  child-count: branch-children.len(),
                  force-var: force-var,
                ),
              ))
              for c in branch-children.rev() {
                stack.push((node: c, state: "pending", meta: (:)))
              }
            } else {
              results.push(([], "none", (), false))
            }
            matched = true
            break
          }
        }
        // If no branch matched, push empty result
        if not matched {
          results.push(([], "none", (), false))
        }
      } else {
        // Leaf node - process immediately
        // Pass current accumulated done-vars in context
        let leaf-ctx = (
          ..ctx,
          done-vars: accumulated-done-vars,
          year-suffix-done: "__year-suffix-done" in accumulated-done-vars,
        )
        let leaf-result = process-leaf(node, leaf-ctx)
        // Accumulate any new done-vars from the leaf
        let new-done-vars = leaf-result.at(2, default: ())
        accumulated-done-vars = accumulated-done-vars + new-done-vars
        results.push(leaf-result)
      }
    } else if state == "macro-pending" {
      // Macro children completed - collect last N results
      // Macros act as implicit groups for suppression purposes.
      // This is not explicitly in CSL spec, but citeproc-js behavior and
      // test "group_SuppressTermInMacro" confirms macros should suppress
      // terms when all variable calls are empty.
      let child-count = meta.child-count
      let ordered = results.slice(-child-count)
      results = results.slice(0, results.len() - child-count)

      // Merge done-vars from all children
      let merged-done-vars = ordered.map(r => r.at(2, default: ())).flatten()

      // Accumulate done-vars for subsequent siblings in parent scope
      accumulated-done-vars = accumulated-done-vars + merged-done-vars

      // Check var-states - apply group suppression to macros
      let states = ordered.map(r => r.at(1, default: "none"))
      if should-suppress-group(states) {
        // Suppress: macro referenced variables but none produced output
        macro-cache.insert(meta.macro-name, (
          [],
          "no-var",
          merged-done-vars,
          false,
        ))
        results.push(([], "no-var", merged-done-vars, false))
      } else {
        // Render normally
        let merged-state = merge-var-state(states)
        let contents = ordered.map(r => r.at(0)).filter(x => not is-empty(x))
        let joined = contents.join()
        let end-flag = false
        for r in ordered.rev() {
          if not end-flag {
            let c = r.at(0)
            if not is-empty(c) { end-flag = r.at(3, default: false) }
          }
        }
        let quote-level = ctx.at("quote-level", default: 0)
        let has-quotes = _attr-true(meta.attrs.at("quotes", default: "false"))
        let normalized = if type(joined) == str {
          let cased = apply-text-case(joined, meta.attrs, ctx: ctx)
          if has-quotes {
            transform-quotes-at-level(cased, ctx, quote-level + 1)
          } else {
            transform-quotes-at-level(cased, ctx, quote-level)
          }
        } else { joined }
        let fixed = _fix-inner-quotes(normalized, ctx, quote-level, has-quotes)
        let quoted = if has-quotes {
          apply-quotes(fixed, ctx, level: quote-level)
        } else { fixed }
        let end-flag = if type(quoted) == str { quoted.ends-with(".") } else {
          end-flag
        }
        let final-attrs = (..meta.attrs, "_ends-with-period": end-flag)

        // Cache the raw result (content, var-state, done-vars) without formatting
        macro-cache.insert(meta.macro-name, (
          joined,
          merged-state,
          merged-done-vars,
          end-flag,
        ))

        // Apply formatting and push
        results.push((
          finalize(quoted, final-attrs),
          merged-state,
          merged-done-vars,
          end-flag,
        ))
      }
    } else if state == "group-pending" {
      // Group children completed - collect last N results
      let child-count = meta.child-count
      let ordered = results.slice(-child-count)
      results = results.slice(0, results.len() - child-count)

      // Merge done-vars from all children
      let merged-done-vars = ordered.map(r => r.at(2, default: ())).flatten()

      // Accumulate done-vars for subsequent siblings in parent scope
      accumulated-done-vars = accumulated-done-vars + merged-done-vars

      // Check var-states for group suppression
      let states = ordered.map(r => r.at(1, default: "none"))
      if should-suppress-group(states) {
        // Suppress: all children reference variables but none produced output
        results.push(([], "no-var", merged-done-vars, false))
      } else {
        // Render normally
        let merged-state = merge-var-state(states)
        let group-delimiter = meta.attrs.at("delimiter", default: "")
        let part-results = ordered.filter(r => not is-empty(r.at(0)))
        let parts = part-results.map(r => r.at(0))
        let all-strings = parts.all(p => type(p) == str)
        let joined = if group-delimiter != "" and parts.len() > 1 {
          let joined = ()
          for i in range(parts.len()) {
            if i > 0 {
              let prev-content = part-results.at(i - 1).at(0)
              let prev-ends = (
                part-results.at(i - 1).at(3, default: false)
                  or content-to-string(prev-content).trim().ends-with(".")
              )
              let next-str = content-to-string(parts.at(i)).trim()
              let delim = if (
                group-delimiter.len() > 0
                  and group-delimiter.first() == "."
                  and prev-ends
                  and group-delimiter.trim() == "."
              ) {
                group-delimiter.slice(1)
              } else {
                group-delimiter
              }
              let prev-str = content-to-string(prev-content).trim()
              let delim = if (
                delim.len() > 0
                  and delim.first() == ","
                  and next-str.starts-with("(")
                  and prev-str.len() > 0
                  and prev-str.clusters().last().match(_re-digit) != none
              ) {
                delim.replace(",", "")
              } else {
                delim
              }
              if delim != "" { joined.push(delim) }
            }
            joined.push(parts.at(i))
          }
          joined.join()
        } else if all-strings {
          parts.join("")
        } else {
          parts.join()
        }

        // Apply prefix/suffix
        let prefix = meta.attrs.at("prefix", default: "")
        let suffix = meta.attrs.at("suffix", default: "")
        let content-end-flag = if type(joined) == str {
          joined.trim().ends-with(".")
        } else {
          content-to-string(joined).trim().ends-with(".")
        }
        let end-flag = content-end-flag
        if suffix != "" and suffix.ends-with(".") { end-flag = true }
        if not is-empty(joined) {
          // CSL spec: "a non-empty nested cs:group is treated as a non-empty variable
          // for the purposes of determining suppression of the outer cs:group"
          // So a non-empty group should report "var" state even if it only contains terms/values
          let final-state = if merged-state == "none" { "var" } else {
            merged-state
          }
          let final-attrs = (
            ..meta.attrs,
            "_ends-with-period": content-end-flag,
          )
          results.push((
            finalize(joined, final-attrs),
            final-state,
            merged-done-vars,
            end-flag,
          ))
        } else {
          results.push(([], merged-state, merged-done-vars, false))
        }
      }
    } else if state == "choose-pending" {
      // Choose branch completed - collect last N results
      let child-count = meta.child-count
      let ordered = results.slice(-child-count)
      results = results.slice(0, results.len() - child-count)

      // Merge done-vars from all children
      let merged-done-vars = ordered.map(r => r.at(2, default: ())).flatten()

      // Accumulate done-vars for subsequent siblings in parent scope
      accumulated-done-vars = accumulated-done-vars + merged-done-vars

      // Merge var-states
      let states = ordered.map(r => r.at(1, default: "none"))
      let merged-state = merge-var-state(states)

      let contents = ordered.map(r => r.at(0)).filter(x => not is-empty(x))
      let joined = contents.join()
      let end-flag = false
      for r in ordered.rev() {
        if not end-flag {
          let c = r.at(0)
          if not is-empty(c) { end-flag = r.at(3, default: false) }
        }
      }
      if meta.at("force-var", default: false) and not is-empty(joined) {
        merged-state = "var"
      }
      results.push((joined, merged-state, merged-done-vars, end-flag))
    }
  }

  // Final result: join all top-level results with optional delimiter
  // Extract content from tuples
  let final-contents = results.map(r => r.at(0)).filter(x => not is-empty(x))
  if delimiter != none {
    final-contents.join(delimiter)
  } else {
    final-contents.join()
  }
}

/// Convenience function to interpret a single node with stack
#let interpret-node-stack(node, ctx) = {
  interpret-children-stack((node,), ctx)
}
