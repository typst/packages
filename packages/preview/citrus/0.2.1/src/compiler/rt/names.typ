// citrus - Compiler Runtime: Names

#import "../../interpreter/names.typ": handle-names as _handle-names
#import "../../core/mod.typ": finalize, is-empty
#import "../../output/helpers.typ": content-to-string

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
#import "../../parsing/mod.typ": lookup-term
#import "../../interpreter/stack.typ": interpret-children-stack
#import "../../text/names.typ": (
  _resolve-et-al-settings, _resolve-name-attr, apply-name-formatting,
  format-names, format-names-with-institutions, names-end-flag,
)

/// Compare two name arrays for equality
#let names-are-equal(names1, names2) = {
  if names1.len() != names2.len() { return false }
  if names1.len() == 0 { return false }

  for (i, name1) in names1.enumerate() {
    let name2 = names2.at(i)
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
#let get-common-term-for-variables(var-names, ctx) = {
  if var-names.len() != 2 {
    return (common-term: none, names: none, used-var: none)
  }

  let var1 = var-names.at(0)
  let var2 = var-names.at(1)
  let names1 = ctx.parsed-names.at(var1, default: ())
  let names2 = ctx.parsed-names.at(var2, default: ())

  if names1.len() == 0 or names2.len() == 0 {
    return (common-term: none, names: none, used-var: none)
  }

  if not names-are-equal(names1, names2) {
    return (common-term: none, names: none, used-var: none)
  }

  let sorted-vars = var-names.sorted()
  let common-term = sorted-vars.join("")

  let term-value = lookup-term(ctx, common-term, form: "long", plural: false)
  if term-value == none or term-value == "" {
    return (common-term: none, names: none, used-var: none)
  }

  (common-term: common-term, names: names1, used-var: var1)
}

