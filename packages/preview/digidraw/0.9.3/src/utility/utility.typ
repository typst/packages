#import "@preview/cetz:0.4.2"
#import cetz.draw: *



#let SYMBOLS = (
  all: "lLhHzpPnNud0123456789x.|",
  mergeable: "pPnNzdux",
  breaker: "lLhHzpPnNud0123456789x",
  bus: "23456789=",
  extender: ".|",
)

/// Converts the given wave structure to a more library focused
#let wave-groupify(wave, config) = {
  let (step1, step2) = (config.step1, config.step2)
  // symbol: the main symbol representing the entry
  // length: total length of the entry in symbol units
  // offset: start of the wave
  let entry = (symbol: none, length: 0, offset: 0)
  let entries = (
    entries: (),
    s: (), // indexes of where the fancy S symbol is placed
  )

  let bus-start = 0
  let bus-end = 0

  // Following rules are applied
  // > Each entry has a "main" symbol -> loaded into entry.symbol
  // > "." extends the length by one
  // > "|" also extends the length by one -> index of the "|" saved in entries.s
  // > Mergeable repeats of the "main" symbol are treated as "."
  // > A new entry starts, when a non-mergeable symbol is read -> the offset is saved

  let offset = 0
  for (i, symbol) in wave.clusters().enumerate() {
    // [1.1] if first element is an extender, then the main symbol is treated as "x"
    if i == 0 and symbol in SYMBOLS.extender {
      entry.symbol = "x"
      entry.length += 1

      if symbol == "|" {
        entries.s += (i,)
      }
    } // [1.2] else just take the first element
    else if i == 0 {
      entry.symbol = symbol
      entry.length += 1
    } // [1.3] i > 0 ; Normal symbol processing
    else {
      // if a repeat of a mergeable entry symbol is read, merge it!
      if symbol == entry.symbol and symbol in SYMBOLS.mergeable or symbol in "." {
        entry.length += 1
      } else if symbol == "|" {
        entries.s += (i,)
        entry.length += 1
      }

      //
      if (symbol not in SYMBOLS.mergeable or symbol != entry.symbol) and symbol not in SYMBOLS.extender {
        entry.offset = offset
        offset += entry.length
        entries.entries += (entry,)

        entry = (symbol: symbol, length: 1)
      }
    }

    if i == wave.len() - 1 {
      entry.offset = offset
      offset += entry.length
      entries.entries += (entry,)
    }
  }

  return entries
}




// "dashed" creates a hard cut

/// Converts a list of nodes to a "dummy" version of their actual shape
#let coords2elements(nodes) = {
  let line-coords = ()
  let dashed = ()

  let groups = ()
  let total = ()

  for node in nodes {
    if type(node) == dictionary {
      if line-coords != () {
        groups += (cetz.draw.line(..line-coords),)
        line-coords = ()
      }

      if "bezier" in node {
        groups += (cetz.draw.bezier(..node.bezier),)
      } else if "dashed" in node {
        if groups != () {
          total += (groups,)
          groups = ()
        }
        dashed += ((..node.dashed,),)
      }
    } else {
      line-coords += (node,)
    }
  }

  if line-coords != () {
    groups += (cetz.draw.line(..line-coords),)
  }

  if groups != () {
    total += (groups,)
  }

  return (total, if dashed == () { none } else { dashed })
}







