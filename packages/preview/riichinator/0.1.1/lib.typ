#let INLINE-TILE-HEIGHT = 2em
#let TILE-RATIO = 29 / 40 // empirically calculated
#let red = rgb("#B83D3C")
#let TILE-BG = rgb("f5f0eb")
#let TILE-COVER = rgb("C7AB90")
#let TILE-OUTLINE = rgb("#efdecd")
#let TILE-SHADE = black.transparentize(40%)
#let TILE-STROKE = 0.5pt + TILE-OUTLINE
#let TILE-HIGHLIGHT-STROKE = 0.5pt + red

/// Renders a single tile as an inline element
///
/// ```example
/// The dragon tiles are #tile("5z"), #tile("6z"), and #tile("7z")
/// ```
///
/// -> content
#let tile(
  /// name of the tile in mpsz notation
  /// -> string
  tile-name,
  /// height of the tile, INLINE_TILE_HEIGHT = `2em` by default
  /// -> length
  tile-height: INLINE-TILE-HEIGHT,
  /// background color of the tile, TILE-BG = `rgb("f5f0eb")` by default
  /// -> color
  tile-fill: TILE-BG,
  /// background color of the face-down tile, TILE-COVER = `rgb("C7AB90")` by default
  /// -> color
  tile-cover-fill: TILE-COVER,
  /// color of the shade overlay to be drawn over the tile if any, `none` by default
  /// -> color | none
  tile-shade-fill: none,
  /// stroke of the tile border, TILE-STROKE = `0.5pt + rgb("#efdecd")` by default
  /// -> stroke
  tile-stroke: TILE-STROKE,
  /// angle to rotate the tile by
  /// -> angle
  rotation: 0deg,
) = {
  // spacing between tiles
  if tile-name == "-" {
    let tile-width = tile-height * TILE-RATIO
    return box(height: tile-height, width: tile-width / 4)
  }
  let base-tile = none
  // flipped tile
  if tile-name == "0z" {
    base-tile = box(
      fill: tile-cover-fill,
      stroke: tile-stroke,
      height: tile-height,
      width: TILE-RATIO * tile-height,
      radius: 0.25em,
      // baseline: tile-height / 2 - 0.5em, // box height / 2 - text height / 2,
      inset: (x: 2.5 / 100 * tile-height, y: 5 / 100 * tile-height),
    )
  } else {
    // TODO: input validation
    base-tile = box(
      fill: tile-fill,
      image("assets/" + tile-name + ".svg", height: 9 / 10 * tile-height),
      stroke: tile-stroke,
      radius: 0.25em,
      inset: (x: 2.5 / 100 * tile-height, y: 5 / 100 * tile-height),
    )
  }

  // adding shade overlay on top if specified
  if tile-shade-fill != none {
    base-tile = layout(bounds => {
      let size = measure(base-tile, ..bounds)
      let tile-shade-stroke = if type(tile-stroke) == stroke {
        tile-stroke.thickness + tile-shade-fill.opacify(70%)
      } else {
        tile-shade-fill
      }

      base-tile
      place(top + left, block(
        ..size,
        fill: tile-shade-fill,
        stroke: tile-shade-stroke,
        radius: 0.25em,
      ))
    })
  }

  return box(
    rotate(rotation, base-tile, reflow: true),
    // baseline: tile-height / 2 - 0.35em, // idk it just looks the most correct
    // TODO: adjust for parent element's font size
  )
}

