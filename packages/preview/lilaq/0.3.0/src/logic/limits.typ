#import "../math.typ": minmax
#import "process-coordinates.typ": is-data-coordinates

#let plot-lim(x, err: none) = {
  if err == none { return minmax(x) }
  
  return (
    calc.min(..array.zip(x, err.m).map(((x, err)) => x - if type(err) == array { err.at(0) } else { err })),
    calc.max(..array.zip(x, err.p).map(((x, err)) => x + if type(err) == array { err.at(1) } else { err })),
  )
}

#let bar-lim(x, base) = {
  let lim = minmax(x + base)
  let (base-min, base-max) = minmax(base)
  if lim.at(0) == base-min { lim.at(0) *= 1fr }
  if lim.at(1) == base-max { lim.at(1) *= 1fr }
  return lim
}

// ignores (relative) lengths and ratios and
// only accounts for data coordinates (which are
// given as floats).
#let compute-primitive-limits(coords) = {
  let filtered-coords = coords.filter(is-data-coordinates)
  if filtered-coords.len() == 0 { return none }
  return (calc.min(..filtered-coords), calc.max(..filtered-coords))
}
