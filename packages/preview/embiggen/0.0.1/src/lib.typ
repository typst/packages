// This is an implementation of some basic LaTeX primitives as Typst functions
// See https://github.com/typst/typst/issues/4048 for this package's motivation

// Functional exponential growth and decay scale factor calculation
#let _embiggen_size_mult = 125%
#let _embiggen_inv_size_mult = 80%
#let _embiggen_comp_size(n, mult) = {
  if n == 1 {
    mult
  } else {
    mult * _embiggen_comp_size(n - 1, mult)
  }
}
#let _embiggen_enlarge(n) = _embiggen_comp_size(n, _embiggen_size_mult)
#let _embiggen_shrink(n) = _embiggen_comp_size(n, _embiggen_inv_size_mult)

// Your standard LaTeX modifiers, but they act on the output of #lr(...)
#let big(it) = {
  math.lr(it, size: _embiggen_enlarge(1))
}

#let Big(it) = {
  math.lr(it, size: _embiggen_enlarge(2))
}

#let bigg(it) = {
  math.lr(it, size: _embiggen_enlarge(3))
}

#let Bigg(it) = {
  math.lr(it, size: _embiggen_enlarge(4))
}

// Like big, Big, etc. but smaller
#let small(it) = {
  math.lr(it, size: _embiggen_shrink(1))
}

#let Small(it) = {
  math.lr(it, size: _embiggen_shrink(2))
}

#let smalll(it) = {
  math.lr(it, size: _embiggen_shrink(3))
}

#let Smalll(it) = {
  math.lr(it, size: _embiggen_shrink(4))
}
