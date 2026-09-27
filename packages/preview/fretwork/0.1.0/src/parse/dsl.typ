// The native tablature DSL: tokenizer and parser.
//
// A source string holds one or more measures separated by barlines. Note values
// are sticky, so only changes need writing. The grammar is designed so that no
// expression can be read two ways; see `SPEC.md` for the full rules, of which
// the three load-bearing ones are:
//
//   1. Whitespace separates events and nothing else, so a fret number is always
//      a maximal run of digits: `11/3` can only be fret eleven.
//   2. A character means one thing standing alone (a note value or a rest) and
//      another inside a token (a technique). The two never meet because a token
//      contains no whitespace.
//   3. Suffixes are matched longest-first from a fixed table, and the ones
//      taking a fret argument require digits immediately after.

#import "../rational.typ" as r
#import "../model.typ" as m
#import "../tuning.typ": string-count, tunings
#import "errors.typ"

#let _DIGITS = ("0", "1", "2", "3", "4", "5", "6", "7", "8", "9")
#let _SPACE = (" ", "\t", "\n", "\r")
#let _DURATION-LETTERS = ("w", "h", "q", "e", "s", "t")

// Characters that end a token without being part of it.
#let _STRUCTURAL = ("(", ")", "{", "}", "|", ":", "@")

// Technique suffixes, longest first. Matching in this order is what keeps `br`
// from being read as `b` followed by a stray `r`, and `PH` from being read as
// the pull-off `p`.
#let _SUFFIXES = (
  ("PH", "harmonic-pinch"),
  ("HH", "harmonic-harp"),
  ("PS", "scrape"),
  ("PO", "pop"),
  ("TP", "tremolo"),
  ("SL", "slap"),
  ("DS", "dead-slap"),
  ("tr", "trill"),
  ("br", "bend-release"),
  ("Br", "prebend-release"),
  ("h", "hammer"),
  ("p", "pull"),
  ("s", "slide-legato"),
  ("S", "slide-shift"),
  ("b", "bend"),
  ("B", "prebend"),
  ("v", "vibrato"),
  ("V", "vibrato-wide"),
  ("*", "harmonic-natural"),
  ("~", "tie"),
  ("g", "ghost"),
  (">", "accent"),
  ("^", "marcato"),
  ("!", "staccato"),
  ("-", "tenuto"),
  ("T", "tap"),
  ("A", "arpeggiate"),
  ("R", "rake"),
  ("n", "stroke-down"),
  ("u", "stroke-up"),
  ("F", "fermata"),
  ("W", "bar-vibrato"),
)

// Suffixes that must be followed by a fret number.
#let _NEEDS-FRET = ("hammer", "pull", "slide-legato", "slide-shift")

// Suffixes that may take a fret number but do not require one.
#let _OPTIONAL-FRET = ("trill",)

// The dynamics that may be written, loudest last. A closed set on purpose: a
// typo in a dynamic is silent otherwise, and there is nothing else `!ff` could
// have been trying to say.
#let DYNAMICS = ("ppp", "pp", "p", "mp", "mf", "f", "ff", "fff", "sf", "sfz", "fp")

// Suffixes that may be followed by a stroke direction, `n` down or `u` up —
// the same two letters that write a pickstroke, since they mean the same
// motion of the hand. Omitted, the stroke is downward, which is both the
// commoner roll and the one an engraver leaves unmarked.
#let _OPTIONAL-DIR = ("arpeggiate", "rake")

// ---------------------------------------------------------------------------
// Low-level scanning
// ---------------------------------------------------------------------------

#let _is-sep(chars, i) = {
  i >= chars.len() or chars.at(i) in _SPACE or chars.at(i) in _STRUCTURAL
}

/// The run of non-separator characters starting at `i`, for error messages.
#let _word-at(chars, i) = {
  let j = i
  while j < chars.len() and not (chars.at(j) in _SPACE) { j += 1 }
  chars.slice(i, j).join()
}

