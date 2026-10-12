// ACM .bbx styles and biblatex-software drivers; function names follow their upstream macros.

#import "bibtex.typ": parse-names
#import "scan.typ": match-brace, split-list-and, remove-outer
#import "tex.typ": foreign-purify, decode-chars, _special-letters as special-letters
#import "tex.typ": _accent-cs as accent-symbols, _cs-literal as visible-symbols
#import "tex.typ": _noop-cw as noop-words
#import "acmref-common.typ": render, blx-ends-punct, blx-visible-tail, it, fld, has, articleno-of, is-others, join-names, dashify, fixing
#import "doi.typ": normalize-doi
#let V(text, c: none) = (c: render(if c == none { text } else { c }), p: blx-ends-punct(text))
#let fV(e, name) = if has(e, name) { V(fld(e, name)) } else { none }

#let blx-maxbibnames = 9
#let blx-minbibnames = 1
#let blx-join-names(people) = {
  let real = people.filter(n => not is-others(n))
  let shown = if real.len() > blx-maxbibnames {
    real.slice(0, blx-minbibnames) + ((first: "", von: "", last: "others", jr: ""),)
  } else { people }
  join-names(shown, suffix-comma: false)
}
// \MakeSentenceCase* reserves capitalization for the first character, even when that character is punctuation.
// Accents pass the position to their letter; braces protect case.
#let blx-accent-words = ("b", "c", "d", "H", "k", "r", "t", "u", "v")
#let blx-case-macros = (
  ae: ("\\AE", "\\ae"), AE: ("\\AE", "\\ae"),
  oe: ("\\OE", "\\oe"), OE: ("\\OE", "\\oe"),
  o: ("\\O", "\\o"), O: ("\\O", "\\o"),
  aa: ("\\AA", "\\aa"), AA: ("\\AA", "\\aa"),
  l: ("\\L", "\\l"), L: ("\\L", "\\l"),
  ss: ("Ss", "\\ss"),
  i: ("I", "\\i"),
  j: ("\\j", "\\j"),
)
#let blx-sentence-case(raw) = {
  let cp = raw.codepoints()
  let n = cp.len()
  let letter = c => (c >= "A" and c <= "Z") or (c >= "a" and c <= "z")
  let accent-at = j => j + 1 < n and cp.at(j) == "\\" and (
    cp.at(j + 1) in accent-symbols or {
      let k = j + 1
      while k < n and letter(cp.at(k)) { k += 1 }
      cp.slice(j + 1, k).join("") in blx-accent-words
    })
  let out = ""
  let first = true
  let after-accent = false
  let i = 0
  while i < n {
    let c = cp.at(i)
    if c == "\\" {
      let at = i + 1
      let k = at
      while k < n and letter(cp.at(k)) { k += 1 }
      if k > at {
        let name = cp.slice(at, k).join("")
        if name in blx-accent-words {
          out += "\\" + name
          after-accent = true
        } else if name in blx-case-macros {
          // Replace consumed control-word whitespace with an empty group to preserve the word boundary without printing a space.
          let form = blx-case-macros.at(name).at(if first { 0 } else { 1 })
          out += form
          let ws = k
          while k < n and cp.at(k) in (" ", "\t", "\n", "\r") { k += 1 }
          if k > ws and form.starts-with("\\") { out += "{}" }
          first = false
          after-accent = false
        } else {
          out += "\\" + name
          if name not in noop-words { first = false }
          after-accent = false
        }
        i = k
      } else {
        let sym = if at < n { cp.at(at) } else { "" }
        out += c + sym
        i = if at < n { at + 1 } else { at }
        after-accent = sym in accent-symbols
        if sym in visible-symbols { first = false }
      }
    } else if after-accent and c in (" ", "\t", "\n", "\r") {
      out += c
      i += 1
    } else if c == "{" and (after-accent or accent-at(i + 1)) {
      out += c
      i += 1
      after-accent = false
    } else if c == "{" {
      let j = match-brace(cp, i)
      out += cp.slice(i, calc.min(j + 1, n)).join("")
      first = false
      after-accent = false
      i = j + 1
    } else if lower(c) != upper(c) {
      out += if first { upper(c) } else { lower(c) }
      first = false
      after-accent = false
      i += 1
    } else {
      out += c
      if c not in (" ", "\t", "\n", "\r") { first = false }
      after-accent = false
      i += 1
    }
  }
  out
}

#let blx-list-join(parts) = {
  if parts.len() == 0 { return [] }
  let out = []
  for (i, p) in parts.enumerate() {
    if i > 0 {
      if parts.len() == 2 { out += " and " }
      else if i == parts.len() - 1 { out += ", and " }
      else { out += ", " }
    }
    out += p
  }
  out
}
#let blx-list-content(raw) = blx-list-join(
  split-list-and(raw, trim: true, filter-empty: true).map(render))
