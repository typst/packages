// Public API of the `fretwork` package.
//
//   #import "@local/fretwork:0.3.0": *
//
//   #show: song.with(title: "Twelve Past Nine", tempo: 132)
//   #section("Main Riff")
//   #tab(```
//   |: q (2/5 2/4 0/6)  q x  e 0/3 3/6 0/6 0/6 :|
//   ```)

#import "model.typ"
#import "rational.typ"
#import "tuning.typ": tunings, tuning, to-pitch, pitch-name, string-count
#import "theme.typ": theme, default-theme
#import "parse/dsl.typ"
#import "parse/ascii.typ"
#import "parse/ascii.typ": even, fill
#import "parse/lyrics.typ" as lyric-source
#import "layout/lanes.typ": lane, stack-lanes
#import "layout/system.typ": layout-part
#import "render/tabstaff.typ"
#import "render/rhythm.typ"
#import "render/lyrics.typ" as lyric-lane
#import "render/chordnames.typ"
#import "render/techniques.typ"
#import "render/dynamics.typ"
#import "render/voltas.typ"
#import "page.typ": song, section, credits

/// Width every event needs for its fret numbers, and for its syllable.
///
/// Measured once and reused for spacing, for the gaps in the string lines and
/// for drawing, so the three can never disagree.
#let _glyph-widths(thm, part) = {
  part.measures.map(m => m.events.map(ev => (
    tabstaff.event-metrics(thm, ev) + (lyric: lyric-lane.event-width(thm, ev))
  )))
}

/// Report problems where the reader can actually see them.
///
/// Typst offers no user-level warning channel: `panic` is the only diagnostic
/// it has and it is fatal. A problem that must not stop the compile therefore
/// has nowhere to go but the page. That is the point — a bar that is short is
/// worth knowing about — and it is why `place(hide[…])` was the wrong answer:
/// it satisfied the type checker and showed the reader nothing.
///
/// `warn: false` on `tab` and `ascii-tab` silences this once the sheet is as
/// intended.
#let _diagnostics(thm, source, messages) = {
  if messages.len() == 0 { return }
  block(
    width: 100%,
    above: thm.staff-space * 0.7,
    below: thm.staff-space * 1.0,
    fill: rgb("#fdf3f0"),
    stroke: (left: 2pt + rgb("#b4491f")),
    inset: (x: 7pt, y: 5pt),
    // Sticky, so a page break can never strand the report on one page and the
    // music it describes on the next.
    sticky: true,
    text(
      font: thm.font,
      size: thm.technique-size,
      fill: rgb("#7a2e11"),
      messages.map(m => source + ": " + m).join(linebreak()),
    ),
  )
}

/// A moment as a rational, however it was written.
///
/// `(1, 2)` and `3` are both accepted beside a rational, because a caller
/// generating these by the hundred should not have to reach for the rational
/// constructor to say "half a whole note in".
#let _moment(position) = {
  if type(position) == array { rational.rat(position.at(0), den: position.at(1)) } else if (
    type(position) == int
  ) { rational.rat(position) } else { position }
}

/// One syllable of a verse written for **another part**, sung at a stated
/// moment: `measure` counting from zero, `position` whole notes into it.
///
/// Words made for the music being set need none of this — they are given as a
/// string and spent over the notes in order. This is for the other case: a
/// singer's words under a guitar's staff, where the two parts share bars but not
/// notes, so each syllable has to say when it falls and is then hung on whatever
/// is sounding then — a note, or a rest the voice sings through.
///
/// ```typc
/// tab(lyrics: (lyric-at(0, (1, 2), "one"), lyric-at(1, 0, "two")), ```q 0/6 0/6 | 0/6```)
/// ```
#let lyric-at(measure, position, text) = lyric-source.at(measure, _moment(position), text)

/// Put verses on the music, each in the form it was given.
///
/// A verse is either a run of syllables, spent in order over the events that are
/// sung — which is what words written for *this* music want — or a set of
/// moments, which is how words written for another part say where they go. The
/// two may be mixed: one voice's own verse and a borrowed one are both verses,
/// and each keeps its own lane whichever way it was placed.
///
/// The lane a verse lands in is its position in the argument, so a verse given
/// as moments is stood in for by an empty one while the others are spent. That
/// is what keeps verse two from being read as verse one.
#let _sing(part, verses) = {
  let sources = if type(verses) == str { (verses,) } else { verses }
  let spent = lyric-source.apply(
    part,
    sources.map(v => if lyric-source.is-timed(v) { "" } else { v }),
  )
  let hung = lyric-source.apply-timed(
    spent.part,
    sources.map(v => if lyric-source.is-timed(v) { v } else { () }),
  )
  (part: hung.part, warnings: spent.warnings + hung.warnings)
}

