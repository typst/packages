// Read BibTeX entries and names while preserving TeX field syntax.

#import "bib-data.typ": journal-macros
#import "scan.typ": match-brace, match-delim, split-list-and, ws

#let months = (
  jan: "Jan.", feb: "Feb.", mar: "March", apr: "April", may: "May", jun: "June",
  jul: "July", aug: "Aug.", sep: "Sept.", oct: "Oct.", nov: "Nov.", dec: "Dec.",
)

#let skip-ws(cp, i) = {
  while i < cp.len() and cp.at(i) in ws { i += 1 }
  i
}

// Allow BibLaTeX line comments between fields; preserve percent signs inside values.
#let skip-ws-comment(cp, i) = {
  i = skip-ws(cp, i)
  while i < cp.len() and cp.at(i) == "%" {
    while i < cp.len() and cp.at(i) != "\n" { i += 1 }
    i = skip-ws(cp, i)
  }
  i
}

#let read-value(cp, i, macros) = {
  i = skip-ws(cp, i)
  let parts = ()
  let more = true
  while more and i < cp.len() {
    let c = cp.at(i)
    if c == "\"" {
      let j = i + 1
      let depth = 0
      while j < cp.len() and not (cp.at(j) == "\"" and depth == 0) {
        if cp.at(j) == "\\" { j += 2; continue }
        if cp.at(j) == "{" { depth += 1 } else if cp.at(j) == "}" { depth -= 1 }
        j += 1
      }
      parts.push(cp.slice(i + 1, j).join(""))
      i = j + 1
    } else if c == "{" {
      let j = match-brace(cp, i)
      parts.push(cp.slice(i + 1, j).join(""))
      i = j + 1
    } else {
      let j = i
      while j < cp.len() and not (cp.at(j) in (",", "}", "#") or cp.at(j) in ws) { j += 1 }
      let tok = cp.slice(i, j).join("").trim()
      // BibTeX expands undefined string macros to the empty string.
      parts.push(if tok.match(regex("^\d+$")) != none {
        tok
      } else {
        macros.at(lower(tok), default: "")
      })
      i = j
    }
    i = skip-ws(cp, i)
    if i < cp.len() and cp.at(i) == "#" { i = skip-ws(cp, i + 1) } else { more = false }
  }
  // Preserve spaces until concatenation is complete: "Tech " # "Press" needs its internal space.
  let v = parts.join("")
  (if v == none { "" } else { v }, i)
}

#let collapse-ws(s) = s.replace(regex("\s+"), " ").trim()

#let split-top(s, seps) = {
  let parts = ()
  let cur = ""
  let depth = 0
  for c in s.codepoints() {
    if c == "{" { depth += 1; cur += c }
    else if c == "}" { depth -= 1; cur += c }
    else if depth == 0 and c in seps { parts.push(cur); cur = "" }
    else { cur += c }
  }
  parts.push(cur)
  parts
}

// bibtex.web, von_token_found: case comes from a top-level letter or a {\control} special character.
// Ordinary brace groups do not determine case.
#let _ascii-alpha(c) = (c >= "a" and c <= "z") or (c >= "A" and c <= "Z")
#let _foreign-lower = ("i", "j", "o", "l", "oe", "ae", "aa", "ss")
#let _foreign-upper = ("O", "L", "OE", "AE", "AA")
#let is-lower-tok(t) = {
  let cp = t.codepoints()
  let n = cp.len()
  let i = 0
  while i < n {
    let c = cp.at(i)
    if c == "{" {
      i += 1
      if i < n and cp.at(i) == "\\" {
        i += 1
        let x = i
        while i < n and _ascii-alpha(cp.at(i)) { i += 1 }
        let cs = cp.slice(x, i).join("")
        if cs in _foreign-lower { return true }
        if cs in _foreign-upper { return false }
        let bl = 1 // Unknown control sequence: use the first inner cased letter.
        while i < n and bl > 0 {
          let d = cp.at(i)
          if d == "}" { bl -= 1 } else if d == "{" { bl += 1 }
          else if lower(d) != upper(d) { return d == lower(d) }
          i += 1
        }
        return false
      } else {
        let bl = 1
        while i < n and bl > 0 {
          if cp.at(i) == "{" { bl += 1 } else if cp.at(i) == "}" { bl -= 1 }
          i += 1
        }
      }
    } else if c == "}" { i += 1 }
    else if lower(c) != upper(c) { return c == lower(c) }
    else { i += 1 }
  }
  false
}

// bibtex.web, von_name_ends_and_last_name_starts_stuff: von may include uppercase tokens before its final lowercase token.
#let von-end(toks, von-start, last-end) = {
  let ve = last-end - 1
  while ve > von-start {
    if is-lower-tok(toks.at(ve - 1)) { return ve }
    ve -= 1
  }
  von-start
}

// format.name$ inserts ties that survive TeX control-word spacing, such as Stra\ss~e.
#let tie-join(toks) = {
  if toks.len() == 0 { return "" }
  let n = toks.len()
  let out = toks.at(0)
  for i in range(1, n) {
    let sep = if toks.at(i - 1).clusters().len() == 1 or i == n - 1 { "~" } else { " " }
    out += sep + toks.at(i)
  }
  out
}