#let parse-notation(
  notation,
  tile-height: INLINE-TILE-HEIGHT,
  tile-fill: TILE-BG,
  tile-cover-fill: TILE-COVER,
  tile-shade-fill: TILE-SHADE,
  tile-stroke: TILE-STROKE,
  tile-highlight-stroke: TILE-HIGHLIGHT-STROKE,
  spacing: none,
) = {
  // e.g. 13 = 13 blank tiles
  if type(notation) == int {
    notation = "0" * notation + "z"
  }
  let tiles = ()
  let current-numbers = ()
  let modifiers = ()
  for chr in notation {
    if chr >= "0" and chr <= "9" {
      current-numbers.push(chr)
      modifiers.push("")
    } else if chr == "'" {
      let previous-modifier = modifiers.pop()
      modifiers.push(previous-modifier + "r")
    } else if chr == "?" {
      let previous-modifier = modifiers.pop()
      modifiers.push(previous-modifier + "s") // like "shaded"
    } else if chr == "!" {
      let previous-modifier = modifiers.pop()
      modifiers.push(previous-modifier + "h") // like "highlighted"
    } else if chr == "\"" {
      // added/extended kan handling
      // combines the two rotated tiles into 1 object so "888\"8m" -> current-numbers = ("8", "88", "8"), modifiers = ("", "k", "")
      assert(
        current-numbers.len() >= 2,
        message: "error when processing added/extended kan. The proper usage is 11\"11s, 888\"8m or 3333\"z",
      )

      let previous-number = current-numbers.pop()
      let previous-previous-number = current-numbers.pop()
      current-numbers.push(previous-previous-number + previous-number)

      let previous-modifier = modifiers.pop()
      let previous-previous-modifier = modifiers.pop()
      modifiers.push(previous-modifier + "k")
    } else if chr == "m" or chr == "p" or chr == "s" or chr == "z" {
      // this is where we take all of current-numbers and turn them into tiles
      for (i, num) in current-numbers.enumerate() {
        let modifier = modifiers.at(i)

        let curr-shade = none
        if "s" in modifier {
          curr-shade = tile-shade-fill
        }

        // added/extended kan handling
        if "k" in modifier {
          tiles.push(
            box(
              height: 2 * tile-height * TILE-RATIO + tile-stroke.thickness,
              rotate(
                -90deg,
                reflow: true,
                (
                  tile(
                    num.at(0) + chr,
                    tile-height: tile-height,
                    tile-fill: tile-fill,
                    tile-cover-fill: tile-cover-fill,
                    tile-shade-fill: curr-shade,
                    tile-stroke: tile-stroke,
                  ),
                  tile(
                    num.at(1) + chr,
                    tile-height: tile-height,
                    tile-fill: tile-fill,
                    tile-cover-fill: tile-cover-fill,
                    tile-shade-fill: curr-shade,
                    tile-stroke: tile-stroke,
                  ),
                ).join(h(spacing)),
              ),
            ),
          )
          continue
        }

        let rotation = 0deg
        if "r" in modifier {
          rotation = -90deg
        }

        let curr-stroke = tile-stroke
        if "h" in modifier {
          curr-stroke = tile-highlight-stroke
        }

        tiles.push(tile(
          num + chr,
          tile-height: tile-height,
          tile-fill: tile-fill,
          tile-cover-fill: tile-cover-fill,
          tile-shade-fill: curr-shade,
          tile-stroke: curr-stroke,
          rotation: rotation,
        ))
      }
      // reset the accumulators
      current-numbers = ()
      modifiers = ()
    } else if chr == "-" {
      // empty space
      tiles.push(
        tile(
          "-",
          tile-height: tile-height,
        ),
      )
    }
  }
  return tiles
}

