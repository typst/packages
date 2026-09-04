// Show rules for the CV body. Each rule matches one element type and reads
// only that element's own content, plus the two counters declared below.
//
// The code line is classified by the paragraph's *own ambient text style*:
// cv() declares `show raw: set text(font: font-chrome, ...)`, and Typst
// propagates that declared style up to the enclosing paragraph only when the
// paragraph consists of nothing but that one raw span. So "is this paragraph
// entirely one raw span" is answerable from the paragraph itself, with no
// marker content and no positional state; a raw span *inside* prose leaves
// the ambient alone and renders as ordinary inline code.
//
// The meta line cannot use the same trick, and is rendered from `show emph`
// instead: emph's italic toggle is applied *around* whatever a `show par`
// rule returns and cannot be overridden from inside it (verified — neither
// `set text(style: "normal")` nor `text(style: "normal")[...]` has any
// effect there), so a meta line rendered at paragraph level would always
// come out italic. A `show emph` replacement is not subject to the toggle.
// See specs/20260902-simplify.md.

#import "content.typ": flatten-text, split-last, get-children
#import "theme.typ": fg, muted, accent-at, resolve-font, space-paragraph, space-bullet, space-entry, space-section-to-rule, space-rule-to-content, space-header-to-section, space-header-line, space-code-indent, size-section-header, size-entry-title, size-body, size-small, size-footer, mark-gutter, logo-width, logo-height, logo-column, skills-label-chars
#import "marks.typ": draw-chevron, draw-rule, draw-placeholder-logo
#import "ats.typ": artifact

// The design's three pieces of cross-node state, all using the same pattern:
// a later sibling reads what an earlier sibling set. Everything else a rule
// needs comes from the element it matched.
#let section-counter = counter("cv-section") // accent rotation
#let entry-counter = counter("cv-entry") // a section's first entry takes a smaller top gap
// Set by every entry title, consumed by the first emph after it, cleared by
// every section header. This is what keeps the meta-line treatment off
// ordinary inline italics, which a `show emph` rule cannot otherwise tell
// apart from the meta-line convention — the markup contract defines the meta
// line by its position (the emph-only line right under an entry title), and
// position is precisely what the matched element does not know.
#let meta-expected = state("cv-meta-expected", false)

// Strips a Pandoc definition-list description's #block[...] wrapper so its
// always-wrapped form and direct-Typst's never-wrapped form read the same.
#let unwrap-block(node) = {
  if node.func() == block { node.at("body") } else { node }
}

// True when the ambient text style is the one cv()'s `show raw` show-set
// leaves behind — i.e. this paragraph is nothing but a raw span. Only
// meaningful inside `context`. Both font *and* size are checked because the
// chrome font alone is not unique to code: a section heading sets it too (at
// size-section-header), and that set lands in the heading's own paragraph
// ambient just the same. Typst normalises font names to lowercase and may
// hand back either a single name or a fallback list.
#let ambient-is-code(family) = {
  let f = text.font
  let name = if type(f) == str { f } else { f.at(0, default: "") }
  lower(name) == lower(family) and text.size == size-small
}

// ---- section header (H1) ---------------------------------------------

// Draws the chevron, colours the heading text (per accent-scope), and draws
// the rule line. Owns both the gap above every section header and the gap
// below the whole chevron+heading+rule block down to whatever content
// follows — centralising that second gap here means no other rule needs any
// notion of "am I the first thing in a section".
#let section-header-rule(accent-list, accent-scope, font-chrome) = it => {
  section-counter.step()
  entry-counter.update(0)
  meta-expected.update(false)
  let name = upper(flatten-text(it.body))
  block(above: space-header-to-section, below: space-rule-to-content, breakable: false, sticky: true, context {
    let color = accent-at(accent-list, section-counter.get().first() - 1)
    block(above: 0pt, below: space-section-to-rule, {
      // `horizon` centres the mark against this block — which holds the
      // heading line and nothing else — so the alignment needs no measured
      // or hand-tuned vertical offset.
      place(left + horizon, dx: -mark-gutter, draw-chevron(color))
      set text(..resolve-font(font-chrome, weight: "bold"), size: size-section-header)
      if accent-scope == "first3" and name.len() > 3 {
        text(fill: color, name.slice(0, 3)) + text(fill: fg, name.slice(3))
      } else {
        text(fill: color, name)
      }
    })
    draw-rule(color)
  })
}

