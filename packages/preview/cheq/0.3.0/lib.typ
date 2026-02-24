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
/// - `light` : ['bool'] - The style of the checked symbol (light or dark)
#let checked-sym(fill: white, stroke: rgb("#616161"), radius: .1em, light: false) = move(dy: -.08em, box(
  stroke: .05em + stroke,
  fill: if light {fill} else {stroke},
  height: .8em,
  width: .8em,
  radius: radius,
  {
    box(move(dy: .48em, dx: 0.1em, rotate(45deg, reflow: false, line(length: 0.3em, stroke: if light {stroke} else {fill} + .1em))))
    box(move(dy: .38em, dx: -0.05em, rotate(-45deg, reflow: false, line(length: 0.48em, stroke: if light {stroke} else {fill} + .1em))))
  },
))

/// `incomplete-sym` function.
///
/// - `fill`: [`string`] - The fill color for the incomplete symbol.
/// - `stroke`: [`string`] - The stroke color for the incomplete symbol.
/// - `radius`: [`string`] - The radius of the incomplete symbol.
/// - `light` : ['bool'] - The style of the incomplete symbol (light or dark)
#let incomplete-sym(fill: white, stroke: rgb("#616161"), radius: .1em, light: false) = move(dy: -.08em, box(
  stroke: .05em + stroke,
  fill: fill,
  height: .8em,
  width: .8em,
  radius: radius,
  if light{
    box(move(dy: .4em, dx: 0.0em, rotate(90deg, reflow: false, line(length: 0.8em, stroke: if light {stroke} else {fill} + .07em))))
  } else {
    box(fill: stroke, height: .8em, width: .4em, radius: (top-left: radius, bottom-left: radius))
  },
))

/// `canceled-sym` function.
///
/// - `fill`: [`string`] - The fill color for the canceled symbol.
/// - `stroke`: [`string`] - The stroke color for the canceled symbol.
/// - `radius`: [`string`] - The radius of the canceled symbol.
/// - `light` : ['bool'] - The style of the canceled symbol (light or dark)
#let canceled-sym(fill: white, stroke: rgb("#616161"), radius: .1em, light: false) = move(dy: -.08em, box(
  stroke: .05em + stroke,
  fill: if light {fill} else {stroke},
  height: .8em,
  width: .8em,
  radius: radius,
  {
    align(center + horizon, box(height: .125em, width: 0.55em, fill: if light {stroke} else {fill}))
  },
))


/// `character-sym` function.
///
/// - `symbol`: [`string`] - The character that will be put inside the checkbox
/// - `fill`: [`string`] - The fill color for the character symbol.
/// - `stroke`: [`string`] - The stroke color for the character symbol.
/// - `radius`: [`string`] - The radius of the character symbol.
/// - `light` : ['bool'] - The style of the character symbol (light or dark)
#let character-sym(symbol: " ", fill: white, stroke: rgb("#616161"), radius: .1em, light: false) = move(dy: -.08em, box(
  stroke: .05em + stroke,
  fill: if light {fill} else {stroke},
  height: .8em,
  width: .8em,
  radius: radius,
  {
    align(center + horizon, text(size: 0.8em, fill: if light {stroke} else {fill} , weight: "bold", symbol))
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
/// - `light`: [`bool'] - The style of the markers, light or dark.
/// - `marker-map`: [`map`] - The map of the checklist marker. It should be a map of character to symbol function, such as `(" ": sym.ballot, "x": sym.ballot.cross, "-": sym.bar.h, "/": sym.slash.double)`.
/// - `highlight-map`: [`map`] - The map of the highlight functions. It should be a map of characther to functions, see examples.
/// - `highlight`: [`bool`] - The flag to enable or disable the application of highlight functions to the list item.
/// - `extras`: [`bool`] - The flag that includes or excludes the extra map of symbols
/// - `body`: [`content`] - The main body from `#show: checklist` rule.
///
/// The default map is:
///
/// ```typ
/// #let default-map = (
///   "x": checked-sym(fill: fill, stroke: stroke, radius: radius),
///   " ": unchecked-sym(fill: fill, stroke: stroke, radius: radius, light: false),
///   "/": incomplete-sym(fill: fill, stroke: stroke, radius: radius, light: false),
///   "-": canceled-sym(fill: fill, stroke: stroke, radius: radius, light: false),
/// )
/// ```
/// 
/// The extra map is:
/// 
/// ```typ
/// 
/// #let extra-map = (
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
  light: false, 
  marker-map: (:),
  highlight-map: (:),
  highlight: true,
  extras: false, 
  body,
) = {
  let default-map = (
    " ": unchecked-sym(fill: fill, stroke: stroke, radius: radius),
    "x": checked-sym(fill: fill, stroke: stroke, radius: radius, light: light),
    "/": incomplete-sym(fill: fill, stroke: stroke, radius: radius, light: light),
    "-": canceled-sym(fill: fill, stroke: stroke, radius: radius, light: light),
  )

  let extra-map = (
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

  let default-map = default-map + if extras {extra-map} else {(:)}

  let marker-map = default-map + marker-map

  let default-highlight = (
    "-": it => {strike(text(fill: rgb("#888888"), it))},
  )
  let highlight-map = default-highlight + highlight-map

  show list: it => {
    let is-checklist = false
    let items-list = ()
    let symbols-list = ()
    let default-marker = if type(it.marker) == array {
      it.marker.at(0)
    } else {
      it.marker
    }

    for list-children in it.children {
      if not (type(list-children.body) == content and list-children.body.func() == [].func()) {
        symbols-list.push(default-marker)
        items-list.push(list-children.body)
      } else {
        let children = list-children.body.children

        // A checklist item has at least 5 children: `[`, marker, `]`, space, content
        if children.len() < 5 or not (children.at(0) == [#"["] and children.at(2) == [#"]"] and children.at(3) == [ ]) {
          symbols-list.push(default-marker)
          items-list.push(list-children.body)
        } else {
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

          if marker-text != none {
            is-checklist = true
            if marker-text in marker-map and marker-map.at(marker-text) != none {
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
                symbols-list.push(marker-map.at(marker-text))
              }
            } else {
              symbols-list.push(character-sym(symbol: marker-text, fill: fill, stroke: stroke, radius: radius, light: light))
            }
            if not ("html" in dictionary(std) and target() == "html") {
              if highlight {
                let highligh-func = highlight-map.at(marker-text, default: it => {it})
                items-list.push(highligh-func(children.slice(4).sum()))
              } else { 
                items-list.push(children.slice(4).sum())
              }
            }
          } else {
            symbols-list.push(default-marker)
            items-list.push(list-children.body)
          }
        }
      }
    }

    if is-checklist {
      if not ("html" in dictionary(std) and target() == "html") {
        enum(
          numbering: (.., n) => { symbols-list.at(n - 1) },
          tight: it.tight,
          indent: it.indent,
          body-indent: it.body-indent,
          spacing: it.spacing,
          ..items-list,
        )
      }
    } else {
      it
    }
  }

  body
}
