#import "../loom-wrapper.typ": loom
#import "../utils/coercion.typ"
#import "../logic/group-by-tax.typ": group-by-tax
#import "../data/tax.typ"

#let create-virtual-tax-item(
  ctx,
  name,
  description,
  date,
  group,
  has-multiple-brackets,
  bracket-discounts,
  bracket-surcharges,
) = {
  let to-dec = coercion.to-decimal
  let to-ratio = coercion.to-ratio
  let norm-money = ctx.normalize.money
  let norm-money-fine = ctx.normalize.money-fine

  let is-net-based = ctx.tax-mode == "exclusive"

  let quantity = ctx.bundle-quantity
  let base-quantity = ctx.bundle-base-quantity
  let quantity-modifier = quantity / base-quantity

  let discount-sum = bracket-discounts
    .map(d => d.absolute)
    .sum(default: decimal("0"))
  let surcharge-sum = bracket-surcharges
    .map(d => d.absolute)
    .sum(default: decimal("0"))

  let base-price = norm-money-fine(group.total)
  let base-total = norm-money(base-price * quantity-modifier)
  let modified-total = base-total + discount-sum + surcharge-sum

  let virtual-item-name = name
  if has-multiple-brackets {
    let bracket-descriptor = (
      "("
        + str(calc.round(group.tax.rate * 100))
        + "% "
        + group.tax.category
        + ")"
    )
    virtual-item-name = (name, bracket-descriptor).join(" ")
  }

  let virtual-item-data = (
    name: virtual-item-name,
    description: description,
    date: date,

    quantity: to-dec(ctx.bundle-quantity),
    base-quantity: to-dec(ctx.bundle-base-quantity),
    unit: ctx.unit,

    price: base-price,
    total: modified-total,
    unmodified-total: base-total,
    tax: group.tax,

    discounts: bracket-discounts,
    surcharge: bracket-surcharges,

    item-id: coercion.to-item-id(ctx.item-id),
    reference: ctx.reference,
  )

  return loom.frame.new(
    kind: "item",
    key: loom.path.current(ctx),
    path: loom.path.get(ctx),
    signal: virtual-item-data,
  )
}

#let calculate-description(ctx, items) = {
  let descripion-groups = (:)

  for item in items {
    let tax-key = tax.to-tax-key(item.tax)
    if tax-key not in descripion-groups {
      descripion-groups.insert(tax-key, ())
    }
    descripion-groups.at(tax-key).push(item.name)
  }

  descripion-groups
    .pairs()
    .map(((key, names)) => {
      (
        key,
        names.join(", ", last: " and ", default: none),
      )
    })
    .to-dict()
}

#let calculate-bundle(ctx, children, name) = {
  // 1. Get Items
  let mod-applicator = loom.query.find-signal(children, "modifier-applicator")
  if mod-applicator == none { return children }

  let bundlable-signals = mod-applicator.items
  if bundlable-signals.len() == 0 { return children }

  // 2. Tax Mode & Modifier Values
  let discounts = mod-applicator.tax-split.discounts
  let surcharges = mod-applicator.tax-split.surcharges

  // 3. Derive Information Based on Children
  let bundle-date = ctx.bundle-date
  if bundle-date == auto {
    let sorted-dates = bundlable-signals
      .map(item => item.date)
      .filter(date => date != none)
      .flatten()
      .sorted()
      .dedup()

    if sorted-dates.len() == 0 { bundle-date = none } else if (
      sorted-dates.len() == 1
    ) { bundle-date = sorted-dates.first() } else {
      bundle-date = (sorted-dates.first(), sorted-dates.last())
    }
  }

  let description = ctx.bundle-description
  if description == auto {
    description = calculate-description(ctx, bundlable-signals)
  }

  // 4. Emit Item Signal for each Tax Bracket
  let tax-groups = group-by-tax(bundlable-signals)
  let has-multiple-brackets = mod-applicator.tax-rates.len() > 1

  let generated-items = tax-groups
    .groups
    .pairs()
    .map(((key, group)) => {
      let bracket-discounts = discounts.at(key, default: ())
      let bracket-surcharges = surcharges.at(key, default: ())

      let item-description = if type(description) == dictionary {
        description.at(key, default: none)
      } else {
        description
      }

      return create-virtual-tax-item(
        ctx,
        name,
        item-description,
        bundle-date,
        group,
        has-multiple-brackets,
        bracket-discounts,
        bracket-surcharges,
      )
    })

  let layout-children = children.filter(c => (
    c.at("kind", default: none)
      not in ("item", "modifier", "modifier-applicator")
  ))

  return layout-children + generated-items
}
