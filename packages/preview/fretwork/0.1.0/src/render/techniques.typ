// Playing techniques drawn above the staff.
//
// Marks pack sideways rather than into fixed lanes: each sits as close to the
// staff as it fits, and things stack only where they are actually in each
// other's way. A palm mute in one bar and an instruction in the next therefore
// share a level, and a plain riff costs no vertical space at all.
//
// Marks of one kind move together, so every palm mute in a system stays at one
// height. When two kinds do collide the order decides, closest to the staff
// first: articulations, vibrato, trills and scrapes, free text, spans.
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

/// Techniques of a kind carried by an event, whether written on one of its
/// notes or on the event itself.
///
/// A rest and a bare mute have no note to hang a suffix on, so theirs are
/// recorded on the event — which is the only way a fermata can hold a rest.
#let _event-techniques(ev, kind) = {
  let own = ev.at("techniques", default: ()).filter(t => t.kind == kind)
  own + ev.notes.map(n => get-technique(n, kind)).filter(t => t != none)
}

#let _ARTICULATIONS = ("accent", "marcato", "staccato", "tenuto", "stroke")

/// Marks that print as a word followed by a wavy line running over the event.
#let _WAVY-LABELS = (trill: "tr", scrape: "P.S.", bar-vibrato: "w/ bar")

/// Bass right-hand techniques, which print as a letter over the note.
#let _BASS-LABELS = (slap: "S", pop: "P", dead-slap: "DS")

/// A vibrato squiggle, drawn from its left edge with `y` at its top.
#let _vibrato-mark(theme, x, y, w, wide) = {
  let wave = g.wavy(theme.staff-space, w, amp: if wide { 0.30 } else { 0.18 }, fill: theme.color)
  place(top + left, dx: x, dy: y, wave.body)
}

/// Every mark the lane has to place.
///
/// A mark records the horizontal room it needs and how to draw itself at a
/// given top edge. They come back grouped by kind, ordered by how close to the
/// staff the kind wants to sit — which is the order the packer tries them in.
///
/// Must be called from a context: labels are measured.
#let _marks(theme, placed) = {
  let sp = theme.staff-space
  let groups = ()

  // --- articulations, one glyph per event ---
  let artic = ()
  for pe in placed {
    for n in pe.event.notes {
      let glyph = none
      for t in n.techniques {
        glyph = if t.kind == "accent" {
          g.accent(sp, fill: theme.color)
        } else if t.kind == "marcato" {
          g.marcato(sp, fill: theme.color)
        } else if t.kind == "staccato" {
          g.staccato(sp, fill: theme.color)
        } else if t.kind == "tenuto" {
          g.tenuto(sp, fill: theme.color)
        } else if t.kind == "stroke" and t.dir == "down" {
          g.downstroke(sp, fill: theme.color)
        } else if t.kind == "stroke" {
          g.upstroke(sp, fill: theme.color)
        } else { none }
        if glyph != none { break }
      }
      if glyph == none { continue }
      let x = pe.x - glyph.width / 2
      artic.push((
        x0: x,
        x1: x + glyph.width,
        height: 0.85 * sp,
        draw: y => place(top + left, dx: x, dy: y + (0.85 * sp - glyph.height) / 2, glyph.body),
      ))
      break
    }
  }
  if artic.len() > 0 { groups.push(artic) }

  // --- the bass right hand: a letter over the note it strikes ---
  let bass = ()
  for pe in placed {
    for kind in _BASS-LABELS.keys() {
      if _event-techniques(pe.event, kind).len() == 0 { continue }
      let body = _label(theme, _BASS-LABELS.at(kind))
      let w = measure(body).width
      let x = pe.x - w / 2
      bass.push((
        x0: x,
        x1: x + w,
        height: theme.technique-size * 1.3,
        draw: y => place(top + left, dx: x, dy: y, body),
      ))
      break
    }
  }
  if bass.len() > 0 { groups.push(bass) }

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

  // --- harmonics and free instructions ---
  let texts = ()
  for pe in placed {
    let harmonics = _event-techniques(pe.event, "harmonic")
    let word = if pe.event.text != none {
      pe.event.text
    } else if harmonics.len() > 0 {
      let style = harmonics.first().style
      if style == "natural" { "Harm." } else if style == "pinch" { "P.H." } else { "H.H." }
    } else { none }
    if word == none { continue }
    let body = _label(theme, word)
    let x = pe.x - 0.2 * sp
    texts.push((
      x0: x,
      x1: x + measure(body).width,
      height: theme.technique-size * 1.3,
      draw: y => place(top + left, dx: x, dy: y, body),
    ))
  }
  if texts.len() > 0 { groups.push(texts) }

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

/// The levels of the technique lane.
#let _levels(theme, system) = levels-of(theme, system, _marks)

/// Total height of the lane.
#let height(theme, system) = marks.stack-height(theme, _levels(theme, system))

/// Draw the technique lane for one placed system.
#let draw(theme, system, width, levels: none) = {
  draw-levels(theme, if levels != none { levels } else { _levels(theme, system) }, width)
}

/// The technique lane, collapsing when nothing needs it.
#let lane-for(theme, system, width) = marks.lane-of(theme, system, width, _marks)