#let bus-builder(prev, next, curr, cfg) = {
  let prev = if prev == none { none } else { lower(prev) }
  let next = if next == none { none } else { lower(next) }

  return (
    (
      /* -------------------------------------------------------------------------- */
      /*                                   Primary                                  */
      /* -------------------------------------------------------------------------- */

      primary: (
        // _____ _ _ _
        //
        // _____ _ _ _
        if prev == none {
          ((-cfg.edge-overshoot, 1),)
        } else if prev in ("u",) {
          ((0, 1),)
        } //
        //   _____
        // \/
        // /\_____
        else if prev in "23456789=xz" {
          (((cfg.step2 + cfg.step1) / 2, 0.5), (cfg.step2, 1))
        } //
        // _________
        //   \
        //    \_____
        else if prev in "1unNhH" {
          ((cfg.step1, 1),)
        } //
        //     ______
        //    /
        // __/_______
        else if prev in "d0plL" {
          ((0, 0), (cfg.step1, 0), (cfg.step2, 1))
        } else {
          panic(
            "No upper prefix found when checking previous symbol \n { prev: `"
              + prev
              + "`, curr: `"
              + curr.symbol
              + "`, next: `"
              + next
              + "` }",
          )
        }
          +
          //       <---- Length ---->
          // _ _ _ __________________ _ _ _
          //
          // _ _ _ __________________ _ _ _
          ((curr.length, 1),)
          + if next == none {
            // don't need to add any upper suffix -> secondary suffix does it
            ((curr.length + cfg.edge-overshoot, 1),)
          } else if next in ("1", "p", "n", "N", "h", "H") {
            // don't need to add any upper suffix -> secondary suffix does it
          } else if next in "z" {
            (
              (
                bezier: (
                  (curr.length + cfg.step1, 1),
                  (curr.length + cfg.step3, 0.5),
                  (curr.length + cfg.bezier-controlpoint, 0.5),
                ),
              ),
            )
          } //
          // _____  ____
          //      \/
          // _____/\____
          else if next in "23456789=x" {
            (((curr.length + cfg.step1), 1), ((curr.length + (cfg.step1 + cfg.step2) / 2), 0.5))
          } //
          // ___
          //    \
          // ____"-.___
          else if next in "d" {
            (
              (curr.length, 1),
              (
                bezier: (
                  (curr.length + cfg.step1, 1),
                  (curr.length + cfg.step3, 0),
                  (curr.length + cfg.bezier-controlpoint, 0),
                ),
              ),
            )
          } //
          // ____
          //     \
          // _____\____
          else if next in "0" {
            ((curr.length + cfg.step1, 1), (curr.length + cfg.step2, 0))
          } //
          // _____
          //      |
          // _____|____
          else if next in "lL" {
            ((curr.length, 0),)
          } //
          //
          //
          //
          else if next in "u" {
            ((curr.length + cfg.step3, 1),)
          } else {
            panic(
              "No upper prefix found when checking next symbol \n { prev: `"
                + prev
                + "`, curr: `"
                + curr.symbol
                + "`, next: `"
                + next
                + "` }",
            )
          }
      )
        .map(x => {
          // apply the offset to everything
          if type(x) == dictionary {
            x.bezier = x.bezier.map(x => (x.first() + curr.offset, x.last() * cfg.symbol-height))
            x
          } else {
            (x.first() + curr.offset, x.last() * cfg.symbol-height)
          }
        })
        .dedup()
        .filter(x => x != none),

      /* -------------------------------------------------------------------------- */
      /*                                  Secondary                                 */
      /* -------------------------------------------------------------------------- */
      secondary: (
        // _____ _ _ _
        //
        // _____ _ _ _
        if prev == none {
          ((-cfg.edge-overshoot, 0),)
        } //
        //   _____
        // \/
        // /\_____
        else if prev in "23456789=xz" {
          (((cfg.step2 + cfg.step1) / 2, 0.5), (cfg.step2, 0))
        } //
        // _________
        //   \
        //    \_____
        else if prev in "1unNhH" {
          ((cfg.step1, 1), (cfg.step2, 0))
        } //
        //     ______
        //    /
        // __/_______
        else if prev in "d0plL" {
          ((cfg.step1, 0),)
        } else {
          panic(
            "No lower prefix found for previous symbol \n { prev: `"
              + prev
              + "`, curr: `"
              + curr.symbol
              + "`, next: `"
              + next
              + "` }",
          )
        }
          +
          //       <---- Length ---->
          // _ _ _ __________________ _ _ _
          //
          // _ _ _ __________________ _ _ _
          ((curr.length, 0),)
          + if next == none {
            ((curr.length + cfg.edge-overshoot, 0),)
          } else if next in ("n", "N", "l", "L") {
            // don't need to add any upper suffix
          } else if next in "z" {
            (
              (
                bezier: (
                  (curr.length + cfg.step1, 0),
                  (curr.length + cfg.step3, 0.5),
                  (curr.length + cfg.bezier-controlpoint, 0.5),
                ),
              ),
            )
          } //
          // _____  ____
          //      \/
          // _____/\____
          else if next in "23456789=x" {
            (((curr.length + cfg.step1), 0), ((curr.length + (cfg.step1 + cfg.step2) / 2), 0.5))
          } //
          // ___
          //    \
          // ____"-.___
          else if next in "d" {
            ((curr.length + cfg.step3, 0),)
          } //
          // _____
          //      |
          // _____|____
          else if next in "phH" {
            ((curr.length, 0), (curr.length, 1))
          } //
          // ____
          //     \
          // _____\____
          else if next in "0" {
            ((curr.length + cfg.step2, 0),)
          } // __________
          //      /
          // ____/
          else if next in "1" {
            ((curr.length + cfg.step1, 0), (curr.length + cfg.step2, 1))
          } else if next in "u" {
            (
              (curr.length + cfg.step1, 0),
              (
                bezier: (
                  (curr.length + cfg.step1, 0),
                  (curr.length + cfg.step3, 1),
                  (curr.length + cfg.bezier-controlpoint, 1),
                ),
              ),
            )
          } else {
            panic(
              "No lower prefix found for next symbol \n { prev: `"
                + prev
                + "`, curr: `"
                + curr.symbol
                + "`, next: `"
                + next
                + "` }",
            )
          }
      )
        .map(x => {
          // apply the offset to everything
          if type(x) == dictionary {
            x.bezier = x.bezier.map(x => (x.first() + curr.offset, x.last() * cfg.symbol-height))
            x
          } else {
            (x.first() + curr.offset, x.last() * cfg.symbol-height)
          }
        })
        .dedup()
        .filter(x => x != none),

      /* -------------------------------------------------------------------------- */
      /*                                    Body                                    */
      /* -------------------------------------------------------------------------- */
      //    2 -------> 3
      //   /            \
      //   \            /
      //    1 <------- 4
      body: // Segments #1 and #2
      coords2elements(
        (
          if prev == none {
            ((-cfg.edge-overshoot, 0), (-cfg.edge-overshoot, 1))
          } else if prev in SYMBOLS.bus + "xz" {
            ((cfg.step2, 0), ((cfg.step1 + cfg.step2) / 2, 0.5), (cfg.step2, 1))
          } else if prev in "1unNhH" {
            ((cfg.step2, 0), (cfg.step1, 1))
          } else if prev in "d0plL" {
            ((cfg.step1, 0), (cfg.step2, 1))
          } else {
            panic("Unknown position for { prev: `" + prev + "`, curr: `" + curr.symbol + "`, next: `" + next + "` }")
          }
        ).map(x => {
          (x.first() + curr.offset, x.last() * cfg.symbol-height)
        })
          +
          // Segments #3 and #4
          (
            if next == none {
              ((cfg.edge-overshoot, 1), (cfg.edge-overshoot, 0))
            } else if next in ("p", "n", "N", "l", "L", "h", "H") {
              ((0, 1), (0, 0))
            } else if next in SYMBOLS.bus + "x" {
              ((cfg.step1, 1), ((cfg.step1 + cfg.step2) / 2, 0.5), (cfg.step1, 0))
            } else if next in "0" {
              ((cfg.step1, 1), (cfg.step2, 0))
            } else if next in "1" {
              ((cfg.step2, 1), (cfg.step1, 0))
            } else if next in "d" {
              ((cfg.step1, 1), (bezier: ((cfg.step1, 1), (cfg.step3, 0), (cfg.bezier-controlpoint, 0))))
            } else if next in "u" {
              ((cfg.step1, 1), (bezier: ((cfg.step3, 1), (cfg.step1, 0), (cfg.bezier-controlpoint, 1))))
            } else if next in "z" {
              (
                (bezier: ((cfg.step1, 1), (cfg.step3, 0.5), (cfg.bezier-controlpoint, 0.5))),
                (bezier: ((cfg.step3, 0.5), (cfg.step1, 0), (cfg.bezier-controlpoint, 0.5))),
              )
            } else {
              panic("Unknown position for { prev: `" + prev + "`, curr: `" + curr.symbol + "`, next: `" + next + "` }")
            }
          ).map(x => if type(x) == array {
            (x.first() + curr.offset + curr.length, x.last() 
            * cfg.symbol-height)
          } else {
            (bezier: x.bezier.map(x => (x.first() + curr.offset + curr.length, x.last() * cfg.symbol-height)))
          }),
      ).first(),

      /* -------------------------------------------------------------------------- */
      /*                                    Other                                   */
      /* -------------------------------------------------------------------------- */

      ..if curr.symbol != "x" {
        (
          label: (
            // start coordinate
            curr.offset
              + if prev in (none,) { 0 } else if prev in SYMBOLS.bus + "ud0xplLz" { cfg.step2 } else if prev
                in "1nNhH" {
                cfg.step2
              } else {
                panic(
                  "Unknown position for { prev: `" + prev + "`, curr: `" + curr.symbol + "`, next: `" + next + "` }",
                )
              },
            // end coordinate
            curr.offset
              + curr.length
              + if next in (none, "p", "n", "N", "l", "L", "h", "H") { 0 } else if next in SYMBOLS.bus + "x" {
                cfg.step1
              } else if next in "du" {
                (cfg.step1 + cfg.step2) / 2
              } else if next in "z" {
                (cfg.step1 + cfg.step2) / 2
              } else if next in "10" { cfg.step1 } else {
                panic(
                  "Unknown position for { prev: `" + prev + "`, curr: `" + curr.symbol + "`, next: `" + next + "` }",
                )
              },
          ),
        )
      },
    )
  )
}


