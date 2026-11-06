#import "asset.typ"
#import "gfx/mod.typ" as gfx
#import "hacks.typ"
#import "util/mod.typ": dbg

/// Returns the fill as a string if `it`
/// comes from a task list entry,
/// returns `none` otherwise.
#let _find-fill(it) = {
  let source = hacks.reconstruct-text(it)
  
  let pattern = asset.data.regex.checkbox
  let checkbox = source.matches(regex("^" + pattern))

  if checkbox == () {
    // nothing to do, this is not a checkbox
    return none
  }

  // can be only one since the regex was anchored
  checkbox.first().captures.first()
}

/// Returns a displayable checkbox icon as content
/// for the given fill character.
#let _get-icon(fill) = {
  let icon = gfx.markers.at(fill, default: gfx.markers.at("?")).icon

  // just a few minor positioning tweaks
  // without the inset, the checkbox wiggles down a bit when typing the desc
  box(move(dx: -0.1em, icon()), inset: 0.05em)
}

/// Show transformation for one kind of a list.
#let _handle-item(it, kind: "list") = {
  let fill = _find-fill(it)
  if fill == none {
    return it
  }
  let checkbox = _get-icon(fill)

  // and remove the description from the checkbox itself
  // HACK: we know `it.body` has to be a sequence
  // since it contains "special characters" for the checkbox
  // hence the desc must be the 4th element on in the sequence
  let desc = it.body.children.slice(3).join()

  // then throw them together
  let full-entry = [#checkbox #desc]
  if kind == "list" {
    [- #full-entry]
  } else if kind == "enum" {
    [+ #full-entry]
  }
}

// Goes through the whole given document,
// converts all item and enum entries that follow the checkbox syntax
// into visually appealing checkboxes,
// and returns the modified document.
// You should use this via a show rule.
#let process(body) = {
  show list.item: _handle-item.with(kind: "list")
  show enum.item: _handle-item.with(kind: "enum")

  body
}