#let split-von-last(toks) = {
  if toks.len() == 0 { return ("", "") }
  let ve = von-end(toks, 0, toks.len())
  (tie-join(toks.slice(0, ve)), tie-join(toks.slice(ve)))
}

#let split-first-von-last(toks) = {
  let n = toks.len()
  let vs = 0
  while vs < n - 1 and not is-lower-tok(toks.at(vs)) { vs += 1 }
  if vs >= n - 1 or not is-lower-tok(toks.at(vs)) {
    (tie-join(toks.slice(0, n - 1)), "", toks.at(n - 1, default: ""))
  } else {
    let ve = von-end(toks, vs, n)
    (tie-join(toks.slice(0, vs)), tie-join(toks.slice(vs, ve)), tie-join(toks.slice(ve)))
  }
}

#let parse-one-name(raw) = {
  let parts = split-top(raw.trim(), (",",)).map(p => p.trim())
  let toks = split-top(parts.at(0), ws).filter(t => t != "")
  let r = if parts.len() == 1 {
    if toks.len() == 0 { (first: "", von: "", last: "", jr: "") }
    else {
      let (first, von, last) = split-first-von-last(toks)
      (first: first, von: von, last: last, jr: "")
    }
  } else {
    let (von, last) = split-von-last(toks)
    let part = i => tie-join(split-top(parts.at(i), ws).filter(t => t != ""))
    let jr = if parts.len() > 2 { part(1) } else { "" }
    let first = if parts.len() > 2 { part(2) } else { part(1) }
    (first: first, von: von, last: last, jr: jr)
  }
  r.pairs().map(((k, v)) => (k, if v == none { "" } else { v })).to-dict()
}

#let parse-names(raw) = split-list-and(raw).map(parse-one-name)

#let parse-entry(block, macros) = {
  let m = block.match(regex("(?s)^@(\w+)\s*[\{\(]\s*([^,]+),"))
  if m == none { return none }
  let etype = lower(m.captures.at(0))
  let key = m.captures.at(1).trim()
  let cp = block.slice(m.end, -1).codepoints()
  let fields = (:)
  let i = 0
  while i < cp.len() {
    let k = skip-ws-comment(cp, i)
    let s = k
    while s < cp.len() and (cp.at(s).match(regex("[A-Za-z0-9_-]")) != none) { s += 1 }
    if s == k { break }
    let name = lower(cp.slice(k, s).join(""))
    let eq = skip-ws(cp, s)
    if eq >= cp.len() or cp.at(eq) != "=" { break }
    let (val, ni) = read-value(cp, eq + 1, macros)
    let val = collapse-ws(val)
    // Keep empty fields: an explicit empty canonical field must block inheritance from its legacy alias.
    fields.insert(name, val)
    i = skip-ws-comment(cp, ni)
    while i < cp.len() and cp.at(i) == "," { i = skip-ws-comment(cp, i + 1) }
  }
  let names = (:)
  for role in ("author", "editor", "bookauthor", "translator", "holder", "sortname") {
    if role in fields { names.insert(role, parse-names(fields.at(role))) }
  }
  (key: key, entry: (entry-type: etype, fields: fields, names: names))
}

#let scan-blocks(cp) = {
  let out = ()
  let i = 0
  while i < cp.len() {
    if cp.at(i) == "%" {
      while i < cp.len() and cp.at(i) != "\n" { i += 1 }
      continue
    }
    if cp.at(i) != "@" { i += 1; continue }
    let b = i
    while b < cp.len() and not (cp.at(b) in ("{", "(")) { b += 1 }
    if b >= cp.len() { break }
    let open = cp.at(b)
    let close = if open == "{" { "}" } else { ")" }
    let e = match-delim(cp, b, open: open, close: close)
    out.push((start: i, brace: b, end: e))
    i = e + 1
  }
  out
}

#let parse-bib(text) = {
  let cp = text.codepoints()
  let blocks = scan-blocks(cp)
  // Macro redefinitions affect only entries that follow them in the source.
  let macros = (:)
  for (k, v) in journal-macros { macros.insert(lower(k), v) }
  for (k, v) in months { macros.insert(k, v) }
  let db = (:)
  for blk in blocks {
    let head = lower(cp.slice(blk.start, calc.min(blk.start + 9, cp.len())).join(""))
    if head.starts-with("@string") {
      let inner = cp.slice(blk.brace + 1, blk.end)
      let k = skip-ws(inner, 0)
      let s = k
      // BibTeX identifiers allow punctuation beyond \w.
      while s < inner.len() and inner.at(s) != "=" and inner.at(s) not in ws { s += 1 }
      if s > k {
        let name = lower(inner.slice(k, s).join("").trim())
        let eq = skip-ws(inner, s)
        if eq < inner.len() and inner.at(eq) == "=" {
          let (val, _) = read-value(inner, eq + 1, macros)
          macros.insert(name, val)
        }
      }
    } else if not (head.starts-with("@preamble") or head.starts-with("@comment")) {
      let block = cp.slice(blk.start, calc.min(blk.end + 1, cp.len())).join("")
      let r = parse-entry(block, macros)
      if r != none { db.insert(r.key, r.entry) }
    }
  }
  db
}

#let read-bib(path) = parse-bib(read(path))
