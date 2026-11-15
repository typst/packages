// Style registry
#let styles = (
  note: (
    title: "Note",
    fill: rgb("151E2C"),
    icon: "✎",
    title-color: rgb("157AFF"),
    body-color: white,
  ),
  info: (
    title: "Info",
    fill: rgb("151E2C"),
    icon: "🛈",
    title-color: rgb("157AFF"),
    body-color: rgb("086DDD"),
  ),
  warning: (
    title: "Warning",
    fill: rgb("2A2118"),
    icon: "⚠",
    title-color: rgb("E9973F"),
    body-color: white,
  ),
  success: (
    title: "Success",
    fill: rgb("19271D"),
    icon: "✓",
    title-color: rgb("44CF6E"),
    body-color: white,
  ),
  check: (
    title: "Check",
    fill: rgb("19271D"),
    icon: "✓",
    title-color: rgb("44CF6E"),
    body-color: white,
  ),
  question: (
    title: "Question",
    fill: rgb("29291D"),
    icon: "?",
    title-color: rgb("E0DE71"),
    body-color: white,
  ),
  fail: (
    title: "Failed",
    fill: rgb("2C191A"),
    icon: "𐄂",
    title-color: rgb("AF3438"),
    body-color: white,
  ),
  example: (
    title: "Example",
    fill: rgb("194F1D"),
    icon: "🕮",
    title-color: rgb("44D96E"),
    body-color: white,
  ),
  examples: (
    title: "Examples",
    fill: rgb("194F1D"),
    icon: "🕮",
    title-color: rgb("44D96E"),
    body-color: white,
  ),
  quote: (
    title: "Quote",
    fill: rgb("222222"),
    icon: "❞",
    title-color: rgb("9E9E9E"),
    body-color: white,
  ),
)

// Helpers
#let coalesce(args) = {
  for arg in args {
    if arg != none {
      return arg
    }
  }
  none
}

// Core function

#let callout(
  body,
  kind: none,
  title: none,
  fill: none,
  title-color: none,
  body-color: none,
  icon: none,
  radius: 4pt,
  stroke: none,
  width: 100%,
) = {
  let s = if kind != none {
    if not styles.keys().contains(kind) {
      panic("Unknown callout kind: " + kind + ". Available: " + styles.keys().join(", "))
    }
    styles.at(kind)
  } else {
    (:)
  }

  let _title = coalesce((title, s.at("title", default: none), kind))
  let _fill = coalesce((fill, s.at("fill", default: none), blue))
  let _icon = coalesce((icon, s.at("icon", default: none)))
  let _title-color = coalesce((title-color, s.at("title-color", default: none), white))
  let _body-color = coalesce((body-color, s.at("body-color", default: none), black))
  let _width = coalesce((width, s.at("width", default: none), 100%))

  block(
    fill: _fill,
    inset: (x: 12pt, y: 10pt),
    width: _width,
    radius: radius,
    stroke: stroke,
    breakable: false,
  )[
    #text(fill: _title-color, weight: "bold")[#_icon #_title]
    #v(4pt)
    #text(fill: _body-color)[#body]
  ]
}

// Convenience wrappers

#let note = callout.with(kind: "note")
#let info = callout.with(kind: "info")
#let warning = callout.with(kind: "warning")
#let success = callout.with(kind: "success")
#let check = callout.with(kind: "check")
#let question = callout.with(kind: "question")
#let fail = callout.with(kind: "fail")
#let example = callout.with(kind: "example")
#let examples = callout.with(kind: "examples")
#let quote = callout.with(kind: "quote")
