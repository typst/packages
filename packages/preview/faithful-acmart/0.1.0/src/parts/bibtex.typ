// Pure-Typst BibTeX reader for the "bst" bibliography backend.
//
// Parses a .bib file (via read()) into the field-dict shape the ACM-Reference-
// Format engine consumes:
//   (<key>: (entry-type: str, fields: (name: value), names: (author: (..), editor: (..))))
// where each parsed name is (first:, von:, last:, jr:).
//
// Handles: @string macros (last definition wins; seeded with the .bst's built-in
// month + journal MACROs), "quoted" and {braced} values with correct brace-depth
// nesting, `#` concatenation, and BibTeX name syntax ("First von Last" /
// "von Last, Jr, First", joined by " and "). Nested braces are KEPT in values
// (TeX-significant: {ACM} casing, \url{...}); the formatter's tx() resolves them.

#import "bib-data.typ": journal-macros
#import "scan.typ": match-brace, match-delim, split-list-and

// ACM journal-style month macros (full name if <=5 letters, else abbreviated)
#let months = (
  jan: "Jan.", feb: "Feb.", mar: "March", apr: "April", may: "May", jun: "June",
  jul: "July", aug: "Aug.", sep: "Sept.", oct: "Oct.", nov: "Nov.", dec: "Dec.",
)

#let ws = (" ", "\n", "\t", "\r")

#let skip-ws(cp, i) = {
  while i < cp.len() and cp.at(i) in ws { i += 1 }
  i
}

// Like skip-ws, but also swallows `%...\n` line comments between fields (biblatex
// supports them; bibtex doesn't treat `%` specially, so silently dropping the rest
// of an entry — the old behaviour — was the worst of both). Only runs in the
// field-structure scan, never inside a braced/quoted value, so a literal `%` in a
// value is preserved.
#let skip-ws-comment(cp, i) = {
  i = skip-ws(cp, i)
  while i < cp.len() and cp.at(i) == "%" {
    while i < cp.len() and cp.at(i) != "\n" { i += 1 }
    i = skip-ws(cp, i)
  }
  i
}

// Read a (possibly #-concatenated) value starting at `i`; resolve bare tokens via
// `macros`. Returns (value-string, next-index). Quoted values respect brace depth.
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
        if cp.at(j) == "\\" { j += 2; continue }   // escaped char (\" \{ \})
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
      parts.push(macros.at(lower(tok), default: tok))
      i = j
    }
    i = skip-ws(cp, i)
    if i < cp.len() and cp.at(i) == "#" { i = skip-ws(cp, i + 1) } else { more = false }
  }
  // return RAW (no collapse/trim): @string fragments rely on exact inner spaces
  // for `#` concatenation ("Tech " # "Press"); whitespace is normalized per-field.
  let v = parts.join("")
  (if v == none { "" } else { v }, i)
}

#let collapse-ws(s) = s.replace(regex("\s+"), " ").trim()

// ---- name parsing ----
// Split a name list on the keyword "and" that sits at brace depth 0 and is
// bounded by whitespace on BOTH sides (any whitespace, incl. newlines — real
// .bib files put "and" on its own line). A leading/trailing "and" is not a
// separator (it has no whitespace on the outer side); two consecutive "and"s
// yield an empty name in between. Matches biblatex's split_token_lists_with_kw.
// Split `s` at every char in `seps` that sits at brace depth 0; brace groups are
// kept intact, so "{de la}" stays one token and "{Robert and Sons, Inc.}" keeps
// its comma. Matches biblatex's split_at_normal_char (commas/spaces inside braces
// are verbatim, not structural).
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

