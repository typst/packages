#import "../loom-wrapper.typ": data-motif, loom
#import "../utils/types.typ"
#import "../utils/coercion.typ"

/// Represents an advance payment or deposit that reduces the final payable amount
/// (BT-113 / BT-115) without altering the taxable base or VAT calculation.
///
/// -> content
#let prepayment(
  /// The amount of the prepayment. Can be an absolute monetary amount (e.g., 300, 300.50, "300") or a percentage ratio (e.g., 30%).
  /// -> int | float | decimal | str | ratio
  amount,

  /// The name or title of the prepayment (e.g., "1. Abschlagszahlung", "Anzahlung").
  /// -> str | content | auto | none
  name: auto,

  /// Custom label prefix for the prepayment (e.g., "Anzahlung", "Bereits bezahlt").
  /// If `auto`, it resolves to the default prepayment label from the locale.
  /// If `none`, no label prefix is displayed.
  /// -> str | content | auto | none
  label: auto,

  /// The date when the prepayment was made or agreed upon.
  /// -> datetime | str | content | auto | none
  date: auto,

  /// Transaction ID, bank transfer reference, or preceding advance invoice number.
  /// -> str | content | auto | none
  reference: auto,

  /// Additional notes or description for the prepayment.
  /// -> str | content | auto | none
  description: auto,

  /// Payment method used (e.g., "Überweisung", "Kreditkarte", "Bar", "PayPal").
  /// -> str | content | auto | none
  method: auto,
) = {
  types.require(
    amount,
    "prepayment::amount",
    types.decimal-like,
    types.ratio-like,
  )
  types.require(name, "prepayment::name", none, auto, types.text-like)
  types.require(label, "prepayment::label", none, auto, types.text-like)
  types.require(
    date,
    "prepayment::date",
    none,
    auto,
    types.date-like,
    types.text-like,
  )
  types.require(reference, "prepayment::reference", none, auto, types.text-like)
  types.require(
    description,
    "prepayment::description",
    none,
    auto,
    types.text-like,
  )
  types.require(method, "prepayment::method", none, auto, types.text-like)

  let is-relative = type(amount) == ratio
  let final-amount = if is-relative {
    calc.abs(amount)
  } else {
    calc.abs(coercion.to-decimal(amount))
  }

  data-motif(
    "prepayment",
    scope: ctx => loom.mutator.batch(ctx, {
      import loom.mutator: *

      derive("prepayment-amount", final-amount)
      derive("name", name)
      derive("label", label, default: auto)
      derive("date", date)
      derive("reference", reference)
      derive("description", description)
      derive("method", method)

      nest("locale", {
        nest("normalize", {
          ensure("money", (..) => panic(
            "locale::normalize::money is not provided",
          ))
        })
        nest("format", {
          ensure("date", (..) => panic("locale::format::date is not provided"))
        })
      })
    }),
    measure: ctx => {
      loom.guards.assert-direct-parent(ctx, "line-items")
      let normalize = ctx.locale.normalize

      let raw-amount = ctx.prepayment-amount
      let amount-type = if is-relative { "relative" } else { "absolute" }
      let normalized-amount = if is-relative {
        coercion.to-ratio(raw-amount)
      } else {
        (normalize.money)(raw-amount)
      }

      let current-label = ctx.at("label", default: auto)
      let resolved-label = if current-label == auto {
        let strings = ctx.locale.at("strings", default: (:))
        let summary-strings = strings.at("summary", default: (:))
        summary-strings.at("prepayment", default: "Prepayment")
      } else if current-label == none {
        none
      } else {
        current-label
      }

      let resolved-name = if ctx.name == auto { none } else { ctx.name }
      let resolved-description = if ctx.description == auto { none } else {
        ctx.description
      }
      let resolved-reference = if ctx.reference == auto { none } else {
        ctx.reference
      }
      let resolved-method = if ctx.method == auto { none } else { ctx.method }

      let resolved-date = if ctx.date == auto or ctx.date == none {
        none
      } else if type(ctx.date) == datetime {
        (ctx.locale.format.date)(ctx.date)
      } else {
        ctx.date
      }

      return (
        name: resolved-name,
        label: resolved-label,
        date: resolved-date,
        reference: resolved-reference,
        description: resolved-description,
        method: resolved-method,
        type: amount-type,
        raw-amount: raw-amount,
        amount: normalized-amount,
      )
    },
  )
}
