#import "diagnostics.typ": _score-error

// WASM parser communication and response-contract validation.

#let _score-plugin = plugin("../plugin.wasm")

#let _validate-plugin-response(response, location, sequence-str) = {
  if type(response) != dictionary {
    _score-error(
      location,
      "the parser returned malformed data",
      value: response,
      expected: "a typed-scores plugin response dictionary",
      fix: "rebuild or reinstall typed-scores so plugin.wasm matches the Typst sources",
    )
  }
  let ok = response.at("ok", default: none)
  if type(ok) != bool {
    _score-error(
      location,
      "the parser response is missing its boolean ok field",
      value: response,
      fix: "rebuild or reinstall typed-scores so plugin.wasm matches the Typst sources",
    )
  }
  if not ok {
    let parser-message = response.at("error", default: none)
    if type(parser-message) != str or parser-message.trim() == "" {
      _score-error(
        location,
        "the parser failed without an actionable message",
        value: response,
        fix: "rebuild or reinstall typed-scores so plugin.wasm matches the Typst sources",
      )
    }
    _score-error(
      location,
      parser-message,
      value: sequence-str,
      fix: "correct the quoted notes token or delimiter using the syntax named above",
    )
  }
  let data = response.at("data", default: none)
  if (
    type(data) != dictionary
      or type(data.at("layouts", default: none)) != array
  ) {
    _score-error(
      location,
      "the parser returned an invalid layout payload",
      value: data,
      expected: "a dictionary containing a layouts array",
      fix: "rebuild or reinstall typed-scores so plugin.wasm matches the Typst sources",
    )
  }
  let anchor = data.at("anchor", default: none)
  let duration-anchor = data.at("duration_anchor", default: none)
  if (
    (anchor != none and type(anchor) != str)
      or (duration-anchor != none and type(duration-anchor) != str)
      or data.layouts.any(layout => type(layout) != dictionary)
  ) {
    _score-error(
      location,
      "the parser returned malformed layout state",
      value: data,
      expected: "dictionary layouts plus optional string anchors",
      fix: "rebuild or reinstall typed-scores so plugin.wasm matches the Typst sources",
    )
  }
  data
}

// ---------------------------------------------------------------------------
// Plugin calls
// ---------------------------------------------------------------------------

// The staves a voice may draw on, top to bottom, after its home staff ID.
// Records are separated by U+001E, and a staff ID, its clef, and its encoded
// drum map by U+001F.
#let _staff-context-request(home-staff-id, staff-clefs, staff-heads) = {
  let records = staff-clefs.zip(staff-heads).map((((staff-id, clef), heads)) => (
    (staff-id, clef, heads).join("\u{1f}")
  ))
  (home-staff-id, ..records).join("\u{1e}")
}

#let _layout-sequence(
  sequence-str,
  home-staff-id: "staff",
  staff-clefs: (("staff", "treble"),),
  staff-heads: ("",),
  time: none,
  anchor: none,
  duration-anchor: none,
  transposition: none,
  location: "notes",
) = {
  let staff-context = _staff-context-request(home-staff-id, staff-clefs, staff-heads)
  // repr keeps an ASCII minus sign, which str replaces with U+2212.
  let transposition-str = if transposition == none { "" } else {
    repr(transposition.steps) + " " + repr(transposition.semitones)
  }
  let anchor-str = if anchor == none { "" } else { anchor }
  let duration-anchor-str = if duration-anchor == none { "" } else { duration-anchor }
  let response = if time == none {
    json(_score-plugin.layout_sequence_relative(bytes(
      (
        staff-context, "\n", transposition-str, "\n", anchor-str, "\n",
        duration-anchor-str, "\n", sequence-str,
      ).join(),
    )))
  } else {
    json(_score-plugin.layout_sequence_timed_relative(bytes(
      (
        staff-context, "\n", transposition-str, "\n", time, "\n", anchor-str, "\n",
        duration-anchor-str, "\n", sequence-str,
      ).join(),
    )))
  }
  _validate-plugin-response(response, location, sequence-str)
}
