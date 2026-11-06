// Dynamics and their gradual changes, drawn below the staff.
//
// Below, because that is where every engraved sheet puts them and because the
// space above is already crowded: palm mutes, bends, harmonics and the rhythm
// all live up there, and a dynamic has nothing to do with any of them.
//
// The mark machinery is shared with the technique lane — see `marks.typ` —
// including the sideways packing, so `cresc.` in one bar and `dim.` in another
// share a row rather than stacking.

#import "marks.typ"
#import "marks.typ": label, span-mark, span-names, span-runs

/// Group names that draw as a gradual change in loudness.
///
/// The dotted-line form rather than a hairpin: with no notation staff there is
/// no pair of staves for a hairpin to sit between, and the reference sheets
/// this package follows write the word out in tablature too.
#let HAIRPIN-LABELS = (
  cresc: "cresc.",
  dim: "dim.",
  decresc: "decresc.",
)

/// Dynamics are set in bold italic, the way every engraver sets them — which is
/// also what keeps `f` from being read as a playing instruction.
#let _dynamic-label(theme, word) = text(
  font: theme.font,
  size: theme.technique-size * 1.15,
  weight: 700,
  style: "italic",
  fill: theme.color,
  top-edge: "cap-height",
  bottom-edge: "baseline",
  word,
)

/// Every mark the lane has to place, grouped by kind.
///
/// Closest-to-the-staff first, which here means the dynamics themselves before
/// the gradual changes: a `cresc.` runs from one dynamic to the next, so it
/// belongs on the far side of both.
///
/// Must be called from a context: labels are measured.
#let _marks(theme, system) = {
  let sp = theme.staff-space
  let placed = marks.flatten(system)
  let groups = ()

  let levels = ()
  for pe in placed {
    let word = pe.event.at("dynamic", default: none)
    if word == none { continue }
    let body = _dynamic-label(theme, word)
    let x = pe.x - measure(body).width / 2
    levels.push((
      x0: x,
      x1: x + measure(body).width,
      height: theme.technique-size * 1.5,
      draw: y => place(top + left, dx: x, dy: y, body),
    ))
  }
  if levels.len() > 0 { groups.push(levels) }

  let hairpins = ()
  for name in span-names(placed) {
    if name not in HAIRPIN-LABELS { continue }
    let body = label(theme, HAIRPIN-LABELS.at(name), italic: true)
    for run in span-runs(placed, name) {
      // The closing tick turns back up towards the music, this lane being
      // under it rather than over.
      hairpins.push(span-mark(theme, run, body, tick: "up"))
    }
  }
  if hairpins.len() > 0 { groups.push(hairpins) }

  groups
}

/// The dynamics lane, collapsing when nothing needs it.
///
/// `inward: "top"` because this lane hangs below the staff: level 0 is the row
/// nearest it, so the stack grows downwards rather than up.
#let lane-for(theme, system, width) = marks.lane-of(
  theme,
  system,
  width,
  _marks,
  inward: "top",
)
