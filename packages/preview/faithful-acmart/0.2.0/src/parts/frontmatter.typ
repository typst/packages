// Render titles, authors, and publication metadata for each format.

#import "copyright.typ": permission-text, copyright-owner
#import "spacing.typ": comp, tex-skip
#import "strings.typ": lang-record
#import "body.typ": in-topmatter
#import "punct.typ": add-punct
#import "tex.typ": script-super
#import "../formats/_base.typ": tp

// \@fnsymbol uses a math asterisk; \correspondingauthor uses a text asterisk.
#let fnsymbols = ("∗", "†", "‡", "§", "¶", "‖", "∗∗", "††", "‡‡")
#let corresponding-mark = "*"

#let month-names = (
  "January", "February", "March", "April", "May", "June",
  "July", "August", "September", "October", "November", "December",
)

#let pub-date(meta) = [#month-names.at(meta.acm-month - 1) #meta.acm-year]

#let doi-link(doi) = link(doi.url)[#doi.url]

// The zero-height box prevents superscript marks from increasing line height.
#let note-super(mark) = box(height: 0pt, align(bottom, script-super(mark)))

#let andify(items) = {
  let n = items.len()
  if n == 0 { return none }
  if n == 1 { return items.at(0) }
  if n == 2 { return items.slice(0, 2).join([ and ]) }
  (items.slice(0, n - 1).join([, ]), items.at(n - 1)).join([, and ])
}

#let affil-list(aff) = {
  if aff == none { () } else if type(aff) == array { aff } else { (aff,) }
}

#let normalize-author(a) = {
  let note = a.at("note", default: none)
  let affiliation = a.at("affiliation", default: none)
  for aff in affil-list(affiliation) {
    let country = aff.at("country", default: none)
    assert(country != none and (type(country) != str or country.trim() != ""),
      message: "faithful-acmart: every author affiliation must include a nonempty `country`, "
        + "matching acmart's required \\country field. Author: " + repr(a.name) + ".")
  }
  (
    name: a.name,
    orcid: a.at("orcid", default: none),
    affiliation: affiliation,
    email: a.at("email", default: none),
    note: if note == none { () } else if type(note) == array { note } else { (note,) },
    corresponding: a.at("corresponding", default: false),
    // Preserve declaration order for replaying \email and \affiliation in contact information.
    contact-order: a.keys().filter(k => k == "email" or k == "affiliation"),
  )
}

#let orcid-url(orcid) = {
  assert(type(orcid) == str, message: "faithful-acmart: author `orcid` must be a string, got " + repr(orcid))
  if orcid.starts-with("http") { orcid } else { "https://orcid.org/" + orcid }
}

#let author-name(a, body) = if a.orcid == none { body } else { link(orcid-url(a.orcid), body) }

#let email-link(email) = link("mailto:" + email)[#email]

#let join-fields(d, keys) = {
  let vals = keys.map(k => d.at(k, default: none)).filter(v => v != none)
  if vals.len() == 0 { none } else { vals.join(", ") }
}

#let affil-strings(aff, keys) = affil-list(aff).map(a => join-fields(a, keys)).filter(v => v != none)

#let contact-affil-fields = ("institution", "department", "city", "state", "country")
#let contact-affil-strings(aff) = affil-list(aff).map(a => {
  join-fields(a, a.keys().filter(k => k in contact-affil-fields))
}).filter(v => v != none)

#let affil-short(aff) = {
  let affs = affil-strings(aff, ("institution", "country"))
  if affs.len() == 0 { none } else { andify(affs) }
}

#let affil-conf-lines(aff) = affil-list(aff).map(a => {
  let lines = ("position", "institution", "department").map(k => a.at(k, default: none))
  lines.push(join-fields(a, ("city", "state", "country")))
  lines.filter(v => v != none)
}).flatten()

#let kw-join(kw) = if type(kw) == array { kw.join(", ") } else { kw }

// In \@mkauthors@i, an affiliation closes the group accumulated so far.
// Equal affiliations on separate authors still close separate groups.
#let group-authors(authors) = {
  let groups = ()
  let pending = ()
  for a in authors {
    pending.push(a)
    if a.affiliation != none {
      groups.push((affiliation: a.affiliation, authors: pending))
      pending = ()
    }
  }
  if pending.len() > 0 {
    groups.push((affiliation: none, authors: pending))
  }
  groups
}

