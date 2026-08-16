// Title block / frontmatter for acmsmall (journal layout).
//
// Mirrors acmart's \maketitle for the journal formats: title (LARGE sans bold,
// left aligned), author lines (large sans uppercase names + small serif
// affiliation, grouped structurally per acmart — see group-authors), then
// abstract / CCS / keywords /
// ACM reference format. See the acmsmall-frontmatter-specs memory for sources.

#import "copyright.typ": permission-text, copyright-owner
#import "spacing.typ": comp, tex-skip
#import "journals.typ": lookup-journal
#import "strings.typ": lang-record

#let fnsymbols = ("∗", "†", "‡", "§", "¶", "‖", "∗∗", "††", "‡‡")

#let month-names = (
  "January", "February", "March", "April", "May", "June",
  "July", "August", "September", "October", "November", "December",
)

// acm-month/acm-year always carry a value (acmart defaults \acmMonth/\acmYear to
// the current date; see acmart() in lib.typ), so no presence check is needed.
// Assembled as content (not a joined string) so the year int renders directly.
#let pub-date(meta) = [#month-names.at(meta.acm-month - 1) #meta.acm-year]

#let has-isbn(meta) = meta.isbn != none and meta.isbn != ""

// Match LaTeX \@textsuperscript marks. Typst's super() scales its body further;
// the Dingbats-style envelope needs less inner scaling than text glyph marks.
#let note-super(mark) = super(text(size: if mark == "✉" { 1.05em } else { 1.22em })[#mark])

// Join a list of names the ACM/amsart "andify" way ("a", "a and b",
// "a, b, and c"). Items may be strings (author names) or content (names carrying
// superscript note marks); the result is content in either case.
#let andify(items) = {
  let n = items.len()
  if n == 0 { return none }
  if n == 1 { return items.at(0) }
  if n == 2 { return items.slice(0, 2).join([ and ]) }
  (items.slice(0, n - 1).join([, ]), items.at(n - 1)).join([, and ])
}

// Fill in the optional author fields so the rest of the code can use plain field
// access (a.email, a.note, ...) instead of defensive `.at(..., default:)`.
#let normalize-author(a) = (
  name: a.name,
  orcid: a.at("orcid", default: none),
  affiliation: a.at("affiliation", default: none),
  email: a.at("email", default: none),
  note: a.at("note", default: none),
  corresponding: a.at("corresponding", default: false),
  // The order the email and affiliation were declared, preserved so the contact
  // line can replay them in that order — acmart prints \addresses in the order
  // the \email/\affiliation commands were issued (acmart.dtx:7588), and Typst
  // dicts keep insertion order, so the author dict's key order is the analog.
  contact-order: a.keys().filter(k => k == "email" or k == "affiliation"),
)

// \orcid wraps the author's visible name in a link to the ORCID profile. A bare
// identifier is resolved against https://orcid.org/; an explicit URL is used as-is.
#let orcid-url(orcid) = {
  assert(type(orcid) == str, message: "faithful-acmart: author `orcid` must be a string, got " + repr(orcid))
  if orcid.starts-with("http") { orcid } else { "https://orcid.org/" + orcid }
}

#let author-name(a, body) = if a.orcid == none { body } else { link(orcid-url(a.orcid), body) }

// acmart renders \email{addr} as \href{mailto:addr}{addr}: the address is both the
// visible text and the mailto target (acmart.dtx:7478/7551/7608). Wrap the address
// so the contact lines carry the same hidden mailto annotations LaTeX emits.
#let email-link(email) = link("mailto:" + email)[#email]

// An author's `affiliation` may be a single dict or an array of dicts (a person
// with several affiliations, like LaTeX's repeated \affiliation). Normalize to a
// list of dicts; none -> empty list.
#let affil-list(aff) = {
  if aff == none { () } else if type(aff) == array { aff } else { (aff,) }
}

// Join the present (non-none) values of `keys` from dict `d` with ", ". Returns
// none — not "" — when no field is present, so absence is *always* `none` (a
// single rule the callers can filter on uniformly).
#let join-fields(d, keys) = {
  let vals = keys.map(k => d.at(k, default: none)).filter(v => v != none)
  if vals.len() == 0 { none } else { vals.join(", ") }
}

// The present affiliation strings of `aff` (one ", "-joined run of `keys` per
// affiliation dict, empty affiliations dropped via join-fields' none).
#let affil-strings(aff, keys) = affil-list(aff).map(a => join-fields(a, keys)).filter(v => v != none)

// Title-block affiliation: institution, country (city/state go to contact info).
// Multiple affiliations are joined with " and ", as LaTeX joins institutions.
#let affil-short(aff) = {
  let affs = affil-strings(aff, ("institution", "country"))
  if affs.len() == 0 { none } else { affs.join(" and ") }
}

// Conference/proceedings author-grid affiliation, as separate lines. acmart's
// non-journal field macros (acmart.dtx:7130) put \position, \institution and
// \department each on their own line (\par), while \city/\state/\country
// accumulate into one ", "-joined address line. (Journal mode collapses the
// whole thing to institution, country — that is affil-short.)
#let affil-conf-lines(aff) = affil-list(aff).map(a => {
  let lines = ("position", "institution", "department").map(k => a.at(k, default: none))
  lines.push(join-fields(a, ("city", "state", "country")))
  lines.filter(v => v != none)
}).flatten()

// Keywords may be an array (joined with ", ") or a ready string/content.
#let kw-join(kw) = if type(kw) == array { kw.join(", ") } else { kw }

