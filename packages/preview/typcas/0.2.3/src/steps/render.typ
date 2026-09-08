// =========================================================================
// typcas v2 Steps Renderer
// =========================================================================
// Equation-chain-first renderer with doc-level style configuration.
// =========================================================================

#import "../expr.typ": *
#import "../display.typ": cas-display, display-symbol
#import "../helpers.typ": check-free-var as _check-free-var
#import "style.typ": _step-style-current

#let _arrow-for(kind, style) = {
  if kind == "sub" { return style.arrow.sub }
  if kind == "meta" { return style.arrow.meta }
  style.arrow.main
}

#let _weight-for(kind, style) = {
  if kind == "sub" { return style.line-weight.minor }
  style.line-weight.major
}

#let _tone-fill(tone, style) = {
  if tone == "warn" { return style.palette.warn }
  if tone == "error" { return style.palette.error }
  if tone == "meta" { return style.palette.meta }
  style.palette.note
}

#let _is-symbol-token(tok) = {
  if "_" not in tok { return false }
  let parts = tok.split("_")
  if parts.len() != 2 { return false }
  let a = parts.at(0)
  let b = parts.at(1)
  if a == "" or b == "" { return false }
  for ch in a.clusters() {
    if not ((ch >= "a" and ch <= "z") or (ch >= "A" and ch <= "Z")) {
      return false
    }
  }
  for ch in b.clusters() {
    if not ((ch >= "0" and ch <= "9") or (ch >= "a" and ch <= "z") or (ch >= "A" and ch <= "Z")) {
      return false
    }
  }
  true
}

#let _rule-content(rule) = {
  if type(rule) == str {
    if "_" not in rule { return rule }
    let parts = rule.split(" ")
    return [
      #for (i, p) in parts.enumerate() [
        #if i > 0 [#h(0.24em)]
        #if _is-symbol-token(p) [
          $#display-symbol(p)$
        ] else [
          #p
        ]
      ]
    ]
  }

  if type(rule) == array {
    return [
      #for (i, p) in rule.enumerate() [
        #if i > 0 [#h(0.24em)]
        #if type(p) == str and _is-symbol-token(p) [
          $#display-symbol(p)$
        ] else [
          #p
        ]
      ]
    ]
  }

  if is-type(rule, "var") {
    return $#display-symbol(rule.name)$
  }

  if is-expr(rule) {
    return $#cas-display(rule)$
  }

  rule
}

#let _math-head(expr, operation: none, var: none, rhs: none) = {
  if operation == "diff" {
    return [$dif / (dif #display-symbol(var)) (#cas-display(expr))$]
  }
  if operation == "integrate" {
    return [$integral #cas-display(expr) thin dif #display-symbol(var)$]
  }
  if operation == "solve" {
    let right = if rhs == none { num(0) } else { rhs }
    return [$#cas-display(expr) = #cas-display(right)$]
  }
  [$#cas-display(expr)$]
}

#let _render-equation(step, style) = {
  let arrow = _arrow-for(step.at("eq-kind", default: "transform"), style)
  let weight = _weight-for(step.at("eq-kind", default: "transform"), style)
  let ann = if step.rule == none {
    none
  } else {
    let rc = _rule-content(step.rule)
    [
      #text(size: 0.82em, fill: style.palette.meta, weight: style.line-weight.minor)[(]
      #rc
      #text(size: 0.82em, fill: style.palette.meta, weight: style.line-weight.minor)[)]
    ]
  }

  [
    $= #cas-display(step.before)$
    #h(style.equation-gap)
    #text(fill: style.palette.transform, weight: weight)[#arrow]
    #h(style.equation-gap)
    $#cas-display(step.after)$
    #if ann != none [#h(0.4em) #ann]
  ]
}

#let _render-define(step, style) = {
  let label = step.at("label", default: none)
  let lhs = if type(step.lhs) == str {
    display-symbol(step.lhs)
  } else if is-type(step.lhs, "var") {
    display-symbol(step.lhs.name)
  } else {
    cas-display(step.lhs)
  }
  let rhs = if is-expr(step.rhs) or type(step.rhs) == dictionary {
    cas-display(step.rhs)
  } else {
    step.rhs
  }

  if label == none {
    [$#lhs = #rhs$]
  } else {
    [#text(size: 0.86em, fill: style.palette.meta, weight: style.line-weight.minor)[#label] $#lhs = #rhs$]
  }
}

#let _render-note(step, style) = {
  let fill = _tone-fill(step.at("tone", default: "note"), style)
  if step.expr != none {
    [
      #text(size: 0.88em, fill: fill, style: "italic")[#step.text]
      #h(0.35em)
      $#cas-display(step.expr)$
    ]
  } else if type(step.text) == str {
    text(size: 0.9em, fill: fill, style: "italic")[#step.text]
  } else {
    step.text
  }
}

#let _render-branch-divider(label, style) = {
  let shown = if label == none or label == "" { "Branch" } else { label }
  [
    #v(style.branch.gap-top)
    #if style.branch.show-divider [
      #line(length: 100%, stroke: style.branch.divider-stroke)
    ]
    #align(center, text(
      size: style.branch.label-size,
      fill: style.branch.label-fill,
      weight: style.branch.label-weight,
    )[#shown])
    #if style.branch.show-divider [
      #line(length: 100%, stroke: style.branch.divider-stroke)
    ]
    #v(style.branch.gap-bottom)
  ]
}

#let _render-branch-inline(label, style) = {
  let shown = if label == none or label == "" { "Branch" } else { label }
  [
    #text(
      size: style.branch.marker-size,
      fill: style.branch.marker-fill,
      weight: style.branch.marker-weight,
    )[#style.branch.marker]
    #h(style.branch.marker-gap)
    #text(
      size: style.branch.label-size,
      fill: style.branch.label-fill,
      weight: style.branch.label-weight,
    )[#shown]
  ]
}

