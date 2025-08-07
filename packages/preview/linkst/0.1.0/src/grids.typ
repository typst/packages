#import "@preview/cetz:0.3.3"

//
// GENERAL
// 

#let match(
  value,
  ..items,
) = {
  return items.pos().find(e => e.at(0) == value or e.at(0) == true).at(1)
}




//
// TANGLE DIAGRAM
// 

#let tangle(
  ..tilemap,
  style: (
    thick: false,
  ),
) = {

  //
  // USER INPUT
  // 

  let get-tile(input) = {
    return match(
      input,
      ("space", 0),
      ("coev", 1),
      ("ev", 2),
      ("id", 3),
      ("switch", 4),
      ("right", 5),
      ("left", 6),
      ("dcoev", 7),
      ("dev", 8),
      ("lswitch", 9),
      ("rswitch", 10),
      ("rtwist", 11),
      ("ltwist", 12),
      ("scoupon", 13),
      ("mcoupon", 14),
      ("lcoupon", 15),
      ("<id", 16),
      (">id", 17),
      (">ltwist", 18),
      (">rtwist", 19),
      ("<coev", 20),
      (">coev", 21),
      ("<ev", 22),
      (">ev", 23),
      (">lswitch", 24),
      (">rswitch", 25),
      ("xscoupon", 26),
      ("<lswitch", 27),
      ("<rswitch", 28),
      ("<<lswitch", 29),
      (true, input),
    )
  }

  let map-tiles(tilemap) = {
    let new-tilemap = ()
    for row in tilemap {
      let new-row = ()
      for tile in row {
        new-row.push(get-tile(tile))
      }
      new-tilemap.push(new-row)
    }
    return new-tilemap
  }

  //
  // GRID
  // 

  let tile-width(tile) = {
    return match(
      tile,
      (0, 1),
      (1, 2),
      (2, 2),
      (3, 1),
      (4, 2),
      (5, 2),
      (6, 2),
      (7, 4),
      (8, 4),
      (9, 2),
      (10, 2),
      (11, 1),
      (12, 1),
      (13, 2),
      (14, 3),
      (15, 3),
      (16, 1),
      (17, 1),
      (18, 1),
      (19, 1),
      (20, 2),
      (21, 2),
      (22, 2),
      (23, 2),
      (24, 2),
      (25, 2),
      (26, 1),
      (27, 2),
      (28, 2),
      (29, 2),
    )
  }

  //
  // DRAW
  // 

  let draw-tile(tile, style, row, index) = {
    import cetz.draw: *

    let cut-bezier(pos, width, ..bezier-args) = {
      bezier(..bezier-args, mark: (end: "bar", scale: 0, pos: pos + width/2))
      bezier(..bezier-args, mark: (start: "bar", scale: 0, pos: 100% - pos + width/2))
    }

    if(row.len() - 1 > index and type(row.at(index + 1)) == array) {
      let label-arr = row.at(index + 1)
      let n = 0
      while n < label-arr.len() {
        let x = label-arr.at(n)
        let y = label-arr.at(n + 1)
        let text = label-arr.at(n + 2)
        content((x, y), text)
        
        n = n + 3
      }
    }

    if(style.thick) {
      match(
        tile,
        (0, {}),
        (1, {bezier((0.1, 0), (0.9, 0), (0.1, -0.95), (0.9, -0.95)); bezier((-0.1, 0), (1.1, 0), (-0.15, -1.25), (1.15, -1.25))}),
        (2, {bezier((0.1, -1), (0.9, -1), (0.1, -0.05), (0.9, -0.05)); bezier((-0.1, -1), (1.1, -1), (-0.15, 0.25), (1.15, 0.25))}),
        (3, {line((-0.1, 0), (-0.1, -1)); line((0.1, 0), (0.1, -1))}),
        (4, {bezier((0.1, 0), (1.1, -1), (0.1, -0.45), (1.1, -0.45)); bezier((-0.1, 0), (0.9, -1), (-0.1, -0.55), (0.9, -0.55)); bezier((0.9, 0), (-0.1, -1), (0.9, -0.45), (-0.1, -0.45)); bezier((1.1, 0), (0.1, -1), (1.1, -0.55), (0.1, -0.55))}),
        (5, {bezier((0.1, 0), (1.1, -1), (0.1, -0.45), (1.1, -0.45)); bezier((-0.1, 0), (0.9, -1), (-0.1, -0.55), (0.9, -0.55))}),
        (6, {bezier((0.9, 0), (-0.1, -1), (0.9, -0.45), (-0.1, -0.45)); bezier((1.1, 0), (0.1, -1), (1.1, -0.55), (0.1, -0.55))}),
        (7, {bezier((0.1, 0), (2.9, 0), (0.1, -0.95), (2.9, -0.95)); bezier((-0.1, 0), (3.1, 0), (-0.1, -1.2), (3.1, -1.2)); bezier((1.1, 0), (1.9, 0), (1.1, -0.5), (1.9, -0.5)); bezier((0.9, 0), (2.1, 0), (0.9, -0.8), (2.1, -0.8))}),
        (8, {bezier((0.1, -1), (2.9, -1), (0.1, -0.05), (2.9, -0.05)); bezier((-0.1, -1), (3.1, -1), (-0.1, 0.2), (3.1, 0.2)); bezier((1.1, -1), (1.9, -1), (1.1, -0.5), (1.9, -0.5)); bezier((0.9, -1), (2.1, -1), (0.9, -0.2), (2.1, -0.2))}),
        (9, {bezier((0.1, 0), (1.1, -1), (0.1, -0.45), (1.1, -0.45)); bezier((-0.1, 0), (0.9, -1), (-0.1, -0.55), (0.9, -0.55)); cut-bezier(53%, 11%, (0.9, 0), (-0.1, -1), (0.9, -0.45), (-0.1, -0.45)); cut-bezier(47%, 11%, (1.1, 0), (0.1, -1), (1.1, -0.55), (0.1, -0.55))}),
        (10, {cut-bezier(53%, 11%, (0.1, 0), (1.1, -1), (0.1, -0.45), (1.1, -0.45)); cut-bezier(47%, 11%, (-0.1, 0), (0.9, -1), (-0.1, -0.55), (0.9, -0.55)); bezier((0.9, 0), (-0.1, -1), (0.9, -0.45), (-0.1, -0.45)); bezier((1.1, 0), (0.1, -1), (1.1, -0.55), (0.1, -0.55))}),
        (11, {line((-0.07, -0.4), (0.035, -0.35)); line((-0.1, -0.5), (0.08, -0.45)); line((-0.07, -0.6), (0.08, -0.55)); bezier((0.1, 0), (-0.1, -.5), (0.1, -0.15), (-0.1, -0.35)); cut-bezier(60%, 15%, (-0.1, 0), (0.1, -.5), (-0.1, -0.15), (0.1, -0.35)); bezier((0.1, -0.5), (-0.1, -1.), (0.1, -0.65), (-0.1, -0.85)); cut-bezier(40%, 15%, (-0.1, -0.5), (0.1, -1.), (-0.1, -0.65), (0.1, -0.85))}),
        (12, {line((0.07, -0.4), (-0.035, -0.35)); line((0.1, -0.5), (-0.08, -0.45)); line((0.07, -0.6), (-0.08, -0.55)); cut-bezier(60%, 15%, (0.1, 0), (-0.1, -.5), (0.1, -0.15), (-0.1, -0.35)); bezier((-0.1, 0), (0.1, -.5), (-0.1, -0.15), (0.1, -0.35)); cut-bezier(40%, 10%, (0.1, -0.5), (-0.1, -1.), (0.1, -0.65), (-0.1, -0.85)); bezier((-0.1, -0.5), (0.1, -1.), (-0.1, -0.65), (0.1, -0.85))}),
        (13, {rect((0., 0.), (rel: (2, -1))); if(tile == 13) {content((1, -0.5), row.at(index + 1))}}),
        (14, {rect((-.5, 0.), (rel: (2, -1))); if(tile == 14) {content((0.5, -0.5), row.at(index + 1))}}),
        (15, {rect((-.5, 0.), (rel: (3, -1))); if(tile == 15) {content((1, -0.5), row.at(index + 1))}; content((1, 0.5), [...]);  content((1, -1.5), [...]);}),
        (16, {line((-0.1, 0), (-0.1, -1)); line((0.1, 0), (0.1, -1)); line((0, -0.7), (0, -0.3), mark: (end: "straight", scale: 0.3, width: 0.4))}),
        (17, {line((-0.1, 0), (-0.1, -1)); line((0.1, 0), (0.1, -1)); line((0, -0.3), (0, -0.7), mark: (end: "straight", scale: 0.3, width: 0.4))}),
        (18, {line((-0.07, -0.4), (0.035, -0.35)); line((-0.1, -0.5), (0.08, -0.45)); line((-0.07, -0.6), (0.08, -0.55)); bezier((0.1, 0), (-0.1, -.5), (0.1, -0.15), (-0.1, -0.35)); cut-bezier(60%, 15%, (-0.1, 0), (0.1, -.5), (-0.1, -0.15), (0.1, -0.35)); bezier((0.1, -0.5), (-0.1, -1.), (0.1, -0.65), (-0.1, -0.85)); cut-bezier(40%, 15%, (-0.1, -0.5), (0.1, -1.), (-0.1, -0.65), (0.1, -0.85)); line((0, -0.15), (0, -0.), mark: (end: "straight", scale: 0.2, width: 0.4))}),
        (19, {line((0.07, -0.4), (-0.035, -0.35)); line((0.1, -0.5), (-0.08, -0.45)); line((0.07, -0.6), (-0.08, -0.55)); cut-bezier(60%, 15%, (0.1, 0), (-0.1, -.5), (0.1, -0.15), (-0.1, -0.35)); bezier((-0.1, 0), (0.1, -.5), (-0.1, -0.15), (0.1, -0.35)); cut-bezier(40%, 10%, (0.1, -0.5), (-0.1, -1.), (0.1, -0.65), (-0.1, -0.85)); bezier((-0.1, -0.5), (0.1, -1.), (-0.1, -0.65), (0.1, -0.85)); line((0, -0.15), (0, -0.), mark: (end: "straight", scale: 0.2, width: 0.4))}),
        (20, {bezier((0.1, 0), (0.9, 0), (0.1, -0.95), (0.9, -0.95)); bezier((-0.1, 0), (1.1, 0), (-0.15, -1.25), (1.15, -1.25)); bezier((0.88, -0.6), (0.12, -0.6), (0.5, -1.05), mark: (end: "straight", scale: 0.3, width: 0.4))}),
        (21, {bezier((0.1, 0), (0.9, 0), (0.1, -0.95), (0.9, -0.95)); bezier((-0.1, 0), (1.1, 0), (-0.15, -1.25), (1.15, -1.25)); bezier((0.88, -0.6), (0.12, -0.6), (0.5, -1.05), mark: (start: "straight", scale: 0.3, width: 0.4))}),
        (22, {bezier((0.1, -1), (0.9, -1), (0.1, -0.05), (0.9, -0.05)); bezier((-0.1, -1), (1.1, -1), (-0.15, 0.25), (1.15, 0.25)); bezier((0.88, -0.4), (0.12, -0.4), (0.5, 0.05), mark: (end: "straight", scale: 0.3, width: 0.4))}),
        (23, {bezier((0.1, -1), (0.9, -1), (0.1, -0.05), (0.9, -0.05)); bezier((-0.1, -1), (1.1, -1), (-0.15, 0.25), (1.15, 0.25)); bezier((0.88, -0.4), (0.12, -0.4), (0.5, 0.05), mark: (start: "straight", scale: 0.3, width: 0.4))}),
        (24, {bezier((0.1, 0), (1.1, -1), (0.1, -0.45), (1.1, -0.45)); bezier((-0.1, 0), (0.9, -1), (-0.1, -0.55), (0.9, -0.55)); cut-bezier(53%, 11%, (0.9, 0), (-0.1, -1), (0.9, -0.45), (-0.1, -0.45)); cut-bezier(47%, 11%, (1.1, 0), (0.1, -1), (1.1, -0.55), (0.1, -0.55)); bezier((0.3, -0.4), (0.7, -0.6), (0.5, -0.5), mark: (end: "straight", scale: 0.2, width: 0.4)); bezier((0, -0.9), (0.3, -0.6), (0.1, -0.73), mark: (end: "straight", scale: 0.2, width: 0.4))}),
        (25, {cut-bezier(53%, 11%, (0.1, 0), (1.1, -1), (0.1, -0.45), (1.1, -0.45)); cut-bezier(47%, 11%, (-0.1, 0), (0.9, -1), (-0.1, -0.55), (0.9, -0.55)); bezier((0.9, 0), (-0.1, -1), (0.9, -0.45), (-0.1, -0.45)); bezier((1.1, 0), (0.1, -1), (1.1, -0.55), (0.1, -0.55)); bezier((0.3, -0.6), (0.7, -0.4), (0.5, -0.5), mark: (end: "straight", scale: 0.2, width: 0.4)); bezier((0, -0.1), (0.3, -0.4), (0.1, -0.27), mark: (end: "straight", scale: 0.2, width: 0.4))}),
        (26, {rect((-0.5, 0.), (rel: (1, -1))); if(tile == 26) {content((0., -0.5), row.at(index + 1))}}),
        (true, {circle((0.5, -0.5), radius: 0.5)}),
      )
    } else {
      match(
        tile,
        (0, {}),
        (1, {bezier((0, 0), (1, 0), (0, -1.2), (1, -1.2))}),
        (2, {bezier((0, -1), (1, -1), (0, 0.2), (1, 0.2))}),
        (3, {line((0, 0), (0, -1))}),
        (4, {bezier((0, 0), (1, -1), (0, -0.5), (1, -0.5)); bezier((1, 0), (0, -1), (1, -0.5), (0, -0.5))}),
        (5, {bezier((0, 0), (1, -1), (0, -0.5), (1, -0.5))}),
        (6, {bezier((1, 0), (0, -1), (1, -0.5), (0, -0.5))}),
        (7, {bezier((0, 0), (3, 0), (0, -1.2), (3, -1.2)); bezier((1, 0), (2, 0), (1, -0.8), (2, -0.8))}),
        (8, {bezier((0, -1), (3, -1), (0, 0.2), (3, 0.2)); bezier((1, -1), (2, -1), (1, -0.22), (2, -0.2))}),
        (9, {bezier((0, 0), (1, -1), (0, -0.5), (1, -0.5)); cut-bezier(50%, 10%, (1, 0), (0, -1), (1, -0.5), (0, -0.5))}),
        (10, {cut-bezier(50%, 10%, (0, 0), (1, -1), (0, -0.5), (1, -0.5)); bezier((1, 0), (0, -1), (1, -0.5), (0, -0.5))}),
        (11, {line((0, 0), (0, -1))}),
        (12, {line((0, 0), (0, -1))}),
        (13, {rect((0., 0.), (rel: (2, -1))); if(tile == 13) {content((1, -0.5), row.at(index + 1))}}),
        (14, {rect((-.5, 0.), (rel: (2, -1))); if(tile == 14) {content((0.5, -0.5), row.at(index + 1))}}),
        (15, {rect((-.5, 0.), (rel: (3, -1))); if(tile == 15) {content((1, -0.5), row.at(index + 1))}; content((1, 0.5), [...]);  content((1, -1.5), [...]);}),
        (16, {line((0, 0), (0, -1)); mark((0, -0.4), (0, 0), symbol: "straight", width: 0.3, scale: 0.5, fill: black)}),
        (17, {line((0, 0), (0, -1)); mark((0, -0.6), (0, -1), symbol: "straight", width: 0.3, scale: 0.5, fill: black)}),
        (18, {line((0, 0), (0, -1)); mark((0, -1), (0, -0.4), symbol: "straight", width: 0.3, scale: 0.5, fill: black)}),
        (19, {line((0, 0), (0, -1)); mark((0, 0), (0, -0.6), symbol: "straight", width: 0.3, scale: 0.5, fill: black)}),
        (20, {bezier((0, 0), (1, 0), (0, -1.2), (1, -1.2)); mark((0.4, -0.9), (0, -0.9), symbol: "straight", width: 0.3, scale: 0.5, fill: black)}),
        (21, {bezier((0, 0), (1, 0), (0, -1.2), (1, -1.2)); mark((0.6, -0.9), (1, -0.9), symbol: "straight", width: 0.3, scale: 0.5, fill: black)}),
        (22, {bezier((0, -1), (1, -1), (0, 0.2), (1, 0.2)); mark((0.4, -0.1), (0, -0.1), symbol: "straight", width: 0.3, scale: 0.5, fill: black)}),
        (23, {bezier((0, -1), (1, -1), (0, 0.2), (1, 0.2)); mark((0.6, -0.1), (1, -0.1), symbol: "straight", width: 0.3, scale: 0.5, fill: black)}),
        (24, {bezier((0, 0), (1, -1), (0, -0.5), (1, -0.5)); cut-bezier(50%, 10%, (1, 0), (0, -1), (1, -0.5), (0, -0.5)); mark((0, -0.25), (0.4, -0.45), symbol: "straight", width: 0.3, scale: 0.5, fill: black); mark((0, -0.75), (0.4, -0.55), symbol: "straight", width: 0.3, scale: 0.5, fill: black)}),
        (25, {cut-bezier(50%, 10%, (0, 0), (1, -1), (0, -0.5), (1, -0.5)); bezier((1, 0), (0, -1), (1, -0.5), (0, -0.5)); mark((0, -0.25), (0.4, -0.45), symbol: "straight", width: 0.3, scale: 0.5, fill: black); mark((0, -0.75), (0.4, -0.55), symbol: "straight", width: 0.3, scale: 0.5, fill: black)}),
        (26, {rect((-0.5, 0.), (rel: (1, -1))); if(tile == 26) {content((0., -0.5), row.at(index + 1))}}),
        (27, {bezier((0, 0), (1, -1), (0, -0.5), (1, -0.5)); cut-bezier(50%, 10%, (1, 0), (0, -1), (1, -0.5), (0, -0.5)); mark((0, -0.25), (0.4, -0.45), symbol: "straight", width: 0.3, scale: 0.5, fill: black); mark((1.3, 0), (0.6, -0.45), symbol: "straight", width: 0.3, scale: 0.5, fill: black)}),
        (28, {cut-bezier(50%, 10%, (0, 0), (1, -1), (0, -0.5), (1, -0.5)); bezier((1, 0), (0, -1), (1, -0.5), (0, -0.5)); mark((0, -0.25), (0.4, -0.45), symbol: "straight", width: 0.3, scale: 0.5, fill: black); mark((1.3, 0), (0.6, -0.45), symbol: "straight", width: 0.3, scale: 0.5, fill: black)}),
        (29, {bezier((1, 0), (0, -1), (1, -0.5), (0, -0.5)); cut-bezier(50%, 10%, (0, 0), (1, -1), (0, -0.5), (1, -0.5)); mark((1, -0.25), (0.6, -0.45), symbol: "straight", width: 0.3, scale: 0.5, fill: black); mark((1, -0.75), (0.6, -0.55), symbol: "straight", width: 0.3, scale: 0.5, fill: black)}),
        (true, {circle((0.5, -0.5), radius: 0.5)}),
      )
    }
  }

  let draw-row(row, style) = {
    import cetz.draw: *

    group({
      for (index, tile) in row.enumerate() {
        if(type(tile) == int) {
          draw-tile(tile, style, row, index)
          translate(x: tile-width(tile), y: 0)
        }
      }
    })
  }

  let draw-grid(tilemap, style) = {
    import cetz.draw: *

    for row in tilemap {
      draw-row(row, style)
      translate(x: 0, y: -1)
    }
  }

  tilemap = map-tiles(tilemap.pos())

  cetz.canvas({
    draw-grid(tilemap, style)
  })
}




