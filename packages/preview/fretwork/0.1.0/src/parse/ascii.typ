// ASCII tab import.
//
// Reads the plain-text tab found on sites like Ultimate Guitar and produces the
// same model the native DSL does, so the whole rendering chain is reused
// unchanged.
//
// The honest limitation is that ASCII tab carries almost nothing beyond fret
// positions: no note values, time signature, tuning, sections or repeats.
// Without note values there are no stems, no beams and no optical spacing, so a
// bare paste is laid out from the source's own column positions instead —
// considerably better than monospaced text, but with no rhythm lane.
//
// Everything missing can be supplied, and supplying it is optional and
// incremental. Three mechanisms, in the order they should be reached for:
//
//   1. Column-aligned annotation rows (`R:`, `C:`, `S:`, `PM:`, …). Being
//      column-aligned is the whole point: a fact attaches to exactly the column
//      it describes, so a tab can be annotated a little or a lot.
//   2. Named arguments, for facts about the whole piece that have no column.
//   3. Inference helpers, for the common cases where annotating every column
//      would be busywork.
//
// Annotation rows win over named arguments, which win over inference.

#import "../rational.typ" as r
#import "../model.typ" as m
#import "../tuning.typ": string-count, tunings
#import "errors.typ"
#import "dsl.typ": DYNAMICS, source-text

#let _DIGITS = ("0", "1", "2", "3", "4", "5", "6", "7", "8", "9")

/// Recognised annotation row prefixes and what they carry.
#let ANNOTATION-KEYS = (
  "R", // note values, using the DSL's own duration tokens
  "C", // chord names
  "S", // section heading
  "T", // free playing instruction
  "D", // dynamics
  "PM", // palm mute span
  "LR", // let ring span
  "1", // first ending
  "2", // second ending
)

// ---------------------------------------------------------------------------
// Inference helpers
// ---------------------------------------------------------------------------

/// Treat every event as the same note value.
///
/// `even(1/8)` covers a large share of real riffs in one word.
#let even(value) = {
  // Accept both `even(1/8)`, which Typst evaluates to a float, and `even(8)`.
  let den = if type(value) == int { value } else { int(calc.round(1 / value)) }
  (kind: "even", value: r.rat(1, den: den))
}

/// Spread each bar's events evenly across the time signature.
///
/// Often musically wrong, which is why it must be asked for: it is a way to get
/// beams out of a tab whose rhythm is regular, not a way to guess one.
#let fill = (kind: "fill")

// ---------------------------------------------------------------------------
// Line classification
// ---------------------------------------------------------------------------

/// Whether a line looks like a string of tablature.
///
/// The test is that the line is mostly made of the characters tab is written
/// with. Real tabs are surrounded by titles, comments and chord charts, and
/// those must not be mistaken for music.
#let _is-tab-row(line) = {
  let body = line.trim()
  if body.len() < 4 { return false }
  let chars = body.clusters()
  let tabbish = chars.filter(c => c in ("-", "|", "—", "=")).len()
  // A string row is dominated by its filler; even a busy one is over half.
  tabbish * 2 > chars.len()
}

/// Split a `PREFIX:` annotation line into its key and the rest.
///
/// Returns `none` when the line carries no known prefix. The column offset of
/// the content is kept, since annotations attach by column.
#let _annotation(line) = {
  let idx = line.position(":")
  if idx == none { return none }
  let key = line.slice(0, idx).trim()
  if key not in ANNOTATION-KEYS { return none }
  (key: key, offset: idx + 1, text: line.slice(idx + 1))
}

/// The label at the start of a tab row, e.g. the `e` of `e|---0---`.
///
/// Returns `(label, offset)` where `offset` is the column the music starts at,
/// so that every row in a block can be aligned even when their labels differ in
/// width.
#let _row-head(line) = {
  let chars = line.clusters()
  let i = 0
  while i < chars.len() and chars.at(i) == " " { i += 1 }
  let start = i
  while i < chars.len() and not (chars.at(i) in ("-", "|", "—", "=")) { i += 1 }
  let label = chars.slice(start, i).join().trim()
  // A leading `|` belongs to the music: it is the opening barline.
  (label: label, offset: i)
}

