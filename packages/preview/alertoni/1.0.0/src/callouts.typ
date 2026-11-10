#import "predefined.typ": default-callout-types, default-icon-set
#import "@preview/tableau-icons:0.344.0": ti-icon

#let icon-state = state("alertoni-icon-state", default-icon-set)
#let callout-types = state("callout-types", default-callout-types)



#let radius = 3pt
#let inset = (top: 8pt, rest: 6pt)

#let callout-styles = (
  "minimal": (title, icon, content, paint, height, width) => align(
    center,
    block(
      above: 1.5em,
      below: 1.5em,
      width: width,
      height: height,
      stroke: paint + 0.5pt,
      inset: inset,
      radius: radius,
      {
        set align(left)
        // title block

        if icon != none or title != none {
          place(top + left, dy: -inset.top - 0.5em, dx: -1pt, box(
            fill: white,
            inset: if icon == none {
              (x: 2pt)
            } else if title == none {
              (x: 0pt)
            } else {
              (left: 1pt, right: 2pt)
            },
            outset: (y: 1pt),
            grid(
              align: center + horizon,
              ..if icon != none and title != none { (column-gutter: 0.2em) },
              columns: if icon == none or title == none {
                auto
              } else {
                (1em, auto)
              }, rows: 1em,
              ..(
                if icon != none {
                  (text(paint, icon),)
                }
                  + if title != none {
                    (text(weight: "bold", paint, title),)
                  }
              )
            ),
          ))
        }
        content
      },
    ),
  ),
  // inline version
  "compact": (title, icon, content, paint, _, _) => {
    let inset = 0.3em

    (
      box(
        fill: paint.lighten(85%),
        outset: inset,
        radius: inset,
        baseline: inset / 2,
        grid(
          rows: 1em,
          columns: (1em,) * int(icon != none) + (auto,) * int(title != none), align: horizon, gutter: inset,
          ..if icon != none {
            (text(paint, icon),)
          },
          ..if title != none {
            (text(strong(title), rgb("#343a40")),)
          }
        ),
      )
        + h(2 * inset)
        + content
    )
  },
  // the callout styling from the extended Markdown format "Quarto" (https://quarto.org/docs/authoring/callouts.html)
  "quarto": (title, icon, content, paint, height, width) => {
    let column-count = if title == none or icon == none {
      1
    } else if title != none and icon != none {
      2
    }

    align(
      center,
      block(
        width: width,
        height: height,
        stroke: (left: paint + 3pt, rest: paint + 0.5pt),
        radius: 3pt,
        clip: true,
        inset: (left: 1.5pt, right: 0.25pt),
        grid(
          rows: (1.5em, height),
          fill: (x, y) => if y == 0 { paint.lighten(85%) } else { none },
          ..if column-count == 2 {(
            columns: (1.5em, 1fr),
            align: (center + horizon, left + horizon)
          )} else {(
            columns: (1fr),
            align: (left + horizon),
            inset: (left: 0.25em)
          )},
          ..if icon != none {
            (
              text(paint, icon),
            )
          },
          ..if title != none {
            (
              text(strong(title), rgb("#343a40")),
            )
          },
          grid.cell(colspan: column-count, align: left + top, block(
            width: 100%,
            content,
            inset: 0.5em,
          )),
        ),
      ),
    )
  },
)





#let callout-invalid-type = (
  color: gray,
  placeholder: (de: "Kein Zugehöriger Titel", en: "No Associated Title"),
)