// BibTeX `von_token_found`: a token is a "von" (lowercase) token iff its first
// *brace-level-0* cased letter is lowercase. Only letters outside braces, and the
// recognized foreign-letter commands inside a `{\..}` special character, count:
//   * `Stra\ss`        -> "S" (level 0)        -> upper, not von
//   * `de`             -> "d"                  -> lower, von
//   * `{de la}`        -> braced group SKIPPED -> no level-0 letter -> not von
//   * `{Barnes & Co.}` -> skipped              -> not von
//   * `{\oe}uvre`      -> \oe foreign letter   -> lower, von
// (A regular `{group}` is skipped whole; a `{\cs..}` special character commits —
// foreign cs gives the case, else its inner letters do.) Mirrors bibtex.web's
// von_token_found / Check-special-character / Skip-over-stuff modules.
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
      if i < n and cp.at(i) == "\\" {     // special character {\cs..}
        i += 1
        let x = i
        while i < n and _ascii-alpha(cp.at(i)) { i += 1 }
        let cs = cp.slice(x, i).join("")
        if cs in _foreign-lower { return true }
        if cs in _foreign-upper { return false }
        let bl = 1                         // unknown cs: first inner cased letter wins
        while i < n and bl > 0 {
          let d = cp.at(i)
          if d == "}" { bl -= 1 } else if d == "{" { bl += 1 }
          else if lower(d) != upper(d) { return d == lower(d) }
          i += 1
        }
        return false                       // closed without a letter
      } else {                             // regular group: skip to its close
        let bl = 1
        while i < n and bl > 0 {
          if cp.at(i) == "{" { bl += 1 } else if cp.at(i) == "}" { bl -= 1 }
          i += 1
        }
      }
    } else if c == "}" { i += 1 }
    else if lower(c) != upper(c) { return c == lower(c) }   // level-0 cased letter
    else { i += 1 }
  }
  false
}

// BibTeX `von_name_ends_and_last_name_starts_stuff`: scanning down from the token
// before Last, von ends right after the LAST lowercase token that still leaves a
// non-empty Last. Everything in [von-start, von-end) is von (it may include
// UPPERCASE tokens, e.g. "De la"); [von-end, last-end) is Last.
#let von-end(toks, von-start, last-end) = {
  let ve = last-end - 1
  while ve > von-start {
    if is-lower-tok(toks.at(ve - 1)) { return ve }
    ve -= 1
  }
  von-start
}

// Join the tokens of ONE name part the way BibTeX's format.name$ does: a tie
// (`~`, -> nbsp) before the LAST token and after a single-letter token, a space
// otherwise — e.g. "de~la", "Stra\ss~e", "Charles Louis Xavier~Joseph". The tie
// matters: a control-word accent (\ss, \ae, ...) swallows a following *space* but
// not a *tie*, so BibTeX (and we) keep the gap by tying. Matches the `~`s BibTeX
// writes straight into the .bbl.
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

// "von Last" (comma form: the part before the first comma; von-start = 0).
#let split-von-last(toks) = {
  if toks.len() == 0 { return ("", "") }
  let ve = von-end(toks, 0, toks.len())
  (tie-join(toks.slice(0, ve)), tie-join(toks.slice(ve)))
}

// "First von Last" (no comma). von-start = first lowercase token (BibTeX scans up
// while von-start < last-1); First = tokens before it; if none, there is no von
// and Last is the final token, First the rest.
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
    // "von Last, [Jr,] First": tokenize and tie-join the Jr/First parts too, the
    // way BibTeX's format.name$ does (so "Harcourt Fenton" -> "Harcourt~Fenton").
    let (von, last) = split-von-last(toks)
    let part = i => tie-join(split-top(parts.at(i), ws).filter(t => t != ""))
    let jr = if parts.len() > 2 { part(1) } else { "" }
    let first = if parts.len() > 2 { part(2) } else { part(1) }
    (first: first, von: von, last: last, jr: jr)
  }
  // `().join(" ")` is `none` in Typst, so an empty part can come back as none;
  // coerce to "" so every part is a string (matches the reference; avoids a
  // downstream `string + none` in the sort key for all-lowercase names).
  r.pairs().map(((k, v)) => (k, if v == none { "" } else { v })).to-dict()
}