#let blx-language-strings = (
  american: "American", basque: "Basque", brazilian: "Brazilian",
  bulgarian: "Bulgarian", catalan: "Catalan", croatian: "Croatian", czech: "Czech",
  danish: "Danish", dutch: "Dutch", english: "English", estonian: "Estonian",
  finnish: "Finnish", french: "French", galician: "Galician", german: "German",
  greek: "Greek", hungarian: "Hungarian", italian: "Italian", japanese: "Japanese",
  latin: "Latin", latvian: "Latvian", lithuanian: "Lithuanian", marathi: "Marathi",
  norwegian: "Norwegian", polish: "Polish", portuguese: "Portuguese",
  romanian: "Romanian", russian: "Russian", serbian: "Serbian", slovak: "Slovak",
  slovene: "Slovene", spanish: "Spanish", swedish: "Swedish", turkish: "Turkish",
  ukrainian: "Ukrainian",
)
#let blx-language-items(raw) = {
  let parts = split-list-and(raw, trim: true, filter-empty: true)
  parts.map(v => if v in blx-language-strings { blx-language-strings.at(v) } else { v })
}
#let blx-language-value(raw) = {
  let parts = blx-language-items(raw)
  (c: blx-list-join(parts.map(render)), p: parts.len() > 0 and blx-ends-punct(parts.last()))
}
// The punctuation tracker sees the last printed list item.
#let blx-list-last(raw) = {
  let parts = split-list-and(raw, trim: true, filter-empty: true)
  if parts.len() == 0 { raw } else { parts.last() }
}
#let blx-list-value(raw) = {
  let parts = split-list-and(raw, trim: true, filter-empty: true)
  (c: blx-list-content(raw), p: parts.len() > 0 and blx-ends-punct(parts.last()))
}
#let blx-list-field(e, ..names) = {
  for name in names.pos() {
    if has(e, name) { return blx-list-value(fld(e, name)) }
  }
  none
}
#let blx-months = (
  "1": "Jan.", "01": "Jan.", jan: "Jan.", january: "Jan.",
  "2": "Feb.", "02": "Feb.", feb: "Feb.", february: "Feb.",
  "3": "Mar.", "03": "Mar.", mar: "Mar.", march: "Mar.",
  "4": "Apr.", "04": "Apr.", apr: "Apr.", april: "Apr.",
  "5": "May", "05": "May", may: "May",
  "6": "June", "06": "June", jun: "June", june: "June",
  "7": "July", "07": "July", jul: "July", july: "July",
  "8": "Aug.", "08": "Aug.", aug: "Aug.", august: "Aug.",
  "9": "Sept.", "09": "Sept.", sep: "Sept.", sept: "Sept.", september: "Sept.",
  "10": "Oct.", oct: "Oct.", october: "Oct.",
  "11": "Nov.", nov: "Nov.", november: "Nov.",
  "12": "Dec.", dec: "Dec.", december: "Dec.",
  "21": "Spr.", "22": "Sum.", "23": "Aut.", "24": "Win.",
)
#let blx-month(raw) = {
  let parts = raw.replace(".", "").split(regex("[\\s,/-]+")).filter(p => p != "")
  let k = if parts.len() > 0 { lower(parts.first()) } else { lower(raw.replace(".", "")) }
  blx-months.at(k, default: raw)
}
// Biber materializes date components before inheritance; explicit date parts override legacy year/month fields.
#let blx-no-date-parts = (
  year: none, month: none, day: none,
  end-year: none, end-month: none, end-day: none, span: false,
)
#let blx-days-in-month(year, month) = {
  let year = calc.abs(year)
  let leap = calc.rem(year, 4) == 0 and (calc.rem(year, 100) != 0 or calc.rem(year, 400) == 0)
  if month == 2 and leap { 29 } else { (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31).at(month - 1) }
}
#let blx-iso-parts(raw) = {
  let t = raw.trim()
  if t.ends-with(regex("[?~%]")) { t = t.slice(0, -1) }
  if t.ends-with(regex("[?~%]")) { return blx-no-date-parts }
  let span = (y, m, d, ey, em, ed) => (
    year: y, month: m, day: d, end-year: ey, end-month: em, end-day: ed, span: true,
  )
  let plain = (y, m, d) => (
    year: y, month: m, day: d, end-year: none, end-month: none, end-day: none, span: false,
  )
  let unspecified = t.match(regex("^(-?\d{1,3})(X+)$"))
  if unspecified != none {
    let head = unspecified.captures.at(0)
    let xs = unspecified.captures.at(1)
    if head.len() + xs.len() != 4 { return blx-no-date-parts }
    return span(head + "0" * xs.len(), none, none, head + "9" * xs.len(), none, none)
  }
  if t.match(regex("^-?\d{4}$")) != none { return plain(t, none, none) }
  let mx = t.match(regex("^(-?\d{4})-XX$"))
  if mx != none {
    let y = mx.captures.at(0)
    return span(y, "01", none, y, "12", none)
  }
  let ym = t.match(regex("^(-?\d{4})-(0[1-9]|1[0-2]|2[1-4])$"))
  if ym != none { return plain(ym.captures.at(0), ym.captures.at(1), none) }
  let dx = t.match(regex("^(-?\d{4})-(0[1-9]|1[0-2])-XX$"))
  if dx != none {
    let y = dx.captures.at(0)
    let m = dx.captures.at(1)
    return span(y, m, "01", y, m, str(blx-days-in-month(int(y), int(m))))
  }
  let ymd = t.match(regex("^(-?\d{4})-(0[1-9]|1[0-2])-(\d{2})$"))
  if ymd != none {
    let y = ymd.captures.at(0)
    let m = ymd.captures.at(1)
    let d = ymd.captures.at(2)
    if int(d) >= 1 and int(d) <= blx-days-in-month(int(y), int(m)) { return plain(y, m, d) }
  }
  blx-no-date-parts
}
#let blx-date-parts(e) = {
  let raw = if has(e, "date") { fld(e, "date").trim() } else { "" }
  let halves = raw.split("/")
  let iso = t => if halves.len() > 2 { blx-no-date-parts } else { blx-iso-parts(t) }
  let legacy = name => if has(e, name) { fld(e, name) } else { none }
  let head = halves.first().trim()
  let start = iso(head)
  let tail = if halves.len() > 1 { halves.at(1).trim() } else { none }
  let far = if tail != none { iso(tail) } else { blx-no-date-parts }
  // An invalid start rejects the date; an invalid end discards only the range.
  let rejected = (head != "" and start.year == none) or halves.len() > 2
  let open-end = not rejected and tail == "" and start.year != none
  let use-end = not rejected and tail != none and tail != "" and far.year != none and not far.span
  let ranged = not rejected and (open-end or use-end or start.span)
  let parsed = not rejected and (start.year != none or use-end)
  if not parsed {
    return (
      year: legacy("year"), month: legacy("month"), day: legacy("day"),
      end-year: legacy("endyear"), end-month: legacy("endmonth"), end-day: legacy("endday"),
      open: legacy("endyearunknown") != none,
      start-open: legacy("year") == none and legacy("endyear") != none,
      ranged: legacy("endyear") != none or legacy("endyearunknown") != none,
      parsed: false,
    )
  }
  let year = if start.year != none { start.year } else { legacy("year") }
  let end = if use-end { far } else { blx-no-date-parts }
  (
    year: year,
    month: if start.month != none { start.month } else { legacy("month") },
    day: start.day,
    end-year: if start.span { start.end-year } else { end.year },
    end-month: if start.span { start.end-month } else { end.month },
    end-day: if start.span { start.end-day } else { end.day },
    open: open-end,
    start-open: ranged and year == none and end.year != none,
    ranged: ranged,
    parsed: true,
  )
}
#let blx-year-digits(y) = {
  if y == none { return none }
  let digits = y.trim("-", at: start).trim("0", at: start)
  if digits == "" { "0" } else { digits }
}
#let blx-year-text(y) = {
  if y == none { return none }
  let shown = blx-year-digits(y)
  if y.starts-with("-") { "\u{2212}" + shown } else { shown }
}
#let blx-year-label(y) = if y == none { none } else { y.replace("-", "\u{2212}") }
#let blx-date-piece(m, d, y) = {
  let c = if m != none { blx-month(m) } else { "" }
  if d != none {
    let day = d.trim(regex("^0+"))
    c += (if c != "" { " " } else { "" }) + (if day == "" { "0" } else { day })
  }
  if y != none { c += (if d != none { ", " } else if c != "" { " " } else { "" }) + blx-year-text(y) }
  c
}
#let blx-render-date(p) = {
  if p.start-open {
    let head = blx-date-piece(p.month, p.day, none)
    let tail = blx-date-piece(p.end-month, p.end-day, p.end-year)
    return head + (if head == "" { "" } else { " " }) + "\u{2013}" + tail
  }
  if p.year == none { return "" }
  let start-with = y => blx-date-piece(p.month, p.day, y)
  if p.open { return start-with(p.year) + "\u{2013}" }
  if p.end-year == none { return start-with(p.year) }
  let same-year = p.end-year == p.year
  let end-month = if same-year and p.end-month == p.month { none } else { p.end-month }
  let end = blx-date-piece(end-month, p.end-day, p.end-year)
  let gap = if p.end-year != none and p.end-year.starts-with("-") { " " } else { "" }
  start-with(if same-year { none } else { p.year }) + "\u{2013}" + gap + end
}
#let blx-printdate(e) = blx-render-date(blx-date-parts(e))
#let blx-label-year(e) = {
  let p = blx-date-parts(e)
  let y = blx-year-label(p.year)
  let ey = blx-year-label(p.end-year)
  if p.start-open { return "\u{2013}" + ey }
  if y == none { return none }
  if p.open { return y + "\u{2013}" }
  if ey != none and ey != y {
    return y + "\u{2013}" + (if p.end-year.starts-with("-") { " " } else { "" }) + ey
  }
  y
}
// The ACM date macro retains parentheses even when \printdate is empty.
#let blx-date-macro(e) = {
  let d = blx-printdate(e)
  if d == "" and fixing() { return none }
  (c: "(" + d + ")", p: false)
}
#let blx-date-ifmonth(e) = if blx-date-parts(e).month != none { blx-date-macro(e) } else { none }
#let blx-year-macro(e) = {
  let p = blx-date-parts(e)
  if p.start-open { return (c: "", p: true) }
  if p.year == none { (c: "[n. d.]", p: true) } else { (c: blx-year-digits(p.year), p: false) }
}
#let blx-labeldate(e, suffix: "") = {
  let d = blx-printdate(e)
  if d == "" { (c: "N.d." + suffix, p: suffix == "") } else { (c: d + suffix, p: false) }
}
#let blx-lead-date(e, style: "numeric", suffix: "") = {
  if style == "author-year" { blx-labeldate(e, suffix: suffix) } else { blx-year-macro(e) }
}

#let blx-punctuated(raw) = {
  let t = blx-visible-tail(raw)
  t != "" and t.last() in (".", "!", "?", ":", ";", ",")
}
#let blx-booktitle(e, with-in: false, style: "numeric", volume-tail: true) = {
  let pre = if not with-in { [] } else if style == "author-year" { [In: ] } else { [In ] }
  let has-book = has(e, "booktitle") or has(e, "booksubtitle") or has(e, "booktitleaddon")
  if not has-book {
    if not with-in { return none }
    return (c: if style == "author-year" { [In:] } else { [In] }, p: true, ends-colon: true)
  }
  let inner = ""
  if has(e, "booktitle") { inner = fld(e, "booktitle") }
  if has(e, "booksubtitle") {
    if inner != "" { inner += if blx-punctuated(inner) { " " } else { ". " } }
    inner += fld(e, "booksubtitle")
  }
  let c = if inner == "" { [] } else { it(render(inner)) }
  // The ACM booktitle macro supplies no separator before booktitleaddon.
  let last = inner
  if has(e, "booktitleaddon") {
    c += render(fld(e, "booktitleaddon"))
    last = fld(e, "booktitleaddon")
  }
  if volume-tail {
    if has(e, "series") {
      c += " (" + render(fld(e, "series")) + ")"
      last = "(" + fld(e, "series") + ")"
    }
    if has(e, "number") {
      c += " " + render(fld(e, "number"))
      last = fld(e, "number")
    }
    if articleno-of(e) != none {
      c += " Article " + articleno-of(e)
      last = articleno-of(e)
    }
  }
  (c: pre + c, p: blx-punctuated(last), sentence-punct: true)
}
#let blx-booktitle-simple(e, with-in: false, style: "numeric") = blx-booktitle(
  e, with-in: with-in, style: style, volume-tail: false)
