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

#import "../model.typ": syllable

/// Read one syllable token.
///
/// A trailing `-` hyphenates into the next syllable and is not part of the
/// word. `_` spends an event without placing anything, which is how a word held
/// over several notes is written: the reference sheets print the word once,
/// where the note starts, and draw no extension line after it, so there is
/// nothing for the held events to show.
///
/// ```typc
/// assert(read-syllable("Twist-") == syllable("Twist", hyphen: true))
/// assert(read-syllable("_") == none)
/// ```
#let read-syllable(token) = {
  if token == "_" { return none }
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