/// Typeset a passage of tablature.
///
/// `source` is either DSL source — a raw block or a string — or an already
/// parsed part, which lets callers build one programmatically.
///
/// `time` sets the signature for the whole passage; `[7/8]` in the source
/// changes it at a measure. Either way it is printed once, at the start —
/// pass `show-time: false` on the second and later blocks of one piece, so the
/// reader is told the meter once rather than at every heading.
///
/// `lyrics` is one string per verse, spent syllable by syllable over the notes
/// that are sung — rests, grace notes and the far ends of ties are skipped. A
/// trailing `-` hyphenates into the next syllable; `_` is a note the word before
/// it is held over. A verse may instead be given as timed syllables — see
/// `lyric-at` — which is how words written for another part say where they go.
///
/// `verse-labels` replaces the automatic numbering, one label per verse. `""`
/// leaves a row unlabelled, so two rows can share the number over the first —
/// which is how one stanza spanning two times round a repeat is set.
///
/// ```typc
/// tab(```
/// q (2/5 2/4 0/6)  q x  e 0/3 3/6 0/6 0/6
/// ```)
/// tab(lyrics: "Some- thing I can ne- ver say", ```q 0/6 2/6 3/6 5/6```)
/// ```
#let tab(
  source,
  tuning: tunings.standard,
  time: (4, 4),
  tempo: none,
  capo: 0,
  anacrusis: false,
  count-in: false,
  show-time: true,
  lyrics: none,
  verse-labels: none,
  theme: default-theme,
  warn: true,
) = {
  let thm = theme
  let parsed = if type(source) == dictionary and source.at("kind", default: none) == "part" {
    source
  } else {
    dsl.parse(source, tuning: tuning, time: time, tempo: tempo, capo: capo, anacrusis: anacrusis)
  }
  // Derived before anything measures or draws, so the widths reserved for the
  // fret numbers and the numbers actually printed agree about which of them are
  // parenthesised — and before the syllables are spent, since a note held by a
  // tie is not sung again.
  let part = model.mark-link-targets(model.mark-tie-targets(parsed))

  let problems = ()
  if lyrics != none {
    let sung = _sing(part, lyrics)
    part = sung.part
    problems += sung.warnings
  }

  // Reported rather than raised: a partially filled model is legal, and an
  // imported tab is often musically imperfect but still worth setting.
  if warn { _diagnostics(thm, "tab", problems + model.validate(part)) }

  layout(size => {
    let strings = string-count(part.tuning)
    let verses = lyric-lane.verse-count(part)
    let widths = _glyph-widths(thm, part)
    let systems = layout-part(
      thm,
      part,
      widths,
      size.width,
      thm.tab-mark-width,
      show-time: show-time,
      floating-widths: part.measures.map(m => lyric-lane.floating-widths(thm, m)),
    )

    // The system each verse begins on, which is the one that carries its number.
    let verse-starts = range(verses).map(v => {
      let first = none
      for (i, sys) in systems.enumerate() {
        if first == none and lyric-lane.sings(sys, v) { first = i }
      }
      first
    })

    for (i, sys) in systems.enumerate() {
      // Every lane is drawn to the system's own width, not to the full line: an
      // unjustified final system must stop at its last barline rather than
      // trailing string lines out to the margin.
      let w = sys.width

      // Top to bottom: the endings furthest out, as they bracket whole measures
      // rather than single events, then chord names, then technique marks
      // directly above the staff. Under it the rhythm, whose stems rise towards
      // the music they describe, then the dynamics and the count row.
      //
      // The verses come last, below all of it. A dynamic marks the music and
      // has to stay near the staff it marks: set above the lyrics it would be
      // pushed a row further out for every verse, until `mf` no longer read as
      // belonging to anything. Lyrics are running text and belong at the foot
      // of the system for the same reason a caption does.
      let lanes = (
        voltas.lane-for(thm, sys, w),
        chordnames.lane-for(thm, sys, w),
        techniques.lane-for(thm, sys, w),
        {
          // Bends and slurs are anchored to their own string and reach above the
          // top line by an amount that depends on which string that is, and a
          // fret number on the lowest string hangs below it. The staff lane
          // reserves both rather than overflowing into its neighbours.
          let over = tabstaff.overflow-above(thm, sys)
          let under = tabstaff.overflow-below(thm, strings, sys)
          lane(over + tabstaff.height(thm, strings) + under, () => tabstaff.draw(
            thm,
            strings,
            sys,
            w,
            overflow: over,
          ))
        },
        rhythm.lane-for(thm, sys, w),
        dynamics.lane-for(thm, sys, w),
        rhythm.count-lane-for(thm, sys, w, enabled: count-in and i == 0),
        ..range(verses).map(v => lyric-lane.lane-for(
          thm,
          sys,
          w,
          v,
          numbered: (verses > 1 or verse-labels != none) and verse-starts.at(v) == i,
          tag: if verse-labels == none { none } else { verse-labels.at(v, default: "") },
        )),
      )
      // A system must never be split by a page break.
      block(breakable: false, stack-lanes(lanes, w, thm.lane-gap))
      if i < systems.len() - 1 { v(thm.system-gap, weak: true) }
    }
  })
}

