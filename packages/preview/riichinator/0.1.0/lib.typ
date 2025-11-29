#let INLINE_TILE_HEIGHT = 2em
#let TILE_RATIO = 29 / 40 // empirically calculated

#let tile(
  tile_name,
  tile_height: INLINE_TILE_HEIGHT,
  rotation: 0deg,
) = {
  // spacing between tiles
  if tile_name == "-" {
    return box(height: tile_height, width: tile_height / 7)
  }
  let base_tile = none
  // flipped tile
  if tile_name == "0z" {
    base_tile = box(
      fill: rgb("C7AB90"),
      stroke: 0.5pt + rgb("#efdecd"),
      height: tile_height,
      width: TILE_RATIO * tile_height,
      radius: 0.25em,
      baseline: 2em / 2 - 0.5em, // box height / 2 - text height / 2,
      inset: (x: 2.5 / 100 * tile_height, y: 5 / 100 * tile_height),
    )
  } else {
    // TODO: input validation
    let file_name = ""
    if "m" in tile_name {
      file_name = "Man" + tile_name.first()
    } else if "p" in tile_name {
      file_name = "Pin" + tile_name.first()
    } else if "s" in tile_name {
      file_name = "Sou" + tile_name.first()
    } else if "z" in tile_name {
      if tile_name.first() == "1" { file_name = "Ton" } else if (
        tile_name.first() == "2"
      ) { file_name = "Nan" } else if tile_name.first() == "3" {
        file_name = "Shaa"
      } else if tile_name.first() == "4" { file_name = "Pei" } else if (
        tile_name.first() == "5"
      ) { file_name = "Haku" } else if tile_name.first() == "6" {
        file_name = "Hatsu"
      } else if tile_name.first() == "7" { file_name = "Chun" }
    }
    base_tile = box(
      fill: rgb("f5f0eb"),
      image("assets/" + file_name + ".svg", height: 9 / 10 * tile_height),
      stroke: 0.5pt + rgb("#efdecd"),
      radius: 0.25em,
      inset: (x: 2.5 / 100 * tile_height, y: 5 / 100 * tile_height),
    )
  }
  return box(
    rotate(rotation, base_tile, reflow: true),
    baseline: tile_height / 2 - 0.35em, // idk it just looks the most correct
    // TODO: adjust for parent element's font size
  )
}

#let parse_notation(notation, tile_height: INLINE_TILE_HEIGHT) = {
  // TODO: add extended kan (w/ red five functionality)
  let tiles = ()
  let current_numbers = ()
  let modifiers = ()
  for chr in notation {
    if chr >= "0" and chr <= "9" {
      current_numbers.push(chr)
      modifiers.push("")
    } else if chr == "'" {
      let previous_modifier = modifiers.pop()
      modifiers.push(previous_modifier + "r")
    } else if chr == "m" or chr == "p" or chr == "s" or chr == "z" {
      // this is where we take all of current_numbers and turn them into tiles
      for (i, num) in current_numbers.enumerate() {
        let modifier = modifiers.at(i)
        let rotation = 0deg
        if "r" in modifier {
          rotation = -90deg
        }
        tiles.push(tile(
          num + chr,
          tile_height: tile_height,
          rotation: rotation,
        ))
      }
      // reset the accumulators
      current_numbers = ()
      modifiers = ()
    } else if chr == "-" {
      // empty space
      tiles.push(tile(
        "-",
        tile_height: tile_height,
      ))
    }
  }
  return tiles
}

#let hand(hand, tile_height: INLINE_TILE_HEIGHT) = {
  return parse_notation(hand, tile_height: tile_height).join()
}

#let river(river, tile_height: INLINE_TILE_HEIGHT) = {
  let tiles = parse_notation(river, tile_height: tile_height)
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