#let _render-branch-lead(label, style) = {
  if style.branch.mode == "divider" {
    return _render-branch-divider(label, style)
  }
  _render-branch-inline(label, style)
}

#let _render-step-block(steps, style, indent: 0pt) = {
  let lines = ()

  for s in steps {
    if s.kind == "group" {
      if s.at("branch", default: false) {
        let hdr = _render-branch-lead(s.at("branch-label", default: none), style)
        lines.push(if indent == 0pt { hdr } else { pad(left: indent, hdr) })
        lines += _render-step-block(s.items, style, indent: indent + style.indent-size)
        continue
      }

      if s.title != none {
        let t = text(size: 0.88em, fill: style.palette.meta, weight: style.line-weight.minor)[#s.title]
        lines.push(if indent == 0pt { t } else { pad(left: indent, t) })
      }
      lines += _render-step-block(s.items, style, indent: indent + style.indent-size)
      continue
    }

    if s.kind == "header" {
      let row = if s.expr == none {
        text(size: 0.94em, fill: style.palette.meta, weight: style.line-weight.major)[#s.title]
      } else if s.title == none {
        [$#cas-display(s.expr)$]
      } else {
        [$#cas-display(s.expr)$ #h(0.4em) #text(size: 0.84em, fill: style.palette.meta)[(#s.title)]]
      }
      lines.push(if indent == 0pt { row } else { pad(left: indent, row) })
      continue
    }

    if s.kind == "equation" {
      let row = _render-equation(s, style)
      lines.push(if indent == 0pt { row } else { pad(left: indent, row) })
      continue
    }

    if s.kind == "define" {
      let row = _render-define(s, style)
      lines.push(if indent == 0pt { row } else { pad(left: indent, row) })
      continue
    }

    if s.kind == "note" {
      let row = _render-note(s, style)
      lines.push(if indent == 0pt { row } else { pad(left: indent, row) })
      continue
    }

    // Legacy compatibility.
    if s.kind == "apply" {
      if s.sub-steps != none and s.sub-steps.len() > 0 {
        lines += _render-step-block(s.sub-steps, style, indent: indent + style.indent-size)
      }
      let row = _render-equation(
        (
          kind: "equation",
          before: s.lhs,
          after: s.result,
          rule: s.rule,
          eq-kind: "transform",
        ),
        style,
      )
      lines.push(if indent == 0pt { row } else { pad(left: indent, row) })
      continue
    }
  }
  lines
}

/// Render a step trace block.
#let display-steps(original, steps, operation: none, var: none, rhs: none) = {
  context {
    if var != none { _check-free-var(var) }
    let style = _step-style-current()

    let lines = ()
    lines.push(_math-head(original, operation: operation, var: var, rhs: rhs))
    lines += _render-step-block(steps, style)

    block(
      inset: (left: 0.45em, y: 0.5em),
      stack(dir: ttb, spacing: 0.8em, ..lines),
    )
  }
}