#let parse-ccs(ccs) = {
  if ccs == none { return none }
  let src = if type(ccs) == str { ccs } else if type(ccs) == content {
    let r = if ccs.func() == raw { ccs } else if ccs.has("children") {
      ccs.children.find(c => c.func() == raw)
    }
    if r != none { r.text }
  }
  if src == none {
    assert(type(ccs) == array,
      message: "faithful-acmart: `ccs` must be an array of (significance, area, "
        + "concept) tuples or the ACM CCS tool's output as a string/raw block, got "
        + repr(ccs))
    return if ccs.len() == 0 { none } else { ccs }
  }
  // \ccsdesc@parse discards text after the second tilde.
  let concept(sig, desc) = {
    assert(sig == none or sig.trim().match(regex("^[0-9]+$")) != none,
      message: "faithful-acmart: non-numeric CCS significance " + repr(sig))
    let parts = desc.split("~")
    let spec = parts.at(1, default: "").trim()
    (if sig == none { 100 } else { int(sig.trim()) },
     parts.first().trim(),
     if spec == "" { none } else { spec })
  }
  // Reject partial parsing so malformed descriptions cannot silently fall back to the XML.
  let uses = src.matches(regex("\\\\ccsdesc\\b")).len()
  let descs = src.matches(regex("\\\\ccsdesc\\b\\s*(?:\\[\\s*([0-9]+)\\s*\\])?\\s*\\{([^{}]*)\\}"))
  if uses > 0 {
    assert(descs.len() == uses,
      message: "faithful-acmart: " + str(uses - descs.len()) + " of " + str(uses)
        + " \\ccsdesc uses in `ccs` are malformed; expected "
        + "\\ccsdesc[significance]{Area~Specific} with a numeric significance "
        + "and no braces in the argument.")
    return descs.map(m => concept(m.captures.first(), m.captures.at(1)))
  }
  let roots = src.matches(regex("(?s)<ccs2012>.*?</ccs2012>"))
  assert(roots.len() == 1,
    message: "faithful-acmart: a `ccs` string must contain \\ccsdesc lines or exactly "
      + "one <ccs2012> element (found " + str(roots.len()) + "); paste the ACM CCS "
      + "tool's output (https://dl.acm.org/ccs).")
  let text-of(node) = node.children.fold("", (acc, c) => if type(c) == str { acc + c } else { acc })
  let concepts = ()
  for c in xml(bytes(roots.first().text)).first().children {
    if type(c) != dictionary or c.tag != "concept" { continue }
    let field(tag) = {
      let n = c.children.find(k => type(k) == dictionary and k.tag == tag)
      if n != none { text-of(n) }
    }
    let desc = field("concept_desc")
    assert(desc != none and desc.trim() != "",
      message: "faithful-acmart: <concept> in `ccs` lacks a <concept_desc>")
    concepts.push(concept(field("concept_significance"), desc))
  }
  assert(concepts.len() > 0,
    message: "faithful-acmart: the <ccs2012> element in `ccs` has no <concept> entries")
  concepts
}

#let render-ccs-concepts(ccs) = {
  let areas = ()
  let by-area = (:)
  let all-specific = true
  for entry in ccs {
    assert(type(entry) == array and entry.len() >= 2,
      message: "each ccs-concepts entry must be a (significance, area, specific?) tuple, got " + repr(entry))
    let sig = entry.at(0)
    let area = entry.at(1)
    let spec = entry.at(2, default: none)
    if area not in by-area {
      by-area.insert(area, ())
      areas.push(area)
    }
    if spec != none and spec != "" {
      by-area.at(area).push((sig: sig, spec: spec))
    } else {
      all-specific = false
    }
  }
  let style-spec(s) = {
    if s.sig >= 500 { strong(s.spec) }
    else if s.sig >= 300 { emph(s.spec) }
    else { s.spec }
  }
  // \ccsdesc decrements its concept counter only for specifics.
  // An area-only entry leaves the closing separator as a semicolon.
  for (i, area) in areas.enumerate() {
    if i > 0 { [; ] }
    [• #strong(area)]
    let specs = by-area.at(area)
    if specs.len() > 0 {
      [ → ]
      specs.map(style-spec).join("; ")
    }
  }
  if all-specific { [.] } else { [;] }
}

// Explicit paragraphs receive separate PDF tags; consecutive inline blocks can merge.
// Use only for single-paragraph content because par() collapses internal paragraph breaks.
#let tagged-par(body) = par(body)

