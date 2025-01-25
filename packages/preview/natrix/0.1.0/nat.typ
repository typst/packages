#let is-2d-arg(mat) = {
  for arr in mat {
    if type(arr) == "array" {
      return true
    }
  }
  false
}

#let nat(..args) = {
  let pos-args = args.pos()
  // same as \mathstrut in LaTeX.
  let strut = context {
    let width = measure($\($).width
    [#hide($\($)#h(-width)]
  }
  let res = for line in pos-args {
    if type(line) == "array" {
      let res = for elem in line {
        ([#elem#strut],)
      }
      (res,)
    } else {
      ([#line#strut],)
    }
  }
  set math.mat(row-gap: 0.1em, column-gap: 1em)
  math.mat(..res, ..args.named())
}

#let bnat = nat.with(delim: "[")
#let pnat = nat.with(delim: "(")
#let Bnat = nat.with(delim: "{")
#let vnat = nat.with(delim: "|")
#let Vnat = nat.with(delim: "||")
