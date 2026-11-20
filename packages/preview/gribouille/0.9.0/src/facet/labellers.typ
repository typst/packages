///! Strip labellers for facets.
///!
///! Labellers transform the raw level value of a facet variable into the
///! string drawn in the strip. The default is `label-value`, which preserves
///! the level as-is. Combine several labellers into one with `labeller` so
///! different facet variables can use different rules.

#import "../utils/errors.typ": check, fail-enum, fail-type
#import "../utils/wrap.typ": soft-wrap

#let _known-labellers = ("value", "both", "context", "wrap", "compound")

#let _check-string(scope, name, value) = {
  if type(value) != str { fail-type(scope, name, value, "a string") }
}

// Check that `lab` is a labeller dictionary, recursing into the labellers it
// holds. Public constructors build such a dictionary, but a facet also takes a
// hand-written one, so the facet constructors run this on their argument.
#let check-labeller(scope, name, lab) = {
  if type(lab) != dictionary or lab.at("kind", default: none) != "labeller" {
    fail-type(scope, name, lab, "a labeller such as `label-value()`")
  }
  let kind = lab.at("name", default: none)
  if kind not in _known-labellers {
    fail-enum(scope, name + " name", kind, _known-labellers)
  }
  if kind == "wrap" and lab.inner != none {
    check-labeller(scope, name, lab.inner)
  }
  if kind == "compound" {
    check-labeller(scope, name, lab.default)
    for (_, rule) in lab.rules { check-labeller(scope, name, rule) }
  }
}

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
  name: "value",
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
#let label-both(separator: ": ") = {
  _check-string("label-both", "separator", separator)
  (
    kind: "labeller",
    name: "both",
    separator: separator,
  )
}

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
  name: "context",
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
#let label-wrap(width: 20, inner: none) = {
  if type(width) != int {
    fail-type("label-wrap", "width", width, "a positive integer")
  }
  check(
    width >= 1,
    "label-wrap",
    "width must be a positive integer; got " + repr(width),
  )
  if inner != none { check-labeller("label-wrap", "inner", inner) }
  (
    kind: "labeller",
    name: "wrap",
    width: width,
    inner: inner,
  )
}

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
#let labeller(rules: (:), default: none) = {
  if type(rules) != dictionary {
    fail-type("labeller", "rules", rules, "a dictionary of labellers")
  }
  for (_, rule) in rules { check-labeller("labeller", "rules", rule) }
  if default != none { check-labeller("labeller", "default", default) }
  (
    kind: "labeller",
    name: "compound",
    rules: rules,
    default: if default == none { (kind: "labeller", name: "value") } else {
      default
    },
  )
}

// Resolve a labeller for a specific facet variable. Compound labellers pick
// the rule matching `var`, falling back to `default`.
#let _pick(lab, var) = {
  if lab == none { return (kind: "labeller", name: "value") }
  if lab.name != "compound" { return lab }
  lab.rules.at(var, default: lab.default)
}

// Apply a single labeller to a (var, level, count) triple. `count` may be
// `none` if the renderer cannot supply it.
#let apply-one(lab, var, level, count) = {
  let level = str(level)
  if lab == none { return level }
  if lab.name == "value" { return level }
  if lab.name == "both" { return var + lab.separator + level }
  if lab.name == "context" {
    if count == none { return level }
    return level + " (n = " + str(count) + ")"
  }
  if lab.name == "wrap" {
    let inner-text = if lab.inner == none { level } else {
      apply-one(lab.inner, var, level, count)
    }
    return soft-wrap(inner-text, lab.width)
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
