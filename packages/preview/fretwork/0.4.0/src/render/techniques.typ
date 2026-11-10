// Playing techniques drawn above the staff.
//
// Marks pack sideways rather than into fixed lanes: each sits as close to the
// staff as it fits, and things stack only where they are actually in each
// other's way. A palm mute in one bar and an instruction in the next therefore
// share a level, and a plain riff costs no vertical space at all.
//
// Marks of one kind move together, so every palm mute in a system stays at one
// height. When two kinds do collide the order decides, closest to the staff
// first: articulations, vibrato, trills and scrapes, free text, spans. The
// articulations are three kinds rather than one — a length mark, an attack mark
// and a stroke direction — so a note may carry one of each and have all three
// drawn. The first two belong to their note and are packed by depth, so each
// note's stack falls towards the staff on its own; the stroke direction is a
// row read across the system and keeps one height.
//
// The division of labour with `tabstaff.typ` is by what a mark is positioned
// against: anything anchored to a *string* — the second number of a hammer-on,
// the line of a slide, a bend arrow — is drawn there. Only marks that belong to
// a lane above the staff are drawn here.

#import "../model.typ": get-technique, has-technique
#import "marks.typ": draw-levels, label as _label, levels-of, span-mark, span-names, span-runs
#import "marks.typ"
#import "dynamics.typ"
#import "glyphs.typ" as g

/// Labels for bracketed spans. Unknown names are printed as written.
#let SPAN-LABELS = (
  PM: "P.M.",
  LR: "let ring",
)

/// What each harmonic style is called above the staff.
#let _HARMONIC-LABELS = (
  natural: "Harm.",
  pinch: "P.H.",
  artificial: "A.H.",
  harp: "H.H.",
  tap: "T.H.",
)

/// Techniques of a kind carried by an event, whether written on one of its
/// notes or on the event itself.
///
/// A rest and a bare mute have no note to hang a suffix on, so theirs are
/// recorded on the event — which is the only way a fermata can hold a rest.
#let _event-techniques(ev, kind) = {
  let own = ev.at("techniques", default: ()).filter(t => t.kind == kind)
  own + ev.notes.map(n => get-technique(n, kind)).filter(t => t != none)
}

/// The articulations that stack against the note, nearest the staff first: a
/// length mark, then an attack mark. That is an engraver's order against a
/// notehead, the staccato dot sitting closer than the accent.
///
/// Within a kind the marks are alternatives — nothing is both staccato and
/// tenuto — so a kind contributes at most one glyph to an event.
///
/// The stroke direction is deliberately not here. `⊓` and `∨` are the bowing
/// marks: they are set clear of every other articulation and level with each
/// other down the system, so they are packed as one kind of their own.
#let _ARTICULATION-KINDS = (
  ("staccato", "tenuto"),
  ("accent", "marcato"),
)

/// Air kept under a stroke direction, on top of the packer's own level gap.
#let _STROKE-CLEARANCE = 0.30

/// The room one articulation is given: the tallest of the glyphs.
///
/// Every row of them is therefore the same height, and a mark is set on its
/// row's *floor* rather than centred in it — a staccato dot is a quarter the
/// height of an accent, and centring left it hanging a third of a staff space
/// clear of the staff while the accent beside it nearly touched.
///
/// Measured from the glyphs rather than written down, so a redrawn mark cannot
/// leave a constant here saying something that is no longer true.
#let _articulation-box(theme) = {
  let sp = theme.staff-space
  calc.max(
    g.accent(sp).height,
    g.marcato(sp).height,
    g.staccato(sp).height,
    g.tenuto(sp).height,
    g.downstroke(sp).height,
    g.upstroke(sp).height,
  )
}

