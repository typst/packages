#import "../../utils/format.typ"

#let render-payment-goal(ctx, view) = {
  let sum-str = (ctx.format.currency)(view.total)

  let deadline = if view.date != none {
    let date-str = if type(view.date) == datetime {
      view.date.display("[day].[month].[year]")
    } else {
      view.date
    }
    [bis spätestens #date-str]
  } else if view.days != none {
    [innerhalb von #view.days Tagen]
  } else {
    [zeitnah]
  }

  [Bitte überweisen Sie den Gesamtbetrag von *#sum-str* #deadline ohne Abzug auf das unten genannte Konto.]
}