#let fm-block(cfg, body, sz: "small", justify: true, indent: 0pt, spacing: 0pt, chunk: false) = {
  let lead = comp(cfg, sz: sz)
  block(width: 100%, spacing: spacing)[
    #set text(font: cfg.fonts.body, size: cfg.size.at(sz))
    #set par(
      justify: justify,
      leading: lead,
      first-line-indent: indent,
      spacing: lead,
    )
    #if chunk { tagged-par(body) } else { body }
  ]
}

#let special-line(cfg, label, content) = {
  let sz = if cfg.journal { "small" } else { "normalsize" }
  let pf = cfg.sec-fonts.paragraph
  let head = if cfg.journal { [#label:] } else { text(weight: pf.weight, style: pf.style)[#label:] }
  v(tex-skip(cfg, cfg.medskip, sz: sz), weak: true)
  fm-block(cfg, [#head #content], sz: sz, spacing: comp(cfg, sz: sz), chunk: true)
}

#let collect-notes(meta) = {
  let anon = meta.anonymous
  let notes = ()
  // \maketitle reserves the first symbol for the corresponding author, even when absent.
  let idx = 1
  let title-mark = none
  let subtitle-mark = none
  let symbol-at(i) = {
    assert(i < fnsymbols.len(), message: "faithful-acmart: too many top-matter notes for the available footnote symbols")
    fnsymbols.at(i)
  }

  let corresponding-present = not anon and meta.authors.any(a => a.corresponding)
  if corresponding-present {
    notes.push((symbol: fnsymbols.at(0), body: [Corresponding author]))
  }
  if meta.title-note != none {
    title-mark = symbol-at(idx)
    notes.push((symbol: title-mark, body: if anon { [Title note] } else { meta.title-note }))
    idx += 1
  }
  if meta.subtitle-note != none {
    subtitle-mark = symbol-at(idx)
    notes.push((symbol: subtitle-mark, body: if anon { [Subtitle note] } else { meta.subtitle-note }))
    idx += 1
  }

  let seen = (:)
  let marks = ()
  for a in meta.authors {
    let m = ()
    if corresponding-present and a.corresponding { m.push(corresponding-mark) }
    if not anon {
      for note in a.note {
        let key = repr(note)
        if key not in seen {
          seen.insert(key, symbol-at(idx))
          notes.push((symbol: seen.at(key), body: note))
          idx += 1
        }
        m.push(seen.at(key))
      }
    }
    marks.push(m)
  }
  (title-mark: title-mark, subtitle-mark: subtitle-mark, notes: notes, marks: marks)
}

#let contact-line(a) = {
  let parts = (author-name(a, a.name),)
  for field in a.contact-order {
    if field == "affiliation" {
      let affs = contact-affil-strings(a.affiliation)
      if affs.len() > 0 { parts.push(affs.join(" and ")) }
    } else if a.email != none {
      parts.push(email-link(a.email))
    }
  }
  parts.join(", ")
}

// \raisebox{-2ex} measures ex in the surrounding footnote font, before the stamp switches size.
#let draft-stamp(cfg) = context {
  let ex = measure(text(size: cfg.size.footnotesize, top-edge: "x-height", bottom-edge: "baseline")[x]).height
  place(top + left, dy: 2 * ex + cfg.size.footnotesize - cfg.size.large,
    text(size: cfg.size.large, weight: "bold")[Unpublished working draft. Not for distribution.])
}

