// The data model every input syntax parses into.
//
// Both the native DSL and the ASCII tab importer produce values from this
// module, and every layout and rendering stage consumes only these values. That
// is what lets a second input syntax reuse the whole rendering chain, and what
// will let a notation staff be added as a consumer without touching the parsers.
//
// The model must tolerate being *partially filled*: an imported ASCII tab knows
// fret positions but usually not durations, so `duration: none` is a legal state
// that the layout engine handles with a column-based spacing strategy.

#import "rational.typ" as r
#import "tuning.typ": string-count, tunings

// ---------------------------------------------------------------------------
// Durations
// ---------------------------------------------------------------------------

/// Base note values, in whole notes, keyed by their DSL token.
#let durations = (
  w: r.rat(1),
  h: r.rat(1, den: 2),
  q: r.rat(1, den: 4),
  e: r.rat(1, den: 8),
  s: r.rat(1, den: 16),
  t: r.rat(1, den: 32),
)

/// Inverse of `durations`: base value -> token. Used by error messages and by
/// the DSL writer that ASCII tabs are exported through.
#let duration-token(value) = {
  for (token, base) in durations {
    if r.eq(base, value) { return token }
  }
  none
}

/// Apply `n` augmentation dots to a note value.
///
/// Each dot adds half of what came before, so a doubly dotted quarter is
/// `1/4 * 7/4`.
#let dotted(value, n) = {
  if n == 0 { return value }
  let factor = r.rat(calc.pow(2, n + 1) - 1, den: calc.pow(2, n))
  r.mul(value, factor)
}

/// The written note value a duration was built from, together with its dots.
///
/// Stems and flags are drawn from the *base* value, not from the dotted total,
/// so this inverts `dotted` for rendering. Returns `none` when the duration is
/// not a dotted power of two, which happens only for hand-written durations.
#let decompose(value) = {
  for dots in range(0, 4) {
    let base = r.div(value, r.rat(calc.pow(2, dots + 1) - 1, den: calc.pow(2, dots)))
    if duration-token(base) != none {
      return (base: base, dots: dots)
    }
  }
  none
}

// ---------------------------------------------------------------------------
// Notes
// ---------------------------------------------------------------------------

/// Fret value marking a dead / muted string, written `x` in both syntaxes.
#let MUTED = "x"

/// A single note on one string.
///
/// `string` is 1-based, counted from the highest-sounding string, matching how
/// guitarists number strings. `fret` is a non-negative integer, or `MUTED`.
/// `techniques` is an array of technique records; see `technique`.
#let note(string, fret, techniques: ()) = {
  assert(type(string) == int and string >= 1, message: "note: string must be a positive integer")
  assert(
    fret == MUTED or (type(fret) == int and fret >= 0),
    message: "note: fret must be a non-negative integer or MUTED",
  )
  (kind: "note", string: string, fret: fret, techniques: techniques)
}

/// A technique record. `kind` names the technique; the remaining fields carry
/// its argument, if any.
///
/// - `hammer`, `pull`, `slide`: `fret` — the target fret, or `none` for the next
///   event that plays the string. A named fret is drawn as a second number
///   beside the first and shares its note value; `none` joins two independently
///   timed notes, which is the only form that can cross a barline.
/// - `slide`: `legato` — whether the target is *not* picked again.
/// - `slide`: `out` in `"up"`, `"down"` — the note is slid *off*, into nothing.
///   It reaches no other note, so it names a direction where a link derives one
///   from the fret it lands on.
/// - `bend`: `amount` (rational, in whole steps), `release`, `pre`.
/// - `vibrato`: `wide`.
/// - `harmonic`: `style` in `"natural"`, `"pinch"`, `"artificial"`, `"harp"`,
///   `"tap"`.
/// - `stroke`: `dir` in `"down"`, `"up"`.
#let technique(kind, ..fields) = (kind: kind, ..fields.named())

/// Whether a note carries a technique of the given kind.
#let has-technique(n, kind) = n.techniques.any(t => t.kind == kind)

/// The technique record of the given kind, or `none`.
#let get-technique(n, kind) = {
  for t in n.techniques {
    if t.kind == kind { return t }
  }
  none
}

// ---------------------------------------------------------------------------
// Events
// ---------------------------------------------------------------------------

/// One sung syllable.
///
/// `hyphen` says the word carries on into the next one. The hyphen is drawn as
/// its own character, centred in the gap between the two syllables rather than
/// tucked against this one, which is where a published sheet puts it.
#let syllable(text, hyphen: false) = (kind: "syllable", text: text, hyphen: hyphen)

/// A note that a word already begun is held over.
///
/// Distinct from "this verse sings nothing here", which is `none`. The two look
/// alike on the page — neither prints a word — but only one of them is a word
/// still sounding, and only over that one can an extender rule be drawn.
#let hold = (kind: "hold")

