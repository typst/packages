
#let apply(fn, x, def) = if x == none { def } else { fn(x) }
#let apply-empty(fn, x, def) = if x == () { def } else { fn(x) }
#let id(x) = x
#let count(s, x) = s.matches(x).len()
#let prefill(x, n, v) = (..range(n).map(i => v), x).flatten().slice(-n)
#let postfill(x, n, v) = (x, (..range(n).map(i => v),)).flatten().slice(0, n)


#let low-octave = box(baseline: -0.7em, circle(radius: 0.5pt, fill: black))
#let up-octave = move(dy: 0.9em, circle(radius: 0.5pt, fill: black))

#let ubar = box(baseline: -7pt, fill: red, width: 1em, height: 0.5pt);
#let tbar = move(dy: 0.6em, line(start: (0% + 0em, 0% + 0em), length: 0.5em, angle: 90deg, stroke: 0.5pt));
#let tbar-indic = move(dy: 0.4em, line(angle: 90deg, length: 0.5em, stroke: 0.5pt))
#let low-octave-indic = move(dx: -0.4em, dy: -0.5em, circle(radius: 0.5pt, fill: black))
#let up-octave-indic = move(dx: -0.4em, dy: 0.9em, circle(radius: 0.5pt, fill: black))

#let komal(v) = math.attach(
  math.limits(v),
  b: ubar,
  t: hide(tbar),
);
#let tivra(v) = math.attach(
  math.limits(v),
  b: hide(ubar),
  t: tbar,
);
#let tivra-indic(v) = math.attach(
  math.limits(v),
  t: tbar-indic,
)
#let suddha(v) = math.attach(
  math.limits(v),
  b: hide(ubar),
  t: hide(tbar),
);
#let low(x) = math.attach(math.limits(x), b: low-octave, t: hide(up-octave))
#let low-indic(x) = box(x + place(bottom + left, dx: 0.5em, dy: 0.6em, low-octave-indic))
#let up-indic(x) = math.attach(math.limits(x), b: hide(low-octave), t: up-octave-indic)
#let up(x) = math.attach(math.limits(x), b: hide(low-octave), t: up-octave)
#let middle(x) = math.attach(math.limits(x), b: hide(low-octave), t: hide(up-octave))
#let kan(x) = math.script(math.attach(math.limits(""), t: x))

#let SA = suddha(math.upright("S"))
#let RE = suddha(math.upright("R"))
#let GA = suddha(math.upright("G"))
#let MA = suddha(math.upright("M"))
#let PA = suddha(math.upright("P"))
#let DA = suddha(math.upright("D"))
#let NI = suddha(math.upright("N"))

#let KM = tivra(math.upright("M"))

#let KR = komal(math.upright("R"))
#let KG = komal(math.upright("G"))
#let KD = komal(math.upright("D"))
//#let KN = math.underline(math.upright("N"))
#let KN = komal(math.upright("N"))

#let swara-config = (
  en: (
    S: SA,
    R: RE,
    G: GA,
    m: MA,
    M: KM,
    P: PA,
    D: DA,
    N: NI,
    r: KR,
    g: KG,
    d: KD,
    n: KN,
    "-": "-",
    ",": math.upright(","),
    ".": math.upright("."),
    "$": math.upright("$"),
    up: x => up(x),
    low: x => low(x),
    middle: x => middle(x),
  ),
  bn: (
    S: suddha(math.upright("স")),
    R: suddha(math.upright("র")),
    G: suddha(math.upright("গ")),
    m: suddha(math.upright("ম")),
    M: tivra-indic(math.upright("ম")),
    P: suddha(math.upright("প")),
    D: suddha(math.upright("ধ")),
    N: suddha(math.upright("ন")),
    r: komal(math.upright("র")),
    g: komal(math.upright("গ")),
    d: komal(math.upright("ধ")),
    n: komal(math.upright("ন")),
    "-": "-",
    ",": math.upright(","),
    ".": math.upright("."),
    "$": math.upright("$"),
    up: x => up-indic(x),
    low: x => low-indic(x),
    middle: x => middle(x),
  ),
  hi: (
    S: suddha(math.upright("स")),
    R: suddha(math.upright("र")),
    G: suddha(math.upright("ग")),
    m: suddha(math.upright("म")),
    M: tivra-indic(math.upright("म")),
    P: suddha(math.upright("प")),
    D: suddha(math.upright("ध")),
    N: suddha(math.upright("न")),
    r: komal(math.upright("र")),
    g: komal(math.upright("ग")),
    d: komal(math.upright("ध")),
    n: komal(math.upright("न")),
    "-": "-",
    ",": math.upright(","),
    ".": math.upright("."),
    "$": math.upright("$"),
    up: x => up-indic(x),
    low: x => low-indic(x),
    middle: x => middle(x),
  ),
  bn_a: (
    S: "স",
    R: "র",
    G: "গ",
    m: "ম",
    M: "হ্ম",
    P: "প",
    D: "ধ",
    N: "ন",
    r: "ঋ",
    g: "জ্ঞ",
    d: "দ",
    n: "ণ",
    "-": "-",
    ",": math.upright(","),
    ".": math.upright("."),
    "$": math.upright("$"),
    up: s => text("\u{09B0}\u{09CD}" + s),
    low: s => text(s + "\u{09CD}"),
    middle: s => text(s),
  ),
)

