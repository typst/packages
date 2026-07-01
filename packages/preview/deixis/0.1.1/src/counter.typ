#import "core.typ": *

/// Retrieves the current integer count of notes for a specific target block and series.
///
/// Because `deixis` relies on a custom state engine to track scoped notes, you cannot use Typst's native
/// `counter()` function to read note counts. This function provides direct access to the internal engine.
///
/// Note: Because it queries the document state, this function must be called within a `context` block.
///
/// - target (int, label, str): The specific block or minipage to query. Defaults to `0` (the current block). Accepts a label/string ID, or a negative integer to query relative parent blocks.
/// - series (str): The specific note series to query. Defaults to `"default"`.
///
/// ```example
/// //| sandbox-mode: "page"
/// #context deixis-note-counter()
/// ```
///
/// -> int
#let deixis-note-counter(
  /// The specific block or minipage to query. Defaults to `0` (the current block). Accepts a label/string ID, or a negative integer to query relative parent blocks.
  /// -> int | label | str
  target: 0,
  /// The specific note series to query.
  /// -> str
  series: "default",
) = {
  _deixis-validate-target(target)
  let sys = deixis-system.get()
  let resolved = _deixis-resolve-target(sys, target)
  sys.counters.at(resolved.count-id + ":" + series, default: 0)
}

/// Set or update the note counter for a specific target block and series.
///
/// This is highly useful for manually resetting note counts at the start of a new chapter or section
/// if you are not using an automatic minipage wrapper. It modifies the internal `deixis` state dictionary.
///
/// - value (int, function): The new integer value for the counter. Alternatively, pass a function `(current-count) => int` to modify the count relative to its current value.
/// - target (int, label, str): The specific block or minipage whose counter should be updated. Defaults to `0` (the current block). Accepts a label/string ID, or a negative integer for relative parent blocks.
/// - series (str): The specific note series to update. Defaults to `"default"`.
///
/// ```example
/// //| sandbox-mode: "page"
/// #deixis-update-note-counter(0)
/// #context deixis-note-counter()
/// ```
///
/// -> content
#let deixis-update-note-counter(
  /// The new integer value for the counter. Alternatively, pass a function `(current-count) => int` to modify the count relative to its current value.
  /// -> int | function
  value,
  /// The specific block or minipage whose counter should be updated. Defaults to `0` (the current block). Accepts a label/string ID, or a negative integer for relative parent blocks.
  /// -> int | label | str
  target: 0,
  /// The specific note series to update.
  /// -> str
  series: "default",
) = {
  context _deixis-check-setup-state()

  _deixis-validate-target(target)
  deixis-system.update(sys => {
    let resolved = _deixis-resolve-target(sys, target)
    let full-c-id = resolved.count-id + ":" + series
    let current = sys.counters.at(full-c-id, default: 0)
    let new-val = if type(value) == function { value(current) } else { int(value) }
    let new-counters = sys.counters
    new-counters.insert(full-c-id, new-val)
    return (..sys, counters: new-counters)
  })
}
