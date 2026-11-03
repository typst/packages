#import "diagnostics.typ": _nonnegative-number, _positive-number, _score-error, _validate-marking, _validate-system-gap
#import "signatures.typ": _validate-clef, _validate-key
#import "meter.typ": _parse-time-rational
#import "markings.typ": _normalize-tempo, _validate-staff-direction-spans
#import "ties-slurs.typ": _validate-staff-slurs, _validate-staff-ties
#import "score-input.typ": _prepare-score-measures
#import "systems.typ": _collect-ending-spans, _finalize-systems, _left-bar-x-for-group, _measure-width-in-system, _pack-score-systems, _render-score-system, _staff-label-reserve, _system-clef-after-barline-gap

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

#let score(
  clef: "treble",
  staves: none,
  bars: (),
  key: "C",
  time: "4/4",
  tempo: none,
  composer: none,
  width: none,
  scale: 1.0,
  note-spacing: 3.1,
  beams: false,
  staff-gap: none,
  group: auto,
  wrap: true,
  indent: 0,
  short-indent: 0,
  ragged-right: auto,
  ragged-last: false,
  system-gap: 1.2em,
  bar-numbers: false,
  first-bar-number: 1,
) = {
  let _ = _validate-clef(clef, "score clef")
  let _ = _validate-key(key, "score key")
  let _ = _parse-time-rational(time, label: "score time")
  let _ = _normalize-tempo(tempo, "score tempo")
  let _ = _validate-marking(composer, "score composer")
  _positive-number(scale, "scale")
  _positive-number(note-spacing, "note-spacing")
  _positive-number(width, "width", optional: true)
  _positive-number(staff-gap, "staff-gap", optional: true)
  _nonnegative-number(indent, "indent")
  _nonnegative-number(short-indent, "short-indent")
  _validate-system-gap(system-gap)
  if type(beams) != bool {
    _score-error(
      "score beams",
      "value must be a boolean",
      value: beams,
      expected: "true or false",
      fix: "choose whether automatic beam groups are drawn",
    )
  }
  if type(wrap) != bool {
    _score-error(
      "score wrap",
      "value must be a boolean",
      value: wrap,
      expected: "true or false",
      fix: "choose whether bars may wrap across systems",
    )
  }
  if ragged-right != auto and type(ragged-right) != bool {
    _score-error(
      "score ragged-right",
      "unsupported value",
      value: ragged-right,
      expected: "auto, true, or false",
      fix: "choose automatic, ragged, or justified system widths",
    )
  }
  if type(ragged-last) != bool {
    _score-error(
      "score ragged-last",
      "value must be a boolean",
      value: ragged-last,
      expected: "true or false",
      fix: "choose whether the final system stays at natural width",
    )
  }
  if bar-numbers != false and bar-numbers not in ("systems", "all") {
    _score-error(
      "score bar-numbers",
      "unsupported numbering mode",
      value: bar-numbers,
      expected: "false, systems, or all",
      fix: "disable numbering or choose a documented mode",
    )
  }
  if type(first-bar-number) != int or first-bar-number < 1 {
    _score-error(
      "score first-bar-number",
      "value must be a positive integer",
      value: first-bar-number,
      expected: "an integer greater than zero",
      fix: "set the number assigned to the first bar",
    )
  }
  if not wrap and short-indent != 0 {
    _score-error(
      "score short-indent",
      "short-indent has no later system when wrap is false",
      value: short-indent,
      expected: "zero for an unwrapped score",
      fix: "remove short-indent or enable wrap",
    )
  }
  if not wrap and ragged-last {
    _score-error(
      "score ragged-last",
      "ragged-last has no distinct effect on a one-system unwrapped score",
      value: ragged-last,
      expected: "false when wrap is false",
      fix: "remove ragged-last or enable wrap",
    )
  }
  if (
    not wrap and width != none
      and (ragged-right != false or ragged-last)
  ) {
    _score-error(
      "score width",
      "width is ignored by an unwrapped ragged score",
      value: width,
      expected: "ragged-right: false when combining width with wrap: false",
      fix: "set ragged-right to false or remove width",
    )
  }
  if not wrap and bar-numbers == "systems" {
    _score-error(
      "score bar-numbers",
      "systems mode cannot produce a later system when wrap is false",
      value: bar-numbers,
      expected: "false or all for an unwrapped score",
      fix: "use bar-numbers: \"all\" or enable wrap",
    )
  }
  let unit = 8pt * scale
  let measures = _prepare-score-measures(
    staves, bars, clef, key, time, tempo,
    note-spacing: note-spacing,
    beams: beams,
  )
  let lane-count = measures.first().voices.len()
  let staff-count = measures.first().staff-count
  if staff-count == 1 and staff-gap != none {
    _score-error(
      "score staff-gap",
      "staff-gap requires at least two staves",
      value: staff-gap,
      expected: "none for a single-staff score",
      fix: "remove staff-gap or declare multiple staves",
    )
  }
  let group-style = if group == auto {
    if staff-count == 1 { "none" }
    else if staff-count == 2 { "brace" }
    else { "bracket" }
  } else {
    if type(group) != str or group not in ("brace", "bracket", "line", "none") {
      _score-error(
        "score group",
        "unsupported grouping style",
        value: group,
        expected: "auto, brace, bracket, line, or none",
        fix: "choose a documented grouping style",
      )
    }
    if staff-count == 1 and group != "none" {
      _score-error(
        "score group",
        "a visible staff group requires at least two staves",
        value: group,
        expected: "auto or none for a single staff",
        fix: "remove group or declare the intended staves",
      )
    }
    group
  }
  let ending-spans = _collect-ending-spans(measures)
  for voice-index in range(lane-count) {
    let staff-layouts = measures.map(measure => measure.voices.at(voice-index).layouts)
    _validate-staff-slurs(
      staff-layouts,
      measures.first().voices.at(voice-index).id,
    )
    _validate-staff-ties(staff-layouts, measures.first().voices.at(voice-index).id)
    _validate-staff-direction-spans(staff-layouts, measures.first().voices.at(voice-index).id)
  }
  let left-bar-x = _left-bar-x-for-group(group-style, measures, staff-gap)
  layout(size => context {
    let first-label-reserve = _staff-label-reserve(measures.first().voices, unit)
    let short-label-reserve = _staff-label-reserve(measures.first().voices, unit, short: true)
    let max-width = if width == none { size.width / unit } else { width }
    let packed-systems = if wrap {
      _pack-score-systems(
        measures,
        max-width,
        left-bar-x,
        indent,
        short-indent,
        first-label-reserve,
        short-label-reserve,
        ragged-right,
        ragged-last,
      )
    } else {
      let widths = ()
      let system-name-left = indent
      let system-left-bar-x = left-bar-x + system-name-left + first-label-reserve
      let system-width = system-left-bar-x
      for measure-index in range(measures.len()) {
        let measure-width = _measure-width-in-system(
          measures.at(measure-index),
          measure-index == 0,
          system-left-bar-x,
          system-left-bar-x + _system-clef-after-barline-gap,
        )
        widths.push(measure-width)
        system-width += measure-width
      }
      ((
        start: 0,
        widths: widths,
        natural-width: system-width,
        left-bar-x: system-left-bar-x,
        name-left: system-name-left,
        label-reserve: first-label-reserve,
      ),)
    }
    let systems = _finalize-systems(packed-systems, max-width, ragged-right, ragged-last)
    for system-index in range(systems.len()) {
      _render-score-system(
        measures,
        systems.at(system-index),
        unit,
        beams: beams,
        staff-gap: staff-gap,
        composer: if system-index == 0 { composer } else { none },
        ending-spans: ending-spans,
        group-style: group-style,
        bar-numbers: bar-numbers,
        first-bar-number: first-bar-number,
      )
      if system-index + 1 < systems.len() {
        v(system-gap)
      }
    }
  })
}

#let bar(
  notes,
  key: "C",
  time: none,
  clef: "treble",
) = {
  score(
    clef: clef,
    bars: ((notes: notes,),),
    key: key,
    time: time,
    wrap: false,
  )
}
