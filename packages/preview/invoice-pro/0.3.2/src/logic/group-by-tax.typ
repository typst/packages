#import "../data/tax.typ"

#let group-by-tax(items, include-items: true) = {
  let total = decimal("0")
  let groups = (:)

  for item in items {
    let tax-key = tax.to-tax-key(item.tax)
    if tax-key not in groups {
      groups.insert(tax-key, (
        total: decimal("0"),
        tax: (
          rate: item.tax.rate,
          category: item.tax.category,
        ),
        ..if include-items { (items: ()) },
      ))
    }

    total += item.total
    groups.at(tax-key).total += item.total

    if include-items {
      groups.at(tax-key).items.push(item)
    }
  }

  return (
    total: total,
    keys: groups.keys(),
    groups: groups,
  )
}
