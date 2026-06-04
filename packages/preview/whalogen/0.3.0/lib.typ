#import "@preview/xarrow:0.3.1": xarrow

#let _quote(t) = {
  return "\"" + t + "\""
}

// reads a list of str or content, ignores content
// replaces the specified string with the content specified
#let _replace_with_content(l, replace: " ", content: []) = {  // array(str|content) -> array(str|content)
  let result = ()
  for item in l {
    if type(item) != str {
      result.push(item)
      continue
    }
    for item_split in item.split(replace) {
      result.push(item_split)
      result.push(content)
    }
    // pop and ignore popped item
    let _ = result.pop()
  }
  return result
}

#let sym_map = (
  "<-->": sym.arrows.lr,
  "<->": sym.arrow.l.r,
  "->": sym.arrow.r,
  "<-": sym.arrow.l,
  "<=>": sym.harpoons.rtlb
)

// rewrites isotope statement as isotope, otherwise returns same thing
#let _parse_isotope(t) = {  // str -> str
  let res = t.match(regex("@([^,]*),([^,]*),([^,]*)@"))
  if res != none {
    return "attach(" + _quote(res.captures.at(0)) + ", tl: " + _quote(res.captures.at(1)) + ", bl: " + _quote(res.captures.at(2)) +")"
  }
  return _quote(t)
}

// describes what to write to the output when a certain state ends
// return result should be written to output. buffer should be cleared after running this function
#let _flush_ce_buffer(_state, _buffer) = {  // (str, str) -> (str)
  return (
    "letter": _quote(_buffer),
    "num_script": "_" + _quote(_buffer),
    "": _buffer,
    "num": _buffer,
    "charge": "^" + _quote(_buffer.replace("-", sym.dash.en)),
    "caret": "^" + _quote(_buffer.replace("^", "", count: 1).replace("-", sym.dash.en).replace(".", sym.bullet)),
    "underscore": "_" + _quote(_buffer.replace("_", "", count: 1)),
    "code": _buffer,
    "math": _buffer,
    "punctuation": _buffer,
    "leading_punctuation": _buffer,
    "isotope?": _parse_isotope(_buffer),
  ).at(_state)
}

// lower level parser operates based off of current state
// adjusts the output according to current context
// primarily inserting math symbols as necessary
// Return: next_state(str), output(str), buffer(str)
#let _parse_ce(_state, _char_in, _buffer) = {  // (str, str, str) -> (str, str, str)
  let _out = ""

  // end previous states on whitespace
  if _char_in.contains(regex("\s")) {
    _out = _flush_ce_buffer(_state, _buffer)
    _buffer = ""
    _state = ""
  }
  if _char_in == "#" {
    _out = _flush_ce_buffer(_state, _buffer)
    _buffer = ""
    _state = "code"
  }

  // on letter flush buffer (unless already is letter)
  if _char_in.contains(regex("[A-Za-z]")) {
    (_state, _out, _buffer) = (
      "letter": ("letter", _out, _buffer),
      "isotope?": ("isotope?", _out, _buffer),
      "code": ("code", _out, _buffer),
      "caret": ("caret", _out, _buffer),
    ).at(_state, default: ("letter", _flush_ce_buffer(_state, _buffer), ""))
  }

  // on digit
  if _char_in.contains(regex("\d")) {
    (_state, _out, _buffer) = (
      "letter": ("num_script", _flush_ce_buffer(_state, _buffer), ""),
      "punctuation": ("num_script", _flush_ce_buffer(_state, _buffer), ""),
      "num_script": ("num_script", _out, _buffer)
    ).at(_state, default: (_state, _out, _buffer))
  }

  // on plus/minus
  if _char_in.contains(regex("[+-]")) {
    (_state, _out, _buffer) = (
      "letter": ("charge", _flush_ce_buffer(_state, _buffer), ""),
      "punctuation": ("charge", _flush_ce_buffer(_state, _buffer), "")
    ).at(_state, default: (_state, _out, _buffer))
  }

  // on caret
  if _char_in.contains("^") {
    (_state, _out, _buffer) = (
      "letter": ("caret", _flush_ce_buffer(_state, _buffer), ""),
      "punctuation": ("caret", _flush_ce_buffer(_state, _buffer), ""),
      "num_script": ("caret", _flush_ce_buffer(_state, _buffer), ""),
      "underscore": ("caret", _flush_ce_buffer(_state, _buffer), "")
    ).at(_state, default: (_state, _out, _buffer))
  }

  // on underscore
  if _char_in.contains("_") {
    (_state, _out, _buffer) = (
      "letter": ("underscore", _flush_ce_buffer(_state, _buffer), ""),
      "punctuation": ("underscore", _flush_ce_buffer(_state, _buffer), ""),
      "num_script": ("underscore", _flush_ce_buffer(_state, _buffer), ""),
      "caret": ("underscore", _flush_ce_buffer(_state, _buffer), "")
    ).at(_state, default: (_state, _out, _buffer))
  }

  // on closing brackets...
  if _char_in.contains(regex("[)}\]]")) {
    (_state, _out, _buffer) = (
      "_": ("", "", "")
    ).at(_state, default: ("punctuation", _flush_ce_buffer(_state, _buffer), ""))
  }

  // on opening brackets...
  if _char_in.contains(regex("[\[({]")) {
    (_state, _out, _buffer) = (
      "_": ("", "", "")
    ).at(_state, default: ("leading_punctuation", _flush_ce_buffer(_state, _buffer), ""))
  }

  // on math...
  if _char_in.contains(regex("\$")) {
    (_state, _out, _buffer) = (
      "_": ("", "", "")
    ).at(_state, default: ("math", _flush_ce_buffer(_state, _buffer), ""))
  }

  // isotope parsing
  if _char_in.contains(regex("@")) {
    (_state, _out, _buffer) = (
      "isotope?": ("", _flush_ce_buffer(_state, _buffer + _char_in), "")
    ).at(_state, default: ("isotope?", _out, _buffer))
    if _state != "isotope?" {
      return (_state, _out, _buffer)
    }
  }

  _buffer = _buffer + _char_in
  return (_state, _out, _buffer)
}