#let conf-info-line(cfg, meta) = {
  let booktitle-form = { if meta.booktitle != none { emph[#meta.booktitle, #meta.acm-year.] } }
  if cfg.name == "acmengage" {
    booktitle-form
  } else if meta.conference != none {
    let c = meta.conference
    let short = c.at("short", default: c.at("name", default: none))
    let venue = c.at("venue", default: none)
    let parts = (short, venue).filter(v => v != none)
    if parts.len() > 0 { emph(parts.join(", ")) }
  } else {
    booktitle-form
  }
}

#let make-footnotes(cfg, meta) = {
  let fs = cfg.size.footnotesize
  let lead = comp(cfg, sz: "footnotesize")
  let ni = collect-notes(meta)
  let j = meta.journal

  let rule(width) = {
    v(cfg.footnote-rule-kern-above, weak: true)
    line(length: width, stroke: 0.4pt)
    v(cfg.footnote-rule-kern-below, weak: true)
  }

  let stack = {
    set text(font: cfg.fonts.body, size: fs)
    set par(justify: true, leading: lead, first-line-indent: 0pt, spacing: lead)

    let anon = meta.anonymous
    let thanks = if meta.thanks == none { () } else if type(meta.thanks) == array { meta.thanks } else { (meta.thanks,) }
    let has-contact-info = cfg.name != "acmcp" and cfg.bibstrip-or-tog and not anon and (
      if meta.authors-addresses == auto { meta.authors.len() > 0 } else { meta.authors-addresses != none }
    )
    let mode = meta.copyright
    let ptext = permission-text(mode, cc-type: meta.cc-type, cc-version: meta.cc-version)
    let has-copyright-info = cfg.name != "acmcp" and (
      if meta.nonacm { mode == "cc" and ptext != none } else { true }
    )

    if ni.notes.len() > 0 {
      rule(cfg.footnote-rule-short)
      for n in ni.notes {
        block(spacing: lead, tagged-par[#note-super(n.symbol)#n.body])
      }
      if thanks.len() > 0 or has-contact-info or has-copyright-info {
        // manyfoot inserts \skip\footins between streams; the rule's kern pulls back into that gap.
        let stream-gap = cfg.footins-skip - cfg.footnote-rule-kern-above
        v(stream-gap, weak: false)
      }
    }

    if thanks.len() > 0 or has-contact-info {
      rule(100%)
      for t in thanks {
        block(spacing: lead, tagged-par[#add-punct(if anon [A note] else { t }, fix: cfg.fix-quirks)])
      }
      if has-contact-info {
        if meta.authors-addresses == auto {
          let label = if meta.authors.len() > 1 { "Authors' Contact Information:" } else { "Author's Contact Information:" }
          let contacts = meta.authors.map(contact-line).join("; ")
          block(spacing: lead, tagged-par[#add-punct([#label #contacts], fix: cfg.fix-quirks)])
        } else {
          block(spacing: lead, tagged-par[#add-punct(meta.authors-addresses, fix: cfg.fix-quirks)])
        }
      }
    }

    if cfg.name == "acmcp" {
      // Contact information goes in the cover infobox.
    } else if meta.nonacm {
      if mode == "cc" and ptext != none {
        rule(100%)
        block(spacing: lead, ptext)
      }
    } else {
      rule(100%)
      block(spacing: lead, {
        if meta.author-draft { draft-stamp(cfg) }
        set text(fill: if meta.author-draft { luma(90%) } else { black })
        // \par boundaries add \parskip; explicit line breaks retain the ordinary baseline interval.
        set par(spacing: lead + 0.1 * cfg.bls.footnotesize)
        if not meta.author-version and ptext != none { ptext; parbreak() }
        let proceedings-copyright = cfg.name != "manuscript" and not cfg.bibstrip
        if proceedings-copyright {
          let cl = conf-info-line(cfg, meta)
          if cl != none { cl; parbreak() }
        }
        let owner = copyright-owner(mode)
        if owner != none {
          [© #meta.copyright-year #owner]
          linebreak()
        } else {
          [#meta.copyright-year. ]
        }
        if cfg.name == "manuscript" {
          [Manuscript submitted to ACM]
        } else if meta.author-version {
          let venue = if cfg.bibstrip { j.name } else { meta.booktitle }
          [This is the author's version of the work. It is posted here for your personal use. Not for redistribution. The definitive Version of Record was published in #emph(venue)#{
            if meta.doi != none [, #doi-link(meta.doi).]
            else [.]
          }]
        } else if cfg.bibstrip {
          // str() separates the month expression from the literal -ART suffix in markup.
          [ACM #j.issn/#meta.acm-year/#str(meta.acm-month)-ART#{
            if meta.acm-article != none { str(meta.acm-article) }
          }]
          if meta.doi != none {
            linebreak()
            doi-link(meta.doi)
          }
        } else {
          if meta.isbn != none and meta.isbn != "" { [ACM ISBN #meta.isbn]; linebreak() }
          if meta.doi != none {
            doi-link(meta.doi)
          }
        }
      })
    }
  }

  place(bottom, float: true, clearance: cfg.footins-skip - cfg.footnote-rule-kern-above,
    block(width: 100%, spacing: 0pt, stack))
}

#let make-acmcp-infobox(cfg, meta) = {
  assert(meta.acmcp-logo != none, message:
    "faithful-acmart: the `acmcp` cover format needs a journal logo — pass `acmcp-logo: image(\"...\")` "
    + "(the ACM journal logo is ACM's trademark and is not bundled with this package).")
  let big = tex-skip(cfg, cfg.bigskip, sz: "scriptsize")
  box(width: 60 * tp)[
    #set align(left)
    #{ set image(width: 100%); meta.acmcp-logo }
    #set text(size: cfg.size.scriptsize)
    #set par(justify: false, first-line-indent: 0pt, leading: comp(cfg, sz: "scriptsize"))
    #if meta.code-data-link != none { v(big, weak: true); [Code and data links:\ #meta.code-data-link] }
    #if meta.keywords != none { v(big, weak: true); [Keywords: #kw-join(meta.keywords)] }
    #if meta.contributions != none { v(big, weak: true); meta.contributions }
    #if meta.authors.len() > 0 {
      v(big, weak: true)
      let label = if meta.authors.len() > 1 { "Authors' Contact Information:" } else { "Author's Contact Information:" }
      if meta.anonymous {
        [#label Anonymous Author(s).]
      } else {
        let contacts = meta.authors.map(contact-line).join("; ")
        [#label #contacts.]
      }
    }
  ]
}

// Bottom alignment reproduces acmart's zref adjustment of the infobox against the body frame.
#let make-acmcp-cover(cfg, meta, art-color, body) = {
  let tint = art-color.lighten(90%)
  let fbox = 3 * tp // \fboxsep
  let body-reduction = 6.5 * 12 * tp
  let framed-body = pad(left: -fbox, block(
    fill: tint,
    inset: fbox,
    width: 100% + 2 * fbox,
    body,
  ))
  block(width: 100%, breakable: false, spacing: 0pt, grid(
    columns: (1fr, body-reduction),
    column-gutter: 0pt,
    grid.cell(align: top + left)[#framed-body],
    grid.cell(align: bottom + right)[#make-acmcp-infobox(cfg, meta)],
  ))
}

#let title-cap-height(cfg) = {
  let tf = cfg.title-font
  measure(text(font: cfg.fonts.at(tf.family), weight: tf.weight, size: cfg.size.at(tf.size),
    top-edge: "cap-height", bottom-edge: "baseline")[X]).height
}

// With cap-height as the top edge, title leading must compensate for cap height instead of font size.
#let title-block(cfg, meta, mark) = context {
  let tf = cfg.title-font
  let lead = cfg.bls.at(tf.size) - title-cap-height(cfg)
  block(spacing: 0pt, width: if cfg.title-width-reduction != 0pt { 100% - cfg.title-width-reduction } else { auto })[
    #set text(font: cfg.fonts.at(tf.family), weight: tf.weight, size: cfg.size.at(tf.size),
      top-edge: "cap-height", bottom-edge: "baseline")
    #set par(justify: false, first-line-indent: 0pt, leading: lead, spacing: lead)
    #tagged-par[#meta.title#if mark != none { note-super(mark) }]
    #for (l, t) in meta.translated-title {
      parbreak()
      text(lang: lang-record(l).code, t)
    }
  ]
}

// The subtitle's closing \par lies outside its font group, so it uses the title's baseline interval (\@mktitle@i).
#let subtitle-block(cfg, meta, mark) = {
  if meta.subtitle == none { return }
  let sf = cfg.subtitle-font
  let lead = cfg.bls.at(cfg.title-font.size) - cfg.size.at(sf.size)
  block(above: lead, below: tex-skip(cfg, 0pt))[
    #set text(font: cfg.fonts.at(sf.family), weight: sf.weight, size: cfg.size.at(sf.size))
    #set par(justify: false, first-line-indent: 0pt, leading: lead, spacing: lead)
    #tagged-par[#meta.subtitle#if mark != none { note-super(mark) }]
    #for (l, t) in meta.translated-subtitle {
      parbreak()
      v(0.51em, weak: true)
      text(lang: lang-record(l).code, t)
    }
  ]
}

// After the tall title box, TeX falls back to \lineskip abutment.
// Subtract the subtitle's extra depth to keep the following material at that boundary.
#let subtitle-extra(cfg, meta) = if meta.subtitle == none { 0pt } else {
  (cfg.bls.at(cfg.title-font.size) - cfg.size.at(cfg.subtitle-font.size)) - tex-skip(cfg, 0pt)
}

#let render-marks(marks) = marks.map(note-super).join()

#let mark-authors(meta, ni) = meta.authors.enumerate().map(((i, a)) => a + (_marks: ni.marks.at(i)))

#let anon-author-strip(cfg, meta, width: auto, weight: none, upper-case: false, tagged: false) = {
  let af = cfg.author-font
  let body = [Anonymous Author(s)#if meta.submission-id != none [\ Submission Id: #meta.submission-id]]
  if upper-case { body = upper(body) }
  if tagged { body = tagged-par(body) }
  block(spacing: 0pt, width: width)[
    #set text(font: cfg.fonts.at(af.family), size: cfg.size.at(af.size), ..(if weight != none { (weight: weight) } else { (:) }))
    #body
  ]
}

#let teaser-figure(meta) = {
  in-topmatter.update(true)
  block(width: 100%, spacing: 0pt)[
    #set figure(placement: none)
    #meta.teaser
  ]
  in-topmatter.update(false)
}

#let journal-title-head(cfg, meta) = {
  let ni = collect-notes(meta)
  title-block(cfg, meta, ni.title-mark)
  subtitle-block(cfg, meta, ni.subtitle-mark)

  let af = cfg.author-font
  let aff-f = cfg.affil-font
  // Combine the title's trailing \bigskip with the author block's leading \medskip.
  v(tex-skip(cfg, cfg.bigskip + cfg.medskip, sz: af.size) - subtitle-extra(cfg, meta), weak: true)

  let author-width = if cfg.title-width-reduction != 0pt { 100% - cfg.title-width-reduction } else { auto }
  if meta.anonymous {
    anon-author-strip(cfg, meta, width: author-width, weight: af.weight, upper-case: true, tagged: true)
  } else {
  block(spacing: 0pt, width: author-width)[
    #set par(justify: false, leading: comp(cfg, sz: af.size), spacing: 0pt)
    #for g in group-authors(mark-authors(meta, ni)) {
      let names = g.authors.map(a => { author-name(a, upper(a.name)); render-marks(a._marks) })
      block(spacing: comp(cfg, sz: af.size))[
        #tagged-par[#text(font: cfg.fonts.at(af.family), weight: af.weight, size: cfg.size.at(af.size))[#andify(names)]#{
          let aff = affil-short(g.affiliation)
          if aff != none {
            text(font: cfg.fonts.at(aff-f.family), weight: aff-f.weight, size: cfg.size.at(aff-f.size))[, #aff]
          }
        }]
      ]
    }
  ]
  }

  if meta.teaser != none {
    v(tex-skip(cfg, cfg.medskip + cfg.bigskip), weak: true)
    teaser-figure(meta)
  }
  v(tex-skip(cfg, cfg.medskip, sz: "small"), weak: true)
}

#let author-grid-box(cfg, group, contact-fn, align-x: center, fli: 0pt) = {
  let af = cfg.author-font
  let aff = cfg.affil-font
  set align(align-x)
  set text(font: cfg.fonts.at(af.family), weight: af.weight, size: cfg.size.at(af.size))
  set par(justify: false, first-line-indent: fli, leading: comp(cfg, sz: af.size), spacing: comp(cfg, sz: af.size))
  group.authors.map(a => { author-name(a, a.name); render-marks(a._marks) }).join(linebreak())
  parbreak()
  set text(font: cfg.fonts.at(aff.family), weight: aff.weight, size: cfg.size.at(aff.size))
  set par(leading: comp(cfg, sz: aff.size), spacing: comp(cfg, sz: aff.size))
  contact-fn(group).join(linebreak())
}

#let make-authors-grid(cfg, groups, authors-per-row: 0) = {
  if groups.len() == 0 { return [] }
  let sep = 12 * tp // \author@bx@sep
  let tw = cfg.paper.width - cfg.margin.inside - cfg.margin.outside
  let n = if authors-per-row > 0 { authors-per-row } else {
    let g = groups.len()
    if g <= 3 { g } else if g == 4 { 2 } else { 3 }
  }
  let bw = (tw - sep) / n - sep
  let contact-fn(group) = {
    let lines = ()
    for a in group.authors {
      for field in a.contact-order {
        if field == "email" and a.email != none { lines.push(email-link(a.email)) }
        else if field == "affiliation" { lines += affil-conf-lines(group.affiliation) }
      }
    }
    lines
  }
  let fli = cfg.parindent
  stack(dir: ttb, spacing: 12 * tp /* \lineskip */, ..groups.chunks(n).map(row => align(center, grid(
    columns: (bw,) * row.len(),
    column-gutter: sep,
    ..row.map(g => author-grid-box(cfg, g, contact-fn, fli: fli)),
  ))))
}

