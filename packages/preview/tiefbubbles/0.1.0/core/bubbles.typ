#import "bubble.typ": bubble
#import "@preview/linguify:0.5.0": linguify

#let valid-mode-names = ("alternating", "named")

#let get-alignment(
  mode,
  i,
  c,
  primary-participant,
  swap-sides,
) = {
  let al1 = if swap-sides { right } else { left }
  let al2 = if swap-sides { left } else { right }
  if mode == "alternating" {
    return if calc.rem(i, 2) == 0 { al1 } else { al2 }
  } else if mode == "named" {
    let al-choice = if type(c) == dictionary {
      c.at("name", default: primary-participant) == primary-participant
    } else {
      c.at(0) == primary-participant
    }

    return if al-choice {
      al1
    } else {
      al2
    }
  }
}

#let get-box-style(
  box-style,
  computed-alignment,
) = {
  if box-style.at("left", default: none) != none and box-style.at("right", default: none) != none {
    if computed-alignment == left {
      box-style.at("left")
    } else {
      box-style.at("right")
    }
  } else {
    box-style
  }
}

/// Creates a series of chat bubbles.
///
/// Two modes are available: alternating and named. In alternating mode,
/// each bubble switches side automatically, while in named mode, it
/// switches side depending on the passed name.
///
/// When using named mode, the `primary-participant` decides on which
/// side the bubble will be rendered.
///
/// = Examples
///
/// #example(`
///   #box(width: 200pt)[
///     #bubbles(
///       [asdf],
///       [asdf asdf asdf asdf asdf],
///     )
///   ]
/// `)
///
/// #example(`
///   #box(width: 200pt)[
///     #bubbles(
///       mode: "named",
///       primary-participant: "Anton",
///       show-name: true,
///       ("Anton", [asdf]),
///       ("Berta", [asdf asdf asdf asdf asdf]),
///     )
///   ]
/// `)
///
/// - mode (str): Mode of the bubble positioning
/// - primary-participant (str): Name of the participant to be on the primary side
/// - show-name (bool): Whether to show a name in named mode
/// - name-style (dict): The style to apply to the text of the name
/// - box-settings (dict): The style to apply to the bubbles
/// - swap-sides (bool): Whether to display alternate side order
/// - contents (arguments): The contents of the rendered bubblesS
///
/// -> content
#let bubbles(
  mode: "alternating",
  primary-participant: "A",
  show-name: false,
  name-style: (:),
  box-style: (:),
  swap-sides: false,
  ..contents,
) = {
  assert(mode in valid-mode-names, message: "mode must be in (" + valid-mode-names.join(", ") + ").")
  if mode == "named" {
    assert(type(primary-participant) == str, message: "primary-participant must be of type str.")
    assert(
      contents.pos().all(c => type(c) == dictionary or type(c) == array),
      message: "All contents must be dictionaries or arrays when using named mode.",
    )
  }

  stack(
    spacing: 1.2em,
    ..contents
      .pos()
      .enumerate()
      .map(ic => {
        let i = ic.at(0)
        let c = ic.at(1)
        let computed-alignment = get-alignment(mode, i, c, primary-participant, swap-sides)
        let computed-box-style = get-box-style(box-style, computed-alignment)

        align(
          computed-alignment,
          if mode == "alternating" {
            bubble(box-style: computed-box-style)[#c]
          } else if mode == "named" {
            if type(c) == array {
              bubble(
                box-style: computed-box-style,
                name: if show-name { c.at(0) } else { none },
                name-style: name-style,
              )[#c.at(1)]
            }
            if type(c) == dictionary {
              bubble(
                box-style: computed-box-style,
                name: if show-name { c.at("name") } else { none },
                name-style: name-style,
              )[#c.at("content")]
            }
          },
        )
      }),
  )
}
