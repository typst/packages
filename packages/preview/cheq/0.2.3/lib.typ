/// `unchecked-sym` function.
///
/// - `fill`: [`string`] - The fill color for the unchecked symbol.
/// - `stroke`: [`string`] - The stroke color for the unchecked symbol.
/// - `radius`: [`string`] - The radius of the unchecked symbol.
#let unchecked-sym(fill: white, stroke: rgb("#616161"), radius: .1em) = move(dy: -.08em, box(
  stroke: .05em + stroke,
  fill: fill,
  height: .8em,
  width: .8em,
  radius: radius,
))

/// `checked-sym` function.
///
/// - `fill`: [`string`] - The fill color for the checked symbol.
/// - `stroke`: [`string`] - The stroke color for the checked symbol.
/// - `radius`: [`string`] - The radius of the checked symbol.
#let checked-sym(fill: white, stroke: rgb("#616161"), radius: .1em) = move(dy: -.08em, box(
  stroke: .05em + stroke,
  fill: stroke,
  height: .8em,
  width: .8em,
  radius: radius,
  {
    box(move(dy: .48em, dx: 0.1em, rotate(45deg, reflow: false, line(length: 0.3em, stroke: fill + .1em))))
    box(move(dy: .38em, dx: -0.05em, rotate(-45deg, reflow: false, line(length: 0.48em, stroke: fill + .1em))))
  },
))

/// `incomplete-sym` function.
///
/// - `fill`: [`string`] - The fill color for the incomplete symbol.
/// - `stroke`: [`string`] - The stroke color for the incomplete symbol.
/// - `radius`: [`string`] - The radius of the incomplete symbol.
#let incomplete-sym(fill: white, stroke: rgb("#616161"), radius: .1em) = move(dy: -.08em, box(
  stroke: .05em + stroke,
  fill: fill,
  height: .8em,
  width: .8em,
  radius: radius,
  {
    box(fill: stroke, height: .8em, width: .4em, radius: (top-left: radius, bottom-left: radius))
  },
))

/// `canceled-sym` function.
///
/// - `fill`: [`string`] - The fill color for the canceled symbol.
/// - `stroke`: [`string`] - The stroke color for the canceled symbol.
/// - `radius`: [`string`] - The radius of the canceled symbol.
#let canceled-sym(fill: white, stroke: rgb("#616161"), radius: .1em) = move(dy: -.08em, box(
  stroke: .05em + stroke,
  fill: stroke,
  height: .8em,
  width: .8em,
  radius: radius,
  {
    align(center + horizon, box(height: .125em, width: 0.55em, fill: fill))
  },
))


/// `checklist` function.
///
/// Example: `#show: checklist.with(fill: luma(95%), stroke: blue, radius: .2em)`
///
/// **Arguments:**
///
/// - `fill`: [`string`] - The fill color for the checklist marker.
/// - `stroke`: [`string`] - The stroke color for the checklist marker.
/// - `radius`: [`string`] - The radius of the checklist marker.
/// - `marker-map`: [`map`] - The map of the checklist marker. It should be a map of character to symbol function, such as `(" ": sym.ballot, "x": sym.ballot.cross, "-": sym.bar.h, "/": sym.slash.double)`.
/// - `show-list-set-block`: [`dictionary`] - The configuration of the block in list. It should be a dictionary of `above` and `below` keys, such as `(above: .5em)`.
/// - `body`: [`content`] - The main body from `#show: checklist` rule.
///
/// The default map is:
///
/// ```typ
/// #let default-map = (
///   "x": checked-sym(fill: fill, stroke: stroke, radius: radius),
///   " ": unchecked-sym(fill: fill, stroke: stroke, radius: radius),
///   "/": incomplete-sym(fill: fill, stroke: stroke, radius: radius),
///   "-": canceled-sym(fill: fill, stroke: stroke, radius: radius),
///   ">": "➡",
///   "<": "📆",
///   "?": "❓",
///   "!": "❗",
///   "*": "⭐",
///   "\"": "❝",
///   "l": "📍",
///   "b": "🔖",
///   "i": "ℹ️",
///   "S": "💰",
///   "I": "💡",
///   "p": "👍",
///   "c": "👎",
///   "f": "🔥",
///   "k": "🔑",
///   "w": "🏆",
///   "u": "🔼",
///   "d": "🔽",
/// )
/// ```
#let checklist(
  fill: white,
  stroke: rgb("#616161"),
  radius: .1em,
  marker-map: (:),
  show-list-set-block: (above: .5em),
  body,
) = {
  let default-map = (
    "x": checked-sym(fill: fill, stroke: stroke, radius: radius),
    " ": unchecked-sym(fill: fill, stroke: stroke, radius: radius),
    "/": incomplete-sym(fill: fill, stroke: stroke, radius: radius),
    "-": canceled-sym(fill: fill, stroke: stroke, radius: radius),
    ">": "➡",
    "<": "📆",
    "?": "❓",
    "!": "❗",
    "*": "⭐",
    "\"": "❝",
    "l": "📍",
    "b": "🔖",
    "i": "ℹ️",
    "S": "💰",
    "I": "💡",
    "p": "👍",
    "c": "👎",
    "f": "🔥",
    "k": "🔑",
    "w": "🏆",
    "u": "🔼",
    "d": "🔽",
  )
  let marker-map = default-map + marker-map

  show: body => {
    if show-list-set-block != none {
      show list: set block(..show-list-set-block)
      body
    } else {
      body
    }
  }

  show list.item: it => {
    // The body should be a sequence
    if not (type(it.body) == content and it.body.func() == [].func()) {
      return it
    }
    let children = it.body.children

    // A checklist item has at least 5 children: `[`, markder, `]`, space, content
    if children.len() < 5 or not (children.at(0) == [#"["] and children.at(2) == [#"]"] and children.at(3) == [ ]) {
      return it
    }

    let marker-text = if children.at(1) == [ ] {
      " "
    } else if children.at(1) == ["] {
      "\""
    } else if children.at(1) == ['] {
      "'"
    } else if children.at(1).has("text") {
      children.at(1).text
    } else {
      none
    }

    if marker-text != none and marker-text in marker-map and marker-map.at(marker-text) != none {
      if "html" in dictionary(std) and target() == "html" {
        list.item(
          box(if marker-text == "x" {
            html.elem("input", attrs: (
              type: "checkbox",
              style: "margin: 0 .2em .25em -1.4em; vertical-align: middle;",
              checked: "checked",
            ))
          } else if marker-text == " " {
            html.elem("input", attrs: (
              type: "checkbox",
              style: "margin: 0 .2em .25em -1.4em; vertical-align: middle;",
            ))
          } else if type(marker-map.at(marker-text)) == str {
            html.elem(
              "span",
              attrs: (
                style: "display: inline-flex; align-items: center; justify-content: center; width: 1em; height: 1em; vertical-align: middle; margin: 0 .2em .25em -1.4em;",
              ),
              marker-map.at(marker-text),
            )
          } else {
            html.elem(
              "span",
              attrs: (
                style: "display: inline-flex; align-items: center; justify-content: center; width: 1em; height: 1em; vertical-align: middle; margin: 0 .2em .25em -1.3em;",
              ),
              html.frame(marker-map.at(marker-text)),
            )
          })
            + children.slice(4).sum(),
        )
      } else {
        list(marker: marker-map.at(marker-text), children.slice(4).sum())
      }
    } else {
      it
    }
  }

  body
}
