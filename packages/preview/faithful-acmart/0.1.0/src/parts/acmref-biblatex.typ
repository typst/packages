// ACM BibLaTeX renderer and software driver port.

#import "tex.typ": purify
#import "bibtex.typ": parse-names
#import "scan.typ": match-brace, split-list-and
#import "acmref-common.typ": render, blx-ends-punct, V, it, fld, has, articleno-of, join-names, dashify

// ---- BibLaTeX ACM driver port ---------------------------------------------
// Source files mirrored here:
//   * acmnumeric.bbx / acmauthoryear.bbx (ACM's BibLaTeX drivers/macros),
//   * software.bbx (driver extension loaded by both ACM styles),
//   * software.dbx (software-family datamodel + inheritance),
//   * english-software.lbx (visible software labels/strings).
//
// This is a visible-output port rather than a TeX macro interpreter: the functions
// below are named after the source macros/drivers where practical, but they emit
// Typst content directly and share the parser, TeX renderer, sort/cite state, and
// hyperlink machinery with the ACM-Reference-Format.bst port above.
#let blx-has-cased(s) = s.codepoints().any(c => lower(c) != upper(c))

// BibLaTeX numeric inherits a sentence-casing title formatter. Keep TeX control
// words and protected brace groups intact so presentation commands/logos survive.
#let blx-sentence-case(raw) = {
  let cp = raw.codepoints()
  let out = ""
  let first = true
  let i = 0
  while i < cp.len() {
    let c = cp.at(i)
    if c == "\\" {
      out += c
      i += 1
      let start = i
      while i < cp.len() and ((cp.at(i) >= "A" and cp.at(i) <= "Z") or (cp.at(i) >= "a" and cp.at(i) <= "z")) {
        out += cp.at(i)
        i += 1
      }
      if i == start and i < cp.len() { out += cp.at(i); i += 1 }
    } else if c == "{" {
      let j = match-brace(cp, i)
      let g = cp.slice(i, calc.min(j + 1, cp.len())).join("")
      out += g
      if first and blx-has-cased(g) { first = false }
      i = j + 1
    } else if c in (".", "!", "?") {
      out += c
      if i + 1 < cp.len() and cp.at(i + 1) == " " { first = true }
      i += 1
    } else if lower(c) != upper(c) {
      out += if first { upper(c) } else { lower(c) }
      first = false
      i += 1
    } else {
      out += c
      i += 1
    }
  }
  out
}

#let blx-field(e, name) = if has(e, name) { V(fld(e, name)) } else { none }
#let blx-list-field(e, ..names) = {
  for name in names.pos() {
    if has(e, name) { return V(fld(e, name)) }
  }
  none
}
#let blx-months = (
  "1": "Jan.", "01": "Jan.", jan: "Jan.", january: "Jan.",
  "2": "Feb.", "02": "Feb.", feb: "Feb.", february: "Feb.",
  "3": "Mar.", "03": "Mar.", mar: "Mar.", march: "Mar.",
  "4": "Apr.", "04": "Apr.", apr: "Apr.", april: "Apr.",
  "5": "May", "05": "May", may: "May",
  "6": "Jun.", "06": "Jun.", jun: "Jun.", june: "Jun.",
  "7": "July", "07": "July", jul: "July", july: "July",
  "8": "Aug.", "08": "Aug.", aug: "Aug.", august: "Aug.",
  "9": "Sept.", "09": "Sept.", sep: "Sept.", sept: "Sept.", september: "Sept.",
  "10": "Oct.", oct: "Oct.", october: "Oct.",
  "11": "Nov.", nov: "Nov.", november: "Nov.",
  "12": "Dec.", dec: "Dec.", december: "Dec.",
)
#let blx-month(raw) = {
  let parts = raw.replace(".", "").split(regex("[\\s,/-]+")).filter(p => p != "")
  let k = if parts.len() > 0 { lower(parts.first()) } else { lower(raw.replace(".", "")) }
  blx-months.at(k, default: raw)
}
#let blx-date-parts(e) = {
  let raw = if has(e, "date") { fld(e, "date") } else { "" }
  let y = if has(e, "year") { fld(e, "year") }
    else if raw.len() >= 4 { raw.slice(0, 4) }
    else { none }
  let m = if has(e, "month") { fld(e, "month") }
    else if raw.len() >= 7 and raw.slice(4, 5) == "-" { raw.slice(5, 7) }
    else { none }
  let d = if has(e, "day") { fld(e, "day") }
    else if raw.len() >= 10 and raw.slice(7, 8) == "-" { raw.slice(8, 10) }
    else { none }
  (year: y, month: m, day: d)
}
#let blx-printdate(e, suffix: "", month-ok: true) = {
  let p = blx-date-parts(e)
  if p.year == none { return "[n. d.]" + suffix }
  if month-ok and p.month != none {
    blx-month(p.month) + " " + p.year + suffix
  } else { p.year + suffix }
}
#let blx-date(e, full: false, suffix: "") = {
  (c: blx-printdate(e, suffix: suffix, month-ok: full), p: false)
}
#let blx-date-if-month(e) = {
  let p = blx-date-parts(e)
  if p.month != none and p.year != none { (c: "(" + blx-printdate(e) + ")", p: false) } else { none }
}
#let blx-date-parens(e) = {
  let p = blx-date-parts(e)
  if p.year != none { (c: "(" + blx-printdate(e, month-ok: p.month != none) + ")", p: false) } else { none }
}
#let blx-eprint-date(e) = {
  if not has(e, "eprint") { return blx-date-if-month(e) }
  let p = blx-date-parts(e)
  if p.year != none { (c: "(" + blx-printdate(e) + ")", p: false) } else { none }
}

