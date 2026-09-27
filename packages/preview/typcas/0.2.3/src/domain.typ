// =========================================================================
// CAS Domain Sets
// =========================================================================
// Interval-domain parser and helpers used by assumptions/restrictions.
//
// Domain set shape:
//   (intervals: (
//     (lo: number|none, lo-closed: bool, hi: number|none, hi-closed: bool),
//     ...
//   ))
//
// `lo: none` means -infinity, `hi: none` means +infinity.
// =========================================================================

/// Internal helper `_is-space`.
#let _is-space(c) = c == " " or c == "\t" or c == "\n" or c == "\r"

/// Internal helper `_is-digit`.
#let _is-digit(c) = c >= "0" and c <= "9"

/// Internal helper `_strip-spaces`.
#let _strip-spaces(s) = {
  let chars = s.clusters()
  let out = ()
  for c in chars {
    if not _is-space(c) { out.push(c) }
  }
  out.join()
}

/// Internal helper `_expand-cut-shorthand`.
/// Supports compact cut-point notation:
/// - `a)(a` => `(-inf,a)U(a,inf)`
/// - `2)(2,3)(3` => `(-inf,2)U(2,3)U(3,inf)`
#let _expand-cut-shorthand(s) = {
  if s == "" { return s }
  if "U" in s or "∪" in s { return s }

  let first = s.clusters().at(0)
  if first == "(" or first == "[" {
    return s
  }
  if not (")(" in s) {
    return s
  }

  let parts = s.split(")(")
  if parts.len() < 2 { return s }

  let left = parts.at(0)
  let right = parts.at(parts.len() - 1)
  if left == "" or right == "" { return s }
  if "," in left or "," in right { return s }

  let out = ()
  out.push("(-inf," + left + ")")

  if parts.len() > 2 {
    for i in range(1, parts.len() - 1) {
      let mid = parts.at(i)
      if mid == "" or not ("," in mid) { return s }
      out.push("(" + mid + ")")
    }
  }

  out.push("(" + right + ",inf)")
  out.join("U")
}

/// Internal helper `_parse-decimal`.
#let _parse-decimal(raw) = {
  let s = _strip-spaces(raw)
  if s == "" { panic("parse-domain: empty numeric endpoint") }

  let chars = s.clusters()
  let i = 0
  let has-dot = false
  let has-digit = false

  if chars.at(0) == "+" or chars.at(0) == "-" {
    i += 1
  }
  if i >= chars.len() { panic("parse-domain: malformed numeric endpoint '" + s + "'") }

  while i < chars.len() {
    let c = chars.at(i)
    if _is-digit(c) {
      has-digit = true
      i += 1
      continue
    }
    if c == "." and not has-dot {
      has-dot = true
      i += 1
      continue
    }
    panic("parse-domain: malformed numeric endpoint '" + s + "'")
  }

  if not has-digit { panic("parse-domain: malformed numeric endpoint '" + s + "'") }
  if "." in s { return float(s) }
  int(s)
}

/// Internal helper `_parse-number-token`.
#let _parse-number-token(raw) = {
  let s = _strip-spaces(raw)
  if s == "" { panic("parse-domain: empty numeric token") }

  if "/" in s {
    let parts = s.split("/")
    if parts.len() != 2 {
      panic("parse-domain: malformed rational token '" + s + "'")
    }
    let n = _parse-decimal(parts.at(0))
    let d = _parse-decimal(parts.at(1))
    if d == 0 { panic("parse-domain: rational denominator cannot be zero in '" + s + "'") }
    return n / d
  }

  _parse-decimal(s)
}

/// Internal helper `_parse-endpoint`.
/// Returns number or `none` for infinity.
#let _parse-endpoint(token, side) = {
  let t = _strip-spaces(token)
  if t == "" { panic("parse-domain: empty interval endpoint") }

  if t == "-inf" or t == "-infinity" or t == "-∞" {
    if side == "hi" {
      panic("parse-domain: right endpoint cannot be -inf")
    }
    return none
  }
  if t == "inf" or t == "+inf" or t == "infinity" or t == "+infinity" or t == "∞" or t == "+∞" {
    if side == "lo" {
      panic("parse-domain: left endpoint cannot be +inf")
    }
    return none
  }

  _parse-number-token(t)
}

