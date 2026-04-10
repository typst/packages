
#let occupation-matrix(nrow, ncol) = {
  let m = (true, )*nrow*ncol
  m.chunks(ncol)
}

#let test-cells(row,cols,matrix) = {
 let r = matrix.at(row)
 r.slice(calc.min(..cols), calc.max(..cols) + 1).reduce( 
    (x,y) => x and y)
}

#let pick-ith(x, i) = {
  for _p in x {(_p.at(i),)}
}

#let palette = range(0,360, step:10).map(h => color.hsl(h*1deg,60%,70%).transparentize(60%))

#let palette-paired = range(0,9).map(i => pick-ith(palette.chunks(9), i)).flatten()