// Group authors exactly as acmart's \@mkauthors@i does (acmart.dtx:7337-7371) —
// the unconditional rule for journal formats incl. acmsmall (the \@mkauthors
// \ifcase routes acmsmall to @i, acmart.dtx:7160). Authors accumulate onto one
// line; an \affiliation closes that line and attaches itself to EVERY author
// accumulated so far, then the next author starts a fresh line. Consequences,
// matching acmart and NOT a value comparison (acmart never compares affiliations):
//   - an author with no affiliation is andified onto the following author(s);
//   - authors that each carry an affiliation get their own line, even when the
//     affiliations are identical;
//   - trailing affiliation-less authors share a final, affiliation-less line.
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

// CCS concepts: group by area (preserving order), style specifics by
// significance (>=500 bold, >=300 italic, else roman), join with "; ",
// bullet + bold area + arrow per group, trailing period. Input: list of
// (significance, area, specific) tuples (mirrors \ccsdesc[sig]{area~specific}).
#let render-ccs-concepts(ccs) = {
  // preserve area order
  let areas = ()
  let by-area = (:)
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
    }
  }
  let style-spec(s) = {
    if s.sig >= 500 { strong(s.spec) }
    else if s.sig >= 300 { emph(s.spec) }
    else { s.spec }
  }
  // \ccsdesc separates every concept (areas and specifics) with "; " and ends
  // with "." (acmart.dtx:5994-6006), so areas are joined by "; " too.
  for (i, area) in areas.enumerate() {
    if i > 0 { [; ] }
    [• #strong(area)]
    let specs = by-area.at(area)
    if specs.len() > 0 {
      [ → ]
      specs.map(style-spec).join("; ")
    }
  }
  [.]
}

// Wrap inline content as an explicit paragraph so Typst's PDF tagger emits it as
// its own <P> structure element. Typst fuses several CONSECUTIVE inline-only
// blocks into a single <Span> (e.g. the author note + the contact-info block
// would merge); a block whose body is an explicit paragraph is tagged separately.
// Layout-neutral — the paragraph already existed implicitly, so the rendering is
// byte-identical; the only effect is to give the content its own structure-tree
// chunk, in reading order, so the text-comparison harness can check intra-chunk
// element order (e.g. each author's name→affiliation→email) instead of one fused
// blob. Only safe for SINGLE-paragraph content — `par` collapses paragraph breaks.
#let tagged-par(body) = par(body)

// A full-width frontmatter text block at one font-size step (default "small" =
// 9pt), with intra-block leading and inter-paragraph spacing on the baseline
// grid (comp()). `indent` sets the first-line indent (0pt = none); `spacing` is
// the outer block gap to neighbours. Used for the abstract, CCS/keywords lines,
// and the ACM reference format.
// `chunk: true` wraps a SINGLE-paragraph body in `tagged-par` so it tags as its
// own <P> structure element instead of fusing into a neighbour's <Span> (see
// tagged-par). Only safe for single-paragraph content — `par` collapses
// paragraph breaks — so it is off by default and the multi-paragraph abstract
// keeps it off.
#let fm-block(cfg, body, sz: "small", justify: true, indent: 0pt, spacing: 0pt, chunk: false) = {
  let lead = comp(cfg, sz: sz)
  block(width: 100%, spacing: spacing)[
    #set text(font: cfg.fonts.body, size: cfg.size.at(sz))
    #set par(
      justify: justify,
      leading: lead,
      first-line-indent: if indent == 0pt { 0pt } else { (amount: indent, all: false) },
      spacing: lead,
    )
    #if chunk { tagged-par(body) } else { body }
  ]
}

