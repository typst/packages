///! The stack a cartesian axis is.
///!
///! An axis is a spine, a tick row, one or more label rows, and a title, laid
///! out away from the panel edge in that order. Every one of those is already a
///! primitive, so this module only says which parts an axis has and what
///! separates them.
///!
///! Two gaps are not spacing between neighbours but room the axis has always
///! owed, so they are spacers rather than a `spacing:` on the stack:
///!
///! - The band gap holds the labels off the panel edge. It is owed whenever the
///!   ticks or the labels reserve anything, which is why it is an owed spacer
///!   rather than spacing between two neighbours. An axis with ticks and no
///!   labels has always reserved it, and an axis with labels and no ticks has
///!   always drawn into it.
///! - The title gap and the edge pad come from the title's own theme surface, so
///!   the caller resolves them and hands them in.
///!
///! Nothing is measured here. The render stage stamps the label extents on the
///! entries and the title extent on the title, exactly as the legend builders
///! do, so the axis a panel reserves and the axis it draws come from one record.

#import "../utils/errors.typ": check, fail-type
#import "compose.typ": compose-stack, train
#import "primitive/labels.typ": prim-labels
#import "primitive/line.typ": prim-line
#import "primitive/spacer.typ": prim-spacer
#import "primitive/ticks.typ": prim-ticks
#import "primitive/title.typ": prim-title

// One label row of an axis: its rotation and how many rows it dodges over. A
// plain axis has one; a `guide-axis-stack` has one per sub-guide.
#let axis-row(angle: 0, n-dodge: 1) = (angle: angle, n-dodge: n-dodge)

// The parts of an axis, in the order they leave the panel.
//
// `line` draws the spine along the panel edge. It reserves nothing either way,
// so a caller whose panel draws its own edge turns it off.
//
// `band-gap` is the gap that holds the band off the panel edge, owed whenever
// the ticks or the labels reserve anything. `tiers` are the tick weights the
// axis draws, `stack-gap` separates the label rows of a stacked axis, and the
// three title numbers are the gap before the title, the box it lands in, and
// the pad past it.
#let axis-node(
  entries: (),
  rows: (),
  line: true,
  tiers: ("major",),
  band-gap: 0.0,
  stack-gap: 0.0,
  dodge-gap: auto,
  title: none,
  title-extent: (0.0, 0.0),
  title-gap: 0.0,
  title-pad: 0.0,
  title-align: none,
  title-angle: 0,
) = {
  check(
    type(rows) == array,
    "guide-axis",
    "rows must be an array of label rows; got " + repr(rows),
    hint: "Build each with `axis-row`, one per sub-guide of the axis.",
  )
  for (i, row) in rows.enumerate() {
    if type(row) != dictionary or ("angle", "n-dodge").any(k => k not in row) {
      fail-type(
        "guide-axis",
        "row " + str(i),
        row,
        "a row carrying `angle` and `n-dodge`",
        hint: "Build each with `axis-row`.",
      )
    }
  }
  let label-parts = ()
  for (i, row) in rows.enumerate() {
    if i > 0 and stack-gap > 0 {
      label-parts.push(prim-spacer(stack-gap))
    }
    label-parts.push(
      prim-labels(
        angle: row.angle,
        n-dodge: row.n-dodge,
        dodge-gap: dodge-gap,
      ),
    )
  }
  // A title that measures nothing reserves neither its gap nor its pad, which
  // is the gate the chrome stage applies through the title's own surface: a
  // blanked `axis-title` would otherwise push the panel in by two gaps around
  // ink that never draws.
  let titled = (
    title != none
      and (
        title-extent.at(0) > 0.0 or title-extent.at(1) > 0.0
      )
  )
  let title-parts = if not titled { () } else {
    (
      ..if title-gap > 0 { (prim-spacer(title-gap),) } else { () },
      prim-title(
        title,
        align: title-align,
        extent: title-extent,
        angle: title-angle,
      ),
      ..if title-pad > 0 { (prim-spacer(title-pad),) } else { () },
    )
  }
  // The table is pushed down to the parts that read it here, because the
  // measure and the draw each take a child's own entries rather than the
  // parent's.
  train(compose-stack(
    // The spine adds no depth, so an axis whose panel already draws its own
    // leaves it out rather than drawing it twice.
    ..if line { (prim-line(),) } else { () },
    prim-ticks(tiers: tiers),
    // The gap belongs to the band rather than to a pair of neighbours: an axis
    // that draws ticks and no labels still reserves it, one that draws labels
    // and no ticks still draws into it, and a stripped axis reserves none of it.
    // The composition decides that, because only it can see what the parts
    // measured.
    ..if band-gap > 0 { (prim-spacer(band-gap, owed: true),) } else { () },
    ..label-parts,
    ..title-parts,
    entries: entries,
    // Every gap an axis owes is a spacer of its own, resolved from the band or
    // from the title's surface, so the stack itself separates nothing.
    spacing: 0.0,
  ))
}