#let blx-title-format(e, style: "numeric") = {
  let t = e.entry-type
  if style == "author-year" {
    if t in ("article", "inbook", "incollection", "inproceedings", "conference",
             "patent", "thesis", "mastersthesis", "phdthesis", "unpublished") {
      "quoted"
    } else { "emph" }
  } else {
    if t in ("book", "collection", "inbook", "manual", "thesis", "mastersthesis",
             "phdthesis", "proceedings") {
      "emph"
    } else { "plain" }
  }
}
#let blx-numeric-preserve-titlecase-types = (
  "book", "mvbook", "bookinbook", "booklet", "suppbook", "collection",
  "mvcollection", "suppcollection", "manual", "periodical", "suppperiodical",
  "proceedings", "mvproceedings", "reference", "mvreference", "report",
  "techreport", "thesis", "mastersthesis", "phdthesis",
)
#let blx-title-field(e, style: "numeric", format: auto, sentence: auto, omit-title: false) = {
  let use-title = has(e, "title") and not omit-title
  if not use-title and not has(e, "subtitle") and not has(e, "titleaddon") { return none }
  let sentence = if sentence == auto {
    style == "numeric" and e.entry-type not in blx-numeric-preserve-titlecase-types
  } else { sentence }
  // BibLaTeX applies title casing separately to title and subtitle.
  let cased = t => if sentence { blx-sentence-case(t) } else { t }
  let comps = ()
  if use-title { comps.push(cased(fld(e, "title"))) }
  if has(e, "subtitle") { comps.push(cased(fld(e, "subtitle"))) }
  let shown = ""
  for (i, comp) in comps.enumerate() {
    if i > 0 { shown += if blx-punctuated(comps.at(i - 1)) { " " } else { ". " } }
    shown += comp
  }
  let fmt = if format == auto { blx-title-format(e, style: style) } else { format }
  let p = blx-punctuated(shown)
  let out = if shown == "" { (c: [], p: false) } else if fmt == "quoted" {
    let inner = render(shown) + if p { [] } else { [.] }
    (c: "\u{201C}" + inner + "\u{201D}", p: true)
  } else if fmt == "emph" {
    (c: it(render(shown)), p: p)
  } else {
    (c: render(shown), p: p)
  }
  if not has(e, "titleaddon") { return out }
  let addon = fld(e, "titleaddon")
  if shown == "" { return (c: render(addon), p: blx-punctuated(addon)) }
  let joined = if out.p or blx-punctuated(shown) { " " } else { ". " }
  (c: out.c + joined + render(addon), p: blx-punctuated(addon))
}
#let blx-ordinal-edition(n) = {
  let suf = if n.ends-with("11") or n.ends-with("12") or n.ends-with("13") { "th" }
    else if n.ends-with("1") { "st" }
    else if n.ends-with("2") { "nd" }
    else if n.ends-with("3") { "rd" }
    else { "th" }
  n + suf
}
#let blx-edition(e) = if has(e, "edition") {
  let ed = fld(e, "edition")
  if ed.match(regex("^\d+$")) != none { (c: "(" + blx-ordinal-edition(ed) + " ed.)", p: false) }
  else { (c: "(" + render(ed) + " ed.)", p: false) }
} else { none }
// Type strings from english.lbx, with the ACM thesis and software overrides.
#let blx-type-strings = (
  bathesis: "BA thesis",
  mathesis: "Master\u{2019}s thesis",
  phdthesis: "Ph.D. Dissertation",
  candthesis: "Cand. thesis",
  resreport: "research rep.",
  techreport: "tech. rep.",
  software: "[SW]",
  datacd: "CD-ROM",
  audiocd: "audio CD",
  patent: "pat.",
  patentde: "German pat.",
  patenteu: "European pat.",
  patentfr: "French pat.",
  patentuk: "British pat.",
  patentus: "U.S. pat.",
  patreq: "pat. req.",
  patreqde: "German pat. req.",
  patreqeu: "European pat. req.",
  patreqfr: "French pat. req.",
  patrequk: "British pat. req.",
  patrequs: "U.S. pat. req.",
)
#let blx-type(e) = if has(e, "type") {
  let raw = fld(e, "type")
  let s = blx-type-strings.at(lower(raw.trim()), default: none)
  if s == none { V(raw) }
  else { (c: upper(s.first()) + s.slice(1), p: blx-ends-punct(s)) }
} else { none }
#let blx-pages(e) = {
  if has(e, "pages") { (c: dashify(fld(e, "pages")), p: false) }
  else if has(e, "numpages") { (c: fld(e, "numpages") + " pages", p: false) }
  else { none }
}
#let blx-chapter-pages(e) = {
  let ch = if has(e, "chapter") { render(fld(e, "chapter")) } else { none }
  let pg = blx-pages(e)
  if ch != none and pg != none { (c: "Chap. " + ch + ", " + pg.c, p: false) }
  else if ch != none { (c: "Chap. " + ch, p: false) }
  else { pg }
}
#let blx-series-number(e, style: "numeric", lower-strings: false, emph-cond: false) = {
  if not has(e, "series") and not has(e, "number") { return none }
  let series = if has(e, "series") {
    let emph-types = ("book", "inproceedings", "conference", "proceedings")
    let emphasized = style == "numeric" and e.entry-type in emph-types and (not emph-cond or has(e, "volume"))
    if emphasized {
      it(render(fld(e, "series")))
    } else {
      render(fld(e, "series"))
    }
  } else { none }
  if style == "numeric" {
    // The entry-specific number format overrides ACM's generic format (trad-standard.bbx, \series+number).
    let num = if has(e, "number") {
      let n = render(fld(e, "number"))
      if e.entry-type in ("book", "incollection", "inproceedings", "conference", "proceedings") {
        (if lower-strings { "number " } else { "Number " }) + n
      } else { n }
    }
    if has(e, "series") and has(e, "number") {
      (c: num + " in " + series, p: blx-punctuated(fld(e, "series")))
    } else if has(e, "number") {
      (c: num, p: blx-punctuated(fld(e, "number")))
    } else {
      (c: series, p: blx-ends-punct(fld(e, "series")))
    }
  } else {
    let c = []
    let last = ""
    if has(e, "series") { c += series; last = fld(e, "series") }
    if has(e, "number") {
      if c != [] { c += " " }
      c += render(fld(e, "number"))
      last = fld(e, "number")
    }
    (c: c, p: blx-ends-punct(last))
  }
}
#let blx-volumes(e) = if has(e, "volumes") {
  (c: render(fld(e, "volumes")) + " vols.", p: true)
} else { none }
#let blx-bookauthor(e) = if has(e, "bookauthor") and fld(e, "bookauthor") != fld(e, "author", d: "\u{0}") {
  if "bookauthor" in e.names {
    let raw = blx-join-names(e.names.bookauthor)
    (c: render(raw), p: blx-ends-punct(raw))
  }
  else { V(fld(e, "bookauthor")) }
} else { none }
#let blx-publisher-location-date(e) = {
  let parts = ()
  if has(e, "publisher") { parts.push(blx-list-content(fld(e, "publisher"))) }
  if has(e, "location") { parts.push(blx-list-content(fld(e, "location"))) }
  let d = blx-date-ifmonth(e)
  if d != none { parts.push(d.c) }
  let raw = ()
  if has(e, "publisher") { raw.push(blx-list-last(fld(e, "publisher"))) }
  if has(e, "location") { raw.push(blx-list-last(fld(e, "location"))) }
  if d != none { raw.push(d.c) }
  if parts.len() == 0 { none } else { (c: parts.join(", "), p: blx-ends-punct(raw.join(", "))) }
}
#let blx-organization-location-date(e) = {
  let loc = if has(e, "location") { fld(e, "location") }
  let c = []
  let last = ""
  if loc != none {
    c += blx-list-content(loc)
    last = blx-list-last(loc)
  }
  if has(e, "organization") {
    if c != [] { c += ": " }
    c += blx-list-content(fld(e, "organization"))
    last = blx-list-last(fld(e, "organization"))
  }
  let d = blx-date-macro(e)
  if d == none { return if c == [] { none } else { (c: c, p: blx-ends-punct(last)) } }
  if c != [] { c += ", " }
  (c: c + d.c, p: false)
}
#let blx-pages-unit(e) = {
  let pg = blx-chapter-pages(e)
  if pg == none { return () }
  if has(e, "chapter") { return (pg,) }
  ((c: pg.c, p: pg.p, join: "comma"),)
}
#let blx-field-date(e, name) = {
  if not has(e, name) { return "" }
  let halves = fld(e, name).trim().split("/")
  if halves.len() > 2 { return "" }
  let head = halves.first().trim()
  let start = blx-iso-parts(head)
  if head != "" and start.year == none { return "" }
  let tail = if halves.len() > 1 { halves.at(1).trim() } else { none }
  let far = if tail != none and tail != "" { blx-iso-parts(tail) } else { blx-no-date-parts }
  let use-end = tail != none and tail != "" and far.year != none and not far.span
  let open-end = tail == "" and start.year != none
  if start.year == none and far.year == none { return "" }
  blx-render-date((
    year: start.year, month: start.month, day: start.day,
    end-year: if start.span { start.end-year } else if use-end { far.year } else { none },
    end-month: if start.span { start.end-month } else if use-end { far.month } else { none },
    end-day: if start.span { start.end-day } else if use-end { far.day } else { none },
    open: open-end,
    start-open: start.year == none and far.year != none,
  ))
}

