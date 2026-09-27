// Lyrics: one string per verse, spent syllable by syllable over the music.
//
// Not written inline in the DSL. Syllables would drown the notes, and there is
// already a pattern for data that runs parallel to the music and lines up with
// it event by event — the `rhythm:` argument and the ASCII annotation rows.
//
//   #tab(lyrics: "Some- thing I can ne- ver say _", ```q 0/6 2/6 e 3/6 3/6```)
//
// The syllables are spent in order over the events that are actually sung, and
// nothing else about the piece has to be repeated to say where they go.

#import "../model.typ": hold, sounding-duration, syllable
#import "../rational.typ" as r

/// Read one syllable token.
///
/// A trailing `-` hyphenates into the next syllable and is not part of the
/// word. `_` is a note the word before it is held over: the reference tab sheets
/// print the word once, where it starts, and draw nothing after it, while a vocal
/// score rules an extender to the last held note — which `lyric-extender` on the
/// theme asks for.
///
/// ```typc
/// assert(read-syllable("Twist-") == syllable("Twist", hyphen: true))
/// assert(read-syllable("_") == hold)
/// ```
#let read-syllable(token) = {
  // A held note, not an unsung one: the two print the same nothing, but only
  // over a held note can an extender rule be drawn.
  if token == "_" { return hold }
  // A lone `-` is a word in its own right rather than an empty hyphenation.
  if token.ends-with("-") and token.clusters().len() > 1 {
    syllable(token.slice(0, -1), hyphen: true)
  } else {
    syllable(token)
  }
}

/// Read one verse into syllable records, in the order they are sung.
#let read-verse(source) = {
  source.split(regex("\\s+")).filter(t => t != "").map(read-syllable)
}

/// Whether an event takes a syllable of its own.
///
/// A rest is silence and a grace note is an ornament, so neither is sung. Nor
/// is the far end of a tie: it is not a new attack, and it keeps the syllable
/// of the note it is held from — which is why this has to look at the notes and
/// not only at the event. `mark-tie-targets` is what puts that mark there, so
/// it must have run first.
#let takes-syllable(ev) = {
  if ev.kind == "rest" or ev.notes.len() == 0 { return false }
  if ev.at("grace", default: none) != none { return false }
  not ev.notes.all(n => n.at("tied-in", default: false))
}

/// Whether any event in a part already carries a syllable.
#let has-lyrics(part) = part.measures.any(m => m.events.any(ev => (
  ev.at("lyrics", default: ()).any(s => s != none)
)))

// ---------------------------------------------------------------------------
// Verses given as moments
// ---------------------------------------------------------------------------
//
// The syntax above spends syllables in order over the events that are sung,
// which is what a verse written for *this* music wants: the words and the notes
// were made for each other, and neither has to say where the other goes.
//
// A verse written for a *different* part cannot be spent that way. A guitar
// staff under a singer's words has its own notes, more of them and elsewhere,
// and counting through them would start the first word bars before anyone sings.
// Such a verse carries its own moments instead, and each syllable is hung on
// whatever this part has sounding then.
//
// That includes a rest. In vocal notation a syllable is never set on one — a
// rest in the sung line means nothing is sung there — but this is not that. It
// is one part's words under another part's staff, the way a guitar songbook
// prints them, and a bar the guitar rests through is a bar the voice sings on.

/// A syllable sung at a stated moment: `measure` counting from zero, `position`
/// a rational of whole notes into that measure.
///
/// `text` is read exactly as a syllable in a verse string is, so a trailing `-`
/// still hyphenates and `_` still spends the moment silently.
#let at(measure, position, text) = (
  measure: measure,
  position: position,
  text: text,
)

/// Whether a verse is given as moments rather than as a run of syllables.
#let is-timed(verse) = (
  type(verse) == array
    and verse.len() > 0
    and verse.all(s => type(s) == dictionary and "measure" in s and "position" in s)
)

/// How far from its stated moment a syllable may still find something to sit on.
///
/// An eighth note. Two transcriptions of one song rarely agree to the tick, and
/// within an eighth a reader sees one moment; beyond it a word is being hung on
/// a note it has nothing to do with, and is better left out.
#let NEAR = r.rat(1, den: 8)

/// Where each event of a measure begins, in whole notes from its start.
///
/// `none` when any event has no duration: an imported ASCII tab carries frets
/// but no note values, so there is no timeline to hang a moment on.
#let _onsets(meas) = {
  let out = ()
  let at = r.zero
  for ev in meas.events {
    let d = sounding-duration(ev)
    if d == none { return none }
    out.push(at)
    at = r.add(at, d)
  }
  out
}

