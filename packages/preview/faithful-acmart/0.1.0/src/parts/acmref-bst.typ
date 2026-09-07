// ACM-Reference-Format.bst renderer.
//
// Reproduces the visible reference text produced by ACM-Reference-Format.bst.

#import "bib-data.typ": journal-canon
#import "tex.typ": purify, change-case
#import "acmref-common.typ": render, ends-punct, V, it, fld, has, articleno-of, is-others, join-names, dashify, von-last, year-value

// ACM journal.canon.abbrev: map a full journal name to its canonical abbreviation
#let canon-abbrev(j) = journal-canon.at(j, default: j)

// ---- output state machine -------------------------------------------------
// state: "before" | "mid" | "block"   (sentence collapses to block)
#let em-init = (pieces: (), state: "before")

#let sep-for(state, variant) = {
  if state == "before" { "first" }
  else if state == "mid" {
    if variant == "dotspace" { "dotspace" }
    else if variant == "removenospace" { "none" }
    else { "comma" }
  } else { "block" }
}

// output a value (none/empty is discarded, like .bst `output`)
#let out(em, v, variant: "norm") = {
  if v == none or v.c == none or v.c == [] or v.c == "" { return em }
  em.pieces.push((sep: sep-for(em.state, variant), c: v.c, p: v.p))
  em.state = "mid"
  em
}
// output.year.check: write previous as-is, year carries a leading space
#let out-year(em, v) = {
  em.pieces.push((sep: "space", c: v.c, p: v.p))
  em.state = "mid"
  em
}
#let nblock(em) = { if em.state != "before" { em.state = "block" }; em }
#let nsentence(em) = { if em.state == "mid" { em.state = "block" }; em }

// render the body pieces, then append trailing items (each space-joined,
// self-punctuating), per fin.block + writeln-based trailing block.
#let em-render(em, trailing) = {
  let r = []
  for (i, pc) in em.pieces.enumerate() {
    if i == 0 { r += pc.c } else {
      let prev = em.pieces.at(i - 1)
      if pc.sep == "comma" { r += ", " }
      else if pc.sep == "dotspace" { r += ". " }
      else if pc.sep == "space" { r += " " }
      else if pc.sep == "none" { }
      else if pc.sep == "block" { if not prev.p { r += "." }; r += " " }
      r += pc.c
    }
  }
  // body terminal period (fin.block / fin.entry)
  let last-punct = if em.pieces.len() > 0 { em.pieces.at(-1).p } else { true }
  if not last-punct { r += "." }
  for t in trailing { r += " " + t }   // note/doi/url, each self-punctuating
  r
}

#let format-authors(e) = {
  if not has(e, "author") { return none }
  let s = join-names(e.names.author)
  if not ends-punct(s) { s = s + "." }
  V(s)
}
// " (Ed.)" / " (Eds.)" per editor count (the .bst appends "." after it in some spots)
#let eds-suffix(people) = if people.len() > 1 { " (Eds.)" } else { " (Ed.)" }
#let format-editors(e) = {     // label position: trailing " (Ed.)."/" (Eds.)."
  if not has(e, "editor") { return none }
  V(join-names(e.names.editor) + eds-suffix(e.names.editor) + ".")
}
#let format-editors-fml(e) = { // inline after booktitle: no trailing period
  if not has(e, "editor") { return none }
  V(join-names(e.names.editor) + eds-suffix(e.names.editor))
}

// ---- titles ---------------------------------------------------------------
#let format-title(e) = if has(e, "title") { V(fld(e, "title")) } else { none }
// The .bst's format.title and format.articletitle apply the same transform.
#let format-articletitle = format-title
#let format-title-emph(e) = if has(e, "title") {
  (c: it(render(fld(e, "title"))), p: ends-punct(fld(e, "title")))
} else { none }

// emph(title) + " (Nth ed.)"  — for book/proceedings btitle & booktitle
#let title-with-edition(e, raw) = {
  if raw == none or raw.trim() == "" { return none }
  let body = it(render(raw))
  if has(e, "edition") {
    let ed = lower(fld(e, "edition"))
    (c: body + " (" + render(ed) + " ed.)", p: false)
  } else { (c: body, p: ends-punct(raw)) }
}
#let format-btitle(e) = title-with-edition(e, fld(e, "title"))
#let format-emph-booktitle(e) = title-with-edition(e, fld(e, "booktitle"))