// A 9pt "Label: content" line used for CCS Concepts and Keywords.
// \@specialsection does `\par\medskip\small ...`, so the gap is \medskip before
// 9pt text (tex-skip with sz: "small"). See DESIGN.md "block vertical spacing".
#let special-line(cfg, label, content) = {
  // Journals (bibstrip) run these in at \small with a plain label; sigplan uses
  // \noindentparagraph (a level-4 run-in heading) at normalsize, so the LABEL takes
  // the paragraph heading style — bold italic (\@specialsection, acmart.dtx:6790).
  let sz = if cfg.bibstrip { "small" } else { "normalsize" }
  let pf = cfg.sec-fonts.paragraph
  let head = if cfg.bibstrip { [#label:] } else { text(weight: pf.weight, style: pf.style)[#label:] }
  v(tex-skip(cfg, cfg.medskip, sz: sz), weak: true)
  fm-block(cfg, [#head #content], sz: sz, justify: false, spacing: comp(cfg, sz: sz), chunk: true)
}

// Assign footnote symbols across the whole top matter, matching acmart's shared
// footnote counter. \maketitle resets the counter and emits the texts in the
// order \@titlenotes, \@subtitlenotes, \@authornotes (acmart.dtx:6577-6581), all
// using \@fnsymbol marks (acmart.dtx:6571). So a title note takes the first
// symbol (*), a subtitle note the next, and author notes follow. Identical author
// notes are deduplicated; the corresponding-author ✉ is a fixed glyph (\ding{41},
// acmart.dtx:5430), NOT a counter step, so it consumes no symbol. In anonymous
// mode \authornote is suppressed (acmart.dtx:5406) while title/subtitle notes
// still appear with placeholder text (acmart.dtx:5360/5383).
//
// Returns the title/subtitle marks (for make-title), the ordered footnote list
// (for make-footnotes), and each author's superscript marks.
#let collect-notes(meta) = {
  let anon = meta.anonymous
  let notes = ()
  let idx = 0
  let title-mark = none
  let subtitle-mark = none
  let symbol-at(i) = {
    assert(i < fnsymbols.len(), message: "faithful-acmart: too many top-matter notes for the available footnote symbols")
    fnsymbols.at(i)
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
    if a.corresponding { m.push("✉") }
    if a.note != none and not anon {
      let key = repr(a.note)
      if key not in seen {
        seen.insert(key, symbol-at(idx))
        notes.push((symbol: seen.at(key), body: a.note))
        idx += 1
      }
      m.push(seen.at(key))
    }
    marks.push(m)
  }
  (title-mark: title-mark, subtitle-mark: subtitle-mark, notes: notes, marks: marks)
}

// One author's contact entry, replaying name then the email/affiliation fields in
// the order they were declared, matching LaTeX \@mkauthorsaddresses, which prints
// \addresses in \email/\affiliation command order (acmart.dtx:7588). Authors are
// listed individually in source order with the affiliation repeated per author —
// NOT grouped. Multiple affiliations per author are supported (an `affiliation`
// array, like LaTeX's repeated \affiliation), joined by " and ".
#let contact-line(a) = {
  let parts = (a.name,)
  for field in a.contact-order {
    if field == "affiliation" {
      // each affiliation as "institution, city, state, country"; several joined
      // by " and " (LaTeX's institution separator).
      let affs = affil-strings(a.affiliation, ("institution", "city", "state", "country"))
      if affs.len() > 0 { parts.push(affs.join(" and ")) }
    } else if a.email != none {
      parts.push(email-link(a.email))
    }
  }
  parts.join(", ")
}

#let acmcp-contact-lines(authors) = {
  let contacts = authors.map(contact-line)
  if contacts.len() <= 1 { return contacts.join("") }
  let out = []
  for (i, c) in contacts.enumerate() {
    if i > 0 {
      let prev = authors.at(i - 1)
      let cur = authors.at(i)
      // acmart's acmcp infobox replays \addresses after the title block has
      // processed corresponding-author marks. In the bundled sample this leaves
      // the separator before the final corresponding author unprinted.
      let omit-final-corresponding-sep = i == contacts.len() - 1 and cur.corresponding and not prev.corresponding
      out += if omit-final-corresponding-sep { [ ] } else { [; ] }
    }
    out += c
  }
  out
}

// authordraft stamps the page-1 copyright block with a black large-bold notice
// overlaying the (greyed) copyright text (acmart.dtx:6606-6610). place() gives it
// zero size, so the copyright lines flow behind it.
#let draft-stamp(cfg) = place(top + left, text(size: cfg.size.large, weight: "bold")[Unpublished working draft. Not for distribution.])

// The conference info line in the copyright block (acmart.dtx:6617-6621). The
// form is format-dependent: engage prints "<booktitle>, <year>.", every other
// conference format prints italic "<conference short>, <conference venue>".
// none when the relevant metadata was not supplied.
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