// ---------------------------------------------------------------------------
// Row parsing
// ---------------------------------------------------------------------------

#let _TECHNIQUE-CHARS = ("h", "p", "b", "r", "s", "/", "\\", "~", "*", "t", "v", "f")

// Markers that join the note before them to the note after them. Written tabs
// put the target wherever the column happens to fall — `5h7`, `5h-7`, `5-h-7`
// and `5h  7` all mean the same hammer-on — so these are held until the next
// note on the row turns up rather than requiring a digit immediately after.
#let _LINKING = ("h", "p", "s", "/", "\\")

// Tapping marks the note it precedes, not the one before it.
#let _PRECEDING = ("t",)

/// Attach a held marker now that the note it was waiting for has been found.
///
/// `previous` is the note the marker hangs off, `fret` the one it points at.
#let _resolve(mark, fret) = {
  if mark == "h" {
    m.technique("hammer", fret: fret)
  } else if mark == "p" {
    m.technique("pull", fret: fret)
  } else {
    m.technique("slide", fret: fret, legato: true)
  }
}

/// Read one string row into `(column, item)` records.
///
/// Multi-digit frets are the reason this scans characters rather than splitting
/// on separators: adjacent digits are one fret and digits parted by filler are
/// separate strikes, which is the universal convention and the only reading of
/// `-11-` against `-1-1-` that makes sense.
#let _parse-row(line, start) = {
  let chars = line.clusters()
  let items = ()
  let warnings = ()
  let i = start
  // Markers seen since the last note, waiting for the note they point at, and
  // where in `items` that last note sits so the marker can be hung off it.
  let pending = ()
  let last = none

  while i < chars.len() {
    let c = chars.at(i)

    if c == "|" {
      items.push((col: i, kind: "bar"))
      i += 1
      continue
    }

    if c in ("x", "X") {
      items.push((col: i, kind: "note", fret: m.MUTED, techniques: ()))
      last = items.len() - 1
      pending = ()
      i += 1
      continue
    }

    // A ghost note is written in parentheses.
    let ghost = c == "("
    if ghost { i += 1 }

    if i < chars.len() and chars.at(i) in _DIGITS {
      let col = if ghost { i - 1 } else { i }
      let start-digits = i
      while i < chars.len() and chars.at(i) in _DIGITS { i += 1 }
      let fret = int(chars.slice(start-digits, i).join())
      let techniques = if ghost { (m.technique("ghost"),) } else { () }
      if ghost and i < chars.len() and chars.at(i) == ")" { i += 1 }

      // A chain of techniques may follow, each optionally naming a target fret.
      let held = ()
      // Where the chain has arrived. A hammer-on, pull-off or slide moves it, so
      // a bend later in the chain measures from there: in `5h7b9` the bend runs
      // from the hammered 7 up to 9, one step, not from the struck 5.
      let reached = fret
      while i < chars.len() and chars.at(i) in _TECHNIQUE-CHARS {
        let mark = chars.at(i)
        i += 1

        // `hb` and `fb` spell the size of a bend out in letters instead of
        // leaving it to be worked out from a target fret: half bend and full
        // bend, as the legends that define them put it. Unambiguous despite `h`
        // otherwise meaning a hammer-on, because a hammer-on always writes its
        // target as digits, so an `h` pressed directly against a `b` can only be
        // this.
        let spelled = none
        if mark in ("h", "f") and i < chars.len() and chars.at(i) == "b" {
          spelled = if mark == "h" { r.rat(1, den: 2) } else { r.rat(1) }
          mark = "b"
          i += 1
        }

        let target = none
        // Digits after a spelled size are the next note, not a target: `7fb5` is
        // a full bend on the 7th fret and then the 5th, and reading the 5 as a
        // target both swallowed the note and refused the bend for not rising.
        if spelled == none {
          let d = i
          while d < chars.len() and chars.at(d) in _DIGITS { d += 1 }
          if d > i {
            target = int(chars.slice(i, d).join())
            i = d
          }
        }
        if mark in _LINKING {
          // Resolved here when the target is adjacent, held for the next note
          // on the row when it is not.
          if target != none {
            techniques.push(_resolve(mark, target))
            reached = target
          } else { held.push(mark) }
        } else if mark == "b" {
          // `7b9` bends up to the pitch of fret 9: two frets to a whole step. A
          // bare `b` is a whole step, which is what an unqualified bend means.
          if target != none and target <= reached {
            // A bend can only rise. `5b3` used to come out as an upward arrow
            // labelled "−1" — nonsense set in ink. The note survives; only the
            // arrow is refused.
            warnings.push(
              "bend " + str(reached) + "b" + str(target)
                + " does not rise; ignored (a release is written "
                + str(reached) + "b" + str(reached + 2) + "r" + str(reached) + ")",
            )
          } else {
            let amount = if target != none {
              r.rat(target - reached, den: 2)
            } else if spelled != none {
              spelled
            } else {
              r.rat(1)
            }
            techniques.push(m.technique("bend", amount: amount, release: false, pre: false))
          }
        } else if mark == "r" {
          // A release only ever follows a bend, so fold it into the one before.
          if techniques.len() > 0 and techniques.last().kind == "bend" {
            let bend = techniques.pop()
            techniques.push(m.technique(
              "bend",
              amount: bend.amount,
              release: true,
              pre: bend.pre,
            ))
          }
        } else if mark == "~" or mark == "v" {
          techniques.push(m.technique("vibrato", wide: false))
        } else if mark == "*" {
          techniques.push(m.technique("harmonic", style: "natural"))
        } else if mark == "t" {
          techniques.push(m.technique("tap"))
        }
      }

      items.push((col: col, kind: "note", fret: fret, techniques: techniques))
      let index = items.len() - 1

      // Hang everything held over onto the pair of notes it joins. Written out
      // rather than factored into a helper: a Typst closure captures its
      // environment by value, so a helper could not update `items` here.
      for mark in pending {
        if mark in _PRECEDING {
          let n = items.at(index)
          items.at(index) = (..n, techniques: n.techniques + (m.technique("tap"),))
        } else if last != none {
          let n = items.at(last)
          items.at(last) = (..n, techniques: n.techniques + (_resolve(mark, fret),))
        }
      }

      pending = held
      last = index
      continue
    }

    // A marker standing in the filler, between the note it hangs off and the
    // one it points at.
    if c in _LINKING or c in _PRECEDING {
      pending.push(c)
      i += 1
      continue
    }

    i += 1
  }

  (items: items, warnings: warnings)
}

