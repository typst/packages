// The rhythm lane: stems, beams, stubs and the count row.
//
// Rests are not here: they are drawn inside the staff, where they take the
// place of a note rather than describing one.
//
// The lane sits *below* the staff, and its values are bars rather than
// noteheads with stems: a beam along the bottom, with stems rising from it
// towards the music above. There is no notation staff to hang a notehead on, so
// the length of the stem carries the value instead — a quarter is a bare stem,
// a half is that same stem cut in two from the same foot, and a whole note is
// not written at all. That last one is not an omission: a bar of whole notes
// produces no lane, which is why `_has-rhythm` asks what would be *drawn*
// rather than what has a duration.
//
// The half's stem being exactly half a quarter's is the one proportion here
// that is structural rather than stylistic — it is the whole of what
// distinguishes the two values — so it lives in this file and not in
// `theme.typ`.

#import "../rational.typ" as r
#import "../model.typ": sounding-duration
#import "../layout/beams.typ": dots-of, flags-of, group-beams, sub-beams, tuplet-runs
#import "../layout/lanes.typ": empty-lane, lane
#import "glyphs.typ" as g

/// Whether an event puts anything in the lane.
///
/// Rests are excluded because they are not drawn here at all — they carry their
/// own duration inside the staff. So are whole notes and anything longer, which
/// this notation leaves unwritten; a bar of them must produce an empty lane
/// rather than a band of white space. A grace note is drawn whether or not a
/// note value is in force, being an ornament rather than a measured beat.
#let _draws(ev) = {
  if ev.at("grace", default: none) != none and ev.kind != "rest" { return true }
  if ev.kind == "rest" { return false }
  let flags = flags-of(ev)
  flags != none and flags > -2
}

/// Whether the lane has anything to draw at all.
#let _has-rhythm(system) = system.measures.any(m => m.events.any(pe => _draws(pe.event)))

/// Whether the system contains a tuplet, which needs room for its bracket.
#let _has-tuplet(system) = system.measures.any(m => m.events.any(pe => pe.event.tuplet != none))

/// Room reserved below the beam for a tuplet bracket and its numeral.
#let _TUPLET-ROOM = 1.2

/// How far a beam stub reaches from the stem it belongs to, in staff spaces.
#let _STUB = 0.8

/// Where an augmentation square sits beside the stem, and how far apart two of
/// them stand, in staff spaces. Both measured off the reference outlines, where
/// the square is exactly a beam thick and two of them leave a beam's air.
#let _DOT-OFFSET = 0.36
#let _DOT-PITCH = 0.57

/// A tremolo slash, in staff spaces, read off the reference outline.
///
/// `top` is how far below the stem's top the first one is centred, and the rest
/// stack downwards from there — one, two or three of them all start at the same
/// height, so hanging them from the top is the rule rather than centring them.
///
/// The thickness is the number that matters: it is *half* a beam, not a whole
/// one. Three slashes at a beam's weight fuse into a block, which is what a
/// tremolo drawn that way looks like at any size.
#let _TREMOLO = (
  width: 0.78,
  thickness: 0.134,
  rise: 0.22,
  pitch: 0.26,
  top: 0.23,
)

/// Height of the rhythm lane.
///
/// Augmentation marks claim nothing: they sit in the slot above the beam stack,
/// which is inside the stem's own length.
#let height(theme, system) = {
  if not _has-rhythm(system) { return 0pt }
  let below = if _has-tuplet(system) { _TUPLET-ROOM * theme.staff-space } else { 0pt }
  theme.rhythm-clearance + theme.stem-length + below
}

#let _bar(theme, x, y, w, h) = place(
  top + left,
  dx: x,
  dy: y,
  rect(width: w, height: h, fill: theme.color, stroke: none),
)

