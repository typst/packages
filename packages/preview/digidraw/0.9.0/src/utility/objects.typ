#import "@preview/cetz:0.4.2"
#import cetz.draw: *

#import "utility.typ"


#let bus-entry(current, prev,  next, config, fill) = scope({
    let paths = utility.bus-build(prev, next, current, config)
    merge-path(stroke: none, fill: fill, paths)
    paths
})


#let objects = (
  // [Clock] -----------------------------------------------------------
  "p": (current, prev,  next, config) => scope({
    for (i,c) in current.clusters().enumerate() {
      if lower(prev.first()) in (lower(none),"p","l","1","0","u","d",..utility.lists.buses,) or c == "." {
        utility.vertical-line(config, mark: if current.first() == "P" {top})
      }
      line((0,1),(0.5,1),(0.5,0),(1,0))
      translate(x: 1)
    }
  }),

  "n": (current, prev,  next, config) =>  scope({
    for (i,c) in current.clusters().enumerate() {
      if lower(prev.first()) in (lower(none),"n","h","1","0","u","d",..utility.lists.buses,) or c == "." {
        utility.vertical-line(config, mark: if current.first() == "N" {bottom})
      }
      line((0,0),(0.5,0),(0.5,1),(1,1))
      translate(x: 1)
    }
  }),
  
  // [Signals] ---------------------------------------------------------
  "h": (current, prev,  next, config) => {
    if lower(prev.first()) in (..utility.lists.ends-low, ..utility.lists.buses) {
      utility.vertical-line(config, mark: if current.first() == "H" {top})
    }
    line((0,1),(current.len(),1))
  },

  "l": (current, prev,  next, config) => {
    if lower(prev.first()) in (..utility.lists.ends-high, ..utility.lists.buses) {
      utility.vertical-line(config, mark: if current.first() == "L" {bottom})
    }
    line((0,0),(current.len(),0))
  },

  

  "1":  (current, prev,  next, config) => {
    let (inset-1, inset-2) = (config.inset-1, config.inset-2)

    // TODO: process buses
    if lower(prev.first()) in (..utility.lists.ends-low) {
      //      ______
      //     /
      // ___/ 
      line((0,0),(inset-1,0),(inset-1 + inset-2,1),(current.len(),1))
    } else if lower(prev.first()) in ("1","h","n") {
      // ___  ______
      //    \/
      // 
      line((0,1),(inset-1,1),(inset-1 + inset-2 / 2,0.5),(inset-1 + inset-2,1),(current.len(),1))

    } else if lower(prev.first()) in ("z",) {
      //     _______
      // ___/
      // 
      line((0,0.5),(inset-1,0.5),(inset-1 + inset-2 / 2,1),(current.len(),1))
    } else if lower(prev.first()) in (..utility.lists.buses,) {
      // ____________
      //     / <- Bus part will be done in the bus component!
      // ___/
      line((inset-1 + inset-2,1),(current.len(),1))
    } else {
      // ___________
      //
      //
      line((0,1),(current.len(),1))
    }
  },

  "0": (current, prev,  next, config) => {
    let (inset-1, inset-2) = (config.inset-1, config.inset-2)

    // TODO: process buses
    if lower(prev.first()) in (..utility.lists.ends-high) {
      // ___
      //    \
      //     \______
      line((0,1),(inset-1,1),(inset-1 + inset-2,0),(current.len(),0))
    } else if lower(prev.first()) in ("0","l","p") {
      //
      //
      // ___/\______
      line((0,0),(inset-1,0),(inset-1 + inset-2 / 2,0.5),(inset-1 + inset-2,0),(current.len(),0))
    } else if lower(prev.first()) in ("z",) {
      //
      // ___
      //    \_______
      line((0,0.5),(inset-1,0.5),(inset-1 + inset-2 / 2,0),(current.len(),0))
    } else if lower(prev.first()) in (..utility.lists.buses,) {
      // ___
      //    \ <- Bus part will be done in the bus component!
      // ____\_______
      line((inset-1 + inset-2,0),(current.len(),0))
    } else {
      // 
      // 
      // ___________
      line((0,0),(current.len(),0))
    }
  },

  "z": (current, prev,  next, config) => {
    let inset-1 = (config.inset-1)
    let dest-x = 0.5
    if lower(prev.first()) in (..utility.lists.ends-low) {
      //        ___ 0.5
      //     ,^'
      // ___/ 0
      utility.lncurve((0,0), (current.len(),0.5), inset-1)
      
    } else if lower(prev.first()) in (..utility.lists.ends-high) {
      // ___ 1
      //    \
      //     '-.___ 0.5
      utility.lncurve((0,1), (1,0.5), inset-1)
      line((1,0.5),(current.len(),0.5))
    } else if lower(prev.first()) in (..utility.lists.buses) {
      //__
      //  '-.______
      //__^''
      line((0.5,0.5),(current.len(),0.5))
    } else {
      // 
      // __________
      //
      line((0,0.5),(current.len(),0.5))
    }
  },

  "u": (current, prev,  next, config) => {
    let inset-1 = (config.inset-1)
    if lower(prev.first()) in (..utility.lists.ends-low) {
      //        ___ 1
      //     ,^'
      // ___/ 0
      utility.lncurve((0,0), (1,1), inset-1, cut: true)
      line((0.5,1), (current.len(),1), stroke: config.stroke-dashed)
    } else if lower(prev.first()) in ("z",) {
      //        ___ 1
      //     ,^'
      // ___/ 0.5
      utility.lncurve((0,0.5), (1,1), inset-1, cut: true)
      line((0.5,1), (current.len(),1), stroke: config.stroke-dashed)
    } else if lower(prev.first()) in (..utility.lists.buses) {
      line((0.5,1), (current.len(),1), stroke: config.stroke-dashed)
    } else {
      // _ _ _ _ _ 
      //
      //
      line((0,1),(current.len(),1), stroke: config.stroke-dashed)
    }
  },

  "d": (current, prev,  next, config) => {
    let inset-1 = (config.inset-1)
    if lower(prev.first()) in (..utility.lists.ends-high) {
      // ___ 1
      //    \
      //     '-.___ 0
      utility.lncurve((0,1), (1,0), inset-1, cut: true)
      line((0.5,0), (current.len(),0), stroke: config.stroke-dashed)
    } else if lower(prev.first()) in ("z",) {
      // ___ 0.5
      //    \
      //     '-.___ 0
      utility.lncurve((0,0.5), (1,0), inset-1, cut: true)
      line((0.5,0), (current.len(),0), stroke: config.stroke-dashed)
    } else if lower(prev.first()) in (..utility.lists.buses) {
      line((0.5,0), (current.len(),0), stroke: config.stroke-dashed)
    } else {
      // _ _ _ _ _ 
      //
      //
      line((0,0),(current.len(),0), stroke: config.stroke-dashed)
    }
  },

  // [Buses] -----------------------------------------------------------
  "x": (current, prev,  next, config) => bus-entry(current, prev,  next, config, config.bus-colors.at(current.first())),
  "2": (current, prev,  next, config) => bus-entry(current, prev,  next, config, config.bus-colors.at(current.first())),
  "3": (current, prev,  next, config) => bus-entry(current, prev,  next, config, config.bus-colors.at(current.first())),
  "4": (current, prev,  next, config) => bus-entry(current, prev,  next, config, config.bus-colors.at(current.first())),
  "5": (current, prev,  next, config) => bus-entry(current, prev,  next, config, config.bus-colors.at(current.first())),
  "6": (current, prev,  next, config) => bus-entry(current, prev,  next, config, config.bus-colors.at(current.first())),
  "7": (current, prev,  next, config) => bus-entry(current, prev,  next, config, config.bus-colors.at(current.first())),
  "8": (current, prev,  next, config) => bus-entry(current, prev,  next, config, config.bus-colors.at(current.first())),
  "9": (current, prev,  next, config) => bus-entry(current, prev,  next, config, config.bus-colors.at(current.first())),


  default: (current, prev,  next, config) => {
    rect((0,0),(current.len(),1), stroke: red, fill:  tiling(size: (2mm, 2mm), box(width: 100%, height: 100%, fill: red.lighten(80%), {
        set std.line(stroke: black + 0.3pt)
        place(std.line(start: (0%,0%), end: (100%,100%), stroke: red))
        place(std.line(start: (100%,0%), end: (0%,100%), stroke: red))
      })))
  },
)