// ---------------------------------------------------------------------------
// Annotation parsing
// ---------------------------------------------------------------------------

/// Split an annotation row into `(column, token)` pairs.
#let _tokens-with-columns(text, offset) = {
  let chars = text.clusters()
  let out = ()
  let i = 0
  while i < chars.len() {
    if chars.at(i) == " " {
      i += 1
      continue
    }
    let start = i
    while i < chars.len() and chars.at(i) != " " { i += 1 }
    out.push((col: offset + start, token: chars.slice(start, i).join()))
  }
  out
}

/// Split an annotation row on runs of two or more spaces.
///
/// Chord names and playing instructions may contain single spaces — "w/ bar",
/// "C#m7 add9" — so only a visible gap separates one from the next.
#let _phrases-with-columns(text, offset) = {
  let chars = text.clusters()
  let out = ()
  let i = 0
  while i < chars.len() {
    if chars.at(i) == " " {
      i += 1
      continue
    }
    let start = i
    let end = i
    while i < chars.len() {
      if chars.at(i) == " " and i + 1 < chars.len() and chars.at(i + 1) == " " { break }
      if chars.at(i) != " " { end = i + 1 }
      i += 1
    }
    out.push((col: offset + start, token: chars.slice(start, end).join()))
  }
  out
}

/// Read a note value written the way the DSL writes it.
///
/// Reusing the DSL's tokens is deliberate: there is no second notation to learn
/// and no second parser to keep in step.
#let _duration-token(token) = {
  let chars = token.clusters()
  if chars.len() == 0 or chars.at(0) not in m.durations { return none }
  let dots = chars.slice(1).filter(c => c == ".").len()
  if chars.len() != 1 + dots { return none }
  m.dotted(m.durations.at(chars.at(0)), dots)
}

