// =========================================================================
// CAS Shared Helpers
// =========================================================================
// Cross-module utility helpers to avoid repeating common checks and
// coefficient/candidate generation logic.
// =========================================================================

#import "core/int-math.typ": int-factors as _int-factors-core

/// Public helper `check-free-var`.
#let check-free-var(v) = {
  if v == "i" {
    panic("Variable name \"i\" is reserved for imaginary unit support.")
  }
}

/// Public helper `check-free-vars`.
#let check-free-vars(..vars) = {
  for vv in vars.pos() {
    check-free-var(vv)
  }
}

/// Public helper `int-factors`.
#let int-factors(n) = _int-factors-core(n)