#let _scan-int(chars, i) = {
  let start = i
  while i < chars.len() and chars.at(i) in _DIGITS { i += 1 }
  (v: if i > start { int(chars.slice(start, i).join()) } else { none }, i: i)
}

/// Whether a string is one or more digits — safe to hand to `int`.
#let _all-digits(s) = s.len() > 0 and s.clusters().all(c => c in _DIGITS)

/// Parse a bend size written `(1/2)`, `(1)` or `(full)`, in whole steps.
#let _scan-bend-amount(chars, i, loc, source) = {
  if i >= chars.len() or chars.at(i) != "(" { return (v: r.rat(1), i: i) }
  let close = i + 1
  while close < chars.len() and chars.at(close) != ")" { close += 1 }
  if close >= chars.len() {
    errors.fail("tab", loc, "unclosed bend amount", source: source)
  }
  // `join` of an empty slice is `none`, so `b()` needs the fallback.
  let joined = chars.slice(i + 1, close).join()
  let body = if joined == none { "" } else { joined.trim() }

  // Everything is checked before `int` is called: a raw `int("x")` panic would
  // point at this file instead of at the source, defeating the located errors
  // the parsers promise.
  let malformed() = errors.fail(
    "tab",
    loc,
    "malformed bend amount '" + body + "' — write (1/2), (1) or (full)",
    source: source,
  )
  let value = if body == "full" {
    r.rat(1)
  } else if "/" in body {
    let parts = body.split("/")
    if parts.len() != 2 or not _all-digits(parts.at(0)) or not _all-digits(parts.at(1)) {
      malformed()
    }
    if int(parts.at(1)) == 0 {
      errors.fail("tab", loc, "bend amount '" + body + "' divides by zero", source: source)
    }
    r.rat(int(parts.at(0)), den: int(parts.at(1)))
  } else {
    if not _all-digits(body) { malformed() }
    r.rat(int(body))
  }
  if value.num == 0 {
    errors.fail("tab", loc, "a bend amount must be positive", source: source)
  }
  (v: value, i: close + 1)
}

/// Build a technique record from a matched suffix kind and its argument.
#let _make-technique(kind, arg) = {
  if kind == "hammer" { m.technique("hammer", fret: arg) } else if kind == "pull" {
    m.technique("pull", fret: arg)
  } else if kind == "slide-legato" {
    m.technique("slide", fret: arg, legato: true)
  } else if kind == "slide-shift" {
    m.technique("slide", fret: arg, legato: false)
  } else if kind == "bend" {
    m.technique("bend", amount: arg, release: false, pre: false)
  } else if kind == "bend-release" {
    m.technique("bend", amount: arg, release: true, pre: false)
  } else if kind == "prebend" {
    m.technique("bend", amount: arg, release: false, pre: true)
  } else if kind == "prebend-release" {
    m.technique("bend", amount: arg, release: true, pre: true)
  } else if kind == "vibrato" {
    m.technique("vibrato", wide: false)
  } else if kind == "vibrato-wide" {
    m.technique("vibrato", wide: true)
  } else if kind == "harmonic-natural" {
    m.technique("harmonic", style: "natural")
  } else if kind == "harmonic-pinch" {
    m.technique("harmonic", style: "pinch")
  } else if kind == "harmonic-harp" {
    m.technique("harmonic", style: "harp")
  } else if kind == "trill" {
    m.technique("trill", fret: arg)
  } else if kind == "stroke-down" {
    m.technique("stroke", dir: "down")
  } else if kind == "stroke-up" {
    m.technique("stroke", dir: "up")
  } else if kind in _OPTIONAL-DIR {
    m.technique(kind, dir: arg)
  } else {
    m.technique(kind)
  }
}