/// Internal helper `_validate-interval`.
/// Returns normalized interval or `none` if empty-open singleton.
#let _validate-interval(iv) = {
  let lo = iv.lo
  let hi = iv.hi
  let lo-closed = if lo == none { false } else { iv.lo-closed }
  let hi-closed = if hi == none { false } else { iv.hi-closed }

  if lo == none and iv.lo-closed {
    panic("parse-domain: -inf boundary cannot be closed")
  }
  if hi == none and iv.hi-closed {
    panic("parse-domain: +inf boundary cannot be closed")
  }

  if lo != none and hi != none {
    if lo > hi { panic("parse-domain: interval lower endpoint exceeds upper endpoint") }
    if lo == hi and not (lo-closed and hi-closed) {
      // (a,a), (a,a], [a,a) are empty.
      return none
    }
  }

  (
    lo: lo,
    lo-closed: lo-closed,
    hi: hi,
    hi-closed: hi-closed,
  )
}

/// Internal helper `_interval-less`.
#let _interval-less(a, b) = {
  if a.lo == none and b.lo != none { return true }
  if a.lo != none and b.lo == none { return false }

  if a.lo != none and b.lo != none {
    if a.lo < b.lo { return true }
    if a.lo > b.lo { return false }
  }

  if a.lo-closed and not b.lo-closed { return true }
  if not a.lo-closed and b.lo-closed { return false }

  if a.hi == none and b.hi != none { return false }
  if a.hi != none and b.hi == none { return true }
  if a.hi != none and b.hi != none {
    if a.hi < b.hi { return true }
    if a.hi > b.hi { return false }
  }

  if a.hi-closed and not b.hi-closed { return true }
  false
}

/// Internal helper `_insert-sorted`.
#let _insert-sorted(sorted, iv) = {
  let out = ()
  let inserted = false
  for cur in sorted {
    if not inserted and _interval-less(iv, cur) {
      out.push(iv)
      inserted = true
    }
    out.push(cur)
  }
  if not inserted { out.push(iv) }
  out
}

/// Internal helper `_overlap-or-touch`.
#let _overlap-or-touch(a, b) = {
  if a.hi == none { return true }
  if b.lo == none { return true }
  if a.hi > b.lo { return true }
  if a.hi < b.lo { return false }
  // Touching at the same endpoint merges when at least one side includes it.
  a.hi-closed or b.lo-closed
}

/// Internal helper `_merge-two`.
#let _merge-two(a, b) = {
  let hi = a.hi
  let hi-closed = a.hi-closed

  if hi == none {
    return a
  }

  if b.hi == none {
    return (
      lo: a.lo,
      lo-closed: a.lo-closed,
      hi: none,
      hi-closed: false,
    )
  }

  if b.hi > hi {
    return (
      lo: a.lo,
      lo-closed: a.lo-closed,
      hi: b.hi,
      hi-closed: b.hi-closed,
    )
  }
  if b.hi < hi { return a }

  (
    lo: a.lo,
    lo-closed: a.lo-closed,
    hi: hi,
    hi-closed: hi-closed or b.hi-closed,
  )
}

/// Public helper `domain-normalize`.
#let domain-normalize(domain) = {
  if domain == none { return (intervals: ()) }
  let raw = domain.at("intervals", default: ())

  let cleaned = ()
  for iv in raw {
    let c = _validate-interval(iv)
    if c != none { cleaned.push(c) }
  }
  if cleaned.len() == 0 { return (intervals: ()) }

  let sorted = ()
  for iv in cleaned {
    sorted = _insert-sorted(sorted, iv)
  }

  let merged = (sorted.at(0),)
  for i in range(1, sorted.len()) {
    let next = sorted.at(i)
    let last = merged.at(merged.len() - 1)
    if _overlap-or-touch(last, next) {
      merged.at(merged.len() - 1) = _merge-two(last, next)
    } else {
      merged.push(next)
    }
  }

  (intervals: merged)
}

