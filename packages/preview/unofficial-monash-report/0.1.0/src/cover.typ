#import "design.typ": *
#import "options.typ": present, date-text
#let balanced(body) = layout(size => {
  let height = measure(block(width: size.width, body)).height
  let low = size.width / 2
  let high = size.width
  for _ in range(12) {
    let middle = (low + high) / 2
    if measure(block(width: middle, body)).height <= height {
      high = middle
    } else { low = middle }
  }
  block(width: high + hairline, body)
})
#let cover(o) = {
  let fields = ()
  if o.authors.len() == 0 {
    fields += ((o.labels.author, o.author), (o.labels.student-id, o.student-id))
  }
  fields += (
    (o.labels.supervisor, o.supervisor), (o.labels.date, date-text(o.date)),
    (o.labels.word-count, o.word-count),
  )
  fields += o.info
  fields = fields.filter(pair => present(pair.last()))
  let bottom-block = [
    #set text(size: field-size)
    #set par(leading: body-leading)
    #if o.authors.len() > 0 {
      let contributions = o.authors.any(person => present(person.at("contribution", default: none)))
      let cells = ()
      for person in o.authors {
        cells += (person.name, person.at("student-id", default: []))
        if contributions { cells.push(person.at("contribution", default: [])) }
      }
      let headers = (o.labels.author, o.labels.student-id)
      if contributions { headers.push(o.labels.contribution) }
      table(
        align: left, columns: if contributions { (1fr, 1fr, 1fr) } else { (1fr, 1fr) },
        table.header(..headers.map(emph)),
        ..cells,
      )
      if fields.len() > 0 { v(group-gap) }
    }
    #if fields.len() > 0 {
      grid(
        columns: (field-label-width, 1fr),
        column-gutter: field-gap, row-gutter: field-row-gap,
        ..fields.map(pair => (
          block(
            above: zero, below: zero, inset: (bottom: field-row-bottom),
            text(style: "italic", fill: monash-grey-dark, pair.first()),
          ),
          block(above: zero, below: zero, inset: (bottom: field-row-bottom), [#pair.last()]),
        )).flatten(),
      )
    }
  ]
  let title-block = [
    #set par(leading: cover-title-leading, justify: false, linebreaks: "optimized")
    #set text(hyphenate: false)
    #if present(o.unit) {
      block(height: cover-unit-height, below: cover-gap, text(
        font: o.heading-font, size: unit-size, weight: "bold", fill: o.accent,
        tracking: unit-tracking, upper(o.unit),
      ))
    }
    #block(inset: (top: cover-title-inset), balanced(text(
      font: o.heading-font, size: cover-title-size, weight: light-weight, fill: o.accent,
      o.title,
    )))
    #if present(o.subtitle) {
      v(cover-gap)
      block(text(size: subtitle-size, style: "italic", fill: monash-grey-dark, o.subtitle))
    }
    #v(cover-gap + cover-rule-gap)
    #notch-rule()
    #if present(o.doc-type) { v(cover-gap); block(text(size: doc-type-size, o.doc-type)) }
  ]
  page(
    paper: o.paper, margin: (x: margin-x, top: cover-top, bottom: margin-bottom),
    header: none, footer: none, numbering: none,
    background: align(bottom, rect(
      width: full, height: cover-band, fill: o.accent, stroke: none,
    )),
    [
      #set par(justify: false)
      #set text(top-edge: compact-top-edge, bottom-edge: zero)
      #block(width: full, height: full)[
        #if present(o.logo) or present(o.faculty) or present(o.semester) {
          place(top + left, grid(
            columns: (1fr, 1fr), align: bottom,
            if present(o.logo) {
              context {
                let height = measure(o.logo).height
                if height > zero {
                  let ratio = cover-logo-height / height * full
                  scale(x: ratio, y: ratio, reflow: true, o.logo)
                } else { o.logo }
              }
            },
            align(right, text(
              font: o.heading-font, size: furniture-size, fill: monash-grey-dark,
              (o.faculty, o.semester).filter(present).join(linebreak()),
            )),
          ))
        }
        #layout(size => {
          let title-height = measure(block(width: size.width, title-block)).height
          let fields-height = measure(block(width: size.width, bottom-block)).height
          let desired = cover-title-top - cover-top
          let title-y = calc.max(
            cover-logo-height + cover-gap,
            calc.min(desired, size.height - title-height - fields-height - group-gap),
          )
          place(top + left, dy: title-y, block(width: full, title-block))
          place(top + left, dy: size.height - fields-height, block(width: full, bottom-block))
        })
      ]
    ],
  )
}
