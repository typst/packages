#import "@preview/cetz:0.5.2"
#import "../foundation/diagnostics.typ": _score-error

// Lyric input, onset alignment, spacing, and engraving.

#let _lyric-minimum-justification-scale = 0.82
#let _lyric-syllable-gap = 0.55
#let _lyric-hyphen-gap = 1.1
#let _lyric-extender-thickness = 0.09

#let _lyric-onset-key(onset) = {
  int(onset.numerator * 4096 / onset.denominator)
}

#let _lyric-text-style(unit, lyric-size, lyric-font, paint: black) = {
  let style = (size: unit * lyric-size, fill: paint)
  if lyric-font != none {
    style.insert("font", lyric-font)
  }
  style
}

#let _lyric-text-width(syllable, lyric-size, lyric-font) = {
  measure(
    text(.._lyric-text-style(8pt, lyric-size, lyric-font), syllable),
  ).width / 8pt
}

#let _normalize-verse-sequences(value, label) = {
  let verses = if type(value) == str { (value,) } else if type(value) == array {
    value
  } else {
    _score-error(
      label,
      "lyrics must be a string or an array of verse strings",
      value: value,
      expected: "one lyric string or a non-empty array of lyric strings",
      fix: "quote one verse or wrap several quoted verses in an array",
    )
  }
  if verses.len() == 0 {
    _score-error(
      label,
      "verse array must not be empty",
      value: value,
      expected: "one or more lyric strings",
      fix: "add a verse or remove the lyrics field",
    )
  }
  for (verse-index, verse) in verses.enumerate() {
    if type(verse) != str or verse.trim() == "" {
      _score-error(
        label + " verse " + str(verse-index + 1),
        "verse must be a non-empty string",
        value: verse,
        expected: "syllables separated by spaces",
        fix: "provide visible lyric text or remove the empty verse",
      )
    }
  }
  verses
}

#let _normalize-measure-lyrics(value, staff-specs, measure-number) = {
  if value == none { return (:) }
  let label = "lyrics in bar " + str(measure-number)
  if staff-specs.len() == 1 and type(value) != dictionary {
    let normalized = (:)
    normalized.insert(
      staff-specs.first().id,
      _normalize-verse-sequences(value, label),
    )
    return normalized
  }
  if type(value) != dictionary or value.len() == 0 {
    _score-error(
      label,
      "multi-staff lyrics must be a non-empty staff dictionary",
      value: value,
      expected: "declared staff IDs mapped to lyric strings or verse arrays",
      fix: "write lyrics: (staff-id: \"words\")",
    )
  }
  let normalized = (:)
  for staff-id in value.keys() {
    if not staff-specs.any(staff => staff.id == staff-id) {
      _score-error(
        label,
        "lyrics reference an unknown staff",
        value: staff-id,
        expected: staff-specs.map(staff => staff.id).join(", "),
        fix: "use a declared staff ID",
      )
    }
    normalized.insert(
      staff-id,
      _normalize-verse-sequences(
        value.at(staff-id),
        label + " staff " + staff-id,
      ),
    )
  }
  normalized
}

#let _main-pitched-layouts(voice) = {
  voice.layouts.filter(layout => (
    not layout.rest and not layout.at("grace", default: false)
  ))
}

#let _lyric-state-key(staff-id, verse-index) = {
  staff-id + ".verse" + str(verse-index + 1)
}