/// Internal helper `_parse-domain-base`.
/// Base syntax supports segment chaining:
/// - `2)(2`
/// - `2)[3,4](5`
/// - `3)`
/// - `(4`
/// - standard intervals like `(0,inf)` or `[-2,-1)`
#let _parse-domain-base(s) = {
  let chars = s.clusters()
  let i = 0
  let intervals = ()

  while i < chars.len() {
    let c = chars.at(i)

    // Skip explicit union separators if present.
    if c == "U" or c == "∪" {
      i += 1
      continue
    }

    // Segment starts with bracket: interval [a,b], (a,b), ... or right ray (a / [a
    if c == "(" or c == "[" {
      let lo-closed = c == "["
      i += 1

      let lo-start = i
      while i < chars.len() and chars.at(i) != "," and chars.at(i) != ")" and chars.at(i) != "]" and chars.at(i) != "U" and chars.at(i) != "∪" {
        i += 1
      }
      let lo-token = chars.slice(lo-start, i).join()
      if lo-token == "" {
        panic("parse-domain: empty lower endpoint in segment starting at position " + str(lo-start - 1))
      }

      // Right-ray shorthand: (a  or [a
      if i >= chars.len() or chars.at(i) == "U" or chars.at(i) == "∪" {
        let lo = _parse-endpoint(lo-token, "lo")
        intervals.push((lo: lo, lo-closed: lo-closed, hi: none, hi-closed: false))
        continue
      }

      // Bounded interval: (a,b), [a,b], ...
      if chars.at(i) == "," {
        i += 1
        let hi-start = i
        while i < chars.len() and chars.at(i) != ")" and chars.at(i) != "]" {
          i += 1
        }
        if i >= chars.len() {
          panic("parse-domain: expected closing ')' or ']' in interval segment")
        }
        let rb = chars.at(i)
        let hi-token = chars.slice(hi-start, i).join()
        i += 1

        let lo = _parse-endpoint(lo-token, "lo")
        let hi = _parse-endpoint(hi-token, "hi")
        intervals.push((lo: lo, lo-closed: lo-closed, hi: hi, hi-closed: rb == "]"))
        continue
      }

      // Segment like "(a)" is not valid in this syntax.
      panic("parse-domain: malformed segment, expected ',' or segment end after lower endpoint")
    }

    // Segment starts with value: left ray shorthand a) or a]
    let hi-start = i
    while i < chars.len() and chars.at(i) != ")" and chars.at(i) != "]" {
      if chars.at(i) == "(" or chars.at(i) == "[" or chars.at(i) == "U" or chars.at(i) == "∪" {
        panic("parse-domain: malformed left-ray segment near position " + str(i))
      }
      i += 1
    }
    if i >= chars.len() {
      panic("parse-domain: expected ')' or ']' to close left-ray segment")
    }
    let rb = chars.at(i)
    let hi-token = chars.slice(hi-start, i).join()
    i += 1

    let hi = _parse-endpoint(hi-token, "hi")
    intervals.push((lo: none, lo-closed: false, hi: hi, hi-closed: rb == "]"))
  }

  domain-normalize((intervals: intervals))
}

/// Public helper `parse-domain`.
/// Accepts interval-union strings such as:
/// - "(-inf,-3) U (-3,inf)"
/// - "[-2,-1)"
/// - "(0,inf)"
#let parse-domain(domain-str) = {
  if type(domain-str) != str {
    panic("parse-domain: input must be a string")
  }

  let s = _expand-cut-shorthand(_strip-spaces(domain-str))
  if s == "" { panic("parse-domain: empty domain string") }
  _parse-domain-base(s)
}

/// Public helper `domain-intersect`.
#let domain-intersect(a, b) = {
  let da = domain-normalize(a)
  let db = domain-normalize(b)
  let ia = da.intervals
  let ib = db.intervals
  let out = ()

  let i = 0
  let j = 0
  while i < ia.len() and j < ib.len() {
    let aiv = ia.at(i)
    let biv = ib.at(j)

    // max(lower bounds)
    let lo = if aiv.lo == none {
      biv.lo
    } else if biv.lo == none {
      aiv.lo
    } else if aiv.lo > biv.lo {
      aiv.lo
    } else {
      biv.lo
    }
    let lo-closed = if aiv.lo == none {
      biv.lo-closed
    } else if biv.lo == none {
      aiv.lo-closed
    } else if aiv.lo > biv.lo {
      aiv.lo-closed
    } else if aiv.lo < biv.lo {
      biv.lo-closed
    } else {
      aiv.lo-closed and biv.lo-closed
    }

    // min(upper bounds)
    let hi = if aiv.hi == none {
      biv.hi
    } else if biv.hi == none {
      aiv.hi
    } else if aiv.hi < biv.hi {
      aiv.hi
    } else {
      biv.hi
    }
    let hi-closed = if aiv.hi == none {
      biv.hi-closed
    } else if biv.hi == none {
      aiv.hi-closed
    } else if aiv.hi < biv.hi {
      aiv.hi-closed
    } else if aiv.hi > biv.hi {
      biv.hi-closed
    } else {
      aiv.hi-closed and biv.hi-closed
    }

    if lo != none and hi != none and lo > hi {
      // No overlap for this pair.
    } else {
      let iv = _validate-interval((lo: lo, lo-closed: lo-closed, hi: hi, hi-closed: hi-closed))
      if iv != none { out.push(iv) }
    }

    if aiv.hi == none and biv.hi == none {
      i += 1
      j += 1
    } else if aiv.hi == none {
      j += 1
    } else if biv.hi == none {
      i += 1
    } else if aiv.hi < biv.hi {
      i += 1
    } else if aiv.hi > biv.hi {
      j += 1
    } else {
      i += 1
      j += 1
    }
  }

  domain-normalize((intervals: out))
}

