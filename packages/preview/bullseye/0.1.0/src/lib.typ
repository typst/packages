/// Returns `"paged"` or `"html"` depending on the current output target.
///
/// When HTML is supported, this is equivalent to Typst's built-in
/// #link("https://staging.typst.app/docs/reference/foundations/target/")[`std.target()`]\;
/// otherwise, it always return `"paged"`.
///
/// This is a polyfill for an unstable Typst function. It may not properly emulate the built-in
/// function if it is changed before stabilization.
///
/// This function is contextual.
///
/// -> str
#let target() = {
  if "target" in dictionary(std) { std.target() }
  else { "paged" }
}

/// The `html` module.
///
/// When HTML is supported, this is equivalent to Typst's built-in
/// #link("https://staging.typst.app/docs/reference/html/")[`std.html`]\; otherwise, it's the
/// #link(<mod-html>)[Bullseye `html` module] documented below. That module doesn't _support_ HTML,
/// it just makes sure that calls to the html module that don't end up in a document don't prevent
/// compilation.
///
/// This is a stub for an unstable Typst module. It may not properly emulate the built-in module
/// (i.e. miss functions; no functionality beyond that is intended) if it is changed before
/// stabilization.
///
/// -> module
#let html = {
  if "html" in dictionary(std) {
    std.html
  } else {
    import "html.typ"
    html
  }
}

/// checks the @@target() (currently, `"paged"` and `"html"` are supported) and returns the
/// associated value in the passed named arguments. If there is none and there is a `default`
/// argument, that value is returned; otherwise there's a panic.
///
/// This function is contextual.
///
/// Examples:
///
/// ```typc
/// match-target(html: "a", paged: "b")  // returns either "a" or "b"
/// match-target(html: "a", default: "b")  // returns either "a" or "b"
/// match-target(html: "a")  // returns either "a" or panics
/// ```
///
/// -> any
#let match-target(
  /// The possible options. Only named arguments with the keys `paged`, `html` and `default` are
  /// allowed.
  /// -> arguments
  ..targets,
) = {
  assert.eq(targets.pos(), (), message: "positional arguments are not allowed")
  let targets = targets.named()
  for key in targets.keys() {
    assert(key in ("paged", "html", "default"), message: "unknown target: `" + key + "`")
  }
  let target = target()
  if target in targets {
    targets.at(target)
  } else if "default" in targets {
    targets.default
  } else {
    panic("no value specified for current target `" + target + "`")
  }
}

/// Wrapper around @@match-target() for target-specific show rules. All values should be functions
/// that you'd ordinarily use in a show rule, i.e. a single-parameter function that transforms some
/// `content`. If no default is specified, it is set to `it => it`, i.e. non-covered targets remain
/// unchanged.
///
/// This function is _not_ contextual; it returns a function that provides its own context so that
/// it can be used in show-everything rules (see examples below) that don't provide their own
/// context.
///
/// Example:
///
/// ```typ
/// #show: show-target(paged: strong, html: doc => ...)
/// // is equivalent to
/// #show: show-target(paged: strong)
/// #show: show-target(html: doc => ...)
/// // is equivalent to (pseudocode)
/// #show: strong if target() == "paged"
/// #show: doc => ... if target() == "html"
/// ```
///
/// -> function
#let show-target(
  /// The possible options. Only named arguments with the keys `paged`, `html` and `default` are
  /// allowed. The `default` key defaults to `it => it`.
  /// -> arguments
  ..targets,
) = body => context {
  match-target(default: it => it, ..targets)(body)
}

/// Wrapper around @@match-target() for target-specific values that should default to `none`;
/// particularly content, for which `none` simply has no effect. If no default is specified, it is
/// set to `none`.
///
/// This function is contextual.
///
/// Example:
///
/// ```typ
/// #on-target(paged: [foo])  // returns either [foo] or none
///
/// #(1, ..on-target(paged: (2, 3)), 4)  // returns either (1, 2, 3, 4) or (1, 4)
/// ```
///
/// -> any
#let on-target(
  /// The possible options. Only named arguments with the keys `paged`, `html` and `default` are
  /// allowed. The `default` key defaults to `none`.
  /// -> arguments
  ..targets,
) = {
  match-target(default: none, ..targets)
}