#let _layout-lyric-verse(
  sequence,
  voice,
  verse-index,
  measure-index,
  state,
  lyric-size,
  lyric-font,
) = {
  let location = (
    "lyrics in bar " + str(measure-index + 1)
      + ", staff " + voice.staff-id
      + ", verse " + str(verse-index + 1)
  )
  let lyric-events = _main-pitched-layouts(voice)
  let tokens = sequence.trim().split(" ").filter(token => token != "")
  let items = ()
  let event-index = 0
  let previous-token-kind = none
  let last-syllable-id = state.at("last-syllable-id", default: none)
  let last-syllable-has-hyphen = state.at("last-syllable-has-hyphen", default: false)

  for token in tokens {
    if token == "--" {
      if previous-token-kind != "syllable" {
        _score-error(
          location,
          "hyphen control must immediately follow a syllable",
          value: sequence,
          expected: "syllable -- syllable",
          fix: "move -- after the syllable it joins or remove it",
        )
      }
      let previous = items.len() - 1
      items.at(previous) = items.at(previous) + (hyphen-after: true,)
      last-syllable-has-hyphen = true
      previous-token-kind = "hyphen"
      continue
    }
    if event-index >= lyric-events.len() {
      _score-error(
        location,
        "lyrics have more alignment tokens than pitched events",
        value: sequence,
        expected: str(lyric-events.len()) + " syllable, extender, or skip tokens",
        fix: "remove extra lyric tokens or add pitched events to the staff's first voice",
      )
    }
    let layout = lyric-events.at(event-index)
    if token == "__" {
      if last-syllable-id == none {
        _score-error(
          location,
          "melisma extender has no preceding syllable",
          value: sequence,
          expected: "a syllable before the first __ token",
          fix: "add the sustained syllable or replace __ with _ for a silent skip",
        )
      }
      if last-syllable-has-hyphen {
        _score-error(
          location,
          "a syllable cannot start both a hyphenated word and a melisma",
          value: sequence,
          expected: "either -- followed by a syllable or __ over sustained notes",
          fix: "remove -- or replace the extender with the next syllable",
        )
      }
      items.push((
        kind: "extender",
        source-id: last-syllable-id,
        onset: layout.onset,
        measure-index: measure-index,
        staff-id: voice.staff-id,
        staff-index: voice.staff-index,
        verse-index: verse-index,
      ))
      previous-token-kind = "extender"
    } else if token == "_" {
      last-syllable-id = none
      last-syllable-has-hyphen = false
      previous-token-kind = "skip"
    } else {
      let syllable-id = (
        voice.staff-id + ".verse" + str(verse-index + 1)
          + ".bar" + str(measure-index + 1)
          + ".event" + str(event-index + 1)
      )
      items.push((
        kind: "syllable",
        id: syllable-id,
        text: token.replace("_", " "),
        width: _lyric-text-width(token.replace("_", " "), lyric-size, lyric-font),
        hyphen-after: false,
        onset: layout.onset,
        measure-index: measure-index,
        staff-id: voice.staff-id,
        staff-index: voice.staff-index,
        verse-index: verse-index,
      ))
      last-syllable-id = syllable-id
      last-syllable-has-hyphen = false
      previous-token-kind = "syllable"
    }
    event-index += 1
  }

  if event-index != lyric-events.len() {
    _score-error(
      location,
      "lyrics do not account for every pitched event",
      value: sequence,
      expected: str(lyric-events.len()) + " syllable, extender, or skip tokens",
      fix: "add syllables, __ extenders, or _ skips for the remaining pitched events",
    )
  }
  (
    items: items,
    state: (
      last-syllable-id: last-syllable-id,
      last-syllable-has-hyphen: last-syllable-has-hyphen,
    ),
  )
}

#let _layout-measure-lyrics(
  normalized-lyrics,
  prepared-voices,
  measure-index,
  lyric-states,
  lyric-size,
  lyric-font,
) = {
  let items = ()
  for staff-id in normalized-lyrics.keys() {
    let voice = prepared-voices.find(voice => (
      voice.staff-id == staff-id and voice.layer-index == 0
    ))
    for (verse-index, sequence) in normalized-lyrics.at(staff-id).enumerate() {
      let state-key = _lyric-state-key(staff-id, verse-index)
      let response = _layout-lyric-verse(
        sequence,
        voice,
        verse-index,
        measure-index,
        lyric-states.at(state-key, default: (:)),
        lyric-size,
        lyric-font,
      )
      items += response.items
      lyric-states.insert(state-key, response.state)
    }
  }
  (items: items, states: lyric-states)
}