#let blx-title-raw(e) = {
  if not has(e, "title") { return none }
  let raw = fld(e, "title")
  if has(e, "subtitle") { raw += ". " + fld(e, "subtitle") }
  raw
}
#let blx-title(e, style: "numeric", sentence: true) = {
  let raw = blx-title-raw(e)
  if raw == none { return none }
  let shown = if style == "numeric" and sentence { blx-sentence-case(raw) } else { raw }
  (c: render(shown), p: blx-ends-punct(shown))
}
#let blx-booktitle(e, with-in: false, style: "numeric") = {
  if not has(e, "booktitle") { return none }
  let c = it(render(fld(e, "booktitle")))
  if has(e, "booksubtitle") { c += ". " + render(fld(e, "booksubtitle")) }
  if has(e, "series") { c += " (" + render(fld(e, "series")) + ")" }
  if has(e, "number") { c += " " + render(fld(e, "number")) }
  if articleno-of(e) != none { c += " Article " + articleno-of(e) }
  let pre = if not with-in { [] } else if style == "author-year" { [In: ] } else { [In ] }
  (c: pre + c, p: false)
}
#let blx-booktitle-simple(e, with-in: false, style: "numeric") = {
  if not has(e, "booktitle") { return none }
  let c = it(render(fld(e, "booktitle")))
  if has(e, "booksubtitle") { c += ". " + render(fld(e, "booksubtitle")) }
  let pre = if not with-in { [] } else if style == "author-year" { [In: ] } else { [In ] }
  (c: pre + c, p: false)
}
#let blx-title-format(e, style: "numeric") = {
  let t = e.entry-type
  if style == "author-year" {
    // acmauthoryear.bbx inherits biblatex's standard title formats: article,
    // inbook, incollection, inproceedings, patent, thesis, and unpublished are
    // quoted; all other title fields use the default emphasized title format.
    if t in ("article", "inbook", "incollection", "inproceedings", "conference",
             "patent", "thesis", "mastersthesis", "phdthesis", "unpublished") {
      "quoted"
    } else { "emph" }
  } else {
    // acmnumeric.bbx inherits trad-standard.bbx: most titles are plain and
    // sentence-cased; book, inbook, manual, thesis, and proceedings titles are
    // emphasized.
    if t in ("book", "collection", "inbook", "manual", "thesis", "mastersthesis",
             "phdthesis", "proceedings") {
      "emph"
    } else { "plain" }
  }
}
#let blx-numeric-preserve-titlecase-types = (
  "book", "collection", "manual", "periodical", "proceedings", "report",
  "techreport", "thesis", "mastersthesis", "phdthesis",
)
#let blx-title-field(e, style: "numeric", format: auto, sentence: auto) = {
  let raw = blx-title-raw(e)
  if raw == none { return none }
  let sentence = if sentence == auto {
    // trad-standard.bbx MakeTitleCase sentence-cases article/chapter/paper-like
    // titles in numeric style. Whole-volume/report/thesis titles preserve the
    // supplied case; authoryear-comp/standard keeps supplied title case too.
    style == "numeric" and e.entry-type not in blx-numeric-preserve-titlecase-types
  } else { sentence }
  let shown = if sentence { blx-sentence-case(raw) } else { raw }
  let fmt = if format == auto { blx-title-format(e, style: style) } else { format }
  let p = blx-ends-punct(shown)
  if fmt == "quoted" {
    let inner = render(shown) + if p { [] } else { [.] }
    (c: "\u{201C}" + inner + "\u{201D}", p: true)
  } else if fmt == "emph" {
    (c: it(render(shown)), p: p)
  } else {
    (c: render(shown), p: p)
  }
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
#let blx-series-number(e, style: "numeric") = {
  if not has(e, "series") and not has(e, "number") { return none }
  let series = if has(e, "series") {
    // trad-standard.bbx emphasizes series for book/inproceedings/proceedings
    // but not inbook/incollection; standard.bbx leaves it plain.
    if style == "numeric" and e.entry-type in ("book", "inproceedings", "conference", "proceedings") {
      it(render(fld(e, "series")))
    } else {
      render(fld(e, "series"))
    }
  } else { none }
  if style == "numeric" {
    // trad-standard.bbx \series+number: \printfield{number} "in"
    // \printfield{series}; ACM's number field format is bare for the custom
    // inproceedings macro, but incollection/book use the inherited "Number N".
    if has(e, "series") and has(e, "number") {
      (c: "Number " + render(fld(e, "number")) + " in " + series, p: false)
    } else if has(e, "number") {
      (c: "Number " + render(fld(e, "number")), p: false)
    } else {
      (c: series, p: blx-ends-punct(fld(e, "series")))
    }
  } else {
    // standard.bbx \series+number: \printfield{series} [space]
    // \printfield{number}.
    let c = []
    if has(e, "series") { c += series }
    if has(e, "number") {
      if c != [] { c += " " }
      c += render(fld(e, "number"))
    }
    (c: c, p: false)
  }
}
#let blx-volumes(e) = if has(e, "volumes") {
  (c: render(fld(e, "volumes")) + " volumes", p: false)
} else { none }
#let blx-bookauthor(e) = if has(e, "bookauthor") and fld(e, "bookauthor") != fld(e, "author", d: "\u{0}") {
  if "bookauthor" in e.names { (c: render(join-names(e.names.bookauthor)), p: false) }
  else { V(fld(e, "bookauthor")) }
} else { none }
#let blx-publisher-location-date(e) = {
  let parts = ()
  if has(e, "publisher") { parts.push(render(fld(e, "publisher"))) }
  if has(e, "location") { parts.push(render(fld(e, "location"))) }
  else if has(e, "address") { parts.push(render(fld(e, "address"))) }
  if has(e, "month") { parts.push("(" + blx-printdate(e) + ")") }
  let raw = ()
  if has(e, "publisher") { raw.push(fld(e, "publisher")) }
  if has(e, "location") { raw.push(fld(e, "location")) }
  else if has(e, "address") { raw.push(fld(e, "address")) }
  if has(e, "month") { raw.push("(" + blx-printdate(e) + ")") }
  if parts.len() == 0 { none } else { (c: parts.join(", "), p: blx-ends-punct(raw.join(", "))) }
}
#let blx-publisher-pages(e) = {
  let pub = blx-publisher-location-date(e)
  let pg = blx-chapter-pages(e)
  if pub != none and pg != none { (c: pub.c + ", " + pg.c, p: false) }
  else if pub != none { pub }
  else { pg }
}
#let blx-volume(e) = if has(e, "volume") { (c: "Vol. " + fld(e, "volume"), p: false) } else { none }
#let blx-ed-by(e) = if has(e, "editor") {
  (c: "Ed. by " + render(join-names(e.names.editor)), p: false)
} else { none }
#let blx-editor-block(e, style: "numeric") = if not has(e, "editor") {
  none
} else if style == "author-year" {
  blx-ed-by(e)
} else {
  let suffix = if e.names.editor.len() > 1 { ", (Eds.)" } else { ", (Ed.)" }
  (c: render(join-names(e.names.editor)) + suffix, p: true)
}
#let blx-isbn(e) = if has(e, "isbn") { (c: "isbn: " + fld(e, "isbn"), p: false) } else { none }
#let blx-journal(e) = {
  if not has(e, "journal") { return none }
  let parts = (it(render(fld(e, "journal"))),)
  if has(e, "series") { parts.push(render(fld(e, "series"))) }
  if has(e, "volume") { parts.push(fld(e, "volume")) }
  if has(e, "number") { parts.push(fld(e, "number")) }
  if has(e, "articleno") { parts.push("Article " + fld(e, "articleno").replace("~", " ")) }
  let d = blx-date-if-month(e)
  if d != none { parts.push(d.c) }
  if has(e, "eid") { parts.push(fld(e, "eid")) }
  let pg = blx-pages(e)
  if pg != none { parts.push(pg.c) }
  (c: parts.join(", "), p: false)
}
#let blx-periodical-journal(e) = {
  if not has(e, "journal") { return none }
  let c = it(render(fld(e, "journal")))
  if has(e, "volume") { c += " " + fld(e, "volume") }
  if has(e, "number") { c += ", " + fld(e, "number") }
  let d = blx-date-if-month(e)
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
  let prefix = fld(e, "archiveprefix", d: if has(e, "eprinttype") { fld(e, "eprinttype") } else { "arXiv" })
  let cls = if has(e, "primaryclass") { " [" + fld(e, "primaryclass") + "]" } else if has(e, "eprintclass") { " [" + fld(e, "eprintclass") + "]" } else { "" }
  // acmart links arXiv eprints to arxiv.org/abs (\showeprint, acmart.dtx:8913);
  // non-arXiv prefixes stay plain text.
  let num = if lower(prefix) == "arxiv" { link("https://arxiv.org/abs/" + ep)[#ep] } else { ep }
  (c: prefix + ": " + num + cls, p: false)
} else { none }
#let blx-doi(e) = if has(e, "doi") {
  let d = fld(e, "doi")
  // BibLaTeX's \printfield{doi} prepends the https://doi.org/ resolver unconditionally
  // (even when the field is already a full URL, which double-wraps it) — mirror that
  // so the link targets match LaTeX. The bst backend strips the prefix instead.
  (c: link("https://doi.org/" + d)[doi: #d], p: false)
} else { none }
#let blx-tail(e, url-always: false) = {
  let items = ()
  // print url when no doi, OR when the per-entry `distinctURL` field is set and not
  // "0" (matches the .bst's `distinctURL empty.or.zero not`; field keys are lowercased
  // at parse time, so only "distincturl" can occur).
  let distinct-url = has(e, "distincturl") and fld(e, "distincturl") != "0"
  if url-always or (not has(e, "doi")) or distinct-url {
    let u = blx-url-urldate(e)
    if u != none { items.push(u) }
  }
  let ep = blx-eprint(e)
  if ep != none { items.push(ep) }
  let doi = blx-doi(e)
  if doi != none { items.push(doi) }
  items
}

#let blx-person-label(e, editor-ok: true, org-ok: true, key-ok: true) = {
  if has(e, "author") { return (c: render(join-names(e.names.author)), kind: "author") }
  if editor-ok and has(e, "editor") {
    let suffix = if e.names.editor.len() > 1 { ", (Eds.)" } else { ", (Ed.)" }
    return (c: render(join-names(e.names.editor)) + suffix, kind: "editor")
  }
  if org-ok and has(e, "organization") { return (c: render(fld(e, "organization")), kind: "organization") }
  if key-ok and has(e, "key") { return (c: render(fld(e, "key")), kind: "key") }
  none
}
#let blx-lead(e, style: "numeric", suffix: "", editor-ok: true, org-ok: true, key-ok: true) = {
  let who = blx-person-label(e, editor-ok: editor-ok, org-ok: org-ok, key-ok: key-ok)
  let dt = blx-date(e, full: style == "author-year", suffix: suffix)
  if who == none { return dt }
  let sep = if style == "numeric" and who.kind == "editor" { " " } else { ". " }
  (c: who.c + sep + dt.c, p: false)
}
#let blx-inbook-lead(e, style: "numeric", suffix: "") = {
  // acmnumeric.bbx/acmauthoryear.bbx use \iffieldundef{author} here, not
  // \ifnameundef{author}. Since author is a name list rather than a literal
  // field, real BibLaTeX takes the "author undefined" branch even when the .bib
  // entry has an author name. Mirror that visible behavior: byeditor+others is
  // the only name lead in this ACM inbook driver.
  if has(e, "editor") {
    // acmnumeric.bbx then prints the year; acmauthoryear.bbx does not.
    let c = "Ed. by " + render(join-names(e.names.editor))
    if style == "numeric" { c += ". " + blx-date(e, suffix: suffix).c }
    return (c: c, p: false)
  }
  if style == "numeric" { blx-date(e, suffix: suffix) } else { none }
}
// a rendered value carries visible text (drives block/swids filtering)
#let blx-nonempty(v) = v != none and v.c != none and v.c != [] and v.c != ""
#let blx-blocks(..vals) = {
  let pieces = vals.pos().filter(blx-nonempty)
  let out = []
  for (i, v) in pieces.enumerate() {
    if i > 0 { out += " " }
    out += v.c
    if not v.p { out += "." }
  }
  out
}
#let blx-article-like(e, style: "numeric", suffix: "") = blx-blocks(
  blx-lead(e, style: style, suffix: suffix),
  blx-title-field(e, style: style),
  blx-journal(e),
  blx-note(e),
  ..blx-tail(e),
)
#let blx-inproceedings(e, style: "numeric", suffix: "") = {
  let title-led = style == "author-year" and not has(e, "author") and not has(e, "editor") and not has(e, "organization") and has(e, "title")
  blx-blocks(
    if title-led { none } else { blx-lead(e, style: style, suffix: suffix, key-ok: false) },
    blx-title-field(e, style: style),
    blx-booktitle(e, with-in: true, style: style),
    blx-editor-block(e, style: style),
    blx-volume(e),
    blx-list-field(e, "organization"),
    blx-publisher-pages(e),
    blx-isbn(e),
    ..blx-tail(e),
  )
}
#let blx-incollection(e, style: "numeric", suffix: "") = blx-blocks(
  blx-lead(e, style: style, suffix: suffix),
  blx-title-field(e, style: style),
  blx-booktitle-simple(e, with-in: true, style: style),
  blx-series-number(e, style: style),
  blx-edition(e),
  blx-volume(e),
  blx-volumes(e),
  blx-editor-block(e, style: style),
  blx-note(e),
  blx-publisher-pages(e),
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
    blx-edition(e),
    blx-volume(e),
    blx-volumes(e),
    blx-series-number(e, style: style),
    blx-note(e),
    blx-publisher-location-date(e),
    blx-chapter-pages(e),
    blx-isbn(e),
    ..blx-tail(e),
  )
}
#let blx-book-like(e, style: "numeric", suffix: "") = blx-blocks(
  blx-lead(e, style: style, suffix: suffix),
  blx-title-field(e, style: style),
  blx-edition(e),
  blx-series-number(e, style: style),
  blx-volume(e),
  blx-volumes(e),
  blx-note(e),
  blx-publisher-pages(e),
  blx-isbn(e),
  ..blx-tail(e),
)
#let blx-online(e, style: "numeric", suffix: "") = {
  let who = blx-person-label(e, key-ok: false)
  let lead = if who == none {
    if style == "numeric" { blx-date(e, suffix: suffix) } else { none }
  } else { blx-lead(e, style: style, suffix: suffix, key-ok: false) }
  blx-blocks(
    lead,
    blx-title-field(e, style: style),
    blx-field(e, "howpublished"),
    blx-field(e, "version"),
    blx-note(e),
    blx-list-field(e, "organization"),
    blx-eprint-date(e),
    blx-eprint(e),
    blx-doi(e),
    blx-url-urldate(e),
  )
}
#let blx-presentation(e, style: "numeric", suffix: "") = blx-blocks(
  blx-lead(e, style: style, suffix: suffix, key-ok: false),
  blx-title-field(e, style: style, format: "plain"),
  blx-date-parens(e),
  ..blx-tail(e),
)
#let blx-institution-location(e) = {
  let inst = blx-list-field(e, "school", "institution")
  let loc = blx-list-field(e, "location", "address")
  if inst != none and loc != none { (c: inst.c + ", " + loc.c, p: false) }
  else if inst != none { inst }
  else { loc }
}
#let blx-report(e, style: "numeric", suffix: "", thesis: false) = {
  let ty = if thesis {
    if has(e, "type") { blx-field(e, "type") } else if e.entry-type == "phdthesis" { (c: "Ph.D. Dissertation", p: false) } else { (c: "Master\u{2019}s thesis", p: false) }
  } else if has(e, "type") and has(e, "number") { (c: render(fld(e, "type")) + " " + render(fld(e, "number")), p: false) }
  else if has(e, "type") { blx-field(e, "type") }
  else { none }
  blx-blocks(
    blx-lead(e, style: style, suffix: suffix, editor-ok: false, org-ok: false),
    blx-title-field(e, style: style),
    ty,
    blx-field(e, "version"),
    blx-institution-location(e),
    blx-note(e),
    blx-chapter-pages(e),
    ..blx-tail(e),
  )
}