/// One rhythmic position: a note, a chord, or a rest.
///
/// `duration` is a rational in whole notes, or `none` when unknown — an ASCII
/// tab imported without rhythm annotation produces events with no duration, and
/// the layout engine falls back to column-derived spacing for those.
///
/// `spans` holds the names of bracketed spans active here (`"PM"`, `"LR"`).
/// Renderers draw one bracket per maximal run of consecutive events carrying the
/// same span, so no index bookkeeping is needed when measures are split across
/// systems.
///
/// `tuplet` is `none` or `(count: 3, of: 2)`, read the same way.
///
/// `grace` is `none`, `"before"` or `"on"`. A grace event is an ornament, not a
/// beat: it is set small, it takes no time from the bar, and it is spaced by a
/// fixed narrow width rather than by its note value.
///
/// `dynamic` is `none` or a name such as `"mf"`. It marks where the dynamic
/// *changes*; what is in force between two marks is whatever the last one
/// said.
///
/// `lyrics` holds one syllable per verse, indexed by verse and `none` where
/// that verse sings nothing here. It is stored on the event rather than in a
/// parallel array so that a syllable rides through system breaking with the
/// note it belongs to — the same reason spans and tuplets are recorded per
/// event.
#let event(
  notes: (),
  duration: none,
  rest: false,
  spans: (),
  tuplet: none,
  chord: none,
  techniques: (),
  text: none,
  column-span: none,
  grace: none,
  dynamic: none,
  lyrics: (),
) = {
  assert(
    duration == none or r.is-rat(duration),
    message: "event: duration must be a rational or none",
  )
  assert(
    grace in (none, "before", "on"),
    message: "event: grace must be none, \"before\" or \"on\"",
  )
  (
    kind: if rest { "rest" } else { "note" },
    notes: notes,
    duration: duration,
    spans: spans,
    tuplet: tuplet,
    chord: chord,
    // Event-level articulations that apply to every note: accent, staccato...
    techniques: techniques,
    // Free playing instruction printed above the staff, e.g. "Harm.".
    text: text,
    // How wide this event was in its source, relative to a typical event.
    // Set by the ASCII importer so a tab with no note values is still spaced
    // the way its author laid it out, instead of evenly.
    column-span: column-span,
    // An ornament rather than a beat: `"before"` is squeezed in ahead of the
    // beat, `"on"` starts on it and delays what follows. Either way it takes no
    // time from the bar, which is what `sounding-duration` enforces.
    grace: grace,
    // A dynamic taking effect here and holding until the next one, printed
    // below the staff: `"mf"`, `"ff"`, and so on.
    dynamic: dynamic,
    // One syllable per verse, or `none` where a verse sings nothing here.
    lyrics: lyrics,
  )
}

/// How long an event actually sounds, as opposed to how it is written.
///
/// Inside a triplet each written eighth sounds for two thirds of an eighth, so
/// bar-length validation must use this rather than `event.duration`.
///
/// A grace note counts for nothing: it is squeezed out of its neighbour's time,
/// and a bar containing one is neither long nor unmeasurable. Returning `none`
/// here instead would make every such bar "not checked", which is exactly the
/// silence bar validation exists to break.
#let sounding-duration(ev) = {
  if ev.at("grace", default: none) != none { return r.zero }
  if ev.duration == none { return none }
  if ev.tuplet == none { return ev.duration }
  r.scale(ev.duration, ev.tuplet.of, ev.tuplet.count)
}

// ---------------------------------------------------------------------------
// Measures
// ---------------------------------------------------------------------------

/// A bar.
///
/// `end` is one of `"single"`, `"double"`, `"final"`. Repeats are separate flags
/// because a bar can both end a repeat and start the next one.
/// `volta` is `none` or an array of ending numbers, e.g. `(1,)`.
#let measure(
  events: (),
  time: none,
  start-repeat: false,
  end-repeat: false,
  end: "single",
  volta: none,
  repeat-count: none,
) = {
  assert(end in ("single", "double", "final"), message: "measure: unknown barline '" + end + "'")
  (
    kind: "measure",
    events: events,
    // Time signature, when it changes here. `none` inherits from the part.
    time: time,
    start-repeat: start-repeat,
    end-repeat: end-repeat,
    end: end,
    volta: volta,
    repeat-count: repeat-count,
  )
}

/// Total sounding length of a measure, or `none` if any event lacks a duration.
#let measure-duration(m) = {
  let total = r.zero
  for ev in m.events {
    let d = sounding-duration(ev)
    if d == none { return none }
    total = r.add(total, d)
  }
  total
}

// ---------------------------------------------------------------------------
// Parts
// ---------------------------------------------------------------------------

