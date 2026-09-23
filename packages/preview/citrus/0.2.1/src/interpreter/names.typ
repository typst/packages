// citrus - Names Handler
//
// Handles <names> CSL element.

#import "../core/mod.typ": finalize, is-empty
#import "../output/helpers.typ": content-to-string

#let _collect-vars(node, macros) = {
  if type(node) != dictionary { return () }
  let tag = node.at("tag", default: "")
  let attrs = node.at("attrs", default: (:))
  let vars = ()

  if tag == "text" and "variable" in attrs {
    vars.push(attrs.variable)
  } else if tag == "names" and "variable" in attrs {
    vars = vars + attrs.variable.split(" ")
  } else if tag == "date" and "variable" in attrs {
    vars.push(attrs.variable)
  } else if tag == "text" and "macro" in attrs {
    let macro-name = attrs.macro
    let macro-def = macros.at(macro-name, default: none)
    if macro-def != none {
      for child in macro-def.at("children", default: ()) {
        vars = vars + _collect-vars(child, macros)
      }
    }
  }

  for child in node.at("children", default: ()) {
    vars = vars + _collect-vars(child, macros)
  }

  vars
}
#import "../text/names.typ": (
  _resolve-et-al-settings, apply-name-formatting, format-names,
  format-names-with-institutions, names-end-flag,
)
#import "../parsing/mod.typ": lookup-term

// =============================================================================
// Helper Functions
// =============================================================================

/// Compare two name arrays for equality
///
/// CSL spec: When variable="editor translator" and both have identical names,
/// use the "editortranslator" term for the label instead of separate terms.
///
/// - names1: First array of name dicts
/// - names2: Second array of name dicts
/// Returns: bool - true if all names match
#let names-are-equal(names1, names2) = {
  if names1.len() != names2.len() { return false }
  if names1.len() == 0 { return false }

  for (i, name1) in names1.enumerate() {
    let name2 = names2.at(i)
    // Compare key name parts: family, given, prefix (dropping-particle), suffix
    let parts = ("family", "given", "prefix", "suffix")
    for part in parts {
      let v1 = name1.at(part, default: "")
      let v2 = name2.at(part, default: "")
      if v1 != v2 { return false }
    }
  }
  true
}

/// Get the common term for merged name variables
///
/// CSL spec: When multiple variables like "editor translator" have identical names,
/// use a combined term (e.g., "editortranslator") for the label.
///
/// - var-names: Array of variable names (e.g., ("editor", "translator"))
/// - ctx: Context with parsed names
/// Returns: (common-term: str or none, names: array) - the merged term name and the names to render
#let get-common-term-for-variables(var-names, ctx) = {
  // Only applicable for exactly 2 variables
  if var-names.len() != 2 {
    return (common-term: none, names: none, used-var: none)
  }

  let var1 = var-names.at(0)
  let var2 = var-names.at(1)
  let names1 = ctx.parsed-names.at(var1, default: ())
  let names2 = ctx.parsed-names.at(var2, default: ())

  // Both must have names
  if names1.len() == 0 or names2.len() == 0 {
    return (common-term: none, names: none, used-var: none)
  }

  // Check if names are identical
  if not names-are-equal(names1, names2) {
    return (common-term: none, names: none, used-var: none)
  }

  // Build combined term name (variables sorted and joined)
  // e.g., ("editor", "translator") -> "editortranslator"
  let sorted-vars = var-names.sorted()
  let common-term = sorted-vars.join("")

  // Check if the locale has this term in long form (the default label form)
  // CSL spec: if the combined term is empty or doesn't exist, render separately
  // We only check long form because:
  // 1. Labels default to long form
  // 2. If a style defines <term name="editortranslator"></term> (empty), it means
  //    "don't use combined rendering" even if short form exists from built-in
  let term-value = lookup-term(ctx, common-term, form: "long", plural: false)

  // If term is undefined (none) or empty, don't use combined rendering
  if term-value == none or term-value == "" {
    return (common-term: none, names: none, used-var: none)
  }

  // Return the first variable's names (they're identical) and the common term
  (common-term: common-term, names: names1, used-var: var1)
}