#let riichi_stick(width, height) = {
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
#let honba_stick(width, height) = {
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
  hands: (
    "0000000000000z",
    "0000000000000z",
    "0000000000000z",
    "0000000000000z",
  ),
  hero_wind: "E",
  discards: ("", "", "", ""),
  current_round: none,
  dora_indicators: none,
  riichied_players: (false, false, false, false),
  scores: none,
  pot: none,
  use_cjk_wind: false,
  wind_font: "Arial",
) = layout(size => {
  let MAIN_SIZE = size.width
  let TILE_HEIGHT = MAIN_SIZE / 15
  let TILE_WIDTH = TILE_HEIGHT * TILE_RATIO
  let hands_to_display = hands
  if type(hands) == "string" {
    hands_to_display = (
      hands,
      "0000000000000z",
      "0000000000000z",
      "0000000000000z",
    )
  } else if type(hands) == "array" and hands.len() < 4 {
    while hands_to_display.len() < 4 {
      hands_to_display.push("0000000000000z") // hidden hand for the remaining unspecified hands, mainly for robustness
    }
  }

  let wind_list = ("E", "S", "W", "N")
  let hero_index = wind_list.position(wind => wind == hero_wind)

  if use_cjk_wind { wind_list = ("東","南","西","北") }
  // why are indexes so weird in typst
  let hero_wind = wind_list.at(hero_index)
  let right_wind = wind_list.at(calc.rem(hero_index + 1, 4))
  let across_wind = wind_list.at(calc.rem(hero_index + 2, 4))
  let left_wind = wind_list.at(calc.rem(hero_index + 3, 4))

  let scores_to_display = scores
  if scores == none { scores_to_display = ("", "", "", "") }

  let CENTRAL_AREA_SIZE = TILE_WIDTH * 6
  let central_area = grid(
    columns: (
      CENTRAL_AREA_SIZE / 8,
      CENTRAL_AREA_SIZE * 3 / 4,
      CENTRAL_AREA_SIZE / 8,
    ),
    rows: (
      CENTRAL_AREA_SIZE / 8,
      CENTRAL_AREA_SIZE * 3 / 4,
      CENTRAL_AREA_SIZE / 8,
    ),
    box(
      width: CENTRAL_AREA_SIZE / 8,
      height: CENTRAL_AREA_SIZE / 8,
      stroke: 1pt,
      inset: 0.25em,
      fill: if hero_index == 1 { rgb("#B83D3C") },
      rotate(90deg, text(left_wind, font: "Arial")),
    ),
    box(
      if riichied_players.at(2) {
        riichi_stick(
          CENTRAL_AREA_SIZE * 3 / 4 - 1em,
          CENTRAL_AREA_SIZE / 8 * 2 / 3,
        )
      },
    ),
    box(
      width: CENTRAL_AREA_SIZE / 8,
      height: CENTRAL_AREA_SIZE / 8,
      stroke: 1pt,
      inset: 0.25em,
      fill: if hero_index == 2 { rgb("#B83D3C") },
      rotate(180deg, text(across_wind, font: "Arial")),
    ),

    box(
      if riichied_players.at(3) {
        rotate(90deg, riichi_stick(
          CENTRAL_AREA_SIZE * 3 / 4 - 1em,
          CENTRAL_AREA_SIZE / 8 * 2 / 3,
        ))
      },
    ),
    grid(
      columns: (1em, CENTRAL_AREA_SIZE * 3 / 4 - 2em, 1em),
      rows: (1em, CENTRAL_AREA_SIZE * 3 / 4 - 2em, 1em),
      [], rotate(180deg, text(str(scores_to_display.at(2)))), [],
      rotate(90deg, text(str(scores_to_display.at(3)))),
      stack(
        spacing: 0.5em,
        current_round,
        if dora_indicators != none { hand(dora_indicators, tile_height: 1.5em) },
        if pot != none [
          #box(baseline: 0.3em, rotate(90deg, reflow: true, riichi_stick(1.5em, 0.5em))) #sym.times #pot.riichi#h(1em)#box(baseline: 0.3em, rotate(90deg, reflow: true, honba_stick(1.5em, 0.5em))) #sym.times #pot.honba
        ],
      ),
      rotate(-90deg, text(str(scores_to_display.at(1)))),
      [], text(str(scores_to_display.at(0))), [],
    ),
    box(
      if riichied_players.at(1) {
        rotate(90deg, riichi_stick(
          CENTRAL_AREA_SIZE * 3 / 4 - 1em,
          CENTRAL_AREA_SIZE / 8 * 2 / 3,
        ))
      },
    ),
    box(
      width: CENTRAL_AREA_SIZE / 8,
      height: CENTRAL_AREA_SIZE / 8,
      stroke: 1pt,
      inset: 0.25em,
      fill: if hero_index == 0 { rgb("#B83D3C") },
      text(hero_wind, font: "Arial"),
    ),
    box(
      if riichied_players.at(0) {
        riichi_stick(
          CENTRAL_AREA_SIZE * 3 / 4 - 1em,
          CENTRAL_AREA_SIZE / 8 * 2 / 3,
        )
      },
    ),
    box(
      width: CENTRAL_AREA_SIZE / 8,
      height: CENTRAL_AREA_SIZE / 8,
      stroke: 1pt,
      inset: 0.25em,
      fill: if hero_index == 3 { rgb("#B83D3C") },
      rotate(-90deg, text(right_wind, font: "Arial")),
    ),
  )

  let playing_field = grid(
    columns: (TILE_HEIGHT * 3, CENTRAL_AREA_SIZE, TILE_HEIGHT * 3),
    rows: (TILE_HEIGHT * 3, CENTRAL_AREA_SIZE, TILE_HEIGHT * 3),
    gutter: TILE_HEIGHT / 10,
    grid.cell(
      colspan: 2,
      align(
        bottom + right,
        rotate(
          180deg,
          reflow: true,
          align(
            left,
            river(discards.at(2), tile_height: TILE_HEIGHT),
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
              river(discards.at(1), tile_height: TILE_HEIGHT),
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
              river(discards.at(3), tile_height: TILE_HEIGHT),
            ),
          ),
        ),
      ),
    ),
    block(central_area, stroke: 0.1em),
    grid.cell(
      colspan: 2,
      align(
        top + left,
        river(discards.at(0), tile_height: TILE_HEIGHT),
      ),
    ),
  )

  return block(
    width: MAIN_SIZE,
    height: MAIN_SIZE,
    stroke: 1pt,
    grid(
      columns: (MAIN_SIZE / 8, MAIN_SIZE * 3 / 4, MAIN_SIZE / 8),
      rows: (MAIN_SIZE / 8, MAIN_SIZE * 3 / 4, MAIN_SIZE / 8),
      [],
      align(
        horizon + center,
        rotate(
          180deg,
          hand(hands_to_display.at(2), tile_height: TILE_HEIGHT),
          reflow: true,
        ),
      ),
      [],

      align(
        horizon + center,
        rotate(
          90deg,
          hand(hands_to_display.at(3), tile_height: TILE_HEIGHT),
          reflow: true,
        ),
      ),
      align(
        center + horizon,
        playing_field,
      ),
      align(
        horizon + center,
        rotate(
          -90deg,
          hand(hands_to_display.at(1), tile_height: TILE_HEIGHT),
          reflow: true,
        ),
      ),

      [],
      align(
        horizon + center,
        hand(hands_to_display.at(0), tile_height: TILE_HEIGHT),
      ),
    ),
  )
})