#let _replace_math(s) = {
    for match in s.matches(regex("(\$.*?\$)")) {
        s = s.replace(match.text, ")" + match.text.slice(1,-1) + " upright(")
    }
        
  let out = "upright(" + s + ")"
  out.replace("upright( )","").replace("upright()","")
}

// higher level parser which parses strings in a larger context
// replaces specific components with content that can be directly output
#let _fill_computed_ce_content(s) = {  // (str) -> array(str | content)
  let result = (s,)
  for symbol in sym_map.values() {
    // text over arrow with xarrow
    let decorated_arrow_result = result
    for r in result {
      if type(r) != str {
        continue
      }
      // match arrow with top and bottom text
      let decorated_arrow_matches = r.matches(regex(symbol + "\[([^\]]+)\]\[([^\]]+)\]"))
      for decorated_arrow_match in decorated_arrow_matches {
        decorated_arrow_result = _replace_with_content(decorated_arrow_result, replace: decorated_arrow_match.text, content: [
          #xarrow(sym: symbol, margin: 0.5em, [
            #eval("$" + _replace_math(decorated_arrow_match.captures.at(0)) + "$")
          ], opposite: [
            #eval("$" + _replace_math(decorated_arrow_match.captures.at(1)) + "$")
          ]
          )
        ])
      }

      // match arrow with top only text
      let decorated_arrow_matches = r.matches(regex(symbol + "\[([^\]]+)\]"))
      for decorated_arrow_match in decorated_arrow_matches {
        decorated_arrow_result = _replace_with_content(decorated_arrow_result, replace: decorated_arrow_match.text, content: [
          #xarrow(sym: symbol, margin: 0.5em, [
            #eval("$" + _replace_math(decorated_arrow_match.captures.at(0)) + "$")
          ])
        ])
      }
    }
    result = decorated_arrow_result

    // lengthen arrow with xarrow
    result = _replace_with_content(result, replace: symbol, content: [
      #xarrow(sym: symbol, margin: 0.8em, [])
    ])
  }
  return result
}

// primary entrypoint for end user
// first runs through low level state machine parser, then applies higher level replacement
#let ce(t, debug: false) = { // (str, bool) -> content
  assert(type(t) == str, message: "ce: argument must be of type `string`")
  let state = ""

  for (pattern, result) in sym_map {
    t = t.replace(regex(pattern), " " + result)
  }

  t = t + " " // append a space to ensure the state machine is reset and output buffer cleared
  let buffer = ""
  let out = ""
  let result = ""
  // iterate through the string
  for c in t.codepoints() {
    (state, out, buffer) = _parse_ce(state, c, buffer)
    result += out
  }

  if debug {
    return raw(result)
  }

  // convert string to content
  for result_sub_str in _fill_computed_ce_content(result) {
    if type(result_sub_str) == str {
      result_sub_str = "$" + _replace_math(result_sub_str) + "$"
      $#eval(result_sub_str)$
    } else if type(result_sub_str) == content {
      result_sub_str
    }
  }
}