// A grace note is drawn as a *miniature of a real value*: a short stem with a
// beam stub, never a flag. Read off Songsterr's own legend and confirmed in bar
// 4 of Heart-Shaped Box, where a lone one sits between ordinary stems — the
// ornament carries the same vocabulary as the values around it, only smaller.
//
// It hangs from the top of the lane instead of standing on the foot the real
// stems stand on, so its beam floats above the beam line. That is what keeps it
// clear of a half note, the other short stem in this notation: a half note's
// stem occupies the lower half of the lane and carries nothing, a grace note's
// the upper half and carries a stub. Measured against its neighbours in that
// bar, the whole mark runs about two fifths of a full stem.
//
// A stroke through the first stem marks the kind squeezed in ahead of the beat;
// one that starts *on* the beat is written plain, which is the distinction the
// two have carried since they were called acciaccatura and appoggiatura. It
// runs down to the right, as the reference draws it.
#let _GRACE-STEM = 0.45 // of a full stem
// Lighter than a real beam, but only a little: a real beam is a seventh of a
// stem now, and much below that an ornament's is a hairline.
#let _GRACE-BEAM = 0.8 // of the beam thickness
#let _GRACE-STUB = 0.55 // of a full stub

/// Maximal runs of consecutive grace events, as arrays of indices.
///
/// Grace notes are beamed to each other but never to the note they lean on:
/// beaming those two would say they share a beat, which is the one thing a
/// grace note does not do.
#let _grace-runs(events) = {
  let runs = ()
  let current = ()
  for (i, ev) in events.enumerate() {
    if ev.at("grace", default: none) != none and ev.kind != "rest" {
      current.push(i)
    } else {
      if current.len() > 0 { runs.push(current) }
      current = ()
    }
  }
  if current.len() > 0 { runs.push(current) }
  runs
}

/// Draw one run of grace notes: short stems hung from `head`, beamed together,
/// with a stroke through the first when they come ahead of the beat.
#let _grace-group(theme, xs, head, slashed) = {
  let sp = theme.staff-space
  let length = theme.stem-length * _GRACE-STEM
  let foot = head + length
  let weight = theme.stem * 0.8
  let thickness = theme.beam-thickness * _GRACE-BEAM

  for x in xs {
    place(top + left, dx: x - weight / 2, dy: head, rect(
      width: weight,
      height: length,
      fill: theme.color,
      stroke: none,
    ))
  }

  // A lone ornament gets a stub where a pair gets a beam, exactly as a lone
  // eighth does among real values.
  let x0 = xs.first()
  let x1 = if xs.len() > 1 { xs.last() } else { x0 + _GRACE-STUB * _STUB * sp }
  place(top + left, dx: x0 - weight / 2, dy: foot - thickness, rect(
    width: x1 - x0 + weight,
    height: thickness,
    fill: theme.color,
    stroke: none,
  ))

  if not slashed { return }
  place(top + left, dx: 0pt, dy: 0pt, curve(
    stroke: (paint: theme.color, thickness: theme.stem * 0.9, cap: "butt"),
    curve.move((x0 - 0.26 * sp, foot - 0.52 * sp)),
    curve.line((x0 + 0.30 * sp, foot + 0.06 * sp)),
  ))
}

/// The top of the `level`-th beam, counting the primary as 1.
///
/// Levels stack *upwards* from the primary, which is the lowest — a sixteenth
/// among eighths carries its second beam above the one it shares with them, not
/// below.
#let _beam-y(theme, foot, level) = (
  foot - theme.beam-thickness - (level - 1) * (theme.beam-thickness + theme.beam-gap)
)

/// The tuplet bracket: a rule under the beam with its ends turned up towards it
/// and the numeral set in a break at its centre.
#let _tuplet-bracket(theme, foot, x0, x1, count, width) = {
  let sp = theme.staff-space
  let y = foot + 0.45 * sp
  let hook = 0.32 * sp
  let mid = (x0 + x1) / 2
  let weight = theme.line * 1.4
  let numeral = text(
    font: theme.font,
    size: 0.95 * sp,
    weight: 600,
    style: "italic",
    fill: theme.color,
    // Pinned to the digit itself, so centring the box on the rule centres the
    // numeral on it.
    top-edge: "cap-height",
    bottom-edge: "baseline",
    str(count),
  )
  let size = measure(numeral)
  let half = size.width / 2 + 0.28 * sp
  let bar(x, w, h) = place(top + left, dx: x, dy: y, rect(
    width: w,
    height: h,
    fill: theme.color,
    stroke: none,
  ))

  // Both ends turn up towards the beam, and the rule stops short of the numeral
  // on either side. A bracket too narrow to leave a rule worth drawing prints
  // as the numeral between its two hooks, which is what an engraver does with a
  // triplet of sixteenths.
  place(top + left, dx: x0, dy: y - hook, rect(width: weight, height: hook, fill: theme.color))
  place(top + left, dx: x1, dy: y - hook, rect(width: weight, height: hook, fill: theme.color))
  if mid - half > x0 + 0.2 * sp {
    bar(x0, mid - half - x0, weight)
    bar(mid + half, x1 - mid - half, weight)
  }
  place(top + center, dx: mid - width / 2, dy: y + weight / 2 - size.height / 2, numeral)
}

