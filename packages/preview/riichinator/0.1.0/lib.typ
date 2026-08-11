#let INLINE-TILE-HEIGHT = 2em
#let TILE-RATIO = 29 / 40 // empirically calculated
#let red = rgb("#B83D3C")
#let TILE-BG = rgb("f5f0eb")
#let TILE-COVER = rgb("C7AB90")
#let TILE-OUTLINE = rgb("#efdecd")

#let tile(
  tile-name,
  tile-height: INLINE-TILE-HEIGHT,
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
      fill: TILE-COVER,
      stroke: 0.5pt + TILE-OUTLINE,
      height: tile-height,
      width: TILE-RATIO * tile-height,
      radius: 0.25em,
      // baseline: tile-height / 2 - 0.5em, // box height / 2 - text height / 2,
      inset: (x: 2.5 / 100 * tile-height, y: 5 / 100 * tile-height),
    )
  } else {
    // TODO: input validation
    base-tile = box(
      fill: TILE-BG,
      image("assets/" + tile-name + ".svg", height: 9 / 10 * tile-height),
      stroke: 0.5pt + TILE-OUTLINE,
      radius: 0.25em,
      inset: (x: 2.5 / 100 * tile-height, y: 5 / 100 * tile-height),
    )
  }
  return box(
    rotate(rotation, base-tile, reflow: true),
    // baseline: tile-height / 2 - 0.35em, // idk it just looks the most correct
    // TODO: adjust for parent element's font size
  )
}

#let parse-notation(notation, tile-height: INLINE-TILE-HEIGHT) = {
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
        // added/extended kan handling
        if "k" in modifier {
          tiles.push(
            box(
              height: 2 * tile-height * TILE-RATIO,
              rotate(
                -90deg,
                reflow: true,
                (
                  tile(num.at(0) + chr, tile-height: tile-height),
                  tile(num.at(1) + chr, tile-height: tile-height),
                ).join(),
              ),
            ),
          )
          continue
        }

        let rotation = 0deg
        if "r" in modifier {
          rotation = -90deg
        }
        tiles.push(tile(
          num + chr,
          tile-height: tile-height,
          rotation: rotation,
        ))
      }
      // reset the accumulators
      current-numbers = ()
      modifiers = ()
    } else if chr == "-" {
      // empty space
      tiles.push(tile(
        "-",
        tile-height: tile-height,
      ))
    }
  }
  return tiles
}

#let hand(hand, tile-height: INLINE-TILE-HEIGHT) = {
  return parse-notation(hand, tile-height: tile-height).join()
}

#let river(river, tile-height: INLINE-TILE-HEIGHT) = {
  let tiles = parse-notation(river, tile-height: tile-height)


  if tiles.len() > 12 {
    tiles.insert(12, "\n")
  }
  if tiles.len() > 6 {
    tiles.insert(6, "\n")
  }
  let rows = tiles.split("\n")
  return stack(
    dir: ttb,
    ..rows.map(row => row.join("")),
  )
}

#let riichi-stick(width, height) = {
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
#let honba-stick(width, height) = {
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

#let board(
  hands: (13, 13, 13, 13),
  hero-wind: "E",
  discards: ("", "", "", ""),
  current-round: none,
  dora-indicators: none,
  riichied-players: (false, false, false, false),
  scores: none,
  pot: none,
  use-cjk-wind: false,
  wind-font: "Arial",
) = layout(size => {
  let MAIN-SIZE = size.width
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