#let conf-title-head(cfg, meta) = {
  let ni = collect-notes(meta)
  set align(center)
  title-block(cfg, meta, ni.title-mark)
  subtitle-block(cfg, meta, ni.subtitle-mark)
  v(tex-skip(cfg, cfg.bigskip + cfg.medskip) - subtitle-extra(cfg, meta), weak: true)
  if meta.anonymous {
    anon-author-strip(cfg, meta)
  } else {
    make-authors-grid(cfg, group-authors(mark-authors(meta, ni)), authors-per-row: meta.authors-per-row)
  }
  // The author grid closes with \bigskip and \@mkteasers adds another.
  if meta.teaser != none {
    v(tex-skip(cfg, 2 * cfg.bigskip), weak: true)
    teaser-figure(meta)
  }
}

#let sigchi-authors(cfg, groups, authors-per-row: 0) = {
  let sep = 12 * tp // \author@bx@sep
  let tw = cfg.paper.width - cfg.margin.left - cfg.margin.right
  let n = if authors-per-row > 0 { authors-per-row } else if groups.len() <= 1 { 1 } else { 2 }
  let bw = (tw - sep) / n - sep
  let contact-fn(group) = group.authors.map(a => a.email).filter(e => e != none).map(email-link) + affil-conf-lines(group.affiliation)
  stack(dir: ttb, spacing: 12 * tp /* \lineskip */, ..groups.chunks(n).map(row => grid(
    columns: (bw,) * row.len(),
    column-gutter: sep,
    align: top + left,
    ..row.map(g => author-grid-box(cfg, g, contact-fn, align-x: left)),
  )))
}

