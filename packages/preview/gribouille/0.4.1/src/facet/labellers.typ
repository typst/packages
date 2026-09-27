///! Strip labellers for facets.
///!
///! Labellers transform the raw level value of a facet variable into the
///! string drawn in the strip. The default is `label-value`, which preserves
///! the level as-is. Combine several labellers into one with `labeller` so
///! different facet variables can use different rules.

/// Default labeller: shows the level value as-is.
///
/// Returns: Labeller dictionary consumed by `facet-wrap` and `facet-grid`.
///
/// See also: `label-both`, `label-context`, `label-wrap`, `labeller`.
///
/// Strip text shows the level value as-is (`"a"`, `"b"`).
///
/// ```typst
/// #let d = ()
/// #for sp in ("a", "b") {
///   for i in range(0, 4) {
///     d.push((sp: sp, x: i, y: i))
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   facet: facet-wrap("sp", labeller: label-value()),
///   width: 10cm,
///   height: 5cm,
/// )
/// ```
#let label-value() = (
  kind: "labeller",
  labeller: "value",
)

/// Labeller showing both the variable name and the level.
///
/// Produces a label of the form `"<variable>: <level>"`, e.g., `"cyl: 6"`.
///
/// - separator: Separator between the variable name and the level.
///
/// Returns: Labeller dictionary consumed by `facet-wrap` and `facet-grid`.
///
/// See also: `label-value`, `label-context`, `labeller`.
///
/// Strip shows the variable name and level (`"sp: a"`, `"sp: b"`).
///
/// ```typst
/// #let d = ()
/// #for sp in ("a", "b") {
///   for i in range(0, 4) {
///     d.push((sp: sp, x: i, y: i))
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   facet: facet-wrap("sp", labeller: label-both()),
///   width: 10cm,
///   height: 5cm,
/// )
/// ```
///
/// Override `separator` to use a different separator.
///
/// ```typst
/// #let d = ()
/// #for sp in ("a", "b") {
///   for i in range(0, 4) {
///     d.push((sp: sp, x: i, y: i))
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   facet: facet-wrap("sp", labeller: label-both(separator: " = ")),
///   width: 10cm,
///   height: 5cm,
/// )
/// ```
#let label-both(separator: ": ") = (
  kind: "labeller",
  labeller: "both",
  separator: separator,
)

/// Labeller appending the row count for each level.
///
/// Produces a label of the form `"<level> (n = <count>)"` where `<count>` is the number of rows in the panel. The renderer supplies the count when it draws the strip.
///
/// Returns: Labeller dictionary consumed by `facet-wrap` and `facet-grid`.
///
/// See also: `label-value`, `label-both`, `labeller`.
///
/// Strip text appends the per-panel row count.
///
/// ```typst
/// #let d = ()
/// #for sp in ("a", "b") {
///   for i in range(0, 4) {
///     d.push((sp: sp, x: i, y: i))
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   facet: facet-wrap("sp", labeller: label-context()),
///   width: 10cm,
///   height: 5cm,
/// )
/// ```
#let label-context() = (
  kind: "labeller",
  labeller: "context",
)

/// Labeller wrapping long labels onto multiple lines.
///
/// Splits the label every `width` characters, inserting a line break at the nearest preceding space when one exists. Inner labellers may be supplied to first transform the level.
///
/// - width: Maximum number of characters per line.
/// - inner: Labeller applied before wrapping, or `none` for the raw level.
///
/// Returns: Labeller dictionary consumed by `facet-wrap` and `facet-grid`.
///
/// See also: `label-value`, `label-both`, `labeller`.
///
/// Wrap long category names onto multiple strip lines.
///
/// ```typst
/// #let d = (
///   (sp: "a long category name", x: 1, y: 1),
///   (sp: "a long category name", x: 2, y: 2),
///   (sp: "another long one",     x: 1, y: 3),
///   (sp: "another long one",     x: 2, y: 4),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   facet: facet-wrap("sp", labeller: label-wrap(width: 10)),
///   width: 10cm,
///   height: 5cm,
/// )
/// ```
///
/// Combine `inner` with `label-both` to wrap a `var: value` label.
///
/// ```typst
/// #let d = (
///   (sp: "alpha-with-long-suffix", x: 1, y: 1),
///   (sp: "alpha-with-long-suffix", x: 2, y: 2),
///   (sp: "beta-with-long-suffix",  x: 1, y: 3),
///   (sp: "beta-with-long-suffix",  x: 2, y: 4),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   facet: facet-wrap("sp", labeller: label-wrap(width: 14, inner: label-both())),
///   width: 10cm,
///   height: 5cm,
/// )
/// ```
#let label-wrap(width: 20, inner: none) = (
  kind: "labeller",
  labeller: "wrap",
  width: width,
  inner: inner,
)

