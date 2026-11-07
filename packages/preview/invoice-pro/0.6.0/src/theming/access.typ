// Sealing (INTERNAL optimisation, never part of the contract): the resolved theme
// travels through loom ctx inside an opaque `metadata` value, which Typst hashes
// lazily, so the ~20 ns/leaf/closure-call cost does not scale with theme size.
// Parts always receive an UNSEALED ctx: `ctx.theme` is a plain dict for them.
#let seal-enabled = sys.inputs.at("ip-seal", default: "1") == "1"

#let seal(theme) = if seal-enabled { metadata(theme) } else { theme }
#let theme-of(ctx) = {
  let t = ctx.at("theme", default: none)
  if type(t) == content { t.value } else { t }
}
/// The row style (`options.row`) of the theme in effect at `ctx`, as
/// `themed(theme.custom.row(..))` sets it for a part of the body. The rows of
/// the items table record it: groups, items and the lines of bundles, so a
/// scope colours every row inside it. `none` without a theme.
#let row-style-of(ctx) = {
  let t = theme-of(ctx)
  if t == none { none } else { t.options.at("row", default: none) }
}
#let unsealed(ctx) = {
  let t = ctx.at("theme", default: none)
  if type(t) == content { ctx + (theme: t.value) } else { ctx }
}
