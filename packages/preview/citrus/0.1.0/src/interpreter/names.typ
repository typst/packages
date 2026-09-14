// citrus - Names Handler
//
// Handles <names> CSL element.

#import "../core/mod.typ": finalize, is-empty
#import "../text/names.typ": format-names, format-names-with-institutions
#import "../parsing/locales.typ": lookup-term

/// Handle <names> element
/// Uses stack-based interpreter internally for substitute processing
/// The third parameter is ignored (kept for dispatch table compatibility)
#let handle-names(node, ctx, .._rest) = {
  // Import here to avoid circular dependency at module level
  import "stack.typ": interpret-children-stack
  let attrs = node.at("attrs", default: (:))
  let children = node.at("children", default: ())
  let var-names = attrs.at("variable", default: "author").split(" ")

  // Try each variable in order
  let names = none
  let used-var = none
  for var-name in var-names {
    let candidate = ctx.parsed-names.at(var-name, default: ())
    if candidate.len() > 0 {
      names = candidate
      used-var = var-name
      break
    }
  }

  if names == none or names.len() == 0 {
    // Try substitute - CSL spec: try each child in order, use FIRST that produces output
    let substitute = children.find(c => (
      type(c) == dictionary and c.at("tag", default: "") == "substitute"
    ))
    if substitute != none {
      let sub-result = []
      for sub-child in substitute.at("children", default: ()) {
        let rendered = interpret-children-stack((sub-child,), ctx)
        if not is-empty(rendered) {
          sub-result = rendered
          break // Use first non-empty result only
        }
      }
      sub-result
    } else { [] }
  } else {
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
    let is-target-element = target-vars.contains(used-var)

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
        // Replace entire name list with substitute string (no inline substitution)
        return finalize(author-substitute, attrs)
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

    // Find label if present
    let label-node = children.find(c => (
      type(c) == dictionary and c.at("tag", default: "") == "label"
    ))
    let label-content = if label-node != none {
      let label-attrs = label-node.at("attrs", default: (:))
      let form = label-attrs.at("form", default: "long")
      let plural = names.len() > 1
      let term = lookup-term(ctx, used-var, form: form, plural: plural)
      // Only apply formatting if term is non-empty (to avoid prefix/suffix on empty content)
      if term == "" { [] } else { finalize(term, label-attrs) }
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
      )
    } else {
      format-names(
        names,
        name-attrs,
        ctx,
        name-parts: name-parts,
        substitute-string: substitute-string-to-use,
        substitute-count: substitute-count-to-use,
      )
    }

    // Combine with label
    let result = if label-content != [] {
      let label-position = if label-node != none {
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

      if label-position == "before" {
        [#label-content #names-content]
      } else {
        [#names-content#attrs.at("delimiter", default: ", ")#label-content]
      }
    } else { names-content }

    finalize(result, attrs)
  }
}
