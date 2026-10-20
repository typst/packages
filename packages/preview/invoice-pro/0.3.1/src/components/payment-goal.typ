#import "../loom-wrapper.typ": loom, managed-motif
#import "../utils/types.typ"
#import "../utils/coercion.typ"

/// Displays the payment deadline and terms for the invoice.
///
/// -> content
#let payment-goal(
  /// The number of days allowed for payment from the invoice date.
  /// -> none | int
  days: none,

  /// A specific fixed date for the payment deadline.
  /// -> none | datetime | string | content
  date: none,
) = {
  types.require(days, "payment-goal::days", none, int)
  types.require(date, "payment-goal::date", none, datetime, str, content)

  managed-motif(
    "payment-goal",
    scope: ctx => loom.mutator.batch(ctx, {
      import loom.mutator: *

      nest("locale", {
        nest("format", {
          ensure("currency", (..) => panic(
            "locale::format::currency is not provided",
          ))
          ensure("date", (..) => panic("locale::date is not provided"))
        })
      })

      nest("theme", {
        ensure("payment-goal", (..) => panic(
          "theme::payment-goal is not provided",
        ))
      })

      nest("global", {
        nest("total", {
          ensure("gross", 0)
        })
      })
    }),
    measure: (ctx, _) => {
      let data = (
        days: days,
        date: date,
        total: ctx.global.total.gross,
      )

      (none, data)
    },
    draw: (ctx, _, view, ..) => (ctx.theme.payment-goal)(ctx, view),
    none,
  )
}
