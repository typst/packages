#import "../utils/coercion.typ"
#import "../utils/text.typ": plain-text
#import "country.typ": normalize-code
#import "../data/tax.typ" as m-tax

/// The decimals of a quantity (BT-129, BT-149). A quantity is rounded to them
/// once, before anything is calculated with it, so the line total, the
/// printed quantity and the e-invoice all use the same value, e.g. 0.3333 for
/// a quantity of `1/3`. The built-in number formats print 4 decimals.
#let quantity-digits = 4

/// A quantity rounded to `quantity-digits` decimals.
///
/// -> decimal | auto | none
#let normalize-quantity(value) = {
  let quantity = coercion.to-decimal(value)
  if quantity == auto or quantity == none { return quantity }
  calc.round(quantity, digits: quantity-digits)
}

/// Panics unless `base-quantity` (the quantity the price refers to) is above
/// 0 once rounded: the price is divided by it (BT-149, PEPPOL-EN16931-R121).
#let require-positive-base-quantity(base-quantity, name) = {
  let value = coercion.to-decimal(base-quantity)
  if value == auto or value == none { return }
  if normalize-quantity(value) <= 0 {
    let written = str(value).replace("\u{2212}", "-")
    panic(if value > 0 {
      (
        name
          + "::base-quantity must be at least 0.0001, got "
          + written
          + ". Quantities are rounded to "
          + str(quantity-digits)
          + " decimals."
      )
    } else {
      (
        name
          + "::base-quantity must be greater than 0, got "
          + written
          + ". It is the quantity the price refers to, e.g. `base-quantity: 100` for a price per 100 pieces."
      )
    })
  }
}

/// The ISO 3166-1 alpha-2 code of the country of origin of an item
/// (`origin`): a country of the `country` module (`country.de`), a country
/// dictionary (`country.custom(..)`) or a code such as "DE". An empty text
/// states no country; anything else that is not a code is an error.
///
/// -> none | str
#let origin-code(origin) = {
  let country = if type(origin) == function { origin() } else { origin }
  let code = if type(country) == dictionary {
    country.at("code", default: none)
  } else { country }
  if code == none or code == auto { return none }
  if type(code) in (str, content) and plain-text(code) == "" { return none }
  normalize-code(code, "item::origin")
}

#let calculate-item-data(ctx, name) = {
  let to-dec = coercion.to-decimal
  let to-ratio = coercion.to-ratio
  let norm-money = ctx.locale.normalize.money
  let norm-money-fine = ctx.locale.normalize.money-fine

  // 1. Quantity & Uni Normalization
  require-positive-base-quantity(ctx.base-quantity, "item")
  let quantity = normalize-quantity(ctx.quantity)
  let base-quantity = normalize-quantity(ctx.base-quantity)
  let quantity-multiplier = quantity / base-quantity
  let unit = ctx.unit

  // 2. Tax Mode & Gross/Net Handling
  let is-net-based = ctx.tax-mode == "exclusive"
  let is-input-gross = if type(ctx.input-gross) == bool {
    ctx.input-gross
  } else { not is-net-based }
  let tax-ratio = to-ratio(ctx.tax.rate)

  let tax-modifier = decimal("1")
  if is-net-based and is-input-gross {
    tax-modifier = 1 / (1 + tax-ratio)
  } else if (not is-net-based) and (not is-input-gross) {
    tax-modifier = 1 + tax-ratio
  }

  // 3. Base Price Calculation (B2C = gross, B2B = net)
  let price = if ctx.item-price != auto { ctx.item-price * tax-modifier } else {
    auto
  }
  let total = if ctx.item-total != auto { ctx.item-total * tax-modifier } else {
    auto
  }

  if price == auto and total == auto {
    price = decimal("0")
  } else if price == auto {
    price = total / quantity-multiplier
  }

  let base-price = norm-money-fine(price)
  let base-total = norm-money(base-price * quantity-multiplier)

  // 4. Discount / Surcharge Application
  let raw-modifiers = if type(ctx.modifier) == array { ctx.modifier } else {
    ()
  }

  let normalized-modifiers = raw-modifiers.map(modifier => {
    // A modifier of an item always has the item's VAT category.
    let pinned = modifier.at("tax", default: none)
    if (
      pinned not in (none, auto)
        and m-tax.to-tax-key(pinned) != m-tax.to-tax-key(ctx.tax)
    ) {
      let text(value) = {
        let result = coercion.to-string(value)
        if type(result) == str { result } else { repr(value) }
      }
      panic(
        "The modifier `"
          + text(modifier.name)
          + "` of the item `"
          + text(name)
          + "` is pinned to the VAT category "
          + m-tax.describe(pinned)
          + ", but the item has "
          + m-tax.describe(ctx.tax)
          + ". A modifier of an item always has the VAT category of the item: remove its `tax:`.",
      )
    }
    let is-relative = type(modifier.amount) == ratio

    let mod-type = if is-relative { "relative" } else { "absolute" }
    let display-value = if is-relative { to-ratio(modifier.amount) } else {
      norm-money(to-dec(modifier.amount))
    }
    let mod-value = if is-relative {
      norm-money(display-value * base-total)
    } else { display-value }

    return (
      name: modifier.name,
      label: modifier.at("label", default: none),
      description: modifier.description,

      type: mod-type,
      display: display-value,
      absolute: mod-value,
    )
  })

  let surcharges = normalized-modifiers.filter(m => m.absolute > 0)
  let discounts = normalized-modifiers.filter(m => m.absolute < 0)

  let modifier-sum = normalized-modifiers
    .map(m => m.absolute)
    .sum(default: decimal("0"))
  let modified-total = base-total + modifier-sum

  // 5. Final Tax Calculation
  let final-tax = (
    rate: ctx.tax.rate,
    category: ctx.tax.category,
    grounds: ctx.tax.at("grounds", default: none),
    // The VAT exemption reason code (BT-121), if the tax has one.
    ..if "code" in ctx.tax { (code: ctx.tax.code) },
    // No tax was set anywhere (`tax: none`), see `tax.implicit-zero`.
    ..if m-tax.is-implicit(ctx.tax) { (implicit: true) },
  )

  // 6. Return Data
  return (
    name: name,
    description: ctx.description,
    date: ctx.date,

    quantity: quantity,
    base-quantity: base-quantity,
    unit: unit,
    unit-singular: ctx.unit-singular,

    price: base-price,
    total: modified-total,
    unmodified-total: base-total,
    tax: final-tax,

    discounts: discounts,
    surcharge: surcharges,

    item-id: coercion.to-item-id(ctx.item-id),
    reference: ctx.reference,
    note: ctx.at("note", default: none),
    origin: origin-code(ctx.at("origin", default: none)),
  )
}
