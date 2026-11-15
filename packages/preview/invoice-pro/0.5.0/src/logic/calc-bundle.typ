#import "../loom-wrapper.typ": loom
#import "../utils/coercion.typ"
#import "../data/tax.typ"
#import "calc-item.typ": normalize-quantity, require-positive-base-quantity

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
  let norm-money = ctx.locale.normalize.money
  let norm-money-fine = ctx.locale.normalize.money-fine

  require-positive-base-quantity(ctx.bundle-base-quantity, "bundle")
  let quantity = normalize-quantity(ctx.bundle-quantity)
  let base-quantity = normalize-quantity(ctx.bundle-base-quantity)
  let quantity-modifier = quantity / base-quantity

  // The items of a bundle make up one unit (per base quantity) of it.
  let base-price = norm-money-fine(group.total)
  let base-total = norm-money(base-price * quantity-modifier)

  // The bundle's own modifiers were computed on one unit. Like on an item, a
  // percentage applies to the whole line (every unit of the bundle), while an
  // absolute amount applies once per line.
  let scale(modifier) = {
    if modifier.type == "relative" {
      modifier.absolute = norm-money(base-total * modifier.display)
    }
    modifier
  }
  let discounts = bracket-discounts.map(scale)
  let surcharges = bracket-surcharges.map(scale)

  let modifier-sum = (discounts + surcharges)
    .map(d => d.absolute)
    .sum(default: decimal("0"))
  let modified-total = base-total + modifier-sum

  let virtual-item-name = name
  if has-multiple-brackets {
    // "(5,5% S)": the rate as printed elsewhere, not rounded to an integer.
    let rate = (ctx.locale.format.percent)(group.tax.rate)
    let bracket-descriptor = "(" + rate + " " + group.tax.category + ")"
    virtual-item-name = (name, bracket-descriptor).join(" ")
  }

  let virtual-item-data = (
    name: virtual-item-name,
    description: description,
    date: date,

    quantity: to-dec(quantity),
    base-quantity: to-dec(base-quantity),
    unit: ctx.bundle-unit,
    unit-singular: ctx.bundle-unit-singular,

    price: base-price,
    total: modified-total,
    unmodified-total: base-total,
    tax: group.tax,

    discounts: discounts,
    surcharge: surcharges,

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
  // "A, B and C", with the conjunction of the invoice language.
  let conjunction = (
    ctx
      .at("locale", default: (:))
      .at("strings", default: (:))
      .at("line-items", default: (:))
      .at("conjunction", default: "and")
  )
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
        names.join(", ", last: " " + conjunction + " ", default: none),
      )
    })
    .to-dict()
}

// The frames a bundle consumes: its items (including the virtual items of
// nested bundles) and its modifiers.
#let _consumed-kinds = ("item", "modifier", "modifier-applicator")

// Removes the consumed frames from `frames` at any depth, the way
// `loom.query.collect` finds the items. A nested bundle is dropped together
// with its virtual items: the enclosing bundle already contains them, so they
// must not be listed (and counted) a second time.
#let strip-consumed(frames) = {
  let result = ()
  for frame in frames {
    if not loom.frame.is-frame(frame) {
      result.push(frame)
      continue
    }
    if frame.kind in _consumed-kinds { continue }

    let signal = frame.signal
    if loom.frame.is-frame(signal) or type(signal) == array {
      let inner = strip-consumed(
        if type(signal) == array { signal } else { (signal,) },
      )
      // A container of nothing but consumed frames, such as a nested bundle.
      if inner.len() == 0 { continue }
      frame.signal = if type(signal) == array { inner } else { inner.first() }
    } else if type(signal) == dictionary and "children" in signal {
      let children = signal.children
      if loom.frame.is-frame(children) { children = (children,) }
      if type(children) == array {
        frame.signal.children = strip-consumed(children)
      }
    }
    result.push(frame)
  }
  result
}

#let calculate-bundle(ctx, children, name) = {
  let layout-children = strip-consumed(children)

  // 1. Get Items
  let mod-applicator = loom.query.find-signal(children, "modifier-applicator")
  if mod-applicator == none { return layout-children }

  let bundlable-signals = mod-applicator.items
  // The VAT groups of the items, plus those the modifiers are pinned to.
  let tax-groups = mod-applicator.tax-groups
  if tax-groups.groups.len() == 0 { return layout-children }

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

  return layout-children + generated-items
}
