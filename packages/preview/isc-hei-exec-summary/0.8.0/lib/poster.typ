// ─────────────────────────────────────────────────────────────────────────────
// Poster functions  (@preview/isc-hei-poster)
//
// Public API:
//   isc-poster()    — top-level show rule; sets up the A1 page, header, footer
//   isc-card()      — section content box; wraps placard's card() with ISC styling
//   isc-colbreak()  — column break that also resets the distribute-columns state
//
// Internals (not exported):
//   _isc-poster-distribute  — state: whether distribute-columns is active
//   _isc-first-card         — state: true at the start of each column (no leading spacer)
// ─────────────────────────────────────────────────────────────────────────────

#import "includes.typ" as inc
#import "settings.typ": programme-name-isc
#import "decorations.typ": hash-rule
#import "i18n.typ": i18n
#import "fonts.typ": isc-fonts-available, _missing-fonts-page
#import "overflow.typ" as overflow

// State for isc-poster's distribute-columns feature (read by isc-card)
#let _isc-poster-distribute = state("_isc-poster-distribute", false)
// Tracks whether the next isc-card is the first in its column (no leading spacer)
#let _isc-first-card = state("_isc-first-card", true)
// Vertical offset applied to the first card in every column (negative = pull up)
#let _isc-col-start-offset = state("_isc-col-start-offset", 0pt)

