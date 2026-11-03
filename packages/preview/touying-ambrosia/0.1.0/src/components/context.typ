// Touying resolves this standard raw-wrapper protocol before layout. The private
// label also permits our purely stylistic helpers to render in a late context.
#let component-wrapper(fn, ..args) = [#metadata((
  kind: "touying-fn-wrapper-raw",
  fn: fn,
  args: args,
))<ambrosia-component>]

#let apply-context-components(self: none, body) = {
  show <ambrosia-component>: it => (it.value.fn)(self: self, ..it.value.args)
  body
}
