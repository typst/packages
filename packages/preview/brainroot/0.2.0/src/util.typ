// Shared helpers.

// A length in pt as a plain number, for the hand-drawn geometry.
#let _pt(l) = if type(l) == length { l.pt() } else { float(l) }

// Perceived luminance of a colour, 0 dark to 1 light.
#let _luma(c) = {
  let (r, g, b, ..) = rgb(c).components().map(v => v / 100%)
  0.299 * r + 0.587 * g + 0.114 * b
}

// Lays `over` on top of `base`, field by field and into nested
// dictionaries. Every field of `over` has to exist in `base`: a misspelt
// option is an error, not a silently ignored one. `nested` names the
// fields whose value is a dictionary merged in turn; the rest replace.
#let _merge(base, over, what, nested: ()) = {
  for (k, v) in over {
    assert(k in base, message: "brainroot: " + what + " has no field \"" + k + "\"; the fields are " + base.keys().join(", "))
    if k in nested and type(v) == dictionary {
      let b = base.at(k)
      base.insert(k, if type(b) == dictionary { _merge(b, v, what + "." + k) } else { v })
    } else {
      base.insert(k, v)
    }
  }
  base
}