/// The glyph one articulation prints as.
#let _articulation-glyph(theme, t) = {
  let sp = theme.staff-space
  if t.kind == "accent" {
    g.accent(sp, fill: theme.color)
  } else if t.kind == "marcato" {
    g.marcato(sp, fill: theme.color)
  } else if t.kind == "staccato" {
    g.staccato(sp, fill: theme.color)
  } else if t.kind == "tenuto" {
    g.tenuto(sp, fill: theme.color)
  } else if t.dir == "down" {
    g.downstroke(sp, fill: theme.color)
  } else {
    g.upstroke(sp, fill: theme.color)
  }
}

/// Marks that print as a word followed by a wavy line running over the event.
///
/// A pick scrape is *not* one of them, though it was: its wave belongs on the
/// string the pick is dragged down, which is where both references draw it and
/// where `tabstaff.typ` now puts it. Above the staff the word is all there is
/// to say, exactly as with a harmonic.
#let _WAVY-LABELS = (trill: "tr", bar-vibrato: "w/ bar")

/// Techniques that print as a plain letter over the note they belong to: the
/// bass right hand, and tapping.
///
/// Tapping is a `T` in both references — Hal Leonard's legend and Songsterr's —
/// and needs nothing beyond the letter, since the note under it says which fret
/// is struck and the whole point of the mark is that no pick was involved.
#let _LETTER-LABELS = (slap: "S", pop: "P", dead-slap: "DS", tap: "T")

/// A vibrato squiggle, drawn from its left edge with `y` at its top.
#let _vibrato-mark(theme, x, y, w, wide) = {
  let wave = g.wavy(theme.staff-space, w, amp: if wide { 0.30 } else { 0.18 }, fill: theme.color)
  place(top + left, dx: x, dy: y, wave.body)
}

/// A free instruction written over an event.
///
/// Alone among the marks this is a phrase rather than a glyph or a word —
/// imported scores carry whole remarks ("Angus alternated between pull offs and
/// picking…") — so it is wider than the note it hangs on and often wider than
/// the room left beside it. It is therefore boxed at a width it is known to fit
/// in: shifted left where that is what it takes, and wrapped only where the
/// system itself is too narrow, with the box's measured height reserved. Set
/// loose it did both wrong at once — it wrapped inside a level one line tall and
/// printed over whatever the level below held.
///
/// Must be called from a context: the phrase is measured.
#let _instruction(theme, pe, width) = {
  let body = _label(theme, pe.event.text)
  let w = calc.min(measure(body).width, width)
  let boxed = box(width: w, body)
  let x = calc.max(0pt, calc.min(pe.x - 0.2 * theme.staff-space, width - w))
  (
    x0: x,
    x1: x + w,
    height: calc.max(theme.technique-size * 1.3, measure(boxed).height),
    draw: y => place(top + left, dx: x, dy: y, boxed),
  )
}