#let stroke-config = (
  en: (
    "da": math.upright("da"),
    "ra": math.upright("ra"),
    "dir": math.upright("dir"),
    "da-": math.upright("da-"),
    "-r": math.upright("-r"),
    "r,da": math.upright("r,da"),
    "-": "-",
  ),
  bn: (
    "da": math.upright("দা"),
    "ra": math.upright("রা"),
    "dir": math.upright("দির"),
    "da-": math.upright("দা-"),
    "-r": math.upright("-র"),
    "r,da": math.upright("র,দা"),
    "-": "-",
  ),
  hi: (
    "da": math.upright("दा"),
    "ra": math.upright("रा"),
    "dir": math.upright("दिर"),
    "da-": math.upright("दा-"),
    "-r": math.upright("-र"),
    "r,da": math.upright("र,दा"),
    "-": "-",
  ),
)
#let stroke-config = stroke-config + (bn_a: stroke-config.bn)

#let meend(x) = math.overparen(x)
#let krintan(x) = math.overbracket(x)
#let beat(x) = math.underparen(x)
//dha , dhin, na, te, re, ke, kat=ta,dhi, ga, di, ghe, ne, thun, tin
#let Dha = math.upright("Dha")
#let Dhin = math.upright("Dhin")
#let Din = math.upright("Din")
#let Ge = math.upright("Ge")
#let Tin = math.upright("Tin")
#let Ti = math.upright("Ti")
#let Ta = math.upright("Ta")
#let Na = math.upright("Na")
#let Kit = math.upright("Kit")
#let Kat = math.upright("Kat")
#let Tita = math.upright("Tita")
#let Kata = math.upright("Kata")
#let Gadi = math.upright("Gadi")
#let Gina = math.upright("Gina")
#let Dhage = math.upright("Dhage")
#let Tirkit = math.upright("Tirkit")
#let Tu = math.upright("Tu")
#let Ka = math.upright("Ka")
#let Dhi = math.upright("Dhi")
#let Ga = math.upright("Ga")

#let taals = (
  "tintal": (
    ("+", Dha, Dhin, Dhin, Dha),
    ("2", Dha, Dhin, Dhin, Dha),
    ("0", Dha, Tin, Tin, Ta),
    ("3", Ta, Dhin, Dhin, Dha),
  ),
  "dadra": (("+", Dha, Dhin, Na), ("0", Dha, Ti, Na)),
  "ektal": (
    ("+", Dhin, Dhin),
    ("0", Dhage, Tirkit),
    ("2", Tu, Na),
    ("0", Kat, Ta),
    ("3", Dhage, Tirkit),
    ("4", Dhin, Na),
  ),
  "ektal3": (
    ("+", Dha, Dhi, Na),
    ("2", Na, Ti, Na),
    ("0", Kat, Tita, Dhin),
    ("3", Tita, Dhin, Tita),
  ),
  "kaharba": (("+", Dha, Ge, Na, Ti), ("0", Na, Ka, Dhin, Na)),
  "chautal": (("+", Dha, Dha), ("0", Dhin, Ta), ("2", Kit, Dha), ("0", Dhin, Ta), ("3", Tita, Kata), ("4", Gadi, Gina)),
  "rupak": (("+", Tin, Tin, Na), ("2", Dhin, Na), ("3", Dhin, Na)),
  "jhaptal": (("+", Dhin, Na), ("2", Dhin, Dhin, Na), ("0", Tin, Na), ("3", Dhin, Dhin, Na)),
  "dipchandi": (("+", Dha, Dhin, "-"), ("2", Dha, Ge, Tin, "-"), ("0", Ta, Tin, "-"), ("3", Dha, Ge, Dhin, "-")),
  "tivra": (("+", Dha, Dhin, Ta), ("2", Tita, Kata), ("3", Gadi, Gina)),
  "dhamar": (("+", Ka, Dhi, Ta, Dhi, Ta), ("2", Dha, "-"), ("0", Ga, Ti, Ta), ("3", Ti, Ta, Ta, "-")),
  "sultal": (("+", Dha, Dha), ("0", Din, Ta), ("2", Kit, Dha), ("3", Tita, Kata), ("0", Gadi, Gina)),
  "adachautal": (
    ("+", Dhin, Tirkit),
    ("2", Dhin, Na),
    ("0", Tu, Na),
    ("3", Kat, Ta),
    ("0", Tirkit, Dhin),
    ("4", Na, Dhin),
    ("0", Dhin, Na),
  ),
)