// ---- BibLaTeX software.dbx + software.bbx port ----------------------------
#let blx-software-types = ("software", "softwareversion", "softwaremodule", "codefragment")
#let blx-software-labels = (
  software: "[SW]",
  softwareversion: "[SW Rel.]",
  softwaremodule: "[SW Mod.]",
  codefragment: "[SW exc.]",
)

// acmnumeric.bbx/acmauthoryear.bbx DeclareStyleSourcemap.
#let blx-acm-sourcemap(db) = {
  let out = (:)
  for (k, e0) in db {
    let e = e0
    if e.entry-type == "techreport" { e = e + (entry-type: "report") }
    else if e.entry-type == "artifactsoftware" { e = e + (entry-type: "software") }
    else if e.entry-type == "artifactdataset" { e = e + (entry-type: "dataset") }
    out.insert(k, e)
  }
  out
}

// software.bbx DeclareStyleSourcemap: strip whitespace in swhid and derive
// swhidcore from the part before the first semicolon.
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

#let blx-fill-date-fields(e) = {
  let p = blx-date-parts(e)
  if p.year != none and not has(e, "year") { e.fields.insert("year", p.year) }
  if p.month != none and not has(e, "month") { e.fields.insert("month", p.month) }
  if p.day != none and not has(e, "day") { e.fields.insert("day", p.day) }
  e
}