// Pages alone supply \bibpagespunct, overriding the pending block break; a chapter consumes that break first.
#let blx-publisher-pages(e) = {
  let pub = blx-publisher-location-date(e)
  let pg = blx-chapter-pages(e)
  if pg == none { return (pub,) }
  if has(e, "chapter") { return (pub, pg) }
  if pub == none { return ((c: pg.c, p: pg.p, join: "comma"),) }
  ((c: pub.c + ", " + pg.c, p: false),)
}
#let blx-volume(e) = if has(e, "volume") { (c: "Vol. " + fld(e, "volume"), p: false) } else { none }
#let blx-ed-by(e, sentence-start: true) = if has(e, "editor") {
  let raw = blx-join-names(e.names.editor)
  (c: (if sentence-start { "Ed. by " } else { "ed. by " }) + render(raw), p: blx-ends-punct(raw))
} else { none }
#let blx-editor-block(e, style: "numeric", sentence-start: true) = if not has(e, "editor") {
  none
} else if style == "author-year" {
  blx-ed-by(e, sentence-start: sentence-start)
} else {
  let suffix = if e.names.editor.len() > 1 { ", (Eds.)" } else { ", (Ed.)" }
  (c: render(blx-join-names(e.names.editor)) + suffix, p: true)
}
#let blx-bytranslator(e) = if has(e, "translator") {
  let raw = blx-join-names(e.names.translator)
  (c: "Trans. by " + render(raw), p: blx-ends-punct(raw))
} else { none }
// BibLaTeX clears an editor list used in the opening attribution.
// The translator cannot lead because usetranslator is off.
#let blx-editor-others(e, style: "numeric", sentence-start: true, editor: true) = {
  let ed = if editor { blx-editor-block(e, style: style, sentence-start: sentence-start) }
  let tr = blx-bytranslator(e)
  if ed == none { return tr }
  if tr == none { return ed }
  (c: ed.c + (if ed.p { " " } else { ". " }) + tr.c, p: tr.p)
}
#let blx-isbn(e) = if has(e, "isbn") { (c: "isbn: " + fld(e, "isbn"), p: false) } else { none }
#let blx-journal-title(e) = if has(e, "journaltitle") { fld(e, "journaltitle") } else { none }
#let blx-journal(e) = {
  let jt = blx-journal-title(e)
  if jt == none { return none }
  let parts = (it(render(jt)),)
  if has(e, "series") { parts.push(render(fld(e, "series"))) }
  if has(e, "volume") { parts.push(fld(e, "volume")) }
  if has(e, "number") { parts.push(fld(e, "number")) }
  if has(e, "articleno") { parts.push("Article " + fld(e, "articleno").replace("~", " ")) }
  let d = blx-date-ifmonth(e)
  if d != none { parts.push(d.c) }
  if has(e, "eid") { parts.push(fld(e, "eid")) }
  let pg = blx-pages(e)
  if pg != none { parts.push(pg.c) }
  (c: parts.join(", "), p: false)
}
#let blx-periodical-journal(e) = {
  let jt = blx-journal-title(e)
  if jt == none { return none }
  let c = it(render(jt))
  if has(e, "volume") { c += " " + fld(e, "volume") }
  if has(e, "number") { c += ", " + fld(e, "number") }
  let d = blx-date-ifmonth(e)
  if d != none { c += " " + d.c }
  (c: c, p: false)
}
#let blx-note(e) = if has(e, "note") { V(fld(e, "note")) } else { none }
#let blx-url-urldate(e) = {
  let u = if has(e, "url") { fld(e, "url") } else if has(e, "urls") { fld(e, "urls") } else { none }
  if u == none { return none }
  let c = if has(e, "lastaccessed") { [Retrieved #render(fld(e, "lastaccessed")) from #link(u)[#u]] } else { link(u)[#u] }
  (c: c, p: false)
}
#let blx-eprint(e) = if has(e, "eprint") {
  let ep = fld(e, "eprint")
  let prefix = fld(e, "eprinttype", d: "arXiv")
  let arxiv = lower(prefix) == "arxiv"
  let cls = if not has(e, "eprintclass") { "" }
    else if arxiv { " [" + fld(e, "eprintclass") + "]" }
    else { " (" + fld(e, "eprintclass") + ")" }
  let num = if arxiv { link("https://arxiv.org/abs/" + ep)[#ep] } else { link(ep)[#ep] }
  (c: prefix + ": " + num + cls, p: false)
} else { none }
// The BibLaTeX DOI format prepends the resolver even when the field already contains a URL.
#let blx-doi(e) = if has(e, "doi") {
  let raw = fld(e, "doi")
  let d = if fixing() { normalize-doi(raw) } else { raw }
  (c: link("https://doi.org/" + d)[doi:#d], p: false)
} else { none }
#let blx-tail(e) = {
  let items = ()
  let distinct-url = has(e, "distincturl") and fld(e, "distincturl") != "0"
  let u = if (not has(e, "doi")) or distinct-url { blx-url-urldate(e) } else { none }
  let ep = blx-eprint(e)
  // A literal newline in ACM's url+urldate branch emits a space and consumes the pending \newunit before the eprint.
  if u != none { items.push(if ep == none { u } else { u + (p: true) }) }
  if ep != none { items.push(ep) }
  let doi = blx-doi(e)
  if doi != none { items.push(doi) }
  items
}

#let blx-person-label(e, editor-ok: true, org-ok: true, key-ok: true) = {
  if has(e, "author") {
    let raw = blx-join-names(e.names.author)
    return (c: render(raw), kind: "author", dot: blx-ends-punct(raw))
  }
  if editor-ok and has(e, "editor") {
    let suffix = if e.names.editor.len() > 1 { ", (Eds.)" } else { ", (Ed.)" }
    return (c: render(blx-join-names(e.names.editor)) + suffix, kind: "editor", dot: true)
  }
  if org-ok and has(e, "organization") {
    let org = blx-list-value(fld(e, "organization"))
    return (c: org.c, kind: "organization", dot: org.p)
  }
  if key-ok and has(e, "key") { return (c: render(fld(e, "key")), kind: "key", dot: false) }
  none
}
#let blx-lead(e, style: "numeric", suffix: "", editor-ok: true, org-ok: true, key-ok: true,
              editor-others: false) = {
  let who = blx-person-label(e, editor-ok: editor-ok, org-ok: org-ok, key-ok: key-ok)
  let dt = blx-lead-date(e, style: style, suffix: suffix)
  if who == none { return if style == "numeric" { dt } else { none } }
  // acmauthoryear inserts a literal period even after punctuation.
  // Its editor+others macro also emits a newline space before date+extradate.
  let sep = if style == "numeric" or fixing() { if who.dot { " " } else { ". " } }
    else if editor-others and who.kind != "author" { " . " }
    else { ". " }
  (c: who.c + sep + dt.c, p: dt.p)
}
// ACM's inbook drivers use \iffieldundef for the author name list, so they always select the editor branch.
#let blx-inbook-author-led(e) = has(e, "author") and fixing()
#let blx-inbook-lead(e, style: "numeric", suffix: "") = {
  if blx-inbook-author-led(e) {
    return blx-lead(e, style: style, suffix: suffix, editor-ok: false, org-ok: false, key-ok: false)
  }
  let ed = blx-editor-others(e, style: style)
  if ed == none { return if style == "numeric" { blx-year-macro(e) } else { none } }
  if style != "numeric" { return ed }
  let dt = blx-year-macro(e)
  (c: ed.c + (if ed.p { " " } else { ". " }) + dt.c, p: dt.p)
}
#let blx-nonempty(v) = v != none and v.c != none and v.c != [] and v.c != ""
#let blx-blocks(..vals) = {
  let pieces = vals.pos().filter(blx-nonempty)
  let out = []
  for (i, v) in pieces.enumerate() {
    // BibLaTeX distinguishes abbreviation dots from sentence punctuation when deciding whether a comma survives.
    let prev = if i == 0 { none } else { pieces.at(i - 1) }
    let after-stop = prev != none and (prev.at("ends-colon", default: false)
      or (prev.p and prev.at("sentence-punct", default: false)))
    let join = if i == 0 { none } else if after-stop and v.at("join", default: none) == "comma" {
      "space"
    } else { v.at("join", default: none) }
    if i > 0 { out += if join == "comma" { ", " } else { " " } }
    out += v.c
    let next-join = if i + 1 < pieces.len() and not v.at("ends-colon", default: false) {
      pieces.at(i + 1).at("join", default: none)
    } else { none }
    if not v.p and next-join == none { out += "." }
  }
  out
}
#let blx-version(e) = if has(e, "version") {
  (c: "Version " + render(fld(e, "version")), p: false)
} else { none }

