// ASCII tab import.
//
// Reads the plain-text tab found on sites like Ultimate Guitar and produces the
// same model the native DSL does, so the whole rendering chain is reused
// unchanged.
//
// The honest limitation is that ASCII tab carries almost nothing beyond fret
// positions and the barlines between them: no note values, time signature,
// tuning or sections.
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
#import "lyrics.typ": read-syllable

#let _DIGITS = ("0", "1", "2", "3", "4", "5", "6", "7", "8", "9")

/// The highest fret a number can name. Beyond it a run of digits cannot be one.
#let _MAX-FRET = 24

/// Read the fret written at `i`, returning `(fret, next-index)`.
///
/// Digits run together are one fret only as far as that fret exists: `-10-` is
/// the 10th, but nothing is fretted at the 77th, so `-77-` is a 7 and another 7
/// struck a column apart — which is how every source writes two quick notes on
/// one string. Reading such runs greedily is what turned a bar of eighth-note
/// power chords into a page of "fret 333 is above the 24th".
///
/// A leading zero never opens a number either, so `-010-` is the open string and
/// then the 10th rather than the 1st and the open string.
#let _read-fret(chars, i) = {
  let pair = (
    i + 1 < chars.len()
      and chars.at(i) != "0"
      and chars.at(i + 1) in _DIGITS
      and int(chars.at(i) + chars.at(i + 1)) <= _MAX-FRET
  )
  let stop = if pair { i + 2 } else { i + 1 }
  (int(chars.slice(i, stop).join()), stop)
}

/// Recognised annotation row prefixes and what they carry.
#let ANNOTATION-KEYS = (
  "R", // note values, using the DSL's own duration tokens
  "C", // chord names
  "L", // sung syllables, one row per verse
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
///
/// Fret numbers count towards that, not only the filler. Counting the filler
/// alone penalises exactly the rows carrying the most music: two-digit frets
/// with single dashes between them push the filler under half and the row was
/// dropped as prose. Measured on a real transcription — Nirvana, *All
/// Apologies*, 252 string rows — two were lost that way, both of the form
/// `G#|---9-10---10s12-12-10-9-|`, at 0.49 filler. With the digits counted they
/// score 0.88.
#let _is-tab-row(line) = {
  let body = line.trim()
  if body.len() < 4 { return false }
  let chars = body.clusters()
  let tabbish = chars.filter(c => c in ("-", "|", "—", "=") or c in _DIGITS).len()
  // A string row is dominated by that alphabet; even a busy one is over half.
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

// Markers that join the note before them to the note after them. Held until the
// next note on the row turns up rather than requiring a digit immediately after,
// since written tabs put the target wherever the column happens to fall.
//
// Where it falls decides what is drawn. `5h7`, digits pressed against the mark,
// is one event with the target printed beside it, sharing its note value — the
// two numbers of a hammer-on as the legend sets them. `5-h-7` spent a column on
// the target, so it is a second event with its own value, joined by a slur that
// runs from one to the other. A tab that puts the target in the next bar can
// only mean the second, and used to get both: a phantom 7 beside the first note
// and the real one after the barline.
#let _LINKING = ("h", "p", "s", "/", "\\")

// Tapping marks the note it precedes, not the one before it.
#let _PRECEDING = ("t",)

/// Build the technique a marker stands for.
///
/// `fret` is the target it points at, or `none` where the target is an event of
/// its own and the link runs to it rather than printing its number again.
#let _resolve(mark, fret) = {
  if mark == "h" {
    m.technique("hammer", fret: fret)
  } else if mark == "p" {
    m.technique("pull", fret: fret)
  } else {
    m.technique("slide", fret: fret, legato: true)
  }
}

/// The slide a marker stands for when no note ever comes for it to reach.
///
/// A row ending `-15\-------` is the note slid *off*, which is a mark in its own
/// right and not a mark that failed: the arrow says which way the pitch leaves
/// and there is nothing more to say. `/` climbs and `\` falls; a bare `s` names
/// no direction, and falls, which is what sliding out of a note ordinarily does.
/// A hammer-on or pull-off to nowhere means nothing, and is dropped as before.
#let _resolve-out(mark) = {
  if mark not in ("s", "/", "\\") { return none }
  m.technique("slide", fret: none, legato: true, out: if mark == "/" { "up" } else { "down" })
}

