// References — referee `name` as a level-3 heading with the
// `reference` quote in italic beneath, joined by the standard divider
// rule. Entries lacking `reference` are skipped (no orphan heading);
// entries lacking `name` render the quote anonymously.

#import "../internal/text.typ": _present
#import "../internal/primitives.typ": _section

#let _references(entries, labels, prefs) = {
  let valid = entries.filter(r => _present(r.at("reference", default: none)))
  // Fallback is opt-in so an empty `references` block stays silent by
  // default — matching every other section's no-data behaviour. Only
  // the fallback needs its own heading; the populated path is the
  // standard section skeleton.
  if valid.len() > 0 {
    _section(labels.references, valid, entry => {
      let name = entry.at("name", default: none)
      if _present(name) [=== #name]
      emph(entry.reference)
    })
  } else if prefs.referencesAvailableOnRequest {
    [== #labels.references]
    emph(labels.referencesAvailableOnRequest)
  }
}
