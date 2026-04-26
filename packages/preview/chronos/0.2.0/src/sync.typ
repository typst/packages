#import "sequence.typ"

#let _sync(elmts) = {
  return ((
    type: "sync",
    elmts: elmts
  ),)
}

#let render(pars-i, x-pos, participants, elmt, y, lifelines) = {
  let draw-seq = sequence.render.with(pars-i, x-pos, participants)

  let shapes = ()

  let end-y = y

  for e in elmt.elmts {
    let yi
    let shps
    (yi, lifelines, shps) = draw-seq(e, y, lifelines)
    shapes += shps
    end-y = calc.min(end-y, yi)
  }

  let r = (end-y, lifelines, shapes)
  return r
}