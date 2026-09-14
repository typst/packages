// Vertical layout: a system is a stack of lanes.
//
// A lane is `(height: length, draw: () => content)`. Chord names, rhythm stems,
// the tab staff and the count row are each one lane, and a lane with no content
// declares zero height and disappears. Every lane draws against the same
// x-positions, which is what keeps them in vertical alignment.
//
// Adding a notation staff in a later phase means adding one more lane to this
// list; nothing else in the vertical layout has to change.

/// Build a lane, collapsing it when it has nothing to show.
#let lane(height, draw) = (height: height, draw: draw)

/// The empty lane, which takes no vertical space.
#let empty-lane = lane(0pt, () => none)

/// Stack lanes top to bottom into one block of known height.
#let stack-lanes(lanes, width, gap) = {
  let visible = lanes.filter(l => l.height > 0pt)
  if visible.len() == 0 { return box(width: width, height: 0pt) }

  let total = visible.fold(0pt, (acc, l) => acc + l.height) + gap * (visible.len() - 1)
  box(width: width, height: total, {
    let y = 0pt
    for l in visible {
      // Parenthesised because a function stored in a dictionary field cannot be
      // called directly through the field access.
      place(top + left, dx: 0pt, dy: y, (l.draw)())
      y += l.height + gap
    }
  })
}