/// Render a single variable name list using a precomputed plan.
#let _render-names-plan(
  ctx,
  attrs,
  plan,
  var-name,
  names,
  term-override: none,
) = {
  // Subsequent-author-substitute handling (inline substitution only)
  let substitute-string-to-use = none
  let substitute-count-to-use = 0
  let author-substitute = ctx.at("author-substitute", default: none)
  if author-substitute != none {
    let substitute-vars = ctx.at("substitute-vars", default: "author")
    let target-vars = substitute-vars.split(" ")
    let element-vars = attrs.at("variable", default: var-name).split(" ")
    let is-target-element = element-vars.any(v => target-vars.contains(v))
    if is-target-element {
      let substitute-rule = ctx.at(
        "author-substitute-rule",
        default: "complete-all",
      )
      let substitute-count = ctx.at("author-substitute-count", default: 0)
      if substitute-rule == "complete-all" {
        substitute-string-to-use = author-substitute
        substitute-count-to-use = -1
      } else if substitute-rule == "complete-each" {
        substitute-string-to-use = author-substitute
        substitute-count-to-use = substitute-count
      } else if substitute-rule == "partial-each" {
        substitute-string-to-use = author-substitute
        substitute-count-to-use = substitute-count
      } else if substitute-rule == "partial-first" {
        if substitute-count > 0 {
          substitute-string-to-use = author-substitute
          substitute-count-to-use = 1
        }
      }
    }
  }

  let name-attrs = plan.at("name-attrs", default: (:))
  let name-parts = plan.at("name-parts", default: (:))
  let et-al-attrs = plan.at("et-al-attrs", default: (:))
  let et-al-term = plan.at("et-al-term", default: "et-al")
  let et-al = _resolve-et-al-settings(name-attrs, ctx)
  let institution-attrs = plan.at("institution-attrs", default: none)

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

  // Apply name-level formatting and affixes
  names-content = apply-name-formatting(names-content, name-attrs)
  let name-prefix = name-attrs.at("prefix", default: "")
  let name-suffix = name-attrs.at("suffix", default: "")
  if (
    (name-prefix != "" or name-suffix != "") and not is-empty(names-content)
  ) {
    names-content = [#name-prefix#names-content#name-suffix]
  }

  // Optional label
  let result = names-content
  let label-attrs = (:)
  let label-content = []
  let term = ""
  if plan.at("has-label", default: false) {
    label-attrs = plan.at("label-attrs", default: (:))
    let form = label-attrs.at("form", default: "long")
    let plural-attr = label-attrs.at("plural", default: "contextual")
    let plural = if plural-attr == "always" {
      true
    } else if plural-attr == "never" {
      false
    } else {
      names.len() > 1
    }
    let term-name = if term-override != none { term-override } else { var-name }
    term = lookup-term(ctx, term-name, form: form, plural: plural)
    if term != none and term != "" {
      let term-ends = (
        term.ends-with(".")
          or label-attrs.at("suffix", default: "").ends-with(".")
      )
      let final-label-attrs = (..label-attrs, "_ends-with-period": term-ends)
      label-content = finalize(term, final-label-attrs)
    }

    if label-content != [] {
      let label-position = plan.at("label-position", default: "after")
      result = if label-position == "before" {
        [#label-content #names-content]
      } else {
        [#names-content#label-content]
      }
    }
  }

  let label-ends = false
  if plan.at("has-label", default: false) and label-content != [] {
    let label-str = if type(label-content) == str {
      label-content
    } else {
      content-to-string(label-content)
    }
    label-ends = if label-str.trim() != "" {
      label-str.trim().ends-with(".")
    } else {
      (
        term.ends-with(".")
          or label-attrs.at("suffix", default: "").ends-with(".")
      )
    }
  }

  let name-ends = raw-name-ends
  if name-suffix.ends-with(".") { name-ends = true }

  let final-ends = if (
    plan.at("has-label", default: false)
      and label-content != []
      and plan.at("label-position", default: "after") == "after"
  ) {
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
  let content = finalize(result, final-attrs)
  let var-state = if is-empty(content) { "no-var" } else { "var" }
  (content, var-state, final-ends)
}

/// Format names from a CSL <names> element
/// This is the hybrid adapter that calls the full interpreter implementation.
///
/// - ctx: Context dictionary with parsed-names, fields, locale, etc.
/// - attrs: Dictionary of CSL attributes (variable, form, delimiter, etc.)
/// - children: Array of child nodes (name, label, et-al, substitute, etc.)
/// Returns: (content, var-state, done-vars, ends-with-period) tuple
#let format-names-compiled(ctx, attrs, children) = {
  // Build a node structure that the interpreter expects
  let node = (
    tag: "names",
    attrs: attrs,
    children: children,
  )

  // Call the interpreter's handle-names
  let (content, done-vars) = _handle-names(node, ctx)

  // Determine var-state based on output
  let var-state = if is-empty(content) {
    // Check if any variable was expected
    let var-names = attrs.at("variable", default: "author").split(" ")
    let has-any = var-names.any(v => (
      ctx.at("parsed-names", default: (:)).at(v, default: ()).len() > 0
    ))
    if has-any { "var" } else { "no-var" }
  } else {
    "var"
  }

  let name-node = children.find(c => (
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

  let et-al-node = children.find(c => (
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
    names-end-flag(last-names, name-attrs, name-parts, ctx, et-al-term, et-al)
  } else { false }

  (content, var-state, done-vars, ends)
}

/// Fast path for <names> with a single variable and no <substitute>.
/// Expects a precomputed plan from the compiler to avoid child scans.
#let format-names-single-compiled(ctx, attrs, plan) = {
  let var-name = plan.at("var", default: "author")

  if var-name in ctx.at("done-vars", default: ()) {
    return ([], "none", (), false)
  }

  // Respect suppress-author for collapse
  if ctx.at("suppress-author", default: false) and var-name == "author" {
    let names = ctx.at("parsed-names", default: (:)).at(var-name, default: ())
    let var-state = if names.len() > 0 { "var" } else { "no-var" }
    return ([], var-state, (), false)
  }

  let names = ctx.at("parsed-names", default: (:)).at(var-name, default: ())
  if names.len() == 0 {
    return ([], "no-var", (), false)
  }

  let (content, var-state, ends) = _render-names-plan(
    ctx,
    attrs,
    plan,
    var-name,
    names,
  )
  (content, var-state, (), ends)
}

/// Fast path for <names> with multiple variables and no <substitute>.
#let format-names-multi-compiled(ctx, attrs, plan) = {
  let var-names = plan.at("vars", default: ())
  if var-names.len() == 0 {
    return ([], "no-var", (), false)
  }

  let done-vars = ctx.at("done-vars", default: ())
  let active-vars = var-names.filter(v => v not in done-vars)
  if active-vars.len() == 0 {
    return ([], "none", (), false)
  }
  var-names = active-vars

  let name-attrs = plan.at("name-attrs", default: (:))
  let name-form = name-attrs.at("form", default: "long")

  // CSL spec: form="count" returns total count across all variables.
  if name-form == "count" {
    let total-count = 0
    for var-name in var-names {
      let var-names-list = ctx.parsed-names.at(var-name, default: ())
      if var-names-list.len() > 0 {
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
      let count-str = str(total-count)
      let ends = count-str.trim().ends-with(".")
      return (finalize(count-str, attrs), "var", (), ends)
    }
  }

  // Check for merged editor-translator pattern
  let common-term-result = get-common-term-for-variables(var-names, ctx)
  let common-term = common-term-result.common-term
  let names = common-term-result.names
  let used-var = common-term-result.used-var

  if names != none and used-var != none {
    let (content, var-state, ends) = _render-names-plan(
      ctx,
      attrs,
      plan,
      used-var,
      names,
      term-override: common-term,
    )
    return (content, var-state, (), ends)
  }

  // Collect all non-empty variables
  let vars-with-names = ()
  for var-name in var-names {
    let candidate = ctx.parsed-names.at(var-name, default: ())
    if candidate.len() > 0 {
      vars-with-names.push((var: var-name, names: candidate))
    }
  }

  if vars-with-names.len() == 0 {
    return ([], "no-var", (), false)
  }

  if vars-with-names.len() == 1 {
    let single = vars-with-names.first()
    let (content, var-state, ends) = _render-names-plan(
      ctx,
      attrs,
      plan,
      single.var,
      single.names,
    )
    return (content, var-state, (), ends)
  }

  let names-delimiter = plan.at("names-delimiter", default: none)
  if names-delimiter == none {
    names-delimiter = _resolve-name-attr("names-delimiter", (:), ctx)
  }
  if names-delimiter == none { names-delimiter = ", " }

  let rendered-parts = ()
  for var-info in vars-with-names {
    let (part, _state, _ends) = _render-names-plan(
      ctx,
      attrs,
      plan,
      var-info.var,
      var-info.names,
    )
    if not is-empty(part) {
      rendered-parts.push(part)
    }
  }

  if rendered-parts.len() == 0 {
    ([], "no-var", (), false)
  } else {
    let joined = if rendered-parts.len() > 1 {
      let joined = ()
      for i in range(rendered-parts.len()) {
        if i > 0 and names-delimiter != "" { joined.push(names-delimiter) }
        joined.push(rendered-parts.at(i))
      }
      joined.join()
    } else {
      rendered-parts.first()
    }
    let ends = if type(joined) == str { joined.ends-with(".") } else { false }
    (joined, "var", (), ends)
  }
}

/// Fast path for <names> with <substitute> handling.
#let format-names-substitute-compiled(ctx, attrs, plan) = {
  let var-names = plan.at("vars", default: ())
  if var-names.len() == 0 {
    return ([], "no-var", (), false)
  }

  let (content, var-state, _done, ends) = if var-names.len() == 1 {
    format-names-single-compiled(ctx, attrs, plan)
  } else {
    format-names-multi-compiled(ctx, attrs, plan)
  }

  if var-state == "var" {
    return (content, var-state, (), ends)
  }

  let substitute-children = plan.at("substitute-children", default: ())
  if substitute-children.len() == 0 {
    return ([], "no-var", (), false)
  }

  let author-substitute = ctx.at("author-substitute", default: none)
  let substitute-vars = ctx.at("substitute-vars", default: "author")
  let target-vars = substitute-vars.split(" ")
  let is-target-element = var-names.any(v => target-vars.contains(v))

  if author-substitute != none and is-target-element {
    // If substitute provides names, use them to allow labels and author-substitute
    let done-vars = ctx.at("done-vars", default: ())
    for sub-child in substitute-children {
      if (
        type(sub-child) == dictionary
          and sub-child.at("tag", default: "") == "names"
      ) {
        let child-attrs = sub-child.at("attrs", default: (:))
        if "variable" in child-attrs {
          let child-vars = child-attrs.variable.split(" ")
          for v in child-vars {
            if v in done-vars { continue }
            let candidate = ctx.parsed-names.at(v, default: ())
            if candidate.len() > 0 {
              let (content, var-state, ends) = _render-names-plan(
                ctx,
                attrs,
                plan,
                v,
                candidate,
              )
              return (content, var-state, (v,), ends)
            }
          }
        }
      }
    }
  }

  if author-substitute != none and is-target-element {
    let substitute-rule = ctx.at(
      "author-substitute-rule",
      default: "complete-all",
    )
    let substitute-count = ctx.at("author-substitute-count", default: 0)
    if substitute-rule == "complete-all" {
      let end-flag = author-substitute.trim().ends-with(".")
      let final-attrs = (..attrs, "_ends-with-period": end-flag)
      return (finalize(author-substitute, final-attrs), "var", (), end-flag)
    } else if substitute-rule == "partial-each" and substitute-count > 0 {
      let end-flag = author-substitute.trim().ends-with(".")
      let final-attrs = (..attrs, "_ends-with-period": end-flag)
      return (finalize(author-substitute, final-attrs), "var", (), end-flag)
    } else if substitute-rule == "complete-each" {
      if substitute-count > 0 {
        let end-flag = author-substitute.trim().ends-with(".")
        let final-attrs = (..attrs, "_ends-with-period": end-flag)
        return (finalize(author-substitute, final-attrs), "var", (), end-flag)
      }
    }
  }

  let parent-name-node = plan.at("parent-name-node", default: none)
  let parent-label-node = plan.at("parent-label-node", default: none)

  let sub-result = []
  let sub-done-vars = ()
  for sub-child in substitute-children {
    let child-var = if type(sub-child) == dictionary {
      let child-tag = sub-child.at("tag", default: "")
      let child-attrs = sub-child.at("attrs", default: (:))
      if child-tag == "text" and "variable" in child-attrs {
        (child-attrs.variable,)
      } else if child-tag == "text" and "macro" in child-attrs {
        _collect-vars(sub-child, ctx.macros)
      } else if child-tag == "names" and "variable" in child-attrs {
        child-attrs.variable.split(" ")
      } else {
        ()
      }
    } else {
      ()
    }

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

      let new-children = sub-children
      if not has-name and parent-name-node != none {
        new-children = (parent-name-node,) + new-children
      }
      if not has-label and parent-label-node != none {
        new-children = new-children + (parent-label-node,)
      }

      let modified = sub-child
      modified.insert("children", new-children)
      modified
    } else {
      sub-child
    }

    let is-term-element = (
      type(sub-child) == dictionary
        and sub-child.at("tag", default: "") == "text"
        and "term" in sub-child.at("attrs", default: (:))
    )

    if is-term-element {
      let term-name = sub-child
        .at("attrs", default: (:))
        .at("term", default: "")
      let form = sub-child.at("attrs", default: (:)).at("form", default: "long")
      let term-value = lookup-term(
        ctx,
        term-name,
        form: form,
        plural: false,
      )
      if term-value != none {
        let rendered = interpret-children-stack((child-to-render,), ctx)
        sub-result = rendered
        if term-value == "" {
          sub-done-vars = child-var + ("__substitute-term__",)
        } else {
          sub-done-vars = child-var
        }
        break
      }
    } else {
      let rendered = interpret-children-stack((child-to-render,), ctx)
      if not is-empty(rendered) {
        sub-result = rendered
        sub-done-vars = child-var
        break
      }
    }
  }

  let content = finalize(sub-result, (..attrs, "_ends-with-period": false))
  let var-state = if is-empty(content) {
    if sub-done-vars.contains("__substitute-term__") { "var" } else { "no-var" }
  } else { "var" }
  (content, var-state, sub-done-vars, false)
}
