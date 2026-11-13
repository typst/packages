#import "design.typ": *
#import "options.typ": present
#import "labels.typ": default-labels
#let config = state("unofficial-monash-report-config", none)
#let current-config() = {
  let value = config.get()
  if value == none {
    (
      mode: "assignment", accent: monash-blue,
      labels: default-labels, show-marks: true, question-box: true,
      heading-font: resolve-font(auto, heading-fonts),
    )
  } else { value }
}
#let furniture(o, left-text, right-text, top-rule: false) = {
  set text(
    top-edge: compact-top-edge, bottom-edge: zero, font: o.heading-font,
    size: furniture-size, fill: monash-grey,
  )
  set par(justify: false, leading: zero)
  let row = grid(
    columns: (1fr, 1fr), column-gutter: furniture-gap,
    align(left, left-text), align(right, right-text),
  )
  let rule = line(length: full, stroke: hairline + monash-grey-mid)
  if top-rule {
    stack(spacing: furniture-gap, rule, row)
  } else {
    stack(spacing: furniture-gap, row, rule)
  }
}
#let running-head(o) = context {
  if o.mode == "assignment" {
    if here().page() > 1 {
      let author = if present(o.author) and present(o.student-id) {
        [#o.author (#o.student-id)]
      } else if present(o.author) {
        o.author
      } else { o.student-id }
      furniture(o, o.short-title, author)
    }
  } else {
    let headings = query(heading.where(level: 1))
      .filter(item => item.location().page() <= here().page())
    let current = if headings.len() > 0 {
      let on-page = headings.filter(item => item.location().page() == here().page())
      let item = if on-page.len() > 0 { on-page.first() } else { headings.last() }
      [#if item.numbering != none {
        numbering(item.numbering, ..counter(heading).at(item.location()))
        h(number-gap)
      }#item.body]
    }
    furniture(o, current, o.title)
  }
}
#let footer(o) = context furniture(o, o.short-title, counter(page).display(), top-rule: true)
#let page-style(o, body) = {
  set page(
    paper: o.paper, margin: (x: margin-x, top: margin-top, bottom: margin-bottom),
    numbering: "1", number-align: right,
    header-ascent: header-ascent, footer-descent: footer-descent,
    header: running-head(o), footer: footer(o),
  )
  body
}
