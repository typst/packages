// Citations and reference lists for the BibTeX and BibLaTeX backends.

#import "bibtex.typ": parse-bib, parse-names
#import "tex.typ": tex-to-string
#import "acmref-common.typ": fld, has, is-others, von-last, it, fixing
#import "acmref-bst.typ": handle, sort-key, has as bst-has, year-value as bst-year-value
#import "acmref-biblatex.typ": blx-handle, blx-biber-datamodel, blx-sort-key, blx-np-lengths, blx-label-year
#import "acmref-blxnames.typ": name-list, disambiguate, list-label, list-context, list-namehash
#import "../formats/_base.typ": tp

#let cited-state = state("acmref-cited", ())
#let bib-path-state = state("acmref-bibpath", none)
#let bib-format-state = state("acmref-bibformat", "bst")
#let cite-style-state = state("acmref-citestyle", "numeric")

#let read-merged(paths) = {
  if type(paths) == arguments { return parse-bib(read(..paths)) }
  let ps = if type(paths) == array { paths } else { (paths,) }
  parse-bib(ps.map(p => read(p)).join("\n"))
}

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
    if xr not in listed { let _ = e.fields.remove("crossref") }
    db2.insert(k, e)
  }
  (db: db2, order: listed.sorted(key: k => sort-key(db2.at(k))))
}

// Biber counts crossref and xref promotions separately over directly cited entries.
// A promoted parent does not promote its own parent.
#let blx-min-refs = (crossref: 2, xref: 2)
#let blx-promotions(db, cited) = {
  let counts = (:)
  for rel in blx-min-refs.keys() { counts.insert(rel, (:)) }
  for k in cited {
    if k not in db { continue }
    for (rel, seen) in counts {
      let parent = db.at(k).fields.at(rel, default: none)
      if parent != none and parent in db {
        counts.at(rel).insert(parent, seen.at(parent, default: 0) + 1)
      }
    }
  }
  let out = ()
  for (rel, seen) in counts {
    for (parent, n) in seen {
      if n >= blx-min-refs.at(rel) and parent not in cited and parent not in out { out.push(parent) }
    }
  }
  out
}
#let resolve-biblatex(db, cited, style) = {
  let db2 = blx-biber-datamodel(db)
  let listed = cited.filter(k => k in db2) + blx-promotions(db2, cited)
  let lens = blx-np-lengths(listed.map(k => db2.at(k)))
  let useprefix = style != "author-year"
  (db: db2, order: listed.sorted(key: k => blx-sort-key(db2.at(k), lens: lens, useprefix: useprefix)))
}

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
#let pick(arr) = { let r = arr.find(x => x != none); if r == none { "" } else { r } }
#let labeltitle-field(e) = {
  let names = ("shorttitle", "title", "maintitle").filter(n => has(e, n))
  if names.len() == 0 { none } else { names.first() }
}
#let label-title(e, quoted: false) = {
  let name = labeltitle-field(e)
  if name == none { return none }
  let t = tex-to-string(fld(e, name))
  if quoted { "\u{201C}" + t + "\u{201D}" } else { t }
}
// Citation-label dispatch uses the original entry type, independently of formatter aliases.
#let bst-lab-label(e, full: false) = {
  let names-fn = if full { format-lab-names-full } else { format-lab-names }
  let au = if bst-has(e, "author") { names-fn(e.names.author) }
  let ed = if bst-has(e, "editor") { names-fn(e.names.editor) }
  let org = if bst-has(e, "organization") { tex-to-string(fld(e, "organization")) }
  let key = if bst-has(e, "key") { tex-to-string(fld(e, "key")) }
  if full { return pick((au, ed, org, key, "??")) }
  let ck = e.at("cite-key", default: "")
  let key3 = ck.clusters().slice(0, calc.min(3, ck.clusters().len())).join()
  let t = e.entry-type
  if t in ("book", "inbook", "article") { pick((au, ed, key, key3)) }
  else if t in ("proceedings", "periodical") { pick((ed, org, key, key3)) }
  else if t == "manual" { pick((au, ed, org, key, key3)) }
  else { pick((au, key, key3)) }
}

#let blx-citetitle-format(e) = {
  let t = e.entry-type
  if t in ("article", "inbook", "incollection", "inproceedings", "conference",
           "patent", "thesis", "mastersthesis", "phdthesis", "unpublished") { "quoted" }
  else if t in ("suppbook", "suppcollection", "suppperiodical") { "plain" }
  else { "emph" }
}
#let blx-lab-label(e, names, style) = {
  if names != none { return names }
  if style == "author-year" and has(e, "label") { return tex-to-string(fld(e, "label")) }
  let t = label-title(e, quoted: blx-citetitle-format(e) == "quoted")
  if t != none { return t }
  if has(e, "key") { return tex-to-string(fld(e, "key")) }
  ""
}