// The translator fallback prevents these drivers from reaching the organization fallback in editor+others.
#let blx-misc-lead(e, style: "numeric", suffix: "") = blx-lead(
  e, style: style, suffix: suffix, org-ok: false, key-ok: false, editor-others: true)

#let blx-author-lead(e, style: "numeric", suffix: "") = blx-lead(
  e, style: style, suffix: suffix, editor-ok: false, org-ok: false, key-ok: false)

// The article driver prints and clears the translator before reaching byeditor+others.
#let blx-article-like(e, style: "numeric", suffix: "") = blx-blocks(
  blx-author-lead(e, style: style, suffix: suffix),
  blx-title-field(e, style: style),
  blx-bytranslator(e),
  blx-version(e),
  blx-journal(e),
  blx-editor-block(e, style: style),
  blx-note(e),
  ..blx-tail(e),
)
#let blx-inproceedings(e, style: "numeric", suffix: "") = {
  blx-blocks(
    blx-author-lead(e, style: style, suffix: suffix),
    blx-title-field(e, style: style),
    blx-booktitle(e, with-in: true, style: style),
    blx-editor-others(e, style: style, sentence-start: has(e, "booktitle")),
    blx-volume(e),
    blx-list-field(e, "organization"),
    ..blx-publisher-pages(e),
    blx-isbn(e),
    ..blx-tail(e),
  )
}
#let blx-incollection(e, style: "numeric", suffix: "") = blx-blocks(
  blx-author-lead(e, style: style, suffix: suffix),
  blx-title-field(e, style: style),
  blx-booktitle-simple(e, with-in: true, style: style),
  blx-series-number(e, style: style),
  blx-edition(e),
  blx-volume(e),
  blx-volumes(e),
  blx-editor-others(e, style: style, sentence-start: has(e, "booktitle")),
  blx-note(e),
  ..blx-publisher-pages(e),
  blx-isbn(e),
  ..blx-tail(e),
)
#let blx-inbook(e, style: "numeric", suffix: "") = {
  let lead = blx-inbook-lead(e, style: style, suffix: suffix)
  blx-blocks(
    lead,
    blx-title-field(e, style: style),
    blx-bookauthor(e),
    blx-booktitle-simple(e, with-in: false, style: style),
    if blx-inbook-author-led(e) { blx-editor-others(e, style: style) },
    blx-edition(e),
    blx-volume(e),
    blx-volumes(e),
    blx-series-number(e, style: style),
    blx-note(e),
    ..blx-publisher-pages(e),
    blx-isbn(e),
    ..blx-tail(e),
  )
}
#let blx-event(e) = {
  let head = ()
  for name in ("eventtitle", "eventtitleaddon") {
    if has(e, name) { head.push((raw: fld(e, name), c: render(fld(e, name)))) }
  }
  let inner = ()
  if has(e, "venue") { inner.push(render(fld(e, "venue"))) }
  let d = blx-field-date(e, "eventdate")
  if d != "" { inner.push(d) }
  if head.len() == 0 and inner.len() == 0 { return none }
  let c = []
  for (i, h) in head.enumerate() {
    if i > 0 { c += if blx-punctuated(head.at(i - 1).raw) { " " } else { ". " } }
    c += h.c
  }
  let bare = head.len() == 0
  if inner.len() > 0 {
    if c != [] { c += " " }
    c += "(" + inner.join(", ") + ")"
  }
  let ends = if inner.len() > 0 or head.len() == 0 { false } else {
    blx-punctuated(head.last().raw)
  }
  if bare { return (c: c, p: ends, join: "space") }
  (c: c, p: ends)
}
#let blx-volume-part(e, lower-case: false) = {
  let vol = if has(e, "volume") {
    (if lower-case { "vol. " } else { "Vol. " }) + render(fld(e, "volume"))
  } else { none }
  let part = if has(e, "part") { "." + render(fld(e, "part")) } else { none }
  if vol == none and part == none { return none }
  (c: (if vol == none { [] } else { vol }) + (if part == none { [] } else { part }), p: false)
}
#let blx-pagetotal(e) = if has(e, "pagetotal") {
  let raw = fld(e, "pagetotal").trim()
  if raw.match(regex("^\\d+$")) == none { return (c: render(fld(e, "pagetotal")), p: false) }
  (c: render(fld(e, "pagetotal")) + (if int(raw) == 1 { " p." } else { " pp." }), p: true)
} else { none }
#let blx-organization-list(e) = blx-list-field(e, "organization")
// Pending separators survive empty stages; the last one wins.
// A starred \newcommaunit applies only after a stage that printed.
#let blx-units(..stages) = {
  let out = []
  let pending = none
  let pending-starred = false
  let emitted = false
  let last-punct = false
  for stage in stages.pos() {
    let (sep, v) = (stage.at(0), stage.at(1))
    let starred = stage.len() > 2 and stage.at(2)
    if not (starred and not emitted) { pending = sep; pending-starred = starred }
    emitted = false
    if not blx-nonempty(v) { continue }
    if out != [] {
      // A starred unit bypasses the usual punctuation suppression.
      let own = v.at("join", default: none)
      out += if own == "space" { " " }
        else if own == "comma" { ", " }
        else if pending == "." and not last-punct { ". " }
        else if pending == "," and (pending-starred or not last-punct) { ", " }
        else { " " }
    }
    out += v.c
    last-punct = v.p
    emitted = true
    pending = none
  }
  if out == [] { none } else { (c: out, p: last-punct) }
}
#let blx-maintitle-same(e) = {
  has(e, "maintitle") and has(e, "title") and fld(e, "maintitle") == fld(e, "title")
}
#let blx-maintitle-takes-volume(e) = has(e, "maintitle") and not blx-maintitle-same(e)
#let blx-maintitle-title(e, style: "numeric") = {
  let title = blx-title-field(e, style: style)
  if not has(e, "maintitle") or blx-maintitle-same(e) { return title }
  let main = fld(e, "maintitle")
  let last = main
  if has(e, "mainsubtitle") {
    main += (if blx-punctuated(main) { " " } else { ". " }) + fld(e, "mainsubtitle")
    last = fld(e, "mainsubtitle")
  }
  let c = it(render(main))
  if has(e, "maintitleaddon") {
    c += (if blx-punctuated(last) { " " } else { ". " }) + render(fld(e, "maintitleaddon"))
    last = fld(e, "maintitleaddon")
  }
  let vol = if has(e, "volume") { blx-volume-part(e) }
  if vol != none {
    c += (if blx-punctuated(last) { " " } else { ". " }) + vol.c
    last = fld(e, "volume")
  }
  if title == none { return (c: c, p: blx-punctuated(last)) }
  let join = if vol != none { ": " } else if blx-punctuated(last) { " " } else { ". " }
  (c: c + join + title.c, p: title.p)
}
#let blx-proceedings(e, style: "numeric", suffix: "") = {
  if style != "numeric" {
    return blx-blocks(
      blx-misc-lead(e, style: style, suffix: suffix),
      blx-maintitle-title(e, style: style),
      if has(e, "language") { blx-language-value(fld(e, "language")) },
      blx-event(e),
      blx-editor-others(e, style: style, editor: has(e, "author")),
      if not blx-maintitle-takes-volume(e) { blx-volume-part(e) },
      blx-volumes(e),
      blx-series-number(e, style: style),
      blx-note(e),
      blx-organization-list(e),
      blx-publisher-location-date(e),
      ..blx-pages-unit(e),
      blx-pagetotal(e),
      blx-isbn(e),
      ..blx-tail(e),
    )
  }
  let vol = if blx-maintitle-takes-volume(e) { none } else { blx-volume-part(e, lower-case: true) }
  let ser = blx-series-number(e, style: style, lower-strings: true, emph-cond: true)
  let series-vol = if vol != none and ser != none { (c: vol.c + " of " + ser.c, p: false) }
    else if vol != none { vol } else { ser }
  let pages = blx-pages-unit(e)
  let location = if has(e, "location") { blx-list-value(fld(e, "location")) }
  let publisher = if has(e, "publisher") {
    (c: blx-list-content(fld(e, "publisher")), p: blx-punctuated(blx-list-last(fld(e, "publisher"))))
  }
  let run = blx-units(
    (none, blx-editor-block(e, style: style)),
    (" ", blx-maintitle-title(e, style: style)),
    (".", if has(e, "language") { blx-language-value(fld(e, "language")) }),
    (".", if has(e, "eventtitle") or has(e, "venue") or blx-field-date(e, "eventdate") != "" {
      blx-event(e)
    }),
    (".", blx-bytranslator(e)),
    (",", series-vol),
    (",", blx-volumes(e)),
    (".", location),
    (",", blx-edition(e)),
    (",", blx-date-macro(e)),
    (".", blx-organization-list(e)),
    (",", publisher, true),
    (if has(e, "chapter") { "." } else { "," }, if pages.len() > 0 { pages.first() }),
    (".", blx-pagetotal(e)),
  )
  blx-blocks(run, blx-isbn(e), ..blx-tail(e), blx-note(e))
}
#let blx-book-like(e, style: "numeric", suffix: "") = blx-blocks(
  blx-misc-lead(e, style: style, suffix: suffix),
  blx-title-field(e, style: style),
  blx-editor-others(e, style: style, editor: has(e, "author")),
  blx-edition(e),
  blx-series-number(e, style: style),
  blx-volume(e),
  blx-volumes(e),
  blx-note(e),
  ..blx-publisher-pages(e),
  blx-isbn(e),
  ..blx-tail(e),
)
#let blx-misc(e, style: "numeric", suffix: "") = blx-blocks(
  blx-misc-lead(e, style: style, suffix: suffix),
  blx-title-field(e, style: style),
  blx-editor-others(e, style: style, editor: has(e, "author")),
  fV(e, "howpublished"),
  blx-type(e),
  blx-version(e),
  blx-note(e),
  blx-organization-location-date(e),
  ..blx-tail(e),
)