/// Draw the rhythm for one placed system.
#let draw(theme, system, width) = {
  let sp = theme.staff-space
  // The staff is above, so the lane opens with the clearance under it and every
  // stem stands on one foot at the bottom, whatever its length. Anything a
  // tuplet or an augmentation mark needs comes after that foot, both being
  // drawn below the beam.
  let foot = theme.rhythm-clearance + theme.stem-length
  let h = height(theme, system)

  box(width: width, height: h, {
    for m in system.measures {
      let events = m.measure.events
      let groups = group-beams(events, m.time)
      let beamed = groups.filter(gr => gr.len() > 1).flatten()

      // Stems and stubs.
      for (i, pe) in m.events.enumerate() {
        let ev = pe.event
        let flags = flags-of(ev)

        // Grace notes are drawn a run at a time, below, since consecutive ones
        // are beamed to each other.
        if ev.at("grace", default: none) != none { continue }
        // A rest gets no stem. The rest glyph itself says how long the silence
        // is, and it is drawn inside the staff by `tabstaff.typ` — which is
        // where the published sheets put it, and where a reader looks for it,
        // since it takes the place of a note rather than describing one.
        // A whole note is written as nothing at all, by the same convention.
        if not _draws(ev) { continue }

        // The stem, standing on the foot: full length for a quarter and
        // shorter, half of it for a half note.
        let length = if flags == -1 { theme.stem-length / 2 } else { theme.stem-length }
        _bar(theme, pe.x - theme.stem / 2, foot - length, theme.stem, length)

        // An unbeamed eighth or shorter gets stubs rather than a flag — one per
        // level, stacked upwards from the beam line. A stub at the end of a
        // measure turns back into it instead of running at the barline.
        if flags >= 1 and not (i in beamed) {
          let rightward = i < m.events.len() - 1
          let x0 = if rightward { pe.x } else { pe.x - _STUB * sp }
          for level in range(1, flags + 1) {
            _bar(
              theme,
              x0 - theme.stem / 2,
              _beam-y(theme, foot, level),
              _STUB * sp + theme.stem,
              theme.beam-thickness,
            )
          }
        }
        // Tremolo picking: slashes across the stem, as many as the legend uses.
        // Hung from the *top* of the stem rather than centred on it, which is
        // what keeps them off the beam whatever the note value — the reference
        // sets one, two and three of them all starting at the same height.
        if ev.notes.any(n => n.techniques.any(t => t.kind == "tremolo")) {
          for k in range(3) {
            let sy = foot - length + (_TREMOLO.top + k * _TREMOLO.pitch) * sp
            place(top + left, dx: 0pt, dy: 0pt, curve(
              stroke: (
                paint: theme.color,
                thickness: _TREMOLO.thickness * sp,
                cap: "butt",
              ),
              curve.move((pe.x - _TREMOLO.width / 2 * sp, sy + _TREMOLO.rise / 2 * sp)),
              curve.line((pe.x + _TREMOLO.width / 2 * sp, sy - _TREMOLO.rise / 2 * sp)),
            ))
          }
        }
        // Augmentation marks: squares to the right of the stem, sitting in the
        // slot immediately above the beam stack — one slot per beam the note
        // carries, so a quarter's rests on the foot itself and a sixteenth's
        // clears both of its beams. That rule is the reference's, checked
        // against all five of its worked examples, and it is what a mark under
        // the foot was standing in for: a square is exactly a beam thick, so
        // anything drawn *on* the beam line disappears into it.
        let slot = theme.beam-thickness + theme.beam-gap
        for d in range(dots-of(ev)) {
          let dot = g.aug-square(theme.beam-thickness, fill: theme.color)
          place(
            top + left,
            dx: pe.x + _DOT-OFFSET * sp + d * _DOT-PITCH * sp,
            dy: foot - calc.max(flags, 0) * slot - dot.height,
            dot.body,
          )
        }
      }

      // Beams. The primary spans the whole group; each further level spans only
      // the runs fast enough to need it, so a sixteenth among eighths gets a
      // stub rather than a full beam.
      for group in groups.filter(gr => gr.len() > 1) {
        let deepest = group.map(i => flags-of(events.at(i))).fold(0, calc.max)
        for level in range(1, deepest + 1) {
          let y = _beam-y(theme, foot, level)
          for run in sub-beams(events, group, level) {
            let (x0, x1) = if run.len() > 1 {
              (m.events.at(run.first()).x, m.events.at(run.last()).x)
            } else {
              // A lone note at this level gets a stub, pointing back towards
              // the group it belongs to.
              let x = m.events.at(run.first()).x
              if run.first() == group.first() { (x, x + _STUB * sp) } else { (x - _STUB * sp, x) }
            }
            _bar(theme, x0 - theme.stem / 2, y, x1 - x0 + theme.stem, theme.beam-thickness)
          }
        }
      }

      // Grace notes, hung from the top of the lane and beamed run by run.
      for run in _grace-runs(events) {
        _grace-group(
          theme,
          run.map(i => m.events.at(i).x),
          theme.rhythm-clearance,
          events.at(run.first()).grace == "before",
        )
      }

      // Tuplet brackets, below the beam.
      for run in tuplet-runs(events, time: m.time) {
        if run.tuplet == none or run.indices.len() == 0 { continue }
        let xs = run.indices.map(i => m.events.at(i).x)
        _tuplet-bracket(theme, foot, xs.first(), xs.last(), run.tuplet.count, width)
      }
    }
  })
}