// ---- entry title/date (H2) --------------------------------------------

// Splits the heading's own text on "|" and lays out title flush-left / date
// flush-right. Entry body content (prose, bullets, code line) is not this
// rule's concern — it flows afterwards as ordinary content, styled by the
// rules below. `sticky: true` keeps the title with the content under it
// across a page break.
//
// `above` is space-rule-to-content for a section's first entry (matching
// what a freeform or skills section's first line already gets straight from
// the section header) and space-entry for every entry after that.
#let entry-heading-rule(accent-list, font-body, font-chrome, show-logos) = it => {
  let (title, date) = split-last(flatten-text(it.body), "|")
  meta-expected.update(true)
  context {
    let is-first-entry = entry-counter.get().first() == 0
    entry-counter.step()
    let color = accent-at(accent-list, section-counter.get().first() - 1)
    block(
      above: if is-first-entry { space-rule-to-content } else { space-entry },
      below: space-header-line,
      breakable: false,
      sticky: true,
      inset: (left: if show-logos { logo-column } else { 0pt }),
      {
        set text(..resolve-font(font-body, weight: "semibold"), size: size-entry-title, fill: fg)
        title
        if date != none {
          h(1fr)
          text(..resolve-font(font-chrome, weight: "regular"), size: size-small, fill: color, date)
        }
      },
    )
  }
}

// ---- notes ---------------------------------------------------------------

// A Markdown blockquote immediately following a bullet, or directly under
// an entry's meta line — the muted annotation line, rendered only when
// show-notes is true. The quote already sits inside its parent's own body,
// so restyling it in place is enough; it never needs to know anything about
// the enclosing element (list item or meta line).
#let note-rule(font-body, show-notes) = it => {
  if not show-notes {
    none
  } else {
    // Block spacing collapses via max(), so the preceding paragraph's
    // larger `below` wins; negative space here compensates, pulling the
    // gap down to match this block's own below.
    v(-(space-paragraph - space-bullet))
    // .trim() matters here: Pandoc's blockquote output carries a leading
    // "space" run before the actual text, which flatten-text renders
    // literally — visibly shifting this line right of the text it is
    // supposed to align with.
    block(above: 0pt, below: space-bullet, {
      // size-footer, not a dedicated note size: a note is opt-in annotation
      // content (show-notes: true), the same "least essential text on the
      // page" tier as the page footer — see specs/20260902-simplify.md §9.
      set text(..resolve-font(font-body, weight: "regular"), size: size-footer, fill: muted)
      flatten-text(it.body).trim()
    })
  }
}

// ---- meta line / logo -----------------------------------------------------

// Pulls the entry logo and the org/location text out of a meta line's own
// children. The image node itself is kept (not just its path string) —
// Typst resolves a relative image path against the file that lexically
// contains the image() call, so reconstructing a fresh image() here would
// re-resolve the author's path against this package's directory instead.
#let extract-meta(nodes) = {
  let logo = none
  let text-nodes = ()
  for k in nodes {
    let body = k.at("body", default: none)
    if logo == none and k.func() == box and body != none and body.func() == image {
      logo = body
    } else {
      text-nodes.push(k)
    }
  }
  let (org, location) = split-last(text-nodes.map(flatten-text).join("").trim(), "|")
  (logo: logo, org: org, location: location)
}