//
// COBORDISM
// 
// 
#let cobordism(
  ..tilemap,
  style: (
    
  ),
) = {

  //
  // USER INPUT
  // 

  let get-tile(input) = {
    return match(
      input,
      ("space", 0),
      ("e", 1),
      ("n", 2),
      ("id", 3),
      ("d", 4),
      ("m", 5),
      ("switch", 6),
      ("up", 7),
      ("down", 8),
      ("hswitch", 9),
      (true, input),
    )
  }

  let map-tiles(tilemap) = {
    let new-tilemap = ()
    for row in tilemap {
      let new-row = ()
      for tile in row {
        new-row.push(get-tile(tile))
      }
      new-tilemap.push(new-row)
    }
    return new-tilemap
  }

  //
  // GRID
  // 

  let tile-width(tile) = {
    return match(
      tile,
      (0, 1),
      (1, 1),
      (2, 1),
      (3, 1),
      (4, 1),
      (5, 1),
      (6, 1),
      (7, 1),
      (8, 1),
      (9, 1),
    )
  }

  //
  // DRAW
  // 

  let draw-tile(tile, style) = {
    import cetz.draw: *

    let hole(pos) = {
      circle(pos, radius: (0.1, 0.2))
    }

    return match(
      tile,
      (0, {}),
      (1, {hole((0, -0.5)); bezier((0, -0.3), (0, -0.7), (0.6, -0.3), (0.6, -0.7))}),
      (2, {hole((1, -0.5)); bezier((1, -0.3), (1, -0.7), (0.4, -0.3), (0.4, -0.7))}),
      (3, {hole((0, -0.5)); hole((1, -0.5)); line((0, -0.3), (1, -0.3)); line((0, -0.7), (1, -0.7))}),
      (4, {hole((0, -0.5)); hole((1, 0)); hole((1, -1)); bezier((0, -0.3), (1, 0.2), (0.3, -0.3), (0.7, 0.2)); bezier((0, -0.7), (1, -1.2), (0.3, -0.7), (0.7, -1.2)); bezier((1, -0.2), (1, -0.8), (0.6, -0.3), (0.6, -0.7))}),
      (5, {hole((1, -0.5)); hole((0, 0)); hole((0, -1)); bezier((1, -0.3), (0, 0.2), (0.7, -0.3), (0.3, 0.2)); bezier((1, -0.7), (0, -1.2), (0.7, -0.7), (0.3, -1.2)); bezier((0, -0.2), (0, -0.8), (0.4, -0.3), (0.4, -0.7))}),
      (6, {hole((0, -0.5)); hole((0, -1)); hole((1, -0.5)); hole((1, -1)); bezier((0, -0.3), (1, -0.8), (0.55, -0.3), (0.55, -0.8)); bezier((0, -0.7), (1, -1.2), (0.45, -0.7), (0.45, -1.2)); bezier((0, -0.8), (1, -0.3), (0.45, -0.8), (0.45, -0.3)); bezier((0, -1.2), (1, -0.7), (0.55, -1.2), (0.55, -0.7))}),
      (7, {hole((0, -0.5)); hole((1, 0)); bezier((0, -0.3), (1, 0.2), (0.45, -0.3), (0.45, 0.2)); bezier((0, -0.7), (1, -0.2), (0.55, -0.7), (0.55, -0.2))}),
      (8, {hole((0, -0.5)); hole((1, -1)); bezier((0, -0.3), (1, -0.8), (0.55, -0.3), (0.55, -0.8)); bezier((0, -0.7), (1, -1.2), (0.45, -0.7), (0.45, -1.2))}),
      (9, {hole((0, 0)); hole((0, -1)); hole((1, 0)); hole((1, -1)); bezier((0, 0.2), (1, -0.8), (0.6, 0.2), (0.6, -0.8)); bezier((0, -0.2), (1, -1.2), (0.4, -0.2), (0.4, -1.2)); bezier((0, -0.8), (1, 0.2), (0.4, -0.8), (0.4, 0.2)); bezier((0, -1.2), (1, -0.2), (0.6, -1.2), (0.6, -0.2))}),
      (true, {circle((0.5, -0.5), radius: 0.5)}),
    )
  }

  let draw-row(row, style) = {
    import cetz.draw: *

    group({
      for tile in row {
        draw-tile(tile, style)
        translate(x: tile-width(tile), y: 0)
      }
    })
  }

  let draw-grid(tilemap, style) = {
    import cetz.draw: *

    for row in tilemap {
      draw-row(row, style)
      translate(x: 0, y: -0.5)
    }
  }

  tilemap = map-tiles(tilemap.pos())

  cetz.canvas({
    draw-grid(tilemap, style)
  })
}