#import "../loom-wrapper.typ": loom, managed-motif
#import "../utils/types.typ"
#import "../utils/coercion.typ"
#import "../logic/cash-discount.typ"
#import "../logic/document-type.typ": sender-pays
#import "../logic/payment-means.typ": goal-strings, of-context

/// Displays the payment deadline and terms for the invoice.
///
/// The sentence follows the payment means of the invoice: a credit transfer
/// (`bank-details`), a direct debit (`direct-debit`) or a payment card
/// (`card-payment`). An invoice that is paid already (`paid`) has no payment
/// goal.
///
/// -> content
#let payment-goal(
  /// The number of days allowed for payment from the invoice date.
  /// -> none | int
  days: none,

  /// A specific fixed date for the payment deadline.
  /// -> none | datetime | string | content
  date: none,

  /// A cash discount (Skonto) for a payment within fewer days, e.g.
  /// `(days: 14, percent: 2%)`, optionally with the `basis`, the amount it
  /// applies to. An array of them states several steps. Each one is printed
  /// after the payment sentence and stated in the payment terms of the
  /// e-invoice (BT-20).
  /// -> none | dictionary | array
  discount: none,
) = {
  types.require(days, "payment-goal::days", none, int)
  types.require(date, "payment-goal::date", none, datetime, str, content)
  types.require-day(date, "payment-goal::date")
  types.require(discount, "payment-goal::discount", none, dictionary, array)
  let discounts = cash-discount.normalize(discount)

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
          ensure("prepaid", 0)
        })
      })
    }),
    measure: (ctx, _) => {
      // A cash discount is granted by the seller to the buyer who pays. The
      // sender of a credit note or a self-billed invoice pays the amount, and
      // its notes would state the discount in the wrong direction.
      if (
        discounts.len() > 0
          and sender-pays(ctx.at("document-type", default: none))
      ) {
        panic(
          "payment-goal: a cash discount (`discount`) is not supported on a credit note or a self-billed invoice, whose sender pays the amount. Remove `discount`.",
        )
      }
      let means = of-context(ctx)
      let data = (
        days: days,
        date: date,
        total: ctx.global.total.at("due", default: ctx.global.total.gross),
        // Prepayments reduce the payable amount, so `total` is the remaining
        // amount due rather than the gross total.
        has-prepayments: ctx.global.total.prepaid > 0,
        // The kind of payment means the sentence is for: "direct-debit",
        // "card", "transfer" or `none` (no payment means is given).
        payment-means: if means != none { means.kinds.first(default: none) },
        // The cash discounts with the note printed for each (`note`).
        discounts: if discounts.len() > 0 {
          cash-discount.with-notes(discounts, ctx.locale)
        } else { () },
      )

      (data, data)
    },
    draw: (ctx, _, view, ..) => {
      // The layout prints the payment sentence of the language (`text`, or
      // `text-due` with prepayments), so that is the sentence here. On a
      // credit note or a self-billed invoice, the sender pays the amount to
      // the recipient; otherwise it is the sentence of the payment means,
      // followed by the notes of the cash discounts.
      let ctx = ctx
      let strings = ctx.locale.strings.payment
      ctx.locale.strings.payment = if sender-pays(
        ctx.at("document-type", default: none),
      ) {
        (
          strings
            + (
              text: strings.text-credit,
              text-due: strings.text-credit,
              deadline-soon: strings.deadline-soon-credit,
            )
        )
      } else {
        goal-strings(
          strings,
          of-context(ctx),
          discount-notes: view.discounts.map(step => step.note),
        )
      }
      (ctx.theme.payment-goal)(ctx, view)
    },
    none,
  )
}
