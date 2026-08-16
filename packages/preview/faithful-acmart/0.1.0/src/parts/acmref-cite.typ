// ACM bibliography cite, sort, and bibliography orchestration.

#import "bibtex.typ": read-bib, parse-bib, parse-names
#import "tex.typ": tex-to-string
#import "acmref-common.typ": fld, has, is-others, von-last, year-value, it
#import "acmref-bst.typ": handle, sort-key
#import "acmref-biblatex.typ": blx-handle, blx-biber-datamodel, blx-sort-key

// ---- cite/number layer ----------------------------------------------------
#let cited-state = state("acmref-cited", ())
#let bib-path-state = state("acmref-bibpath", none)
#let bib-format-state = state("acmref-bibformat", "bst")
// "numeric" (default) or "author-year" — set by the acmart show rule from the
// `cite-style` option, mirroring acmart's \citestyle{acmnumeric|acmauthoryear}.
#let cite-style-state = state("acmref-citestyle", "numeric")

// accept a single path, a list of paths, or an `arguments` value carrying one path.
// The `arguments` case comes from the `bibliography` shadow for a single source: it
// is threaded here un-indexed and read with `read(..paths)` so a RELATIVE path keeps
// the caller's location (Typst resolves it against where the args were constructed).
// Extracted string/array paths have lost that origin, so they must be absolute.
#let read-merged(paths) = {
  if type(paths) == arguments { return parse-bib(read(..paths)) }
  let ps = if type(paths) == array { paths } else { (paths,) }
  let db = (:)
  for p in ps { db = db + read-bib(p) }
  db
}

// ---- crossref resolution (BibTeX engine behaviour, not the .bst) -----------
// BibTeX (not the .bst) inherits a crossref parent's missing fields into the
// child, and adds the parent to the reference list only when it is crossref'd
// >= min_crossrefs (=2) times or cited directly. A child whose parent IS listed
// renders "See [parent]" (the .bst's format.*.crossref); a child whose parent is
// NOT listed keeps the inherited fields and renders in full (BibTeX strips its
// crossref). Verified against real bibtex (both thresholds + field inheritance).
#let min-crossrefs = 2
#let resolve-crossref(db, cited) = {
  let counts = (:)
  for k in cited {
    if k not in db { continue }
    let xr = db.at(k).fields.at("crossref", default: none)
    if xr != none and xr in db { counts.insert(xr, counts.at(xr, default: 0) + 1) }
  }
  let listed = cited.filter(k => k in db)
  for (xr, c) in counts {
    if c >= min-crossrefs and xr not in listed { listed.push(xr) }
  }
  let db2 = db
  for k in listed {
    let e = db2.at(k)
    let xr = e.fields.at("crossref", default: none)
    if xr == none or xr not in db { continue }
    let parent = db.at(xr)
    for (fk, fv) in parent.fields {
      if fk == "crossref" { continue }
      if fk not in e.fields {
        e.fields.insert(fk, fv)
        if fk == "author" or fk == "editor" { e.names.insert(fk, parse-names(fv)) }
      }
    }
    if xr not in listed { let _ = e.fields.remove("crossref") }   // parent excluded -> full render
    db2.insert(k, e)
  }
  (db: db2, order: listed.sorted(key: k => sort-key(db2.at(k))))
}

#let resolve-biblatex(db, cited) = {
  let db2 = blx-biber-datamodel(db)
  let listed = cited.filter(k => k in db2)
  (db: db2, order: listed.sorted(key: k => blx-sort-key(db2.at(k))))
}

// resolved (db, order) for the current cited set, or `none` if no acmart
// `#bibliography` ever registered a path (`bib-path-state` still `none`). Callers
// turn that into an actionable error — see `with-prepared`.
#let prepared() = {
  let path = bib-path-state.final()
  if path == none { return none }
  let db = read-merged(path)
  let cited = cited-state.final()
  if bib-format-state.final() == "biblatex" { resolve-biblatex(db, cited) }
  else { resolve-crossref(db, cited) }
}

