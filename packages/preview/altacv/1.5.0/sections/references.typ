// References — referee `name` as a level-3 heading with the
// `reference` quote in italic beneath, joined by the standard divider
// rule. Entries lacking `reference` are skipped (no orphan heading);
// entries lacking `name` render the quote anonymously.

#import "../internal/text.typ": _present
#import "../internal/primitives.typ": _join_with_dividers

#let _references(entries, labels, prefs) = {
  let valid = entries.filter(r => _present(r.at("reference", default: none)))
  let empty = valid.len() == 0
  // Fallback is opt-in so an empty `references` block stays silent by
  // default — matching every other section's no-data behaviour.
  if empty and not prefs.referencesAvailableOnRequest { return }
  [== #labels.references]
  if empty {
    emph(labels.referencesAvailableOnRequest)
  } else {
    _join_with_dividers(valid, entry => block(breakable: false, {
      let name = entry.at("name", default: none)
      if _present(name) [=== #name]
      emph(entry.reference)
    }))
  }
}
