#import "state.typ": deixis-system, _deixis-registry
#import "targets.typ": _deixis-check-setup-state, _deixis-validate-target, _deixis-resolve-target, _deixis-with-target-scopes

#let _deixis-counter-series(series) = {
  assert(type(series) == str, message: "deixis: Counter series must be a string.")
}

#let _deixis-counter-value(value) = {
  assert(type(value) == int, message: "deixis: A counter value or update result must be an integer.")
}

// Scope and series are independent dictionary keys. Concatenating them with a
// delimiter aliases valid names containing that delimiter.
#let _deixis-read-counter(sys, count-id, series) = {
  _deixis-counter-series(series)
  _deixis-registry(sys).counters.at(count-id, default: (:)).at(series, default: 0)
}

#let _deixis-write-counter(sys, count-id, series, value) = {
  _deixis-counter-series(series)
  _deixis-counter-value(value)
  let registry = _deixis-registry(sys)
  let streams = registry.counters.at(count-id, default: (:))
  streams.insert(series, value)
  registry.counters.insert(count-id, streams)
  sys + (registry: metadata(registry))
}

/// Retrieves the current counter value for a target scope and series.
/// An unused stream starts at zero. This numbering value can be reset or changed;
/// it is not the total number of registered notes.
///
/// Use this function rather than native `counter()` for Deixis numbering.
/// Unnumbered originals (`numbering: none`) take no counter value. Page-local
/// display numbering does not change this assigned value.
///
/// Note: Because it queries the document state, this function must be called within a `context` block.
///
/// - target (int, label, str): Current scope (0), ancestor (negative integer), named/forward scope, or global `"page"`. Synchronized scopes share their resolved counter owner.
/// - series (str): Literal series name, default `"default"`. Endnote wrappers use `"endnote"`; select that explicitly when reading it. Punctuation and empty names are valid distinct strings.
///
/// ```example
/// //| sandbox-mode: "page"
/// #context deixis-note-counter()
/// ```
///
/// -> int
#let deixis-note-counter(
  /// Current scope (0), ancestor (negative integer), named scope, or global "page".
  /// -> int | label | str
  target: 0,
  /// The specific note series to query.
  /// -> str
  series: "default",
) = {
  _deixis-check-setup-state()
  _deixis-validate-target(target)
  let sys = deixis-system.get()
  let resolved = _deixis-resolve-target(sys, target)
  _deixis-read-counter(sys, resolved.count-id, series)
}

/// Set or update the current counter value for one target scope and series.
/// The next numbered original mark increments that value. Resetting to zero makes
/// the next numbered original use one; earlier notes retain their assigned numbers and identities.
/// Unnumbered originals, bodies, references, and reused marks do not increment it.
///
/// Reset a stream at a chapter or section boundary, or use `deixis-block`
/// for an independent local collection. Other series are unaffected.
///
/// - value (int, function): Integer or a function `(current) => int`. Direct values and results must be integers; strings, floats, and booleans are not coerced. Negative displayed counts need a suitable numbering callback.
/// - target (int, label, str): Current scope (0), ancestor (negative integer), named/forward scope, or global `"page"`. Updates affect all scopes synchronized with that counter owner.
/// - series (str): Literal series name, default `"default"`; other series are untouched.
///
/// ```example
/// //| sandbox-mode: "page"
/// #deixis-update-note-counter(0)
/// #context deixis-note-counter()
/// ```
///
/// -> content
#let deixis-update-note-counter(
  /// Integer or a function of the current value returning an integer. Use 0 to
  /// restart the next numbered original at 1. Values are not coerced.
  /// -> int | function
  value,
  /// Current scope (0), ancestor (negative integer), named/forward scope, or "page".
  /// -> int | label | str
  target: 0,
  /// The specific note series to update.
  /// -> str
  series: "default",
) = {
  assert(type(value) in (int, function),
    message: "deixis: A counter update must be an integer or a function returning an integer; values are not coerced.")
  _deixis-counter-series(series)
  context _deixis-check-setup-state()

  _deixis-validate-target(target)
  _deixis-with-target-scopes(target, scopes => {
    deixis-system.update(sys => {
      let resolved = _deixis-resolve-target(sys, target, scopes: scopes)
      let current = _deixis-read-counter(sys, resolved.count-id, series)
      let new-val = if type(value) == function { value(current) } else { value }
      _deixis-write-counter(sys, resolved.count-id, series, new-val)
    })
  })
}