/// Renders a mahjong hand, or rather any series of tiles as an inline element
///
/// ```example
/// #hand("5567m34p6788s-0p-77'7z")\
/// #hand("19m19p19s1234567z")\
/// #hand(13)
/// ```
/// -> content
#let hand(
  /// the input to be parsed and processed as the hand
  /// -> str | int
  hand,
  /// height of the tile, INLINE_TILE_HEIGHT = `2em` by default
  /// -> length
  tile-height: INLINE-TILE-HEIGHT,
  /// background color of the tile, TILE-BG = `rgb("f5f0eb")` by default
  /// -> color
  tile-fill: TILE-BG,
  /// background color of the face-down tile, TILE-COVER = `rgb("C7AB90")` by default
  /// -> color
  tile-cover-fill: TILE-COVER,
  /// color of the shade overlay to be drawn over the tile if any, TILE-SHADE = `rgb("00000099")` by default
  /// -> color | none
  tile-shade-fill: TILE-SHADE,
  /// stroke of the tile border, TILE-STROKE = `0.5pt + rgb("#efdecd")` by default
  /// -> stroke
  tile-stroke: TILE-STROKE,
  /// stroke of the highlighted tile border, TILE-HIGHLIGHT-STROKE = `0.5pt + red` by default
  /// -> stroke
  tile-highlight-stroke: TILE-HIGHLIGHT-STROKE,
  /// length of spacing between the tile. If not specified, half of `tile-stroke.thickness` will be used
  /// -> length | none
  spacing: none,
) = {
  if spacing == none {
    spacing = tile-stroke.thickness
  }
  return parse-notation(
    hand,
    tile-height: tile-height,
    tile-fill: tile-fill,
    tile-cover-fill: tile-cover-fill,
    tile-shade-fill: tile-shade-fill,
    tile-stroke: tile-stroke,
    tile-highlight-stroke: tile-highlight-stroke,
    spacing: spacing,
  ).join(h(spacing))
}
/// Renders a discard pool
///
/// ```example
/// #river("9s11p73z81m9p7's")
/// #river("0z5m00'z")
/// #river(4)
/// ```
/// -> content
#let river(
  /// the input to parsed and processed as the discard pool
  /// -> str | int
  river,
  /// height of the tile, INLINE_TILE_HEIGHT = `2em` by default
  /// -> length
  tile-height: INLINE-TILE-HEIGHT,
  /// background color of the tile, TILE-BG = `rgb("f5f0eb")` by default
  /// -> color
  tile-fill: TILE-BG,
  /// background color of the face-down tile, TILE-COVER = `rgb("C7AB90")` by default
  /// -> color
  tile-cover-fill: TILE-COVER,
  /// color of the shade overlay to be drawn over the tile if any, TILE-SHADE = `rgb("00000099")` by default
  /// -> color | none
  tile-shade-fill: TILE-SHADE,
  /// stroke of the tile border, TILE-STROKE = `0.5pt + rgb("#efdecd")` by default
  /// -> stroke
  tile-stroke: TILE-STROKE,
  /// stroke of the highlighted tile border, TILE-HIGHLIGHT-STROKE = `0.5pt + red` by default
  /// -> stroke
  tile-highlight-stroke: TILE-HIGHLIGHT-STROKE,
  /// length of spacing between the tile. If not specified, half of `tile-stroke.thickness` will be used
  /// -> length | none
  spacing: none,
) = {
  if spacing == none {
    spacing = tile-stroke.thickness
  }
  let tiles = parse-notation(
    river,
    tile-height: tile-height,
    tile-fill: tile-fill,
    tile-cover-fill: tile-cover-fill,
    tile-shade-fill: tile-shade-fill,
    tile-stroke: tile-stroke,
    tile-highlight-stroke: tile-highlight-stroke,
  )

  if tiles.len() > 12 {
    tiles.insert(12, "\n")
  }
  if tiles.len() > 6 {
    tiles.insert(6, "\n")
  }
  let rows = tiles.split("\n")
  return stack(
    dir: ttb,
    ..rows.map(row => row.join(h(spacing))),
  )
}

/// Renders a riichi stick
///
/// ```example
/// #riichi-stick(10em, 1em)
/// ```
/// -> content
#let riichi-stick(
  /// width of the riichi stick
  /// -> length
  width,
  /// height of the riichi stick
  /// -> length
  height,
) = {
  rect(
    height: height,
    width: width,
    radius: height / 2,
    inset: (x: 0pt, y: 0pt),
    align(
      horizon + center,
      circle(fill: red, radius: height / 3.5),
    ),
  )
}
/// Renders a honba stick
///
/// ```example
/// #honba-stick(10em, 1em)
/// ```
/// -> content
#let honba-stick(
  /// width of the honba stick
  /// -> length
  width,
  /// height of the honba stick
  /// -> length
  height,
) = {
  rect(
    height: height,
    width: width,
    radius: height / 2,
    inset: (x: 0pt, y: 0pt),
    align(
      center + horizon,
      grid(
        columns: (height / 3, height / 3, height / 3),
        rows: (height / 3, height / 3),
        ..range(6).map(i => align(center + horizon, circle(
          fill: black,
          radius: height / 10,
        )))
      ),
    ),
  )
}

