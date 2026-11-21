#import "design.typ": *
#import "options.typ": present, date-text
#import "labels.typ": labelled
#let titleblock(o) = {
  set text(top-edge: compact-top-edge, bottom-edge: zero)
  set par(justify: false, leading: title-leading)
  v(first-page-top - margin-top, weak: false)
  let items = ()
  if present(o.author) { items.push(text(weight: "bold", fill: monash-black, o.author)) }
  if present(o.student-id) { items.push(o.student-id) }
  if present(o.tutor) { items.push(labelled(o.labels.tutor, o.tutor)) }
  if present(o.date) { items.push(date-text(o.date)) }
  items += o.info.filter(present)
  if present(o.logo) or present(o.unit) or present(o.semester) {
    block(width: full, below: title-gap)[
      #grid(
        columns: (1fr, 1fr), align: bottom,
        block(height: assignment-logo-height, if present(o.logo) {
          context {
            let height = measure(o.logo).height
            if height > zero {
              let ratio = assignment-logo-height / height * full
              scale(x: ratio, y: ratio, reflow: true, o.logo)
            } else { o.logo }
          }
        }),
        align(right, text(
          top-edge: body-top-edge, bottom-edge: furniture-bottom-edge,
          font: o.heading-font, size: furniture-size, fill: monash-grey-dark,
          (o.unit, o.semester).filter(present).join(linebreak()),
        )),
      )
    ]
  }
  block(
    above: zero, inset: (top: assignment-title-inset),
    below: if items.len() > 0 { byline-gap } else { zero },
    text(
      top-edge: title-top-edge, bottom-edge: title-bottom-edge, hyphenate: false,
      font: o.heading-font, size: assignment-title-size, weight: light-weight,
      fill: o.accent, o.title,
    ),
  )
  if items.len() > 0 {
    block(above: zero, below: zero, text(
      top-edge: body-top-edge, bottom-edge: body-bottom-edge,
      font: o.heading-font, size: byline-size, fill: monash-grey-dark, items.join([ · ]),
    ))
  }
  v(rule-gap)
  notch-rule()
  v(first-question-gap - notch-depth - question-above)
}