/// Marks written against the fret in two capitals, as Ultimate Guitar writes
/// its harmonics: `7PH`.
///
/// Read in capitals only, which collides with nothing: every technique letter
/// inside a row is lower case. Sources also write these on a line of their own
/// above the staff, which reaches the page as a `T:` row instead.
///
/// A pick scrape is written the same way and read at the same point. It is the
/// one of these with no pitch of its own — both legends draw an X on the string
/// — so it is written against an `x` rather than a number: `xPS`.
#let _CAPITAL-MARKS = (
  NH: m.technique("harmonic", style: "natural"),
  PH: m.technique("harmonic", style: "pinch"),
  AH: m.technique("harmonic", style: "artificial"),
  HH: m.technique("harmonic", style: "harp"),
  TH: m.technique("harmonic", style: "tap"),
  PS: m.technique("scrape", fret: none),
)

/// Marks that read a target fret written against them, as `xPS1` does.
///
/// A harmonic takes none, so `7PH5` is the harmonic and then the fifth. A pick
/// scrape does: the fret is where the pick stops, and it is no more a second
/// attack than a slide's target is — which is why the digits belong to the mark
/// here and to the next note there.
#let _CAPITAL-TAKES-FRET = ("PS",)

/// The two-capital mark written at `i`, with the target fret it may carry.
///
/// Returns `(technique, next)` or `none`.
#let _capital-mark-at(chars, i) = {
  if i + 1 >= chars.len() { return none }
  let name = chars.at(i) + chars.at(i + 1)
  let mark = _CAPITAL-MARKS.at(name, default: none)
  if mark == none { return none }
  let next = i + 2
  if name not in _CAPITAL-TAKES-FRET { return (technique: mark, next: next) }
  if next >= chars.len() or chars.at(next) not in _DIGITS {
    return (technique: mark, next: next)
  }
  let (fret, after) = _read-fret(chars, next)
  (technique: mark + (fret: fret), next: after)
}

/// Read the `x3` that may follow a repeat's closing stroke, as `(count, next)`.
///
/// Only read after a `:|`, and only when digits follow the `x`: `x` is also a
/// dead note, so `|x3` in the middle of a row is a muted string and then the
/// third fret. After a repeat sign that reading is not open — nothing is struck
/// on the far side of the stroke that closes a bar.
#let _repeat-count(chars, i, ends) = {
  if not ends or i >= chars.len() or lower(chars.at(i)) != "x" { return (none, i) }
  let j = i + 1
  while j < chars.len() and chars.at(j) in _DIGITS { j += 1 }
  if j == i + 1 { return (none, i) }
  (int(chars.slice(i + 1, j).join()), j)
}