///
/// #example(`#at.callout(title: [Title], [Content])`, scale-preview: 100%)
///
/// #example(`#at.callout([Content with automatic Title])`, scale-preview: 100%)
///
///
/// -> content
#let callout(
  /// #let types = ("info", "warning", "important", "tip", "caution", "correct", "incorrect", "example")
  ///
  /// Type of the callout. Predefined styles are #types.map(x => raw(`"`.text + x + `"`.text, lang: "typc")).join([, ]).
  ///
  /// If user defined types have been set via #link(label("-new-type()"),`#new-type`), can also contain the respective type name.
  ///
  /// #example(```
  /// #at.callout(type: "info", lorem(5))
  ///
  /// #at.callout(type: "caution", lorem(5))
  ///
  /// #at.callout(type: "tip", lorem(5))
  /// ```, scale-preview: 100%)
  ///
  /// -> string
  type: "info",

  /// Rendering style of the callout. Predefined styles are #raw(lang:"typc", `"minimal"`.text), #raw(lang:"typc", `"compact"`.text) and #raw(lang:"typc", `"minimal"`.text).
  ///
  /// #example(```
  /// #at.callout(style: "minimal", lorem(5))
  /// #at.callout(style: "quarto", lorem(5))
  /// #at.callout(style: "compact", lorem(5))
  /// ```, scale-preview: 100%)
  ///
  ///
  /// Passing a function in the shape of
  ///
  /// #{
  /// show raw: set text(1.15em)
  /// code-block(```typc
  /// (title, icon, content, paint, height, width) => {...}
  /// ```)
  /// }
  ///
  /// allows for a user defined style.
  ///
  /// #example(```
  /// #at.callout(style:
  ///   (title,_,body,paint,_,_) => {
  ///     [*#text(paint, title)* #body]
  ///   },
  ///   lorem(5)
  /// )
  /// ```, scale-preview: 100%)
  ///
  ///
  /// -> string | function
  style: "minimal",

  /// Title of the callout.
  ///
  /// When set to #raw(`auto`.text,lang:"typc") the title is automatically chosen from the (user- or pre-) assigned placeholder title.
  ///
  /// When set to #raw(`none`.text,lang:"typc"), hides title. If set to anything else, callout title is overwritten. *This applies but is not limited to the predefined styles.*
  ///
  /// #example(```
  /// #at.callout(icon: auto, lorem(5))
  ///
  /// #at.callout(icon: [i], lorem(5))
  ///
  ///
  /// #at.callout(icon: none, lorem(5))
  /// ```, scale-preview: 100%)
  ///
  ///
  /// -> auto | none |
  title: auto,

  /// Width of the callout, but depends on the style. Style #raw(`"compact"`.text,lang: "typc") for
  /// example ignores this parameter.
  ///
  /// -> auto | relative | fraction
  width: 100%,

  /// Height of the callout, but depends on the style. Style #raw(`"compact"`.text,lang: "typc") for
  /// example ignores this parameter.
  ///
  /// -> auto | relative | fraction
  height: auto,

  /// The icon of the callout. Per default the icon is automatically selected from
  /// the respective type configuration. Passing anything that can render as content,
  /// overwrites the "default" icon.
  ///
  /// When set to #raw(`none`.text,lang:"typc"), does not render any icons. *This applies but is not limited to the predefined styles.*
  ///
  /// #example(```
  /// #at.callout(icon: auto, lorem(5))
  ///
  /// #at.callout(icon: [i], lorem(5))
  ///
  ///
  /// #at.callout(icon: none, lorem(5))
  /// ```, scale-preview: 100%)
  ///
  /// -> content | auto
  icon: auto,

  /// The color of the callout. Per default the color is automatically selected from
  /// the respective type configuration. Passing a color, overwrites the "default"
  /// color.
  ///
  /// #example(```
  /// #at.callout(color: auto, lorem(5))
  ///
  ///
  /// #at.callout(color: purple, lorem(5))
  /// ```, scale-preview: 100%)
  ///
  /// -> color | auto
  color: auto,

  /// The body of the calloutm, *IF* only one position item is passed. If two
  /// position items are passed, the first item is the callout, the second one
  /// is the callout body.
  ///
  /// #example(```
  /// #at.callout[No shorthand version]
  /// #at.callout[Shorthand][Version!]
  /// ```, scale-preview: 100%)
  ///
  /// This improves writing callouts slightly, as in doesn't break writing flow as much.
  ..content,
) = context {
  assert(
    (std.type(style) == function) or (std.type(style) == str and style in (callout-styles.keys())),
    message: "`style` is neither a function or of a valid string: \"minimal\", \"compact\", \"quarto\".",
  )
  assert(
    content.pos().len() <= 2,
    message: "Only one (for content only) or two (for [0] title and [1] content) positonal arguments are accepted!",
  )

  let types = callout-types.get()
  let icon-state = icon-state.get()

  assert(
    type in types.keys() and type in icon-state.keys(),
    message: "The callout type '"
      + type
      + "' doesn't exist in either type collection or icon set. Have forgotten to add it via 'alertoni.new-type' or 'alertoni.set-icons'?",
  )
  let config = callout-types.get().at(type)

  let color = if color == auto { config.color } else { color }
  let icon = if icon == auto { icon-state.at(type) } else { icon }

  let title = if content.pos().len() == 2 {
    content.pos().first()
  } else if title == auto {
    if std.type(config.placeholder) == dictionary {
      assert(
        text.lang in config.placeholder or "fallback" in config.placeholder,
        message: "No callout title for language '"
          + text.lang
          + "' found. Did you forget to add it or a 'fallback' entry?",
      )

      let key = if text.lang not in config.placeholder { "fallback" } else { text.lang }

      config.placeholder.at(key) // the user has to deal with the correct fallback on their own.
    } else {
      config.placeholder
    }
  } else {
    title
  }

  let content = if content.pos().len() == 2 {
    content.pos().last()
  } else {
    content.pos().first()
  }

  if std.type(style) == function {
    // calls custom function
    return style(title, icon, content, color, height, width)
  } else {
    // Callout Library predefined styles
    return (callout-styles.at(style))(title, icon, content, color, height, width)
  }
}