/// A section heading anchored to a measure index.
///
/// Headings live in the model rather than only as standalone Typst elements so
/// that an ASCII tab carrying `S:` rows can produce them.
#let section-mark(index, title, count-in: false) = (
  index: index,
  title: title,
  count-in: count-in,
)

/// A contiguous run of music for one instrument.
#let part(
  measures: (),
  tuning: tunings.standard,
  time: (4, 4),
  tempo: none,
  capo: 0,
  anacrusis: false,
  sections: (),
) = {
  assert(
    time == none or (type(time) == array and time.len() == 2),
    message: "part: time must be a (beats, unit) pair or none",
  )
  (
    kind: "part",
    measures: measures,
    tuning: tuning,
    time: time,
    tempo: tempo,
    capo: capo,
    // A pick-up bar is short on purpose; validation skips the first measure.
    anacrusis: anacrusis,
    sections: sections,
  )
}

/// Mark every note that a tie runs *into*.
///
/// `~` is written on the note that *starts* the tie, so the note at the far end
/// knows nothing about it. It has to: the far end is not struck at all, and
/// published sheets set its fret number in parentheses to say so. One forward
/// pass over the piece finds them, carrying a pending tie per string.
///
/// Adds `tied-in: true` to the notes that receive one and leaves every other
/// note exactly as it was, so this is safe to run on any part and idempotent.
///
/// ```typc
/// let held = model.note(3, 12)
/// let p = model.part(measures: (model.measure(events: (
///   model.event(notes: (model.note(3, 12, techniques: (model.technique("tie"),)),)),
///   model.event(notes: (held,)),
/// )),))
/// let after = mark-tie-targets(p).measures.first().events
/// assert(after.at(1).notes.first().tied-in)
/// assert(after.at(0).notes.first().at("tied-in", default: false) == false)
/// ```
#let mark-tie-targets(part) = {
  // Strings whose tie is still looking for the note it runs into.
  let pending = ()
  let measures = ()
  for m in part.measures {
    let events = ()
    for ev in m.events {
      let notes = ev.notes.map(n => if n.string in pending { n + (tied-in: true) } else { n })
      // A note can both receive a tie and start another, so the strings this
      // event closes are cleared before the ones it opens are recorded.
      pending = pending.filter(s => not ev.notes.any(n => n.string == s))
      for n in ev.notes {
        if has-technique(n, "tie") and not (n.string in pending) { pending.push(n.string) }
      }
      events.push(ev + (notes: notes))
    }
    measures.push(m + (events: events))
  }
  part + (measures: measures)
}

/// The kinds of technique that join one note to another.
/// Techniques that run from one note to another on the same string.
///
/// A pick scrape is one of them. It is dragged *to* somewhere — the fret the
/// pick stops at — and that destination is not a second attack: it is where the
/// gesture ends, exactly as a slide's target is. Being a link gives it both
/// forms for nothing: written with a target fret the number is set beside the
/// `x` and shares its value, and written without one the scrape runs to the next
/// note on the string and carries across a system break like any other link.
#let LINK-KINDS = ("hammer", "pull", "slide", "scrape")

/// The slide a note is carried *off* by, or `none`.
///
/// A slide out reaches no other note, so it is drawn as a short stroke leaving
/// this one and needs a direction of its own — see `technique`.
#let slide-out(n) = {
  for t in n.techniques {
    if t.kind == "slide" and t.at("out", default: none) != none { return t }
  }
  none
}

/// The link a note carries that runs to the next event, or `none`.
///
/// A hammer-on, pull-off or slide written with a target fret prints that fret
/// beside its own number and needs nothing from the notes around it. Written
/// without one it runs to the next event that plays the string, which is the
/// only form that can join two independently timed notes or cross a barline.
///
/// A slide *out* is neither: it names a direction rather than a destination, so
/// there is no later note for it to reach and none to mark.
#let link-to-next(n) = {
  for t in n.techniques {
    if t.kind in LINK-KINDS and t.at("fret", default: none) == none {
      if t.at("out", default: none) == none { return t }
    }
  }
  none
}

