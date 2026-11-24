// What a time signature says about grouping: where the beats fall, and where a
// beam is allowed to end.
//
// Kept apart from `beams.typ` because it is knowledge about metre rather than
// about note values, and apart from `render/meter.typ`, which draws the numerals
// and knows nothing of what they mean.
//
// The rules are Gould's, *Behind Bars* p. 153, cross-checked against LilyPond's
// `time-signature-settings.scm` and against the published sheets in `research/`.

#import "../rational.typ" as r

/// The rhythmic unit a metre counts in, as a rational.
///
/// Simple metres beat in their own unit: a quarter in 4/4, an eighth in 3/8.
/// Compound metres — 6/8, 9/8, 12/8 — beat in the dotted value of three.
#let beat-unit(time) = {
  if time == none { return none }
  let (beats, unit) = time
  let compound = unit >= 8 and calc.rem(beats, 3) == 0 and beats > 3
  if compound { r.rat(3, den: unit) } else { r.rat(1, den: unit) }
}

/// Beats that are not all the same length, counted in beat units.
///
/// Only the irregular metres need an entry. Everywhere else the bar is a whole
/// number of equal beats, which is what `beat-structure` works out for itself.
#let _STRUCTURES = (
  "4/8": (2, 2),
  "5/8": (3, 2),
  "7/8": (2, 2, 3),
)

/// The beats of one bar, as an array of rationals summing to its length.
///
/// ```typc
/// assert.eq(beat-structure((4, 4)).len(), 4) // four quarters
/// assert.eq(beat-structure((6, 8)).len(), 2) // two dotted quarters
/// assert.eq(beat-structure((5, 8)).len(), 2) // three eighths, then two
/// ```
#let beat-structure(time) = {
  if time == none { return () }
  let (beats, den) = time
  let unit = beat-unit(time)
  let counts = _STRUCTURES.at(str(beats) + "/" + str(den), default: none)
  if counts == none {
    // Equal beats: the bar holds a whole number of them, since `beat-unit`
    // returns the dotted beat exactly where the unit would not divide the bar.
    counts = range(r.div(r.rat(beats, den: den), unit).num).map(_ => 1)
  }
  counts.map(c => r.scale(unit, c, 1))
}

/// Beaming that departs from the beat, keyed by metre and then by note value.
///
/// The counts are in the note value of their key, so 4/4's `(4, 4)` beams
/// eighths into half-bars. A value with no entry of its own follows
/// `beat-structure` instead — which is why sixteenths in 4/4 still group by the
/// quarter while eighths no longer do.
///
/// From Gould p. 153: quavers in 4/4 may be beamed into half-bars, but never
/// across the middle of the bar, which carries a secondary stress; 2/4, 3/4 and
/// 3/8 may beam a whole bar of quavers; and in 2/2 the values shorter than the
/// beat group by the quarter rather than by the minim they are counted in.
#let _EXCEPTIONS = (
  "2/4": ("1/8": (4,)),
  "3/4": ("1/8": (6,)),
  "4/4": ("1/8": (4, 4)),
  "3/8": ("1/8": (3,)),
  "2/2": ("1/16": (4, 4, 4, 4), "1/32": (8, 8, 8, 8)),
)

/// Where a beam of `value` notes may end, as positions from the start of the bar.
///
/// The bar's own end is the last of them, and the start is not one: a group ends
/// at a boundary, it does not have to begin at one.
///
/// ```typc
/// // Eighths in 4/4 end at the half-bar and nowhere else inside it.
/// assert.eq(beam-boundaries((4, 4), r.rat(1, den: 8)), (r.rat(1, den: 2), r.rat(1)))
/// // Sixteenths have no exception of their own, so they end on every beat.
/// assert.eq(beam-boundaries((4, 4), r.rat(1, den: 16)).len(), 4)
/// ```
#let beam-boundaries(time, value) = {
  if time == none or value == none { return () }
  let (beats, den) = time
  let exception = _EXCEPTIONS
    .at(str(beats) + "/" + str(den), default: (:))
    .at(r.str-of(value), default: none)

  let lengths = if exception == none {
    beat-structure(time)
  } else {
    exception.map(count => r.scale(value, count, 1))
  }

  let at = r.zero
  let bounds = ()
  for length in lengths {
    at = r.add(at, length)
    bounds.push(at)
  }
  bounds
}
