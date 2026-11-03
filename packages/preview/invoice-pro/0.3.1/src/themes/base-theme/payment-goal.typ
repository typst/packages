#import "../../utils/format.typ"

#let render-payment-goal(ctx, view) = {
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

  (pay-str.text)(
    (format.currency)(view.total),
    deadline,
  )
}