#let beats-count(t) = t.map(b => b.len() - 1).sum()
#let bibhag-count(taal) = taal.len()
#let bibhag-positions(taal, repeat: 1) = {
  let single = range(taal.len() + 1).map(i => taal.slice(0, i).map(s => s.len() - 1).sum(default: 0))
  let b-count = beats-count(taal)
  range(repeat).map(r => single.slice(0, -1).map(p => r * b-count + p)).flatten() + (repeat * b-count,)
}
#let all-beats(cycles) = cycles.flatten()

#let deduplicate(arr) = arr.fold((), (acc, item) => if acc.contains(item) { acc } else { acc + (item,) })

#let extract-opts(s) = {
  let m = s.match(regex("\\s*\\[(.*?)\\]"))
  if m == none { return (s, (:)) }
  let opts = (:)
  for part in m.captures.at(0).split(",") {
    let kv = part.split(":")
    if kv.len() == 2 { opts.insert(kv.at(0).trim(), kv.at(1).trim()) }
  }
  (s.replace(m.text, ""), opts)
}

#let notation-options = (
  "taal": (values: ("none",) + taals.keys(), default: "none"),
  "matra": (values: ("show", "hide", "always"), default: "show"),
  "wrapped": (values: (true, false), default: true),
  "lang": (values: ("en", "bn", "hi", "bn_a"), default: "en"),
  "taal-separator": (values: ("none", "between", "all"), default: "between"),
  "taal-header": (values: ("bibhag", "bol", "matra"), default: ("bibhag",), multi: true),
)

#let parse-options(user-opts) = {
  let resolved = (:)
  for (key, config) in notation-options {
    let raw = user-opts.at(key, default: none)
    if raw == none {
      resolved.insert(key, config.default)
      continue
    }

    if config.at("multi", default: false) {
      let parts = raw.split("+").map(s => s.trim())
      let final = if parts.contains("all") { config.values } else if parts.contains("none") { () } else {
        parts.filter(p => config.values.contains(p))
      }
      resolved.insert(key, deduplicate(final))
    } else if config.values == (true, false) {
      resolved.insert(key, if raw == "true" { true } else if raw == "false" { false } else { config.default })
    } else {
      resolved.insert(key, if config.values.contains(raw) { raw } else { config.default })
    }
  }
  resolved
}


#let parse-pitch(s) = {
  let m = s.match(regex("(S|R|r|G|g|m|M|P|d|D|N|n|-|\\.|\\$)(\\.{0,2})(\\'{0,2})"))
  if m == none { return none }
  (base: m.captures.at(0), octave: count(m.captures.at(1), ".") * -1 + count(m.captures.at(2), "'"))
}

#let parse-note(s) = {
  let kan-m = s.match(regex("\\{([^}]*)\\}"))
  let base-s = s.replace(regex("\\{([^}]*)\\}"), "")
  let m = base-s.match(regex("(S|R|r|G|g|m|M|P|d|D|N|n|-|\\.|\\$)(\\.{0,2})(\\'{0,2})([,;]?)"))
  (
    pitch: (base: m.captures.at(0), octave: count(m.captures.at(1), ".") * -1 + count(m.captures.at(2), "'")),
    kan: if kan-m != none {
      kan-m
        .captures
        .at(0)
        .matches(regex("(S|R|r|G|g|m|M|P|d|D|N|n|-|\\.|\\$)(\\.{0,2})(\\'{0,2})"))
        .map(km => (
          base: km.captures.at(0),
          octave: count(km.captures.at(1), ".") * -1 + count(km.captures.at(2), "'"),
        ))
    } else { () },
    sep: if m.captures.len() > 3 { m.captures.at(3) } else { "" },
  )
}