/// Public helper `domain-contains`.
#let domain-contains(domain, value) = {
  let d = domain-normalize(domain)
  for iv in d.intervals {
    let lower-ok = if iv.lo == none {
      true
    } else {
      value > iv.lo or (value == iv.lo and iv.lo-closed)
    }
    let upper-ok = if iv.hi == none {
      true
    } else {
      value < iv.hi or (value == iv.hi and iv.hi-closed)
    }
    if lower-ok and upper-ok { return true }
  }
  false
}

/// Internal helper `_interval-is-singleton`.
#let _interval-is-singleton(iv, x) = {
  iv.lo != none and iv.hi != none and iv.lo == x and iv.hi == x and iv.lo-closed and iv.hi-closed
}

/// Internal helper `_interval-any-true`.
#let _interval-any-true(iv, rel, c) = {
  if rel == "!=" {
    if not domain-contains((intervals: (iv,)), c) { return true }
    return not _interval-is-singleton(iv, c)
  }
  if rel == ">" {
    if iv.hi == none { return true }
    iv.hi > c
  } else if rel == ">=" {
    if iv.hi == none { return true }
    iv.hi > c or (iv.hi == c and iv.hi-closed)
  } else if rel == "<" {
    if iv.lo == none { return true }
    iv.lo < c
  } else if rel == "<=" {
    if iv.lo == none { return true }
    iv.lo < c or (iv.lo == c and iv.lo-closed)
  } else {
    false
  }
}

/// Internal helper `_interval-any-false`.
#let _interval-any-false(iv, rel, c) = {
  if rel == "!=" {
    return domain-contains((intervals: (iv,)), c)
  }
  if rel == ">" {
    if iv.lo == none { return true }
    iv.lo < c or (iv.lo == c and iv.lo-closed)
  } else if rel == ">=" {
    if iv.lo == none { return true }
    iv.lo < c
  } else if rel == "<" {
    if iv.hi == none { return true }
    iv.hi > c or (iv.hi == c and iv.hi-closed)
  } else if rel == "<=" {
    if iv.hi == none { return true }
    iv.hi > c
  } else {
    false
  }
}

/// Public helper `domain-status-rel`.
/// Returns one of: "satisfied" | "conflict" | "unknown".
#let domain-status-rel(domain, rel, c) = {
  if domain == none { return "unknown" }
  let d = domain-normalize(domain)
  if d.intervals.len() == 0 { return "unknown" }

  let any-true = false
  let any-false = false
  for iv in d.intervals {
    if _interval-any-true(iv, rel, c) { any-true = true }
    if _interval-any-false(iv, rel, c) { any-false = true }
    if any-true and any-false { return "unknown" }
  }

  if any-true and not any-false { return "satisfied" }
  if any-false and not any-true { return "conflict" }
  "unknown"
}

/// Internal helper `_endpoint-str`.
#let _endpoint-str(v, side) = {
  if v == none { return if side == "lo" { "-inf" } else { "inf" } }
  str(v)
}

/// Internal helper `_interval-str`.
#let _interval-str(iv) = {
  let lb = if iv.lo-closed { "[" } else { "(" }
  let rb = if iv.hi-closed { "]" } else { ")" }
  lb + _endpoint-str(iv.lo, "lo") + "," + _endpoint-str(iv.hi, "hi") + rb
}

/// Public helper `domain-to-string`.
/// Renders canonical interval-union form:
/// - `(-inf,1) ∪ (1,inf)`
/// - `[0,inf)`
/// - `∅`
#let domain-to-string(domain) = {
  let all-real = (intervals: ((lo: none, lo-closed: false, hi: none, hi-closed: false),))
  let d = domain-normalize(if domain == none { all-real } else { domain })
  if d.intervals.len() == 0 { return "∅" }
  let parts = ()
  for iv in d.intervals { parts.push(_interval-str(iv)) }
  parts.join(" ∪ ")
}
