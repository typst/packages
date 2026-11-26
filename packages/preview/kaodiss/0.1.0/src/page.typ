// Page geometry, running heads and empty pages (kaobook scrheadings).
#import "metrics.typ" as m
#import "state.typ": *
#import "@preview/marginalia:0.3.1" as marginalia

// Top of the text area, measured from the top of the page.
#let area-top = m.top + m.top-correction

// Margins of the 1.5-column layout (kaobook \marginlayout).
#let margin-config = (
  inner: (far: m.inner, width: 0mm, sep: 0mm),
  outer: (far: m.outer-far, width: m.margin-width, sep: m.margin-sep),
  top: area-top,
  bottom: m.bottom - m.bottom-correction,
  book: true,
  clearance: m.margin-clearance,
)

#let margin-page-margins = (
  inside: m.inner,
  outside: m.outer-far + m.margin-width + m.margin-sep,
  top: area-top,
  bottom: m.bottom - m.bottom-correction,
)

// Margins of the wide layout (kaobook \widelayout), used for front and back matter.
#let wide-page-margins = (
  inside: m.inner,
  outside: m.wide-outer,
  top: area-top,
  bottom: m.bottom - m.bottom-correction,
)

// Switches to the 1.5-column layout. Must be used as a show rule; starts a new page.
#let margin-layout(body) = {
  marginalia._config.update(marginalia._fill_config(..margin-config))
  set page(margin: margin-page-margins, binding: left)
  body
}

// Switches to the wide layout. Must be used as a show rule; starts a new page.
#let wide-layout(body) = {
  set page(margin: wide-page-margins, binding: left)
  body
}

// --- Page classification -------------------------------------------------------

// Returns "start" for the first page of a chapter or part, "blank" for pages
// left empty by \cleardoublepage and "normal" otherwise. Requires context.
#let page-kind(p) = {
  let starts = query(<kao-start>)
  let next = starts.find(s => s.location().page() >= p)
  if next != none and next.location().page() == p { return "start" }
  // A page is empty if a \cleardoublepage break happened on an earlier page
  // and no chapter or part has started since.
  let breaks = query(<kao-break>).filter(b => b.location().page() < p)
  if next == none or breaks.len() == 0 { return "normal" }
  let last-break = breaks.last().location()
  let started-since = starts.any(s => {
    let sp = s.location().page()
    sp < p and (sp > last-break.page() or (sp == last-break.page() and s.location().position().y > last-break.position().y))
  })
  if started-since { "normal" } else { "blank" }
}

#let matter-at(p) = {
  let marks = query(<kao-matter>).filter(x => x.location().page() <= p)
  if marks.len() == 0 { "front" } else { marks.last().value }
}

// --- Running heads -------------------------------------------------------------

#let heading-mark(hd) = {
  let nums = counter(heading).at(hd.location())
  let number = if hd.numbering != none { numbering(hd.numbering, ..nums) }
  if number != none and number != [] and number != "" {
    [#number#h(0.5em)]
  }
  hd.body
}

// Chapter shown on left-hand pages: the last chapter started on or before p.
#let chapter-mark(p) = {
  let chapters = query(heading.where(level: 1)).filter(h => not is-part(h) and h.location().page() <= p)
  if chapters.len() > 0 { heading-mark(chapters.last()) }
}

// Section shown on right-hand pages: the first section on page p, or else the
// last one before p (LaTeX's \rightmark), but only within the current chapter.
#let section-mark(p) = {
  let chapters = query(heading.where(level: 1)).filter(h => h.location().page() <= p)
  let chapter-page = if chapters.len() > 0 { chapters.last().location().page() } else { 0 }
  let sections = query(heading.where(level: 2)).filter(h => {
    let hp = h.location().page()
    hp >= chapter-page and hp <= p
  })
  let on-page = sections.filter(h => h.location().page() == p)
  if on-page.len() > 0 { heading-mark(on-page.first()) } else if sections.len() > 0 {
    heading-mark(sections.last())
  } else { chapter-mark(p) }
}

// Draws the kaobook running head: page number, thin vertical rule, mark.
#let running-head(p, rule-color: black) = {
  set text(size: m.size.normalsize, style: "italic", top-edge: m.top-edge, bottom-edge: m.bottom-edge)
  set par(justify: false)
  let y = m.head-baseline - 0.75 * m.size.normalsize
  let rule = line(
    angle: 90deg,
    length: 18mm,
    stroke: m.head-rule-width + rule-color,
  )
  let rule-top = m.head-baseline + 1mm - 18mm
  let number = counter(page).display()
  if calc.even(p) {
    let x = m.outer-far
    place(top + left, dx: x, dy: y, box(width: m.head-number-box, align(right, number)))
    place(top + left, dx: x + m.head-number-box + m.head-rule-gap + m.head-rule-width / 2, dy: rule-top, rule)
    place(
      top + left,
      dx: x + m.head-number-box + 2 * m.head-rule-gap + m.head-rule-width,
      dy: y,
      box(width: m.text-width, chapter-mark(p)),
    )
  } else {
    let x = m.page-width - m.outer-far
    place(top + left, dx: x - m.head-number-box, dy: y, box(width: m.head-number-box, align(left, number)))
    place(
      top + left,
      dx: x - m.head-number-box - m.head-rule-gap - m.head-rule-width / 2,
      dy: rule-top,
      rule,
    )
    place(
      top + left,
      dx: x - m.head-number-box - 2 * m.head-rule-gap - m.head-rule-width - m.text-width,
      dy: y,
      box(width: m.text-width, align(right, section-mark(p))),
    )
  }
}

// Page background: the running head on ordinary main-matter pages, and the
// layout frame in draft mode.
#let page-background(draft: false, rule-color: black) = context {
  let p = here().page()
  if draft {
    let r = 0.3pt + rgb(80%, 85%, 95%)
    let left-x = if calc.odd(p) { m.inner } else { m.page-width - m.inner - m.text-width }
    let matter = matter-at(p)
    if matter == "main" {
      place(top + left, dx: left-x, dy: area-top, rect(width: m.text-width, height: m.page-height - area-top - m.bottom + m.bottom-correction, stroke: r))
      let margin-x = if calc.odd(p) { left-x + m.text-width + m.margin-sep } else { left-x - m.margin-sep - m.margin-width }
      place(top + left, dx: margin-x, dy: area-top, rect(width: m.margin-width, height: m.page-height - area-top - m.bottom + m.bottom-correction, stroke: r))
    } else {
      place(top + left, dx: m.inner, dy: area-top, rect(width: m.wide-width, height: m.page-height - area-top - m.bottom + m.bottom-correction, stroke: r))
    }
  }
  if matter-at(p) == "main" and page-kind(p) == "normal" {
    running-head(p, rule-color: rule-color)
  }
}