#let sigchi-title-head(cfg, meta) = context {
  let ni = collect-notes(meta)
  let tf = cfg.title-font
  let cap-h = title-cap-height(cfg)
  let last-size = if meta.subtitle != none { cfg.subtitle-font.size } else { tf.size }
  let desc = measure(text(size: cfg.size.at(last-size), top-edge: "baseline", bottom-edge: "descender")[gjpqy]).height
  pad(left: 5 * 12 * tp, {
    // Use a filled rectangle so the rule thickness occupies layout height.
    block(above: 0pt, below: cfg.bls.at(tf.size) - cap-h,
      rect(width: 100%, height: 2pt, fill: black, stroke: none))
    title-block(cfg, meta, ni.title-mark)
    subtitle-block(cfg, meta, ni.subtitle-mark)
  })
  // sigchiamode defers authors until after \@printtopmatter, placing teasers before them.
  // The gap starts at the title box's bottom, including its descender.
  let box-gap = desc + tex-skip(cfg, 2 * cfg.bigskip) - subtitle-extra(cfg, meta)
  if meta.teaser != none {
    v(box-gap, weak: true)
    teaser-figure(meta)
    v(tex-skip(cfg, cfg.medskip + cfg.bigskip), weak: true)
  } else {
    v(box-gap, weak: true)
  }
  if meta.anonymous {
    anon-author-strip(cfg, meta, weight: cfg.author-font.weight)
  } else {
    sigchi-authors(cfg, group-authors(mark-authors(meta, ni)), authors-per-row: meta.authors-per-row)
  }
  v(tex-skip(cfg, cfg.bigskip), weak: true)
}

