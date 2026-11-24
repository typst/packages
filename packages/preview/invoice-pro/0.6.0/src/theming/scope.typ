#import "../loom-wrapper.typ": motif
#import "build.typ": scope-theme
#import "access.typ": seal, theme-of, unsealed
#import "../validation/issue.typ": enforce
#import "../validation/render.typ": emit

/// Re-themes a subtree with the same patches as `theme.custom`. Derived tokens
/// re-derive inside the scope. Layout patches and named arguments are rejected.
/// Findings of the scoped theme (e.g. contrast) follow `invoice(validation: ..)`.
/// -> content
#let themed(..patches, body) = {
  if patches.named().len() > 0 {
    panic(
      "themed: unexpected named argument(s) `"
        + patches.named().keys().join("`, `")
        + "`; pass patches, e.g. themed(theme.custom.colors(primary: red))[..]",
    )
  }
  motif(
    scope: ctx => {
      let t = scope-theme(theme-of(ctx), patches.pos())
      let level = ctx.at("validation", default: (level: none)).level
      // strict panics here; draft emits in draw (ids prefixed: a scope may
      // repeat a document-level finding with other colours); none drops them
      t.issues = if level == none { () } else {
        enforce(t.issues, level).map(x => x + (id: "themed/" + x.id))
      }
      ctx + (theme: seal(t))
    },
    measure: (_, children) => (children, none),
    draw: (ctx, _, _, body) => {
      let issues = theme-of(ctx).issues
      if ctx.at("validation", default: (level: none)).level == "draft" {
        emit(issues)
      }
      body
    },
    body,
  )
}