/// Read a chain of technique suffixes.
#let _scan-suffixes(chars, i, loc, source) = {
  let techs = ()
  while not _is-sep(chars, i) {
    let matched = none
    for (token, kind) in _SUFFIXES {
      let n = token.clusters().len()
      if i + n <= chars.len() and chars.slice(i, i + n).join() == token {
        matched = (token: token, kind: kind, n: n)
        break
      }
    }
    if matched == none {
      errors.fail(
        "tab",
        loc,
        "unknown technique '" + chars.at(i) + "' in '" + _word-at(chars, loc.col) + "'",
        source: source,
      )
    }
    i += matched.n
    let arg = none
    if matched.kind in _OPTIONAL-FRET {
      let scanned = _scan-int(chars, i)
      arg = scanned.v
      i = scanned.i
    } else if matched.kind in _NEEDS-FRET {
      let scanned = _scan-int(chars, i)
      if scanned.v == none {
        errors.fail(
          "tab",
          loc,
          "'" + matched.token + "' must be followed by a target fret",
          source: source,
        )
      }
      arg = scanned.v
      i = scanned.i
    } else if matched.kind in ("bend", "bend-release", "prebend", "prebend-release") {
      let scanned = _scan-bend-amount(chars, i, loc, source)
      arg = scanned.v
      i = scanned.i
    } else if matched.kind in _OPTIONAL-DIR {
      arg = "down"
      if i < chars.len() and chars.at(i) in ("n", "u") {
        arg = if chars.at(i) == "n" { "down" } else { "up" }
        i += 1
      }
    }
    techs.push(_make-technique(matched.kind, arg))
  }
  (v: techs, i: i)
}

/// Read one `fret/string` note with its suffixes.
#let _scan-note(chars, i, loc, source) = {
  let fret = none
  if chars.at(i) == "x" {
    fret = m.MUTED
    i += 1
  } else {
    let scanned = _scan-int(chars, i)
    fret = scanned.v
    i = scanned.i
  }
  if i >= chars.len() or chars.at(i) != "/" {
    errors.fail(
      "tab",
      loc,
      "expected '/' between fret and string in '" + _word-at(chars, loc.col) + "'",
      source: source,
    )
  }
  i += 1
  let scanned = _scan-int(chars, i)
  if scanned.v == none {
    errors.fail("tab", loc, "missing string number after '/'", source: source)
  }
  let string = scanned.v
  i = scanned.i
  let suffixes = _scan-suffixes(chars, i, loc, source)
  (v: m.note(string, fret, techniques: suffixes.v), i: suffixes.i)
}

/// Read a chord `( … )` and any suffixes that follow it.
///
/// A suffix after the closing paren binds to every note in the chord, which is
/// what makes `(2/5 2/4 0/6)~` tie the whole chord.
#let _scan-chord(chars, i, loc, source) = {
  i += 1 // consume '('
  let notes = ()
  while true {
    while i < chars.len() and chars.at(i) in _SPACE { i += 1 }
    if i >= chars.len() {
      errors.fail("tab", loc, "unclosed chord", source: source)
    }
    if chars.at(i) == ")" {
      i += 1
      break
    }
    let scanned = _scan-note(chars, i, loc, source)
    notes.push(scanned.v)
    i = scanned.i
  }
  if notes.len() == 0 {
    errors.fail("tab", loc, "empty chord", source: source)
  }
  let shared = _scan-suffixes(chars, i, loc, source)
  if shared.v.len() > 0 {
    notes = notes.map(n => m.note(n.string, n.fret, techniques: n.techniques + shared.v))
  }
  (v: notes, i: shared.i)
}

// ---------------------------------------------------------------------------
// Tokenizer
// ---------------------------------------------------------------------------

