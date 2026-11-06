// Cash discounts (Skonto) of the payment goal: a lower amount for a payment
// within fewer days, e.g. 2 % for a payment within 14 days.
//
// One structure yields both the note the invoice prints and the payment
// terms of the e-invoice (BT-20): the note as text, or in XRechnung a line
// in the Skonto syntax of the KoSIT (BR-DE-18), e.g.
// "#SKONTO#TAGE=14#PROZENT=2.00#". A cash discount changes no amount of the
// invoice: the buyer deducts it when paying in time.

#import "../utils/types.typ"
#import "../utils/coercion.typ": to-decimal, to-ratio

// The keys of a cash discount.
#let _keys = ("days", "percent", "basis")

/// Checks and normalizes the `discount` of the payment goal: `none`, a
/// dictionary `(days: .., percent: .., basis: ..)` or an array of them.
///
/// Returns an array of `(days: int, percent: decimal, basis: none |
/// decimal)`, where `percent` is in percent (e.g. `2.5` for `2.5%`), in the
/// order given.
///
/// -> array
#let normalize(discount) = {
  if discount == none { return () }
  let steps = if type(discount) == dictionary { (discount,) } else {
    discount
  }
  let out = ()
  for (i, step) in steps.enumerate() {
    let name = (
      "payment-goal::discount"
        + if type(discount) == array {
          ".at(" + str(i) + ")"
        } else { "" }
    )
    assert(
      type(step) == dictionary,
      message: "`"
        + name
        + "` must be a dictionary such as `(days: 14, percent: 2%)`, got "
        + repr(step),
    )
    for key in step.keys() {
      assert(
        key in _keys,
        message: "`"
          + name
          + "` has the unknown key `"
          + key
          + "`. A cash discount has `days`, `percent` and optionally `basis`.",
      )
    }
    let days = step.at("days", default: none)
    assert(
      type(days) == int and days > 0,
      message: "`"
        + name
        + ".days` must be the number of days within which the discount applies (an integer greater than 0), got "
        + repr(days),
    )
    let percent = step.at("percent", default: none)
    assert(
      type(percent) == ratio,
      message: "`"
        + name
        + ".percent` must be a percentage such as `2%`, got "
        + repr(percent),
    )
    let percent = to-ratio(percent) * 100
    assert(
      percent > 0 and percent < 100,
      message: "`"
        + name
        + ".percent` must be more than 0% and less than 100%, got "
        + str(percent)
        + "%",
    )
    assert(
      calc.round(percent, digits: 2) == percent,
      message: "`"
        + name
        + ".percent` can have at most 2 decimals (the e-invoice states it with 2 decimals), got "
        + str(percent)
        + "%",
    )
    let basis = step.at("basis", default: none)
    types.require(basis, name + ".basis", none, types.decimal-like)
    out.push((
      days: days,
      percent: percent,
      basis: if basis != none { to-decimal(basis) },
    ))
  }
  out
}

/// The cash discounts with the note the invoice prints for each of them
/// (`note`), from the `cash-discount` sentence of the language: the percent
/// in the number format of the locale, the deadline as a payment goal of
/// `days` prints it, and the basis as an amount (`none` if not given).
///
/// -> array
#let with-notes(discounts, locale) = {
  let payment = locale.strings.payment
  let format = locale.format
  let out = ()
  for step in discounts {
    // The basis is an amount of the invoice, rounded like every amount.
    let basis = if step.basis != none {
      (locale.normalize.money)(step.basis)
    }
    out.push(
      step
        + (
          basis: basis,
          note: (payment.cash-discount)(
            (format.number)(float(step.percent)) + "%",
            (payment.deadline-days)(step.days),
            if basis != none { (format.currency)(basis) },
          ),
        ),
    )
  }
  out
}