/// The columns a span row covers, as `(start, end)` runs of dashes.
#let _span-runs-in(text, offset) = {
  let chars = text.clusters()
  let runs = ()
  let start = none
  for (i, c) in chars.enumerate() {
    if c in ("-", "_", "=") {
      if start == none { start = i }
    } else if start != none {
      runs.push((start: offset + start, end: offset + i))
      start = none
    }
  }
  if start != none { runs.push((start: offset + start, end: offset + chars.len())) }
  runs
}

// ---------------------------------------------------------------------------
// Block assembly
// ---------------------------------------------------------------------------

/// Group the source into blocks of string rows with their annotation rows.
#let _blocks(lines, strings) = {
  let blocks = ()
  let pending = ()
  let rows = ()
  let warnings = ()

  for line in lines {
    // Annotations are recognised first: a span row is made almost entirely of
    // dashes and would otherwise be mistaken for a string.
    let ann = _annotation(line)
    if ann != none {
      pending.push(ann)
      continue
    }

    if _is-tab-row(line) {
      rows.push(line)
      if rows.len() == strings {
        blocks.push((annotations: pending, rows: rows))
        pending = ()
        rows = ()
      }
      continue
    }

    if line.trim() != "" and rows.len() > 0 {
      warnings.push("ignored line inside a tab block: " + line.trim())
    }
  }

  if rows.len() > 0 {
    warnings.push(
      "the last block has " + str(rows.len()) + " string rows, expected " + str(strings),
    )
  }
  (blocks: blocks, warnings: warnings)
}

/// Work out which model string each row of a block refers to.
///
/// Tabs are written highest string first. A block whose labels match the tuning
/// reversed is written the other way round, which some editors do.
#let _string-order(heads, tuning) = {
  let labels = heads.map(h => lower(h.label.replace("|", "")))
  let expected = tuning.labels.map(l => lower(l))
  if labels == expected.rev() {
    return range(heads.len(), 0, step: -1)
  }
  range(1, heads.len() + 1)
}

// ---------------------------------------------------------------------------
// Main entry point
// ---------------------------------------------------------------------------

/// Apply a rhythm specification to the events that still have no note value.
///
/// Annotation rows have already run by this point, so anything they set is left
/// alone: the precedence is annotation, then argument, then inference.
#let apply-rhythm(part, spec) = {
  // An explicit sequence of note values, spent event by event.
  let sequence = if type(spec) == str {
    spec
      .split(" ")
      .map(t => t.trim())
      .filter(t => t != "" and t != "|")
      .map(_duration-token)
      .filter(d => d != none)
  } else { none }

  let index = 0
  let measures = ()
  for measure in part.measures {
    let events = ()
    // Spreading a bar evenly needs to know how many events share it.
    let per-event = if spec == fill and measure.events.len() > 0 and part.time != none {
      r.rat(part.time.at(0), den: part.time.at(1) * measure.events.len())
    } else { none }

    for ev in measure.events {
      let value = if ev.duration != none {
        ev.duration
      } else if sequence != none {
        let d = sequence.at(calc.rem(index, calc.max(1, sequence.len())), default: none)
        d
      } else if type(spec) == dictionary and spec.at("kind", default: none) == "even" {
        spec.value
      } else { per-event }
      index += 1
      events.push(m.event(
        notes: ev.notes,
        duration: value,
        rest: ev.kind == "rest",
        spans: ev.spans,
        tuplet: ev.tuplet,
        chord: ev.chord,
        text: ev.text,
        column-span: ev.column-span,
      ))
    }
    measures.push(m.measure(
      events: events,
      time: measure.time,
      start-repeat: measure.start-repeat,
      end-repeat: measure.end-repeat,
      end: measure.end,
      volta: measure.volta,
      repeat-count: measure.repeat-count,
    ))
  }

  m.part(
    measures: measures,
    tuning: part.tuning,
    time: part.time,
    tempo: part.tempo,
    capo: part.capo,
    anacrusis: part.anacrusis,
    sections: part.sections,
  )
}

