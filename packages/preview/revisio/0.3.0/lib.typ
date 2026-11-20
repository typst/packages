/*
 * revisio
 *
 * Word-style review comments. `#comment[note][text]` attaches a note to a
 * passage. Comments are invisible by default; with
 * `#show: revisio.with(enabled: true)` the passage is highlighted and
 * the note appears in an extra right-hand margin (the page is widened on the
 * right only, so text layout and page breaks stay the same).
 */

#let _enabled = state("revisio-enabled", false)
#let _text-right = state("revisio-text-right", 0cm)
#let _show-resolved = state("revisio-show-resolved", true)
#let _counter = counter("review-comment")

// Page widths (portrait) of the standard Typst paper sizes.
#let _paper-widths = (
  a3: 29.7cm, a4: 21cm, a5: 14.8cm, a6: 10.5cm,
  b4: 25cm, b5: 17.6cm, b6: 12.5cm,
  "iso-b5": 17.6cm, "us-letter": 21.59cm, "us-legal": 21.59cm,
  "us-executive": 18.42cm, "us-tabloid": 27.94cm,
)

/// Document-level setup. Apply with `#show: revisio.with(...)`.
///
/// - enabled (bool): show the comments (default `false`: they are hidden).
/// - paper (str): paper size of the document, e.g. `"a4"` (default),
///   `"a5"`, `"us-letter"`. Used to place the comments correctly.
/// - paper-width (length, auto): explicit page width *without* the comment
///   margin, for sizes not covered by `paper` (overrides `paper`).
/// - margin-right (length): the document's normal right page margin
///   (default: 3cm).
/// - margin-width (length): width of the extra comment margin.
/// - show-resolved (bool): show comments marked `resolved: true` (default
///   `true`; they are green). With `false` they are hidden like when
///   `enabled` is off.
/// - fill, accent (color): highlight/card colour and the card's left border.
/// - resolved-fill, resolved-accent (color): the same for resolved comments.
#let revisio(
  enabled: false,
  show-resolved: true,
  paper: "a4",
  paper-width: auto,
  margin-right: 3cm,
  margin-width: 5.5cm,
  fill: rgb("#fff2a8"),
  accent: rgb("#e0b800"),
  resolved-fill: rgb("#cdeccb"),
  resolved-accent: rgb("#3a9a47"),
  body,
) = {
  assert(paper-width != auto or paper in _paper-widths, message: "unknown paper size \"" + paper + "\": pass paper-width instead")
  let paper-width = if paper-width == auto { _paper-widths.at(paper) } else { paper-width }
  _enabled.update(enabled)
  _text-right.update(paper-width - margin-right)
  _show-resolved.update(show-resolved)
  state("revisio-style").update((
    margin-width: margin-width,
    fill: fill,
    accent: accent,
    resolved-fill: resolved-fill,
    resolved-accent: resolved-accent,
  ))
  set page(width: paper-width + margin-width, margin: (right: margin-right + margin-width)) if enabled
  body
}

/// A review comment.
///
/// - ..args: `[note]` or `[note][highlighted text]`.
/// - author (str, content, none): shown in bold on the card.
/// - date (str, content, none): shown next to the author.
/// - resolved (bool): mark the comment as resolved: it turns green and can be
///   hidden with `show-resolved: false`.
#let comment(..args, author: none, date: none, resolved: false) = {
  let pos = args.pos()
  assert(pos.len() in (1, 2), message: "usage: #comment[note][text], or #comment[note] for an anchor-only comment")
  let note = pos.at(0)
  let body = if pos.len() == 2 { pos.at(1) } else { none }
  context if _enabled.get() and (not resolved or _show-resolved.get()) {
    let style = state("revisio-style").get()
    let (fill, accent) = if resolved {
      (style.resolved-fill, style.resolved-accent)
    } else {
      (style.fill, style.accent)
    }
    let gap = 0.4cm
    let width = style.margin-width - gap - 0.3cm
    _counter.step()
    let n = context _counter.display()
    if body != none { highlight(fill: fill, body) }
    super(text(fill: if resolved { accent } else { rgb("#b8860b") }, weight: "bold", size: 0.8em, n))
    let card = block(
      width: width,
      fill: fill.lighten(40%),
      stroke: (left: 1.5pt + accent),
      inset: (x: 5pt, y: 4pt),
      radius: 1pt,
      {
        set text(size: 7pt, weight: "regular", style: "normal")
        set par(justify: false, first-line-indent: 0em, leading: 0.4em)
        if author != none or date != none {
          text(weight: "bold")[#n. #author]
          if resolved { h(0.3em); text(fill: accent, weight: "bold")[✓] }
          if date != none { h(0.4em); text(fill: luma(100), date) }
          linebreak()
        } else {
          text(weight: "bold")[#n.]
          if resolved { h(0.2em); text(fill: accent, weight: "bold")[✓] }
          h(0.3em)
        }
        note
      },
    )
    // Next to its anchor; a note that would overlap the previous one on the
    // same page is pushed down below it.
    // Each note's anchor position and height are published as metadata; the
    // offset is then computed from the earlier notes only, which converges
    // quickly however many comments there are.
    box(width: 0pt, context {
      let pos = here().position()
      let h = measure(card).height
      let earlier = query(selector(<revisio-note>).before(here(), inclusive: false))
      let bottom = none
      for m in earlier {
        let v = m.value
        if v.page == pos.page {
          let top = if bottom == none { v.y } else { calc.max(v.y, bottom + 3pt) }
          bottom = top + v.h
        }
      }
      let dy = if bottom == none { 0pt } else { calc.max(0pt, bottom + 3pt - pos.y) }
      [#metadata((page: pos.page, y: pos.y, h: h)) <revisio-note>]
      place(top + left, dx: _text-right.get() - pos.x + gap, dy: dy, card)
    })
  } else {
    body
  }
}
