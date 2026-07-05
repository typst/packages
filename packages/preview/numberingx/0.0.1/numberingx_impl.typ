// SPDX-License-Identifier: CC0-1.0

/// Parse a style object into a descriptor
#let parse-style(s) = {
  assert(type(s) == "dictionary", message: "Invalid style: " + repr(s) + ".")
  assert("system" in s, message: repr(s) + " is missing a `system` key.")
  let sys = s.system
  assert(
    sys in ("cyclic", "symbolic", "alphabetic", "fixed", "numeric", "additive")
    or (type(sys) == "array" and sys.len() == 2
      and sys.at(0) == "fixed" and type(sys.at(1)) == "integer"),
    message: "Invalid system: " + repr(sys) + "."
  )

  let desc = (:)
  desc.system = if type(sys) == "string" { sys } else { sys.at(0) }
  if sys == "fixed" { desc.offset = 1 }
  if type(sys) == "array" { desc.offset = int(sys.at(1)) }

  desc.fallback = if "fallback" in s {
    assert(
      type(s.fallback) == "string",
      message: "Invalid fallback value: " + repr(s.fallback) + "."
    )
    s.fallback
  } else {
    "decimal"
  }

  let (min, max) = if "range" in s {
    assert(
      type(s.range) == "array" and s.range.len() == 2
      and s.range.all((n) => type(n) == "integer" or n == "inf"),
      message: repr(s.range) + " is not a valid range."
    )
    s.range.map((x) => if x == "inf" { calc.inf } else { x })
  } else if desc.system in ("cyclic", "numeric", "fixed") {
    (min: -calc.inf, max: calc.inf)
  } else if desc.system in ("alphabetic", "symbolic") {
    (min: 1, max: calc.inf)
  } else if desc.system == "additive" {
    (min: 0, max: calc.inf)
  }
  desc.min = min
  desc.max = max

  let allow-negative =  ("symbolic", "alphabetic", "numeric", "additive")
  desc.negative = if desc.system in  allow-negative  {
    if "negative" in s {
      assert(
        type(s.negative) in ("string", "content"),
        message: "Invalid negative marker: " + repr(s.negative) + "."
      )
      s.negative
    } else {
      "-"
    }
  }

  desc.symbols = if desc.system == "additive" {
    assert(
      "additive-symbols" in s,
      message: repr(s) + " is missing an `additive-symbols` key."
    )
    let check-sym(sym) = (type(sym) == "array" and sym.len() == 2
      and type(sym.at(0)) == "integer"
      and type(sym.at(1)) in ("string", "content"))
    assert(
      type(s.additive-symbols) == "array" and s.additive-symbols.len() > 0
        and s.additive-symbols.all(check-sym),
      message: "Invalid symbols: " + repr(s.additive-symbols) + "."
    )
    s.additive-symbols
  } else {
    assert("symbols" in s, message: repr(s) + " is missing a `symbols` key.")
    assert(
      type(s.symbols) == "array" and s.symbols.len() > 0 and
      s.symbols.all((sym) => type(sym) in ("string", "content")),
      message: "Invalid symbols: " + repr(s.symbols) + "."
    )
    s.symbols
  }

  desc
}

/// Apply function `f` to all values of `dict` without touching the keys
#let map-values(dict, f) = {
  let d = (:)
  for (k, v) in dict.pairs() {
    d.insert(k, f(v))
  }
  d
}

#let builtin-styles = map-values(yaml("styles.yaml"), parse-style)

#builtin-styles.insert("1", builtin-styles.decimal)
#builtin-styles.insert("a", builtin-styles.lower-alpha)
#builtin-styles.insert("A", builtin-styles.upper-alpha)
#builtin-styles.insert("i", builtin-styles.lower-roman)
#builtin-styles.insert("I", builtin-styles.upper-roman)
#builtin-styles.insert("い", builtin-styles.hiragana-iroha)
#builtin-styles.insert("イ", builtin-styles.katakana-iroha)
#builtin-styles.insert("א", builtin-styles.hebrew)
#builtin-styles.insert("ㄱ", builtin-styles.korean-consonant)
#builtin-styles.insert("가", builtin-styles.korean-syllable)
#builtin-styles.insert("一", builtin-styles.cjk-decimal)

#builtin-styles.insert("*", parse-style((
  system: "symbolic",
  symbols: ("*", "†", "‡", "§", "¶", "‖"),
)))