// The page-1 footnote stack: author notes, authors' contact information, and the
// copyright/permission block, each with a rule above. Placed at the bottom of
// the first page's text area.
#let make-footnotes(cfg, meta) = {
  let fs = cfg.size.footnotesize
  let lead = comp(cfg, sz: "footnotesize")
  let ni = collect-notes(meta)
  let j = lookup-journal(meta.journal)

  let rule(width) = {
    v(cfg.footnote-rule-kern-above, weak: true)
    line(length: width, stroke: 0.4pt)
    v(cfg.footnote-rule-kern-below, weak: true)
  }

  let stack = {
    set text(font: cfg.fonts.body, size: fs)
    set par(justify: true, leading: lead, first-line-indent: 0pt, spacing: lead)

    let anon = meta.anonymous
    let has-contact-info = cfg.name != "acmcp" and meta.bibstrip and not anon and meta.authors.len() > 0 and meta.authors.any(a => a.affiliation != none or a.email != none)
    let mode = meta.copyright
    let ptext = permission-text(mode, cc-type: meta.cc-type, cc-version: meta.cc-version)
    let has-copyright-info = cfg.name != "acmcp" and (
      if meta.nonacm { mode == "cc" and ptext != none } else { true }
    )

    // 1. Title/subtitle/author notes (regular footnotes, symbol marks). collect-notes
    // already excludes author notes under anonymity but keeps title/subtitle notes.
    if ni.notes.len() > 0 {
      rule(cfg.footnote-rule-short)
      for n in ni.notes {
        block(spacing: lead, tagged-par[#note-super(n.symbol)#n.body])
      }
      if has-contact-info or has-copyright-info {
        // These are separate LaTeX footnote streams (ordinary notes, then
        // manyfoot authors-address/copyright streams). The later full-width
        // rule is already bottom-aligned; add the measured inter-stream strut so
        // the author-note rule/text sit at the LaTeX height above it.
        let stream-gap = if meta.bibstrip {
          2 * lead + cfg.footnote-rule-kern-below
        } else {
          lead
        }
        block(spacing: 0pt)[#box(width: 0pt, height: stream-gap)]
      }
    }

    // 2. Authors' Contact Information — only the journal/tog formats print this
    // footnote (\if@ACM@journal@bibstrip@or@tog, acmart.dtx:6592); the conference
    // formats carry contact info in the author grid instead. Suppressed if anon.
    if has-contact-info {
      rule(100%)
      let label = if meta.authors.len() > 1 { "Authors' Contact Information:" } else { "Author's Contact Information:" }
      let contacts = meta.authors.map(contact-line).join("; ")
      block(spacing: lead, tagged-par[#label #contacts.])
    }

    // 3. Copyright / permission (faithful to acmart's assembly). nonacm
    // suppresses this whole block — including the © line and ACM bibstrip —
    // except cc mode, which still prints its permission text (acmart.dtx:6599-6661).
    if cfg.name == "acmcp" {
      // acmcp routes contact data to the cover infobox and suppresses the normal
      // copyright footnote block (acmart.dtx:6589/6604).
    } else if meta.nonacm {
      if mode == "cc" and ptext != none {
        rule(100%)
        block(spacing: lead, ptext)
      }
    } else if meta.author-version {
      // author-version: drop the permission text (acmart.dtx:6612) and replace
      // the ACM bibstrip with the author's-version notice, naming the full
      // (emphasized) journal and the DOI (acmart.dtx:6634-6647). Unlike the short
      // bibstrip lines below, this is a running paragraph, so it stays justified
      // (inherited from the footnote stack) rather than ragged.
      rule(100%)
      block(spacing: lead, {
        if meta.author-draft { draft-stamp(cfg) }
        set text(fill: if meta.author-draft { luma(90%) } else { black })
        let owner = copyright-owner(mode)
        if owner != none { [© #meta.copyright-year #owner] } else { [#meta.copyright-year.] }
        linebreak()
        [This is the author's version of the work. It is posted here for your personal use. Not for redistribution. The definitive Version of Record was published in #emph(j.name)#{
          if meta.doi != none [, #link("https://doi.org/" + meta.doi)[https:\/\/doi.org\/#meta.doi].]
          else [.]
        }]
      })
    } else {
      rule(100%)
      block(spacing: lead, {
        if meta.author-draft { draft-stamp(cfg) }
        set text(fill: if meta.author-draft { luma(90%) } else { black })
        if ptext != none { ptext; parbreak() }
        set par(justify: false)
        // Conference info line, between the permission text and the © line
        // (acmart.dtx:6615-6622): italic "<conf short>, <conf venue>", or for the
        // engage/booktitle path "<booktitle>, <year>.". Journal/tog skip it.
        let proceedings-copyright = cfg.name != "manuscript" and (
          not meta.bibstrip or meta.conference != none
        )
        if proceedings-copyright {
          let cl = conf-info-line(cfg, meta)
          if cl != none { cl; linebreak() }
        }
        // © <year> <owner>  (copyright-year always has a value; see acmart() in lib.typ)
        let owner = copyright-owner(mode)
        if owner != none {
          [© #meta.copyright-year #owner]
          linebreak()
        } else {
          [#meta.copyright-year. ]
        }
        // Final line: manuscript notice / journal bibstrip / conference ISBN+DOI
        // (acmart.dtx:6631-6656).
        if cfg.name == "manuscript" {
          [Manuscript submitted to ACM]
        } else if meta.bibstrip and meta.conference == none {
          // ACM <issn>/<year>/<month>-ART<article> then DOI (acmart.dtx:6651).
          // \@acmArticle defaults to empty, so ART may have no number. str() on the
          // month delimits the number from the following "-ART" (markup would
          // otherwise read "acm-month-ART" as one hyphenated identifier).
          [ACM #j.issn/#str(meta.acm-year)/#str(meta.acm-month)-ART#{
            if meta.acm-article != none { str(meta.acm-article) }
          }]
          if meta.doi != none {
            linebreak()
            link("https://doi.org/" + meta.doi)[https:\/\/doi.org\/#meta.doi]
          }
        } else {
          // conference: ACM ISBN <isbn> then DOI (acmart.dtx:6654).
          if has-isbn(meta) { [ACM ISBN #meta.isbn]; linebreak() }
          if meta.doi != none {
            link("https://doi.org/" + meta.doi)[https:\/\/doi.org\/#meta.doi]
          }
        }
      })
    }
  }

  // float: true so the block reserves space at the bottom of the first page and
  // the body text flows above it (rather than overlapping).
  place(bottom, float: true, block(width: 100%, spacing: 0pt, stack))
}

// acmcp cover infobox (\set@ACM@acmcpbox, acmart.dtx:6725): a 5pc-wide box at the
// right text margin (\fancyhead[R]\makebox[\z@][r], acmart.dtx:8129) — the JDS logo
// over optional code/data links, keywords, contributions and author contact
// information, in scriptsize. The acmcp title is narrowed by 6pc so it clears the
// box. The caller bottom-aligns this box in the cover grid's right column, matching
// LaTeX's two-pass zref adjustment that drives the infobox bottom to the frame bottom.
#let make-acmcp-infobox(cfg, meta) = {
  assert(meta.acmcp-logo != none, message:
    "faithful-acmart: the `acmcp` cover format needs a journal logo — pass `acmcp-logo: image(\"...\")` "
    + "(the ACM journal logo is ACM's trademark and is not bundled with this package).")
  let big = tex-skip(cfg, cfg.bigskip, sz: "scriptsize")
  box(width: 60pt /* 5pc */)[
    #set align(left) // the \parindent\z@ vbox is left-aligned, not centred
    // User-supplied logo (see `acmcp-logo`); default it to the box width so a bare
    // `image("logo.png")` fills the column, as the bundled JDS logo used to.
    #{ set image(width: 100%); meta.acmcp-logo }
    #set text(size: cfg.size.scriptsize)
    #set par(justify: false, first-line-indent: 0pt, leading: comp(cfg, sz: "scriptsize"))
    #if meta.code-data-link != none { v(big, weak: true); [Code and data links:\ #meta.code-data-link] }
    #if meta.keywords != none { v(big, weak: true); [Keywords: #kw-join(meta.keywords)] }
    #if meta.contributions != none { v(big, weak: true); meta.contributions }
    #let contacts = meta.authors.map(contact-line)
    #if contacts.len() > 0 {
      v(big, weak: true)
      let label = if contacts.len() > 1 { "Authors' Contact Information:" } else { "Author's Contact Information:" }
      [#label #acmcp-contact-lines(meta.authors).]
    }
  ]
}

// --- Shared title-head pieces (used by both the journal and the conference head;
// the only difference between those heads is centering + the author layout). ---

// The title block: \@titlefont per format, with cap-height top-edge so the (tall)
// first line's cap-top sits at the top margin, matching LaTeX \topskip for a first
// line taller than \topskip. \@translatedtitle adds each secondary title as a new
// \par in the title font (acmart.dtx:3374/6994), one baselineskip below.
#let title-block(cfg, meta, mark) = {
  let tf = cfg.title-font
  // acmcp narrows the title box by 6pc (\@mktitle@i \advance\hsize -6pc,
  // acmart.dtx:6988) so it clears the top-right cover infobox; auto width (natural,
  // unchanged) elsewhere.
  block(spacing: 0pt, width: if cfg.title-width-reduction != 0pt { 100% - cfg.title-width-reduction } else { auto })[
    #set text(font: cfg.fonts.at(tf.family), weight: tf.weight, size: cfg.size.at(tf.size), top-edge: "cap-height")
    #set par(justify: false, first-line-indent: 0pt, leading: comp(cfg, sz: tf.size), spacing: comp(cfg, sz: tf.size))
    // tagged-par so the title is its own <P> chunk, not fused into the author
    // head's <Span>. Translated titles are already separate paragraphs (parbreak)
    // and tag separately on their own.
    #tagged-par[#meta.title#if mark != none { super(mark) }]
    #for (l, t) in meta.translated-title {
      parbreak()
      v(0.51em, weak: true)
      text(lang: lang-record(l).code, t)
    }
  ]
}

// The subtitle block (\@subtitlefont = \normalsize\mdseries; its own block so it
// gets normalsize leading, one normalsize baselineskip below the title via the
// \par). \@translatedsubtitle each in the subtitle font (acmart.dtx:3391/6996).
// none when there is no subtitle.
#let subtitle-block(cfg, meta, mark) = {
  if meta.subtitle == none { return }
  let sf = cfg.subtitle-font
  block(spacing: tex-skip(cfg, 0pt))[
    #set text(font: cfg.fonts.at(sf.family), weight: sf.weight, size: cfg.size.at(sf.size))
    #set par(justify: false, first-line-indent: 0pt, leading: comp(cfg, sz: sf.size), spacing: comp(cfg, sz: sf.size))
    #tagged-par[#meta.subtitle#if mark != none { super(mark) }]
    #for (l, t) in meta.translated-subtitle {
      parbreak()
      v(0.51em, weak: true)
      text(lang: lang-record(l).code, t)
    }
  ]
}

// Render an author's note marks as superscripts.
#let render-marks(marks) = {
  for m in marks {
    note-super(m)
  }
}

// Attach each author's collected note marks (collect-notes order) as `_marks`, so
// group-authors and the per-name rendering can read them off the author dict.
#let mark-authors(meta, ni) = meta.authors.enumerate().map(((i, a)) => {
  let a2 = a
  a2.insert("_marks", ni.marks.at(i))
  a2
})

// Teaser figure between the authors and the abstract (\@mkteasers, acmart.dtx:7663):
// a full-text-width figure, \par\bigskip above. none when there is no teaser.
#let teaser-block(cfg, meta) = {
  if meta.teaser == none { return }
  v(tex-skip(cfg, cfg.bigskip), weak: true)
  block(width: 100%, spacing: 0pt)[
    #set figure(placement: none)
    #meta.teaser
  ]
}

// The journal @i spanning head (acmart.dtx:6986): left-aligned title/subtitle,
// then the andified author *list* with short affiliations. Used by the single-
// column journals and by acmtog (two-column journal). The conference formats use
// conf-title-head instead; make-title-head dispatches on cfg.title-style.
#let journal-title-head(cfg, meta) = {
  let ni = collect-notes(meta)
  title-block(cfg, meta, ni.title-mark)
  subtitle-block(cfg, meta, ni.subtitle-mark)

  // Author-list fonts come from the format dict (acmart.dtx:7206 \@authorfont /
  // \@affiliationfont): acmsmall \large sans names + \small serif affils (the
  // make-format defaults), acmtog \LARGE sans + \large. The size step also drives
  // the leading and the title->authors gap.
  let af = cfg.author-font
  let aff-f = cfg.affil-font
  // Title box ends with \par\bigskip; \@mkauthors@i prepends \par\medskip before
  // the author lines (at the author size). gap = \bigskip + \medskip.
  v(tex-skip(cfg, cfg.bigskip + cfg.medskip, sz: af.size), weak: true)

  // --- Authors (grouped structurally per acmart; see group-authors) ---
  // Anonymous review: replace the whole author strip with "Anonymous Author(s)".
  if meta.anonymous {
    block(spacing: 0pt)[
      #set text(font: cfg.fonts.at(af.family), weight: af.weight, size: cfg.size.at(af.size))
      #tagged-par[#upper[Anonymous Author(s)]]
    ]
  } else {
  block(spacing: 0pt)[
    #set par(justify: false, leading: comp(cfg, sz: af.size), spacing: 0pt)
    #for g in group-authors(mark-authors(meta, ni)) {
      // andify preserves the per-name content marks (superscript symbols).
      let names = g.authors.map(a => { author-name(a, upper(a.name)); render-marks(a._marks) })
      // tagged-par so each author line is its own <P> chunk (author order can be
      // checked) rather than fusing into one frontmatter <Span>.
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
  } // end non-anonymous author block

  // Teaser figure between authors and abstract; then the author box's trailing
  // \par\medskip to the next block (abstract/CCS/..., at 9pt).
  teaser-block(cfg, meta)
  v(tex-skip(cfg, cfg.medskip, sz: "small"), weak: true)
}

// Conference author grid (\@mkauthors@iii, acmart.dtx:7438): one centered box per
// affiliation group (same group-authors rule as the journal list), laid out N per
// row. acmart's box width is (textwidth - sep)/N - sep with sep = \author@bx@sep
// (1pc); N defaults from the group count (1-3 -> that many, 4 -> 2, 5+ -> 3) and
// is overridable with authors-per-row. Names are mixed-case (not uppercased like
// the journal list); fonts are cfg.author-font / cfg.affil-font. Each row is
// centered independently (acmart \centering per row), so a partial final row is
// centered under the full rows rather than left-aligned.
// Chunk a flat list into rows of at most `n` (acmart lays author boxes N per row).
#let chunk-rows(items, n) = {
  let rows = ()
  let i = 0
  while i < items.len() {
    rows.push(items.slice(i, calc.min(i + n, items.len())))
    i += n
  }
  rows
}

// One author box shared by the conference (@mkauthors@iii) and sigchi-a
// (@mkauthors@iv) grids: STACKED names in author-font (acmart adds every name with
// `\par##1`, NOT andified like the journal list), a blank line, then the contact
// lines in affil-font. `contact-fn(group)` yields the ordered contact lines;
// sigchi-a left-aligns (else centered). `fli` is the name paragraph's first-line
// indent (0pt for sigchi-a; the conference box keeps the ambient body indent).
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
  let sep = 12pt // \author@bx@sep = 1pc
  let tw = cfg.paper.width - cfg.margin.inside - cfg.margin.outside
  let n = if authors-per-row > 0 { authors-per-row } else {
    let g = groups.len()
    if g <= 3 { g } else if g == 4 { 2 } else { 3 }
  }
  let bw = (tw - sep) / n - sep
  // Contact lines in acmart's command order: \email/\affiliation append to
  // \@currentaffiliation as issued (acmart.dtx). Replay each author's email and
  // affiliation in its own declared order (a.contact-order), so an author who
  // wrote \affiliation before \email (sample Lars/Charles/John/Julius) prints
  // institution-then-email, while one who wrote \email first prints email-then
  // -institution. The shared group affiliation is emitted once, at the position
  // its holder declared it (only that author carries it in contact-order).
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
  // Center each row on its own (acmart centers every row), so a short final row
  // sits centered rather than left-aligned. Rows are \lineskip (1pc) apart. The
  // conference box keeps the ambient body first-line indent (\parindent).
  let fli = (amount: cfg.parindent, all: false)
  stack(dir: ttb, spacing: 12pt, ..chunk-rows(groups, n).map(row => align(center, grid(
    columns: (bw,) * row.len(),
    column-gutter: sep,
    ..row.map(g => author-grid-box(cfg, g, contact-fn, fli: fli)),
  ))))
}

