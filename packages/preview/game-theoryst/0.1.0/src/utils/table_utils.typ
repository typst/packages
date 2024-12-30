#import table: cell
#import "programming_utils.typ": if-else


// Utility to insert blank cells
#let blank-cells(cspn: 3) = {
  cell(colspan: cspn, [])
}

// "Stroke-if": utility to stroke only the payoff matrix, not the player or strategy cells
#let strf(x, y, tstart: 3) = {
  if-else(x < tstart or y < tstart, none, 1pt)
}

// "Align-if": Utility to set alignment for players and strategies
#let alif(x, y, tstart: 3) = {
  if calc.max(x, y) >= tstart {
    if (x,y).any(z => {z < tstart}) {
      if x == 0 { //p1
          horizon + center
      } else if y == 0 { //p2
          top + center
      } else if x <= tstart - 2 { //h_mixings
          horizon + right
      } else if y <= tstart - 1 { // s2 + v_mixings
          bottom + center
      } else { //s1
        horizon + center
      }
    } else { //payoffs
        horizon + center
    } 
  } else { //blank cells
      horizon + center
  }
}