#let blx-online(e, style: "numeric", suffix: "") = blx-blocks(
  blx-misc-lead(e, style: style, suffix: suffix),
  blx-title-field(e, style: style),
  blx-editor-others(e, style: style, editor: has(e, "author")),
  blx-version(e),
  blx-note(e),
  blx-list-field(e, "organization"),
  blx-date-ifmonth(e),
  blx-eprint(e),
  blx-url-urldate(e),
)

#let blx-manual(e, style: "numeric", suffix: "") = blx-blocks(
  blx-lead(e, style: style, suffix: suffix, key-ok: false, editor-others: true),
  blx-title-field(e, style: style),
  blx-edition(e),
  blx-series-number(e, style: style),
  blx-type(e),
  blx-version(e),
  blx-note(e),
  blx-list-field(e, "organization"),
  blx-publisher-location-date(e),
  blx-chapter-pages(e),
  blx-isbn(e),
  ..blx-tail(e),
)
// dataset inherits standard.bbx and never calls the numeric ACM year macro.
#let blx-dataset(e, style: "numeric", suffix: "") = {
  let lead = if style == "author-year" {
    blx-misc-lead(e, style: style, suffix: suffix)
  } else {
    let who = blx-person-label(e, org-ok: false, key-ok: false)
    if who != none { (c: who.c, p: who.dot) }
  }
  blx-blocks(
    lead,
    blx-title-field(e, style: style),
    blx-editor-others(e, style: style, editor: has(e, "author")),
    blx-type(e),
    blx-edition(e),
    blx-version(e),
    blx-series-number(e, style: style),
    blx-note(e),
    blx-list-field(e, "organization"),
    blx-publisher-location-date(e),
    ..blx-tail(e),
  )
}
#let blx-institution-location(e) = {
  let parts = ()
  for v in (blx-list-field(e, "institution"),
            blx-list-field(e, "location"),
            blx-date-ifmonth(e)) {
    if v != none { parts.push(v.c) }
  }
  if parts.len() == 0 { none } else { (c: parts.join(", "), p: false) }
}
#let blx-labeltitle-lead(lead, title, e, style: "numeric", suffix: "") = {
  if style != "author-year" or lead != none { return (lead, title) }
  let explicit = has(e, "label")
  let short = has(e, "shorttitle")
  let raw = if explicit { fld(e, "label") } else if short { fld(e, "shorttitle") } else if has(e, "title") { fld(e, "title") } else { "" }
  if raw == "" { return (lead, title) }
  let fmt = if explicit { "plain" } else { blx-title-format(e, style: style) }
  let head = if fmt == "quoted" { "\u{201C}" + render(raw) + ". \u{201D}" }
    else if fmt == "emph" { it(render(raw)) + ". " }
    else { render(raw) + ". " }
  let dt = blx-labeldate(e, suffix: suffix)
  ((c: head + dt.c, p: dt.p), blx-title-field(e, style: style, omit-title: not (explicit or short)))
}
#let blx-report(e, style: "numeric", suffix: "", thesis: false) = {
  let ty = blx-type(e)
  if ty != none and not thesis and has(e, "number") {
    ty = (c: ty.c + " " + render(fld(e, "number")), p: false)
  }
  let (lead, title) = blx-labeltitle-lead(
    blx-lead(e, style: style, suffix: suffix, editor-ok: false, org-ok: false),
    blx-title-field(e, style: style), e, style: style, suffix: suffix)
  blx-blocks(
    lead,
    title,
    ty,
    if not thesis { blx-version(e) },
    blx-institution-location(e),
    blx-note(e),
    blx-chapter-pages(e),
    ..blx-tail(e),
  )
}

#let blx-patent(e, style: "numeric", suffix: "") = {
  let locations = if has(e, "location") {
    split-list-and(fld(e, "location"), trim: true, filter-empty: true).map(render).join(", ")
  } else { none }
  let identification = []
  let ty = blx-type(e)
  if ty != none { identification += ty.c }
  if has(e, "number") {
    if identification != [] { identification += " " }
    identification += "Patent No. " + render(fld(e, "number"))
  }
  if locations != none and locations != [] {
    identification += " (" + locations + ")"
  }
  let holder = if has(e, "holder") {
    let raw = blx-join-names(e.names.holder)
    (c: render(raw), p: blx-ends-punct(raw))
  } else { none }
  let (lead, title) = blx-labeltitle-lead(
    blx-lead(e, style: style, suffix: suffix, editor-ok: false, org-ok: false, key-ok: false),
    blx-title-field(e, style: style), e, style: style, suffix: suffix)
  blx-blocks(
    lead,
    title,
    blx-date-macro(e),
    if identification == [] { none } else { (c: identification, p: false) },
    holder,
    blx-note(e),
    ..blx-tail(e),
  )
}

#let blx-software-types = ("software", "softwareversion", "softwaremodule", "codefragment")
#let blx-software-labels = (
  software: "[SW]",
  softwareversion: "[SW Rel.]",
  softwaremodule: "[SW Mod.]",
  codefragment: "[SW exc.]",
)

// Driver sourcemaps preserve the original report/thesis type as a localized type field.
#let blx-typed-remaps = (
  techreport: "techreport", phdthesis: "phdthesis", mastersthesis: "mathesis",
)
#let blx-name-roles = ("author", "editor", "bookauthor", "translator", "holder", "sortname")
// Rename aliases before inheritance so a child's legacy field blocks the parent's canonical field.
#let blx-type-aliases = (conference: "inproceedings", electronic: "online", www: "online")
#let blx-field-aliases = (
  hyphenation: "langid", address: "location", school: "institution",
  annote: "annotation", archiveprefix: "eprinttype", journal: "journaltitle",
  primaryclass: "eprintclass", key: "sortkey", pdf: "file",
)
#let blx-acm-sourcemap(db) = {
  let out = (:)
  for (k, e0) in db {
    let e = e0
    if e.entry-type in blx-typed-remaps and not has(e, "type") {
      e.fields.insert("type", blx-typed-remaps.at(e.entry-type))
    }
    if e.entry-type == "techreport" { e = e + (entry-type: "report") }
    else if e.entry-type == "artifactsoftware" { e = e + (entry-type: "software") }
    else if e.entry-type == "artifactdataset" { e = e + (entry-type: "dataset") }
    else if e.entry-type in blx-type-aliases {
      e = e + (entry-type: blx-type-aliases.at(e.entry-type))
    }
    // Biber drops the legacy day field; only a parsed date can supply day precision.
    if "day" in e.fields { let _ = e.fields.remove("day") }
    for (alias, canonical) in blx-field-aliases {
      if alias in e.fields {
        let v = e.fields.at(alias)
        let _ = e.fields.remove(alias)
        if canonical not in e.fields {
          e.fields.insert(canonical, v)
          if canonical in blx-name-roles { e.names.insert(canonical, parse-names(v)) }
        }
        if alias in e.names { let _ = e.names.remove(alias) }
      }
    }
    // Empty fields decide alias precedence above, but must not block inheritance below.
    for (name, value) in e.fields {
      if value.trim() == "" {
        let _ = e.fields.remove(name)
        if name in e.names { let _ = e.names.remove(name) }
      }
    }
    out.insert(k, e)
  }
  out
}