// An emph in the meta-line position (see meta-expected above); every other
// emph is left alone and renders as ordinary inline italics. Returning the
// original `it` unmodified is safe — it is a fresh instance of the matched
// element that does not re-trigger this rule.
#let meta-line-rule(accent-list, font-body, show-logos) = it => context {
  if not meta-expected.get() {
    it
  } else {
    meta-expected.update(false)
    let meta = extract-meta(get-children(it.body))
    // Plain inline content: this is already the whole paragraph, so it needs
    // no box of its own to lay out against, and paragraph-rule supplies the
    // block wrapper and the gap below.
    let line = {
      if show-logos { h(logo-column) }
      set text(..resolve-font(font-body, weight: "regular"), size: size-body, fill: muted)
      if meta.org != none { meta.org }
      if meta.location != none { h(1fr); meta.location }
    }
    if not show-logos {
      line
    } else {
      let color = accent-at(accent-list, section-counter.get().first() - 1)
      // Purely decorative — the org name right beside it already carries the
      // same information — so it is a PDF artifact, exempt from PDF/UA-1
      // alt-text requirements. That also sidesteps a real Pandoc limitation:
      // alt text on an inline (non-block) Markdown image is silently dropped
      // by its typst writer. An entry with no logo still reserves the column
      // (a placeholder mark in the entry's accent colour) so sibling entries
      // stay aligned regardless of which ones have one.
      let logo-content = if meta.logo != none {
        artifact(box(width: logo-width, height: logo-height, clip: true, align(center + horizon, meta.logo)), kind: "other")
      } else {
        draw-placeholder-logo(color, width: logo-width, height: logo-height)
      }
      // Reach back up over the entry title so the logo reads as belonging to
      // the whole title+meta group rather than to this line alone. Measured
      // from an explicit text style, never the ambient one — the ambient
      // here is the meta line's, not the title's. Known limitation: a title
      // that wraps to two lines is not accounted for.
      let title-height = measure(block(text(..resolve-font(font-body, weight: "semibold"), size: size-entry-title)[Ag])).height
      let meta-line-height = measure(block(text(..resolve-font(font-body, weight: "regular"), size: size-body)[Ag])).height
      // logo-height doesn't equal title-height + space-header-line +
      // meta-line-height (a fixed token vs. font-metric-derived heights, no
      // reason they'd match) — split the leftover evenly above and below so
      // the logo overhangs the title/meta group by the same amount on both
      // ends, rather than flush on one side and off by the full remainder on
      // the other.
      let overhang = logo-height - (title-height + space-header-line + meta-line-height)
      place(dx: 0pt, dy: -(space-header-line + title-height) - overhang / 2, logo-content)
      line
    }
  }
}

// ---- paragraphs: code line and prose --------------------------------------

#let paragraph-rule(font-chrome) = it => context {
  if ambient-is-code(font-chrome) {
    block(above: 0pt, below: space-bullet, inset: (left: space-code-indent), it.body)
  } else {
    block(above: 0pt, below: space-paragraph, it.body)
  }
}

// A bare list has no block-level above/below of its own to collapse against
// a following show-rule-produced block that declares `above: 0pt` — without
// this wrapper the next block overlaps the list's last line. Returning `it`
// unmodified is what keeps this from re-matching itself.
#let list-rule = it => block(above: 0pt, below: space-paragraph, it)

// ---- skills row -------------------------------------------------------------

// One line of real text per row: a monospace (font-chrome) label padded with
// literal space characters to a fixed column width, not a box or table
// gutter — several PDF text extractors (pymupdf's default plain-text mode
// included) insert a spurious line break when a box's reserved width leaves
// a large glyph-free gap on the line, even at the same baseline.
#let skills-item-rule(accent-list, font-chrome, font-body) = it => context {
  let color = accent-at(accent-list, section-counter.get().first() - 1)
  let label = flatten-text(it.term).trim()
  let desc = flatten-text(unwrap-block(it.description)).trim()
  block(above: 0pt, below: space-bullet, {
    // At least one space, so an over-long label still separates from its
    // description instead of failing on a negative repeat count.
    text(..resolve-font(font-chrome, weight: "medium"), size: size-small, fill: color, label + " " * calc.max(skills-label-chars - label.len(), 1))
    text(..resolve-font(font-body, weight: "regular"), size: size-body, fill: fg, desc)
  })
}