/// Render a part programmatically, bypassing the DSL.
#let render(part, theme: default-theme, count-in: false, show-time: true, lyrics: none) = tab(
  part,
  theme: theme,
  count-in: count-in,
  show-time: show-time,
  lyrics: lyrics,
)

/// Typeset a pasted ASCII tab.
///
/// A bare paste always renders. Everything ASCII tab cannot carry — note
/// values, chord names, sections, spans — can be supplied, and supplying it is
/// optional and incremental:
///
/// - **Column-aligned annotation rows** inside the block, which is the primary
///   mechanism because a fact attaches to exactly the column it describes:
///   `R:` note values, `C:` chord names, `L:` sung syllables — one row per
///   verse — `S:` a section heading, `T:` a playing instruction, `D:` dynamics,
///   `PM:` and `LR:` bracketed spans.
/// - **Named arguments** for facts about the whole piece: `tuning`, `time`,
///   `tempo`, `capo`, `anacrusis`.
/// - **`rhythm:`** for the common cases: `even(1/8)`, `fill`, or an explicit
///   sequence such as `"q q e e"`, and **`lyrics:`** for verses spent syllable
///   by syllable, as on `tab`. `L:` rows win: where they supply syllables the
///   argument is ignored and says so.
///
/// `enrich` is the escape hatch for anything the three do not cover: it
/// receives the parsed part and returns a modified one.
///
/// `show-time: false` suppresses the time signature, as on `tab`. A piece pasted
/// in several blocks is several calls, and the meter is a thing the reader is
/// told once — so every block after the first should pass it.
///
/// ```typc
/// ascii-tab(```
/// R:   q   q   e e
/// e|---0---2---3-5--|
/// ```, rhythm: even(1/8))
/// ```
#let ascii-tab(
  source,
  tuning: tunings.standard,
  time: (4, 4),
  tempo: none,
  capo: 0,
  anacrusis: false,
  rhythm: none,
  lyrics: none,
  count-in: false,
  show-time: true,
  theme: default-theme,
  enrich: none,
  warn: true,
) = {
  let result = ascii.parse(
    source,
    tuning: tuning,
    time: time,
    tempo: tempo,
    capo: capo,
    anacrusis: anacrusis,
    rhythm: rhythm,
  )
  let part = if enrich != none { enrich(result.part) } else { result.part }
  let problems = result.warnings

  // Spent over the whole piece before it is cut into sections: the cursor runs
  // through the music, and restarting it at every heading would put verse one
  // under every section.
  if lyrics != none and lyric-source.has-lyrics(part) {
    problems.push("lyrics: the L: rows already carry syllables, so the argument was ignored")
  } else if lyrics != none {
    let sung = _sing(model.mark-tie-targets(part), lyrics)
    part = sung.part
    problems += sung.warnings
  }

  // Sections carried by `S:` rows are headings in their own right, and a
  // heading in the middle of the piece must land *between* the measures it
  // separates — which means the music is rendered in one run per section
  // rather than in one call. An `S:` row used to print only when it came
  // before the first measure; later ones vanished without a word.
  let cuts = part.sections.map(mk => mk.index).dedup().sorted()
  let starts = if cuts.len() == 0 or cuts.first() != 0 { (0,) + cuts } else { cuts }
  for (si, from) in starts.enumerate() {
    let to = starts.at(si + 1, default: part.measures.len())
    for mark in part.sections {
      if mark.index == from { section(mark.title, theme: theme) }
    }
    if to <= from { continue }
    tab(
      model.part(
        measures: part.measures.slice(from, to),
        tuning: part.tuning,
        time: part.time,
        tempo: part.tempo,
        capo: part.capo,
        anacrusis: part.anacrusis and from == 0,
      ),
      theme: theme,
      // The count row belongs to the pick-up into the piece, not to every
      // section — and neither does the time signature, which is one piece of
      // information however many sections it has been cut into.
      count-in: count-in and from == 0,
      show-time: show-time and from == 0,
      warn: false,
    )
  }
  // A heading at the very end — `mark.index == measures.len()` — is its own
  // cut, so the loop above prints it and then finds no music to set under it,
  // which is the right outcome for an outro the transcriber never finished.

  // Malformed input is reported but never fatal: a real tab is usually
  // imperfect, and refusing to set it would defeat the purpose of importing.
  if warn {
    _diagnostics(theme, "ascii-tab", problems + model.validate(part))
  }
}

/// Convert an ASCII tab to equivalent DSL source.
///
/// Once a tab is fully annotated it is as complete as one written by hand, and
/// this is how it graduates to the native syntax: import, print, keep.
#let ascii-to-dsl(source, ..args) = dsl.write(ascii.parse(source, ..args).part)