#let blx-software-sourcemap-entry(e) = {
  if has(e, "swhid") {
    let clean = fld(e, "swhid").replace(regex("\s+"), "")
    e.fields.insert("swhid", clean)
    if not has(e, "swhidcore") {
      e.fields.insert("swhidcore", clean.split(";").at(0))
    }
  }
  e
}

// A parsed date's empty components block inheritance; an invalid date leaves components inheritable.
#let blx-fill-date-fields(e) = {
  let p = blx-date-parts(e)
  if not p.parsed { return e }
  // An open end needs its own marker to distinguish it from a date without a range.
  for (name, value) in (
    ("year", p.year), ("month", p.month), ("day", p.day),
    ("endyear", p.end-year), ("endmonth", p.end-month), ("endday", p.end-day),
  ) {
    e.fields.insert(name, if value == none { "" } else { value })
  }
  e.fields.insert("endyearunknown", if p.open { "1" } else { "" })
  e
}

#let blx-inherit-skip = (
  "ids", "crossref", "xref", "entryset", "entrysubtype", "execute", "label",
  "options", "presort", "related", "relatedoptions", "relatedstring",
  "relatedtype", "shorthand", "shorthandintro", "sortkey",
  "date",
)
#let blx-title-skip = ("shorttitle", "sorttitle", "indextitle", "indexsorttitle")
#let blx-inherit-rules = (
  (from: ("mvbook", "book"), to: ("inbook", "bookinbook", "suppbook"),
   map: (("author", "author"), ("author", "bookauthor")), skip: ()),
  (from: ("mvbook",), to: ("book", "inbook", "bookinbook", "suppbook"),
   map: (("title", "maintitle"), ("subtitle", "mainsubtitle"),
         ("titleaddon", "maintitleaddon")), skip: blx-title-skip),
  (from: ("mvcollection", "mvreference"),
   to: ("collection", "reference", "incollection", "inreference", "suppcollection"),
   map: (("title", "maintitle"), ("subtitle", "mainsubtitle"),
         ("titleaddon", "maintitleaddon")), skip: blx-title-skip),
  (from: ("mvproceedings",), to: ("proceedings", "inproceedings"),
   map: (("title", "maintitle"), ("subtitle", "mainsubtitle"),
         ("titleaddon", "maintitleaddon")), skip: blx-title-skip),
  (from: ("book",), to: ("inbook", "bookinbook", "suppbook"),
   map: (("title", "booktitle"), ("subtitle", "booksubtitle"),
         ("titleaddon", "booktitleaddon")), skip: blx-title-skip),
  (from: ("collection", "reference"), to: ("incollection", "inreference", "suppcollection"),
   map: (("title", "booktitle"), ("subtitle", "booksubtitle"),
         ("titleaddon", "booktitleaddon")), skip: blx-title-skip),
  (from: ("proceedings",), to: ("inproceedings",),
   map: (("title", "booktitle"), ("subtitle", "booksubtitle"),
         ("titleaddon", "booktitleaddon")), skip: blx-title-skip),
  (from: ("periodical",), to: ("article", "suppperiodical"),
   map: (("title", "journaltitle"), ("subtitle", "journalsubtitle"),
         ("titleaddon", "journaltitleaddon")), skip: blx-title-skip),
)
#let blx-inherit-field(e, name, value) = {
  if name in e.fields { return e }
  e.fields.insert(name, value)
  if name in blx-name-roles { e.names.insert(name, parse-names(value)) }
  e
}
#let blx-inherit-entry(db, key, seen: ()) = {
  let e = blx-fill-date-fields(blx-software-sourcemap-entry(db.at(key)))
  if not has(e, "crossref") { return e }
  let xr = fld(e, "crossref")
  if xr not in db or xr in seen { return e }
  let parent = blx-inherit-entry(db, xr, seen: seen + (key,))
  let processed = ()
  for rule in blx-inherit-rules {
    if parent.entry-type not in rule.from or e.entry-type not in rule.to { continue }
    for (source, target) in rule.map {
      if source not in parent.fields { continue }
      processed.push(source)
      e = blx-inherit-field(e, target, parent.fields.at(source))
    }
    for source in rule.skip {
      if source in parent.fields { processed.push(source) }
    }
  }
  for (fk, fv) in parent.fields {
    if fk in blx-inherit-skip or fk in processed { continue }
    e = blx-inherit-field(e, fk, fv)
  }
  e
}

#let blx-biber-datamodel(db) = {
  let mapped = blx-acm-sourcemap(db)
  let out = (:)
  for (k, e) in mapped {
    let r = blx-inherit-entry(mapped, k)
    out.insert(k, r)
  }
  out
}

}

#let blx-printlist(e, name) = if has(e, name) {
  (c: blx-list-content(fld(e, name)), p: false)
} else { none }

#let blx-sw-title(e, style) = {
  let t = render(fld(e, "title", d: ""))
  if style == "author-year" { it(t) } else { t }
}
#let blx-sw-version(e) = if has(e, "version") { " version " + render(fld(e, "version")) } else { [] }
#let blx-sw-date(e) = {
  let date = blx-printdate(e)
  if date == "" { [] }
  else if has(e, "version") or has(e, "editor") { ", " + date }
  else { " " + date }
}
#let blx-sw-editor(e) = if has(e, "editor") {
  [ (Coord.by #render(blx-join-names(e.names.editor)))]
} else { [] }

#let blx-sw-subtitle(e) = if has(e, "subtitle") {
  "\u{201C}" + render(fld(e, "subtitle")) + ",\u{201D}"
} else { [] }

#let blx-sw-title-macro(e, style, subtitle-join: none) = {
  let c = []
  if has(e, "author") { c += render(blx-join-names(e.names.author)) + ", " }
  if subtitle-join != none and has(e, "subtitle") { c += blx-sw-subtitle(e) + subtitle-join }
  c += blx-sw-title(e, style)
  c += blx-sw-version(e)
  c += blx-sw-editor(e)
  c += blx-sw-date(e)
  (c: c, p: false)
}

