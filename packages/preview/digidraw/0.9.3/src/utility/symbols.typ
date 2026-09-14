#import "utility.typ"





#let symbols = (
  "z": (prev, next, curr, cfg) => {
    (
      primary: (
        if prev == none {
          ((-cfg.edge-overshoot, cfg.symbol-height / 2),)
        } else if prev in "23456789=x" {
          ((cfg.step3, cfg.symbol-height / 2),)
        } else if prev in "hHnN1u" {
          (
            (0, cfg.symbol-height),
            (cfg.step1, cfg.symbol-height),
            (bezier: ((cfg.step1, cfg.symbol-height), (cfg.step3, cfg.symbol-height / 2), (cfg.bezier-controlpoint, cfg.symbol-height / 2))), (cfg.step3, cfg.symbol-height / 2))
        } else if prev in "lLpP0d" {
          ((0, 0), (cfg.step1, 0), (bezier: ((cfg.step1, 0), (cfg.step3, cfg.symbol-height / 2), (cfg.bezier-controlpoint, cfg.symbol-height / 2))), (cfg.step3, cfg.symbol-height / 2))
        } else { ((0, cfg.symbol-height / 2),) }
      ).map(x => if type(x) == array {
        (x.first() + curr.offset, x.last())
      } else {
        (bezier: x.bezier.map(x => (x.first() + curr.offset, x.last())))
      })
        + (
          if next in (none,) {
            ((cfg.edge-overshoot, cfg.symbol-height / 2),)
          } else if next in utility.SYMBOLS.bus + "x10" {
            ((cfg.step1, cfg.symbol-height / 2),)
          } else {
            ((0, cfg.symbol-height / 2),)
            //panic("Unknown position for { prev: `" + prev + "`, curr: `" + curr.symbol + "`, next: `" + next + "` }")
          }
        ).map(x => (x.first() + curr.offset + curr.length, x.last())),
    )
  },

  "d": (prev, next, curr, cfg) => {
    (
      primary: (
        // big ignore
        if prev not in (none,) + utility.SYMBOLS.bus.clusters() + "x0pPlL".clusters() {
          (
            if prev in "1nNhHu" {
              ((0, cfg.symbol-height), (cfg.step1, cfg.symbol-height), (bezier: ((cfg.step1, cfg.symbol-height), (cfg.step3, 0), (cfg.step2, 0))))
            } else if prev in "z" {
              ((bezier: ((cfg.step1, cfg.symbol-height / 2), (cfg.step3, 0), (cfg.bezier-controlpoint, 0))),)
            } else {
              panic("Unknown position for { prev: `" + prev + "`, curr: `" + curr.symbol + "`, next: `" + next + "` }")
            }
          ).map(x => if type(x) == array {
            (x.first() + curr.offset, x.last())
          } else {
            (bezier: x.bezier.map(x => (x.first() + curr.offset, x.last())))
          })
        }
          +
          /* ------------------------------ Dashed Lines ------------------------------ */
          (
            (
              dashed: if prev == none { ((curr.offset - cfg.edge-overshoot, 0),) } else if prev in "pPlL0" {
                ((curr.offset, 0),)
              } else if prev in utility.SYMBOLS.bus + "x1nNhHzu" {
                ((curr.offset + cfg.step3, 0),)
              } else {
                panic(
                  "Unknown position for { prev: `" + prev + "`, curr: `" + curr.symbol + "`, next: `" + next + "` }",
                )
              }
                + if next == none {
                  ((curr.offset + curr.length + cfg.edge-overshoot, 0),)
                } else if next in "x01pPnNlLhHzu" + utility.SYMBOLS.bus {
                  ((curr.offset + curr.length, 0),)
                } else {
                  panic(
                    "Unknown position for { prev: `" + prev + "`, curr: `" + curr.symbol + "`, next: `" + next + "` }",
                  )
                },
            ),
          )
      ),
    )
  },

  "u": (prev, next, curr, cfg) => {
    (
      primary: (
        // big ignore
        if prev not in (none,) + utility.SYMBOLS.bus.clusters() + "x1nNhH".clusters() {
          (
            if prev in "0pPlLd" {
              ((0, 0), (cfg.step1, 0), (bezier: ((cfg.step1, 0), (cfg.step3, cfg.symbol-height), (cfg.bezier-controlpoint, cfg.symbol-height))))
            } else if prev in "z" {
              ((bezier: ((cfg.step1, cfg.symbol-height / 2), (cfg.step3, cfg.symbol-height), (cfg.bezier-controlpoint, cfg.symbol-height))),)
            } else {
              panic("Unknown position for { prev: `" + prev + "`, curr: `" + curr.symbol + "`, next: `" + next + "` }")
            }
          ).map(x => if type(x) == array {
            (x.first() + curr.offset, x.last())
          } else {
            (bezier: x.bezier.map(x => (x.first() + curr.offset, x.last())))
          })
        }
          +
          /* ------------------------------ Dashed Lines ------------------------------ */
          (
            (
              dashed: if prev == none { ((curr.offset - cfg.edge-overshoot, cfg.symbol-height),) } else if prev in "nNhH1" {
                ((curr.offset, cfg.symbol-height),)
              } else if prev in utility.SYMBOLS.bus + "x0pPlLzd" {
                ((curr.offset + cfg.step3, cfg.symbol-height),)
              } else {
                panic(
                  "Unknown position for { prev: `" + prev + "`, curr: `" + curr.symbol + "`, next: `" + next + "` }",
                )
              }
                + if next == none { ((curr.offset + curr.length + cfg.edge-overshoot, cfg.symbol-height),) } else if next
                  in "x01pPnNlLhHzd" + utility.SYMBOLS.bus {
                  ((curr.offset + curr.length, cfg.symbol-height),)
                } else {
                  panic(
                    "Unknown position for { prev: `" + prev + "`, curr: `" + curr.symbol + "`, next: `" + next + "` }",
                  )
                },
            ),
          )
      ),
    )
  },

  // (prev,next,curr,config) => (primary: ..., secondary: ..., marks: ...)

  "0": (prev, next, curr, cfg) => {
    return (
      primary: if prev == none {
        ((-cfg.edge-overshoot, 0),)
      }
        + (
          if prev == "u" {
            (
              (curr.offset, cfg.symbol-height),
              (curr.offset + cfg.step1, cfg.symbol-height),
              (curr.offset + cfg.step2, 0),
              (curr.offset + curr.length, 0),
            )
          } else if prev in "1nNhH".clusters() {
            (
              (curr.offset + cfg.step1, cfg.symbol-height),
              (curr.offset + cfg.step2, 0),
              (curr.offset + curr.length, 0),
            )
          } else if prev in utility.SYMBOLS.bus.clusters() + ("x",) {
            (
              (curr.offset + cfg.step2, 0),
              (curr.offset + curr.length, 0),
            )
          } else if prev in "0lL".clusters() {
            (
              (curr.offset + cfg.step1, 0),
              (curr.offset + (cfg.step2 + cfg.step1) / 2, cfg.symbol-height / 2),
              (curr.offset + cfg.step2, 0),
              (curr.offset + curr.length, 0),
            )
          } else if prev in "z".clusters() {
            ((curr.offset + cfg.step2, 0), (curr.offset + curr.length, 0))
          } else {
            ((curr.offset, 0), (curr.offset + curr.length, 0))
          }
        )
        + if next == none {
          ((curr.offset + curr.length + cfg.edge-overshoot, 0),)
        },
    )
  },

  "1": (prev, next, curr, cfg) => {
    return (
      primary: if prev == none {
        ((-cfg.edge-overshoot, cfg.symbol-height),)
      }
        + (
          if prev in ("0", "l", "L", "d") {
            (
              (curr.offset, 0),
              (curr.offset + cfg.step1, 0),
              (curr.offset + cfg.step2, cfg.symbol-height),
              (curr.offset + curr.length, cfg.symbol-height),
            )
          } else if prev in ("1", "n", "N", "h", "H") {
            (
              (curr.offset + cfg.step1, cfg.symbol-height),
              (curr.offset + (cfg.step1 + cfg.step2) / 2, cfg.symbol-height / 2),
              (curr.offset + cfg.step2, cfg.symbol-height),
              (curr.offset + curr.length, cfg.symbol-height),
            )
          } else if prev == "z" {
            ((curr.offset + cfg.step2, cfg.symbol-height), (curr.offset + curr.length, cfg.symbol-height))
          } else {
            ((curr.offset, cfg.symbol-height), (curr.offset + curr.length, cfg.symbol-height))
          }
        )
        + if next == none {
          ((curr.offset + curr.length + cfg.edge-overshoot, cfg.symbol-height),)
        },
    )
  },

  /* ------------------------------ Flank Signals ----------------------------- */
  "l": (prev, next, curr, cfg) => {
    return (
      primary: if prev == none {
        ((-cfg.edge-overshoot, 0),)
      }
        + (
          if prev in "zu".clusters() { ((curr.offset, cfg.symbol-height),) }
            + (
              (curr.offset, 0),
              (curr.offset + curr.length, 0),
            )
        )
        + if next == none {
          ((curr.offset + curr.length + cfg.edge-overshoot, 0),)
        },

      ..if curr.symbol == "L" and lower(prev) in "n123456789=xhzu".clusters() {
        (
          mark: (curr.offset,),
          symbol: "<",
        )
      },
    )
  },
  "h": (prev, next, curr, cfg) => {
    return (
      primary: if prev == none {
          ((-cfg.edge-overshoot, cfg.symbol-height),)
        } + if prev in "zd0".clusters() { ((curr.offset, 0),) }
        + (
          (curr.offset, cfg.symbol-height),
          (curr.offset + curr.length, cfg.symbol-height),
        ) + if next == none {
          ((curr.offset + curr.length + cfg.edge-overshoot, cfg.symbol-height),)
        },

      ..if curr.symbol == "H" and lower(prev) in "p023456789=xlzd".clusters() {
        (
          mark: (curr.offset,),
          symbol: ">",
        )
      },
    )
  },

  /* ------------------------------ Clock Signals ----------------------------- */

  "p": (prev, next, curr, cfg) => {
    return (
      primary: if prev in (none, "1", "z", "u", "d") { ((curr.offset, 0),) }
        + range(0, curr.length)
          .map(i => {
            ((curr.offset + i, cfg.symbol-height), (curr.offset + i + 0.5, cfg.symbol-height), (curr.offset + i + 0.5, 0), (curr.offset + i + 1, 0))
          })
          .sum(),

      ..if curr.symbol == "P" {
        (
          mark: range(curr.offset + int(lower(prev) in ("n", "h")), curr.length + curr.offset),
          symbol: ">",
        )
      },
    )
  },

  "n": (prev, next, curr, cfg) => {
    return (
      primary: if prev in (none, "0", "z", "u", "d") { ((curr.offset, cfg.symbol-height),) }
        + range(0, curr.length)
          .map(i => {
            ((curr.offset + i, 0), (curr.offset + i + 0.5, 0), (curr.offset + i + 0.5, cfg.symbol-height), (curr.offset + i + 1, cfg.symbol-height))
          })
          .sum(),

      ..if curr.symbol == "N" {
        (
          mark: range(curr.offset + int(lower(prev) in ("p", "l")), curr.length + curr.offset),
          symbol: "<",
        )
      },
    )
  },

  /* ---------------------------------- Buses --------------------------------- */
  "x": utility.bus-builder,
  "=": utility.bus-builder,
  "2": utility.bus-builder,
  "3": utility.bus-builder,
  "4": utility.bus-builder,
  "5": utility.bus-builder,
  "6": utility.bus-builder,
  "7": utility.bus-builder,
  "8": utility.bus-builder,
  "9": utility.bus-builder,
)

#let symbol2lines = symbols
