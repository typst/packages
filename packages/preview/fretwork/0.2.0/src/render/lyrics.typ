// The lyric lanes: one per verse, at the foot of the system.
//
// A syllable is centred on the event it is sung on, exactly as the fret number
// above it is, and an event with nothing to sing is simply left blank. That is
// the layout the reference sheets use — the syllables ride on the guitar's own
// rhythm rather than carrying one of their own, which is also the only layout
// a single stream of events can express.
//
// A word held across several notes is written once, where it starts, with
// nothing trailing it: no extension line, because the sheets draw none. A word
// broken in two carries a hyphen, and the hyphen is its own character centred
// in the gap between the syllables rather than tucked against the first.

#import "../layout/lanes.typ": empty-lane, lane

/// The syllable a verse sings at an event, or `none`.
#let syllable-at(ev, verse) = ev.at("lyrics", default: ()).at(verse, default: none)

/// How many verses a part carries.
#let verse-count(part) = {
  let n = 0
  for m in part.measures {
    for ev in m.events {
      n = calc.max(n, ev.at("lyrics", default: ()).len())
    }
  }
  n
}

/// A syllable, set for measurement and for drawing.
#let label(theme, body) = text(
  font: theme.lyric-font,
  size: theme.lyric-size,
  fill: theme.color,
  body,
)

/// The widest syllable an event sings, across every verse.
///
/// This is what the spacing engine reserves room for, so it is measured once
/// here and used both there and when drawing.
///
/// Must be called from a context, since it measures type.
#let event-width(theme, ev) = {
  let widths = ev
    .at("lyrics", default: ())
    .filter(s => s != none)
    .map(s => measure(label(theme, s.text)).width)
  widths.fold(0pt, calc.max)
}

/// Height of one verse's lane.
///
/// Measured from a string with both an ascender and a descender rather than
/// from the type size, so a syllable ending in `g` cannot hang into whatever
/// the next lane draws.
#let height(theme) = measure(label(theme, "Hgy")).height

/// Draw one verse for a placed system.
#let draw(theme, system, width, verse) = {
  let placed = system.measures.map(m => m.events).flatten()

  box(width: width, height: height(theme), {
    for (i, pe) in placed.enumerate() {
      let s = syllable-at(pe.event, verse)
      if s == none { continue }
      let body = label(theme, s.text)
      let size = measure(body)
      place(top + left, dx: pe.x - size.width / 2, dy: 0pt, body)
      if not s.hyphen { continue }

      // The hyphen belongs to the word rather than to either syllable, so it is
      // centred between them. A word whose second half falls on the next system
      // gets none: there is no gap on this one to centre it in.
      let next = none
      for j in range(i + 1, placed.len()) {
        let later = syllable-at(placed.at(j).event, verse)
        if later == none { continue }
        next = (x: placed.at(j).x, width: measure(label(theme, later.text)).width)
        break
      }
      if next == none { continue }
      let from = pe.x + size.width / 2
      let to = next.x - next.width / 2
      let dash = label(theme, "-")
      let dash-size = measure(dash)
      // Nothing to centre in when the two syllables already touch.
      if to - from < dash-size.width { continue }
      place(top + left, dx: (from + to - dash-size.width) / 2, dy: 0pt, dash)
    }
  })
}

/// One verse's lane, or an empty lane when it sings nothing on this system.
#let lane-for(theme, system, width, verse) = {
  let sung = system.measures.any(m => m.events.any(pe => syllable-at(pe.event, verse) != none))
  if not sung { return empty-lane }
  lane(height(theme), () => draw(theme, system, width, verse))
}