// The conference @mktitle@iii spanning head (acmart.dtx:7018): CENTERED title and
// subtitle, then the centered author grid. Fonts come from the format dict.
#let conf-title-head(cfg, meta) = {
  let ni = collect-notes(meta)
  set align(center)
  title-block(cfg, meta, ni.title-mark)
  subtitle-block(cfg, meta, ni.subtitle-mark)
  // title box \par\bigskip + @mkauthors@iii leading \par\medskip before the boxes
  v(tex-skip(cfg, cfg.bigskip + cfg.medskip), weak: true)
  if meta.anonymous {
    block(spacing: 0pt)[
      #set text(font: cfg.fonts.at(cfg.author-font.family), size: cfg.size.at(cfg.author-font.size))
      Anonymous Author(s)
    ]
  } else {
    make-authors-grid(cfg, group-authors(mark-authors(meta, ni)), authors-per-row: meta.authors-per-row)
  }
  teaser-block(cfg, meta)
  // closing \par\bigskip of \mktitle@bx (the float clearance adds the gap to body)
  v(tex-skip(cfg, cfg.bigskip), weak: true)
}

// Dispatch the spanning head on the format's title style (acmart.dtx:6874).
// sigchi-a @mkauthors@iv (acmart.dtx:7518): authors in left-aligned boxes, no more
// than 2 per row, each box holding the bold mixed-case name(s) (\@authorfont =
// \bfseries) then the email(s) and affiliation lines (\@affiliationfont = \mdseries),
// in source order (the twins declare \email before \affiliation). Unlike the
// conference grid (\@mkauthors@iii) the boxes are NOT centred (sigchiamode skips
// \centering) and box width is (textwidth - sep)/N - sep with sep = \author@bx@sep.
#let sigchi-authors(cfg, groups, authors-per-row: 0) = {
  let sep = 12pt // \author@bx@sep = 1pc
  let tw = cfg.paper.width - cfg.margin.left - cfg.margin.right
  let n = if authors-per-row > 0 { authors-per-row } else if groups.len() <= 1 { 1 } else { 2 }
  let bw = (tw - sep) / n - sep
  // grouped emails then affiliation lines (source order, \email before \affiliation)
  let contact-fn(group) = group.authors.map(a => a.email).filter(e => e != none).map(email-link) + affil-conf-lines(group.affiliation)
  // Boxes flow left-aligned (sigchiamode skips \centering) and wrap after N; rows
  // are \lineskip (1pc) apart. The box first line is unindented (\parindent 0).
  stack(dir: ttb, spacing: 12pt, ..chunk-rows(groups, n).map(row => grid(
    columns: (bw,) * row.len(),
    column-gutter: sep,
    align: top + left,
    ..row.map(g => author-grid-box(cfg, g, contact-fn, align-x: left)),
  )))
}