/// Combine labellers into a single rule keyed by facet variable.
///
/// `rules` is a dict of `var-name -> labeller`. Variables not listed fall back to the labeller passed via `default`.
///
/// - rules: Dict mapping facet variable names to labellers.
/// - default: Labeller used for variables absent from `rules`.
///
/// Returns: Labeller dictionary consumed by `facet-wrap` and `facet-grid`.
///
/// See also: `label-value`, `label-both`, `label-context`.
///
/// Mix labellers per facet variable: rows show `var: level`, columns show level only.
///
/// ```typst
/// #let d = ()
/// #for sp in ("a", "b") {
///   for sex in ("F", "M") {
///     d.push((sp: sp, sex: sex, x: 1, y: 1))
///     d.push((sp: sp, sex: sex, x: 2, y: 2))
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   facet: facet-grid(
///     rows: "sex",
///     columns: "sp",
///     labeller: labeller(rules: (sex: label-both(), sp: label-value())),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Set `default` to a fallback labeller for variables not listed in `rules`.
///
/// ```typst
/// #let d = ()
/// #for sp in ("a", "b") {
///   for sex in ("F", "M") {
///     d.push((sp: sp, sex: sex, x: 1, y: 1))
///     d.push((sp: sp, sex: sex, x: 2, y: 2))
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   facet: facet-grid(
///     rows: "sex",
///     columns: "sp",
///     labeller: labeller(
///       rules: (sex: label-both()),
///       default: label-context(),
///     ),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let labeller(rules: (:), default: none) = (
  kind: "labeller",
  labeller: "compound",
  rules: rules,
  default: if default == none { (kind: "labeller", labeller: "value") } else {
    default
  },
)

// Resolve a labeller for a specific facet variable. Compound labellers pick
// the rule matching `var`, falling back to `default`.
#let _pick(lab, var) = {
  if lab == none { return (kind: "labeller", labeller: "value") }
  if lab.labeller != "compound" { return lab }
  lab.rules.at(var, default: lab.default)
}

// Soft-wrap `s` to lines no longer than `width`, breaking at the latest space
// at or before the limit when possible. Falls back to a hard split.
#let _soft-wrap(s, width) = {
  if width <= 0 { return s }
  let n = s.len()
  if n <= width { return s }
  let lines = ()
  let rest = s
  while rest.len() > width {
    // Skip leading whitespace before measuring the next line.
    while rest.len() > 0 and rest.at(0) == " " { rest = rest.slice(1) }
    if rest.len() <= width { break }
    let head = rest.slice(0, width)
    let space-at = -1
    let i = 0
    while i < head.len() {
      if head.at(i) == " " { space-at = i }
      i = i + 1
    }
    if space-at > 0 {
      lines.push(rest.slice(0, space-at))
      rest = rest.slice(space-at + 1)
    } else {
      lines.push(head)
      rest = rest.slice(width)
    }
  }
  while rest.len() > 0 and rest.at(0) == " " { rest = rest.slice(1) }
  if rest.len() > 0 { lines.push(rest) }
  lines.join("\n")
}

// Apply a single labeller to a (var, level, count) triple. `count` may be
// `none` if the renderer cannot supply it.
#let apply-one(lab, var, level, count) = {
  if lab == none { return level }
  if lab.labeller == "value" { return level }
  if lab.labeller == "both" { return var + lab.separator + level }
  if lab.labeller == "context" {
    if count == none { return level }
    return level + " (n = " + str(count) + ")"
  }
  if lab.labeller == "wrap" {
    let inner-text = if lab.inner == none { level } else {
      apply-one(lab.inner, var, level, count)
    }
    return _soft-wrap(inner-text, lab.width)
  }
  level
}

// Public entry point used by the renderer. Picks the rule for `var` then
// formats the level. `count` may be `none`.
#let format(lab, var, level, count: none) = apply-one(
  _pick(lab, var),
  var,
  level,
  count,
)