/// Renders a board state.\
/// *All 4-player arguments are in a counterclockwise direction starting from yourself (or "hero" point of view)*
///
/// ```example
/// #board(
///   hands: ("1112345678999s-6z", "1112223334446z", "222333444666s6z", "19m19p19s1234567z"),
///   hero-wind: "E",
///   discards: ("1m3'p", 2, 2, 2),
///   dora-indicators: "1m0000z",
///   scores: (24000, 25000, 25000, 25000),
///   current-round: "East 1",
///   pot: (riichi: 0, honba: 0),
///   riichied-players: (true, false, false, false)
/// )
/// ```
///
/// -> content
#let board(
  /// The hands to show on the board. If only a string or integer is provided it is treated as your hand. Otherwise it expects an array of length 4
  /// ```example
  /// #board(
  ///   hands: "34567m34567p666s"
  /// )
  /// #board(
  ///   hands: ("34567m34567p666s", "123p12788s33z-132'p", 13, 13)
  /// )
  /// ```
  /// -> str | int | array
  hands: (13, 13, 13, 13),
  /// The seat wind of the hero
  /// ```example
  /// #board(
  ///   hero-wind: "N"
  /// )
  /// ```
  /// -> "E" | "S" | "W" | "N"
  hero-wind: "E",
  /// The discard pools of the players
  /// ```example
  /// #board(
  ///   discards: ("1s1366z8m14p5s1m", "4z9m1s9m8s612p39s8p9s", "1z9214p7z9m46z8m7's", "4z12s7z9p1z4's2p")
  /// )
  /// ```
  /// -> array
  discards: ("", "", "", ""),
  /// The current round of the game, e.g. East 1, South 4. Can be any text in general, e.g. "East Round"
  /// ```example
  /// #board(
  ///   current-round: "East 1"
  /// )
  /// ```
  /// -> str
  current-round: none,
  /// Display the dead wall dora indicators. Functionally just a wrapper for `hand()`\
  /// ```example
  /// #board(
  ///   dora-indicators: "7z0000z"
  /// )
  /// ```
  /// -> str
  dora-indicators: none,
  /// Display riichi sticks (if any)
  /// ```example
  /// #board(
  ///   riichied-players: (true, false, false, true)
  /// )
  /// ```
  /// -> array
  riichied-players: (false, false, false, false),
  /// Display scores of each player
  /// ```example
  /// #board(
  ///   scores: (100000, 1000, 0, -1000)
  /// )
  /// ```
  /// -> array
  scores: none,
  /// Display the "pot", i.e. extra points you will gain on a win. Comprises leftover riichi sticks and honba sticks
  /// ```example
  /// #board(
  ///   pot: (riichi: 6, honba: 7)
  /// )
  /// ```
  /// -> obj
  pot: none,
  /// Whether or not to use 東南西北 instead of ESNW for the seat wind indicators
  /// ```example
  /// #board(
  ///   use-cjk-wind: true
  /// )
  /// ```
  /// -> boolean
  use-cjk-wind: false,
  /// The font to use for the seat wind indicators
  /// -> font
  wind-font: "Arial",
) = layout(size => {
  let MAIN-SIZE = size.width
  // prevent infinities
  if MAIN-SIZE == float.inf * 1pt {
    MAIN-SIZE = 50em
  }
  let tile-height = MAIN-SIZE / 15
  let TILE-WIDTH = tile-height * TILE-RATIO
  let hands-to-display = hands
  if type(hands) == "string" {
    hands-to-display = (
      hands,
      "0000000000000z",
      "0000000000000z",
      "0000000000000z",
    )
  } else if type(hands) == "array" and hands.len() < 4 {
    while hands-to-display.len() < 4 {
      hands-to-display.push("0000000000000z") // hidden hand for the remaining unspecified hands, mainly for robustness
    }
  }

  let wind-list = ("E", "S", "W", "N")
  let hero-index = wind-list.position(wind => wind == hero-wind)

  if use-cjk-wind { wind-list = ("東", "南", "西", "北") }
  let hero-wind = wind-list.at(hero-index)
  let right-wind = wind-list.at(calc.rem(hero-index + 1, 4))
  let across-wind = wind-list.at(calc.rem(hero-index + 2, 4))
  let left-wind = wind-list.at(calc.rem(hero-index + 3, 4))

  let scores-to-display = scores
  if scores == none { scores-to-display = ("", "", "", "") }

  let CENTRAL-AREA-SIZE = TILE-WIDTH * 6
  let central-area = grid(
    columns: (
      CENTRAL-AREA-SIZE / 8,
      CENTRAL-AREA-SIZE * 3 / 4,
      CENTRAL-AREA-SIZE / 8,
    ),
    rows: (
      CENTRAL-AREA-SIZE / 8,
      CENTRAL-AREA-SIZE * 3 / 4,
      CENTRAL-AREA-SIZE / 8,
    ),
    box(
      width: CENTRAL-AREA-SIZE / 8,
      height: CENTRAL-AREA-SIZE / 8,
      stroke: 1pt,
      inset: 0.25em,
      fill: if hero-index == 1 { red },
      rotate(90deg, text(left-wind, font: wind-font)),
    ),
    box(
      if riichied-players.at(2) {
        riichi-stick(
          CENTRAL-AREA-SIZE * 3 / 4 - 1em,
          CENTRAL-AREA-SIZE / 8 * 2 / 3,
        )
      },
    ),
    box(
      width: CENTRAL-AREA-SIZE / 8,
      height: CENTRAL-AREA-SIZE / 8,
      stroke: 1pt,
      inset: 0.25em,
      fill: if hero-index == 2 { red },
      rotate(180deg, text(across-wind, font: wind-font)),
    ),

    box(
      if riichied-players.at(3) {
        rotate(90deg, riichi-stick(
          CENTRAL-AREA-SIZE * 3 / 4 - 1em,
          CENTRAL-AREA-SIZE / 8 * 2 / 3,
        ))
      },
    ),
    grid(
      columns: (1em, CENTRAL-AREA-SIZE * 3 / 4 - 2em, 1em),
      rows: (1em, CENTRAL-AREA-SIZE * 3 / 4 - 2em, 1em),
      [], rotate(180deg, text(str(scores-to-display.at(2)))), [],
      rotate(90deg, text(str(scores-to-display.at(3)))),
      stack(
        spacing: 0.5em,
        current-round,
        if dora-indicators != none {
          hand(dora-indicators, tile-height: 1.5em)
        },
        if pot != none [
          #box(baseline: 0.3em, rotate(90deg, reflow: true, riichi-stick(
            1.5em,
            0.5em,
          ))) #sym.times #pot.riichi#h(1em)#box(baseline: 0.3em, rotate(
            90deg,
            reflow: true,
            honba-stick(1.5em, 0.5em),
          )) #sym.times #pot.honba
        ],
      ),
      rotate(-90deg, text(str(scores-to-display.at(1)))),

      [], text(str(scores-to-display.at(0))), [],
    ),
    box(
      if riichied-players.at(1) {
        rotate(90deg, riichi-stick(
          CENTRAL-AREA-SIZE * 3 / 4 - 1em,
          CENTRAL-AREA-SIZE / 8 * 2 / 3,
        ))
      },
    ),

    box(
      width: CENTRAL-AREA-SIZE / 8,
      height: CENTRAL-AREA-SIZE / 8,
      stroke: 1pt,
      inset: 0.25em,
      fill: if hero-index == 0 { red },
      text(hero-wind, font: wind-font),
    ),
    box(
      if riichied-players.at(0) {
        riichi-stick(
          CENTRAL-AREA-SIZE * 3 / 4 - 1em,
          CENTRAL-AREA-SIZE / 8 * 2 / 3,
        )
      },
    ),
    box(
      width: CENTRAL-AREA-SIZE / 8,
      height: CENTRAL-AREA-SIZE / 8,
      stroke: 1pt,
      inset: 0.25em,
      fill: if hero-index == 3 { red },
      rotate(-90deg, text(right-wind, font: wind-font)),
    ),
  )

  let playing-field = grid(
    columns: (tile-height * 3, CENTRAL-AREA-SIZE, tile-height * 3),
    rows: (tile-height * 3, CENTRAL-AREA-SIZE, tile-height * 3),
    gutter: tile-height / 10,
    grid.cell(
      colspan: 2,
      align(
        bottom + right,
        rotate(
          180deg,
          reflow: true,
          align(
            left,
            river(discards.at(2), tile-height: tile-height),
          ),
        ),
      ),
    ),
    grid.cell(
      rowspan: 2,
      align(
        bottom + left,
        rotate(
          -90deg,
          reflow: true,
          block(
            align(
              left,
              river(discards.at(1), tile-height: tile-height),
            ),
          ),
        ),
      ),
    ),
    grid.cell(
      rowspan: 2,
      align(
        top + right,
        rotate(
          90deg,
          reflow: true,
          block(
            align(
              left,
              river(discards.at(3), tile-height: tile-height),
            ),
          ),
        ),
      ),
    ),
    block(central-area, stroke: 0.1em),
    grid.cell(
      colspan: 2,
      align(
        top + left,
        river(discards.at(0), tile-height: tile-height),
      ),
    ),
  )

  return block(
    width: MAIN-SIZE,
    height: MAIN-SIZE,
    stroke: 1pt,
    grid(
      columns: (MAIN-SIZE / 8, MAIN-SIZE * 3 / 4, MAIN-SIZE / 8),
      rows: (MAIN-SIZE / 8, MAIN-SIZE * 3 / 4, MAIN-SIZE / 8),
      [],
      align(
        horizon + center,
        rotate(
          180deg,
          hand(hands-to-display.at(2), tile-height: tile-height),
          reflow: true,
        ),
      ),
      [],

      align(
        horizon + center,
        rotate(
          90deg,
          hand(hands-to-display.at(3), tile-height: tile-height),
          reflow: true,
        ),
      ),
      align(
        center + horizon,
        playing-field,
      ),
      align(
        horizon + center,
        rotate(
          -90deg,
          hand(hands-to-display.at(1), tile-height: tile-height),
          reflow: true,
        ),
      ),

      [],
      align(
        horizon + center,
        hand(hands-to-display.at(0), tile-height: tile-height),
      ),
    ),
  )
})