#let blx-software-can-inherit(parent, child) = {
  if parent == "software" { child in ("softwareversion", "softwaremodule", "codefragment") }
  else if parent == "softwareversion" { child in ("softwaremodule", "codefragment") }
  else if parent == "softwaremodule" { child == "codefragment" }
  else { false }
}

// software.dbx DeclareDataInheritance, resolved recursively so a codefragment
// inherits through softwareversion to the top-level software project.
#let blx-software-inherit-entry(db, key, seen: ()) = {
  let e = blx-fill-date-fields(blx-software-sourcemap-entry(db.at(key)))
  if e.entry-type not in blx-software-types or not has(e, "crossref") { return e }
  let xr = fld(e, "crossref")
  if xr not in db or xr in seen { return e }
  let parent = blx-software-inherit-entry(db, xr, seen: seen + (key,))
  if not blx-software-can-inherit(parent.entry-type, e.entry-type) { return e }
  for (fk, fv) in parent.fields {
    if fk == "crossref" { continue }
    if fk not in e.fields {
      e.fields.insert(fk, fv)
      if fk == "author" or fk == "editor" { e.names.insert(fk, parse-names(fv)) }
    }
  }
  e
}

#let blx-biber-datamodel(db) = {
  let mapped = blx-acm-sourcemap(db)
  let out = (:)
  for (k, e) in mapped {
    let r = if e.entry-type in blx-software-types {
      blx-software-inherit-entry(mapped, k)
    } else {
      blx-fill-date-fields(e)
    }
    out.insert(k, r)
  }
  out
}

