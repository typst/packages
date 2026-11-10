// The net amounts of an invoice with gross prices (`tax-mode: "inclusive"`).
//
// The printed invoice states gross amounts: gross unit prices, gross line
// totals, gross allowances and charges, and per VAT group its gross total
// split into the taxable amount and the VAT amount (see `calculate-taxes`).
// EN 16931 states net amounts only, so the e-invoice needs the net amount of
// every line, allowance and charge. They are derived here, once, from the
// printed amounts, and nowhere else (the data model of the e-invoice reads
// them):
//
// - A net amount is its gross amount divided by 1 + the VAT rate, rounded to
//   the unit of the currency (a cent). Within a VAT group, the net amounts
//   of the lines and of the document level allowances and charges must add
//   up exactly to the printed taxable amount (BR-S-08 and the like), so the
//   units the separately rounded amounts lack or exceed are distributed by
//   the largest remainder method: the amounts whose rounding moved them
//   furthest the other way take one unit each. A line may turn to 0 that
//   way (e.g. a line of 0.01 including 19 % VAT, 0.0084 net), an allowance
//   or charge may not, as the XML would leave it out. Every net amount then
//   differs from its exact value by less than one unit, plus the rounding of
//   the printed taxable amount where the invoice rounds money more coarsely
//   than to the unit (e.g. with a custom `money` rounding to 0.05).
// - The net price of a gross price (BT-146) is the gross price divided by
//   1 + the VAT rate, with 6 decimals, or as many more as a large quantity
//   needs: the invoiced quantity times the net price then differs from the
//   line's net amount (with its allowances and charges) by less than 0.02
//   (PEPPOL-EN16931-R120), the rounding of the price contributing at most
//   0.0005 of it.
// - The net amounts of the allowances and charges of a line (BT-136, BT-141)
//   are rounded to the unit each, to the side that keeps the line's net
//   amount closest to its quantity times its net price plus its charges
//   minus its allowances (again PEPPOL-EN16931-R120).
//
// Performance: this runs only for e-invoices with gross prices, once per
// invoice; the lines are visited in `for` loops without a call per line.

#import "../data/tax.typ": to-tax-key
#import "../utils/coercion.typ": to-ratio

#let _zero = decimal("0")
#let _one = decimal("1")

// The number of digits of the integer part of a non-negative decimal, e.g. 1
// for 0.5 and 4 for 1000.
#let _integer-digits(value) = str(calc.floor(value)).len()

/// The decimals of the net price of a gross price (BT-146) for a line of
/// `quantity` units of a price per `base-quantity` units: at least `fine`
/// (the decimals the invoice prints unit prices with) and 6, and 3 more than
/// the integer digits of `quantity / base-quantity`, so that the rounding of
/// the price changes the line's amount by at most 0.0005.
///
/// -> int
#let price-digits(quantity, base-quantity, fine: 4) = calc.max(
  6,
  fine,
  3 + _integer-digits(calc.abs(quantity / base-quantity)),
)

/// Rounds the exact amounts `exact` (decimals) to `digits` decimals so that
/// they add up to `total`, by the largest remainder method: each is rounded
/// to the nearest unit (`10^-digits`), and the units the rounded amounts
/// lack or exceed go to the amounts whose rounding moved them furthest the
/// other way, one each (in turn, if there are more units than amounts). No
/// amount changes its sign, no amount of 0 gets a unit, and the amounts
/// `nonzero` marks (`auto`: all) do not turn to 0 either, e.g. an allowance
/// or charge, which the XML would leave out. The amounts keep their order.
///
/// -> array
#let allocate(exact, total, digits: 2, nonzero: auto) = {
  let rounded = ()
  let sum = _zero
  for value in exact {
    let r = calc.round(value, digits: digits)
    rounded.push(r)
    sum += r
  }
  let difference = total - sum
  if difference == _zero or exact == () { return rounded }
  let unit = calc.pow(decimal("10"), -digits)
  let step = if difference > _zero { unit } else { -unit }
  // The amounts that were rounded furthest against the direction of the
  // difference first (`sorted` keeps the order of equal ones), but none
  // that one unit more would turn to the other sign, or to 0 where it must
  // not. An amount that may turn to 0 (a line) takes its unit like any other,
  // so that the units do not pile up on the few other amounts, e.g. next to
  // many lines of 0.01.
  let order = ()
  for i in range(exact.len()).sorted(key: i => (
    (rounded.at(i) - exact.at(i)) * step
  )) {
    let moved = (rounded.at(i) + step) * exact.at(i)
    if (
      moved > _zero
        or (
          moved == _zero
            and exact.at(i) != _zero
            and nonzero != auto
            and not nonzero.at(i)
        )
    ) { order.push(i) }
  }
  if order == () { order = range(exact.len()) }
  let count = calc.floor(calc.abs(difference) / unit)
  for k in range(count) {
    let i = order.at(calc.rem(k, order.len()))
    rounded.at(i) += step
  }
  // A total with more decimals than the unit (e.g. from a custom rounding):
  // the rest goes to the first amount, so that the sum still holds.
  let rest = difference - step * count
  if rest != _zero { rounded.at(order.first()) += rest }
  rounded
}