// ---- volume / number / series ---------------------------------------------
#let format-bvolume(e) = {
  if not has(e, "volume") { return none }
  if has(e, "series") { V("\u{200B}", c: fld(e, "series") + ", Vol.\u{00A0}" + fld(e, "volume")) }
  else { V("\u{200B}", c: "Vol.\u{00A0}" + fld(e, "volume")) }
}
#let format-bvolume-noseries(e) = if has(e, "volume") {
  (c: "Vol.\u{00A0}" + fld(e, "volume"), p: false)
} else { none }
#let format-number-series(e) = {
  // Per the .bst: a lone series (no volume, no number) is NOT shown here — only
  // "Number <n> in <series>" when a number is present and volume is absent.
  if has(e, "volume") { return none }
  if has(e, "number") and has(e, "series") {
    (c: "Number " + fld(e, "number") + " in " + render(fld(e, "series")), p: false)
  } else { none }
}

// format.series: " (series)" / " (series, number)" / " (series, Vol. N)" (emph), leading space
#let format-series(e) = {
  if not has(e, "series") { return none }
  let inner = render(fld(e, "series"))
  if has(e, "volume") { inner = inner + ", Vol.\u{00A0}" + fld(e, "volume") }
  else if has(e, "number") { inner = inner + ", " + fld(e, "number") }
  (c: " " + it("(" + inner + ")"), p: false)
}

// ---- pages ----------------------------------------------------------------
#let format-pages(e) = if has(e, "pages") { (c: dashify(fld(e, "pages")), p: false) } else { none }
#let format-bookpages(e) = if has(e, "bookpages") {
  (c: render(fld(e, "bookpages")) + " book pages", p: false) } else { none }
// chapter + pages, or just pages
#let format-chapter-pages(e) = {
  if has(e, "chapter") {
    let ty = if has(e, "type") { render(change-case(fld(e, "type"), "t")) } else { "Chapter" }
    let r = ty + " " + fld(e, "chapter")
    if has(e, "pages") { r = r + ", " + dashify(fld(e, "pages")) }
    (c: r, p: false)
  } else { format-pages(e) }
}
// pages when no articleno (acmsmall: numpages-only -> "N pages")
#let format-pages-noart(e) = {
  if articleno-of(e) != none { none }
  else if has(e, "pages") { format-pages(e) }
  else if has(e, "numpages") { (c: fld(e, "numpages") + " pages", p: false) }
  else { none }
}
// reduce.pages.to.page.count: numpages wins; else parse the first three numbers of
// `pages` — a bare "1--N" range reduces to N (its page count), anything else
// (n:1--n:m, 5--12, ...) stays verbatim. (The .bst's second `if` overwrites the
// first, so only the "1--N" case actually reduces.)
#let reduce-pages(e) = {
  if has(e, "numpages") { return fld(e, "numpages") }
  if not has(e, "pages") { return none }
  let p = fld(e, "pages")
  let nums = p.matches(regex("[0-9]+"))
  let p1 = if nums.len() > 0 { nums.at(0).text } else { none }
  let p3 = if nums.len() > 2 { nums.at(2).text } else { none }
  if nums.len() >= 2 and p1 == "1" and p3 == none { nums.at(1).text } else { p }
}
// calc.format.page.count: "<count> pages" (misc/periodical/articleno paths)
#let format-page-count(e) = {
  let c = reduce-pages(e)
  if c == none { none } else { (c: dashify(c) + " pages", p: false) }
}

// ---- date / journal -------------------------------------------------------
// optional ", Article N" prefix, then "(month year)"/"(day month year)", joined
// by a leading space (`lead`); `lead: false` drops it for standalone use (the
// content can't be .trim()ed once rendered, unlike the old decoded string).
#let format-day-month-year(e, lead: true) = {
  let art = articleno-of(e)
  let pre = if art != none { ", Article " + art } else { "" }
  let sp = if lead { " " } else { "" }
  if not has(e, "month") {
    if has(e, "year") { (c: pre + sp + "(" + fld(e, "year") + ")", p: false) }
    else if art != none { (c: pre, p: false) } else { none }
  } else {
    let d = if has(e, "day") { fld(e, "day") + " " } else { "" }
    let y = if has(e, "year") { fld(e, "year") } else { "[n.d.]" }
    (c: pre + sp + "(" + render(fld(e, "month")) + " " + d + y + ")", p: false)
  }
}
// "N pages" when articleno present (numpages, or reduced from pages)
#let format-articleno-numpages(e) = {
  if articleno-of(e) == none { return none }
  format-page-count(e)
}
#let format-journal-block(e) = {
  if not has(e, "journal") { return none }
  let c = it(render(canon-abbrev(fld(e, "journal"))))
  if has(e, "volume") and has(e, "number") {
    c = c + " " + fld(e, "volume") + ", " + fld(e, "number")
  } else if has(e, "volume") {
    c = c + " " + fld(e, "volume")
  } else if has(e, "number") {
    c = c + " " + fld(e, "number")
  }
  let dmy = format-day-month-year(e)
  if e.entry-type != "inproceedings" and dmy != none { c = c + dmy.c }
  (c: c, p: false)
}
#let format-journal-underreview(e) = {
  let pre = if has(e, "journal") { it(render(canon-abbrev(fld(e, "journal")))) + "." } else { [] }
  (c: pre + " Manuscript submitted for review", p: false)
}