#let blx-list-content(raw) = {
  let parts = split-list-and(raw, trim: true, filter-empty: true).map(render)
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

#let blx-printlist(e, name) = if has(e, name) {
  (c: blx-list-content(fld(e, name)), p: false)
} else { none }

#let blx-sw-version(e) = if has(e, "version") { " version " + render(fld(e, "version")) } else { [] }
#let blx-sw-editor(e) = if has(e, "editor") {
  [ (Coord.by #render(join-names(e.names.editor)))]
} else { [] }

// software.bbx: \newbibmacro*{swtitleauthoreditoryear}
#let blx-swtitleauthoreditoryear(e) = {
  let c = []
  if has(e, "author") { c += render(join-names(e.names.author)) + ", " }
  c += render(fld(e, "title", d: ""))
  c += blx-sw-version(e)
  c += blx-sw-editor(e)
  let date = blx-printdate(e)
  if has(e, "version") or has(e, "editor") { c += ", " + date } else { c += " " + date }
  (c: c, p: false)
}

#let blx-sw-subtitle(e) = if has(e, "subtitle") {
  "\u{201C}" + render(fld(e, "subtitle")) + ",\u{201D}"
} else { [] }

// software.bbx: \newbibmacro*{swsubtitleauthoreditoryear}
#let blx-swsubtitleauthoreditoryear(e) = {
  let c = []
  if has(e, "author") { c += render(join-names(e.names.author)) + ", " }
  if has(e, "subtitle") { c += blx-sw-subtitle(e) + " part of " }
  c += render(fld(e, "title", d: ""))
  c += blx-sw-version(e)
  c += blx-sw-editor(e)
  let date = blx-printdate(e)
  if has(e, "version") or has(e, "editor") { c += ", " + date } else { c += " " + date }
  (c: c, p: false)
}