#let _validate-lyric-continuations(measures) = {
  let all-items = ()
  for measure in measures { all-items += measure.lyrics }
  for item in all-items {
    if item.kind != "syllable" or not item.hyphen-after { continue }
    let next-syllable = all-items.find(candidate => (
      candidate.kind == "syllable"
        and candidate.staff-id == item.staff-id
        and candidate.verse-index == item.verse-index
        and candidate.id != item.id
        and (
          candidate.measure-index > item.measure-index
            or (
              candidate.measure-index == item.measure-index
                and _lyric-onset-key(candidate.onset) > _lyric-onset-key(item.onset)
            )
        )
    ))
    if next-syllable == none {
      _score-error(
        "lyrics staff " + item.staff-id + " verse " + str(item.verse-index + 1),
        "hyphenated syllable has no following syllable",
        value: item.text,
        expected: "another syllable later in the same staff and verse",
        fix: "add the next syllable or remove the trailing --",
      )
    }
  }
}

#let _lyric-spacing-items(lyrics) = {
  lyrics.filter(item => item.kind == "syllable")
}

#let _add-lyric-spacing-demands(
  lyrics,
  first-onset-x,
  demands-by-ending-onset,
  measure-end-demands,
) = {
  let verse-keys = ()
  for item in _lyric-spacing-items(lyrics) {
    let key = item.staff-id + "." + str(item.verse-index)
    if key not in verse-keys { verse-keys.push(key) }
  }
  for verse-key in verse-keys {
    let syllables = _lyric-spacing-items(lyrics).filter(item => (
      item.staff-id + "." + str(item.verse-index) == verse-key
    ))
    if syllables.len() == 0 { continue }
    let first = syllables.first()
    first-onset-x = calc.max(
      first-onset-x,
      first.width / (2 * _lyric-minimum-justification-scale) + _lyric-syllable-gap,
    )
    for syllable-index in range(syllables.len()) {
      let syllable = syllables.at(syllable-index)
      if syllable-index + 1 < syllables.len() {
        let next = syllables.at(syllable-index + 1)
        let gap = if syllable.hyphen-after { _lyric-hyphen-gap } else { _lyric-syllable-gap }
        let demand = (
          from: _lyric-onset-key(syllable.onset),
          distance: (syllable.width / 2 + next.width / 2 + gap)
            / _lyric-minimum-justification-scale,
        )
        let next-key = str(_lyric-onset-key(next.onset))
        if next-key in demands-by-ending-onset {
          demands-by-ending-onset.at(next-key).push(demand)
        } else {
          demands-by-ending-onset.insert(next-key, (demand,))
        }
      } else {
        measure-end-demands.push((
          from: _lyric-onset-key(syllable.onset),
          distance: syllable.width / (2 * _lyric-minimum-justification-scale)
            + _lyric-syllable-gap,
        ))
      }
    }
  }
  (
    first-onset-x: first-onset-x,
    demands-by-ending-onset: demands-by-ending-onset,
    measure-end-demands: measure-end-demands,
  )
}

#let _lyric-verse-counts(measures, staff-count) = {
  let counts = (:)
  for staff-index in range(staff-count) { counts.insert(str(staff-index), 0) }
  for measure in measures {
    for item in measure.lyrics {
      counts.at(str(item.staff-index)) = calc.max(
        counts.at(str(item.staff-index)),
        item.verse-index + 1,
      )
    }
  }
  counts
}

#let _lyric-lane-center(
  note-extent-low,
  verse-index,
  lyric-size,
  lyric-gap,
  verse-gap,
) = {
  note-extent-low - lyric-gap - lyric-size / 2 - verse-index * verse-gap
}

#let _placed-lyric-items(
  system-measures,
  measure-note-starts,
  measure-justifications,
) = {
  let placed = ()
  for (measure-index, measure) in system-measures.enumerate() {
    for item in measure.lyrics {
      placed.push(item + (
        x: measure-note-starts.at(measure-index)
          + measure.positions.at(str(_lyric-onset-key(item.onset)))
            * measure-justifications.at(measure-index),
      ))
    }
  }
  placed
}