/// Read one string row into `(column, item)` records.
///
/// Multi-digit frets are the reason this scans characters rather than splitting
/// on separators: adjacent digits are one fret and digits parted by filler are
/// separate strikes, which is the universal convention and the only reading of
/// `-11-` against `-1-1-` that makes sense.
///
/// `valued` is the set of columns the block's `R:` row gives a note value to,
/// as string keys. It decides one thing: whether a linking mark's target is a
/// second number inside this event or an event of its own — see `_link-target`.
#let _parse-row(line, start, valued: ()) = {
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

    // A barline, together with the repeat colons that may sit on either side of
    // it: `|:` opens a repeat, `:|` closes one, `:|:` does both where a repeated
    // section runs straight into the next. The colons are read as music rather
    // than skipped as filler because a section played four times and one played
    // once are not the same piece.
    if c == "|" or (c == ":" and i + 1 < chars.len() and chars.at(i + 1) == "|") {
      let ends = c == ":"
      // The mark belongs to the stroke, not to the colon leading into it, so
      // `:|` and `|` are keyed by the same kind of column.
      let bar = if ends { i + 1 } else { i }
      i = bar + 1
      let starts = i < chars.len() and chars.at(i) == ":"
      if starts { i += 1 }
      let (count, next) = _repeat-count(chars, i, ends)
      i = next
      // `stop` is where the whole mark ends, colons and count included, so that
      // a second stroke written against it is recognised as part of the same
      // mark however wide the first one was.
      items.push((col: bar, kind: "bar", stop: i, starts: starts, ends: ends, count: count))
      continue
    }

    if c in ("x", "X") {
      let col = i
      i += 1
      // A dead note has no fret for a suffix to hang off, and it never enters
      // the technique chain below, which belongs to the fret scan. It can still
      // carry a mark of its own: a pick scrape is written against an `x`
      // *because* it has no pitch, so `xPS` is the one spelling both legends
      // show for it, and reading it anywhere else would mean reading it nowhere.
      let techniques = ()
      let mark = _capital-mark-at(chars, i)
      if mark != none {
        techniques.push(mark.technique)
        i = mark.next
      }
      items.push((col: col, kind: "note", fret: m.MUTED, techniques: techniques))
      last = items.len() - 1
      pending = ()
      continue
    }

    // A bracket around the fret marks the note it encloses: parentheses a ghost
    // note or the far end of a tie, angle brackets a natural harmonic. `<12>` is
    // the Power Tab and Guitar Pro export spelling of what the native syntax
    // writes `12/3*`, and it is a dialect of ASCII tab rather than of any one
    // site, so it is read here rather than left to whatever fetched the file.
    let bracket = if c == "(" {
      "paren"
    } else if c == "<" { "harmonic" } else { none }
    if bracket != none { i += 1 }

    if i < chars.len() and chars.at(i) in _DIGITS {
      let col = if bracket != none { i - 1 } else { i }
      // A bracket delimits the number, so the digits inside it are one fret
      // however many there are — the ambiguity `_read-fret` resolves is only
      // there when nothing marks where the number ends.
      let (fret, next) = if bracket == none {
        _read-fret(chars, i)
      } else {
        let d = i
        while d < chars.len() and chars.at(d) in _DIGITS { d += 1 }
        (int(chars.slice(i, d).join()), d)
      }
      i = next
      // A parenthesised fret that repeats the note before it on the same string
      // is the far end of a tie rather than a ghost note: the string is still
      // sounding and is not struck again, which is how Ultimate Guitar writes a
      // held note. Any other fret in brackets is the ghost note the brackets
      // otherwise mean. The two print alike either way — the arc is what tells
      // them apart, the same ambiguity the published sheets carry — so the
      // reading only matters to the model, and reading it wrong turns a note
      // held over into a second strike.
      //
      // The tie itself belongs to the note the string is *held from*, since that
      // is where the native syntax writes it and where the forward pass that
      // marks the far end starts.
      let tied = bracket == "paren" and last != none and items.at(last).fret == fret
      if tied {
        let held = items.at(last)
        items.at(last) = (..held, techniques: held.techniques + (m.technique("tie"),))
      }
      let techniques = if bracket == "paren" and not tied {
        (m.technique("ghost"),)
      } else if bracket == "harmonic" {
        (m.technique("harmonic", style: "natural"),)
      } else { () }
      let closing = if bracket == "paren" { ")" } else { ">" }
      if bracket != none and i < chars.len() and chars.at(i) == closing { i += 1 }

      // A chain of techniques may follow, each optionally naming a target fret.
      let held = ()
      // Where the chain has arrived. A hammer-on, pull-off or slide moves it, so
      // a bend later in the chain measures from there: in `5h7b9` the bend runs
      // from the hammered 7 up to 9, one step, not from the struck 5.
      let reached = fret
      while i < chars.len() {
        // A harmonic or a pick scrape names itself in two capitals and takes no
        // target, so it is read before the letter chain rather than inside it.
        let capital = _capital-mark-at(chars, i)
        if capital != none {
          techniques.push(capital.technique)
          i = capital.next
          continue
        }
        if chars.at(i) not in _TECHNIQUE-CHARS { break }
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

        // `pb` is a pre-bend and `pbr` a pre-bend and release, which is how
        // Ultimate Guitar's own symbol table spells them. Unambiguous for the
        // same reason `hb` is: a pull-off always writes its target as digits,
        // so a `p` pressed directly against a `b` can only be this.
        //
        // Read as an ordinary `p` the string was *misread* rather than merely
        // impoverished — the pull-off was held for the next note on the row and
        // hung off it, inventing a slur the source never had, and the pre-bend
        // came out as an ordinary bend. Silent, which is the one thing this
        // importer is meant not to be.
        let pre = false
        if mark == "p" and i < chars.len() and chars.at(i) == "b" {
          pre = true
          mark = "b"
          i += 1
        }

        let target = none
        // A note value written over the digits says they are a note in their own
        // right, so they are left for the outer loop to read and the mark runs to
        // the event they become. Nothing else can say it: in ASCII every
        // character has a column, so `3/7` spends one on its target exactly as
        // `3-/-7` does, and only the `R:` row distinguishes a slide into a note
        // of its own from the compact pair the legend sets.
        // Only a link's target can be a note of its own. A bend names a *pitch*
        // to reach, never a second strike, so digits after `b` are its size
        // whatever the `R:` row says about that column.
        let owned = mark in _LINKING and i < chars.len() and str(i) in valued
        // Digits after a spelled size are the next note, not a target: `7fb5` is
        // a full bend on the 7th fret and then the 5th, and reading the 5 as a
        // target both swallowed the note and refused the bend for not rising.
        if spelled == none and not owned and i < chars.len() and chars.at(i) in _DIGITS {
          // A target is a fret like any other, so it stops where a fret stops:
          // in `7b910` the bend rises to the 9th and the 10th is the next note.
          let (fret, next) = _read-fret(chars, i)
          target = fret
          i = next
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
            techniques.push(m.technique("bend", amount: amount, release: false, pre: pre))
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
        } else if last != none and items.at(last).fret == m.MUTED {
          // Nothing sounds on a dead string, so nothing can be hammered, pulled
          // or slid from it. The mark is dropped rather than hung there, which
          // is what a stray letter between a dead note and the next one used to
          // do: `0-x---pbr12` in a real transcription left a pull-off pointing
          // from `x` to the 12th, and the renderer, asked whether the 12th is
          // above a fret called "x", stopped the whole document.
          warnings.push(
            "'" + mark + "' joins a dead string to the " + str(fret) + "th fret; ignored",
          )
        } else if last != none {
          // The target keeps its own column, so the link runs to it as an event
          // rather than printing its fret a second time beside the note it comes
          // from. `5h7` — the digits pressed against the mark — is the other
          // form and stays one event; the source says which it means by whether
          // it spent a column on the target.
          let n = items.at(last)
          items.at(last) = (..n, techniques: n.techniques + (_resolve(mark, none),))
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

  // Marks still held when the row runs out never had a note to reach, and a
  // slide is the one that means something anyway: the note is slid off, in the
  // direction the arrow points. This is where `-15\-------` gets its stroke; it
  // used to be dropped without a word, so a figure that trails away came out as
  // a plain note.
  for mark in pending {
    let out = _resolve-out(mark)
    if out != none and last != none and items.at(last).fret != m.MUTED {
      let n = items.at(last)
      items.at(last) = (..n, techniques: n.techniques + (out,))
    }
  }

  (items: items, warnings: warnings)
}

// ---------------------------------------------------------------------------
// Barlines
// ---------------------------------------------------------------------------

/// Fold a barline read from one row into what the rows before it said.
///
/// Repeat marks are additive: every row draws the same barline, so a colon or a
/// count written on any one of them belongs to the mark.
#let _merge-bar(before, item) = {
  let mark = (stop: item.stop, starts: item.starts, ends: item.ends, count: item.count)
  if before == none { return mark }
  (
    stop: calc.max(before.stop, mark.stop),
    starts: before.starts or mark.starts,
    ends: before.ends or mark.ends,
    count: if before.count != none { before.count } else { mark.count },
  )
}

/// Collapse runs of adjacent barline columns into the single mark they are
/// drawn as, as `(columns, flags)` keyed by the column that survives.
///
/// Adjacency is measured against where the previous mark ended rather than
/// where it began, so a stroke written against a wide one — the second `|` of
/// `:|x3|` — is still part of it, while `|-|` a column apart is two barlines.
#let _collapse-bars(flags) = {
  let kept = ()
  let out = (:)
  for col in flags.keys().map(int).sorted() {
    let key = if kept.len() > 0 { str(kept.last()) } else { none }
    if key != none and col <= out.at(key).stop {
      out.insert(key, _merge-bar(out.at(key), flags.at(str(col))))
    } else {
      kept.push(col)
      out.insert(str(col), flags.at(str(col)))
    }
  }
  (kept.map(str), out)
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
///
/// Case is ignored, which is what lets an `R:` row carry a Power Tab or Guitar
/// Pro export's own duration line unchanged — those write `W H Q E S` where the
/// DSL writes `w h q e s`, and mark a dot the same way. A tab exported that way
/// therefore arrives with real rhythm, stems and beams, instead of being spaced
/// from its columns.
///
/// Two things that dialect says are not read, from its own legend: a
/// *lowercase* letter there means the note is staccato as well, and `X` is a
/// 64th, which is shorter than any value this package has. The first comes out
/// as the plain value — the right duration, without the dot over it — and the
/// second leaves the sticky value standing. Lower case cannot be given that
/// second meaning here in any case: it is what the DSL's own tokens are written
/// in.
#let _duration-token(token) = {
  let chars = lower(token).clusters()
  if chars.len() == 0 or chars.at(0) not in m.durations { return none }
  let dots = chars.slice(1).filter(c => c == ".").len()
  if chars.len() != 1 + dots { return none }
  m.dotted(m.durations.at(chars.at(0)), dots)
}

