#import "design.typ": *
#import "options.typ": present, plain
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
// Fit furniture text on one line of `width`: overlong text is cut after a whole word
// (or a character, for a single long word) and ends with an ellipsis. Content without
// text is clipped instead.
#let one-line(body, width) = {
  let natural = measure(body).width
  if natural <= width { return body }
  let words = plain(body)
  if words == "" { return box(width: width, clip: true, box(width: natural, body)) }
  let clusters = words.clusters()
  let fits(count) = measure(clusters.slice(0, count).join() + "…").width <= width
  let (low, high) = (0, clusters.len())
  while low < high {
    let middle = calc.ceil((low + high) / 2)
    if fits(middle) { low = middle } else { high = middle - 1 }
  }
  let words = clusters.slice(0, low).join(default: "").split(" ")
  if clusters.at(low, default: " ") != " " and words.len() > 1 { words = words.slice(0, -1) }
  words.join(" ").trim() + "…"
}
#let furniture(o, left-text, right-text, top-rule: false) = {
  set text(
    top-edge: compact-top-edge, bottom-edge: zero, font: o.heading-font,
    size: furniture-size, fill: monash-grey, hyphenate: false,
  )
  set par(justify: false, leading: zero)
  show linebreak: [ ]
  // Each side keeps to one line. A side shorter than half the width leaves the rest
  // to the other side; otherwise both get half.
  let row = layout(size => {
    let available = size.width - furniture-gap
    let left-width = measure([#left-text]).width
    let right-width = measure([#right-text]).width
    let widths = if left-width + right-width <= available or left-width <= available / 2 {
      (left-width, available - left-width)
    } else if right-width <= available / 2 {
      (available - right-width, right-width)
    } else { (available / 2, available / 2) }
    grid(
      columns: widths, column-gutter: furniture-gap,
      align(left, one-line([#left-text], widths.first())),
      align(right, one-line([#right-text], widths.last())),
    )
  })
  let rule = line(length: full, stroke: hairline + monash-grey-mid)
  if top-rule {
    stack(spacing: furniture-gap, rule, row)
  } else {
    stack(spacing: furniture-gap, row, rule)
  }
}
// The level-1 heading named in the running head at `location`: the first on that
// page, else the last before it. Outline titles (such as "Contents") are skipped.
#let current-chapter(location) = {
  let titles = query(outline).filter(item => item.title != none).map(item => {
    query(heading.where(level: 1).after(item.location())).at(0, default: none)
  }).filter(item => (
    item != none and not item.outlined
  )).map(item => item.location())
  let headings = query(heading.where(level: 1))
    .filter(item => item.location().page() <= location.page())
    .filter(item => item.location() not in titles)
  let on-page = headings.filter(item => item.location().page() == location.page())
  if on-page.len() > 0 { on-page.first() } else { headings.at(-1, default: none) }
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
    let item = current-chapter(here())
    let current = if item != none {
      [#if item.numbering != none {
        numbering(item.numbering, ..counter(heading).at(item.location()))
        h(number-gap)
      }#item.body]
    }
    furniture(o, current, o.short-title)
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