#let blx-sw-url(e) = if has(e, "url") {
  let u = fld(e, "url")
  (c: [url: #link(u)[#u]], p: false)
} else { none }
#let blx-sw-hal-id(e) = if has(e, "hal_id") {
  let id = fld(e, "hal_id") + fld(e, "hal_version", d: "")
  (c: [hal: #link("https://hal.archives-ouvertes.fr/" + id)[⟨#id⟩]], p: false)
} else { none }
#let blx-sw-repository(e) = if has(e, "repository") {
  let u = fld(e, "repository")
  (c: [vcs: #link(u)[#u]], p: false)
} else { none }
#let blx-sw-swhid(e) = if has(e, "swhid") {
  let id = fld(e, "swhid")
  (c: [swhid: #link("http://archive.softwareheritage.org/" + id)[⟨#id⟩]], p: false)
} else { none }

// The ACM styles disable the software license field.
#let blx-swids(e) = {
  let pieces = (
    blx-doi(e),
    blx-sw-hal-id(e),
    blx-eprint(e),
    blx-sw-url(e),
    blx-sw-repository(e),
    blx-sw-swhid(e),
  ).filter(blx-nonempty)
  if pieces.len() == 0 { return none }
  let c = []
  for (i, v) in pieces.enumerate() {
    if i > 0 { c += ", " }
    c += v.c
  }
  (c: c, p: false)
}

#let blx-software-driver(e, kind, style: "numeric") = {
  let body = blx-sw-title-macro(e, style, subtitle-join: if kind == "software" { none }
    else if kind == "codefragment" { " from " } else { " part of " })
  let labelled = (c: blx-software-labels.at(kind) + " " + body.c, p: body.p)
  blx-blocks(
    labelled,
    blx-printlist(e, "institution"),
    blx-printlist(e, "organization"),
    blx-swids(e),
  )
}

#let blx-handle(e, style: "numeric", year-suffix: "") = {
  let t = e.entry-type
  if t == "article" { blx-article-like(e, style: style, suffix: year-suffix) }
  else if t == "inproceedings" or t == "conference" { blx-inproceedings(e, style: style, suffix: year-suffix) }
  else if t == "incollection" { blx-incollection(e, style: style, suffix: year-suffix) }
  else if t == "inbook" { blx-inbook(e, style: style, suffix: year-suffix) }
  else if t == "proceedings" { blx-proceedings(e, style: style, suffix: year-suffix) }
  else if t == "book" or t == "collection" { blx-book-like(e, style: style, suffix: year-suffix) }
  else if t == "patent" { blx-patent(e, style: style, suffix: year-suffix) }
  else if t in blx-software-types { blx-software-driver(e, t, style: style) }
  else if t == "artifactdataset" or t == "dataset" { blx-dataset(e, style: style, suffix: year-suffix) }
  else if t == "online" or t == "www" or t == "electronic" { blx-online(e, style: style, suffix: year-suffix) }
  else if t == "manual" { blx-manual(e, style: style, suffix: year-suffix) }
  else if t == "mastersthesis" or t == "phdthesis" or t == "thesis" { blx-report(e, style: style, suffix: year-suffix, thesis: true) }
  else if t == "techreport" or t == "report" { blx-report(e, style: style, suffix: year-suffix) }
  else if t == "periodical" {
    blx-blocks(
      blx-lead(e, style: style, suffix: year-suffix),
      blx-title-field(e, style: style, sentence: false),
      blx-periodical-journal(e),
      blx-note(e),
      ..blx-tail(e),
    )
  }
  else { blx-misc(e, style: style, suffix: year-suffix) }
}

// Pack nty sort slots with NUL separators so a field sorts before its extension.
// Biber's final sortkey overrides all later slots.
#let blx-sort-slot-sep = "\u{0}"

// Retain braces until nosort has tested protected name parts (Biber Utils.pm, normalise_string_sort).
#let blx-sort-clean(s) = {
  let t = str.normalize(decode-chars(s), form: "nfd")
    .replace(regex("([^\\\\])~"), m => m.captures.at(0) + " ")
  t = t.replace(regex("\\p{M}+"), "")
  t = t.replace(regex("\\\\[A-Za-z]+([ \t\n\r]*)"), m => m.captures.at(0))
  t = t.replace(regex("\\\\['`^\"~=.][ \t\n\r]*"), "")
  t.replace(regex("\\\\(.)"), m => m.captures.at(0))
}
#let blx-sort-debrace(t) = t.replace(regex("[{}]+"), "").trim().replace(regex("\\s+"), " ")
#let blx-sort-normalize(s) = blx-sort-debrace(blx-sort-clean(s))
// Expand foreign letters after nosort, whose patterns count decoded letters.
#let blx-char-expansions = {
  let out = (:)
  for (name, expansion) in foreign-purify { out.insert(special-letters.at(name), expansion) }
  out
}
#let blx-expand-chars(t) = {
  t.clusters().map(c => blx-char-expansions.at(c, default: c)).fold("", (a, b) => a + b)
}

// Approximate collation with case-folded text, then an uppercase-first tie-break.
// Remap ASCII punctuation below digits and letters to preserve their collation classes.
#let blx-sort-punct = {
  let out = (:)
  for (i, c) in " !\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~".clusters().enumerate() {
    out.insert(c, str.from-unicode(2 + i))
  }
  out
}
#let blx-collate(t) = {
  let case-bit(c) = if c != lower(c) { "\u{0}" } else { "\u{1}" }
  let weigh(c) = blx-sort-punct.at(c, default: c)
  let primary = lower(t).clusters().map(weigh).fold("", (a, b) => a + b)
  primary + "\u{1}" + t.clusters().map(case-bit).fold("", (a, b) => a + b)
}
#let blx-sort-field(s) = blx-collate(blx-expand-chars(blx-sort-normalize(s)))

#let blx-maxsortnames = 9
#let blx-minsortnames = 1
#let blx-name-trunc = "\u{10FFFD}"

// Biber applies nosort to name parts, leaving titles unfiltered (Constants.pm).
#let blx-nosort(s) = {
  s.replace(regex("^\\p{L}\\p{L}\\p{Pd}(\\S)"), m => m.captures.at(0))
    .replace(regex("[\u{02BF}\u{2018}]"), "")
}
#let blx-name-sort-part(s) = blx-expand-chars(blx-sort-debrace(blx-nosort(blx-sort-clean(remove-outer(s)))))

#let blx-np-lengths(entries) = {
  let m = (family: 0, given: 0, suffix: 0, prefix: 0)
  for e in entries {
    for (_, people) in e.names {
      for n in people {
        for (k, s) in (("family", n.last), ("given", n.first), ("suffix", n.jr), ("prefix", n.von)) {
          let l = blx-name-sort-part(s).clusters().len()
          if l > m.at(k) { m.insert(k, l) }
        }
      }
    }
  }
  m
}

// Biber pads present name parts to list-wide widths; missing parts contribute no padding (Internals.pm, _namestring).
#let blx-name-sort-string(people, lens, useprefix) = {
  let real = people.filter(n => not is-others(n))
  let visible = if real.len() > blx-maxsortnames { blx-minsortnames } else { real.len() }
  let out = ""
  for n in real.slice(0, visible) {
    let part(s, w) = {
      let t = blx-name-sort-part(s)
      t + " " * calc.max(0, w - t.clusters().len())
    }
    if useprefix and n.von != "" { out += blx-name-sort-part(n.von) }
    if n.last != "" { out += part(n.last, lens.family) }
    if n.first != "" { out += part(n.first, lens.given) }
    if n.jr != "" { out += part(n.jr, lens.suffix) }
    if not useprefix and n.von != "" { out += part(n.von, lens.prefix) }
  }
  if visible < real.len() { out += blx-name-trunc }
  out
}

#let blx-roman-value(s) = {
  let t = upper(s.trim())
  if t == "" { return none }
  if t.match(regex("^M{0,3}(CM|CD|D?C{0,3})(XC|XL|L?X{0,3})(IX|IV|V?I{0,3})$")) == none { return none }
  let vals = (M: 1000, D: 500, C: 100, L: 50, X: 10, V: 5, I: 1)
  let total = 0
  let prev = 0
  for c in t.clusters().rev() {
    let v = vals.at(c)
    if v < prev { total -= v } else { total += v; prev = v }
  }
  total
}
#let blx-sort-int(s) = {
  if s == none { return 2000000000 }
  let t = s.trim()
  let r = blx-roman-value(t)
  if r != none { return r }
  if t.match(regex("^[+-]?\d+$")) != none { return int(t.trim("+", at: start)) }
  2000000000
}
// Perl treats the literal string "0" as false, so Biber falls through to the next integer field.
#let blx-int-field(e, name) = if has(e, name) and fld(e, name).trim() != "0" { fld(e, name) }
// Bias signed integers before padding so their string order remains numeric.
#let blx-int-bias = 5000000000
#let blx-pad-int(n) = { let s = str(n + blx-int-bias); "0" * calc.max(0, 11 - s.len()) + s }

#let pick-int(..vals) = { let r = vals.pos().find(v => v != none); r }
#let blx-sort-key(e, lens: (family: 0, given: 0, suffix: 0, prefix: 0), useprefix: false) = {
  let presort = blx-sort-field(fld(e, "presort", d: "mm"))
  let sortkey = if has(e, "sortkey") { fld(e, "sortkey") }
  if sortkey != none {
    let slot = blx-sort-field(sortkey)
    let n = blx-pad-int(blx-sort-int(blx-sort-normalize(sortkey)))
    return (presort, slot, slot, n, n).join(blx-sort-slot-sep)
  }
  let title = if has(e, "sorttitle") { fld(e, "sorttitle") } else { fld(e, "title", d: "") }
  let people = if "sortname" in e.names { e.names.sortname }
    else if "author" in e.names { e.names.author }
    else if "editor" in e.names { e.names.editor }
  let named = if people != none { blx-name-sort-string(people, lens, useprefix) } else { "" }
  let name-slot = if named != "" { blx-collate(named) } else { blx-sort-field(title) }
  let year = pick-int(blx-int-field(e, "sortyear"), blx-int-field(e, "year"))
  let volume = blx-int-field(e, "volume")
  (
    presort,
    name-slot,
    blx-sort-field(title),
    blx-pad-int(blx-sort-int(year)),
    blx-pad-int(if volume == none { 0 } else { blx-sort-int(volume) }),
  ).join(blx-sort-slot-sep)
}