/// How far an annotation reaches for the event it belongs to.
///
/// Three columns, which is what `C:`, `T:` and `D:` resolve by. `R:` uses it to
/// tell a value that merely misses its note from one written where nothing is
/// struck at all.
#let _REACH = 3

/// The columns of an `R:` row that name a value where nothing is struck.
///
/// Each is a rest as long as the value written over it — `R: q e e q` over a bar
/// holding one note says the rest of the bar is silent, and a transcriber has no
/// other way of writing that down. ASCII tab spells silence as filler, so the
/// annotation row is the only place it can be said.
///
/// **The notes claim their tokens, rather than each token asking whether a note
/// is near.** Asking by distance alone cannot read a densely spaced row at all:
/// where events stand two columns apart, a value written over the gap between
/// two of them is within reach of both, and a real transcription — eight eighths
/// over seven notes, `-0-0---7-8---8-7-` — lost its rest and came out a beat
/// short in every bar. Letting each note take the token nearest it leaves over
/// exactly the ones no note wanted, whatever the spacing.
///
/// `_REACH` still bounds what a note may claim, so a token far from everything
/// is a rest and one that merely misses its note is not.
#let _rest-columns(tokens, note-columns) = {
  let values = tokens.filter(t => _duration-token(t.token) != none).map(t => t.col).sorted()
  let taken = ()
  for note in note-columns.sorted() {
    let best = none
    for (i, col) in values.enumerate() {
      if i in taken or calc.abs(col - note) > _REACH { continue }
      if best == none or calc.abs(col - note) < calc.abs(values.at(best) - note) { best = i }
    }
    if best != none { taken.push(best) }
  }
  let out = ()
  for (i, col) in values.enumerate() {
    if i not in taken and col not in out { out.push(col) }
  }
  out
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

  // What a bar with nothing written in it holds: one rest, as long as the bar.
  //
  // An empty bar is not an empty statement — it says this part is silent here,
  // and a published sheet writes that as a rest. Emitting one is also what
  // gives the bar an honest width and what stops `validate` from reporting
  // every silent bar as short, both of which a bar left literally empty gets
  // wrong. With no time signature there is no bar length to give it, and the
  // rest is left durationless, which draws nothing.
  //
  // The rest is drawn from its duration, so in a meter whose bar is not a
  // dotted power of two it comes out as the nearest value rather than as the
  // whole rest an engraver would use for any bar. 4/4 — where nearly all of
  // this lands — is exact.
  let empty-bar = () => {
    if time == none { return (m.event(rest: true),) }
    (m.event(rest: true, duration: r.rat(time.at(0), den: time.at(1))),)
  }

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
  // Whether a `|:` is waiting for the measure it opens. Kept across blocks, as
  // a repeat may open at the end of one block and be played out in the next.
  let start-repeat = false
  // Note values are sticky across the whole piece, as in the DSL.
  let duration = none
  let pending-tuplet = none
  let tuplet-left = 0

  for block in grouped.blocks {
    // Whether a barline has opened a measure in this block yet. Every block
    // begins with one, and that first one opens the music rather than closing
    // anything; from then on a barline closes a measure even if nothing was
    // written in it. Per block, not per piece: a measure may run across the
    // join between two blocks, and the second block's leading barline is its
    // opening one, not a bar's end.
    let opened = false
    let heads = block.rows.map(_row-head)
    let order = _string-order(heads, tuning)

    // Every row of a block must start its music at the same column, or the
    // columns no longer mean simultaneity.
    let offset = heads.fold(0, (acc, h) => calc.max(acc, h.offset))
    let lengths = block.rows.map(row => row.clusters().len())
    if lengths.len() > 0 and calc.max(..lengths) - calc.min(..lengths) > 1 {
      warnings.push("string rows in a block have different lengths; columns may be misaligned")
    }

    // Annotations are grouped before the rows are read, because the `R:` row has
    // a say in how a row is read: a value over a link's target makes it a note
    // of its own rather than a second number inside the event before it.
    let annotations = (:)
    for ann in block.annotations {
      let existing = annotations.at(ann.key, default: ())
      annotations.insert(ann.key, existing + (ann,))
    }
    let durations-at = annotations
      .at("R", default: ())
      .map(a => _tokens-with-columns(a.text, a.offset))
      .flatten()
    let valued = durations-at.filter(t => _duration-token(t.token) != none).map(t => str(t.col))

    // Collect every note and barline, keyed by the column it sits in. A barline
    // is written on every row, so its repeat marks are merged across the block:
    // the transcriber who writes `x3` on one row only still means it.
    let by-column = (:)
    let bar-flags = (:)
    for (row-index, row) in block.rows.enumerate() {
      let string = order.at(row-index)
      let parsed = _parse-row(row, offset, valued: valued)
      warnings += parsed.warnings
      for item in parsed.items {
        if item.kind == "bar" {
          let key = str(item.col)
          bar-flags.insert(key, _merge-bar(bar-flags.at(key, default: none), item))
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
    // Adjacent barlines are one mark, not two: `||` is drawn with two strokes
    // and a bar of silence between them is exactly what it does not mean.
    // Collapsing them here rather than while walking the columns is what keeps
    // a compound mark's repeats — in `||:` the repeat is written on the second
    // stroke, and dropping that stroke used to drop the repeat with it.
    let (bar-columns, bar-flags) = _collapse-bars(bar-flags)

    // The rest of the annotations, resolved to columns.
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
    // A value written where nothing is struck is a rest of that length, and
    // takes a column of its own alongside the notes and the barlines.
    let rest-columns = _rest-columns(durations-at, note-columns)
    let all-columns = ()
    for col in (note-columns + rest-columns + bar-columns.map(int)).sorted() {
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
      if best != none and calc.abs(best - target) <= _REACH { best } else { none }
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
    // Lyrics: one verse per `L:` row in the block, in the order they appear.
    // Syllables attach by column like chord names do, which is why the ASCII
    // side needs no spending rule — the transcriber has already said where each
    // one goes by writing it there.
    // A syllable with no note near it still belongs on the page: a singer
    // carries on where the guitar stops, and a bar the transcription leaves
    // empty is exactly where that happens. Such a syllable gets a column of its
    // own, and the event built there is a rest with no duration — nothing
    // sounds on the guitar, and what the voice does with the time is not
    // something the source says. It draws no glyph, so the bar stays empty
    // under the words.
    let lyric-only = ()
    let lyric-at = (:)
    for (verse, a) in annotations.at("L", default: ()).enumerate() {
      for token in _tokens-with-columns(a.text, a.offset) {
        let col = nearest-event(token.col)
        if col == none {
          col = token.col
          if col not in lyric-only { lyric-only.push(col) }
        }
        let here = lyric-at.at(str(col), default: ())
        // Verses are filled in order, so a column that skips one is padded to
        // keep every syllable at its own verse's index.
        while here.len() < verse { here.push(none) }
        here.push(read-syllable(token.token))
        lyric-at.insert(str(col), here)
      }
    }
    // Columns that carry only a syllable join the walk below, in order with
    // the notes and barlines.
    if lyric-only.len() > 0 {
      let merged = (all-columns + lyric-only).sorted()
      all-columns = ()
      for col in merged {
        if all-columns.len() == 0 or all-columns.last() != col { all-columns.push(col) }
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
        // A barline closes a measure even when nothing was written in it. The
        // guard used to be `events.len() > 0`, which threw such a measure away —
        // and with it the whole block when every bar was empty, so an outro
        // where the guitar has stopped and only the voice carries on vanished
        // from the sheet without a word. A bar with no notes is a bar of
        // silence, and the barlines saying so are in the source.
        //
        // `opened` is what keeps the *first* barline from closing a measure
        // before one has begun: every row starts with one, and it opens the
        // music rather than ending anything.
        let bar = bar-flags.at(str(col))
        if events.len() > 0 or opened {
          let volta = none
          for run in volta-runs {
            if volta == none and event-cols.any(c => c >= run.start - 1 and c <= run.end) {
              volta = (run.number,)
            }
          }
          // The bar's own rest comes first where nothing in it sounds — a bar
          // that is empty outright, and one carrying only syllables, are both
          // bars of silence and a sheet writes each as a rest.
          //
          // Rests the `R:` row named are the exception: they say how the silence
          // is divided, and the whole-bar rest ahead of them would be a second
          // bar's worth of it. A syllable's own column carries no value, which
          // is what tells the two apart.
          let written = events.any(ev => ev.notes.len() > 0 or ev.duration != none)
          measures.push(m.measure(
            events: if written { events } else { empty-bar() + events },
            volta: volta,
            start-repeat: start-repeat,
            end-repeat: bar.ends,
            repeat-count: bar.count,
          ))
          events = ()
          event-cols = ()
          start-repeat = false
        }
        // A `|:` opens the measure the barline leads into, which is the one
        // built after it — and across a block join too, since a repeat may open
        // the last bar of one block and be played out in the next.
        if bar.starts { start-repeat = true }
        opened = true
        continue
      }

      let spans = spans-at.filter(s => col >= s.start - 1 and col <= s.end).map(s => s.name)

      // How wide this event was in the source, so a tab with no note values is
      // still spaced the way its author laid it out.
      let next-col = if idx + 1 < all-columns.len() { all-columns.at(idx + 1) } else { col + 4 }
      let span = calc.max(0.35, calc.min(4.0, (next-col - col) / 4.0))

      events.push(m.event(
        notes: by-column.at(str(col), default: ()),
        // A column carrying only a syllable holds no note, so it is a rest —
        // and one with no duration, since the source says when the word is sung
        // but not for how long. It draws no glyph.
        rest: str(col) not in by-column,
        duration: value-at.at(str(col), default: none),
        spans: spans,
        tuplet: tuplet-at.at(str(col), default: none),
        chord: chord-at.at(str(col), default: none),
        text: text-at.at(str(col), default: none),
        dynamic: dynamic-at.at(str(col), default: none),
        lyrics: lyric-at.at(str(col), default: ()),
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
    measures.push(m.measure(events: events, volta: volta, start-repeat: start-repeat))
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