/// Split a DSL source string into tokens.
///
/// Exposed for testing; `parse` is the normal entry point.
#let tokenize(source) = {
  let chars = source.clusters()
  let tokens = ()
  let i = 0
  let measure = 1
  let ordinal = 0

  while i < chars.len() {
    let c = chars.at(i)
    if c in _SPACE {
      i += 1
      continue
    }
    // Line comment.
    if c == "/" and i + 1 < chars.len() and chars.at(i + 1) == "/" {
      while i < chars.len() and chars.at(i) != "\n" { i += 1 }
      continue
    }

    ordinal += 1
    let loc = errors.at(measure: measure, token: ordinal, col: i)
    let next = if i + 1 < chars.len() { chars.at(i + 1) } else { none }

    if c == "|" {
      let style = if next == ":" { "repeat-start" } else if next == "|" {
        "double"
      } else if next == "." { "final" } else { "single" }
      i += if style == "single" { 1 } else { 2 }
      if style != "repeat-start" { measure += 1 }
      tokens.push((kind: "barline", style: style, count: none, loc: loc))
      continue
    }

    if c == ":" and next == "|" {
      i += 2
      // An optional repeat count, written `:|x3`.
      let count = none
      if i < chars.len() and chars.at(i) == "x" {
        let scanned = _scan-int(chars, i + 1)
        if scanned.v != none {
          count = scanned.v
          i = scanned.i
        }
      }
      measure += 1
      tokens.push((kind: "barline", style: "repeat-end", count: count, loc: loc))
      continue
    }

    if c in _DURATION-LETTERS {
      let j = i + 1
      let dots = 0
      while j < chars.len() and chars.at(j) == "." {
        dots += 1
        j += 1
      }
      if not _is-sep(chars, j) {
        errors.fail("tab", loc, "unknown duration '" + _word-at(chars, i) + "'", source: source)
      }
      tokens.push((kind: "duration", value: m.dotted(m.durations.at(c), dots), loc: loc))
      i = j
      continue
    }

    // A dynamic, written `!mf`, attaching to the next event. `!` inside a token
    // is the staccato dot; alone it opens a dynamic, and the two never meet.
    if c == "!" {
      let start = i + 1
      let j = start
      while not _is-sep(chars, j) { j += 1 }
      let word = chars.slice(start, j).join()
      if word == none or word == "" {
        errors.fail("tab", loc, "'!' must be followed by a dynamic, as in '!mf'", source: source)
      }
      if word not in DYNAMICS {
        errors.fail(
          "tab",
          loc,
          "unknown dynamic '" + word + "' — one of " + DYNAMICS.join(" "),
          source: source,
        )
      }
      tokens.push((kind: "dynamic", value: word, loc: loc))
      i = j
      continue
    }

    // A standalone `g` marks the *next* event as a grace note, the way `@E5`
    // and `"Harm."` attach to the one after them. Inside a token `g` stays the
    // ghost note; the two never meet, because a token holds no whitespace.
    // `g` is squeezed in before the beat, `G` starts on it.
    if (c == "g" or c == "G") and _is-sep(chars, i + 1) {
      tokens.push((kind: "grace", when: if c == "g" { "before" } else { "on" }, loc: loc))
      i += 1
      continue
    }

    // A rest and a bare mute have no note to hang a suffix on, so theirs go on
    // the event. That is what lets `rF` hold a rest — the one mark that is at
    // least as common over silence as over a note.
    if c == "r" {
      let suffixes = _scan-suffixes(chars, i + 1, loc, source)
      tokens.push((kind: "rest", techniques: suffixes.v, loc: loc))
      i = suffixes.i
      continue
    }

    // A bare `x` mutes every string; `x/5` mutes one.
    if c == "x" and next != "/" {
      let suffixes = _scan-suffixes(chars, i + 1, loc, source)
      tokens.push((kind: "mute-all", techniques: suffixes.v, loc: loc))
      i = suffixes.i
      continue
    }

    if c == "(" {
      let scanned = _scan-chord(chars, i, loc, source)
      tokens.push((kind: "event", notes: scanned.v, loc: loc))
      i = scanned.i
      continue
    }

    if c in _DIGITS or c == "x" {
      let scanned = _scan-note(chars, i, loc, source)
      tokens.push((kind: "event", notes: (scanned.v,), loc: loc))
      i = scanned.i
      continue
    }

    // A time signature, written `[7/8]`. Brackets rather than a bare `7/8`,
    // which the grammar has already spoken for: it is fret seven on string
    // eight. Nothing else in either syntax uses a bracket.
    if c == "[" {
      let close = i + 1
      while close < chars.len() and chars.at(close) != "]" { close += 1 }
      if close >= chars.len() {
        errors.fail("tab", loc, "unclosed time signature", source: source)
      }
      let body = chars.slice(i + 1, close).join().trim()
      let parts = body.split("/")
      let bad = parts.len() != 2 or parts.any(p => p == "" or p.clusters().any(d => d not in _DIGITS))
      if bad {
        errors.fail(
          "tab",
          loc,
          "time signature '[" + body + "]' is not 'beats/unit', as in '[7/8]'",
          source: source,
        )
      }
      let (beats, unit) = (int(parts.at(0)), int(parts.at(1)))
      if beats < 1 or unit not in (1, 2, 4, 8, 16, 32) {
        errors.fail(
          "tab",
          loc,
          "time signature '[" + body + "]' needs at least one beat and a unit of 1, 2, 4, 8, 16 or 32",
          source: source,
        )
      }
      tokens.push((kind: "time", time: (beats, unit), loc: loc))
      i = close + 1
      continue
    }

    if c == "{" {
      let j = i + 1
      while j < chars.len() and chars.at(j) != ":" and chars.at(j) != "}" { j += 1 }
      if j >= chars.len() or chars.at(j) != ":" {
        errors.fail("tab", loc, "group is missing its ':' — write '{PM: … }'", source: source)
      }
      let name = chars.slice(i + 1, j).join().trim()
      if name == "" {
        errors.fail("tab", loc, "group has an empty name", source: source)
      }
      tokens.push((kind: "group-open", name: name, loc: loc))
      i = j + 1
      continue
    }

    if c == "}" {
      tokens.push((kind: "group-close", loc: loc))
      i += 1
      continue
    }

    if c == "@" {
      i += 1
      let name = ""
      if i < chars.len() and chars.at(i) == "\"" {
        let close = i + 1
        while close < chars.len() and chars.at(close) != "\"" { close += 1 }
        if close >= chars.len() {
          errors.fail("tab", loc, "unclosed chord name", source: source)
        }
        name = chars.slice(i + 1, close).join()
        i = close + 1
      } else {
        let start = i
        while not _is-sep(chars, i) { i += 1 }
        name = chars.slice(start, i).join()
      }
      if name == "" {
        errors.fail("tab", loc, "'@' must be followed by a chord name", source: source)
      }
      tokens.push((kind: "chord-name", name: name, loc: loc))
      continue
    }

    if c == "\"" {
      let close = i + 1
      while close < chars.len() and chars.at(close) != "\"" { close += 1 }
      if close >= chars.len() {
        errors.fail("tab", loc, "unclosed playing instruction", source: source)
      }
      tokens.push((kind: "text", text: chars.slice(i + 1, close).join(), loc: loc))
      i = close + 1
      continue
    }

    errors.fail("tab", loc, "unexpected character '" + c + "'", source: source)
  }

  tokens
}