/// The rhythm lane, or an empty lane when the music carries no note values.
#let lane-for(theme, system, width) = {
  if not _has-rhythm(system) { return empty-lane }
  lane(height(theme, system), () => draw(theme, system, width))
}

// ---------------------------------------------------------------------------
// Count row
// ---------------------------------------------------------------------------

#let _SUBDIVISIONS = (
  (r.rat(0), ""),
  (r.rat(1, den: 4), "e"),
  (r.rat(1, den: 2), "+"),
  (r.rat(3, den: 4), "a"),
)

/// The syllable counted at a position within a beat, or `none` if it falls
/// between the four subdivisions a player would actually count.
#let _syllable(offset, beat) = {
  let frac = r.div(offset, beat)
  for (at, name) in _SUBDIVISIONS {
    if r.eq(frac, at) { return name }
  }
  none
}

/// Draw the "1 2 3 + 4 +" row under the staff.
#let draw-count(theme, system, width) = {
  let sp = theme.staff-space
  box(width: width, height: theme.count-size, {
    for m in system.measures {
      let time = m.time
      let beat = if time == none { r.rat(1, den: 4) } else { r.rat(1, den: time.at(1)) }
      let position = r.zero

      for pe in m.events {
        let d = sounding-duration(pe.event)
        let beats = r.to-float(r.div(position, beat))
        let whole = calc.floor(beats)
        let offset = r.sub(position, r.mul(beat, r.rat(whole)))
        let syllable = _syllable(offset, beat)
        if syllable != none and pe.event.kind != "rest" {
          let label = if syllable == "" { str(whole + 1) } else { syllable }
          place(
            top + center,
            dx: pe.x - width / 2,
            dy: 0pt,
            text(
              font: theme.font,
              size: theme.count-size,
              weight: 700,
              style: "italic",
              fill: theme.color,
              top-edge: "cap-height",
              bottom-edge: "baseline",
              label,
            ),
          )
        }
        if d == none { break }
        position = r.add(position, d)
      }
    }
  })
}

/// The count row lane, shown only where it was asked for and is derivable.
#let count-lane-for(theme, system, width, enabled: false) = {
  if not enabled or not _has-rhythm(system) { return empty-lane }
  lane(theme.count-size + 0.3 * theme.staff-space, () => draw-count(theme, system, width))
}