// ---- author-year labels (format.lab.names + calc.basic.label dispatch) -----
// short citation label: von+Last only, " and " for two, "et al." for >2 (or "and
// others"). von-last is RAW; tex-to-string gives the plain label used for both
// display and (suffix-)grouping comparison.
#let format-lab-names(people) = {
  if people.len() == 0 { return "" }
  if people.len() > 2 { return tex-to-string(von-last(people.at(0))) + " et al." }
  let s = von-last(people.at(0))
  if people.len() == 2 {
    if is-others(people.at(1)) { s = s + " et al." } else { s = s + " and " + von-last(people.at(1)) }
  }
  s = tex-to-string(s)
  s
}
#let format-lab-names-full(people) = {
  people.map(n => tex-to-string(von-last(n))).join(" and ")
}
#let format-blx-lab-names(people, full: false, count: none) = {
  let last = people.map(n => if is-others(n) { "et al." } else { tex-to-string(von-last(n)) })
  if last.len() == 0 { return "" }
  if full or count != none and count >= last.len() {
    if last.len() == 1 { return last.first() }
    if last.len() == 2 {
      if last.at(1) == "et al." { return last.first() + " et al." }
      return last.first() + " and " + last.at(1)
    }
    return last.slice(0, -1).join(", ") + ", and " + last.last()
  }
  if count != none {
    if count <= 1 { return last.first() + " et al." }
    return last.slice(0, count).join(", ") + ", et al."
  }
  if last.len() == 1 { return last.first() }
  if last.len() == 2 {
    if last.at(1) == "et al." { return last.first() + " et al." }
    return last.first() + " and " + last.at(1)
  }
  last.first() + " et al."
}
#let pick(arr) = { let r = arr.find(x => x != none); if r == none { "" } else { r } }
#let label-title(e, quoted: false) = if has(e, "title") {
  let t = tex-to-string(fld(e, "title"))
  if quoted { "\u{201C}" + t + "\u{201D}" } else { t }
}
// Entry types the .bst / biblatex treat as "manual-like" for label + title dispatch.
#let manual-like-types = ("manual", "online", "game", "video", "artifactsoftware", "artifactdataset", "software", "softwareversion", "softwaremodule", "codefragment", "dataset", "preprint")

// calc.basic.label's type dispatch: which field supplies the .bst citation label.
// `full: true` is the disambiguation label (all names spelled out via format-lab-names-full).
#let bst-lab-label(e, full: false) = {
  let t = e.entry-type
  let names-fn = if full { format-lab-names-full } else { format-lab-names }
  let au = if has(e, "author") { names-fn(e.names.author) }
  let ed = if has(e, "editor") { names-fn(e.names.editor) }
  let org = if has(e, "organization") { tex-to-string(fld(e, "organization")) }
  let key = if has(e, "key") { tex-to-string(fld(e, "key")) }
  if t in ("book", "inbook", "article") { pick((au, ed, key)) }
  else if t in ("proceedings", "periodical", "collection") { pick((ed, org, key)) }
  else if t in manual-like-types { pick((au, ed, org, key)) }
  else { pick((au, key)) }
}
#let bst-lab-disambiguation-label(e) = bst-lab-label(e, full: true)

#let blx-lab-label(e, full: false) = {
  let t = e.entry-type
  let au = if has(e, "author") { format-blx-lab-names(e.names.author, full: full) }
  let ed = if has(e, "editor") { format-blx-lab-names(e.names.editor, full: full) }
  let org = if has(e, "organization") { tex-to-string(fld(e, "organization")) }
  let title = label-title(e, quoted: t in ("article", "inproceedings", "conference", "presentation", "incollection"))
  let key = if has(e, "key") { tex-to-string(fld(e, "key")) }
  if t in ("book", "inbook", "article") { pick((au, ed, title, key)) }
  else if t in ("proceedings", "periodical", "collection") { pick((ed, org, title, key)) }
  else { pick((au, ed, org, title, key)) }
}