// ---------------------------------------------------------------------------
// Parser
// ---------------------------------------------------------------------------

/// The number a tuplet is played "in the time of".
///
/// Three in the time of two, five in the time of four, and so on: the largest
/// power of two below the count. Duplets and quadruplets are the exception —
/// they only occur in compound time, where they replace three.
#let _tuplet-of(count) = {
  if count in (2, 4) { return 3 }
  let p = 1
  while p * 2 < count { p = p * 2 }
  p
}

/// Interpret a group name as a tuplet, a volta, or a bracketed span.
#let _classify-group(name, loc, source) = {
  let digits-only = name.clusters().all(c => c in _DIGITS)
  if digits-only {
    let count = int(name)
    if count < 2 {
      errors.fail("tab", loc, "a tuplet needs at least two notes", source: source)
    }
    return (kind: "tuplet", tuplet: (count: count, of: _tuplet-of(count)))
  }
  if "/" in name {
    let parts = name.split("/")
    if parts.len() == 2 and parts.all(p => p.clusters().all(c => c in _DIGITS)) {
      return (kind: "tuplet", tuplet: (count: int(parts.at(0)), of: int(parts.at(1))))
    }
  }
  if (
    name.starts-with("V")
      and name.len() > 1
      and name.slice(1).clusters().all(c => c in _DIGITS)
  ) {
    return (kind: "volta", volta: (int(name.slice(1)),))
  }
  (kind: "span", span: name)
}

