// parser.typ - Music string parser
//
// Converts a music string like "c'4 d' e' f' | g'2 g'" into an array
// of event dictionaries (notes, rests, barlines, etc.)

#import "model.typ": make-note, make-rest, make-spacer, make-gap, make-barline, make-line-break, make-chord, make-clef, make-time-sig
#import "constants.typ": supported-clefs, clef-default-base-octave
#import "utils.typ": is-digit, is-lower, is-whitespace

/// Main entry: parse a music string into an array of events.
/// - base-octave: the default octave number when no ' or , markers are given.
///   Use 4 for treble clef (C4 = middle C), 3 for bass clef (C3 = low C).
#let parse-music(input, base-octave: 4) = {
  let events = ()
  let pos = 0
  let len = input.len()
  let last-duration = 4   // sticky duration
  let current-base-octave = base-octave

  // Tuplet state: track open "{n" blocks
  let tuplet-start-idx = none
  let tuplet-n = none
  let tuplet-m = none
  let tuplet-open-order = none

  // Octave-line state: track open "n[a|b]{" blocks (e.g. 8a{...}, 15b{...})
  let octline-start-idx = none
  let octline-number = none
  let octline-dir = none
  let octline-open-order = none

  // Hairpin state: track open "cresc{...}" / "decresc{...}" spans
  let hairpin-start-idx = none
  let hairpin-kind = none
  let hairpin-open-order = none

  // Trill state: track open "tr{...}" spans
  let trill-start-idx = none
  let trill-open-order = none

  // Grace-note state: track open "grace{...}" spans
  let grace-start-idx = none
  let grace-slash = false
  let grace-open-order = none

  // Ending state: track open `end{label: ...}` volta spans
  let ending-start-idx = none
  let ending-label = none
  let ending-open-order = none

  let curly-open-serial = 0

  // Helper: peek at current character (returns none at end)
  let peek(p) = {
    if p < len { input.at(p) } else { none }
  }
  let next-nonspace-char(p) = {
    let next-pos = p
    while next-pos < len and (input.at(next-pos) == " " or input.at(next-pos) == "\t" or input.at(next-pos) == "\r") {
      next-pos += 1
    }
    peek(next-pos)
  }

  let is-word-char(ch) = {
    ch != none and (is-lower(ch) or is-digit(ch) or ch == "-")
  }

  let parse-time-token(token) = {
    if token == "common" or token == "C" {
      make-time-sig(4, 4, symbol: "common")
    } else if token == "cut" or token == "C|" {
      make-time-sig(2, 2, symbol: "cut")
    } else if token.contains("/") {
      let parts = token.split("/")
      if parts.len() == 2 and parts.at(0).len() > 0 and parts.at(1).len() > 0 {
        make-time-sig(int(parts.at(0)), int(parts.at(1)))
      } else {
        none
      }
    } else {
      none
    }
  }

  let parse-accidental(p) = {
    let next-pos = p
    let accidental = none
    let ac = peek(next-pos)
    if ac == "#" {
      next-pos += 1
      if peek(next-pos) == "#" {
        accidental = "double-sharp"
        next-pos += 1
      } else {
        accidental = "sharp"
      }
    } else if ac == "&" {
      next-pos += 1
      if peek(next-pos) == "&" {
        accidental = "double-flat"
        next-pos += 1
      } else {
        accidental = "flat"
      }
    } else if ac == "=" {
      accidental = "natural"
      next-pos += 1
    }
    (accidental: accidental, pos: next-pos)
  }

  let parse-octave-markers(p, octave) = {
    let next-pos = p
    let next-octave = octave
    while peek(next-pos) == "'" {
      next-octave += 1
      next-pos += 1
    }
    while peek(next-pos) == "," {
      next-octave -= 1
      next-pos += 1
    }
    (octave: next-octave, pos: next-pos)
  }

  let parse-duration-dots(p, sticky-duration: last-duration) = {
    let next-pos = p
    let duration = sticky-duration
    let dur-str = ""
    while peek(next-pos) != none and is-digit(peek(next-pos)) {
      dur-str += peek(next-pos)
      next-pos += 1
    }
    if dur-str.len() > 0 {
      duration = int(dur-str)
    }

    let dots = 0
    while peek(next-pos) == "." {
      dots += 1
      next-pos += 1
    }
    (duration: duration, dots: dots, pos: next-pos)
  }

  let read-bracketed-text(p) = {
    let next-pos = p
    let value = ""
    while next-pos < len and input.at(next-pos) != "]" {
      value += input.at(next-pos)
      next-pos += 1
    }
    if next-pos < len {
      next-pos += 1
    }
    (value: value, pos: next-pos)
  }

  let is-fingering-start(p) = {
    (
      peek(p) == "n"
      and p + 1 < len
      and (
        input.at(p + 1) == "["
        or (input.at(p + 1) == "_" and p + 2 < len and input.at(p + 2) == "[")
      )
    )
  }

  let parse-fingering(p) = {
    let below = p + 1 < len and input.at(p + 1) == "_"
    let parsed = read-bracketed-text(p + (if below { 3 } else { 2 }))
    let parts = parsed.value.split(" ").filter(s => s.len() > 0)
    let fingering = none
    if parts.len() == 1 {
      fingering = int(parts.at(0))
    } else if parts.len() > 1 {
      fingering = parts.map(s => int(s))
    }
    (
      fingering: fingering,
      fingering-position: if below { "below" } else { "above" },
      pos: parsed.pos,
    )
  }

  let parse-lyric(p) = {
    if peek(p) != "l" { return (entry: none, pos: p) }
    if p + 1 < len and input.at(p + 1) == "[" {
      let parsed = read-bracketed-text(p + 2)
      let raw = parsed.value
      let continuation = "none"
      let text = raw
      if raw.ends-with("-") {
        continuation = "hyphen"
        text = raw.slice(0, raw.len() - 1)
      } else if raw.ends-with("_") {
        continuation = "extender"
        text = raw.slice(0, raw.len() - 1)
      }
      (
        entry: (
          text: text,
          carry: false,
          continuation: continuation,
        ),
        pos: parsed.pos,
      )
    } else {
      (
        entry: (
          text: none,
          carry: true,
          continuation: "none",
        ),
        pos: p + 1,
      )
    }
  }

  let parse-tagged-text(p, tag) = {
    if p + tag.len() >= len or input.slice(p, p + tag.len()) != tag or input.at(p + tag.len()) != "[" {
      return (value: none, pos: p)
    }
    let parsed = read-bracketed-text(p + tag.len() + 1)
    (value: if parsed.value.len() > 0 { parsed.value } else { none }, pos: parsed.pos)
  }

  let parse-staff-marker(p) = {
    if (
      peek(p) == "c"
      and peek(p + 1) == "o"
      and peek(p + 2) == "d"
      and peek(p + 3) == "a"
    ) {
      (kind: "coda", pos: p + 4)
    } else if peek(p) == "b" and peek(p + 1) == "m" {
      (kind: "breath-mark", pos: p + 2)
    } else if peek(p) == "d" and peek(p + 1) == "s" {
      (kind: "dal-segno", pos: p + 2)
    } else if peek(p) == "/" and peek(p + 1) == "/" {
      (kind: "caesura", pos: p + 2)
    } else {
      (kind: none, pos: p)
    }
  }

  let parse-note-attachments(p) = {
    let next-pos = p
    let tie = false
    if peek(next-pos) == "~" {
      tie = true
      next-pos += 1
    }

    let articulations = ()
    while peek(next-pos) == ">" or peek(next-pos) == "*" or peek(next-pos) == "-" or peek(next-pos) == "_" {
      let ac = peek(next-pos)
      articulations.push(
        if ac == ">" {
          "accent"
        } else if ac == "*" {
          "staccato"
        } else if ac == "-" {
          "tenuto"
        } else {
          "fermata"
        }
      )
      next-pos += 1
    }

    let dynamic = none
    if peek(next-pos) == "v" and next-pos + 1 < len and input.at(next-pos + 1) == "[" {
      let parsed = read-bracketed-text(next-pos + 2)
      if parsed.value.len() > 0 {
        dynamic = parsed.value
      }
      next-pos = parsed.pos
    }

    if not tie and peek(next-pos) == "~" {
      tie = true
      next-pos += 1
    }

    let trill = false
    if peek(next-pos) == "t" and next-pos + 1 < len and input.at(next-pos + 1) == "r" {
      trill = true
      next-pos += 2
    }

    let staff-markers = ()
    let marker = parse-staff-marker(next-pos)
    while marker.kind != none {
      staff-markers.push(marker.kind)
      next-pos = marker.pos
      marker = parse-staff-marker(next-pos)
    }

    let slur-start = false
    let slur-end = false
    if peek(next-pos) == "(" {
      slur-start = true
      next-pos += 1
    }
    if peek(next-pos) == ")" {
      slur-end = true
      next-pos += 1
    }

    let beam-start = false
    let beam-end = false
    if peek(next-pos) == "[" {
      let nxt = if next-pos + 1 < len { input.at(next-pos + 1) } else { none }
      if nxt == none or not (nxt >= "A" and nxt <= "G") {
        beam-start = true
        next-pos += 1
      }
    }
    if peek(next-pos) == "]" {
      beam-end = true
      next-pos += 1
    }

    let chord-symbol = none
    let staff-text = none
    let expression-text = none
    let fingering = none
    let fingering-position = "above"
    let lyrics = ()
    while (
      peek(next-pos) == "["
      or is-fingering-start(next-pos)
      or peek(next-pos) == "l"
      or (
        next-pos + 5 <= len
        and (
          input.slice(next-pos, next-pos + 5) == "text["
          or input.slice(next-pos, next-pos + 4) == "exp["
        )
      )
    ) {
      if peek(next-pos) == "l" {
        let parsed = parse-lyric(next-pos)
        if parsed.entry != none {
          lyrics.push(parsed.entry)
        }
        next-pos = parsed.pos
      } else if next-pos + 5 <= len and input.slice(next-pos, next-pos + 5) == "text[" {
        let parsed = parse-tagged-text(next-pos, "text")
        staff-text = parsed.value
        next-pos = parsed.pos
      } else if next-pos + 4 <= len and input.slice(next-pos, next-pos + 4) == "exp[" {
        let parsed = parse-tagged-text(next-pos, "exp")
        expression-text = parsed.value
        next-pos = parsed.pos
      } else if is-fingering-start(next-pos) {
        let parsed = parse-fingering(next-pos)
        fingering = parsed.fingering
        fingering-position = parsed.fingering-position
        next-pos = parsed.pos
      } else {
        let parsed = read-bracketed-text(next-pos + 1)
        if parsed.value.len() > 0 {
          chord-symbol = parsed.value
        }
        next-pos = parsed.pos
      }
    }

    (
      tie: tie,
      articulations: articulations,
      dynamic: dynamic,
      trill: trill,
      slur-start: slur-start,
      slur-end: slur-end,
      beam-start: beam-start,
      beam-end: beam-end,
      chord-symbol: chord-symbol,
      staff-markers: staff-markers,
      staff-text: staff-text,
      expression-text: expression-text,
      fingering: fingering,
      fingering-position: fingering-position,
      lyrics: lyrics,
      pos: next-pos,
    )
  }

  let parse-note-pitch(p, base-octave: current-base-octave) = {
    let accidental = parse-accidental(p)
    let octave = parse-octave-markers(accidental.pos, base-octave)
    (accidental: accidental.accidental, octave: octave.octave, pos: octave.pos)
  }

  let parse-note-event-data(p, base-octave: current-base-octave, sticky-duration: last-duration) = {
    let pitch = parse-note-pitch(p, base-octave: base-octave)
    let rhythm = parse-duration-dots(pitch.pos, sticky-duration: sticky-duration)
    let attachments = parse-note-attachments(rhythm.pos)
    (
      accidental: pitch.accidental,
      octave: pitch.octave,
      duration: rhythm.duration,
      dots: rhythm.dots,
      tie: attachments.tie,
      articulations: attachments.articulations,
      dynamic: attachments.dynamic,
      trill: attachments.trill,
      slur-start: attachments.slur-start,
      slur-end: attachments.slur-end,
      beam-start: attachments.beam-start,
      beam-end: attachments.beam-end,
      chord-symbol: attachments.chord-symbol,
      staff-markers: attachments.staff-markers,
      staff-text: attachments.staff-text,
      expression-text: attachments.expression-text,
      fingering: attachments.fingering,
      fingering-position: attachments.fingering-position,
      lyrics: attachments.lyrics,
      pos: attachments.pos,
    )
  }

  while pos < len {
    let ch = input.at(pos)

    // --- Skip whitespace ---
    if ch == " " or ch == "\t" or ch == "\r" {
      let start = pos
      while pos < len and (input.at(pos) == " " or input.at(pos) == "\t" or input.at(pos) == "\r") {
        pos += 1
      }
      let run-len = pos - start
      let next = next-nonspace-char(pos)
      let prev-event = if events.len() > 0 { events.last() } else { none }
      if (
        run-len > 1
        and prev-event != none
        and prev-event.type != "barline"
        and prev-event.type != "line-break"
        and next != none
        and next != "\n"
        and next != "|"
      ) {
        events.push(make-gap(amount: run-len - 1))
      }
      continue
    }

    // --- Newlines signal system breaks ---
    if ch == "\n" {
      pos += 1
      // Skip subsequent whitespace/blank lines
      while pos < len {
        let nc = input.at(pos)
        if nc == " " or nc == "\t" or nc == "\r" or nc == "\n" {
          pos += 1
        } else {
          break
        }
      }
      // Only emit a line-break if there's more content ahead and we already have events
      if pos < len and events.len() > 0 {
        events.push(make-line-break())
      }
      continue
    }

    // --- Barlines ---
    // Check multi-character barlines first
    if ch == "|" {
      // Look ahead for double, final, repeat barlines
      let next = peek(pos + 1)
      if next == "|" {
        if peek(pos + 2) == ":" {
          // "||:" - repeat start
          events.push(make-barline(style: "repeat-start"))
          pos += 3
        } else {
          // "||" - double barline
          events.push(make-barline(style: "double"))
          pos += 2
        }
      } else if next == ":" {
        // "|:" - repeat start
        events.push(make-barline(style: "repeat-start"))
        pos += 2
      } else if next == "." {
        // "|." - final barline
        events.push(make-barline(style: "final"))
        pos += 2
      } else {
        // "|" - single barline
        events.push(make-barline(style: "single"))
        pos += 1
      }
      continue
    }

    // --- Repeat-end barlines starting with ":" ---
    if ch == ":" {
      let next = peek(pos + 1)
      if next == "|" {
        if peek(pos + 2) == "|" and peek(pos + 3) == ":" {
          // ":||:" - repeat both
          events.push(make-barline(style: "repeat-both"))
          pos += 4
        } else if peek(pos + 2) == ":" {
          // ":|:" - repeat both
          events.push(make-barline(style: "repeat-both"))
          pos += 3
        } else if peek(pos + 2) == "|" {
          // ":||" - repeat end
          events.push(make-barline(style: "repeat-end"))
          pos += 3
        } else {
          // ":|" - repeat end
          events.push(make-barline(style: "repeat-end"))
          pos += 2
        }
      } else {
        // Unknown colon - skip
        pos += 1
      }
      continue
    }

    // --- Chords: <note1 note2 ...>duration ---
    if ch == "<" {
      pos += 1
      let chord-notes = ()
      while pos < len and input.at(pos) != ">" {
        let c = input.at(pos)
        if is-whitespace(c) { pos += 1; continue }
        if (c >= "a" and c <= "g") {
          let cname = c
          pos += 1
          let pitch = parse-note-pitch(pos, base-octave: current-base-octave)
          pos = pitch.pos
          chord-notes.push((name: cname, accidental: pitch.accidental, octave: pitch.octave))
        } else {
          pos += 1
        }
      }
      // Consume the closing ">"
      if pos < len and input.at(pos) == ">" { pos += 1 }

      let rhythm = parse-duration-dots(pos, sticky-duration: last-duration)
      let attachments = parse-note-attachments(rhythm.pos)
      pos = attachments.pos
      last-duration = rhythm.duration

      if chord-notes.len() > 0 {
        events.push(make-chord(
          chord-notes,
          duration: rhythm.duration,
          dots: rhythm.dots,
          tie: attachments.tie,
          slur-start: attachments.slur-start,
          slur-end: attachments.slur-end,
          beam-start: attachments.beam-start,
          beam-end: attachments.beam-end,
          articulations: attachments.articulations,
          dynamic: attachments.dynamic,
          trill: attachments.trill,
          fingering: attachments.fingering,
          fingering-position: attachments.fingering-position,
          chord-symbol: attachments.chord-symbol,
          staff-markers: attachments.staff-markers,
          staff-text: attachments.staff-text,
          expression-text: attachments.expression-text,
          lyrics: attachments.lyrics,
        ))
      }
      continue
    }

    // --- Inline clef changes ---
    if is-lower(ch) {
      let word-end = pos
      while word-end < len and is-word-char(input.at(word-end)) {
        word-end += 1
      }
      let token = input.slice(pos, word-end)
      if token == "end" and word-end < len and input.at(word-end) == "{" {
        let label-pos = word-end + 1
        let label = ""
        while label-pos < len and input.at(label-pos) != ":" and input.at(label-pos) != "}" {
          label += input.at(label-pos)
          label-pos += 1
        }
        if label-pos < len and input.at(label-pos) == ":" {
          if ending-start-idx != none {
            let members = ()
            for i in range(ending-start-idx, events.len()) {
              let ev = events.at(i)
              if ev.type != "line-break" {
                members.push(i)
              }
            }
            if members.len() > 0 {
              let first = members.first()
              let last = members.last()
              for i in members {
                events.at(i).ending = ending-label
                if i == first { events.at(i).ending-start = true }
                if i == last { events.at(i).ending-end = true }
              }
            }
            ending-start-idx = none
            ending-label = none
            ending-open-order = none
          }
          ending-start-idx = events.len()
          ending-label = label.trim()
          curly-open-serial += 1
          ending-open-order = curly-open-serial
          pos = label-pos + 1
          continue
        }
      }
      if word-end < len and input.at(word-end) == "{" and (token == "cresc" or token == "decresc") {
        if hairpin-start-idx != none {
          let anchors = ()
          for i in range(hairpin-start-idx, events.len()) {
            let ev = events.at(i)
            if ev.type == "note" or ev.type == "chord" or ev.type == "rest" {
              anchors.push(i)
            }
          }
          if anchors.len() > 0 {
            let first = anchors.first()
            let last = anchors.last()
            for i in anchors {
              events.at(i).hairpin = hairpin-kind
              if i == first { events.at(i).hairpin-start = true }
              if i == last { events.at(i).hairpin-end = true }
            }
          }
          hairpin-open-order = none
        }
        hairpin-start-idx = events.len()
        hairpin-kind = token
        curly-open-serial += 1
        hairpin-open-order = curly-open-serial
        pos = word-end + 1
        continue
      }
      if token == "tr" and word-end < len and input.at(word-end) == "{" {
        if trill-start-idx != none {
          let anchors = ()
          for i in range(trill-start-idx, events.len()) {
            let ev = events.at(i)
            if ev.type == "note" or ev.type == "chord" or ev.type == "rest" {
              anchors.push(i)
            }
          }
          if anchors.len() > 0 {
            let first = anchors.first()
            let last = anchors.last()
            for i in anchors {
              events.at(i).trill = true
              events.at(i).trill-line = true
              if i == first { events.at(i).trill-start = true }
              if i == last { events.at(i).trill-end = true }
            }
          }
        }
        trill-start-idx = events.len()
        curly-open-serial += 1
        trill-open-order = curly-open-serial
        pos = word-end + 1
        continue
      }
      if token == "grace" and word-end < len and input.at(word-end) == "{" {
        grace-start-idx = events.len()
        grace-slash = false
        curly-open-serial += 1
        grace-open-order = curly-open-serial
        pos = word-end + 1
        continue
      }
      let time-event = parse-time-token(token)
      if time-event != none {
        events.push(time-event)
        pos = word-end
        continue
      } else if supported-clefs.contains(token) {
        events.push(make-clef(token))
        current-base-octave = clef-default-base-octave(token)
        pos = word-end
        continue
      }
    }

    // --- Inline time signatures with uppercase shorthand ---
    if ch == "C" {
      let token = if pos + 1 < len and input.at(pos + 1) == "|" { "C|" } else { "C" }
      let time-event = parse-time-token(token)
      let end-pos = if token == "C|" { pos + 2 } else { pos + 1 }
      let next = peek(end-pos)
      if time-event != none and (next == none or is-whitespace(next) or next == "|" or next == "\n") {
        events.push(time-event)
        pos = end-pos
        continue
      }
    }

    // --- Notes (a-g) ---
    if ch >= "a" and ch <= "g" {
      let name = ch
      pos += 1
      let note = parse-note-event-data(
        pos,
        base-octave: current-base-octave,
        sticky-duration: last-duration,
      )
      pos = note.pos
      last-duration = note.duration

      events.push(make-note(
        name,
        accidental: note.accidental,
        octave: note.octave,
        duration: note.duration,
        dots: note.dots,
        tie: note.tie,
        slur-start: note.slur-start,
        slur-end: note.slur-end,
        beam-start: note.beam-start,
        beam-end: note.beam-end,
        articulations: note.articulations,
        dynamic: note.dynamic,
        trill: note.trill,
        fingering: note.fingering,
        fingering-position: note.fingering-position,
        chord-symbol: note.chord-symbol,
        staff-markers: note.at("staff-markers", default: ()),
        staff-text: note.at("staff-text", default: none),
        expression-text: note.at("expression-text", default: none),
        lyrics: note.lyrics,
      ))
      continue
    }

    // --- Rests ---
    if ch == "r" {
      pos += 1
      let rhythm = parse-duration-dots(pos, sticky-duration: last-duration)
      pos = rhythm.pos
      last-duration = rhythm.duration
      events.push(make-rest(duration: rhythm.duration, dots: rhythm.dots))
      continue
    }

    // --- Spacers (invisible rests) ---
    if ch == "s" {
      pos += 1
      let rhythm = parse-duration-dots(pos, sticky-duration: last-duration)
      pos = rhythm.pos
      last-duration = rhythm.duration
      events.push(make-spacer(duration: rhythm.duration, dots: rhythm.dots))
      continue
    }

    // --- Slur start/end (when not after a note) ---
    if ch == "(" {
      // Attach to previous note if possible
      if events.len() > 0 {
        let last = events.last()
        if last.type == "note" {
          events.at(events.len() - 1).slur-start = true
        }
      }
      pos += 1
      continue
    }
    if ch == ")" {
      if events.len() > 0 {
        let last = events.last()
        if last.type == "note" {
          events.at(events.len() - 1).slur-end = true
        }
      }
      pos += 1
      continue
    }

    // --- Tuplet start: "{n,m:" ---
    // n = number of beats this tuplet occupies for spacing
    // m = the tuplet number displayed on the bracket
    if ch == "{" {
      pos += 1
      // Skip optional whitespace
      while pos < len and (input.at(pos) == " " or input.at(pos) == "\t") { pos += 1 }
      // Parse n (beats, required digit string)
      let n-str = ""
      while pos < len and is-digit(input.at(pos)) {
        n-str += input.at(pos)
        pos += 1
      }
      if n-str.len() > 0 {
        let tb = int(n-str)  // tuplet-beats
        let tn = tb           // tuplet-number defaults to beats if not specified
        // Parse ",m" (required comma then tuplet number)
        if pos < len and input.at(pos) == "," {
          pos += 1
          let m-str = ""
          while pos < len and is-digit(input.at(pos)) {
            m-str += input.at(pos)
            pos += 1
          }
          if m-str.len() > 0 { tn = int(m-str) }
        }
        // Skip colon separator
        if pos < len and input.at(pos) == ":" { pos += 1 }
        // Skip whitespace after header
        while pos < len and (input.at(pos) == " " or input.at(pos) == "\t") { pos += 1 }
        tuplet-start-idx = events.len()
        tuplet-n = tn    // tuplet number (displayed)
        tuplet-m = tb     // tuplet beats (spacing)
        curly-open-serial += 1
        tuplet-open-order = curly-open-serial
      }
      continue
    }

    // --- Octave-line start: "<number>a{" or "<number>b{" ---
    // Examples: 8a{ ... }  15b{ ... }
    if is-digit(ch) {
      let p = pos
      let nstr = ""
      while p < len and is-digit(input.at(p)) { nstr += input.at(p); p += 1 }
      if nstr.len() > 0 and p < len and input.at(p) == "/" {
        let q = p + 1
        let dstr = ""
        while q < len and is-digit(input.at(q)) { dstr += input.at(q); q += 1 }
        if dstr.len() > 0 {
          let next = peek(q)
          if next == none or is-whitespace(next) or next == "|" or next == "\n" {
            events.push(make-time-sig(int(nstr), int(dstr)))
            pos = q
            continue
          }
        }
      }
      if nstr.len() > 0 and p < len {
        let suf = input.at(p)
        if suf == "a" or suf == "b" {
          // Allow optional whitespace between suffix and "{"
          let q = p + 1
          while q < len and (input.at(q) == " " or input.at(q) == "\t") { q += 1 }
          if q < len and input.at(q) == "{" {
            octline-start-idx = events.len()
            octline-number = int(nstr)
            octline-dir = if suf == "a" { "above" } else { "below" }
            curly-open-serial += 1
            octline-open-order = curly-open-serial
            pos = q + 1
            continue
          }
        }
      }
    }

    // --- Tuplet end: "}" ---
    if ch == "/" and peek(pos + 1) == "}" and grace-open-order != none {
      grace-slash = true
      pos += 1
      continue
    }

    if ch == "}" {
      let latest-order = -1
      let close-kind = none
      if tuplet-open-order != none and tuplet-open-order > latest-order {
        latest-order = tuplet-open-order
        close-kind = "tuplet"
      }
      if octline-open-order != none and octline-open-order > latest-order {
        latest-order = octline-open-order
        close-kind = "octline"
      }
      if ending-open-order != none and ending-open-order > latest-order {
        latest-order = ending-open-order
        close-kind = "ending"
      }
      if hairpin-open-order != none and hairpin-open-order > latest-order {
        latest-order = hairpin-open-order
        close-kind = "hairpin"
      }
      if trill-open-order != none and trill-open-order > latest-order {
        latest-order = trill-open-order
        close-kind = "trill"
      }
      if grace-open-order != none and grace-open-order > latest-order {
        latest-order = grace-open-order
        close-kind = "grace"
      }

      if close-kind == "tuplet" {
        let end-idx = events.len()
        let count = end-idx - tuplet-start-idx
        for i in range(tuplet-start-idx, end-idx) {
          events.at(i).tuplet-beats = tuplet-m
          events.at(i).tuplet-number = tuplet-n
          events.at(i).tuplet-count = count
          if i == tuplet-start-idx { events.at(i).tuplet-start = true }
          if i == end-idx - 1 { events.at(i).tuplet-end = true }
        }
        tuplet-start-idx = none
        tuplet-n = none
        tuplet-m = none
        tuplet-open-order = none
      } else if close-kind == "octline" {
        let end-idx = events.len()
        for i in range(octline-start-idx, end-idx) {
          events.at(i).octave-line-number = octline-number
          events.at(i).octave-line-direction = octline-dir
          if i == octline-start-idx { events.at(i).octave-line-start = true }
          if i == end-idx - 1 { events.at(i).octave-line-end = true }
        }
        octline-start-idx = none
        octline-number = none
        octline-dir = none
        octline-open-order = none
      } else if close-kind == "ending" {
        let members = ()
        for i in range(ending-start-idx, events.len()) {
          let ev = events.at(i)
          if ev.type != "line-break" {
            members.push(i)
          }
        }
        if members.len() > 0 {
          let first = members.first()
          let last = members.last()
          for i in members {
            events.at(i).ending = ending-label
            if i == first { events.at(i).ending-start = true }
            if i == last { events.at(i).ending-end = true }
          }
        }
        ending-start-idx = none
        ending-label = none
        ending-open-order = none
      } else if close-kind == "hairpin" {
        let anchors = ()
        for i in range(hairpin-start-idx, events.len()) {
          let ev = events.at(i)
          if ev.type == "note" or ev.type == "chord" or ev.type == "rest" {
            anchors.push(i)
          }
        }
        if anchors.len() > 0 {
          let first = anchors.first()
          let last = anchors.last()
          for i in anchors {
            events.at(i).hairpin = hairpin-kind
            if i == first { events.at(i).hairpin-start = true }
            if i == last { events.at(i).hairpin-end = true }
          }
        }
        hairpin-start-idx = none
        hairpin-kind = none
        hairpin-open-order = none
      } else if close-kind == "trill" {
        let anchors = ()
        for i in range(trill-start-idx, events.len()) {
          let ev = events.at(i)
          if ev.type == "note" or ev.type == "chord" or ev.type == "rest" {
            anchors.push(i)
          }
        }
        if anchors.len() > 0 {
          let first = anchors.first()
          let last = anchors.last()
          for i in anchors {
            events.at(i).trill = true
            events.at(i).trill-line = true
            if i == first { events.at(i).trill-start = true }
            if i == last { events.at(i).trill-end = true }
          }
        }
        trill-start-idx = none
        trill-open-order = none
      } else if close-kind == "grace" {
        let anchors = ()
        for i in range(grace-start-idx, events.len()) {
          let ev = events.at(i)
          if ev.type == "note" or ev.type == "chord" or ev.type == "rest" {
            anchors.push(i)
          }
        }
        if anchors.len() > 0 {
          for i in anchors {
            events.at(i).grace = true
            events.at(i).grace-slash = grace-slash
          }
        }
        grace-start-idx = none
        grace-slash = false
        grace-open-order = none
      }
      pos += 1
      continue
    }

    // --- Unknown character: skip ---
    pos += 1
  }

  if hairpin-start-idx != none {
    let anchors = ()
    for i in range(hairpin-start-idx, events.len()) {
      let ev = events.at(i)
      if ev.type == "note" or ev.type == "chord" or ev.type == "rest" {
        anchors.push(i)
      }
    }
    if anchors.len() > 0 {
      let first = anchors.first()
      let last = anchors.last()
      for i in anchors {
        events.at(i).hairpin = hairpin-kind
        if i == first { events.at(i).hairpin-start = true }
        if i == last { events.at(i).hairpin-end = true }
      }
    }
  }

  if trill-start-idx != none {
    let anchors = ()
    for i in range(trill-start-idx, events.len()) {
      let ev = events.at(i)
      if ev.type == "note" or ev.type == "chord" or ev.type == "rest" {
        anchors.push(i)
      }
    }
    if anchors.len() > 0 {
      let first = anchors.first()
      let last = anchors.last()
      for i in anchors {
        events.at(i).trill = true
        events.at(i).trill-line = true
        if i == first { events.at(i).trill-start = true }
        if i == last { events.at(i).trill-end = true }
      }
    }
  }

  if ending-start-idx != none {
    let members = ()
    for i in range(ending-start-idx, events.len()) {
      let ev = events.at(i)
      if ev.type != "line-break" {
        members.push(i)
      }
    }
    if members.len() > 0 {
      let first = members.first()
      let last = members.last()
      for i in members {
        events.at(i).ending = ending-label
        if i == first { events.at(i).ending-start = true }
        if i == last { events.at(i).ending-end = true }
      }
    }
  }

  if grace-start-idx != none {
    let anchors = ()
    for i in range(grace-start-idx, events.len()) {
      let ev = events.at(i)
      if ev.type == "note" or ev.type == "chord" or ev.type == "rest" {
        anchors.push(i)
      }
    }
    if anchors.len() > 0 {
      for i in anchors {
        events.at(i).grace = true
        events.at(i).grace-slash = grace-slash
      }
    }
  }

  events
}
