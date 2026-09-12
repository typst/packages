// citrus - Compiler Runtime: Label

#import "../../interpreter/number.typ": handle-label as _handle-label
#import "../../core/mod.typ": is-empty

/// Format label from a CSL <label> element
#let format-label-compiled(ctx, attrs) = {
  let node = (
    tag: "label",
    attrs: attrs,
    children: (),
  )

  let stub-interpret(children, c) = []
  let content = _handle-label(node, ctx, stub-interpret)
  let var-state = if is-empty(content) { "no-var" } else { "none" }
  let ends = if type(content) == str { content.trim().ends-with(".") } else {
    false
  }
  (content, var-state, (), ends)
}