#let make-title-head(cfg, meta) = if cfg.title-style == "conf-center" {
  conf-title-head(cfg, meta)
} else if cfg.title-style == "sigchi-rule" {
  sigchi-title-head(cfg, meta)
} else {
  journal-title-head(cfg, meta)
}

#let special-section(cfg, label, content, lang: none) = {
  if (cfg.journal and cfg.name != "acmcp") or cfg.name == "sigplan" {
    special-line(cfg, label, if lang != none { text(lang: lang, content) } else { content })
  } else {
    heading(numbering: none, outlined: false)[#label]
    fm-block(cfg, if lang != none { text(lang: lang, content) } else { content }, sz: "normalsize", chunk: true)
  }
}

#let engage-metadata-block(cfg, items) = {
  if items.len() == 0 { return }
  block(width: 100%, spacing: 0pt)[
    #set text(font: cfg.fonts.body, size: cfg.size.normalsize)
    #set par(justify: true, first-line-indent: 0pt, leading: comp(cfg), spacing: comp(cfg))
    #for item in items {
      let label = item.first()
      let value = item.last()
      strong(label)
      [ ]
      value
      parbreak()
    }
  ]
}

// acmengage overrides \abstractname only in \captionsenglish.
#let abstract-name(cfg, language) = {
  if cfg.name == "acmengage" and language in (none, "english") { return "Synopsis" }
  if language == none { cfg.strings.abstract } else { lang-record(language).abstract }
}