// software.bbx: \newbibmacro*{codefragmenttitleauthoreditoryear}
#let blx-codefragmenttitleauthoreditoryear(e) = {
  let c = []
  if has(e, "author") { c += render(join-names(e.names.author)) + ", " }
  if has(e, "subtitle") { c += blx-sw-subtitle(e) + " from " }
  c += render(fld(e, "title", d: ""))
  c += blx-sw-version(e)
  c += blx-sw-editor(e)
  let date = blx-printdate(e)
  if has(e, "version") or has(e, "editor") { c += ", " + date } else { c += " " + date }
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

// software.bbx: \newbibmacro*{swids}. ACM sets license=false, halid/swhid/vcs
// true in acmnumeric.bbx/acmauthoryear.bbx.
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

#let blx-software-driver(e, kind) = {
  let body = if kind == "software" { blx-swtitleauthoreditoryear(e) }
    else if kind == "codefragment" { blx-codefragmenttitleauthoreditoryear(e) }
    else { blx-swsubtitleauthoreditoryear(e) }
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
  else if t == "underreview" {
    blx-blocks(
      blx-lead(e, style: style, suffix: year-suffix),
      blx-title(e, style: style, sentence: style == "numeric"),
      blx-date-parens(e),
      blx-note(e),
      ..blx-tail(e),
    )
  }
  else if t == "inproceedings" or t == "conference" { blx-inproceedings(e, style: style, suffix: year-suffix) }
  else if t == "presentation" { blx-presentation(e, style: style, suffix: year-suffix) }
  else if t == "incollection" { blx-incollection(e, style: style, suffix: year-suffix) }
  else if t == "inbook" { blx-inbook(e, style: style, suffix: year-suffix) }
  else if t == "book" or t == "proceedings" or t == "collection" { blx-book-like(e, style: style, suffix: year-suffix) }
  else if t in blx-software-types { blx-software-driver(e, t) }
  else if t == "online" or t == "manual" or t == "misc" or t == "game" or t == "video" or t == "artifactdataset" or t == "dataset" or t == "preprint" {
    blx-online(e, style: style, suffix: year-suffix)
  }
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
  else { blx-blocks(blx-lead(e, style: style, suffix: year-suffix), blx-title(e, style: style, sentence: style == "numeric"), ..blx-tail(e)) }
}

// ---- sort key -------------------------------------------------------------
#let blx-sort-key(e) = {
  let ppl = e.names.at("author", default: e.names.at("editor", default: ()))
  let names = ppl.map(n => (n.von + " " + n.last + " " + n.first).trim()).join(" ")
  if names == none { names = "" }
  names = lower(purify(names))
  if names == "" and has(e, "key") { names = lower(purify(fld(e, "key"))) }
  let y = if has(e, "year") { fld(e, "year") } else { "" }
  names + "   " + lower(purify(fld(e, "title", d: ""))) + "   " + y
}
