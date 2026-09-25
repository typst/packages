/// Validates the *shape* of a checklist value passed to `checkitoff()` or
/// `render-checklist()` — a configuration error (malformed/inconsistent
/// data), not a manuscript diagnostic, so it panics unconditionally
/// regardless of `strict:`. A duplicate or blank id in the checklist data
/// itself would silently make `resolve-item` return the wrong item's
/// pages, or every item after a blank id impossible to reach at all — a
/// mistake in the *grid definition*, not something the author writing
/// `check()` calls could ever cause or fix.
#let validate-checklist(checklist) = {
  assert(type(checklist) == dictionary, message: "checkitoff: checklist must be a dictionary, got " + repr(type(checklist)))
  for key in ("name", "items") {
    assert(key in checklist, message: "checkitoff: checklist is missing required key " + repr(key))
  }
  let ids = checklist.items.map(it => it.id)
  let seen = ()
  for id in ids {
    assert(id != none and id != "", message: "checkitoff: checklist " + repr(checklist.name) + " contains an item with a blank id")
    assert(id not in seen, message: "checkitoff: checklist " + repr(checklist.name) + " contains a duplicate item id " + repr(id))
    seen.push(id)
  }
  checklist
}

/// True if `id` names an item present in `checklist.items` — used by
/// `check()`/`na()` to validate their argument against the active
/// checklist, and by `grid.typ` to flag a `check()`/`na()` id that
/// doesn't belong to any item.
#let known-item(checklist, id) = checklist.items.any(it => it.id == id)
