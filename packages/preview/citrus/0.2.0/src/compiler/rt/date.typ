// citrus - Compiler Runtime: Date

#import "../../interpreter/date.typ": handle-date as _handle-date
#import "../../core/mod.typ": is-empty

/// Format date from a CSL <date> element
/// Hybrid adapter: use interpreter implementation
#let format-date-compiled(ctx, attrs, children) = {
  let done-vars = ctx.at("done-vars", default: ())
  let var-name = attrs.at("variable", default: "issued")
  if var-name in done-vars {
    return ([], "none", (), false)
  }
  let node = (
    tag: "date",
    attrs: attrs,
    children: children,
  )

  let content = _handle-date(node, ctx)
  let var-state = if is-empty(content) { "no-var" } else { "var" }
  let ends = if type(content) == str { content.trim().ends-with(".") } else {
    false
  }
  let suffix = ctx.at("year-suffix", default: none)
  let has-explicit = ctx.at("has-explicit-year-suffix", default: false)
  let done-vars = ctx.at("done-vars", default: ())
  let mark-suffix = (
    suffix != none
      and suffix != ""
      and not has-explicit
      and "__year-suffix-done" not in done-vars
  )
  let date-done = if mark-suffix { ("__year-suffix-done",) } else { () }
  (content, var-state, date-done, ends)
}