/// Every mark the lane has to place.
///
/// A mark records the horizontal room it needs and how to draw itself at a
/// given top edge. They come back grouped by kind, ordered by how close to the
/// staff the kind wants to sit — which is the order the packer tries them in.
///
/// `width` is the system's own width, which only a free instruction needs: it is
/// the one mark that can be wider than the music it belongs to. `reserved` is
/// room the staff below needs back at named stretches — an ornate repeat's
/// serifs — held as marks with nothing to draw, so the packer treats them like
/// any other obstacle instead of the lane being pushed clear of them.
///
/// Must be called from a context: labels are measured.
#let _marks(theme, system, width, reserved: ()) = {
  let sp = theme.staff-space
  let placed = marks.flatten(system)
  let groups = ()

  // First, so it takes the level against the staff and everything else packs
  // around it. It draws nothing: it is the serif itself, already on the page.
  if reserved.len() > 0 {
    groups.push(reserved.map(r => (x0: r.x0, x1: r.x1, height: r.height, draw: y => none)))
  }

  let box = _articulation-box(theme)
  // `pad` is air kept *under* the glyph, carried in the mark's own height so the
  // packer knows about it. Only the stroke direction asks for any.
  let artic-mark(pe, t, pad: 0pt) = {
    let glyph = _articulation-glyph(theme, t)
    let x = pe.x - glyph.width / 2
    (
      x0: x,
      x1: x + glyph.width,
      height: box + pad,
      draw: y => place(top + left, dx: x, dy: y + box - glyph.height, glyph.body),
    )
  }
  let carried(ev, kinds) = ev.notes.map(n => n.techniques.filter(t => t.kind in kinds)).flatten()

  // --- articulations, stacked against the note ---
  //
  // Grouped by *depth* rather than by kind: group `i` holds every event's `i`-th
  // mark, so the only marks that can collide are the ones over the same note and
  // each event's stack falls as far towards the staff as its own contents allow.
  // An accent with nothing under it therefore sits against the staff rather than
  // floating at the height of one that has a staccato dot beneath it, which is
  // how an engraver sets articulations against a notehead — they belong to their
  // note, not to a row running through the system.
  let stacks = placed.map(pe => (pe: pe, marks: _ARTICULATION-KINDS
    .map(kinds => carried(pe.event, kinds))
    .filter(hits => hits.len() > 0)
    .map(hits => hits.first())))
  for depth in range(stacks.fold(0, (acc, s) => calc.max(acc, s.marks.len()))) {
    let row = stacks.filter(s => s.marks.len() > depth).map(s => artic-mark(s.pe, s.marks.at(depth)))
    if row.len() > 0 { groups.push(row) }
  }

  // --- the stroke direction, one row for the whole system ---
  //
  // A kind of its own, and pushed after the articulations so it takes a level
  // clear of them: bowing marks are read as a row telling the picking hand what
  // to do, and one that fell towards the staff wherever the note under it was
  // unmarked would say the pattern changes where only the articulation does.
  //
  // It keeps air under it, which no other articulation does. `⊓` and `∨` are
  // open shapes as wide as they are tall, and set at the packer's ordinary gap
  // they read as resting on whatever is beneath — the top string line where the
  // note is otherwise unmarked, an accent where it is not.
  let strokes = ()
  for pe in placed {
    let found = carried(pe.event, ("stroke",))
    if found.len() > 0 { strokes.push(artic-mark(pe, found.first(), pad: _STROKE-CLEARANCE * sp)) }
  }
  if strokes.len() > 0 { groups.push(strokes) }

  // --- a letter over the note: the bass right hand, and tapping ---
  let letters = ()
  for pe in placed {
    for kind in _LETTER-LABELS.keys() {
      if _event-techniques(pe.event, kind).len() == 0 { continue }
      let body = _label(theme, _LETTER-LABELS.at(kind))
      let w = measure(body).width
      let x = pe.x - w / 2
      letters.push((
        x0: x,
        x1: x + w,
        height: theme.technique-size * 1.3,
        draw: y => place(top + left, dx: x, dy: y, body),
      ))
      break
    }
  }
  if letters.len() > 0 { groups.push(letters) }

  // --- vibrato ---
  let vibrato = ()
  for pe in placed {
    for t in _event-techniques(pe.event, "vibrato") {
      let w = calc.max(1.4 * sp, pe.alloc * 0.8)
      let x = pe.x - 0.2 * sp
      vibrato.push((
        x0: x,
        x1: x + w,
        height: 0.75 * sp,
        draw: y => _vibrato-mark(theme, x, y + 0.1 * sp, w, t.wide),
      ))
      break
    }
  }
  if vibrato.len() > 0 { groups.push(vibrato) }

  // --- a trill or a pick scrape: a word, then a wavy line for as long as it lasts ---
  let wavy = ()
  for pe in placed {
    for kind in _WAVY-LABELS.keys() {
      if _event-techniques(pe.event, kind).len() == 0 { continue }
      let word = _label(theme, _WAVY-LABELS.at(kind), italic: kind == "trill")
      let word-w = measure(word).width
      let wave = g.wavy(
        sp,
        calc.max(1.2 * sp, pe.alloc - word-w - 0.5 * sp),
        fill: theme.color,
      )
      let x = pe.x - 0.2 * sp
      wavy.push((
        x0: x,
        x1: x + word-w + 0.25 * sp + wave.width,
        height: theme.technique-size * 1.3,
        draw: y => {
          place(top + left, dx: x, dy: y, word)
          place(
            top + left,
            dx: x + word-w + 0.25 * sp,
            dy: y + theme.technique-size * 0.25,
            wave.body,
          )
        },
      ))
    }
  }
  if wavy.len() > 0 { groups.push(wavy) }

  // --- harmonics and pick scrapes: a word over the note ---
  let words = ()
  for pe in placed {
    // An event carrying its own instruction has said what it wants said, and two
    // words over one note read as two things happening.
    if pe.event.text != none { continue }
    let harmonics = _event-techniques(pe.event, "harmonic")
    let word = if harmonics.len() > 0 {
      _HARMONIC-LABELS.at(harmonics.first().style)
    } else if _event-techniques(pe.event, "scrape").len() > 0 {
      "P.S."
    } else { none }
    if word == none { continue }
    let body = _label(theme, word)
    let x = pe.x - 0.2 * sp
    words.push((
      x0: x,
      x1: x + measure(body).width,
      height: theme.technique-size * 1.3,
      draw: y => place(top + left, dx: x, dy: y, body),
    ))
  }
  if words.len() > 0 { groups.push(words) }

  // --- free instructions: a phrase over the note ---
  // One group each, rather than one group for all of them: every other mark is
  // as wide as the note it sits on and two of a kind can share a level by
  // construction, but two remarks in one system are routinely in each other's
  // way and have to be allowed to stack.
  for pe in placed {
    if pe.event.text == none { continue }
    groups.push((_instruction(theme, pe, width),))
  }

  // --- bracketed spans ---
  let spans = ()
  for name in span-names(placed) {
    // A `cresc.` is a span too, but it belongs to the dynamics lane below the
    // staff, which draws it. Left in, it would print here as well.
    if name in dynamics.HAIRPIN-LABELS { continue }
    let body = _label(theme, SPAN-LABELS.at(name, default: name))
    for run in span-runs(placed, name) {
      spans.push(span-mark(theme, run, body))
    }
  }
  if spans.len() > 0 { groups.push(spans) }

  // --- fermata ---
  // Last, so it takes the outermost level: a fermata governs everything written
  // under it, and printing it below an accent or a palm mute bracket would read
  // as though it applied only to what is between them.
  let holds = ()
  for pe in placed {
    if _event-techniques(pe.event, "fermata").len() == 0 { continue }
    let glyph = g.fermata(sp, fill: theme.color)
    let x = pe.x - glyph.width / 2
    holds.push((
      x0: x,
      x1: x + glyph.width,
      height: glyph.height,
      draw: y => place(top + left, dx: x, dy: y, glyph.body),
    ))
  }
  if holds.len() > 0 { groups.push(holds) }

  groups
}

/// The marks builder for a lane of the given width, in the form the packer takes.
#let _builder(width, reserved) = (thm, sys) => _marks(thm, sys, width, reserved: reserved)

/// The levels of the technique lane.
#let _levels(theme, system, width, reserved: ()) = levels-of(
  theme,
  system,
  _builder(width, reserved),
)

/// Total height of the lane.
#let height(theme, system, width, reserved: ()) = marks.stack-height(
  theme,
  _levels(theme, system, width, reserved: reserved),
)

/// Draw the technique lane for one placed system.
#let draw(theme, system, width, levels: none, reserved: ()) = {
  draw-levels(
    theme,
    if levels != none { levels } else { _levels(theme, system, width, reserved: reserved) },
    width,
  )
}

/// The technique lane, collapsing when nothing needs it.
#let lane-for(theme, system, width, reserved: ()) = marks.lane-of(
  theme,
  system,
  width,
  _builder(width, reserved),
)
