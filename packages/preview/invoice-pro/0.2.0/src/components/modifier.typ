#import "../loom-wrapper.typ": data-motif, loom
#import "../utils/types.typ"
#import "../utils/coercion.typ"

/// Represents a modifier, such as a discount or a surcharge, to be applied to an item, a bundle, or the entire invoice.
/// Modifiers can be either relative (percentage-based) or absolute (fixed monetary amount) depending on the data type of the `amount` provided.
///
/// -> content
#let modifier(
  /// The name or label of the modifier (e.g., "Summer Sale Discount", "Shipping Fee").
  /// -> str | content
  name,
  /// Indicates whether the modifier's absolute amount should be treated as a gross value (inclusive of tax). Automatically defaults to `false`.
  // -> bool | auto
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
) = {
  types.require(name, "modifier::name", types.text-like)
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
      derive("input-gross", input-gross, default: false)

      nest("normalize", {
        ensure("money", x => calc.round(x, digits: 2))
        ensure("money-fine", x => calc.round(x, digits: 2))
      })
    }),
    measure: ctx => {
      loom.guards.assert-direct-parent(ctx, "line-items", "bundle")
      let _raw-amount = ctx.modifier-amount
      let _amount = 0
      let _amount-type = none

      if type(_raw-amount) == ratio {
        _amount = coercion.to-ratio(_raw-amount)
        _amount-type = "relative"
      } else {
        _amount = (ctx.normalize.money)(_raw-amount)
        _amount-type = "absolute"
      }

      return (
        name: name,
        description: ctx.description,

        type: _amount-type,
        amount: _amount,

        is-gross: ctx.input-gross,
      )
    },
  )
}

#let discount(
  /// The name or label of the modifier (e.g., "Summer Sale Discount", "Shipping Fee").
  /// -> str | content
  name,
  /// Indicates whether the modifier's absolute amount should be treated as a gross value (inclusive of tax). Automatically defaults to `false`.
  // -> bool | auto
  description: auto,
  /// The value of the modifier.
  /// -> ratio | int | float | decimal | str
  amount: 0,
  /// Indicates whether the modifier's absolute amount should be treated as a gross value (inclusive of tax). Automatically defaults to `false`.
  /// -> bool | auto
  input-gross: auto,
) = {
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
    description: description,
    amount: final-amount,
    input-gross: input-gross,
  )
}

#let surcharge(
  /// The name or label of the modifier (e.g., "Summer Sale Discount", "Shipping Fee").
  /// -> str | content
  name,
  /// Indicates whether the modifier's absolute amount should be treated as a gross value (inclusive of tax). Automatically defaults to `false`.
  // -> bool | auto
  description: auto,
  /// The value of the modifier.
  /// -> ratio | int | float | decimal | str
  amount: 0,
  /// Indicates whether the modifier's absolute amount should be treated as a gross value (inclusive of tax). Automatically defaults to `false`.
  /// -> bool | auto
  input-gross: auto,
) = {
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
    description: description,
    amount: final-amount,
    input-gross: input-gross,
  )
}