// ---- "In booktitle (city)" variants ---------------------------------------
#let format-city(e) = {
  let loc = if has(e, "location") { fld(e, "location") } else if has(e, "city") { fld(e, "city") } else { none }
  let date = if has(e, "date") { fld(e, "date") } else { none }
  if loc == none and date == none { "" }
  else if loc == none { " (" + render(date) + ")" }
  else if date == none { " (" + render(loc) + ")" }
  else { " (" + render(loc) + ", " + render(date) + ")" }
}
#let format-in-emph-booktitle(e) = {
  let bt = format-emph-booktitle(e)
  if bt == none { return none }
  (c: [In ] + bt.c + format-city(e), p: false)
}
#let format-in-ed-booktitle(e) = {
  let bt = format-emph-booktitle(e)
  if bt == none { return none }
  let c = [In ] + bt.c + format-city(e)
  if has(e, "editor") {
    c = c + ", " + join-names(e.names.editor) + eds-suffix(e.names.editor)
  }
  (c: c, p: false)
}
#let format-venue(e) = if has(e, "venue") {
  (c: "Presentation at " + render(fld(e, "venue")), p: false) } else { none }

// ---- thesis / techreport --------------------------------------------------
#let format-thesis-type(e, default) = (c: render(if has(e, "type") { fld(e, "type") } else { default }), p: ends-punct(if has(e, "type") { fld(e, "type") } else { default }))
#let format-tr-number(e) = {
  let raw = if has(e, "type") { fld(e, "type") } else { "Technical Report" }
  let ty = render(raw)
  if has(e, "number") { (c: ty + " " + fld(e, "number"), p: false) }
  else { (c: ty, p: ends-punct(raw)) }
}
#let format-advisor(e) = if has(e, "advisor") {
  V("Advisor(s) " + fld(e, "advisor")) } else { none }

