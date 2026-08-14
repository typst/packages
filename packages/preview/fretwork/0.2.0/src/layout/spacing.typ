// Horizontal spacing: how much room each event and each measure wants.
//
// Spacing is optical rather than proportional. A whole note lasts eight times
// as long as an eighth but is nowhere near eight times as wide on the page —
// engravers have always compressed the relationship, and `spacing-exponent`
// (0.6 by default) is that compression. Proportional spacing would leave long
// notes stranded in white space and cram fast passages together.
//
// The functions here are pure: glyph widths are measured by the caller, which
// is what keeps the packing logic testable without a layout context.

#import "../rational.typ" as r
#import "../model.typ": sounding-duration

/// Natural width of one event.
///
/// `glyph-width` is the total width the event's fret numbers occupy, including
/// any linked hammer-on or slide target, so a `12` claims more room than a `0`
/// and `5h7` more than either.
///
/// An event with no duration — an ASCII tab imported without rhythm — falls
/// back to the width of a quarter, optionally stretched by `column-span` so that
/// the source's own column positions still shape the result.
#let event-natural(theme, ev, glyph-width) = {
  // A grace note is spaced as the ornament it is: narrow and the same width
  // whatever value it is written with, since it is squeezed into its
  // neighbour's time rather than given any of its own. Spacing it from its
  // note value would hand a grace quarter the room of a real one.
  if ev.at("grace", default: none) != none {
    return calc.max(theme.quarter-width * 0.45, glyph-width + theme.min-event-gap * 0.6)
  }
  let d = sounding-duration(ev)
  let base = if d == none {
    let span = ev.at("column-span", default: none)
    if span == none { theme.quarter-width } else { theme.quarter-width * span }
  } else {
    theme.quarter-width * calc.pow(r.to-float(d) * 4.0, theme.spacing-exponent)
  }
  calc.max(base, glyph-width + theme.min-event-gap)
}

/// The width a measure claims, given the widths of its events.
///
/// Shared so that a pass which widens events afterwards — the lyric one does —
/// rebuilds the total the same way it was built.
#let measure-total(theme, widths) = (
  widths.fold(0pt, (a, b) => a + b) + 2 * theme.measure-padding
)

/// Natural widths for every event in a measure, plus the measure total.
///
/// `glyph-widths` is one `(total, anchor)` pair per event, in order: `total` is
/// the width of everything the event prints, `anchor` the width of the number
/// the event is aligned on.
#let measure-natural(theme, measure, glyph-widths) = {
  let widths = measure.events.enumerate().map(((i, ev)) => event-natural(
    theme,
    ev,
    glyph-widths.at(i, default: (total: 0pt, anchor: 0pt)).total,
  ))
  (events: widths, total: measure-total(theme, widths))
}

/// Cap height of one time-signature numeral.
///
/// Measured off the published sheet in `research/TNT_0001.png`, where the pair
/// spans 1.18 to 3.71 staff spaces on a six-string staff: each numeral is 1.22
/// spaces tall, and the two nearly touch at the staff's middle. That is a
/// constant in staff spaces rather than a fraction of the staff, so a bass tab
/// prints the same size of signature as a guitar one and merely fills more of
/// its shorter staff. The clamp only bites on a staff too short to hold it.
#let meter-cap(theme, strings) = {
  let h = (strings - 1) * theme.staff-space
  calc.min(1.22 * theme.staff-space, h / 2 * 0.92)
}

/// Whether a measure prints a time signature.
///
/// Printed where it changes, and at the start of the piece — the convention a
/// clef does not follow. Repeating it on every system would be a reminder the
/// reader has not asked for, since unlike a clef it does not affect how the
/// notes in front of them are read.
#let prints-meter(measure, first) = first or measure.time != none

/// Width claimed by a printed time signature, or zero where none is printed.
///
/// The same sheet leaves about 1.3 staff spaces of air on either side of the
/// numerals. The drawn ones are measured and centred within this, so the
/// estimate here only has to be close and a shade generous — a hair of extra
/// air beats a numeral touching the first fret number.
#let meter-allowance(theme, strings, measure, time, first) = {
  if time == none or not prints-meter(measure, first) { return 0pt }
  let digits = calc.max(str(time.at(0)).len(), str(time.at(1)).len())
  digits * 0.86 * meter-cap(theme, strings) + 1.8 * theme.staff-space
}

/// Extra width claimed by a measure's opening and closing barlines.
///
/// Repeat signs are wide, and a system whose measures all carry them must make
/// room or the music is squeezed.
#let barline-allowance(theme, measure) = {
  let sp = theme.staff-space
  let left = if measure.start-repeat { 1.1 * sp } else { 0pt }
  let right = if measure.end-repeat {
    1.1 * sp
  } else if measure.end == "final" { 0.6 * sp } else if measure.end == "double" {
    0.35 * sp
  } else { 0pt }
  left + right
}
