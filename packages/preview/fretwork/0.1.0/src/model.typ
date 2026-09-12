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
/// - `hammer`, `pull`, `slide`: `fret` — the target fret.
/// - `slide`: `legato` — whether the target is *not* picked again.
/// - `bend`: `amount` (rational, in whole steps), `release`, `pre`.
/// - `vibrato`: `wide`.
/// - `harmonic`: `style` in `"natural"`, `"pinch"`, `"harp"`.
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

    // A pick-up bar is short by definition. A bar closing a repeat is often
    // short too, but only when a pick-up accounts for the difference — that
    // pairing is not modelled, so such bars are still reported and the report
    // is advisory.
    if i == 0 and part.anacrusis { continue }

    let expected = if sig == none { none } else { r.rat(sig.at(0), den: sig.at(1)) }
    if expected == none { continue }
    let actual = measure-duration(m)
    if actual == none { continue }
    if not r.eq(actual, expected) {
      problems.push(
        where + ": holds " + r.str-of(actual) + " but the time signature calls for "
          + r.str-of(expected),
      )
    }
  }

  problems
}
