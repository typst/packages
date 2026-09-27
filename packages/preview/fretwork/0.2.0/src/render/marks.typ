// The machinery every lane of small marks is built from.
//
// A *mark* is `(x0, x1, height, draw: y => content)`: the horizontal room it
// needs, and how to draw itself given a top edge. `_marks` in a lane module
// returns them grouped by kind, ordered by how close to the staff the kind
// wants to sit, and everything here is indifferent to what they actually are.
//
// Two lanes are built on it — the techniques above the staff and the dynamics
// below — and they share it rather than each growing their own copy, because
// the packing rule is the interesting part and there should be one of it.

#import "../layout/lanes.typ": empty-lane, lane

/// Vertical clearance between two levels of marks.
#let LEVEL-GAP = 0.15

/// All events of a system in one list, with their x-positions.
///
/// Flattened across measures on purpose: a palm mute bracket runs from where it
/// starts to where it stops, and barlines do not interrupt it.
#let flatten(system) = system.measures.map(m => m.events).flatten()

/// Maximal runs of consecutive events carrying the given span.
#let span-runs(placed, name) = {
  let runs = ()
  let current = ()
  for pe in placed {
    if name in pe.event.spans {
      current.push(pe)
    } else {
      if current.len() > 0 { runs.push(current) }
      current = ()
    }
  }
  if current.len() > 0 { runs.push(current) }
  runs
}

/// Every span name used anywhere in the system, in first-seen order.
#let span-names(placed) = {
  let names = ()
  for pe in placed {
    for s in pe.event.spans {
      if s not in names { names.push(s) }
    }
  }
  names
}

/// A short label, set in the technique face.
#let label(theme, body, italic: false) = text(
  font: theme.font,
  size: theme.technique-size,
  style: if italic { "italic" } else { "normal" },
  fill: theme.color,
  top-edge: "cap-height",
  bottom-edge: "baseline",
  body,
)

/// One bracketed span: a label, then a dashed rule to the end of its run.
///
/// The rule is closed by a tick that *crosses* it rather than merely hanging
/// off it, and meets the label near its baseline rather than at its cap. Dash
/// and gap are each about a third of a staff space.
///
/// `tick` is which way the closing tick points relative to the rule: `"down"`
/// for a mark above the staff, `"up"` for one below, so in both cases it turns
/// back towards the music.
///
/// Must be called from a context: the label is measured.
#let span-mark(theme, run, body, tick: "down") = {
  let sp = theme.staff-space
  let label-w = measure(body).width
  let x0 = run.first().x - 0.2 * sp
  let x1 = run.last().x + 0.3 * sp
  let rule-x = x0 + label-w + 0.3 * sp
  (
    x0: x0,
    x1: calc.max(x1, rule-x),
    height: 1.15 * sp,
    draw: y => {
      place(top + left, dx: x0, dy: y, body)
      if x1 <= rule-x { return }
      let rule-y = y + 0.5 * sp
      place(top + left, dx: rule-x, dy: rule-y, line(
        length: x1 - rule-x,
        stroke: (
          paint: theme.color,
          thickness: 0.07 * sp,
          dash: (array: (0.30 * sp, 0.30 * sp), phase: 0pt),
        ),
      ))
      place(
        top + left,
        dx: x1,
        dy: rule-y - (if tick == "down" { 0.28 * sp } else { 0.77 * sp }),
        line(angle: 90deg, length: 1.05 * sp, stroke: (paint: theme.color, thickness: 0.07 * sp)),
      )
    },
  )
}

/// Pack groups of marks into as few levels as the horizontal room allows.
///
/// Published sheets pack sideways: a mark sits as close to the staff as it fits,
/// and things only stack where they are actually in each other's way. Reserving
/// a level per kind for the whole system instead makes a system taller than it
/// needs to be whenever two marks are in different bars.
///
/// A whole group moves together, so every palm mute in a system stays at one
/// height. Groups are offered the levels in the order they arrive in, so when
/// two do collide the closer-to-the-staff kind wins the lower level.
///
/// `pad` is the least horizontal air between two marks sharing a level; without
/// it, two that merely fit end up touching.
#let pack(groups, pad) = {
  let levels = ()
  for group in groups {
    let target = none
    for (i, level) in levels.enumerate() {
      let clear = group.all(m => level.all(o => m.x1 + pad <= o.x0 or m.x0 >= o.x1 + pad))
      if clear {
        target = i
        break
      }
    }
    if target == none {
      levels.push(group)
    } else {
      levels.at(target) = levels.at(target) + group
    }
  }
  levels
}

/// The levels of a system, each with the height it needs.
#let levels-of(theme, system, marks) = {
  pack(marks(theme, flatten(system)), 0.35 * theme.staff-space).map(level => (
    marks: level,
    height: level.fold(0pt, (acc, m) => calc.max(acc, m.height)),
  ))
}

/// Total height of a stack of levels.
#let stack-height(theme, levels) = {
  if levels.len() == 0 { return 0pt }
  let gap = LEVEL-GAP * theme.staff-space
  levels.fold(0pt, (acc, l) => acc + l.height) + gap * (levels.len() - 1)
}

/// Draw a stack of levels into a box of exactly its own height.
///
/// `inward` names which edge of the lane is nearest the staff, since level 0
/// belongs against it: `"bottom"` for a lane above the staff, `"top"` for one
/// below.
#let draw-levels(theme, levels, width, inward: "bottom") = {
  let total = stack-height(theme, levels)
  if levels.len() == 0 { return box(width: width, height: 0pt) }
  let gap = LEVEL-GAP * theme.staff-space

  box(width: width, height: total, {
    let edge = if inward == "bottom" { total } else { 0pt }
    for level in levels {
      let y = if inward == "bottom" { edge - level.height } else { edge }
      for m in level.marks {
        (m.draw)(y)
      }
      edge = if inward == "bottom" { y - gap } else { y + level.height + gap }
    }
  })
}

/// A whole lane, collapsing to nothing when no mark needs it.
///
/// The levels are packed once here and handed to the drawing closure, rather
/// than worked out again when it runs.
#let lane-of(theme, system, width, marks, inward: "bottom") = {
  let levels = levels-of(theme, system, marks)
  if levels.len() == 0 { return empty-lane }
  lane(stack-height(theme, levels), () => draw-levels(theme, levels, width, inward: inward))
}