/// Mark every note that a link runs *into*.
///
/// The mirror of `mark-tie-targets`, and needed for the same reason ties need
/// theirs — but at the other end of the piece's geometry. A system is drawn on
/// its own and cannot look back past its own first event, so a link arriving
/// from the line above would leave no trace there. `linked-in` is what lets the
/// landing system draw the incoming half of it.
///
/// Adds `linked-in: (kind: …, legato: …)` to the notes that receive one and
/// leaves every other note as it was, so this is safe to run on any part and
/// idempotent.
///
/// ```typc
/// let p = model.part(measures: (model.measure(events: (
///   model.event(notes: (model.note(3, 5, techniques: (model.technique("slide", legato: true),)),)),
///   model.event(notes: (model.note(3, 9),)),
/// )),))
/// let after = mark-link-targets(p).measures.first().events
/// assert(after.at(1).notes.first().linked-in.kind == "slide")
/// ```
#let mark-link-targets(part) = {
  // Strings whose link is still looking for the note it runs into, and what
  // kind of link is on its way.
  let pending = (:)
  let measures = ()
  for m in part.measures {
    let events = ()
    for ev in m.events {
      let notes = ev.notes.map(n => {
        let waiting = pending.at(str(n.string), default: none)
        if waiting == none { n } else { n + (linked-in: waiting) }
      })
      // A note can both receive a link and start another, so what this event
      // closes is cleared before what it opens is recorded.
      for n in ev.notes {
        if str(n.string) in pending { let _ = pending.remove(str(n.string)) }
      }
      for n in ev.notes {
        let link = link-to-next(n)
        if link != none {
          pending.insert(str(n.string), (kind: link.kind, legato: link.at("legato", default: true)))
        }
      }
      events.push(ev + (notes: notes))
    }
    measures.push(m + (events: events))
  }
  part + (measures: measures)
}

/// Whether a note's fret number is set in parentheses.
///
/// A ghost note is struck but barely sounded, and the brackets are the whole of
/// how a tab sheet says so.
#let is-parenthesised(n) = has-technique(n, "ghost")

/// Whether a note's fret number is printed at all.
///
/// The far end of a tie is not struck: the string is still sounding the note
/// before it, and there is no second attack to write down. Songsterr — the
/// reference for how this package sets ties, since it too renders tablature with
/// no notation staff beside it — draws the arc alone and prints no number there,
/// and the arc is then the whole of what says the note is held. Hal Leonard
/// parenthesises it instead, but it has a notation staff carrying the tie and
/// can afford the redundancy; alone on a tab staff a bracketed digit reads as a
/// second, quieter attack, which is exactly what a ghost note is — so the two
/// printed alike left the reader no way to tell them apart.
///
/// Nothing else about the note changes: the event keeps its slot in the rhythm
/// lane, so the held note still has a written duration and the tie still has
/// somewhere to land. A note that is both tied into and ghosted prints nothing,
/// the tie being the stronger statement — it says the string was never struck
/// again at all.
#let prints-fret(n) = not n.at("tied-in", default: false)

/// The time signature in force at a measure index, as a `(beats, unit)` pair.
///
/// A measure records a time signature only where one *changes*, so anything
/// that needs the signature in force — bar-length validation, beam grouping,
/// the count row — has to resolve it by looking back.
#let time-signature-at(part, index) = {
  let sig = part.time
  for i in range(0, index + 1) {
    let t = part.measures.at(i).time
    if t != none { sig = t }
  }
  sig
}

/// The time signature in force at a measure index, as a rational bar length.
#let time-at(part, index) = {
  let sig = time-signature-at(part, index)
  if sig == none { none } else { r.rat(sig.at(0), den: sig.at(1)) }
}

/// Check a part for musical inconsistencies, returning an array of messages.
///
/// This is advisory: a partially filled model is legal, so unknown durations are
/// reported as "not checked" rather than as errors. Callers decide whether to
/// warn or fail.
#let validate(part) = {
  let problems = ()
  let strings = string-count(part.tuning)

  // The signature in force, carried forward in one pass — resolving it per
  // measure through `time-at` would rescan the part each time.
  let sig = part.time

  for (i, m) in part.measures.enumerate() {
    let where = "measure " + str(i + 1)
    if m.time != none { sig = m.time }

    for ev in m.events {
      for n in ev.notes {
        if n.string > strings {
          problems.push(
            where + ": string " + str(n.string) + " does not exist in tuning "
              + repr(part.tuning.name),
          )
        }
        if n.fret != MUTED and n.fret > 24 {
          problems.push(where + ": fret " + str(n.fret) + " is above the 24th")
        }
      }
    }

    // A pick-up bar is short by definition.
    if i == 0 and part.anacrusis { continue }

    let expected = if sig == none { none } else { r.rat(sig.at(0), den: sig.at(1)) }
    if expected == none { continue }
    let actual = measure-duration(m)
    if actual == none { continue }
    // So is the bar that closes a passage: it pairs with the pick-up that opened
    // it — between them they are one bar — and a passage set on its own, which
    // every section of an imported score is, simply stops where it stops. Two
    // limits keep this from silencing real mistakes: a bar holding *more* than
    // the signature allows is wrong however the piece ends, and a part of one
    // bar is exempt from nothing, there being no passage for it to be the end
    // of.
    let closing = part.measures.len() > 1 and i == part.measures.len() - 1
    if closing and r.lt(actual, expected) { continue }
    if not r.eq(actual, expected) {
      problems.push(
        where + ": holds " + r.str-of(actual) + " but the time signature calls for "
          + r.str-of(expected),
      )
    }
  }

  problems
}
