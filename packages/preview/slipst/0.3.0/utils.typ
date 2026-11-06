#let sequence = [].func()
#let styled = text(red)[].func()
#let space = [ ].func()
#let symbol-func = $.$.body.func()
#let context-func = (context {}).func()

#assert($mu$.body.func() == symbol-func)
#assert(type(sym.mu) == symbol)

#let _is(it, func) = {
  type(it) == content and it.func() == func
}

#let _should_strip(it) = {
  _is(it, parbreak) or _is(it, space) or (_is(it, sequence) and it.children.len() == 0)
}

#let _strip(slip) = {
  let _ = while _should_strip(slip.first(default: none)) {
    slip.remove(0)
  }
  let _ = while _should_strip(slip.last(default: none)) {
    slip.pop()
  }
  slip
}

#let fmap(it, func) = {
  assert(type(it) == content)
  if it.func() == sequence {
    let children = _strip(it.children)
    if (children.len() == 1) {
      fmap(children.at(0), func)
    } else {
      func(it)
    }
  } else if it.func() == styled {
    styled(fmap(it.child, func), it.styles)
  } else {
    it
  }
}

// not actual maximum integer, but large enough
#let _int_max = 1.bit-lshift(53) - 1

// Parse range in string into [start, end) format.
//
// range syntax:
// - "2": only 2
// - "2-": from 2 to infinity
// - "2-5": from 2 to 5 (inclusive)
#let _parse_range(range_str) = {
  let parts = range_str.split("-")
  let start = int(parts.at(0))
  let end = if parts.len() == 1 {
    start + 1
  } else if parts.at(1) == "" {
    _int_max
  } else {
    int(parts.at(1)) + 1
  }
  return (start, end)
}

#assert(_parse_range("2") == (2, 3))
#assert(_parse_range("2-") == (2, _int_max))
#assert(_parse_range("2-5") == (2, 6))

// Parse multiple ranges
#let _parse_ranges(ranges) = {
  if type(ranges) == str {
    return (_parse_range(ranges),)
  }
  return ranges.map(_parse_range)
}

#assert(_parse_ranges("2") == ((2, 3),))
#assert(_parse_ranges("2-") == ((2, _int_max),))
#assert(_parse_ranges("2-5") == ((2, 6),))
#assert(_parse_ranges(("2", "4-5")) == ((2, 3), (4, 6)))

// Check if num is in any of the ranges
#let _is_in_ranges(num, ranges) = {
  for range in ranges {
    if num >= range.at(0) and num < range.at(1) {
      return true
    }
  }
  return false
}

#assert(_is_in_ranges(2, _parse_ranges("2")))
#assert(not _is_in_ranges(3, _parse_ranges("2")))
#assert(_is_in_ranges(2, _parse_ranges("2-5")))
#assert(_is_in_ranges(4, _parse_ranges("2-5")))
#assert(not _is_in_ranges(6, _parse_ranges(("2-5", "7-9"))))