#let blx-label-people(e) = {
  if e.entry-type in ("proceedings", "periodical", "collection") {
    if has(e, "editor") { e.names.editor } else { none }
  } else {
    if has(e, "author") { e.names.author } else if has(e, "editor") { e.names.editor } else { none }
  }
}

#let blx-label-title-italic(e) = {
  e.entry-type in manual-like-types and not has(e, "author") and not has(e, "editor") and not has(e, "organization") and has(e, "title")
}

#let name-prefix-len(left, right) = {
  let i = 0
  while i < left.len() and i < right.len() and tex-to-string(von-last(left.at(i))) == tex-to-string(von-last(right.at(i))) {
    i += 1
  }
  i
}

#let lab-label(e) = if bib-format-state.final() == "biblatex" {
  blx-lab-label(e)
} else {
  bst-lab-label(e)
}

#let lab-disambiguation-label(e) = if bib-format-state.final() == "biblatex" {
  blx-lab-label(e, full: true)
} else {
  bst-lab-disambiguation-label(e)
}

// \natexlab a/b/c suffixes: a..z over consecutive (label, year)-equal entries in
// sorted order (forward.pass/reverse.pass); singletons get "".
#let lab-dedup-key(e) = {
  let label = if bib-format-state.final() == "biblatex" { lab-disambiguation-label(e) } else { bst-lab-label(e) }
  label + "\u{0}" + year-value(e).c
}
#let extra-labels(db, order) = {
  let res = (:)
  let i = 0
  while i < order.len() {
    let k = lab-dedup-key(db.at(order.at(i)))
    let j = i
    while j < order.len() and lab-dedup-key(db.at(order.at(j))) == k { j += 1 }
    let grp = order.slice(i, j)
    if grp.len() == 1 { res.insert(grp.at(0), "") }
    else { for (m, gk) in grp.enumerate() { res.insert(gk, str.from-unicode(97 + m)) } }
    i = j
  }
  res
}

// cited keys reordered into reference-list (sorted) order
#let cite-order(keys, order) = keys.filter(k => k in order).sorted(key: k => order.position(x => x == k))

#let cite-label(k, db, order) = {
  let e = db.at(k)
  if bib-format-state.final() != "biblatex" { return lab-label(e) }
  let people = blx-label-people(e)
  if people != none and people.len() > 2 {
    let full = format-blx-lab-names(people, full: true)
    let count = 1
    for ok in order {
      if ok == k { continue }
      let other = blx-label-people(db.at(ok))
      if other == none { continue }
      if format-blx-lab-names(other, full: true) == full { continue }
      let prefix = name-prefix-len(people, other)
      if prefix > 0 and prefix + 1 > count { count = prefix + 1 }
    }
    if count > 1 {
      if count > people.len() { count = people.len() }
      return format-blx-lab-names(people, count: count)
    }
  }
  let short = blx-lab-label(e)
  let full = blx-lab-label(e, full: true)
  let year = year-value(e).c
  for ok in order {
    if ok == k { continue }
    let oe = db.at(ok)
    if year-value(oe).c == year and blx-lab-label(oe) == short and blx-lab-label(oe, full: true) != full {
      return full
    }
  }
  short
}
#let cite-label-content(k, db, order) = {
  let label = cite-label(k, db, order)
  if bib-format-state.final() == "biblatex" and blx-label-title-italic(db.at(k)) { it(label) } else { label }
}

// ---- cite -> reference-list hyperlinks -------------------------------------
// Each reference entry carries `entry-label(key)`; cites `link` to it, matching
// LaTeX+hyperref's in-text cite anchors (the golden gate is raster-based and the
// link gate compares only external /URI targets, so these internal goto links are
// invisible to both). The label is namespaced to avoid clashing with user labels.
#let entry-label(key) = label("acmref:" + key)
#let cite-num-link(num, key) = link(entry-label(key))[#num]

