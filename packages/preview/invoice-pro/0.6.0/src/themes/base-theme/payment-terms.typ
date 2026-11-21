#import "../../utils/format.typ"

#let render-payment-terms(ctx, view) = {
  let pay-str = ctx.locale.strings.payment
  let format = ctx.locale.format

  let deadline = if view.date != none {
    let date-str = if type(view.date) == datetime {
      (format.date)(view.date)
    } else {
      view.date
    }
    (pay-str.deadline-date)(date-str)
  } else if view.days != none {
    (pay-str.deadline-days)(view.days)
  } else {
    pay-str.deadline-soon
  }

  // after prepayments the sentence names the amount due, not the total
  let sentence = if view.at("amount-kind", default: "total") == "amount-due" {
    pay-str.text-due
  } else { pay-str.text }
  sentence((format.currency)(view.total), deadline)
}
