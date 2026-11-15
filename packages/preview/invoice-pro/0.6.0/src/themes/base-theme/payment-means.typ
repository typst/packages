// Draws the payment means of `direct-debit`, `card-payment` and `paid`. The
// component prepares the view (see there): an optional sentence (`text`)
// and the details to print, each with its `label`, its `value` and, for an
// identifier, whether it is `valid`. An invalid identifier is a data issue
// of the root, which a draft lists in its report; it is marked here only
// when an e-invoice reports its problems in the document
// (`report-problems`, `zugferd-errors: "report"`).
#let render-payment-means(ctx, view) = {
  let lines = ()
  let sentence = view.at("text", default: none)
  if sentence != none { lines.push(sentence) }
  for detail in view.at("details", default: ()) {
    let line = [#detail.label: #detail.value]
    if (
      not detail.at("valid", default: true)
        and view.at("report-problems", default: false)
    ) {
      line += text(fill: rgb("#b91c1c"))[ (invalid)]
    }
    lines.push(line)
  }
  block(width: 100%, {
    set par(leading: 0.4em)
    set text(number-type: "lining")
    lines.join(linebreak())
  })
}