// natbib author-year \citep/\citet: group consecutive same-label entries, then
// group their years by base year so suffixes collapse ("2020a,b,c"); ", " between
// distinct years, "; " between author groups. \citet puts years in brackets.
#let cite-ay(keys, db, order, extras, citet: false) = {
  let ks = cite-order(keys, order)
  let lgroups = ()
  for k in ks {
    let lbl = cite-label(k, db, order)
    let shown = cite-label-content(k, db, order)
    let yr = (base: year-value(db.at(k)).c, suf: extras.at(k, default: ""))
    if lgroups.len() > 0 and lgroups.at(-1).label == lbl { lgroups.at(-1).years.push(yr) }
    else { lgroups.push((label: lbl, shown: shown, years: (yr,), key: k)) }
  }
  let render-years(years) = {
    let ybits = ()
    for y in years {
      if ybits.len() > 0 and ybits.at(-1).base == y.base { ybits.at(-1).sufs.push(y.suf) }
      else { ybits.push((base: y.base, sufs: (y.suf,))) }
    }
    ybits.map(b => b.base + b.sufs.join(",")).join(", ")
  }
  // link each author group to its first entry (hyperref anchors the whole citation)
  let parts = lgroups.map(g => link(entry-label(g.key),
    if citet { g.shown + " [" + render-years(g.years) + "]" }
    else { g.shown + " " + render-years(g.years) }))
  if citet { parts.join("; ") } else { "[" + parts.join("; ") + "]" }
}

// collapse [1,2,3,5] -> "1–3, 5", each number linked to its entry. `pairs` are
// (num, key) so the range endpoints keep their own link targets.
#let collapse-linked(pairs) = {
  let s = pairs.sorted(key: p => p.num)
  let groups = ()
  for p in s {
    if groups.len() > 0 and p.num == groups.at(-1).at(-1).num + 1 { groups.at(-1).push(p) }
    else { groups.push((p,)) }
  }
  groups.map(g => if g.len() >= 3 {
    [#cite-num-link(g.first().num, g.first().key)\u{2013}#cite-num-link(g.last().num, g.last().key)]
  } else {
    g.map(p => cite-num-link(p.num, p.key)).join(", ")
  }).join(", ")
}

// numeric \cite: each cited key -> its reference-list number; the .bst collapses
// ranges while BibLaTeX lists them in command order. Every key is known here
// (ensure-known ran first, so `position` never returns none).
#let numeric-cite(ks, order) = {
  let pairs = ks.map(k => (num: order.position(x => x == k) + 1, key: k))
  if bib-format-state.final() == "biblatex" {
    [[#pairs.map(p => cite-num-link(p.num, p.key)).join(", ")]]
  } else {
    [[#collapse-linked(pairs)]]
  }
}

// An undefined citation key is a hard error, matching Typst's native `cite`/`@key`
// ("key `x` does not exist in the bibliography") rather than LaTeX's silent "[?]".
#let ensure-known(ks, db) = {
  for k in ks {
    assert(k in db, message: "faithful-acmart: key `" + k + "` does not exist in the bibliography")
  }
}

#let register-cites(ks) = cited-state.update(cur => {
  for k in ks { if k not in cur { cur.push(k) } }
  cur
})

// Run `body(p)` in a cite context. `prepared()` is `none` only when no acmart
// `#bibliography` ever registered a path (`bib-path-state` still holds its `none`
// init) — a real misconfiguration, since on the bibtex/biblatex backends `@key` /
// `#cite` resolve against acmart's own `bibliography`. (When the acmart bibliography
// IS in scope, Typst pre-collects its state update, so `.final()` reliably returns
// the path on every layout pass — verified: none of the twins ever hit this branch.
// So erroring here is safe; it does not abort a valid document mid-convergence.)
// The old code called `read()` on the `none` path instead, crashing with a cryptic
// "expected string, found none" deep in the .bib reader.
#let with-prepared(ks, body) = context {
  let p = prepared()
  assert(p != none, message:
    "faithful-acmart: cited a key but no bibliography is registered to resolve it. On "
    + "the `bibtex`/`biblatex` backends, `@key` / `#cite` resolve through "
    + "faithful-acmart's `#bibliography` (not Typst's built-in). Make sure you (1) import "
    + "the template with `*` (`#import \"...\": *`, not just `acmart`) so `bibliography` "
    + "shadows the built-in, and (2) call `#bibliography(\"refs.bib\")`.")
  ensure-known(ks, p.db)
  body(p)
}