/// The source text of a DSL or ASCII argument.
///
/// Typst takes the first token of a *single-line* raw block as a language tag
/// and strips it from `.text`, so ```` ```q 0/6 2/6``` ```` arrives as
/// `0/6 2/6` with `lang: "q"`. Every duration token is a bare word, so the
/// leading note value would vanish without a sound. Put it back.
#let source-text(source) = {
  if type(source) == str { return source }
  let lang = source.at("lang", default: none)
  if lang == none { source.text } else { lang + " " + source.text }
}

/// Parse DSL source into an array of measures.
#let parse-measures(source, tuning: tunings.standard) = {
  let source = source-text(source)
  let tokens = tokenize(source)
  let strings = string-count(tuning)

  let measures = ()
  let events = ()
  let duration = none
  let spans = ()
  let tuplet = none
  let volta = none
  let stack = ()
  let pending-chord = none
  let pending-text = none
  let pending-grace = none
  let pending-dynamic = none
  let start-repeat = false
  // A time signature belongs to the measure it opens, and only where it
  // changes: `none` means "carry on with whatever is in force".
  let time = none

  for tok in tokens {
    if tok.kind == "barline" {
      // Closing off the measure is written out rather than factored into a
      // closure because a Typst closure captures by value and could not update
      // `measures` and `events` here.
      //
      // A leading barline produces no measure; `|:` only arms the repeat sign
      // for the measure that follows it.
      if events.len() > 0 or start-repeat {
        measures.push(m.measure(
          events: events,
          time: time,
          start-repeat: start-repeat,
          end-repeat: tok.style == "repeat-end",
          end: if tok.style in ("double", "final") { tok.style } else { "single" },
          volta: volta,
          repeat-count: tok.count,
        ))
        events = ()
        start-repeat = false
        time = none
      }
      if tok.style == "repeat-start" { start-repeat = true }
      continue
    }

    if tok.kind == "duration" {
      duration = tok.value
      continue
    }

    if tok.kind == "time" {
      time = tok.time
      continue
    }

    if tok.kind == "chord-name" {
      pending-chord = tok.name
      continue
    }

    if tok.kind == "text" {
      pending-text = tok.text
      continue
    }

    if tok.kind == "grace" {
      pending-grace = tok.when
      continue
    }

    if tok.kind == "dynamic" {
      pending-dynamic = tok.value
      continue
    }

    if tok.kind == "group-open" {
      let g = _classify-group(tok.name, tok.loc, source)
      stack.push((kind: g.kind, spans: spans, tuplet: tuplet, volta: volta))
      if g.kind == "tuplet" {
        tuplet = g.tuplet
      } else if g.kind == "volta" {
        volta = g.volta
      } else {
        spans = spans + (g.span,)
      }
      continue
    }

    if tok.kind == "group-close" {
      if stack.len() == 0 {
        errors.fail("tab", tok.loc, "'}' without a matching group", source: source)
      }
      let prev = stack.pop()
      spans = prev.spans
      tuplet = prev.tuplet
      volta = prev.volta
      continue
    }

    // Everything below produces one event.
    let notes = if tok.kind == "mute-all" {
      range(1, strings + 1).map(s => m.note(s, m.MUTED))
    } else if tok.kind == "rest" {
      ()
    } else {
      tok.notes
    }

    for n in notes {
      if n.string > strings {
        errors.fail(
          "tab",
          tok.loc,
          "string " + str(n.string) + " does not exist in tuning " + repr(tuning.name),
          source: source,
        )
      }
    }

    events.push(m.event(
      notes: notes,
      duration: duration,
      rest: tok.kind == "rest",
      spans: spans,
      tuplet: tuplet,
      chord: pending-chord,
      text: pending-text,
      techniques: tok.at("techniques", default: ()),
      grace: pending-grace,
      dynamic: pending-dynamic,
    ))
    pending-chord = none
    pending-text = none
    pending-grace = none
    pending-dynamic = none
  }

  if stack.len() > 0 {
    errors.fail("tab", errors.at(), "unclosed group '{'", source: source)
  }
  if events.len() > 0 or start-repeat {
    measures.push(m.measure(
      events: events,
      time: time,
      start-repeat: start-repeat,
      end-repeat: false,
      end: "single",
      volta: volta,
      repeat-count: none,
    ))
  }
  measures
}

