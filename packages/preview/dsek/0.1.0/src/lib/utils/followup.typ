#import "../misc/assertions.typ": required-keys
#import "translate.typ": translate

#let followup(..decisions) = {
  show table.cell: set par(justify: false)
  table(
    columns: (auto, 1fr, auto, auto),
    stroke: none,
    table.hline(stroke: 0.4pt, position: bottom),
    table.header(
      [*#translate("Taget", "Meeting")*],
      [*#translate("Beslut", "Decision")*],
      [*#translate("Ansvarig", "Responsible")*],
      [*#translate("Redovisas", "Due")*],
    ),
    row-gutter: (0.25em, auto),
    ..decisions
      .pos()
      .map(x => {
        let (taget, beslut, ansvarig, redovisas) = x
        let limit(item, max: 85pt) = context {
          let width = measure(item).width
          block(width: calc.min(width, max), item)
        }
        (limit(taget), beslut, limit(ansvarig), limit(redovisas))
      })
      .flatten(),
  )
}

#let uppföljningslista = followup