// workaround for https://github.com/typst/typst/issues/7839
#let merge-strokes(stroke1, stroke2) = {
  (
    (
      if stroke1.paint != auto {
        (paint: stroke1.paint)
      }
        + if stroke1.thickness != auto {
          (thickness: stroke1.thickness)
        }
        + if stroke1.cap != auto {
          (cap: stroke1.cap)
        }
        + if stroke1.join != auto {
          (join: stroke1.join)
        }
        + if stroke1.dash != auto {
          (dash: stroke1.dash)
        }
    )
      + (
        if stroke2.paint != auto {
          (paint: stroke2.paint)
        }
          + if stroke2.thickness != auto {
            (thickness: stroke2.thickness)
          }
          + if stroke2.cap != auto {
            (cap: stroke2.cap)
          }
          + if stroke2.join != auto {
            (join: stroke2.join)
          }
          + if stroke2.dash != auto {
            (dash: stroke2.dash)
          }
      )
  )
}



/// <-- width -->
///           __          __
/// ........./  \......../  \...
///         /           /
///        /     x     /
///       /           /
/// ...../.........../.........
///  \__/        \__/
///     <- spacing ->
///
/// x: center of symbol
#let draw-s(x, width, spacing, outside, stroke, sym-height) = {
  spacing = spacing / 2
  width = width / 2
  (
    bezier(
      stroke: stroke,
      // top left
      (x + 0.5 - spacing, sym-height / 2),
      (x + 0.5 - spacing + width, sym-height + outside),
      (x + 0.5 - spacing + width / 4, sym-height + outside / 2)
    )
      + bezier(
        stroke: stroke,
        // top right
        (x + 0.5 + spacing + width, sym-height + outside),
        (x + 0.5 + spacing, sym-height / 2),
        (x + 0.5 + spacing + width / 4, sym-height + outside / 2),
      )
      + bezier(
        stroke: stroke,
        // bottom right
        (x + 0.5 + spacing, sym-height / 2),
        (x + 0.5 + spacing - width, -outside),
        (x + 0.5 + spacing - width / 4, -outside / 2),
      )
      + bezier(
        stroke: stroke,
        // bottom left
        (x + 0.5 - spacing - width, -outside),
        (x + 0.5 - spacing, sym-height / 2),
        (x + 0.5 - spacing - width / 4, -outside / 2),
      )
  )
}


#let length-to-float(length-value, size-ref) = if type(length-value) == length {
  length-value / size-ref } else {
  float(length-value)
}