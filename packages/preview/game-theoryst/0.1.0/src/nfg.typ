#import table: cell
#set cell(fill: none)
#import "utils/programming_utils.typ": *
#import "utils/styling_utils.typ": *
#import "utils/table_utils.typ": *
#import "@preview/pinit:0.1.4": *

// State + setting function for black-white vs color
#let _bw = state("no-colors", false)
#let colorless(bw: true) = _bw.update(bw)

// Counter, needed for pin IDs
#let _nfg-counter = counter("nfg-counter")

/* Main function to make normal/strategic form games */
  
  // ..args represents payoffs 
  // "pad": Pads cells with additional space, helpful for underlines
  // "lazy-cells": don't equalize cell dimensions
  // Note: This function requires context in order to equalize cell lengths.
    // --It's possible that the scope of the context could be reduced at a later point through refactoring

#let nfg(
  players: ("A", "B"),
  s1: ($x$, $y$),
  s2: ($a$, $b$),
  mixings: none,
  eliminations: none,
  ejust: (:), // -ex: (s11: (x: (0,0), y: (0,0)))
  gid: none,
  pad: none,
  lazy-cells: false,
  bw: none,
  custom-fills: (:),
  // opts: (:), // --Other options, tbd
  ..args
) = context {
    let nrow = s1.len()
    let ncol = s2.len()
    let payoffs = args.pos()
    let (S1, S2) = (s1, s2)

    /* Colors */
    let colors = (
      hp: red, vp: blue, //players
      hm: "#e64173", vm: eastern, //mixings
      he: orange, ve: olive //elim-lines
    )
    
    for p in custom-fills.pairs() { colors.insert(..p) }

    let bw = if-none(bw, _bw.get(), bw)
    colors = if-else(bw, colors.keys().map(k => (str(k): black)).join(), colors)
    // Previous version, easier to understand: 
      // for (k,v) in colors.pairs() {
      //   if bw {colors.at(k) = black}
      // }


    /* Mixed Strategies */
    let (hmix, vmix) = {
      if type(mixings) == "array" { 
        assert(mixings.len() == 2, message: "`mixings` must be a dictionary or an array of length 2") 
        mixings
      } else if type(mixings) == "dictionary" {
        assert(("hmix", "vmix").any(k => k in mixings.keys()), message: "Must provide one of (`hmix`, `vmix`) keys to mixings")
        let dmixings = (hmix: none, vmix: none)
        for p in mixings.pairs() { dmixings.insert(..p) }
        (dmixings.hmix, dmixings.vmix)
      } else {
        (none, none)
      }
    }
    
    let (x-col-w, x-row-h) = {
      (hmix, vmix)
      .map(mix => if-none(mix, 0pt, auto))
    }

    hmix = if-none(hmix, ([],) * nrow, hmix)
    .map(m => mixd(color: colors.hm, m))
    vmix = if-none(vmix, ([],) * ncol, vmix)
    .map(m => mixd(color: colors.vm, m))
      
    /* Equalize Cell Dims. */
    // Get array of content widths and heights
    let (warray, harray) = {
      (s2 + vmix, s1 + hmix)
      .map(strat =>
        (strat + payoffs)
        .map(ent => measure(ent))
      )
    }

    // Compute maximums
    let (cw, rh) = (
      10pt + warray.fold(0pt, (acc, val) => calc.max(acc, val.width)), 
      10pt + harray.fold(0pt, (acc, val) => calc.max(acc, val.height))
    )

    /* Additional Padding */
    
    // Format pad => cpad arg
    let cpad = {
      if type(pad) == "array" { 
        assert(pad.len() == 2, message: "When padding is an array, it must be of length 2")
        ("x": pad.at(0), "y": pad.at(1)) 
      } else if type(pad) == "length" {
        ("x": pad, "y": pad) 
      } else if type(pad) == "dictionary" {
        req-keys(pad, ("x", "y"))
      } else { req-keys((:), ("x", "y")) }
    }
    
    // Add padding, account for lazy sizing

    (cw, rh) = if-else(
      lazy-cells, 
      (auto, auto), 
      (cw + cpad.at("x"), rh + cpad.at("y"))
    )
    
    // Function to build cells w. default padding
    // Also allows lazy-cells + custom padding
    let pad-cell(dinset, body) = {
      let sinset = if-else(
        cpad != (none, none) and lazy-cells, 
        (x: 5pt + cpad.at("x"), y: 5pt + cpad.at("y")), 
        dinset
      )
      cell(inset: sinset, body)
    }

    /* Eliminations */
    let pin-names = if-none(eliminations, (), eliminations)
    let pin-strats = if-none(eliminations, (), eliminations)
    let elim-id = if-none(gid, "nfg" + _nfg-counter.display() + "-", gid)

    for strat-name in pin-strats {
      let e = int(strat-name.at(2))
      if (strat-name.at(1) == "1") {
        S1.at(e - 1) = S1.at(e - 1) + pin(elim-id + strat-name + "--start")
        payoffs.at( (e * ncol) - 1 ) = payoffs.at( (e * ncol) - 1 ) + pin(elim-id + strat-name + "--end")
      } else {
        S2.at(e - 1) = S2.at(e - 1) + pin(elim-id + strat-name + "--start")
        payoffs.at( (nrow * ncol) - (ncol - (e - 1)) ) = payoffs.at( (nrow * ncol) - (ncol - (e - 1)) ) + pin(elim-id + strat-name + "--end")
      }
    }

    // Elimination Adjustments
    let eljust = (:)
      for name in pin-strats {
        eljust.insert(name, (x: (0pt, 0pt), y: (0pt, 0pt)))
        if name in ejust.keys() { 
          for p in ejust.at(name).pairs() { 
            eljust.at(name).insert(..p) 
        }} 
      }
    
    /* Make NFG */
    table(
      stroke: (x, y) => {strf(x, y)},
      align: (x, y) => {alif(x, y)},
      rows: ((auto, x-row-h, auto), ((rh,) * nrow)).join(),
      columns: ((auto, x-col-w ,auto), ((cw,) * ncol)).join(),
      p2(players.at(1), color: colors.vp, cspn: ncol),
      blank-cells(), ..(vmix.map(m => { pad-cell((top: 1pt), m) })), 
      blank-cells(), ..S2.map(s => pad-cell((top: 1pt), s)),
      p1(players.at(0), color: colors.hp, rspn: nrow),
      ..for i in range(0, nrow) {
        (pad-cell(0pt, hmix.at(i)), pad-cell(auto, S1.at(i)), ..range(0, ncol).map(j => payoffs.at(i * ncol + j)))
      }
    )
  
  /* Draw Eliminations */
  for el-strat-name in pin-strats {
    let fill = if-else(el-strat-name.at(1) == "1", colors.he, colors.ve) 
    let this-just = eljust.at(el-strat-name)
    pinit-line(
      stroke: fill,
      start-dx: this-just.x.at(0),
      end-dx: this-just.x.at(1),
      start-dy: this-just.y.at(0),
      end-dy: this-just.y.at(1),
      elim-id + el-strat-name + "--start", 
      elim-id + el-strat-name + "--end",
    )
  }
  _nfg-counter.step()
}