// numeric: .bst collapses ranges, BibLaTeX preserves command order; author-year:
// \citep "[Label Year]"
#let bbl-cite(..keys) = {
  let ks = keys.pos()
  register-cites(ks)
  with-prepared(ks, p => {
    if cite-style-state.get() == "author-year" {
      cite-ay(ks, p.db, p.order, extra-labels(p.db, p.order))
    } else {
      numeric-cite(ks, p.order)
    }
  })
}

// \citet "Label [Year]" (author-year); falls back to numeric brackets otherwise
#let bbl-citet(..keys) = {
  let ks = keys.pos()
  register-cites(ks)
  with-prepared(ks, p => {
    if cite-style-state.get() == "author-year" {
      cite-ay(ks, p.db, p.order, extra-labels(p.db, p.order), citet: true)
    } else {
      numeric-cite(ks, p.order)
    }
  })
}

// \citeyear: just the year(s) with suffix; \citeauthor: just the label
#let bbl-citeyear(..keys) = {
  let ks = keys.pos()
  register-cites(ks)
  with-prepared(ks, p => {
    let extras = extra-labels(p.db, p.order)
    cite-order(ks, p.order).map(k => year-value(p.db.at(k)).c + extras.at(k, default: "")).join(", ")
  })
}
#let bbl-citeauthor(..keys) = {
  let ks = keys.pos()
  register-cites(ks)
  with-prepared(ks, p => {
    cite-order(ks, p.order).map(k => link(entry-label(k), cite-label-content(k, p.db, p.order))).join("; ")
  })
}

#let bbl-bibliography(path, title: [References], size: 8pt, leading: auto, format: "bst") = {
  bib-path-state.update(path)
  bib-format-state.update(format)
  context {
    let p = prepared()
    let db = p.db
    let order = p.order
    let ay = cite-style-state.get() == "author-year"
    let extras = if ay { extra-labels(db, order) } else { (:) }
    let num-of = (:)
    for (i, k) in order.enumerate() { num-of.insert(k, i + 1) }
    set text(size: size)
    set par(justify: true, first-line-indent: 0pt, leading: if leading == auto { 0.65em } else { leading })
    if title != none { heading(level: 1, numbering: none, outlined: false, title) }
    for (i, key) in order.enumerate() {
      let e = db.at(key)
      // "See [parent]" citation for a child whose parent is in the list
      let xref-cite = none
      let xr = e.fields.at("crossref", default: none)
      if xr != none and xr in num-of {
        xref-cite = if ay { cite-ay((xr,), db, order, extras, citet: true) } else { [[#cite-num-link(num-of.at(xr), xr)]] }
      }
      let body = if format == "biblatex" {
        blx-handle(e, style: cite-style-state.get(), year-suffix: extras.at(key, default: ""))
      } else {
        handle(e, xref-cite: xref-cite, year-suffix: extras.at(key, default: ""))
      }
      let entry = if ay {
        // author-year list: no numbers, hanging indent (acmart \bibhang)
        block(par(hanging-indent: 1.8em, body))
      } else {
        grid(columns: (2.4em, 1fr), gutter: 0pt, [[#(i + 1)]], body)
      }
      // in-text cites `link` here (see `entry-label`); the label must be attached
      // in markup (a bare label in a code block can't join with content)
      [#entry#entry-label(key)]
    }
  }
}
