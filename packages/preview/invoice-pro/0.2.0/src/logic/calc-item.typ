#import "../utils/coercion.typ"


#let calculate-item-data(ctx, name) = {
  let to-dec = coercion.to-decimal
  let to-ratio = coercion.to-ratio
  let norm-money = ctx.normalize.money
  let norm-money-fine = ctx.normalize.money-fine

  // 1. Quantity & Uni Normalization
  let quantity = to-dec(ctx.quantity)
  let base-quantity = to-dec(ctx.base-quantity)
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
  )

  // 6. Return Data
  return (
    name: name,
    description: ctx.description,
    date: ctx.date,

    quantity: quantity,
    base-quantity: base-quantity,
    unit: unit,

    price: base-price,
    total: modified-total,
    unmodified-total: base-total,
    tax: final-tax,

    discounts: discounts,
    surcharge: surcharges,

    item-id: coercion.to-item-id(ctx.item-id),
    reference: ctx.reference,
  )
}
