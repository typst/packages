#import "../loom-wrapper.typ": compute-motif, loom
#import "../utils/coercion.typ"
#import "group-by-tax.typ": group-by-tax

#let apply-mod(ctx, tax-groups, modifier) = {
  let normalize = ctx.locale.normalize
  let modifier-total = decimal("0")
  let tax-split = (:)

  let is-net-based = ctx.tax-mode == "exclusive"
  let mod-is-gross = modifier.is-gross
  let needs-adjustment = (
    (is-net-based and mod-is-gross) or (not is-net-based and not mod-is-gross)
  )

  let effective-amount = modifier.amount

  if modifier.type == "absolute" and needs-adjustment {
    let scope-net-total = decimal("0")
    let scope-gross-total = decimal("0")

    if is-net-based {
      for (key, group) in tax-groups.groups {
        scope-net-total += group.total
        scope-gross-total += group.total * (1 + group.tax.rate)
      }
    } else {
      for (key, group) in tax-groups.groups {
        scope-net-total += group.total / (1 + group.tax.rate)
        scope-gross-total += group.total
      }
    }

    if is-net-based and mod-is-gross {
      if scope-gross-total > decimal("0") {
        let conversion-ratio = scope-net-total / scope-gross-total
        effective-amount = (normalize.money)(
          modifier.amount * conversion-ratio,
        )
      } else {
        effective-amount = decimal("0")
      }
    } else if not is-net-based and not mod-is-gross {
      if scope-net-total > decimal("0") {
        let conversion-ratio = scope-gross-total / scope-net-total
        effective-amount = (normalize.money)(
          modifier.amount * conversion-ratio,
        )
      } else {
        effective-amount = decimal("0")
      }
    }
  }

  if modifier.type == "relative" {
    for (key, group) in tax-groups.groups {
      let group-modifier = (normalize.money)(group.total * effective-amount)
      modifier-total += group-modifier
      tax-split.insert(key, (
        tax: (
          rate: group.tax.rate,
          category: group.tax.category,
          absolute: group.tax.rate * group-modifier,
        ),
        absolute: group-modifier,
      ))
    }
  } else {
    let left-over-total = effective-amount
    let base-total = tax-groups.total
    if base-total <= 0 { return none }

    let largest-group = none
    let largest-group-total = decimal("0")

    for (key, group) in tax-groups.groups {
      let group-total = group.total
      let group-proporiton = group-total / base-total
      let group-modifier = (normalize.money)(
        effective-amount * group-proporiton,
      )

      tax-split.insert(key, (
        tax: (
          rate: group.tax.rate,
          category: group.tax.category,
        ),
        absolute: group-modifier,
      ))

      if calc.abs(group-total) > calc.abs(largest-group-total) {
        largest-group = key
        largest-group-total = group-total
      }

      modifier-total += group-modifier
      left-over-total -= group-modifier
    }

    if calc.abs(left-over-total) > decimal("0") and largest-group != none {
      tax-split.at(largest-group).absolute += left-over-total
      modifier-total += left-over-total
    }
  }

  return (
    name: modifier.name,
    description: modifier.description,

    type: modifier.type,
    display: effective-amount,
    absolute: modifier-total,

    split: tax-split,
  )
}

#let modifiers-by-tax(modifiers, tax-rates) = {
  let tax-keys = tax-rates.keys()

  return tax-keys
    .map(key => {
      (
        key,
        modifiers.map(mod => {
          (
            name: mod.name,
            description: mod.description,

            type: mod.type,
            display: if mod.type == "relative" { mod.display } else {
              mod.split.at(key).absolute
            },
            absolute: mod.split.at(key).absolute,
          )
        }),
      )
    })
    .to-dict()
}

#let calculate-modifier(ctx, children) = {
  let to-dec = coercion.to-decimal
  let to-ratio = coercion.to-ratio
  let normalize = ctx.locale.normalize
  let norm-money = normalize.money
  let norm-money-fine = normalize.money-fine

  let items = loom.query.collect-signals(children, kind: "item", depth: 2)
  let modifiers = loom.query.collect-signals(children, kind: "modifier")

  let tax-groups = group-by-tax(items)
  let tax-rates = tax-groups
    .groups
    .pairs()
    .map(((key, group)) => (
      key,
      (rate: group.tax.rate, category: group.tax.category),
    ))
    .to-dict()
  let applied-modifiers = modifiers.map(apply-mod.with(ctx, tax-groups))

  let discounts = ()
  let surcharges = ()
  for mod in modifiers {
    let applied-mod = apply-mod(ctx, tax-groups, mod)
    if applied-mod == none { continue }
    if applied-mod.absolute < 0 { discounts.push(applied-mod) }
    if applied-mod.absolute > 0 { surcharges.push(applied-mod) }
  }

  return (
    tax-rates: tax-rates,
    modifier: (
      discounts: discounts,
      surcharges: surcharges,
    ),
    tax-split: (
      discounts: modifiers-by-tax(discounts, tax-rates),
      surcharges: modifiers-by-tax(surcharges, tax-rates),
    ),

    items: items,
    tax-groups: tax-groups,
  )
}

#let modifier-applicator(
  body,
) = {
  compute-motif(
    scope: ctx => loom.mutator.batch(ctx, {
      import loom.mutator: *

      nest("locale", {
        nest("normalize", {
          ensure("money", (..) => panic(
            "locale::normalize::money is not provided",
          ))
          ensure("money-fine", (..) => panic(
            "locale::normalize::money-fine is not provided",
          ))
        })
      })
    }),
    measure: (ctx, children) => {
      let data = calculate-modifier(ctx, children)

      let filtered-children = children.filter(c => (
        c.at("kind", default: none) != "modifier"
      ))

      return (
        (
          loom.frame.new(
            kind: "modifier-applicator",
            key: loom.path.current(ctx),
            path: loom.path.get(ctx),
            signal: data,
          ),
        )
          + filtered-children
      )
    },
    body,
  )
}