#let make-title-body(cfg, meta) = {
  if cfg.name == "acmengage" {
    engage-metadata-block(cfg, meta.engage-metadata)
  }

  let render-abstract(name, body) = if cfg.journal {
    fm-block(cfg, body, indent: cfg.parindent)
  } else {
    heading(numbering: none, outlined: false)[#name]
    fm-block(cfg, body, indent: cfg.parindent, sz: "normalsize")
  }
  if meta.abstract != none { render-abstract(abstract-name(cfg, cfg.strings.main), meta.abstract) }
  for (l, ab) in meta.translated-abstract {
    render-abstract(abstract-name(cfg, l), text(lang: lang-record(l).code, ab))
  }

  if meta.ccs != none and meta.print-ccs {
    special-section(cfg, [CCS Concepts], render-ccs-concepts(meta.ccs))
  }

  if meta.keywords != none and cfg.name != "acmcp" {
    let label = if cfg.journal { cfg.strings.keywords } else { cfg.strings.keywords_proceedings }
    special-section(cfg, label, kw-join(meta.keywords))
  }
  if cfg.name != "acmcp" {
    for (l, kw) in meta.translated-keywords {
      let rec = lang-record(l)
      let label = if cfg.journal { rec.keywords } else { rec.keywords_proceedings }
      special-section(cfg, label, kw-join(kw), lang: rec.code)
    }
  }

  if meta.print-acm-reference {
    let j = meta.journal
    let proceedings-ref = not cfg.bibstrip
    v(tex-skip(cfg, cfg.medskip, sz: "small"), weak: true)
    context {
      // \ref{TotPages} counts physical sheets independently of \startPage.
      let start = if meta.start-page == none { 1 } else { meta.start-page }
      let total = counter(page).final().first() - (start - 1)
      fm-block(cfg, [
        #strong[ACM Reference Format:]\
        #{ if meta.anonymous [Anonymous Author(s)] else { andify(meta.authors.map(a => a.name)) } }. #meta.acm-year. #meta.title#{
          if meta.subtitle != none [: #meta.subtitle]
        }. #if not meta.nonacm {
          if not proceedings-ref {
            [#if j.short != none { emph(j.short) + " " }#meta.acm-volume, #meta.acm-number#if meta.acm-article != none [, Article #meta.acm-article] (#pub-date(meta)), #total #if total == 1 [page] else [pages].]
          } else {
            [In #emph(meta.booktitle)#if meta.editors.len() == 0 [#emph[.]] else [#emph[, ]#andify(meta.editors) (#if meta.editors.len() == 1 [Ed.] else [Eds.]).] ACM, New York, NY, USA#if meta.acm-article != none [, Article #meta.acm-article], #total #if total == 1 [page] else [pages].]
          }
        }#{
          if meta.doi != none [ #doi-link(meta.doi)]
        }
      ], chunk: true)
    }
  }

  v(tex-skip(cfg, cfg.bigskip), weak: true)
}

#let make-title(cfg, meta) = {
  make-title-head(cfg, meta)
  make-title-body(cfg, meta)
}

#let format-received(received) = {
  if type(received) != array { return received }
  let parts = ()
  for (i, item) in received.enumerate() {
    let (stage, date) = if type(item) == array and item.len() >= 2 { (item.at(0), item.at(1)) }
      else if type(item) == array { (none, item.at(0, default: none)) }
      else { (none, item) }
    let s = if stage == none or stage == "" {
      if i == 0 { "Received" } else { "revised" }
    } else { stage }
    parts.push([#s #date])
  }
  parts.join([; ])
}

#let make-received(cfg, received) = {
  v(tex-skip(cfg, cfg.bigskip, sz: "small"), weak: true)
  block(width: 100%, spacing: 0pt)[
    #set text(font: cfg.fonts.body, weight: "regular", style: "normal", size: cfg.size.small)
    #set par(justify: true, leading: comp(cfg, sz: "small"), first-line-indent: 0pt)
    #format-received(received)
  ]
}

#let make-badges(badges) = {
  let l = badges.at("left", default: none)
  let r = badges.at("right", default: none)
  grid(columns: (1fr, 1fr),
    align(left + bottom, l),
    align(right + bottom, r))
}
