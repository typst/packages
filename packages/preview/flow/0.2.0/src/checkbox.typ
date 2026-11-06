#import "gfx/mod.typ" as gfx

// Returns `default` in place of missing values when slicing out-of-bounds towards the positive end.
#let _graceful-slice(it, start, end, default: []) = {
  if end == -1 {
    end = it.len()
  }

  let missing = calc.max(start, end - it.len(), 0)
  it += (default,) * missing
  it.slice(start, end)
}

#let _handle-item(it, kind: "list") = {
  // body can be a sequence (=> have children) or be directly text
  // either way we just want the children as array
  let body = it.body.fields().at(
    "children",
    default: (it.body,),
  )
  let checkbox = _graceful-slice(body, 0, 3)
  let fill = checkbox.at(1).fields().at("text", default: " ")

  let is-checkbox = (
    checkbox.at(0) == [\[] and
    fill.len() == 1 and
    checkbox.at(-1) == [\]]
  )

  if not is-checkbox {
    return it
  }

  // convert the fill character to a showable icon
  let checkbox = gfx.markers.at(fill, default: gfx.markers.at("?")).icon
  // just a few minor positioning tweaks
  let checkbox = box(move(dx: -0.1em, checkbox()))

  // and remove the description from the checkbox itself
  let desc = _graceful-slice(body, 3, -1).join()

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