// ---- crossref ("See [N]") --------------------------------------------------
// `xref-cite` is the rendered citation of the crossref'd parent ("[N]" in numeric
// mode), supplied by the context layer once the parent's number is known.
// format.crossref.editor: first editor (von last); " and second" for two, " et al." for >2
#let format-crossref-editor(e) = {
  let eds = e.names.editor
  let s = von-last(eds.at(0))
  if eds.len() > 2 { s + " et al." }
  else if eds.len() == 2 {
    if is-others(eds.at(1)) { s + " et al." } else { s + " and " + von-last(eds.at(1)) }
  } else { s }
}
#let format-article-crossref(e, xref-cite) = (c: [See] + xref-cite, p: false)   // .bst: no space
#let format-incoll-inproc-crossref(e, xref-cite) = (c: [See ] + xref-cite, p: false)
#let format-book-crossref(e, xref-cite) = {
  // "Volume N of <ed/key/series> [N]" or "In <ed/key/series> [N]"
  let pre = if has(e, "volume") { [Volume #fld(e, "volume") of ] } else { [In ] }
  let ed-empty = not has(e, "editor") or fld(e, "editor") == fld(e, "author", d: "\u{0}")
  let mid = if ed-empty {
    if has(e, "key") { render(fld(e, "key")) }
    else if has(e, "series") { it(render(fld(e, "series"))) }
    else { [] }
  } else { render(format-crossref-editor(e)) }
  (c: pre + mid + [ ] + xref-cite, p: false)
}

// ---- shared trailing block: note, doi, url --------------------------------
// .bst strip.doi: bare DOIs start "10."; otherwise drop any scheme + host, keeping
// the path (http://doi.acm.org/10.1145/X -> 10.1145/X).
#let strip-doi(d) = {
  if d.starts-with("10.") { return d }
  let s = d.replace(regex("(?i)^https?://"), "")
  let parts = s.split("/")
  if parts.len() <= 1 { d } else { parts.slice(1).join("/") }
}
// arXiv eprint per acmart's \showeprint: "arXiv:" + linked number + " [class]"
// for arxiv-family prefixes, else plain "prefix:eprint".
#let format-eprint(e) = {
  let ep = fld(e, "eprint")
  let prefix = fld(e, "archiveprefix", d: if has(e, "eprinttype") { fld(e, "eprinttype") } else { "arxiv" })
  let cls = if has(e, "primaryclass") { fld(e, "primaryclass") } else if has(e, "eprintclass") { fld(e, "eprintclass") } else { none }
  let suffix = if cls != none { " [" + cls + "]" } else { "" }
  if lower(prefix) == "arxiv" {
    [arXiv:#link("https://arxiv.org/abs/" + ep)[#ep]#suffix]
  } else {
    [#prefix:#ep#suffix]
  }
}

// shared trailing block: note, eprint, doi, url — each self-punctuating, with real
// hyperlinks (acmart renders these via hyperref \href/\url/\showeprint).
#let trailing(e) = {
  let items = ()
  if has(e, "note") {
    let n = render(fld(e, "note"))
    items.push(if ends-punct(fld(e, "note")) { n } else { n + [.] })
  }
  if has(e, "issue") { items.push("Issue " + fld(e, "issue") + ".") }
  if has(e, "eprint") { items.push(format-eprint(e)) }
  if has(e, "doi") {
    let bare = strip-doi(fld(e, "doi"))
    items.push(link("https://doi.org/" + bare)[doi:#bare])
  }
  // output.url: print url when no doi, OR when the per-entry `distinctURL` field
  // is present and not "0" (the .bst's `distinctURL empty.or.zero not`).
  let distinct-url = has(e, "distincturl") and fld(e, "distincturl") != "0"
  if has(e, "url") and (not has(e, "doi") or distinct-url) {
    let u = fld(e, "url")
    let r = if has(e, "lastaccessed") { [Retrieved #render(fld(e, "lastaccessed")) from #link(u)[#u]] } else { link(u)[#u] }
    if has(e, "archived") { r = r + [, archived at \[#link(fld(e, "archived"))[#fld(e, "archived")]\]] }
    items.push(r)
  }
  items
}

// ---- per-entry-type handlers ----------------------------------------------
#let howpub(e) = if has(e, "howpublished") { V(fld(e, "howpublished")) } else { none }

#let lead-author-year(em, e, ysuf) = {
  em = out(em, format-authors(e), variant: "norm")
  if not has(e, "author") and has(e, "editor") { em = out(em, format-editors(e)) }
  // format.key fallback: an author-less entry shows its `key` field in that slot
  if not has(e, "author") and not has(e, "editor") and has(e, "key") { em = out(em, V(fld(e, "key"))) }
  em = out-year(em, ysuf(year-value(e)))
  em
}

// `xref-cite`: rendered parent citation when the entry keeps a `crossref` (parent
// is in the bibliography); `year-suffix`: \natexlab a/b/c disambiguator (author-year).
// The suffix attaches ONLY to the lead `output.year.check` year (verified against
// bibtex: an article's later "(2020)" journal date is NOT disambiguated).
#let handle(e, xref-cite: none, year-suffix: "") = {
  // append the \natexlab suffix to the lead year value (no-op in numeric mode)
  let ysuf = v => if year-suffix == "" { v } else { (c: v.c + year-suffix, p: v.p) }
  let lead = (em, e) => lead-author-year(em, e, ysuf)
  let has-xref = has(e, "crossref") and xref-cite != none
  let t = e.entry-type
  let em = em-init
  // aliases
  let manual-like = ("online", "game", "video", "artifactsoftware", "artifactdataset", "software", "dataset", "preprint", "manual")
  if t == "article" or t == "underreview" {
    em = lead(em, e)
    em = nblock(em)
    em = out(em, format-articletitle(e))
    em = nblock(em)
    em = out(em, howpub(e))
    em = nblock(em)
    if t == "underreview" { em = out(em, format-journal-underreview(e)) }
    else {
      if has-xref { em = out(em, format-article-crossref(e, xref-cite)) }
      else { em = out(em, format-journal-block(e)) }
      em = out(em, format-pages-noart(e))
      em = out(em, format-articleno-numpages(e))
    }
  } else if t == "book" or t == "inbook" {
    if has(e, "author") { em = out(em, format-authors(e)) } else { em = out(em, format-editors(e)) }
    em = out-year(em, ysuf(year-value(e)))
    em = nblock(em)
    em = out(em, format-btitle(e))
    if has-xref {
      // inbook prints chapter/pages before the crossref; book does not
      if t == "inbook" {
        em = out(em, format-bookpages(e))
        em = out(em, format-chapter-pages(e))
      }
      em = nblock(em)
      em = out(em, format-book-crossref(e, xref-cite))
    } else {
      em = nsentence(em)
      em = out(em, format-bvolume(e))
      em = nblock(em)
      em = out(em, format-number-series(e))
      em = nsentence(em)
      em = out(em, if has(e, "publisher") { V(fld(e, "publisher")) } else { none })
      em = out(em, if has(e, "address") { V(fld(e, "address")) } else { none })
      if t == "inbook" {
        em = out(em, format-bookpages(e))
        em = out(em, format-chapter-pages(e))
      } else {
        // book: fin.sentence, then bookpages OR "<pages> pages"
        em = nsentence(em)
        if has(e, "pages") { em = out(em, (c: dashify(fld(e, "pages")) + " pages", p: false)) }
        else { em = out(em, format-bookpages(e)) }
      }
    }
  } else if t == "incollection" {
    em = lead(em, e)
    em = nblock(em)
    em = out(em, format-articletitle(e))
    em = nblock(em)
    if has-xref {
      em = out(em, format-incoll-inproc-crossref(e, xref-cite))
      em = out(em, format-chapter-pages(e))
    } else {
      em = out(em, format-in-ed-booktitle(e))
      em = nsentence(em)
      em = out(em, format-bvolume(e))
      em = out(em, format-number-series(e))
      em = nsentence(em)
      em = out(em, if has(e, "publisher") { V(fld(e, "publisher")) } else { none })
      em = out(em, if has(e, "address") { V(fld(e, "address")) } else { none })
      em = out(em, format-bookpages(e))
      em = out(em, format-chapter-pages(e))
    }
  } else if t == "inproceedings" or t == "conference" or t == "presentation" {
    em = lead(em, e)
    em = nblock(em)
    em = out(em, format-articletitle(e))
    em = out(em, howpub(e), variant: "dotspace")
    if has-xref {
      em = out(em, format-incoll-inproc-crossref(e, xref-cite))
    } else {
      if t == "presentation" {
        em = nsentence(em)
        em = out(em, format-venue(e))
      } else {
        em = out(em, format-in-emph-booktitle(e), variant: "dotspace")
      }
      em = out(em, format-series(e), variant: "removenospace")
      em = out(em, format-editors-fml(e))
      if not has(e, "series") { em = out(em, format-bvolume-noseries(e)) }
      em = nsentence(em)
      em = out(em, if has(e, "organization") { V(fld(e, "organization")) } else { none })
      em = out(em, if has(e, "publisher") { V(fld(e, "publisher")) } else { none })
      em = out(em, if has(e, "address") { V(fld(e, "address")) } else { none })
      em = out(em, format-bookpages(e))
    }
    em = out(em, format-pages-noart(e))
    em = out(em, format-articleno-numpages(e))
  } else if t == "mastersthesis" or t == "phdthesis" {
    em = lead(em, e)
    em = nblock(em)
    em = out(em, format-title-emph(e))
    em = nblock(em)
    let default = if t == "phdthesis" { "Ph.\u{2009}D. Dissertation" } else { "Master's thesis" }
    em = out(em, format-thesis-type(e, default))
    em = nsentence(em)
    em = out(em, if has(e, "school") { V(fld(e, "school")) } else { none })
    em = out(em, if has(e, "address") { V(fld(e, "address")) } else { none })
    em = nblock(em)
    em = out(em, format-advisor(e))
  } else if t == "periodical" {
    if has(e, "editor") { em = out(em, format-editors(e)) }
    else if has(e, "organization") { em = out(em, V(fld(e, "organization"))) }
    em = nblock(em)
    em = out-year(em, ysuf(year-value(e)))
    em = nsentence(em)
    em = out(em, format-articletitle(e))
    em = nblock(em)
    em = out(em, format-journal-block(e))
    em = out(em, format-page-count(e))
  } else if t == "proceedings" or t == "collection" {
    // editor, else organization, else `format.key` fallback (org & editor absent)
    if has(e, "editor") { em = out(em, format-editors(e)) }
    else if has(e, "organization") { em = out(em, V(fld(e, "organization"))) }
    else if has(e, "key") { em = out(em, V(fld(e, "key"))) }
    em = out-year(em, ysuf(year-value(e)))
    em = nblock(em)
    let bt = format-btitle(e)
    if bt != none { bt = (c: bt.c + format-city(e), p: false) }
    em = out(em, bt)
    em = nsentence(em)
    em = out(em, format-bvolume(e))
    em = out(em, format-number-series(e))
    em = nsentence(em)
    em = out(em, if has(e, "organization") { V(fld(e, "organization")) } else { none })
    em = out(em, if has(e, "publisher") { V(fld(e, "publisher")) } else { none })
    em = out(em, if has(e, "address") { V(fld(e, "address")) } else { none })
  } else if t == "techreport" {
    em = lead(em, e)
    em = nblock(em)
    em = out(em, format-btitle(e))
    em = nblock(em)
    em = out(em, format-tr-number(e))
    em = nsentence(em)
    em = out(em, if has(e, "institution") { V(fld(e, "institution")) } else { none })
    em = out(em, if has(e, "address") { V(fld(e, "address")) } else { none })
    em = nsentence(em)
    em = out(em, if has(e, "pages") { (c: dashify(fld(e, "pages")) + " pages", p: false) } else { none })
  } else if t == "unpublished" {
    em = lead(em, e)
    em = nblock(em)
    em = out(em, format-title(e))          // plain title (not emphasized)
    em = nsentence(em)
    let ymd = format-day-month-year(e, lead: false)
    if ymd != none { em = out(em, ymd) }
    em = out(em, format-page-count(e))
    // note is required for @unpublished and emitted by the shared trailing block
  } else if t == "misc" or t == "booklet" {
    em = lead(em, e)
    em = nblock(em)
    em = out(em, format-title(e))
    em = nblock(em)
    em = out(em, if has(e, "howpublished") { V(fld(e, "howpublished")) } else { none })
    if t == "booklet" { em = out(em, if has(e, "address") { V(fld(e, "address")) } else { none }) }
    else { em = out(em, format-page-count(e)) }
  } else if t in manual-like {
    // manual & friends (online/software/dataset/preprint/...): title + org + address;
    // url/"Retrieved" comes from the shared trailing block.
    if has(e, "author") { em = out(em, format-authors(e)) }
    else if has(e, "editor") { em = out(em, format-editors(e)) }
    else if has(e, "organization") { em = out(em, V(fld(e, "organization"))) }
    else if has(e, "key") { em = out(em, V(fld(e, "key"))) }   // format.key fallback
    em = out-year(em, ysuf(year-value(e)))
    em = nblock(em)
    em = out(em, format-btitle(e))
    em = nblock(em)
    em = out(em, if has(e, "organization") { V(fld(e, "organization")) } else { none })
    em = out(em, if has(e, "address") { V(fld(e, "address")) } else { none })
  } else {
    // fallback: author. year. title.
    em = lead(em, e)
    em = nblock(em)
    em = out(em, format-title(e))
  }
  em-render(em, trailing(e))
}

// ---- sort key -------------------------------------------------------------
// .bst sort key: alphabetical by author/editor (von last first), then year, then
// title — ties on surname break by given name, like bibtex's label-based presort.
#let sort-key(e) = {
  let ppl = e.names.at("author", default: e.names.at("editor", default: ()))
  let names = ppl.map(n => (n.von + " " + n.last + " " + n.first).trim()).join(" ")
  if names == none { names = "" }   // ().join() is none, not ""
  // bibtex sorts on purify$(name): drops \commands + grouping braces and reduces
  // foreign chars to ASCII, so {{R Core Team}} sorts under "R" and "Stra\ss e"
  // under "Strasse" — exactly BibTeX's order. (tex.typ's purify is the faithful
  // port; lower() makes the compare case-insensitive, as our presort does.)
  names = lower(purify(names))
  if names == "" and has(e, "key") { names = lower(purify(fld(e, "key"))) }
  let y = if has(e, "year") { fld(e, "year") } else { "" }
  names + "   " + y + "   " + lower(purify(fld(e, "title", d: "")))
}