#let _draw-lyric-hyphens(
  item,
  next-syllable,
  source-x,
  target-x,
  y,
  lyric-size,
  lyric-font,
  unit,
  paint,
) = {
  import cetz.draw: *
  let start-x = source-x + item.width / 2 + 0.18
  let stop-x = target-x - next-syllable.width / 2 - 0.18
  if stop-x <= start-x { return }
  let span = stop-x - start-x
  let count = calc.max(1, int(calc.floor(span / 2.4)))
  for index in range(count) {
    let x = start-x + span * (index + 0.5) / count
    content(
      (x, y),
      text(.._lyric-text-style(unit, lyric-size * 0.85, lyric-font, paint: paint), "–"),
      anchor: "center",
      padding: 0pt,
    )
  }
}

#let _draw-system-lyrics(
  measures,
  system,
  placed-lyrics,
  bottom-map,
  staff-note-extents,
  lyric-size,
  lyric-font,
  lyric-gap,
  verse-gap,
  left-x,
  right-x,
  unit,
  paint: black,
) = {
  import cetz.draw: *
  let all-items = ()
  for measure in measures { all-items += measure.lyrics }
  let system-stop = system.start + system.widths.len()
  let placed-by-id = (:)
  for item in placed-lyrics {
    if item.kind == "syllable" { placed-by-id.insert(item.id, item) }
  }

  for item in placed-lyrics {
    if item.kind != "syllable" { continue }
    let y = bottom-map.at(str(item.staff-index)) + _lyric-lane-center(
      staff-note-extents.at(item.staff-index).low,
      item.verse-index,
      lyric-size,
      lyric-gap,
      verse-gap,
    )
    content(
      (item.x, y),
      text(.._lyric-text-style(unit, lyric-size, lyric-font, paint: paint), item.text),
      anchor: "center",
      padding: 0pt,
    )
  }

  for item in all-items {
    if item.kind != "syllable" { continue }
    let same-verse = candidate => (
      candidate.staff-id == item.staff-id
        and candidate.verse-index == item.verse-index
    )
    let y = bottom-map.at(str(item.staff-index)) + _lyric-lane-center(
      staff-note-extents.at(item.staff-index).low,
      item.verse-index,
      lyric-size,
      lyric-gap,
      verse-gap,
    )
    if item.hyphen-after {
      let next = all-items.find(candidate => (
        candidate.kind == "syllable"
          and same-verse(candidate)
          and candidate.id != item.id
          and (
            candidate.measure-index > item.measure-index
              or (
                candidate.measure-index == item.measure-index
                  and _lyric-onset-key(candidate.onset) > _lyric-onset-key(item.onset)
              )
          )
      ))
      let intersects-system = item.measure-index < system-stop and next.measure-index >= system.start
      if intersects-system {
        let source-x = if item.id in placed-by-id { placed-by-id.at(item.id).x } else {
          left-x - item.width / 2
        }
        let target-x = if next.id in placed-by-id { placed-by-id.at(next.id).x } else {
          right-x + next.width / 2
        }
        _draw-lyric-hyphens(
          item,
          next,
          source-x,
          target-x,
          y,
          lyric-size,
          lyric-font,
          unit,
          paint,
        )
      }
    }
    let extenders = all-items.filter(candidate => (
      candidate.kind == "extender" and candidate.source-id == item.id
    ))
    if extenders.len() > 0 {
      let last = extenders.last()
      let intersects-system = item.measure-index < system-stop and last.measure-index >= system.start
      if intersects-system {
        let source-x = if item.id in placed-by-id {
          placed-by-id.at(item.id).x + item.width / 2 + 0.22
        } else {
          left-x
        }
        let placed-extenders = placed-lyrics.filter(candidate => (
          candidate.kind == "extender" and candidate.source-id == item.id
        ))
        let target-x = if placed-extenders.len() > 0 {
          placed-extenders.last().x + 0.58
        } else {
          right-x
        }
        if target-x > source-x {
          line(
            (source-x, y - lyric-size * 0.34),
            (target-x, y - lyric-size * 0.34),
            stroke: _lyric-extender-thickness * unit + paint,
          )
        }
      }
    }
  }
}