#let parse-names(raw) = split-list-and(raw).map(parse-one-name)

// ---- one entry: "@type{key, f = v, ...}" / "@type(key, f = v, ...)" ----
#let parse-entry(block, macros) = {
  let m = block.match(regex("(?s)^@(\w+)\s*[\{\(]\s*([^,]+),"))
  if m == none { return none }
  let etype = lower(m.captures.at(0))
  let key = m.captures.at(1).trim()
  let cp = block.slice(m.end, -1).codepoints()
  let fields = (:)
  let i = 0
  while i < cp.len() {
    // next field name (or end of entry)
    let k = skip-ws-comment(cp, i)
    let s = k
    while s < cp.len() and (cp.at(s).match(regex("[A-Za-z0-9_-]")) != none) { s += 1 }
    if s == k { break }                       // no identifier -> done (trailing })
    let name = lower(cp.slice(k, s).join(""))
    let eq = skip-ws(cp, s)
    if eq >= cp.len() or cp.at(eq) != "=" { break }
    let (val, ni) = read-value(cp, eq + 1, macros)
    // store the RAW TeX value (collapse whitespace only); decoding to Unicode and
    // rendering to content happen later, in tex.typ, so the raw TeX survives the
    // pipeline (BibTeX-style). Names tokenize on the RAW string too — exactly like
    // BibTeX's format.name$ (brace/case rules in parse-names), so "Stra\ss e" and
    // "{Barnes and Noble}" split the way bibtex splits them.
    fields.insert(name, collapse-ws(val))
    i = skip-ws-comment(cp, ni)
    while i < cp.len() and cp.at(i) == "," { i = skip-ws-comment(cp, i + 1) }
  }
  let names = (:)
  // Parse every name-list role in the ACM data model. `translator` is not yet
  // rendered by our backends, but the upstream ACM BibLaTeX drivers do print it
  // (acmnumeric/acmauthoryear.bbx `translator+others`), so keep it in the parsed
  // data model rather than dropping it on the floor.
  for role in ("author", "editor", "bookauthor", "translator") {
    if role in fields { names.insert(role, parse-names(fields.at(role))) }
  }
  (key: key, entry: (entry-type: etype, fields: fields, names: names))
}

// span of every top-level @...{...} or @...(...) block
#let scan-blocks(cp) = {
  let out = ()
  let i = 0
  while i < cp.len() {
    if cp.at(i) == "%" {            // top-level line comment: skip to EOL
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
  // pass 1: macro table — built-ins first, then @string (later defs win)
  let macros = (:)
  for (k, v) in journal-macros { macros.insert(lower(k), v) }
  for (k, v) in months { macros.insert(k, v) }
  for blk in blocks {
    let head = lower(cp.slice(blk.start, calc.min(blk.start + 8, cp.len())).join(""))
    if head.starts-with("@string") {
      let inner = cp.slice(blk.brace + 1, blk.end)
      let k = skip-ws(inner, 0)
      let s = k
      while s < inner.len() and (inner.at(s).match(regex("\w")) != none) { s += 1 }
      if s > k {
        let name = lower(inner.slice(k, s).join(""))
        let eq = skip-ws(inner, s)
        if eq < inner.len() and inner.at(eq) == "=" {
          let (val, _) = read-value(inner, eq + 1, macros)
          macros.insert(name, val)
        }
      }
    }
  }
  // pass 2: entries
  let db = (:)
  for blk in blocks {
    let head = lower(cp.slice(blk.start, calc.min(blk.start + 9, cp.len())).join(""))
    if head.starts-with("@string") or head.starts-with("@preamble") or head.starts-with("@comment") { continue }
    let block = cp.slice(blk.start, calc.min(blk.end + 1, cp.len())).join("")
    let r = parse-entry(block, macros)
    if r != none { db.insert(r.key, r.entry) }
  }
  db
}

#let read-bib(path) = parse-bib(read(path))
