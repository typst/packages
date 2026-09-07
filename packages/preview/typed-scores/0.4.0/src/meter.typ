#import "diagnostics.typ": _score-error

// ---------------------------------------------------------------------------
// Rational duration and meter validation
// ---------------------------------------------------------------------------

#let _gcd(a, b) = {
  if b == 0 { a } else { _gcd(b, calc.rem(a, b)) }
}

#let _rational(n, d) = {
  let g = _gcd(n, d)
  (numerator: n / g, denominator: d / g)
}

#let _rational-add(a, b) = {
  _rational(
    a.numerator * b.denominator + b.numerator * a.denominator,
    a.denominator * b.denominator,
  )
}

#let _rational-eq(a, b) = {
  a.numerator * b.denominator == b.numerator * a.denominator
}

#let _rational-lte(a, b) = {
  a.numerator * b.denominator <= b.numerator * a.denominator
}

#let _format-rational(value) = {
  if value.denominator == 1 {
    str(value.numerator)
  } else {
    str(value.numerator) + "/" + str(value.denominator)
  }
}

#let _time-digits = ("0", "1", "2", "3", "4", "5", "6", "7", "8", "9")

#let _parse-time-rational(time, label: "time signature", optional: true) = {
  if time == none {
    if optional {
      none
    } else {
      _score-error(
        label,
        "a meter is required",
        value: time,
        expected: "a string such as \"4/4\" or \"12/8\"",
        fix: "set time to the active meter",
      )
    }
  } else {
    if type(time) != str {
      _score-error(
        label,
        "meter must be a string",
        value: time,
        expected: "a value such as \"4/4\" or \"12/8\"",
        fix: "quote the meter",
      )
    }
    let parts = time.split("/")
    if (
      parts.len() != 2
        or parts.any(part => (
          part == ""
            or part.len() > 9
            or part.codepoints().any(digit => digit not in _time-digits)
        ))
    ) {
      _score-error(
        label,
        "meter has invalid syntax",
        value: time,
        expected: "positive whole numbers separated by one slash, such as \"4/4\" or \"12/8\"",
        fix: "write the numerator and denominator with ASCII digits",
      )
    }
    let numerator = int(parts.at(0))
    let denominator = int(parts.at(1))
    if numerator <= 0 or denominator <= 0 {
      _score-error(
        label,
        "meter values must be positive",
        value: time,
        expected: "a numerator and denominator greater than zero",
        fix: "replace zero with the intended positive meter value",
      )
    }
    _rational(numerator, denominator)
  }
}

#let _duration-sum(layouts) = {
  let total = (numerator: 0, denominator: 1)
  for layout in layouts {
    total = _rational-add(total, layout.duration_value)
  }
  total
}

#let _validate-measure-duration(layouts, time, staff-name, measure-number) = {
  let expected = _parse-time-rational(
    time,
    label: staff-name + " bar " + str(measure-number) + " meter",
  )
  if expected != none {
    let actual = _duration-sum(layouts)
    if not _rational-eq(actual, expected) {
      _score-error(
        staff-name + " bar " + str(measure-number),
        "voice durations sum to " + _format-rational(actual),
        expected: time,
        fix: "add, remove, or change event durations so this voice fills the active bar or partial",
      )
    }
  }
}

// Harmony is an independent, duration-bearing sequence in a bar. Symbols are
// intentionally author-controlled text; only the trailing duration is parsed.
#let _harmony-duration-values = (
  "w": (numerator: 1, denominator: 1),
  "w.": (numerator: 3, denominator: 2),
  "w..": (numerator: 7, denominator: 4),
  "h": (numerator: 1, denominator: 2),
  "h.": (numerator: 3, denominator: 4),
  "h..": (numerator: 7, denominator: 8),
  "q": (numerator: 1, denominator: 4),
  "q.": (numerator: 3, denominator: 8),
  "q..": (numerator: 7, denominator: 16),
  "e": (numerator: 1, denominator: 8),
  "e.": (numerator: 3, denominator: 16),
  "e..": (numerator: 7, denominator: 32),
  "s": (numerator: 1, denominator: 16),
  "s.": (numerator: 3, denominator: 32),
  "s..": (numerator: 7, denominator: 64),
  "t": (numerator: 1, denominator: 32),
  "t.": (numerator: 3, denominator: 64),
  "t..": (numerator: 7, denominator: 128),
)

#let _layout-harmony(sequence, time, bar-number) = {
  if sequence == none { return () }
  if type(sequence) != str or sequence.trim() == "" {
    _score-error(
      "harmony in bar " + str(bar-number),
      "harmony must be a non-empty string",
      value: sequence,
      expected: "space-separated symbol:duration tokens such as \"Cmaj7:h G7:h\"",
      fix: "provide timed harmony text or remove the harmony field",
    )
  }
  if time == none {
    _score-error(
      "harmony in bar " + str(bar-number),
      "timed harmony requires an active meter",
      value: sequence,
      expected: "a bar time or partial value",
      fix: "set time for the score or partial for this bar",
    )
  }
  let layouts = ()
  let onset = _rational(0, 1)
  for token in sequence.trim().split(" ") {
    if token == "" { continue }
    let parts = token.split(":")
    if parts.len() != 2 or parts.first().trim() == "" or parts.last() not in _harmony-duration-values {
      _score-error(
        "harmony token in bar " + str(bar-number),
        "harmony token has invalid syntax",
        value: token,
        expected: "one symbol, one colon, and a duration such as Cmaj7:h",
        fix: "add the missing symbol, colon, or supported duration code",
      )
    }
    let duration = _harmony-duration-values.at(parts.last())
    layouts.push((symbol: parts.first(), onset: onset, duration-value: duration))
    onset = _rational-add(onset, duration)
  }
  let expected = _parse-time-rational(time, label: "harmony bar " + str(bar-number) + " meter")
  if not _rational-eq(onset, expected) {
    _score-error(
      "harmony bar " + str(bar-number),
      "durations sum to " + _format-rational(onset),
      expected: time,
      fix: "change the harmony durations so they fill the active bar or partial",
    )
  }
  layouts
}

// ---------------------------------------------------------------------------
