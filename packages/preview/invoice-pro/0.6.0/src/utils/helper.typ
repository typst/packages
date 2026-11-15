#let date(d, m, y) = datetime(day: d, month: m, year: y)

/// The first of `values` that is given, i.e. not `none`, `auto` or empty, or
/// `none`. For inputs with fallbacks: the context of an invoice holds every
/// parameter of `invoice`, most of them as `none`, so a lookup with
/// `ctx.at(key, default: ..)` would never reach its fallback.
///
/// -> any
#let first-given(..values) = {
  for value in values.pos() {
    if value not in (none, auto, "", []) { return value }
  }
  none
}