#let note-re = regex("(\\{[^}]+\\})?(S|R|r|G|g|m|M|P|d|D|N|n|-|\\.|\\$)(\\.{0,2})(\\'{0,2})([,;]*)")

#let parse-line(text, taal: none, is-lyrics: false, is-stroke: false) = {
  let meends = text
    .matches(regex("\((.*?)\)"))
    .map(m => (
      text.slice(0, m.start).matches(note-re).len(),
      text.slice(0, m.end).matches(note-re).len() - 1,
    ))

  let bibhag-tokens = text
    .split("|")
    .map(b => {
      let raw = b.trim().split(regex("\s+")).filter(v => v != "")
      raw.fold((), (acc, p) => if p.matches(regex("^[,;]$")).len() > 0 and acc.len() > 0 {
        let last = acc.at(-1)
        acc.slice(0, -1) + (last + p,)
      } else { acc + (p,) })
    })
  let processed = if taal == none { bibhag-tokens } else {
    bibhag-tokens
      .enumerate()
      .map(iv => {
        let b-expected = taal.at(calc.rem(iv.at(0), taal.len())).len() - 1
        if iv.at(1).len() > 0 and iv.at(1).at(0) == ">" { prefill(iv.at(1).slice(1), b-expected, "") } else {
          postfill(iv.at(1), b-expected, "")
        }
      })
  }

  let flat-tokens = processed.flatten()
  let notes = flat-tokens
    .map(token => if is-lyrics or is-stroke {
      ((pitch: (base: token, octave: 0), kan: (), sep: ""),)
    } else {
      token.matches(note-re).map(m => parse-note(m.text))
    })
    .flatten()
  let beat-counts = flat-tokens.map(token => if is-lyrics or is-stroke { 1 } else { token.matches(note-re).len() })
  let beats = beat-counts.fold((0,), (acc, c) => acc + (acc.at(-1) + c,))
  let bibhags = processed.map(b => b.len()).fold((0,), (acc, c) => acc + (acc.at(-1) + c,))

  (line: notes, beats: beats, bibhags: bibhags, meends: meends)
}


#let render-note(note, lang) = {
  let config = swara-config.at(lang, default: swara-config.en)
  let render-p(p) = {
    let n = config.at(p.base, default: math.upright(p.base))
    if p.octave > 0 { (config.up)(n) } else if p.octave < 0 { (config.low)(n) } else { (config.middle)(n) }
  }
  let base = render-p(note.pitch) + note.sep
  if note.kan.len() > 0 {
    kan(note.kan.map(p => render-p(p)).join()) + base
  } else {
    base
  }
}

#let render-beat(ast, bi, matra-mode, is-lyrics, lang, is-stroke: false) = {
  let (start, end) = (ast.beats.at(bi), ast.beats.at(bi + 1))
  let line-len = ast.line.len()
  let (start, end) = (calc.min(start, line-len), calc.min(end, line-len))
  if is-lyrics { return ast.line.slice(start, end).map(n => n.pitch.base).join() }
  if is-stroke {
    let token = ast.line.slice(start, end).map(n => n.pitch.base).join()
    let config = stroke-config.at(lang, default: stroke-config.en)
    return text(size: 0.8em, config.at(token, default: math.upright(token)))
  }

  let notes-indices = range(start, end)
  let content = notes-indices
    .fold((out: (), skip: -1), (acc, ni) => {
      if ni < acc.skip { return acc }
      let m = ast.meends.find(m => m.at(0) == ni and m.at(1) < end)
      if m != none {
        let segment = ast.line.slice(ni, m.at(1) + 1).map(n => render-note(n, lang)).join()
        (out: acc.out + (meend(segment),), skip: m.at(1) + 1)
      } else {
        (out: acc.out + (render-note(ast.line.at(ni), lang),), skip: -1)
      }
    })
    .out
    .join()

  let total-count = end - start
  if matra-mode == "always" or (matra-mode == "show" and total-count > 1) {
    beat(content)
  } else {
    content
  }
}