/// Handle <names> element
/// Uses stack-based interpreter internally for substitute processing
/// The third parameter is ignored (kept for dispatch table compatibility)
/// Returns: (content, done-vars) tuple for substitute quashing support
#let handle-names(node, ctx, .._rest) = {
  // Support suppress-author for collapse (CSL spec: subsequent cites in collapsed group omit author)
  let var-names-str = node
    .at("attrs", default: (:))
    .at("variable", default: "author")
  if (
    ctx.at("suppress-author", default: false)
      and var-names-str.contains("author")
  ) {
    // Check if author names actually exist — if so, signal "suppressed" (not "absent")
    // to prevent the <substitute> chain from running
    let author-names = ctx
      .at("parsed-names", default: (:))
      .at("author", default: ())
    if author-names.len() > 0 {
      return ([], ("__suppress-author__",))
    }
    return ([], ())
  }

  // Import here to avoid circular dependency at module level
  import "stack.typ": interpret-children-stack
  let attrs = node.at("attrs", default: (:))
  let children = node.at("children", default: ())
  let var-names = attrs.at("variable", default: "author").split(" ")
  let done-vars = ctx.at("done-vars", default: ())
  let active-vars = var-names.filter(v => not done-vars.contains(v))
  if active-vars.len() == 0 {
    return ([], ())
  }
  var-names = active-vars

  // Check for merged editor-translator pattern first
  // CSL spec: When variable="editor translator" and both have identical names,
  // render once with "editortranslator" label
  let common-term-result = get-common-term-for-variables(var-names, ctx)
  let common-term = common-term-result.common-term
  let names = common-term-result.names
  let used-var = common-term-result.used-var

  // Check for form="count" - special handling for multiple variables
  // CSL spec: form="count" returns the total count of names across all variables
  let name-node = children.find(c => (
    type(c) == dictionary and c.at("tag", default: "") == "name"
  ))
  let name-attrs = if name-node != none {
    name-node.at("attrs", default: (:))
  } else { (:) }
  if "name-as-sort-order" not in name-attrs {
    let sort-order = attrs.at("name-as-sort-order", default: none)
    if sort-order != none {
      name-attrs.insert("name-as-sort-order", sort-order)
    }
  }
  let name-form = name-attrs.at("form", default: "long")

  if name-form == "count" {
    // For form="count", sum the counts from ALL variables (after et-al truncation each)
    import "../text/names.typ": _resolve-et-al-settings
    let total-count = 0
    for var-name in var-names {
      let var-names-list = ctx.parsed-names.at(var-name, default: ())
      if var-names-list.len() > 0 {
        // Apply et-al truncation per CSL spec
        let et-al = _resolve-et-al-settings(name-attrs, ctx)
        let use-et-al = (
          et-al.et-al-min != none
            and et-al.et-al-use-first != none
            and var-names-list.len() >= et-al.et-al-min
            and et-al.et-al-use-first < var-names-list.len()
        )
        let show-count = if use-et-al { et-al.et-al-use-first } else {
          var-names-list.len()
        }
        total-count += show-count
      }
    }
    if total-count > 0 {
      return (finalize(str(total-count), attrs), ())
    }
    // Fall through to substitute handling if no names found
  }

  // If no common term match, check if we need to render multiple variables
  // CSL spec: when variable="editor translator" and names are different,
  // render each variable separately with the element's delimiter
  if names == none and var-names.len() > 1 {
    // Collect all non-empty variables
    let vars-with-names = ()
    for var-name in var-names {
      let candidate = ctx.parsed-names.at(var-name, default: ())
      if candidate.len() > 0 {
        vars-with-names.push((var: var-name, names: candidate))
      }
    }

    // If multiple variables have names, render them separately with delimiter
    if vars-with-names.len() > 1 {
      // Get the names element delimiter - check element first, then cascade
      // CSL spec: cs:names delimiter attribute takes precedence over inherited names-delimiter
      let names-delimiter = attrs.at("delimiter", default: none)
      if names-delimiter == none {
        // Import cascade helper
        import "../text/names.typ": _resolve-name-attr
        names-delimiter = _resolve-name-attr("names-delimiter", (:), ctx)
      }
      // CSL spec default
      if names-delimiter == none { names-delimiter = ", " }

      // Render each variable's names separately
      let rendered-parts = ()
      for var-info in vars-with-names {
        // Create a modified node with just this variable
        let single-var-node = (
          tag: "names",
          attrs: (
            ..attrs,
            variable: var-info.var,
          ),
          children: children,
        )
        // Recursive call for single variable (returns (content, done-vars) tuple)
        let (part, _part-done-vars) = handle-names(single-var-node, ctx)
        if not is-empty(part) {
          rendered-parts.push(part)
        }
      }

      if rendered-parts.len() > 0 {
        // Multi-variable rendering doesn't trigger substitute quashing
        return (rendered-parts.join(names-delimiter), ())
      }
    } else if vars-with-names.len() == 1 {
      // Only one variable has names, use it
      names = vars-with-names.first().names
      used-var = vars-with-names.first().var
    }
  } else if names == none {
    // Single variable or all variables empty
    for var-name in var-names {
      let candidate = ctx.parsed-names.at(var-name, default: ())
      if candidate.len() > 0 {
        names = candidate
        used-var = var-name
        break
      }
    }
  }

  let substitute-done-vars = ()
  let substitute = none
  if names == none or names.len() == 0 {
    substitute = children.find(c => (
      type(c) == dictionary and c.at("tag", default: "") == "substitute"
    ))
    // Check for subsequent-author-substitute BEFORE trying substitute
    // CSL spec: subsequent-author-substitute applies to the ENTIRE output of the
    // first cs:names element, including substitutes
    let author-substitute = ctx.at("author-substitute", default: none)
    let substitute-vars = ctx.at("substitute-vars", default: "author")
    let target-vars = substitute-vars.split(" ")
    // Check if ANY of our variables match the target variables
    let is-target-element = var-names.any(v => target-vars.contains(v))

    if author-substitute != none and is-target-element {
      let substitute-vars = ()
      if substitute != none {
        for sub-child in substitute.at("children", default: ()) {
          if (
            type(sub-child) == dictionary
              and sub-child.at("tag", default: "") == "names"
          ) {
            let child-attrs = sub-child.at("attrs", default: (:))
            if "variable" in child-attrs {
              let child-vars = child-attrs.variable.split(" ")
              for v in child-vars {
                let candidate = ctx.parsed-names.at(v, default: ())
                if candidate.len() > 0 {
                  substitute-vars = (v,)
                  break
                }
              }
            }
          }
          if substitute-vars.len() > 0 { break }
        }
      }
      let has-substitute-names = substitute-vars.len() > 0
      let substitute-rule = ctx.at(
        "author-substitute-rule",
        default: "complete-all",
      )
      let substitute-count = ctx.at("author-substitute-count", default: 0)
      if substitute-rule == "complete-all" and not has-substitute-names {
        // Replace entire output with substitute string
        return (finalize(author-substitute, attrs), substitute-vars)
      } else if (
        substitute-rule == "partial-each"
          and substitute-count > 0
          and not has-substitute-names
      ) {
        // For partial-each with substitute fallback (no actual names),
        // if matching-count > 0, it means the substitute output matched
        // Replace entire output with substitute string
        return (finalize(author-substitute, attrs), substitute-vars)
      } else if substitute-rule == "complete-each" {
        // complete-each also substitutes if match was found
        if substitute-count > 0 and not has-substitute-names {
          return (finalize(author-substitute, attrs), substitute-vars)
        }
      }
      // For other rules (partial-first, etc.) we still need to render the substitute
      // to get the actual content to compare - but this is rare for substitute cases
    }

    // Try substitute - CSL spec: try each child in order, use FIRST that produces output
    let substitute = substitute
    if substitute != none {
      if author-substitute != none and is-target-element {
        // If substitute provides names, use them to allow label + author-substitute
        for sub-child in substitute.at("children", default: ()) {
          if (
            type(sub-child) == dictionary
              and sub-child.at("tag", default: "") == "names"
          ) {
            let child-attrs = sub-child.at("attrs", default: (:))
            if "variable" in child-attrs {
              let child-vars = child-attrs.variable.split(" ")
              for v in child-vars {
                let candidate = ctx.parsed-names.at(v, default: ())
                if candidate.len() > 0 {
                  names = candidate
                  used-var = v
                  substitute-done-vars = (v,)
                  break
                }
              }
            }
          }
          if names != none and names.len() > 0 { break }
        }
      }
      if names != none and names.len() > 0 {
        // Fall through to normal rendering with substitute-done-vars
      } else {
        // CSL spec: "cs:names elements in cs:substitute inherit any name and label
        // elements from the parent cs:names element."
        // Extract parent's name and label elements for inheritance
        let parent-name-node = children.find(c => (
          type(c) == dictionary and c.at("tag", default: "") == "name"
        ))
        let parent-label-node = children.find(c => (
          type(c) == dictionary and c.at("tag", default: "") == "label"
        ))

        let sub-result = []
        let sub-done-vars = ()
        for sub-child in substitute.at("children", default: ()) {
          // Track which variable this substitute child will render
          let child-var = if type(sub-child) == dictionary {
            let child-tag = sub-child.at("tag", default: "")
            let child-attrs = sub-child.at("attrs", default: (:))
            if child-tag == "text" and "variable" in child-attrs {
              // <text variable="..."/> - track this variable
              (child-attrs.variable,)
            } else if child-tag == "text" and "macro" in child-attrs {
              _collect-vars(sub-child, ctx.macros)
            } else if child-tag == "names" and "variable" in child-attrs {
              // <names variable="..."/> - track all name variables
              child-attrs.variable.split(" ")
            } else {
              ()
            }
          } else {
            ()
          }

          // For names elements, inject parent's name/label if not present
          let child-to-render = if (
            type(sub-child) == dictionary
              and sub-child.at("tag", default: "") == "names"
          ) {
            let sub-children = sub-child.at("children", default: ())
            let has-name = sub-children.any(c => (
              type(c) == dictionary and c.at("tag", default: "") == "name"
            ))
            let has-label = sub-children.any(c => (
              type(c) == dictionary and c.at("tag", default: "") == "label"
            ))

            // Build new children list with inherited elements
            let new-children = sub-children
            if not has-name and parent-name-node != none {
              new-children = (parent-name-node,) + new-children
            }
            if not has-label and parent-label-node != none {
              new-children = new-children + (parent-label-node,)
            }

            // Create modified node with inherited children
            let modified = sub-child
            modified.insert("children", new-children)
            modified
          } else {
            sub-child
          }

          // Special handling for <text term="..."/>: CSL spec says "Fallback stops once
          // a localizable unit has been found. For terms, this even is the case when
          // they are defined as empty strings"
          let is-term-element = (
            type(sub-child) == dictionary
              and sub-child.at("tag", default: "") == "text"
              and "term" in sub-child.at("attrs", default: (:))
          )

          if is-term-element {
            // Check if term is defined (even if empty)
            let term-name = sub-child
              .at("attrs", default: (:))
              .at("term", default: "")
            let form = sub-child
              .at("attrs", default: (:))
              .at("form", default: "long")
            let term-value = lookup-term(
              ctx,
              term-name,
              form: form,
              plural: false,
            )
            if term-value != none {
              // Term is defined (even if empty) - use it and stop
              let rendered = interpret-children-stack((child-to-render,), ctx)
              sub-result = rendered
              if term-value == "" {
                sub-done-vars = child-var + ("__substitute-term__",)
              } else {
                sub-done-vars = child-var
              }
              break
            }
            // Term is undefined - continue to next substitute child
          } else {
            let rendered = interpret-children-stack((child-to-render,), ctx)
            if not is-empty(rendered) {
              sub-result = rendered
              // CSL Substitute Quashing: mark rendered variables as "done"
              sub-done-vars = child-var
              break // Use first non-empty result only
            }
          }
        }
        // CSL spec: substitute output should still have parent <names> element's
        // prefix/suffix applied (not formatting - that's on the substitute child)
        return (finalize(sub-result, attrs), sub-done-vars)
      }
    } else { ([], ()) }
  }

  if names == none or names.len() == 0 {
    return ([], ())
  }

  // Check for subsequent-author-substitute (bibliography grouping)
  // CSL spec: "Substitution is limited to the names of the first cs:names element rendered"
  //
  // IMPLEMENTATION NOTE:
  // We identify the "first cs:names" by matching variable names from the structurally
  // first cs:names node in the bibliography layout (stored in ctx.substitute-vars).
  //
  // KNOWN LIMITATION:
  // If a layout contains multiple cs:names elements with the SAME variable attribute
  // (e.g., two separate `<names variable="author">` elements), this implementation
  // will substitute ALL of them, not just the first. However, this edge case is
  // extremely rare in real CSL styles - typically each variable appears in only one
  // cs:names element per layout.
  //
  // A fully spec-compliant fix would require mutable state to track "have we already
  // rendered the first cs:names?", which Typst's functional model doesn't support
  // without restructuring to two-pass rendering.
  let author-substitute = ctx.at("author-substitute", default: none)
  let substitute-vars = ctx.at("substitute-vars", default: "author")

  // Check if current variable matches the first cs:names element's variables
  let target-vars = substitute-vars.split(" ")
  let original-vars = attrs.at("variable", default: "author").split(" ")
  let is-target-element = original-vars.any(v => target-vars.contains(v))

  // Determine substitution parameters for format-names
  // These will be passed to format-names to handle inline substitution
  let substitute-string-to-use = none
  let substitute-count-to-use = 0

  if author-substitute != none and is-target-element {
    // CSL spec: "replaces the entire name list (including punctuation and terms
    // like 'et al' and 'and'), except for the affixes set on the cs:names element"
    let substitute-rule = ctx.at(
      "author-substitute-rule",
      default: "complete-all",
    )
    let substitute-count = ctx.at("author-substitute-count", default: 0)

    if substitute-rule == "complete-all" {
      // Replace entire name list with substitute string (preserve labels)
      substitute-string-to-use = author-substitute
      substitute-count-to-use = -1
    } else if substitute-rule == "complete-each" {
      // All names match: substitute each name inline
      substitute-string-to-use = author-substitute
      substitute-count-to-use = substitute-count
    } else if substitute-rule == "partial-each" {
      // Substitute matching names from start inline
      substitute-string-to-use = author-substitute
      substitute-count-to-use = substitute-count
    } else if substitute-rule == "partial-first" {
      // Substitute only first name inline
      if substitute-count > 0 {
        substitute-string-to-use = author-substitute
        substitute-count-to-use = 1
      }
    }
  }

  // Find name formatting options
  let name-node = children.find(c => (
    type(c) == dictionary and c.at("tag", default: "") == "name"
  ))
  let name-attrs = if name-node != none {
    name-node.at("attrs", default: (:))
  } else { (:) }

  // Parse <name-part> children from <name> element
  // CSL spec: <name-part name="family"> and <name-part name="given"> control formatting
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

  // Find institution formatting options (CSL-M extension)
  let institution-node = children.find(c => (
    type(c) == dictionary and c.at("tag", default: "") == "institution"
  ))
  let institution-attrs = if institution-node != none {
    institution-node.at("attrs", default: (:))
  } else { none }

  // Find et-al element if present (CSL spec: can override term with term="...")
  // Also extract formatting attributes (font-style, font-weight, etc.)
  let et-al-node = children.find(c => (
    type(c) == dictionary and c.at("tag", default: "") == "et-al"
  ))
  let et-al-attrs = if et-al-node != none {
    et-al-node.at("attrs", default: (:))
  } else { (:) }
  let et-al-term = et-al-attrs.at("term", default: "et-al")
  let et-al = _resolve-et-al-settings(name-attrs, ctx)

  // Find label if present
  let label-node = children.find(c => (
    type(c) == dictionary and c.at("tag", default: "") == "label"
  ))
  let term = ""
  let label-attrs = if label-node != none {
    label-node.at("attrs", default: (:))
  } else { (:) }
  let label-position = "after"
  let label-content = if label-node != none {
    let form = label-attrs.at("form", default: "long")
    let plural-attr = label-attrs.at("plural", default: "contextual")
    let plural = if plural-attr == "always" {
      true
    } else if plural-attr == "never" {
      false
    } else {
      names.len() > 1
    }
    // Use common term (e.g., "editortranslator") if available, otherwise use variable name
    let term-name = if common-term != none { common-term } else { used-var }
    term = lookup-term(ctx, term-name, form: form, plural: plural)
    // Only apply formatting if term is defined and non-empty (to avoid prefix/suffix on empty content)
    if term == none or term == "" {
      []
    } else {
      let term-ends = (
        term.ends-with(".")
          or label-attrs.at("suffix", default: "").ends-with(".")
      )
      let final-label-attrs = (..label-attrs, "_ends-with-period": term-ends)
      finalize(term, final-label-attrs)
    }
  } else { [] }

  // Format names (with institution support if cs:institution is present)
  // Pass substitute parameters for inline substitution
  let names-content = if institution-attrs != none {
    format-names-with-institutions(
      names,
      name-attrs,
      institution-attrs,
      ctx,
      name-parts: name-parts,
      substitute-string: substitute-string-to-use,
      substitute-count: substitute-count-to-use,
      et-al-term: et-al-term,
      et-al-attrs: et-al-attrs,
    )
  } else {
    format-names(
      names,
      name-attrs,
      ctx,
      name-parts: name-parts,
      substitute-string: substitute-string-to-use,
      substitute-count: substitute-count-to-use,
      et-al-term: et-al-term,
      et-al-attrs: et-al-attrs,
    )
  }

  let raw-name-ends = if type(names-content) == str {
    names-content.trim().ends-with(".")
  } else {
    names-end-flag(
      names,
      name-attrs,
      name-parts,
      ctx,
      et-al-term,
      et-al,
    )
  }

  // Apply name-level formatting (font-weight, font-style, etc.)
  // CSL spec: <name> element can have formatting attributes that apply to all rendered names
  names-content = apply-name-formatting(names-content, name-attrs)

  // CSL spec: <name> element's prefix/suffix wrap the formatted name list
  // This is SEPARATE from <names> element's prefix/suffix (applied via finalize later)
  let name-prefix = name-attrs.at("prefix", default: "")
  let name-suffix = name-attrs.at("suffix", default: "")
  if (
    (name-prefix != "" or name-suffix != "") and not is-empty(names-content)
  ) {
    names-content = [#name-prefix#names-content#name-suffix]
  }

  // Combine with label
  let label-ends = if label-content != [] {
    let label-str = if type(label-content) == str {
      label-content
    } else {
      content-to-string(label-content)
    }
    if label-str.trim() != "" {
      label-str.trim().ends-with(".")
    } else {
      (
        term.trim().ends-with(".")
          or label-attrs.at("suffix", default: "").ends-with(".")
      )
    }
  } else { false }

  let result = if label-content != [] {
    label-position = if label-node != none {
      let label-idx = children.position(c => (
        type(c) == dictionary and c.at("tag", default: "") == "label"
      ))
      let name-idx = children.position(c => (
        type(c) == dictionary and c.at("tag", default: "") == "name"
      ))
      if label-idx != none and name-idx != none and label-idx < name-idx {
        "before"
      } else { "after" }
    } else { "after" }

    // If label has its own prefix, use it directly; otherwise use names delimiter
    let label-has-prefix = label-attrs.at("prefix", default: "") != ""

    if label-position == "before" {
      // Label's own suffix controls spacing (e.g., suffix=" " on "by")
      [#label-content#names-content]
    } else {
      // CSL spec: label follows names directly without additional delimiter
      // Label's own prefix/suffix controls spacing
      [#names-content#label-content]
    }
  } else { names-content }

  let name-ends = raw-name-ends
  if name-suffix.ends-with(".") { name-ends = true }

  let final-ends = if label-content != [] and label-position == "after" {
    label-ends
  } else {
    name-ends
  }

  let suffix = attrs.at("suffix", default: "")
  let final-attrs = if final-ends and suffix.starts-with(".") {
    (..attrs, suffix: suffix.slice(1), "_ends-with-period": final-ends)
  } else {
    (..attrs, "_ends-with-period": final-ends)
  }

  // Normal names rendering - no substitute quashing needed
  (finalize(result, final-attrs), substitute-done-vars)
}
