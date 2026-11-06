#import "../loom-wrapper.typ": data-motif, loom
#import "../utils/types.typ"
#import "../utils/coercion.typ"

/// Represents a modifier, such as a discount or a surcharge, to be applied to an item, a bundle, or the entire invoice.
/// Modifiers can be either relative (percentage-based) or absolute (fixed monetary amount) depending on the data type of the `amount` provided.
///
/// -> content
#let modifier(
  /// The name or title of the modifier (e.g., "Summer Sale Discount", "Shipping Fee").
  /// -> str | content
  name,
  /// The label prefix of the modifier (e.g. "Rabatt", "Zuschlag", "Nachlass").
  /// If `auto`, it resolves to the default discount/surcharge label from the locale.
  /// If `none`, no label prefix is displayed.
  /// -> none | auto | str | content
  label: auto,
  /// Additional description about the modifier.
  /// -> str | content | auto | none
  description: auto,
  /// The value of the modifier.
  ///   - If a `ratio` is provided (e.g., `-10%`), it acts as a relative modifier applied to the base total.
  ///   - If a numeric/decimal value is provided (e.g., `-15.50`), it acts as an absolute monetary modifier.
  ///   - Negative values represent discounts, while positive values represent surcharges.
  /// -> ratio | int | float | decimal | str | auto
  amount: auto,
  /// Indicates whether the modifier's absolute amount should be treated as a gross value (inclusive of tax). Automatically defaults to `false`.
  /// -> bool | auto
  input-gross: auto,
  /// Internal flag indicating whether this modifier is semantically a discount or surcharge.
  /// -> bool | auto
  is-discount: auto,
) = {
  types.require(name, "modifier::name", types.text-like)
  types.require(label, "modifier::label", none, auto, types.text-like)
  types.require(
    description,
    "modifier::description",
    none,
    auto,
    description,
    types.text-like,
  )
  types.require(
    amount,
    "modifier::amount",
    auto,
    types.decimal-like,
    types.ratio-like,
  )
  types.require(input-gross, "modifier::input-gross", auto, bool)

  data-motif(
    "modifier",
    scope: ctx => loom.mutator.batch(ctx, {
      import loom.mutator: *

      derive("modifier-amount", amount, default: decimal("0"))
      derive("description", description)
      derive(
        "input-gross",
        input-gross,
        default: ctx.at("tax-mode", default: "exclusive") == "inclusive",
      )
      derive("label", label, default: auto)

      nest("locale", {
        nest("normalize", {
          ensure("money", (..) => panic(
            "locale::normalize::money is not provided",
          ))
        })
      })
    }),
    measure: ctx => {
      loom.guards.assert-direct-parent(ctx, "line-items", "bundle")
      let normalize = ctx.locale.normalize

      let raw-amount = ctx.modifier-amount

      let amount = 0
      let amount-type = none

      if type(raw-amount) == ratio {
        amount = coercion.to-ratio(raw-amount)
        amount-type = "relative"
      } else {
        amount = (normalize.money)(raw-amount)
        amount-type = "absolute"
      }

      let discount-mode = if is-discount != auto {
        is-discount
      } else {
        amount < 0
      }

      let current-label = ctx.at("label", default: auto)
      let resolved-label = if current-label == auto {
        let strings = ctx
          .locale
          .at("strings", default: (:))
          .at(
            "line-items",
            default: (:),
          )
        if discount-mode {
          strings.at("discount", default: "Discount")
        } else {
          strings.at("surcharge", default: "Surcharge")
        }
      } else if current-label == none {
        none
      } else {
        current-label
      }

      return (
        name: name,
        label: resolved-label,
        description: ctx.description,

        type: amount-type,
        amount: amount,

        is-gross: ctx.input-gross,
      )
    },
  )
}

#let discount(
  /// The name or title of the discount (e.g., "Summer Sale Discount", "Skonto").
  /// -> str | content
  name,
  /// The label prefix of the discount (e.g. "Rabatt", "Nachlass").
  /// If `auto`, it resolves to the default discount label from the locale.
  /// If `none`, no label prefix is displayed.
  /// -> none | auto | str | content
  label: auto,
  /// Additional description about the discount.
  /// -> str | content | auto | none
  description: auto,
  /// The value of the discount. Must be positive.
  /// -> ratio | int | float | decimal | str
  amount: 0,
  /// Indicates whether the modifier's absolute amount should be treated as a gross value (inclusive of tax). Automatically defaults to `false`.
  /// -> bool | auto
  input-gross: auto,
) = {
  types.require(label, "discount::label", none, auto, types.text-like)
  types.require(
    amount,
    "discount::amount",
    types.decimal-like,
    types.ratio-like,
  )

  let final-amount = 0
  if type(amount) == ratio {
    assert(amount >= 0%, message: "discount::amount must be positive!")
    final-amount = -amount
  } else {
    let normalized-amount = coercion.to-decimal(amount)
    assert(
      normalized-amount >= 0,
      message: "discount::amount must be positive!",
    )
    final-amount = -normalized-amount
  }

  modifier(
    name,
    label: label,
    description: description,
    amount: final-amount,
    input-gross: input-gross,
    is-discount: true,
  )
}

#let surcharge(
  /// The name or title of the surcharge (e.g., "Shipping Fee", "Express Surcharge").
  /// -> str | content
  name,
  /// The label prefix of the surcharge (e.g. "Zuschlag", "Gebühr").
  /// If `auto`, it resolves to the default surcharge label from the locale.
  /// If `none`, no label prefix is displayed.
  /// -> none | auto | str | content
  label: auto,
  /// Additional description about the surcharge.
  /// -> str | content | auto | none
  description: auto,
  /// The value of the surcharge. Must be positive.
  /// -> ratio | int | float | decimal | str
  amount: 0,
  /// Indicates whether the modifier's absolute amount should be treated as a gross value (inclusive of tax). Automatically defaults to `false`.
  /// -> bool | auto
  input-gross: auto,
) = {
  types.require(label, "surcharge::label", none, auto, types.text-like)
  types.require(
    amount,
    "surcharge::amount",
    types.decimal-like,
    types.ratio-like,
  )

  let final-amount = 0
  if type(amount) == ratio {
    assert(amount >= 0%, message: "surcharge::amount must be positive!")
    final-amount = amount
  } else {
    let normalized-amount = coercion.to-decimal(amount)
    assert(
      normalized-amount >= 0,
      message: "discount::amount must be positive!",
    )
    final-amount = normalized-amount
  }

  modifier(
    name,
    label: label,
    description: description,
    amount: final-amount,
    input-gross: input-gross,
    is-discount: false,
  )
}
