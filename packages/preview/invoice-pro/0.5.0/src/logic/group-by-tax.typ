#import "../data/tax.typ"

// The tax of a VAT group: rate, category and every distinct exemption ground
// of its items. `grounds` joins them into the one exemption reason of the
// category (BT-120). With several grounds, `grounds-list` keeps each of them
// for the printed notes. The exemption reason codes of the items (BT-121)
// are `code`, or `codes` if they differ. `implicit` marks a group with an
// item whose tax was never set (`tax: none`), see `tax.implicit-zero`.
#let group-tax(first-tax, grounds-list, implicit, codes: ()) = (
  rate: first-tax.rate,
  category: first-tax.category,
  grounds: tax.join-grounds(grounds-list),
  ..if grounds-list.len() > 1 { (grounds-list: grounds-list) },
  ..if codes.len() == 1 { (code: codes.first()) },
  ..if codes.len() > 1 { (codes: codes) },
  ..if implicit { (implicit: true) },
)

/// Makes sure `tax-groups` has a group for the VAT category of `pinned-tax`
/// (the `tax` a modifier is pinned to) and adds its exemption grounds. A
/// group without items has a total of 0.
///
/// -> dictionary
#let with-tax-group(tax-groups, pinned-tax) = {
  let key = tax.to-tax-key(pinned-tax)
  let group = tax-groups.groups.at(key, default: (
    total: decimal("0"),
    tax: pinned-tax,
    grounds-list: (),
    missing-grounds: 0,
    items: (),
  ))
  let grounds-list = tax.merge-grounds(
    group.grounds-list,
    tax.grounds-of(pinned-tax),
  )
  group.grounds-list = grounds-list
  group.tax = group-tax(
    group.tax,
    grounds-list,
    tax.is-implicit(group.tax) or tax.is-implicit(pinned-tax),
    codes: tax.merge-codes(tax.codes-of(group.tax), tax.codes-of(pinned-tax)),
  )
  tax-groups.groups.insert(key, group)
  tax-groups.keys = tax-groups.groups.keys()
  tax-groups
}

/// Groups items by VAT group (rate and category) and sums their totals.
///
/// Every group keeps the distinct exemption grounds of all its items, not
/// only those of the first one, and counts the items that have none
/// (`missing-grounds`).
///
/// -> dictionary
#let group-by-tax(items, include-items: true) = {
  let total = decimal("0")
  let groups = (:)

  for item in items {
    let tax-key = tax.to-tax-key(item.tax)
    let item-grounds = tax.grounds-of(item.tax)
    if tax-key not in groups {
      groups.insert(tax-key, (
        total: decimal("0"),
        first-tax: item.tax,
        grounds-list: (),
        missing-grounds: 0,
        codes: (),
        implicit: false,
        ..if include-items { (items: ()) },
      ))
    }

    // Update the group in place: a copy of it would copy its items as well,
    // which makes grouping quadratic in the number of items.
    total += item.total
    groups.at(tax-key).total += item.total
    if item-grounds.len() == 0 {
      groups.at(tax-key).missing-grounds += 1
    } else {
      groups.at(tax-key).grounds-list = tax.merge-grounds(
        groups.at(tax-key).grounds-list,
        item-grounds,
      )
    }
    if tax.is-implicit(item.tax) { groups.at(tax-key).implicit = true }
    // Most taxes have no exemption reason code: only those are merged.
    if "code" in item.tax or "codes" in item.tax {
      groups.at(tax-key).codes = tax.merge-codes(
        groups.at(tax-key).codes,
        tax.codes-of(item.tax),
      )
    }
    if include-items { groups.at(tax-key).items.push(item) }
  }

  for (key, group) in groups {
    let first-tax = group.remove("first-tax")
    let implicit = group.remove("implicit")
    let codes = group.remove("codes")
    group.insert("tax", group-tax(
      first-tax,
      group.grounds-list,
      implicit,
      codes: codes,
    ))
    groups.insert(key, group)
  }

  return (
    total: total,
    keys: groups.keys(),
    groups: groups,
  )
}