/// The event nearest `position` that this verse has not already used.
///
/// Nearest rather than next: a moment is a claim about *when*, and the event
/// just before it is often the closer of the two. Used events are passed over so
/// that two syllables falling together keep their order instead of one
/// overwriting the other.
///
/// A rest is offered like anything else: it is an event with a place in the bar,
/// and a word sung while the part is silent belongs there. What must not happen
/// is *mixing* — see [`apply-timed`], which settles a bar one way or the other.
#let _nearest(onsets, used, position) = {
  let best = none
  let best-gap = none
  for (i, onset) in onsets.enumerate() {
    if i in used { continue }
    let gap = r.sub(onset, position)
    if r.lt(gap, r.zero) { gap = r.sub(r.zero, gap) }
    if r.gt(gap, NEAR) { continue }
    if best-gap == none or r.lt(gap, best-gap) {
      best = i
      best-gap = gap
    }
  }
  best
}

/// Hang verses of timed syllables on whatever is sounding at their moments.
///
/// Returns `(part: …, warnings: …)` as [`apply`] does. A syllable that finds
/// nothing near enough is reported rather than dragged to the next event there
/// is: a part rests through phrases the voice sings, and a word five bars from
/// where it belongs is not a near miss but a different line.
#let apply-timed(part, verses) = {
  let lanes = verses.len()
  // Gathered per measure, so the measures are walked once however many verses
  // there are.
  let wanted = (:)
  for (v, verse) in verses.enumerate() {
    for s in verse {
      let key = str(s.measure)
      wanted.insert(key, wanted.at(key, default: ()) + ((verse: v, ..s),))
    }
  }

  let measures = ()
  let missed = 0
  for (mi, meas) in part.measures.enumerate() {
    let here = wanted.at(str(mi), default: ())
    if here.len() == 0 {
      measures.push(meas)
      continue
    }
    let onsets = _onsets(meas)
    if onsets == none {
      missed += here.len()
      measures.push(meas)
      continue
    }
    // Settle the bar one way or the other. A syllable on an event sits at that
    // event's own x; one placed by its moment is interpolated between the notes.
    // The two nearly agree, and "nearly" is what a collision is made of — so a
    // bar where every syllable finds an event of its own uses events for all of
    // them, and a bar where any one cannot uses moments for all of them.
    //
    // What forces the second case is a bar the part rests through: it is a
    // *single* whole rest, and a phrase sung across it has five syllables and one
    // event to hang them on.
    let assigned = (:)
    let used = ((),) * lanes
    let all-placed = true
    for (k, s) in here.enumerate() {
      let i = _nearest(onsets, used.at(s.verse), s.position)
      if i == none {
        all-placed = false
        break
      }
      used.at(s.verse) = used.at(s.verse) + (i,)
      assigned.insert(str(k), i)
    }

    let events = meas.events
    let floating = meas.at("floating", default: ())
    for (k, s) in here.enumerate() {
      let syl = read-syllable(s.text)
      if not all-placed {
        // A held note carries no word, and away from an event there is nothing
        // for an extender to run along either, so it is simply passed over.
        if syl.kind == "syllable" {
          floating.push((verse: s.verse, position: s.position, syllable: syl))
        }
        continue
      }
      let i = assigned.at(str(k))
      let lyrics = events.at(i).at("lyrics", default: ())
      // Widened to every lane, so verse two is never read as verse one.
      while lyrics.len() < lanes { lyrics.push(none) }
      lyrics.at(s.verse) = syl
      events.at(i) = events.at(i) + (lyrics: lyrics)
    }
    measures.push(meas + (events: events, floating: floating))
  }

  let warnings = if missed > 0 {
    (str(missed) + " syllable(s) fall in a bar with no note values to place them by",)
  } else {
    ()
  }
  (part: part + (measures: measures), warnings: warnings)
}

/// Spend one or more verses over a part's sung events.
///
/// `verses` is a string, or an array of strings for several verses — one lane
/// each, in the order given. Returns `(part: …, warnings: …)`; syllables left
/// over after the last note are reported rather than dropped in silence,
/// because a miscount is the one mistake this syntax makes easy.
#let apply(part, verses) = {
  let sources = if type(verses) == str { (verses,) } else { verses }
  let parsed = sources.map(read-verse)
  let cursors = parsed.map(_ => 0)
  let measures = ()

  for meas in part.measures {
    let events = ()
    for ev in meas.events {
      if not takes-syllable(ev) {
        events.push(ev)
        continue
      }
      let here = ()
      for (v, syllables) in parsed.enumerate() {
        here.push(syllables.at(cursors.at(v), default: none))
        cursors.at(v) = cursors.at(v) + 1
      }
      events.push(ev + (lyrics: here))
    }
    measures.push(meas + (events: events))
  }

  let warnings = ()
  for (v, syllables) in parsed.enumerate() {
    let left = syllables.len() - cursors.at(v)
    if left > 0 {
      warnings.push(
        "verse " + str(v + 1) + ": " + str(left) + " syllable(s) left over after the last note",
      )
    }
  }
  (part: part + (measures: measures), warnings: warnings)
}