// sigchi-a @mktitle@iv (acmart.dtx:7039): hsize-wide box with \leftskip5pc and a
// leading full-width 2pt rule (\leaders\hrule height 2pt\hfill), then the
// ragged-right title; the author grid (\@mkauthors@iv) follows at leftskip 0.
#let sigchi-title-head(cfg, meta) = {
  let ni = collect-notes(meta)
  pad(left: 5 * 12pt, { // \leftskip5pc
    // \leaders\hrule height 2pt\hfill\par then \@title: the title sits one title-font
    // \baselineskip below the rule (rule height 2pt + a full Huge baseline step).
    let tf = cfg.title-font
    block(above: 0pt, below: comp(cfg, sz: tf.size) + cfg.size.at(tf.size) - 2pt,
      line(length: 100%, stroke: 2pt))
    title-block(cfg, meta, ni.title-mark)
    subtitle-block(cfg, meta, ni.subtitle-mark)
  })
  // title box \par\bigskip, then the author grid
  v(tex-skip(cfg, cfg.bigskip), weak: true)
  if meta.anonymous {
    block(spacing: 0pt)[
      #set text(font: cfg.fonts.at(cfg.author-font.family), weight: cfg.author-font.weight, size: cfg.size.at(cfg.author-font.size))
      Anonymous Author(s)
    ]
  } else {
    sigchi-authors(cfg, group-authors(mark-authors(meta, ni)), authors-per-row: meta.authors-per-row)
  }
  teaser-block(cfg, meta)
  // \@mkauthors@iv closing \par\bigskip before the abstract block
  v(tex-skip(cfg, cfg.bigskip), weak: true)
}