#let hcell(val, visible) = if visible { (grid.cell(align: left + bottom, val),) } else { () }

#let render-taal-header(taal, has-any-prefix, b-count, repeat: 1, modes: ("bibhag",)) = {
  let h-row = hcell("", has-any-prefix)
  modes
    .map(mode => if mode == "bibhag" {
      (
        h-row
          + range(repeat)
            .map(_ => taal.map(bibhag => {
              (grid.cell(align: center + bottom, [#bibhag.at(0)]),) + range(bibhag.len() - 2).map(_ => grid.cell(""))
            }))
            .flatten()
            .flatten()
      )
    } else if mode == "bol" {
      (
        h-row
          + range(repeat)
            .map(_ => taal.map(bibhag => {
              bibhag.slice(1).map(bol => grid.cell(align: center + bottom, text(size: 0.8em, bol)))
            }))
            .flatten()
            .flatten()
      )
    } else if mode == "matra" {
      (
        h-row
          + range(1, repeat * b-count + 1)
            .map(i => {
              let val = calc.rem(i - 1, b-count) + 1
              grid.cell(align: center + bottom, text(size: 0.8em, str(val)))
            })
            .flatten()
      )
    } else { () })
    .flatten()
}

#let parse-itemized-lines(code, taal) = {
  code
    .split("\n")
    .filter(l => l.trim() != "")
    .fold((has-prefix: false, plus-count: 0, pl: ()), (acc, line) => {
      let content = line.trim()
      let is-separator = content.starts-with("---")
      let is-empty = content.len() == 0
      let (prefix, is-lyrics, is-stroke, plus) = (none, false, false, acc.plus-count)
      if not (is-separator or is-empty) {
        if content.starts-with("+") {
          plus = plus + 1
          (prefix, content) = ([#plus.], content.slice(1).trim())
        } else if content.starts-with("-") {
          (prefix, content) = ([•], content.slice(1).trim())
        } else if content.starts-with("#L") {
          (prefix, is-lyrics, content) = (none, true, content.slice(2).trim())
        } else if content.starts-with("#S") {
          (prefix, is-stroke, content) = (none, true, content.slice(2).trim())
        }
      }
      (
        has-prefix: acc.has-prefix or prefix != none,
        plus-count: plus,
        pl: acc.pl
          + (
            (
              prefix: prefix,
              is-lyrics: is-lyrics,
              is-stroke: is-stroke,
              is-separator: is-separator,
              is-empty: is-empty,
              ast: if is-separator or is-empty { none } else {
                parse-line(content, taal: taal, is-lyrics: is-lyrics, is-stroke: is-stroke)
              },
            ),
          ),
      )
    })
}

#let render-composition(text, lang) = {
  let (code-str, o1) = extract-opts(str(text))
  let (lang-str, o2) = extract-opts(str(lang))
  let opts = parse-options(o1 + o2)
  let (matra-mode, wrapped, config-lang) = (opts.matra, opts.wrapped, opts.lang)
  let taal = taals.at(opts.taal, default: none)
  let res = parse-itemized-lines(code-str, taal)
  let (processed-lines, has-any-prefix) = (res.pl, res.has-prefix)

  if taal == none {
    processed-lines
      .map(pl => {
        if pl.is-empty or pl.is-separator { return linebreak() }
        let ast = pl.ast
        let cells = range(ast.beats.len() - 1)
          .fold((out: (), skip: -1), (acc, bi) => {
            if bi < acc.skip { return acc }
            let (s, e) = (ast.beats.at(bi), ast.beats.at(bi + 1) - 1)
            let m = ast.meends.find(m => m.at(0) >= s and m.at(0) <= e and m.at(1) > e)
            if m != none {
              let span = range(bi + 1, ast.beats.len()).find(next => ast.beats.at(next) > m.at(1)) - bi
              let content = meend(
                range(span)
                  .map(i => render-beat(ast, bi + i, matra-mode, pl.is-lyrics, config-lang, is-stroke: pl.is-stroke))
                  .join(" "),
              )
              return (out: acc.out + (content,), skip: bi + span)
            }
            (
              out: acc.out + (render-beat(ast, bi, matra-mode, pl.is-lyrics, config-lang, is-stroke: pl.is-stroke),),
              skip: -1,
            )
          })
          .out
          .join(" ")
        (if pl.prefix != none { pl.prefix + " " } else { [] }) + cells + linebreak()
      })
      .join()
  } else {
    let b-count = beats-count(taal)
    let total-beats = if wrapped { b-count } else {
      processed-lines.fold(0, (m, pl) => if pl.ast == none { m } else { calc.max(m, pl.ast.beats.len() - 1) })
    }
    let row-counts = processed-lines.map(pl => if pl.is-separator { 0 } else if pl.is-empty { 1 } else {
      let count = pl.ast.beats.len() - 1
      if wrapped { int(calc.max(1, calc.ceil(count / b-count))) } else { 1 }
    })
    let h-modes = opts.at("taal-header")
    let h-rows = h-modes.len()

    grid(
      columns: if has-any-prefix { (auto,) + (1fr,) * total-beats } else { (1fr,) * total-beats },
      align: center + bottom, gutter: 2pt, inset: 5pt,
      ..bibhag-positions(taal, repeat: if wrapped { 1 } else { int(calc.ceil(total-beats / b-count)) })
        .filter(p => {
          if opts.at("taal-separator") == "none" { return false }
          if opts.at("taal-separator") == "between" {
            let total-repeat = if wrapped { 1 } else { int(calc.ceil(total-beats / b-count)) }
            return p > 0 and p < total-repeat * b-count
          }
          return true
        })
        .map(p => grid.vline(x: int(has-any-prefix) + p)),
      ..render-taal-header(
        taal,
        has-any-prefix,
        b-count,
        repeat: if wrapped { 1 } else {
          int(calc.ceil(total-beats / b-count))
        },
        modes: h-modes,
      ),
      ..if h-rows > 0 { (grid.hline(),) } else { () },
      ..processed-lines
        .enumerate()
        .map(iv => {
          let (i, pl) = iv
          if pl.is-separator { return (grid.hline(y: h-rows + row-counts.slice(0, i).sum(default: 0)),) }
          if pl.is-empty { return (hcell("", has-any-prefix) + range(total-beats).map(_ => grid.cell(""))).flatten() }
          let ast = pl.ast
          let step = if wrapped { b-count } else { ast.beats.len() - 1 }
          range(0, ast.beats.len() - 1, step: step)
            .enumerate()
            .map(rij => {
              let (ri, j) = rij
              let row-indices = range(j, calc.min(j + step, ast.beats.len() - 1))
              let res = row-indices.fold((out: (), skip: -1, used: 0), (acc, bi) => {
                if bi < acc.skip { return acc }
                let (s, e) = (ast.beats.at(bi), ast.beats.at(bi + 1) - 1)
                let m = ast.meends.find(m => m.at(0) >= s and m.at(0) <= e and m.at(1) > e)
                if m != none {
                  let span = range(bi + 1, ast.beats.len()).find(next => ast.beats.at(next) > m.at(1)) - bi
                  let actual-span = calc.min(span, row-indices.len() - (bi - j))
                  let sub = range(actual-span).map(k => render-beat(
                    ast,
                    bi + k,
                    matra-mode,
                    pl.is-lyrics,
                    config-lang,
                    is-stroke: pl.is-stroke,
                  ))
                  return (
                    out: acc.out
                      + (
                        grid.cell(colspan: actual-span, meend(grid(columns: (1fr,)
                            * actual-span, inset: 0pt, gutter: 2pt, ..sub))),
                      ),
                    skip: bi + actual-span,
                    used: acc.used + actual-span,
                  )
                }
                (
                  out: acc.out
                    + (
                      grid.cell(render-beat(
                        ast,
                        bi,
                        matra-mode,
                        pl.is-lyrics,
                        config-lang,
                        is-stroke: pl.is-stroke,
                      )),
                    ),
                  skip: -1,
                  used: acc.used + 1,
                )
              })
              (
                hcell(if ri == 0 { pl.prefix } else { none }, has-any-prefix)
                  + res.out
                  + range(total-beats - res.used).map(_ => grid.cell(""))
              )
            })
            .flatten()
        })
        .flatten()
    )
  }
}
#let apply-swaralipi(doc) = {
  show raw: it => if it.lang != none and it.lang.starts-with("note") { render-composition(it.text, it.lang) } else {
    it
  }
  doc
}
