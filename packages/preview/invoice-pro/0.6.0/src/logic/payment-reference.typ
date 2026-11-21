// Resolution of the payment reference (remittance information,
// Verwendungszweck).
//
// The same order applies everywhere the payment reference appears: the printed
// bank details, the EPC-QR payload, the reference signs, `info` and the
// ZUGFeRD XML (BT-83).
//
//   1. the `reference` or `text` argument of `bank-details`
//   2. the `payment-reference` argument of `invoice`
//   3. the `invoice-nr`

/// Resolves the remittance information of a bank transfer.
///
/// Returns `(reference: .., text: ..)` with at most one value set. `reference`
/// is a structured reference (EPC-QR line 10, max. 35 characters), `text` is
/// unstructured remittance text (EPC-QR line 11, max. 140 characters). The
/// invoice-level `payment-reference` is free text and therefore resolves to
/// `text`; the `invoice-nr` fallback resolves to `reference`.
///
/// -> dictionary
#let resolve-remittance(
  ctx,
  /// The `reference` argument of `bank-details`. `auto` falls back to the
  /// invoice; `none` explicitly omits the reference.
  /// -> auto | none | str | content
  reference: auto,
  /// The `text` argument of `bank-details`.
  /// -> none | str | content
  text: none,
) = {
  if text != none { return (reference: none, text: text) }
  if reference != auto { return (reference: reference, text: none) }

  let payment-reference = ctx.at("payment-reference", default: none)
  if payment-reference != none {
    return (reference: none, text: payment-reference)
  }
  (reference: ctx.at("invoice-nr", default: none), text: none)
}

/// Resolves the payment reference of the invoice as a single value.
///
/// `bank` is the public signal of `bank-details`, which already carries the
/// resolved remittance information. Without bank details, the invoice-level
/// fallbacks apply.
///
/// -> none | str | content
#let resolve-payment-reference(ctx, bank: none) = {
  let remittance = if bank != none { bank } else { resolve-remittance(ctx) }
  let text = remittance.at("text", default: none)
  if text != none { text } else { remittance.at("reference", default: none) }
}

/// Finds the public `bank-details` signal in a context, if any.
///
/// The root draw context carries it as `bank`, every other context receives it
/// through `global` from the second layout pass on.
///
/// -> none | dictionary
#let bank-signal(ctx) = ctx.at(
  "bank",
  default: ctx.at("global", default: (:)).at("bank", default: none),
)
