
#import "general.typ": (
  accent-color, detail-stack, draft-pattern, font-size, formal-general, ghost, ghost-color,
  inline-heading, smaller-font-size,
)
#import "margins.typ": page-margin-setting, resolve-page-margin
#import "@preview/drafting:0.2.2": margin-note, set-margin-note-defaults, set-page-properties

#let resolve-marginalia-width(content-width, marginalia-width) = {
  if type(marginalia-width) == type(1fr) {
    return marginalia-width / 1fr * content-width
  }

  marginalia-width
}

#let marginalia-rect(stroke: none, fill: none, width: auto, body) = rect(
  stroke: stroke,
  fill: fill,
  width: width,
  inset: 0pt,
  align(left, block(width: 100%, body)),
)

#let style-page(
  draft: false,
  page-paper: "a4",
  page-width: auto,
  page-height: auto,
  page-margin: auto,
  marginalia-width: 0.33fr,
  marginalia-gutter: 5mm,
  body,
) = {
  let page-args = (
    background: if draft { draft-pattern } else { none },
    margin: page-margin-setting(page-margin),
  )

  if page-width != auto and page-height != auto {
    page-args.width = page-width
    page-args.height = page-height
  } else {
    page-args.paper = page-paper
  }

  set page(..page-args)

  context {
    let resolved-page-margin = resolve-page-margin(
      page.margin,
      page.width,
      page.height,
      here().page(),
    )
    let page-body-width = page.width - resolved-page-margin.left - resolved-page-margin.right
    let marginalia-column-width = resolve-marginalia-width(page-body-width, marginalia-width)
    let text-width = page-body-width - marginalia-gutter - marginalia-column-width

    // NOTE: drafting places right-side note boxes 2% of the text width away from the text column.
    // It also shrinks the effective note box by the same amount on both sides, so compensate here
    // to keep the configured gutter and marginalia width visible on the page.
    let drafting-gap = 2 * text-width / 100
    let note-region-width = marginalia-column-width + 2 * drafting-gap

    set page(margin: (
      top: resolved-page-margin.top,
      bottom: resolved-page-margin.bottom,
      left: resolved-page-margin.left,
      right: resolved-page-margin.right + marginalia-gutter + marginalia-column-width,
    ))

    set-page-properties(
      margin-right: note-region-width,
      page-offset-x: marginalia-gutter - drafting-gap,
    )

    set-margin-note-defaults(
      rect: marginalia-rect,
      stroke: none,
      side: right,
    )

    body
  }
}

#let style-text(lang: "en", body) = {
  set text(
    lang: lang,
    costs: (hyphenation: 10%),
  )
  body
}

#let style-tables(smaller-font-size: smaller-font-size, body) = {
  show table: set text(size: smaller-font-size)
  show table.cell.where(y: 0): strong

  set table(
    stroke: (_, y) => (
      left: none,
      right: none,
      bottom: if y == 0 { 0.5pt + accent-color },
    ),
  )

  set table(align: horizon)
  // TODO: Add header style
  // Currently not supported: https://github.com/typst/typst/issues/3640
  body
}


// NOTES AND MARGINALIA

// Note styles
#let style-note(body) = {
  set math.equation(numbering: none)
  show math.equation.where(block: true): set block(spacing: 0.5em)
  set text(size: smaller-font-size)
  body
}

#let wide(body) = context {
  let margins = resolve-page-margin(page.margin, page.width, page.height, here().page())
  let left-margin = margins.left
  let right-margin = margins.right
  block(width: 100% + calc.max(0pt, right-margin - left-margin), body)
}

#let marginalia(title: none, ..content) = {
  show: style-note

  let body = if content.pos().len() == 1 {
    content.at(0)
  } else {
    if title == none {
      title = content.at(0)
    }
    content.pos().slice(1).join(linebreak())
  }

  let title = inline-heading(title)
  margin-note(if title == none { body } else { title + body }, dy: -1em)
}

// Paragraph-level note
#let note(cols: 1, title: none, body) = {
  show: style-note

  let heading = inline-heading(title)
  let content = {
    set align(left)
    show: it => columns(cols, it)
    if heading != none {
      heading
    }
    body
  }

  block(
    width: 100%,
    fill: ghost-color.transparentize(95%),
    inset: 3mm,
    radius: 2mm,
    content,
  )
}


// TEMPLATE

#let header(authors: none, date: none) = {
  let content = detail-stack(
    if authors != none { text(weight: "medium", authors) },
    if date != none { ghost(date) },
  )

  if content == none {
    return none
  }

  margin-note(content)
}

#let formal-text(
  body,
  authors: none,
  date: none,
  lang: "en",
  draft: false,
  page-paper: "a4",
  page-width: auto,
  page-height: auto,
  page-margin: auto,
  marginalia-width: 0.33fr,
  marginalia-gutter: 5mm,
  font-size: font-size,
) = {
  show: formal-general.with(font-size: font-size)

  show: style-text.with(lang: lang)
  show: style-page.with(
    draft: draft,
    page-paper: page-paper,
    page-width: page-width,
    page-height: page-height,
    page-margin: page-margin,
    marginalia-width: marginalia-width,
    marginalia-gutter: marginalia-gutter,
  )
  show: style-tables

  header(
    authors: authors,
    date: date,
  )

  body
}