#let blx-label-people(e) = {
  if e.entry-type in ("proceedings", "periodical", "collection") {
    if has(e, "editor") { e.names.editor } else { none }
  } else {
    if has(e, "author") { e.names.author } else if has(e, "editor") { e.names.editor } else { none }
  }
}

#let blx-label-title-italic(e, style) = {
  if style == "author-year" and has(e, "label") { return false }
  blx-label-people(e) == none and labeltitle-field(e) != none and blx-citetitle-format(e) == "emph"
}

#let lab-dedup-key(e) = bst-lab-label(e) + "\u{0}" + bst-year-value(e).c
// Assign year suffixes in BibTeX presort order; the final reference order can split equal-label groups.
#let bst-extras(db, order) = {
  order = order.sorted(key: k => (lab-dedup-key(db.at(k)), sort-key(db.at(k))))
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

#let blx-extras(db, order, contexts) = {
  let group = k => {
    let y = blx-label-year(db.at(k))
    contexts.at(k) + "\u{0}" + (if y == none { "n.d." } else { y })
  }
  let counts = (:)
  for k in order { counts.insert(group(k), counts.at(group(k), default: 0) + 1) }
  let seen = (:)
  let res = (:)
  for k in order {
    let g = group(k)
    if counts.at(g) == 1 { res.insert(k, ""); continue }
    seen.insert(g, seen.at(g, default: 0) + 1)
    let letter = str.from-unicode(96 + seen.at(g))
    res.insert(k, if blx-label-year(db.at(k)) == none { "(" + letter + ")" } else { letter })
  }
  res
}

#let blx-labels(db, order, style) = {
  let unique = style == "author-year"
  let useprefix = not unique
  let lists = order
    .map(k => {
      let people = blx-label-people(db.at(k))
      if people != none { name-list(k, people) }
    })
    .filter(l => l != none)
  let dis = (:)
  for d in disambiguate(lists, unique: unique) { dis.insert(d.key, d) }
  let by-key = (:)
  for l in lists { by-key.insert(l.key, l) }

  let labels = (:)
  let contexts = (:)
  let hashes = (:)
  for k in order {
    let e = db.at(k)
    let named = k in dis
    labels.insert(k, (
      text: blx-lab-label(e, if named { list-label(by-key.at(k), dis.at(k), useprefix: useprefix) }, style),
      italic: blx-label-title-italic(e, style),
      named: named,
    ))
    hashes.insert(k, if named { list-namehash(by-key.at(k), dis.at(k)) } else { "\u{0}" + k })
    // An entry with neither labelname nor labeltitle needs a unique context to prevent year lettering.
    let lt = labeltitle-field(e)
    contexts.insert(k, if named { "n\u{0}" + list-context(by-key.at(k), dis.at(k)) }
      else if lt != none { "t\u{0}" + str.normalize(tex-to-string(fld(e, lt)), form: "nfc") }
      else { "k\u{0}" + k })
  }
  (labels: labels, hashes: hashes, extras: blx-extras(db, order, contexts))
}

#let bst-labels(db, order) = {
  let res = (:)
  for k in order { res.insert(k, (text: bst-lab-label(db.at(k)), italic: false)) }
  res
}

#let prepared() = {
  let path = bib-path-state.final()
  if path == none { return none }
  let db = read-merged(path)
  for (k, e) in db { db.insert(k, e + (cite-key: k)) }
  let cited = cited-state.final()
  let fmt = bib-format-state.final()
  let style = cite-style-state.final()
  let res = if fmt == "biblatex" { resolve-biblatex(db, cited, style) } else { resolve-crossref(db, cited) }
  res + (fmt: fmt) + if fmt == "biblatex" { blx-labels(res.db, res.order, style) } else {
    (labels: bst-labels(res.db, res.order), extras: bst-extras(res.db, res.order))
  }
}

#let cite-order(keys, order) = keys.filter(k => k in order).sorted(key: k => order.position(x => x == k))

#let cite-year(p, k) = {
  if p.fmt == "biblatex" { let y = blx-label-year(p.db.at(k)); if y == none { "n.d." } else { y } }
  else { bst-year-value(p.db.at(k), nodate: "[n.\u{2009}d.]").c }
}
#let cite-label(p, k) = p.labels.at(k).text
#let cite-label-content(p, k) = {
  let label = p.labels.at(k)
  if label.italic { it(label.text) } else { label.text }
}