/// Parse DSL source into a complete part.
#let parse(
  source,
  tuning: tunings.standard,
  time: (4, 4),
  tempo: none,
  capo: 0,
  anacrusis: false,
) = {
  // Accept a raw block as well as a plain string, since raw blocks keep the
  // source readable in a document; `parse-measures` unwraps it.
  let text = source
  m.part(
    measures: parse-measures(text, tuning: tuning),
    tuning: tuning,
    time: time,
    tempo: tempo,
    capo: capo,
    anacrusis: anacrusis,
  )
}

// ---------------------------------------------------------------------------
// Writer
// ---------------------------------------------------------------------------

/// The suffix that writes a technique back out.
#let _technique-suffix(t) = {
  if t.kind == "hammer" { "h" + str(t.fret) } else if t.kind == "pull" {
    "p" + str(t.fret)
  } else if t.kind == "slide" {
    (if t.legato { "s" } else { "S" }) + str(t.fret)
  } else if t.kind == "bend" {
    let mark = if t.pre and t.release {
      "Br"
    } else if t.pre { "B" } else if t.release { "br" } else { "b" }
    let size = if r.eq(t.amount, r.rat(1)) { "" } else { "(" + r.str-of(t.amount) + ")" }
    mark + size
  } else if t.kind == "vibrato" {
    if t.wide { "V" } else { "v" }
  } else if t.kind == "harmonic" {
    if t.style == "natural" { "*" } else if t.style == "pinch" { "PH" } else { "HH" }
  } else if t.kind == "stroke" {
    if t.dir == "down" { "n" } else { "u" }
  } else if t.kind == "trill" {
    "tr" + (if t.at("fret", default: none) == none { "" } else { str(t.fret) })
  } else if t.kind == "tremolo" { "TP" } else if t.kind == "scrape" {
    "PS"
  } else if t.kind in ("arpeggiate", "rake") {
    // The direction is always written out, even when it is the default: the
    // writer's job is to produce source that reads back identically, not the
    // shortest source that happens to.
    let mark = if t.kind == "arpeggiate" { "A" } else { "R" }
    let dir = if t.at("dir", default: "down") == "down" { "n" } else { "u" }
    mark + dir
  } else if t.kind == "tie" { "~" } else if t.kind == "ghost" {
    "g"
  } else if t.kind == "accent" { ">" } else if t.kind == "marcato" {
    "^"
  } else if t.kind == "staccato" { "!" } else if t.kind == "tenuto" {
    "-"
  } else if t.kind == "tap" { "T" } else if t.kind == "fermata" {
    "F"
  } else if t.kind == "bar-vibrato" { "W" } else if t.kind == "slap" {
    "SL"
  } else if t.kind == "pop" { "PO" } else if t.kind == "dead-slap" {
    "DS"
  } else { "" }
}

#let _write-note(n) = {
  let fret = if n.fret == m.MUTED { "x" } else { str(n.fret) }
  fret + "/" + str(n.string) + n.techniques.map(_technique-suffix).join()
}

/// Write one event, without its note value.
#let _write-event(ev, strings) = {
  // A rest and a bare mute carry their suffixes on the event, having no note to
  // put them on, so they are written back on the `r` or the `x`.
  let own = ev.at("techniques", default: ()).map(_technique-suffix).join()
  let own = if own == none { "" } else { own }
  if ev.kind == "rest" or ev.notes.len() == 0 { return "r" + own }
  if ev.notes.len() == strings and ev.notes.all(n => n.fret == m.MUTED) { return "x" + own }
  if ev.notes.len() == 1 { return _write-note(ev.notes.first()) }
  "(" + ev.notes.map(_write-note).join(" ") + ")"
}