/// Parse ASCII tab into a part.
///
/// Returns `(part: …, warnings: (…))`. Warnings never stop the parse: a real
/// tab is usually imperfect, and refusing to render it would defeat the point.
#let parse(
  source,
  tuning: tunings.standard,
  time: (4, 4),
  tempo: none,
  capo: 0,
  anacrusis: false,
  rhythm: none,
) = {
  let text = source-text(source)
  let strings = string-count(tuning)
  let lines = text.split("\n")
  let grouped = _blocks(lines, strings)
  let warnings = grouped.warnings

  let measures = ()
  let events = ()
  // The source column of every event in the open measure, so that when the
  // measure closes it can be matched against the ending rows' dash runs.
  let event-cols = ()
  // Dash runs from `1:` and `2:` rows. Columns only mean anything within one
  // block, so this is rebuilt per block; a measure is matched by the block it
  // *closes* in.
  let volta-runs = ()
  let sections = ()
  // Note values are sticky across the whole piece, as in the DSL.
  let duration = none
  let pending-tuplet = none
  let tuplet-left = 0

  for block in grouped.blocks {
    let heads = block.rows.map(_row-head)
    let order = _string-order(heads, tuning)

    // Every row of a block must start its music at the same column, or the
    // columns no longer mean simultaneity.
    let offset = heads.fold(0, (acc, h) => calc.max(acc, h.offset))
    let lengths = block.rows.map(row => row.clusters().len())
    if lengths.len() > 0 and calc.max(..lengths) - calc.min(..lengths) > 1 {
      warnings.push("string rows in a block have different lengths; columns may be misaligned")
    }

    // Collect every note and barline, keyed by the column it sits in.
    let by-column = (:)
    let bar-columns = ()
    for (row-index, row) in block.rows.enumerate() {
      let string = order.at(row-index)
      let parsed = _parse-row(row, offset)
      warnings += parsed.warnings
      for item in parsed.items {
        if item.kind == "bar" {
          if str(item.col) not in bar-columns { bar-columns.push(str(item.col)) }
          continue
        }
        if item.fret != m.MUTED and item.fret > 24 {
          warnings.push("fret " + str(item.fret) + " is above the 24th")
        }
        let key = str(item.col)
        let existing = by-column.at(key, default: ())
        by-column.insert(key, existing + (m.note(string, item.fret, techniques: item.techniques),))
      }
    }

    // Annotations, resolved to columns.
    let annotations = (:)
    for ann in block.annotations {
      let existing = annotations.at(ann.key, default: ())
      annotations.insert(ann.key, existing + (ann,))
    }
    let durations-at = annotations
      .at("R", default: ())
      .map(a => _tokens-with-columns(a.text, a.offset))
      .flatten()
    let chords-at = annotations
      .at("C", default: ())
      .map(a => _phrases-with-columns(a.text, a.offset))
      .flatten()
    let texts-at = annotations
      .at("T", default: ())
      .map(a => _phrases-with-columns(a.text, a.offset))
      .flatten()
    let dynamics-at = annotations
      .at("D", default: ())
      .map(a => _tokens-with-columns(a.text, a.offset))
      .flatten()
    let spans-at = ()
    for key in ("PM", "LR") {
      for a in annotations.at(key, default: ()) {
        for run in _span-runs-in(a.text, a.offset) {
          spans-at.push((name: key, start: run.start, end: run.end))
        }
      }
    }
    // Ending rows mark their extent with dashes the way span rows do, but they
    // attach to measures rather than to events.
    volta-runs = ()
    for key in ("1", "2") {
      for a in annotations.at(key, default: ()) {
        for run in _span-runs-in(a.text, a.offset) {
          volta-runs.push((number: int(key), start: run.start, end: run.end))
        }
      }
    }
    for a in annotations.at("S", default: ()) {
      sections.push(m.section-mark(measures.len(), a.text.trim()))
    }

    // Walk the columns in order, turning note columns into events and barline
    // columns into measure breaks.
    let note-columns = by-column.keys().map(int)
    let all-columns = ()
    for col in (note-columns + bar-columns.map(int)).sorted() {
      if all-columns.len() == 0 or all-columns.last() != col { all-columns.push(col) }
    }

    // Resolve the sticky note value and any tuplet for each column in one pass,
    // rather than rescanning the annotation row per event.
    let sorted-tokens = durations-at.sorted(key: t => t.col)
    let value-at = (:)
    let tuplet-at = (:)
    let cursor = 0
    for col in all-columns {
      while cursor < sorted-tokens.len() and sorted-tokens.at(cursor).col <= col + 1 {
        let token = sorted-tokens.at(cursor).token
        if token.ends-with(":") {
          // `3:` opens a tuplet covering the next three events.
          let count = token.slice(0, -1)
          if count.clusters().all(c => c in _DIGITS) and int(count) >= 2 {
            let n = int(count)
            let of = if n in (2, 4) {
              3
            } else {
              let p = 1
              while p * 2 < n { p = p * 2 }
              p
            }
            pending-tuplet = (count: n, of: of)
            tuplet-left = n
          }
        } else {
          let value = _duration-token(token)
          if value != none { duration = value }
        }
        cursor += 1
      }
      value-at.insert(str(col), duration)
      if tuplet-left > 0 and str(col) in by-column {
        tuplet-at.insert(str(col), pending-tuplet)
        tuplet-left -= 1
      }
    }

    // Attach each column annotation to the single nearest event, so two events
    // a column apart cannot both claim the same chord name.
    let nearest-event(target) = {
      let best = none
      for col in all-columns {
        if str(col) not in by-column { continue }
        if best == none or calc.abs(col - target) < calc.abs(best - target) { best = col }
      }
      if best != none and calc.abs(best - target) <= 3 { best } else { none }
    }
    let chord-at = (:)
    for token in chords-at {
      let col = nearest-event(token.col)
      if col != none {
        chord-at.insert(str(col), token.token)
      } else {
        warnings.push("chord '" + token.token + "' has no note within 3 columns; ignored")
      }
    }
    let text-at = (:)
    for token in texts-at {
      let col = nearest-event(token.col)
      if col != none {
        text-at.insert(str(col), token.token)
      } else {
        warnings.push("instruction '" + token.token + "' has no note within 3 columns; ignored")
      }
    }
    let dynamic-at = (:)
    for token in dynamics-at {
      let col = nearest-event(token.col)
      if col == none {
        warnings.push("dynamic '" + token.token + "' has no note within 3 columns; ignored")
      } else if token.token not in DYNAMICS {
        warnings.push("unknown dynamic '" + token.token + "'; ignored")
      } else {
        dynamic-at.insert(str(col), token.token)
      }
    }

    for (idx, col) in all-columns.enumerate() {
      if str(col) in bar-columns and str(col) not in by-column {
        if events.len() > 0 {
          // The measure belongs to an ending when any of its events sits under
          // a dash run. Inlined at both close sites: a helper closure would
          // capture `volta-runs` by value, before the block rebuilt it.
          let volta = none
          for run in volta-runs {
            if volta == none and event-cols.any(c => c >= run.start - 1 and c <= run.end) {
              volta = (run.number,)
            }
          }
          measures.push(m.measure(events: events, volta: volta))
          events = ()
          event-cols = ()
        }
        continue
      }

      let spans = spans-at.filter(s => col >= s.start - 1 and col <= s.end).map(s => s.name)

      // How wide this event was in the source, so a tab with no note values is
      // still spaced the way its author laid it out.
      let next-col = if idx + 1 < all-columns.len() { all-columns.at(idx + 1) } else { col + 4 }
      let span = calc.max(0.35, calc.min(4.0, (next-col - col) / 4.0))

      events.push(m.event(
        notes: by-column.at(str(col), default: ()),
        duration: value-at.at(str(col), default: none),
        spans: spans,
        tuplet: tuplet-at.at(str(col), default: none),
        chord: chord-at.at(str(col), default: none),
        text: text-at.at(str(col), default: none),
        dynamic: dynamic-at.at(str(col), default: none),
        column-span: span,
      ))
      event-cols.push(col)
    }
  }

  if events.len() > 0 {
    let volta = none
    for run in volta-runs {
      if volta == none and event-cols.any(c => c >= run.start - 1 and c <= run.end) {
        volta = (run.number,)
      }
    }
    measures.push(m.measure(events: events, volta: volta))
  }

  let part = m.part(
    measures: measures,
    tuning: tuning,
    time: time,
    tempo: tempo,
    capo: capo,
    anacrusis: anacrusis,
    sections: sections,
  )

  // Inference, applied only where annotation left the value unknown.
  if rhythm != none { part = apply-rhythm(part, rhythm) }

  (part: part, warnings: warnings)
}