/// Get a style descriptor given an id.
#let get-descriptor(id, styles) = {
  assert(
    id in builtin-styles or id in styles,
    message: "Unknown style: " + id + "."
  )
  if id in styles { styles.at(id) } else { builtin-styles.at(id) }
}

/// Parse a format string into a structured descriptor (ids not resolved).
#let parse-format-string(fmt) = {
  let pieces = ()
  let (acc, lex) = ("", fmt)
  while lex.len() > 0 {
    let i = lex.position(regex("[{}]"))
    if i == none {
      acc += lex
      lex = ""
    } else if lex.at(i + 1) == lex.at(i) {
      acc += lex.slice(0, i + 1)
      lex = lex.slice(i + 2)
    } else if lex.at(i) == "{" {
      let j = lex.position("}")
      assert(
        j != none,
        message: "Unclosed format rule in format string \"" + fmt + "\"."
      )
      pieces.push((prefix: acc + lex.slice(0, i), id: lex.slice(i + 1, j)))
      acc = ""
      lex = lex.slice(j + 1)
    } else {
      assert(
        false,
        message: "Unpaired closing brace in format string \"" + fmt + "\"."
      )
    }
  }
  (pieces: pieces, suffix: acc)
}

/// Parse a format string and resolves the styles ids into descriptors
#let parse-format-desc(fmt, styles) = {
  let (pieces, suffix) = parse-format-string(fmt)
  pieces = pieces.map(((prefix, id)) => {
    (prefix: prefix, style: get-descriptor(id, styles))
  })
  (pieces: pieces, suffix: suffix)
}

/// System specific formatting routines
#let format-functions = (
  cyclic: (d, n) => {
    d.symbols.at(calc.rem(n - 1, d.symbols.len()))
  },
  fixed: (d, n) => {
    let (min, max) = (d.offset, d.offset + d.symbols.len() -  1)
    if n < min or n > max { return false }
    d.symbols.at(n - min)
  },
  symbolic: (d, n) => {
    let sym = d.symbols.at(calc.rem(n - 1, d.symbols.len()))
    let len = calc.ceil(n / d.symbols.len())
    sym * len
  },
  alphabetic: (d, n) => {
    let s = ""
    let len = d.symbols.len()
    while n != 0 {
      n = n - 1
      s = d.symbols.at(calc.rem(n, len)) + s
      n = calc.quo(n, len)
    }
    s
  },
  numeric: (d, n) => {
    if n == 0 { return d.symbols.at(0) }
    let s = ""
    let len = d.symbols.len()
    while n != 0 {
      s = d.symbols.at(calc.rem(n, len)) + s
      n = calc.quo(n, len)
    }
    s
  },
  additive: (d, n) => {
    let tups = d.symbols
    if n == 0 {
      let sym = tups.find((s) => s.at(0) == 0)
      return if sym != none { sym.at(1) } else { false }
    }
    let s = ""
    for (weight, sym) in tups {
      if weight >= 1 and weight <= n {
        s = s + sym * calc.quo(n, weight)
        n = calc.rem(n, weight)
        if n == 0 { return s }
      }
    }
    if n == 0 { s } else { return false }
  }
)

/// Format a number using a given style descriptor.
#let format-one(desc, n) = {
  assert(type(n) == "integer", message: "only integer can be formatted")
  let fallback() = format-one(get-descriptor(desc.fallback), n)

  let m = if desc.negative != none { calc.abs(n) } else { n }
  if m < desc.min or m > desc.max { return fallback() }
  let s = format-functions.at(desc.system)(desc, m)
  if s == false { return fallback() }
  if n < 0 { desc.negative + s } else { s }
}

#let do-format(desc, ..nums) = {
  let nums = nums.pos()
  let front = nums.slice(0, calc.min(nums.len(), desc.pieces.len()))
  let back = if front.len() < nums.len() {
    nums.slice(front.len())
  } else { () }

  for (i, n) in front.enumerate() {
    let (prefix, style) = desc.pieces.at(i)
    prefix
    format-one(style, n)
  }

  let (prefix, style) = desc.pieces.last()
  for n in back {
    if prefix != "" { prefix } else { desc.suffix }
    format-one(style, n)
  }

  desc.suffix
}

#let format(fmt, styles: (:), ..nums) = do-format(
  parse-format-desc(fmt, styles),
  styles: styles,
  ..nums
)

#let formatter(fmt, styles: (:)) = (..nums) => {
  format(fmt, styles: styles, ..nums)
}