#let make-title-head(cfg, meta) = if cfg.title-style == "conf-center" {
  conf-title-head(cfg, meta)
} else if cfg.title-style == "sigchi-rule" {
  sigchi-title-head(cfg, meta)
} else {
  journal-title-head(cfg, meta)
}

// acmart's \@specialsection is small run-in text for journals and sigplan, but a
// real unnumbered section for the other proceedings (acmart.dtx:6763-6817).
#let special-section(cfg, label, content, lang: none) = {
  if cfg.bibstrip or cfg.name == "sigplan" {
    special-line(cfg, label, if lang != none { text(lang: lang, content) } else { content })
  } else {
    // Proceedings \section*{label}: the heading is a real section and the body is
    // normalsize (\@specialsection, acmart.dtx:6786) — NOT the journals' \small.
    heading(numbering: none, outlined: false)[#label]
    fm-block(cfg, if lang != none { text(lang: lang, content) } else { content }, sz: "normalsize", justify: false, chunk: true)
  }
}

// ACM Engage prints \setengagemetadata lines immediately after the author block
// and before the Synopsis heading: one no-indent paragraph per key/value pair,
// with the key bold and no punctuation inserted by the class.
#let engage-metadata-block(cfg, items) = {
  if items.len() == 0 { return }
  block(width: 100%, spacing: 0pt)[
    #set text(font: cfg.fonts.body, size: cfg.size.normalsize)
    #set par(justify: false, first-line-indent: 0pt, leading: comp(cfg), spacing: comp(cfg))
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

// In-column top matter: abstract / CCS / keywords / ACM reference format. In
// two-column formats these follow \@printtopmatter (acmart.dtx:6665) and so flow
// in the FIRST column beneath the spanning title box; in one column they are
// contiguous with the head. The leading weak skip collapses at a column top.
#let make-title-body(cfg, meta) = {
  let abstract-name = if cfg.name == "acmengage" { "Synopsis" } else { "Abstract" }

  if cfg.name == "acmengage" {
    engage-metadata-block(cfg, meta.engage-metadata)
  }

  // --- Abstract ---
  // Journals (bibstrip) set the abstract in \small with no heading; proceedings do
  // \section*{Abstract} + a normalsize body (\@mkabstract, acmart.dtx:7688-7696).
  if meta.abstract != none {
    if meta.bibstrip {
      fm-block(cfg, meta.abstract, indent: cfg.parindent)
    } else {
      heading(numbering: none, outlined: false)[#abstract-name]
      fm-block(cfg, meta.abstract, indent: cfg.parindent, sz: "normalsize")
    }
  }
  // Translated abstracts: each is another block in its own language, right after the
  // main one; proceedings repeat the abstract heading per language.
  for (l, ab) in meta.translated-abstract {
    let rec = lang-record(l)
    // Each translated abstract is headed by its own language's \abstractname
    // (babel: Résumé / Zusammenfassung / Resumen / …), not the English one.
    let name = rec.at("abstract", default: abstract-name)
    if meta.bibstrip {
      fm-block(cfg, text(lang: rec.code, ab), indent: cfg.parindent)
    } else {
      heading(numbering: none, outlined: false)[#name]
      fm-block(cfg, text(lang: rec.code, ab), indent: cfg.parindent, sz: "normalsize")
    }
  }

  // --- CCS Concepts (suppressed by \settopmatter{printccs=false}) ---
  if meta.ccs != none and meta.print-ccs {
    special-section(cfg, [CCS Concepts], render-ccs-concepts(meta.ccs))
  }

  // --- Keywords ---
  // acmcp suppresses normal keyword top matter; the infobox prints it instead.
  if meta.keywords != none and cfg.name != "acmcp" {
    let label = if meta.bibstrip { meta.strings.keywords } else { meta.strings.keywords_proceedings }
    special-section(cfg, label, kw-join(meta.keywords))
  }
  // Translated keywords (secondary languages): each block carries \keywordsname
  // in its own language and sets that language for hyphenation (acmart.dtx:5338).
  if cfg.name != "acmcp" {
    for (l, kw) in meta.translated-keywords {
      let rec = lang-record(l)
      let label = if meta.bibstrip { rec.keywords } else { rec.keywords_proceedings }
      special-section(cfg, label, kw-join(kw), lang: rec.code)
    }
  }

  // --- ACM Reference Format ---
  if meta.print-acm-reference {
    let j = lookup-journal(meta.journal)
    let proceedings-ref = not meta.bibstrip or meta.conference != none
    // \@mkbibcitation does `\par\medskip\small ...`; next block is 9pt
    v(tex-skip(cfg, cfg.medskip, sz: "small"), weak: true)
    context {
      let total = counter(page).final().first()
      fm-block(cfg, [
        #strong[ACM Reference Format:]\
        #{ if meta.anonymous [Anonymous Author(s)] else { andify(meta.authors.map(a => a.name)) } }. #meta.acm-year. #meta.title#{
          if meta.subtitle != none [: #meta.subtitle]
        }. #if not meta.nonacm {
          if not proceedings-ref {
            [#if j.short != none { emph(j.short) + " " }#meta.acm-volume, #meta.acm-number#if meta.acm-article != none [, Article #meta.acm-article] (#pub-date(meta)), #total #if total == 1 [page] else [pages].]
          } else {
            // booktitle is resolved (explicit or derived from the conference) in acmart().
            [In #emph(meta.booktitle). ACM, New York, NY, USA#if meta.acm-article != none [, Article #meta.acm-article], #total #if total == 1 [page] else [pages].]
          }
        }#{
          if meta.doi != none [ #link("https://doi.org/" + meta.doi)[https:\/\/doi.org\/#meta.doi]]
        }
      ], chunk: true)
    }
  }

  // \@printendtopmatter \par\bigskip; next block is the body at 10pt
  v(tex-skip(cfg, cfg.bigskip), weak: true)
}

// One-column path: the head and in-column body are contiguous, exactly as the
// old single make-title. Two-column formats call the two halves separately (the
// head inside a spanning float), so this wrapper is the single-column entry.
#let make-title(cfg, meta) = {
  make-title-head(cfg, meta)
  make-title-body(cfg, meta)
}

// Format a paper-history line for \received. acmart accumulates calls into one
// string: the first stage defaults to "Received <date>", later stages append
// "; <stage> <date>" (acmart.dtx:5844-5857). We accept either:
//   - content/string -> used verbatim, or
//   - an array of items, each a (stage, date) pair or a bare date; the first
//     item's empty/none stage becomes "Received", later empty stages "revised".
#let format-received(received) = {
  if type(received) != array { return received }
  let parts = ()
  for (i, item) in received.enumerate() {
    let (stage, date) = if type(item) == array and item.len() >= 2 { (item.at(0), item.at(1)) }
      else if type(item) == array { (none, item.at(0, default: none)) }  // 1-elem array: treat as bare date
      else { (none, item) }
    let s = if stage == none or stage == "" {
      if i == 0 { "Received" } else { "revised" }
    } else { stage }
    parts.push([#s #date])
  }
  parts.join([; ])
}

// The paper-history line, printed at the very end of the document
// (acmart \AtEndDocument, acmart.dtx:5858-5861): \par\bigskip then \small
// \normalfont (9pt body roman — serif, or sans under sans-default), unindented.
#let make-received(cfg, received) = {
  v(tex-skip(cfg, cfg.bigskip, sz: "small"), weak: true)
  block(width: 100%, spacing: 0pt)[
    #set text(font: cfg.fonts.body, weight: "regular", style: "normal", size: cfg.size.small)
    #set par(justify: false, leading: comp(cfg, sz: "small"), first-line-indent: 0pt)
    #format-received(received)
  ]
}

// Artifact-evaluation badges for the first-page header (acmart firstpagestyle,
// acmsmall: \@acmBadgeL at left, \@acmBadgeR at right; acmart.dtx:8203-8206).
// `badges` is a dict with optional `left`/`right` content (typically an image at
// `cfg.badge-width` wide, optionally wrapped in a link). Returns header content.
#let make-badges(cfg, badges) = {
  if badges == none { return none }
  let l = badges.at("left", default: none)
  let r = badges.at("right", default: none)
  grid(columns: (1fr, 1fr),
    align(left + bottom, if l != none { l }),
    align(right + bottom, if r != none { r }))
}