/// Configures the icons by passing a dictionary, which assigns a content value to the respective callout type.
///
/// #example(```
/// #let new-set = (
///   "info": [*i*],
///   "warning": burger-image(width: 100%)
/// )
/// #at.set-icons(new-set)
/// #at.callout(type: "info", [Hello])
/// #at.callout(type: "warning", [World])
///
/// #at.set-icons(auto)
/// #at.callout(type: "info", [Hello])
/// #at.callout(type: "warning", [World])
/// ```, scale-preview: 100%)
///
#let set-icons(
  /// Passing a dictionary in the format of `(<type> : <icon>, ...)`, allows you to add or overwrite the icon assignments for specific callout types.
  ///
  ///
  /// Passing #raw(`auto`.text,lang:"typc"), resets all the default types.\
  /// Passing #raw(`none`.text,lang:"typc"), resets all the default types *and* clears entries of user defined types.
  ///
  /// -> dictionary | auto | none
  new-set,
) = {
  icon-state.update(x => {
    if new-set == auto {
      // reset default, keep user defined
      return x + default-icon-set
    } else if new-set == none {
      // reset and clear
      return default-icon-set
    }

    return x + new-set // add/overwrite new items
  })
}


/// #example(```
/// #at.new-type(
///   name: "test",
///   color: red,
///   icon: text(0.8em)[#emoji.croissant],
///   placeholder: (
///     fallback: "Title?",
///     en: "A Title",
///     de: "Ein Titel"
///   )
/// )
///
/// #set text(lang: "en")
/// #at.callout(type: "test", [In English])
///
/// #set text(lang: "de")
/// #at.callout(type: "test", [In Deutsch])
///
/// #set text(lang: "fr")
/// #at.callout(type: "test", [En français?])
/// ```, scale-preview: 100%)
///
/// -> none
#let new-type(
  /// Name of the new callout type which is also to be used in the #link(label("-callout()"),`#callout`) function.
  /// -> str
  name: none,

  /// The color of the callout. Depends on the style on how it is used.
  ///
  /// -> color
  color: none,

  /// The icon to be associated with the callout. Everything not #raw(lang: "typc", `none`.text)
  /// will be added to the icon-set via #link(label("-set-icons()"),`#set-icons()`). Passing
  /// #raw(lang: "typc", `none`.text) skips this step.
  ///
  /// -> content | str | none
  icon: none,

  /// The fallback/automatic title used when no title is given when calling #link(label("-callout()"),`#callout`).
  /// Passing a dictionary with the key-value shape of `(<lang> : <title>)` allows for language dependent titles (for the languages in the dictionary).
  ///
  /// #at.callout(type: "important", width: 80%)[If a dictionary is used, #link(label("-callout()"), [\#callout]) will throw an error, if the respective title cannot be found.
  ///
  ///   This can be circumvented via an #raw("\"fallback\"", lang: "typc") entry!
  /// ]
  ///
  ///
  /// -> dictionary | content | str
  placeholder: none,
) = {
  assert(type(name) == str, message: "template name must be a string")
  assert(type(color) == std.color, message: "'color' must be of type 'color'.")

  assert(type(icon) in (content, str, symbol) or icon == none, message: "'icon' must be a type of content.")
  assert(
    type(placeholder) in (dictionary, content, str),
    message: "config.placeholder must be either a string/content or a language dictionary '(en: \"..\", de: \"..\")'.",
  )

  if icon != none {
    set-icons(((name, icon),).to-dict())
  }

  let config = (
    color: color,
    placeholder: placeholder,
  )

  callout-types.update(old => {
    old.insert(name, config)
    old
  })
}

