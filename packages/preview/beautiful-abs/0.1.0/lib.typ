#let __HALF_SPACE_SIZE = 0.16667em

#let __half-space() = {
  h(__HALF_SPACE_SIZE)
}

#let __join-values(letters) = {
  return letters.join(__half-space())
}

#let customab = __join-values

// Latin
#let eg = __join-values(("e.", "g."))
#let etal = __join-values(("et", "al."))
#let ie = __join-values(("i.", "e."))
#let perse = __join-values(("per", "se"))
#let qed = __join-values(("q.", "e.", "d."))

// English
#let aka = __join-values(("a.", "k.", "a."))
#let st = __join-values(("s.", "t."))
#let wrt = __join-values(("w.", "r.", "t."))

// German
#let dh = __join-values(("d.", "h."))
#let ua = __join-values(("u.", "a."))
#let zb = __join-values(("z.", "B."))

// French
#let pex = __join-values(("p.", "ex."))