/// The DSL token for a note value, e.g. `e.` for a dotted eighth.
#let _write-duration(value) = {
  let d = m.decompose(value)
  if d == none { return none }
  let token = m.duration-token(d.base)
  if token == none { return none }
  token + "." * d.dots
}

/// The group names an event belongs to, outermost first.
#let _group-names(ev) = {
  let names = ev.spans
  if ev.tuplet != none { names = names + (str(ev.tuplet.count),) }
  names
}

/// A chord name as the tokenizer will read it back.
///
/// An unquoted name ends at the first space or structural character, so a name
/// containing either must be written in the quoted form — otherwise the writer
/// emits source its own parser rejects, and the round trip is broken exactly
/// where it is needed.
#let _write-chord-name(name) = {
  let needs-quotes = name.clusters().any(c => c in _SPACE or c in _STRUCTURAL)
  if needs-quotes { "\"" + name + "\"" } else { name }
}

/// Serialise a part back to DSL source.
///
/// Round-tripping matters because it is how an annotated ASCII tab graduates to
/// the native syntax: import it, print it, keep the result.
#let write(part) = {
  let strings = string-count(part.tuning)
  let lines = ()
  let duration = none
  let open = ()
  // The ending currently written, so a volta spanning several measures opens
  // once and closes after its last one.
  let open-volta = none

  for (mi, measure) in part.measures.enumerate() {
    let parts = ()
    if measure.start-repeat { parts.push("|:") }
    // The signature goes after the repeat sign and before the ending bracket,
    // which is the order the tokenizer reads them back in.
    if measure.time != none {
      parts.push("[" + str(measure.time.at(0)) + "/" + str(measure.time.at(1)) + "]")
    }
    if measure.volta != none and measure.volta != open-volta {
      parts.push("{V" + str(measure.volta.first()) + ":")
      open-volta = measure.volta
    }

    for ev in measure.events {
      // Close the groups this event has left, innermost first, then open the
      // ones it has entered.
      let want = _group-names(ev)
      while open.len() > 0 and (open.len() > want.len() or open != want.slice(0, open.len())) {
        parts.push("}")
        let _ = open.pop()
      }
      for name in want.slice(open.len()) {
        parts.push("{" + name + ":")
        open.push(name)
      }

      if ev.at("dynamic", default: none) != none { parts.push("!" + ev.dynamic) }
      if ev.chord != none { parts.push("@" + _write-chord-name(ev.chord)) }
      if ev.text != none { parts.push("\"" + ev.text + "\"") }
      if ev.duration != none and ev.duration != duration {
        let token = _write-duration(ev.duration)
        if token != none {
          parts.push(token)
          duration = ev.duration
        }
      }
      // After the note value, since the marker attaches to the event and the
      // value is sticky across it.
      let grace = ev.at("grace", default: none)
      if grace != none { parts.push(if grace == "before" { "g" } else { "G" }) }
      parts.push(_write-event(ev, strings))
    }

    while open.len() > 0 {
      parts.push("}")
      let _ = open.pop()
    }

    parts.push(if measure.end-repeat {
      // The count sits directly on the sign, as the tokenizer requires.
      ":|" + (if measure.repeat-count != none { "x" + str(measure.repeat-count) } else { "" })
    } else if measure.end == "final" { "|." } else if measure.end == "double" {
      "||"
    } else { "|" })

    // The ending's group closes after the barline of its last measure, which is
    // where the parser expects it: the barline is inside the group.
    let next-volta = if mi + 1 < part.measures.len() {
      part.measures.at(mi + 1).volta
    } else { none }
    if open-volta != none and next-volta != open-volta {
      parts.push("}")
      open-volta = none
    }
    lines.push(parts.join(" "))
  }

  lines.join("\n")
}
