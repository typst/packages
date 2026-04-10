// =========================================================================
// CAS Steps Renderer
// =========================================================================
// Renders step traces into displayable Typst content blocks.
// =========================================================================

#import "../expr.typ": *
#import "../display.typ": cas-display
#import "../helpers.typ": check-free-var as _check-free-var

// =========================================================================
// 2. DISPLAY ENGINE
// =========================================================================

/// Render a traced derivation as a stacked block of math lines.
/// Supports plain display plus operation-specific headers for `diff`,
/// `integrate`, and `solve`.
#let display-steps(original, steps, operation: none, var: none, rhs: none) = {
  if var != none { _check-free-var(var) }
  let lines = ()

  // 1. Initial Setup Line
  if operation == "diff" {
    lines.push($d / (d #cas-display(cvar(var))) (#cas-display(original))$)
  } else if operation == "integrate" {
    let body = cas-display(original)
    if is-type(original, "add") { body = $lr((#body))$ }
    lines.push($integral #body thin #math.italic("d" + var)$)
  } else if operation == "solve" {
    let rhs-expr = if rhs != none { rhs } else { num(0) }
    lines.push($#cas-display(original) = #cas-display(rhs-expr)$)
  } else {
    lines.push($#cas-display(original)$)
  }

  // 2. Render Steps
  // Helper to indent sub-steps
  let render-sub(sub-steps, depth) = {
    let sub-lines = ()
    let indent = 1.5em * depth
    for s in sub-steps {
      if s.kind == "note" and s.expr != none {
        sub-lines.push(pad(left: indent, text(fill: eastern)[
          $= #cas-display(s.expr)$ #h(0.5em) #text(size: 0.8em, fill: luma(120))[(#s.text)]
        ]))
      } else if s.kind == "note" {
        if type(s.text) == str {
          sub-lines.push(pad(left: indent, text(size: 0.9em, fill: luma(100), style: "italic")[#s.text]))
        } else {
          sub-lines.push(pad(left: indent, s.text))
        }
      } else if s.kind == "header" {
        sub-lines.push(pad(left: indent, text(fill: eastern)[
          $= #cas-display(s.expr)$ #h(0.5em) #text(size: 0.8em, fill: luma(120))[(#s.rule)]
        ]))
      } else if s.kind == "define" {
        let lhs = cas-display(cvar(s.name))
        if s.prefix == none {
          sub-lines.push(pad(left: indent, text(fill: eastern)[$#lhs = #cas-display(s.val)$]))
        } else {
          sub-lines.push(pad(left: indent, text(fill: eastern)[
            #s.prefix $#lhs = #cas-display(s.val)$
          ]))
        }
      } else if s.kind == "apply" {
        if s.sub-steps.len() > 0 {
          sub-lines += render-sub(s.sub-steps, depth + 1)
        }
        sub-lines.push(pad(left: indent, text(fill: eastern)[
          $#s.lhs = #cas-display(s.result)$ #h(0.5em) #text(size: 0.8em, fill: luma(120))[(#s.rule)]
        ]))
      }
    }
    sub-lines
  }

  for s in steps {
    if s.kind == "header" {
      lines.push([$= #cas-display(s.expr)$ #h(0.5em) #text(size: 0.8em, fill: luma(120))[(#s.rule)]])
    } else if s.kind == "note" {
      if s.expr != none {
        lines.push([$= #cas-display(s.expr)$ #h(0.5em) #text(size: 0.8em, fill: luma(120))[(#s.text)]])
      } else {
        if type(s.text) == str {
          lines.push(text(size: 0.9em, fill: luma(100), style: "italic")[#s.text])
        } else {
          lines.push(s.text)
        }
      }
    } else if s.kind == "define" {
      let lhs = cas-display(cvar(s.name))
      if s.prefix == none {
        lines.push(pad(left: 1.5em, text(fill: eastern)[$#lhs = #cas-display(s.val)$]))
      } else {
        lines.push(pad(left: 1.5em, text(fill: eastern)[
          #s.prefix $#lhs = #cas-display(s.val)$
        ]))
      }
    } else if s.kind == "apply" {
      if s.sub-steps.len() > 0 {
        lines += render-sub(s.sub-steps, 1)
      }
      lines.push(pad(left: 1.5em, text(fill: eastern)[
        $#s.lhs = #cas-display(s.result)$ #h(0.5em) #text(size: 0.8em, fill: luma(120))[(#s.rule)]
      ]))
    } else if s.kind == "combine" {
      // Legacy support or final result
      lines.push($= #cas-display(s.result)$)
    }
  }

  block(
    inset: (left: 0.5em, y: 0.5em),
    stack(dir: ttb, spacing: 1em, ..lines),
  )
}