// The net amounts of the allowances and charges of a line: `amounts` are
// their gross amounts as the line prints them (allowances negative),
// `divisor` is 1 + the VAT rate and `target` the sum of their signed net
// amounts that keeps the line consistent (its net amount minus its quantity
// times its net price). Each is rounded to the unit; while the rounded sum
// misses the target by more than half a unit, amounts are rounded the other
// way, each at most once, if that brings the sum closer (never to 0).
// Returns the net amounts, positive, in the order of `amounts`.
#let _modifier-nets(amounts, divisor, target, digits) = {
  let unit = calc.pow(decimal("10"), -digits)
  let exact = ()
  let nets = ()
  let sum = _zero
  for amount in amounts {
    let value = amount / divisor
    let net = calc.round(value, digits: digits)
    exact.push(value)
    nets.push(net)
    sum += net
  }
  let i = 0
  for value in exact {
    let miss = target - sum
    if calc.abs(miss) * 2 <= unit { break }
    let net = nets.at(i)
    // The other rounding of this amount, one unit toward its exact value.
    let other = if value > net { net + unit } else if value < net {
      net - unit
    } else { net }
    if other != net and other != _zero and (other - net) * miss > _zero {
      nets.at(i) = other
      sum += other - net
    }
    i += 1
  }
  let out = ()
  for net in nets { out.push(calc.abs(net)) }
  out
}

/// The net amounts the e-invoice states for an invoice with gross prices
/// (see the top of this file).
///
/// - `items`: the computed items (`item-data.items`) with their gross unit
///   price (`price`), gross total (`total`, with the item's own allowances
///   and charges), their allowances and charges (`discounts`, `surcharge`)
///   and `tax`.
/// - `taxes`: the VAT groups by key (`item-data.taxes`), with the printed
///   taxable amount (`basis`) of each.
/// - `modifiers`: the document level allowances and charges
///   (`item-data.discounts` and `item-data.surcharges`, in this order), each
///   with its gross amount per VAT group (`split`).
/// - `digits`: the decimals of the currency; `fine`: those of the printed
///   unit prices.
///
/// Returns `(lines: .., modifiers: ..)`: for every item, in order,
/// `(net: .., price: .., adjustments: (..))`, the net amount of the line
/// (BT-131), its net price (BT-146, positive) and the net amounts of its
/// allowances and charges (BT-136, BT-141; positive), in the order of its
/// `discounts` and then its `surcharge`; for every modifier, in order, the
/// net amount of each of its parts by the key of its VAT group, signed like
/// the part.
///
/// -> dictionary
#let net-amounts(items, taxes, modifiers, digits: 2, fine: 4) = {
  // The exact net amounts of the lines and modifier parts of every VAT
  // group, and where each one goes (`slots`).
  let exact = (:)
  let slots = (:)
  let lines = ()
  let i = 0
  for item in items {
    let tax = item.tax
    let rate = tax.rate
    if type(rate) != decimal { rate = to-ratio(rate) }
    let divisor = _one + rate
    let key = to-tax-key(tax)
    if key not in exact {
      exact.insert(key, ())
      slots.insert(key, ())
    }
    exact.at(key).push(item.total / divisor)
    slots.at(key).push((i, none))
    let quantity = item.quantity
    let base-quantity = item.at("base-quantity", default: _one)
    let price = calc.round(
      calc.abs(item.price) / divisor,
      digits: price-digits(quantity, base-quantity, fine: fine),
    )
    // The line's amount at the net price, which its allowances and charges
    // complete to its net amount; negative for a credited line (a negative
    // gross price, written as a negative quantity, BR-27).
    let base = quantity * price / base-quantity
    if item.price < _zero { base = -base }
    lines.push((
      net: none,
      price: price,
      base: base,
      divisor: divisor,
      modifiers: item.at("discounts", default: ())
        + item.at("surcharge", default: ()),
    ))
    i += 1
  }
  let parts = ()
  for (m, modifier) in modifiers.enumerate() {
    let nets = (:)
    for (key, part) in modifier.at("split", default: (:)) {
      let amount = part.at("absolute", default: _zero)
      let rate = part.at("tax", default: (:)).at("rate", default: _zero)
      if type(rate) != decimal { rate = to-ratio(rate) }
      if key not in exact {
        exact.insert(key, ())
        slots.insert(key, ())
      }
      exact.at(key).push(amount / (_one + rate))
      slots.at(key).push((m, key))
      nets.insert(key, none)
    }
    parts.push(nets)
  }

  // The net amounts of each VAT group add up to its printed taxable amount.
  // A line may turn to 0 (the XML states it all the same), a part of an
  // allowance or charge may not.
  for (key, values) in exact {
    let basis = taxes.at(key, default: (:)).at("basis", default: none)
    let rounded = if basis == none {
      let out = ()
      for value in values { out.push(calc.round(value, digits: digits)) }
      out
    } else {
      let nonzero = ()
      for (_, part) in slots.at(key) { nonzero.push(part != none) }
      allocate(values, basis, digits: digits, nonzero: nonzero)
    }
    for ((index, part), net) in slots.at(key).zip(rounded) {
      if part == none { lines.at(index).net = net } else {
        parts.at(index).insert(part, net)
      }
    }
  }

  let out = ()
  for line in lines {
    let adjustments = ()
    if line.modifiers != () {
      let amounts = ()
      for modifier in line.modifiers { amounts.push(modifier.absolute) }
      adjustments = _modifier-nets(
        amounts,
        line.divisor,
        line.net - line.base,
        digits,
      )
    }
    out.push((net: line.net, price: line.price, adjustments: adjustments))
  }
  (lines: out, modifiers: parts)
}