#let entry-label(key) = label("acmref:" + key)
#let cite-num-link(num, key) = link(entry-label(key))[#num]

#let cite-ay(p, keys, mode: "citep", supplement: none) = {
  let ks = cite-order(keys, p.order)
  let lgroups = ()
  for k in ks {
    // authoryear-comp groups by namehash, which can distinguish identical printed labels.
    let lbl = if "hashes" in p { p.hashes.at(k) } else { cite-label(p, k) }
    let shown = cite-label-content(p, k)
    let yr = (base: cite-year(p, k), suf: p.extras.at(k, default: ""))
    if lgroups.len() > 0 and lgroups.at(-1).label == lbl { lgroups.at(-1).years.push(yr) }
    else { lgroups.push((label: lbl, shown: shown, years: (yr,), key: k)) }
  }
  let render-years(years) = {
    let ybits = ()
    for y in years {
      if ybits.len() > 0 and ybits.at(-1).base == y.base { ybits.at(-1).sufs.push(y.suf) }
      else { ybits.push((base: y.base, sufs: (y.suf,))) }
    }
    // \bibrangedash forbids line breaks within a year range.
    ybits.map(b => box(b.base + b.sufs.join(","))).join(", ")
  }
  let years = g => render-years(g.years)
  let tail(i) = if mode != "citep" and supplement != none and i == lgroups.len() - 1 {
    [, #supplement]
  } else { [] }
  let parts = lgroups.enumerate().map(((i, g)) => link(entry-label(g.key),
    if mode == "citet" { g.shown + " [" + years(g) + tail(i) + "]" }
    else { g.shown + " " + years(g) + tail(i) }))
  let note = if mode == "citep" and supplement != none { [, #supplement] } else { [] }
  if mode == "citep" { "[" + parts.join("; ") + note + "]" } else { parts.join("; ") }
}
#let numeric-textcite(p, ks, brackets: true, supplement: none) = {
  let ordered = cite-order(ks, p.order)
  ordered.enumerate().map(((i, k)) => {
    let num = p.order.position(x => x == k) + 1
    let label = cite-label-content(p, k)
    let note = if supplement != none and i == ordered.len() - 1 { [, #supplement] } else { [] }
    link(entry-label(k), if brackets { [#label \[#num#note\]] } else { [#label #num#note] })
  }).join(", ")
}

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

#let numeric-cite(p, ks, supplement: none) = {
  let pairs = ks.map(k => (num: p.order.position(x => x == k) + 1, key: k))
  let inner = if p.fmt == "biblatex" {
    pairs.map(pair => cite-num-link(pair.num, pair.key)).join(", ")
  } else {
    collapse-linked(pairs)
  }
  let note = if supplement != none { [, #supplement] } else { [] }
  [[#inner#note]]
}

#let ensure-known(ks, db) = {
  for k in ks {
    assert(k in db, message: "faithful-acmart: key `" + k + "` does not exist in the bibliography")
  }
}

#let register-cites(ks) = cited-state.update(cur => {
  for k in ks { if k not in cur { cur.push(k) } }
  cur
})

#let with-prepared(ks, body) = {
  register-cites(ks)
  context {
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
}

#let bbl-cite(..keys) = {
  let ks = keys.pos()
  let supp = keys.named().at("supplement", default: none)
  with-prepared(ks, p => {
    if cite-style-state.get() == "author-year" {
      cite-ay(p, ks, supplement: supp)
    } else {
      numeric-cite(p, ks, supplement: supp)
    }
  })
}

#let bbl-nocite(..keys) = with-prepared(keys.pos(), _ => none)

#let bbl-fullcite(..keys) = {
  let ks = keys.pos()
  with-prepared(ks, p => {
    let ay = cite-style-state.get() == "author-year"
    let extras = if ay { p.extras } else { (:) }
    ks.map(k => {
      let e = p.db.at(k)
      let suffix = extras.at(k, default: "")
      if p.fmt == "biblatex" {
        blx-handle(e, style: cite-style-state.get(), year-suffix: suffix)
      } else {
        let xr = e.fields.at("crossref", default: none)
        let n = if xr == none { none } else { p.order.position(x => x == xr) }
        let xref-cite = if n != none {
          if ay { cite-ay(p, (xr,), mode: "citet") } else { [[#cite-num-link(n + 1, xr)]] }
        }
        handle(e, xref-cite: xref-cite, year-suffix: suffix)
      }
    }).join(" ")
  })
}

#let bbl-citet(..keys) = {
  let ks = keys.pos()
  let supp = keys.named().at("supplement", default: none)
  with-prepared(ks, p => {
    if cite-style-state.get() == "author-year" {
      cite-ay(p, ks, mode: "citet", supplement: supp)
    } else {
      numeric-textcite(p, ks, supplement: supp)
    }
  })
}

#let bbl-citealt(..keys) = {
  let ks = keys.pos()
  let supp = keys.named().at("supplement", default: none)
  with-prepared(ks, p => {
    if cite-style-state.get() == "author-year" {
      cite-ay(p, ks, mode: "citealt", supplement: supp)
    } else {
      numeric-textcite(p, ks, brackets: false, supplement: supp)
    }
  })
}

#let bbl-citeyearpar(..keys) = {
  let ks = keys.pos()
  let supp = keys.named().at("supplement", default: none)
  with-prepared(ks, p => {
    let extras = if cite-style-state.get() == "author-year" { p.extras } else { (:) }
    let note = if supp != none { [, #supp] } else { [] }
    "[" + cite-order(ks, p.order).map(k =>
      link(entry-label(k), cite-year(p, k) + extras.at(k, default: ""))).join(", ") + note + "]"
  })
}

#let bbl-shortcite(..keys) = context {
  if cite-style-state.get() == "author-year" { bbl-citeyearpar(..keys) } else { bbl-cite(..keys) }
}

// natbib drops author/year postnotes in numeric mode; BibLaTeX keeps them.
#let keeps-postnote(p) = p.fmt == "biblatex" or cite-style-state.get() == "author-year" or fixing()

#let bbl-citeyear(..keys) = {
  let ks = keys.pos()
  let supp = keys.named().at("supplement", default: none)
  with-prepared(ks, p => {
    let extras = if cite-style-state.get() == "author-year" { p.extras } else { (:) }
    let note = if supp != none and keeps-postnote(p) { [, #supp] } else { [] }
    cite-order(ks, p.order).map(k => cite-year(p, k) + extras.at(k, default: "")).join(", ") + note
  })
}
#let bbl-citeauthor(..keys) = {
  let ks = keys.pos()
  let supp = keys.named().at("supplement", default: none)
  with-prepared(ks, p => {
    // acmauthoryear patches \citeauthor to fall back to titles; acmnumeric leaves nameless entries empty.
    let bare = p.fmt == "biblatex" and cite-style-state.get() != "author-year"
    let note = if supp != none and keeps-postnote(p) { [, #supp] } else { [] }
    cite-order(ks, p.order)
      .filter(k => not (bare and not p.labels.at(k).at("named", default: true)))
      .map(k => link(entry-label(k), cite-label-content(p, k))).join("; ") + note
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
    let extras = if ay { p.extras } else { (:) }
    let num-of = (:)
    for (i, k) in order.enumerate() { num-of.insert(k, i + 1) }
    set text(size: size)
    set par(justify: true, first-line-indent: 0pt, leading: if leading == auto { 0.65em } else { leading })
    // BibLaTeX uses twice amsart's \labelsep (biblatex.def, \biblabelsep).
    // Measure labels at bibliography size.
    let labelsep = if format == "biblatex" { 2 * 5 * tp } else { 5 * tp }
    let labelwidth = measure(text(size: size)[[#order.len()]]).width
    if title != none { heading(level: 1, numbering: none, outlined: true, title) }
    for (i, key) in order.enumerate() {
      let e = db.at(key)
      let xref-cite = none
      let xr = e.fields.at("crossref", default: none)
      if xr != none and xr in num-of {
        xref-cite = if ay { cite-ay(p, (xr,), mode: "citet") } else { [[#cite-num-link(num-of.at(xr), xr)]] }
      }
      let body = if format == "biblatex" {
        blx-handle(e, style: cite-style-state.get(), year-suffix: extras.at(key, default: ""))
      } else {
        handle(e, xref-cite: xref-cite, year-suffix: extras.at(key, default: ""))
      }
      let entry = if ay {
        // natbib freezes \bibhang at load-time font size.
        block(par(hanging-indent: 10 * tp, body))
      } else {
        grid(columns: (labelwidth, 1fr), column-gutter: labelsep, align: (right, left),
          [[#(i + 1)]], body)
      }
      // Attach the label in markup so it binds to the entry content.
      [#entry#entry-label(key)]
    }
  }
}