// A1 poster layout powered by @preview/placard.
//
// Parameters:
//   title              — main poster title (content; multi-line is fine)
//   subtitle           — optional subtitle rendered below the title in lighter weight
//   student            — student full name
//   permanent-email    — student permanent e-mail shown below the name (optional)
//   supervisor         — supervising professor
//   co-supervisor      — optional second supervisor
//   expert             — optional thesis expert / jury member
//   thesis-id          — optional thesis ID shown in the footer left in monospace
//   academic-year      — optional academic year shown in the footer left, e.g. "2025-2026"
//   school             — institution name (shown in affiliation line)
//   programme          — degree programme (shown in affiliation line)
//   major              — optional specialization appended to the affiliation line
//   orientation        — "portrait" (default) or "landscape" for A1 paper
//   language           — "fr" | "en" | "de" — controls label strings
//   logo               — right-side logo: auto → ISC logo PDF; none → suppress; or custom content
//   logo-height        — height of the right logo when logo: auto (default: 2.5cm)
//   hei-logo           — left-side logo:  auto → HEI logo PDF; none → suppress; or custom content
//   hei-logo-height    — height of the left logo when hei-logo: auto (default: 3.6cm)
//   num-columns        — number of card columns (default: 2)
//   distribute-columns — true → vertically space cards so columns fill top-to-bottom
//
// Usage:  #show: isc-poster.with(title: ..., student: ..., supervisor: ..., ...)
//         Then place content with #isc-card(title: "...")[...] blocks.
#let isc-poster(
  title: [Poster Title],
  subtitle: none,
  student: [Prénom Nom],
  permanent-email: none,
  supervisor: [Prof. Prénom Nom],
  co-supervisor: none,
  expert: none,
  thesis-id: none,
  academic-year: none,
  school: "Haute École d'Ingénierie de Sion",
  programme: programme-name-isc,
  major: none,
  orientation: "portrait",
  language: "fr",
  logo: auto,             // right-side logo: auto = ISC logo, none = suppress, or custom content
  logo-height: 2.5cm,     // height applied when logo: auto; ignored for custom content
  hei-logo: auto,         // left-side logo:  auto = HEI logo, none = suppress, or custom content
  hei-logo-height: 3.6cm, // height applied when hei-logo: auto; ignored for custom content
  num-columns: 2,
  distribute-columns: true,
  body,
) = {
  import "@preview/placard:0.1.0": placard as _placard
  // Import at function scope so tiaoma is always available for QR generation
  // regardless of which if/else branch runs (Typst imports are block-scoped).
  import "@preview/tiaoma:0.3.0"

  // Render the "fonts not installed" page instead of the poster when the ISC
  // fonts are missing (same guard as project(), sized for the poster's A1 paper).
  context if not isc-fonts-available() { _missing-fonts-page(paper: "a1") } else {

  // Reproducible PDF: without this, typst defaults document.date to `auto` and bakes
  // the current wall-clock into /CreationDate + /ModDate, so every build differs in git
  // (project()-based templates already pass date:, so only the poster needed this).
  set document(date: none)

  // ISC TB aggregator — not user-facing; update here when the URL moves.  
  let _isc-tbs-website = "https://tbs.isc-vs.ch/"

  // ── Logo resolution ───────────────────────────────────────────────────────
  // auto → default logo at the given height; none → suppress; custom → pass through as-is.
  let isc-logo = if logo == auto {
    image("assets/isc_logo.svg", height: logo-height)
  } else if logo == none { none } else { logo }

  let resolved-hei-logo = if hei-logo == auto {
    image("assets/hei_logo.svg", height: hei-logo-height)
  } else if hei-logo == none { none } else { hei-logo }

  // ── Localised label strings for the author block ──────────────────────────
  let lbl = if language == "de" {
    (student: [Student·in], supervisor: [Betreuer·in],
     co-supervisor: [Co-Betreuer·in], expert: [Expert·in])
  } else if language == "fr" {
    (student: [Étudiant·e], supervisor: [Superviseur·e],
     co-supervisor: [Co-superviseur·e], expert: [Expert·e])
  } else {
    (student: [Student], supervisor: [Supervisor],
     co-supervisor: [Co-supervisor], expert: [Expert])
  }

  // ── Author entries: muted role label above the name ───────────────────────
  // placard renders each author entry in bold by default; explicit text() calls
  // override that so only the name uses the bold weight placard would apply.
  // sub: optional second line below the name (used for permanent-email).
  let make-entry = (l, val, sub: none) => stack(
    dir: ttb,
    spacing: 12pt,
    text(size: 16pt, weight: "regular", fill: luma(120), l),
    if sub != none {
      stack(dir: ttb, spacing: 8pt,
        val,
        text(size: 15pt, weight: "regular", fill: luma(160), sub))
    } else { val },
  )

  let authors-list = (
    (make-entry(lbl.student, student, sub: permanent-email),)
    + (if supervisor != none { (make-entry(lbl.supervisor, supervisor),) } else { () })
    + (if co-supervisor != none { (make-entry(lbl.co-supervisor, co-supervisor),) } else { () })
    + (if expert != none { (make-entry(lbl.expert, expert),) } else { () })
  )

  // ── Title block: title → subtitle → affiliation → accent line (placard) ──
  // Affiliation (school · programme · major?) sits between the subtitle and
  // placard's accent rule so the institutional context is visible without
  // crowding the heading.
  // set par() scoped to tight-title only via code block; stack() uses absolute
  // pt spacers to avoid implicit paragraph spacing artefacts.
  // hyphenate: false keeps long words whole — placard justifies the title, which
  // would otherwise split words mid-line (e.g. "hospitalières" → "hospital-ières").
  let tight-title = { set par(leading: 0.5em); set text(hyphenate: false); title }
  let _affil-parts = (school, programme) + (if major != none { (major,) } else { () })
  let affiliation = layout(size => block(width: size.width, {
    align(center, text(size: 18pt, weight: "regular", fill: luma(140), _affil-parts.join([  ·  ])))
    if thesis-id != none {
      place(right + horizon, text(font: "Source Sans Pro", size: 15pt, weight: "regular", fill: luma(160), thesis-id))
    }
  }))

  // pad(bottom: …) reduces the natural gap placard inserts between the title
  // content and its accent rule — negative value pulls them closer together.
  let full-title = pad(bottom: -25pt,
    if subtitle != none {
      stack(dir: ttb,
        tight-title,
        1cm,
        text(size: 28pt, weight: "regular", subtitle),
        8mm,
        affiliation,
      )
    } else {
      stack(dir: ttb, tight-title, 16pt, affiliation)
    }
  )

  // ── Dot decoration: brand dots fading left → right, bottom-right corner ──
  // 20 columns × 3 rows of circles; opacity increases toward the right edge.
  // Placed in the page background so poster content and footer sit on top.
  let _dot-d    = 5pt
  let _dot-gap  = 4pt
  let _n-cols   = 20
  let _n-rows   = 3
  // Pre-computed transparency steps: index 0 = leftmost (nearly invisible),
  // index 19 = rightmost (fully opaque). Hard-coded to avoid float→ratio arithmetic.
  let _t-steps  = (95%, 90%, 85%, 80%, 75%, 70%, 65%, 60%, 55%, 50%,
                    45%, 40%, 35%, 30%, 25%, 20%, 15%, 10%,  5%,  0%)
  let _dot-grid = grid(
    columns: range(_n-cols).map(_ => _dot-d + _dot-gap),
    rows:    range(_n-rows).map(_ => _dot-d + _dot-gap),
    align:   center + horizon,
    ..range(_n-cols * _n-rows).map(idx => {
      let col = calc.rem(idx, _n-cols)
      circle(radius: _dot-d / 2,
             fill: inc.hei-purple.transparentize(_t-steps.at(col)),
             stroke: none)
    })
  )
  set page(background: place(bottom + right,
    pad(right: 2.5cm, bottom: 2.2cm, _dot-grid)
  ))

  // ── Page header: HEI logo left, ISC logo right ────────────────────────────
  // set page(header:) merges with the background set above and with placard's
  // set page(paper:, margin:, footer:) since neither touches the other's keys.
  // top padding: distance from paper edge to logo top.
  // bottom padding: breathing room between logo bottom and the title block.
  // The top margin passed to _placard (6cm) must clear logo height + padding.
  set page(header: pad(top: 2.5cm, bottom: 0.8cm,
    grid(
      columns: (auto, 1fr, auto),
      align: horizon,
      if resolved-hei-logo != none { resolved-hei-logo },
      [],
      if isc-logo != none { isc-logo },
    )
  ))

  // ── QR helper ─────────────────────────────────────────────────────────────
  let _make-qr(url) = box(fill: white, inset: 4pt, radius: 2pt,
    tiaoma.barcode(url, "QRCode", options: (
      scale: 1.6, fg-color: black, bg-color: white, dot-size: 1.0,
      output-options: (barcode-dotty-mode: false),
    ))
  )

  // ── Institutional info block — bottom-left foreground overlay ─────────────
  // Sits on top of the footer accent line (foreground layer).
  // Layout: ISC TB QR on the left, programme · major · academic-year stacked on the right.
  let _label-orientation   = i18n(language, "poster-orientation")
  let _label-academic-year = i18n(language, "poster-academic-year")

  let _info-value(t, first: false) = text(
    font: "Source Sans Pro",
    size: if first { 18pt } else { 14pt },
    weight: if first { "semibold" } else { "regular" },
    fill: if first { luma(50) } else { luma(110) },
    t,
  )
  let _info-row(label, value) = text(font: "Source Sans Pro", size: 14pt)[#text(fill: luma(110))[#label · ]#text(fill: luma(50))[#value]]

  let _tous-les-travaux-pill = rotate(-90deg, reflow: true,
    par(leading: 2pt,
      text(font: "Source Sans Pro", size: 10pt, weight: "semibold",
           fill: inc.hei-purple, i18n(language, "poster-discover").split("\n").join(linebreak()))
    )
  )

  let _info-block = grid(
    columns: (auto, auto, auto),
    column-gutter: 5mm,
    align: horizon,
    _tous-les-travaux-pill,
    _make-qr(_isc-tbs-website),
    stack(dir: ttb, spacing: 10pt,
      _info-value(programme, first: true),
      ..(if major != none {
        (_info-row(_label-orientation, major),)
      } else { () }),
      ..(if academic-year != none {
        (_info-row(_label-academic-year, academic-year),)
      } else { () }),
    ),
  )

  // Foreground overlay: the bottom-left institutional block, plus the title
  // overflow warning when it fires. The warning lives in the FOREGROUND (not the
  // flow) so it never pushes content onto a second page — important on the short
  // landscape A1. The verdict uses the shared thesis reference (see lib/overflow.typ)
  // so it matches every other document type. lang is passed explicitly because the
  // poster bypasses project() and keeps its own language.
  set page(foreground: {
    place(bottom + left, pad(left: 2.5cm, bottom: 1.6cm, _info-block))
    context {
      let issues = overflow.title-overflow-issues(title, subtitle: subtitle, lang: language)
      if issues.len() > 0 {
        place(top + center, dy: 7cm,
          overflow.overflow-warning-box(issues, font: "Source Sans Pro", width: 78%, scale: 3, lang: language))
      }
    }
  })

  // ── Initialise distribute-columns state before body renders ───────────────
  // State updates must appear before the content that reads them in document flow.
  _isc-poster-distribute.update(distribute-columns)
  _isc-first-card.update(true)
  // Pull every column's first card up by this amount to close the gap below the authors.
  _isc-col-start-offset.update(-0.6cm)

  // ── Branded title separator ───────────────────────────────────────────────
  // placard draws two full-width accent lines: the title separator first, then
  // the footer rule. Swap only the first for the hashed bit-rule (the same one
  // on the bachelor-thesis cover); the footer rule stays a plain line. The
  // state is keyed on document position, so the title line — which precedes the
  // footer — is the one replaced regardless of layout order.
  //
  // Seed must match the bachelor cover (thesis-id + author, raw strings) so the
  // same document yields the same bit pattern across both templates.
  let _as-str = v => if v == none { "" } else if type(v) == str { v } else { repr(v) }
  let _seed = _as-str(thesis-id) + _as-str(student)
  let _title-rule-seen = state("_isc-poster-title-rule", false)
  show line: it => {
    if it.length != 100% { return it }
    context {
      if _title-rule-seen.get() { it } else {
        _title-rule-seen.update(true)
        // Bits clustered on the left (matching the bachelor pattern), then a
        // plain line runs on to the right square. Overlaid in a zero-height box
        // so the title block keeps the original line's vertical footprint and
        // the cards still fit on a single page.
        box(width: 100%, height: 0pt, place(top, dy: -6pt,
          layout(size => hash-rule(_seed, length: size.width, bits-length: 24cm,
            n-bits: 16, thickness: 2pt, square-size: 12pt, circle-r: 5pt))))
      }
    }
  }

  // ── Hand off to placard ───────────────────────────────────────────────────
  // footer.content: thesis ID + academic year (simple text, left-aligned).
  // footer.logo: none — QR codes live in the page foreground above.
  _placard(
    title: full-title,
    authors: authors-list,
    paper: "a1",
    flipped: orientation == "landscape",
    num-columns: num-columns,
    // top margin = space reserved for the title block (title+subtitle+affiliation+authors).
    // Increase if the title block overflows into the cards; decrease to close the gap
    // between the authors row and the first card column.
    margin: (top: 6.3cm, bottom: 6.5cm),
    colors: (
      accent:  inc.hei-purple,
      heading: inc.hei-purple,
    ),
    fonts: (
      title:    "Source Sans Pro",
      authors:  "Source Sans Pro",
      body:     "Source Sans Pro",
      headings: "Source Sans Pro",
      card:     "Source Sans Pro",
      footer:   "Source Sans Pro",
    ),
    sizes: (authors: 22pt),
    footer: (
      // Institutional block lives in the page foreground overlay.
      content: [],
      logo: none,
      logo-placement: right,
      text-placement: left,
    ),
    body,
  )
  } // else (fonts available)
}

// Section content box for use inside isc-poster().
//
// Wraps @preview/placard's card() with ISC colours and optional vertical
// distribution.  When distribute-columns is active (the default), a leading
// v(1fr) is injected before every card except the first in each column, giving
// space-between semantics: first card at the top, last card at the bottom,
// equal space distributed between them.
//
// gap: auto  → 0pt when distributing (no trailing gap after last card);
//              placard default otherwise.
//      length → explicit override, always applied.
#let isc-card(title: "", fill: none, gap: auto, body) = {
  import "@preview/placard:0.1.0": card as _card
  // First card in each column: apply the column-start offset (closes the gap below
  // the authors block for every column equally). Subsequent cards get v(1fr) for
  // space-between distribution.
  context {
    if _isc-poster-distribute.get() {
      if _isc-first-card.get() { v(_isc-col-start-offset.get()) }
      else { v(1fr) }
    }
  }
  _isc-first-card.update(false)
  // Resolve effective gap: suppress trailing space when distributing so the
  // last card sits flush with the column bottom.
  context {
    let effective-gap = if gap != auto { gap }
                        else if _isc-poster-distribute.get() { 0pt }
                        else { none }
    _card(title: title, fill: fill, gap: effective-gap, body)
  }
}

// Column break that resets the first-card flag for the new column.
// Always use #isc-colbreak() instead of #colbreak() when distribute-columns is
// active, otherwise the leading spacer logic mis-fires in the next column.
#let isc-colbreak() = {
  _isc-first-card.update(true)
  colbreak()
}
