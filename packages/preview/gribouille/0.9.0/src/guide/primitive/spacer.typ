///! Blank depth, for aligning one guide against another.
///!
///! Draws nothing and reserves a fixed thickness. A stack uses it to line a
///! guide up with a neighbour that carries a part it does not.
///!
///! An `owed` spacer takes its room only when the rest of the stack takes some.
///! That is the gap an axis holds its labels off the panel edge by: it belongs
///! to the band as a whole, so an axis with ticks and no labels still reserves
///! it, one with labels and no ticks still draws into it, and a stripped axis
///! reserves nothing at all. The composition decides it, because only the
///! composition can see whether anything else in the stack drew.

#import "../../utils/errors.typ": check, fail-type
#import "common.typ": measured, primitive

#let prim-spacer(space, owed: false) = {
  if type(space) not in (int, float) {
    fail-type("guide-spacer", "space", space, "a number of centimetres")
  }
  // A negative spacer would shrink the band a stack computes rather than pad
  // it, so it fails here rather than quietly eating a neighbour's room.
  check(
    space >= 0,
    "guide-spacer",
    "space cannot be negative; got " + repr(space),
    hint: "Use a positive number of centimetres, or drop the spacer.",
  )
  primitive("spacer", entries: (), space: space * 1.0, owed: owed)
}

// An owed spacer is measured as its full space here and dropped by the
// composition when nothing else in the stack reserved any. Measuring it as zero
// instead would hide it from a caller that measures one on its own.
#let measure(prim, gctx, entries: auto) = measured(across: prim.space)

// Blank by construction.
#let draw(prim, gctx, entries: auto) = {}
