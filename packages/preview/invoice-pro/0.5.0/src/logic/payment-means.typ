// The payment means of an invoice (BG-16 of EN 16931): how the buyer pays
// the amount due, or how it was paid.
//
// Four components state them:
//
// - `bank-details`: a credit transfer to the account of the seller (BG-17),
// - `direct-debit`: a SEPA direct debit from the account of the buyer (BG-19),
// - `card-payment`: a payment card (BG-18),
// - `paid`: the invoice is paid already, and how.
//
// `resolve` combines their signals into the description the root context
// publishes (`global.payment-means`). It is the one source for the sentence
// the payment goal prints, for whether the bank details show an EPC-QR code
// and for the payment means the e-invoice states (BT-81 and its groups).

/// The methods of `paid`, with the kind of payment means each one is: a
/// credit transfer, a direct debit, a payment card, or another means without
/// details of its own.
#let method-kinds = (
  cash: "other",
  cheque: "other",
  online: "other",
  transfer: "transfer",
  card: "card",
  direct-debit: "direct-debit",
)

// The kinds of the payment means codes (UNTDID 4461) that have details in
// EN 16931: credit transfers (BG-17), payment cards (BG-18) and direct
// debits (BG-19).
#let _code-kinds = (
  "30": "transfer",
  "58": "transfer",
  "48": "card",
  "54": "card",
  "55": "card",
  "49": "direct-debit",
  "59": "direct-debit",
)

/// The kind of payment means of a code (BT-81): `"transfer"`,
/// `"direct-debit"`, `"card"` or `"other"`.
///
/// -> str
#let code-kind(code) = _code-kinds.at(code, default: "other")

/// The kind of payment means of a method of `paid`, or `none` for `auto`,
/// which states no kind of its own.
///
/// -> none | str
#let method-kind(method) = {
  if method == auto { return none }
  if type(method) == dictionary { return code-kind(method.code) }
  method-kinds.at(method)
}

/// The payment means code (BT-81) of a credit transfer: SEPA credit transfer
/// (58) in euro, credit transfer (30) in any other currency.
///
/// -> str
#let transfer-code(currency) = if currency == "EUR" { "58" } else { "30" }

/// The payment means code (BT-81) of a direct debit: SEPA direct debit (59)
/// in euro, direct debit (49) in any other currency.
///
/// -> str
#let direct-debit-code(currency) = if currency == "EUR" { "59" } else {
  "49"
}

/// The payment means code (BT-81) of a payment card: credit card (54), debit
/// card (55), or bank card (48) if the kind of card is not stated (`auto`).
///
/// -> str
#let card-code(kind) = if kind == "credit" { "54" } else if kind == "debit" {
  "55"
} else { "48" }

// The codes of the methods of `paid` that do not depend on the currency.
#let _method-codes = (cash: "10", cheque: "20", card: "48", online: "68")

/// The payment means code (BT-81) of a method of `paid` (see `method-kinds`,
/// or `(code: .., name: ..)`) in an invoice currency.
///
/// -> str
#let method-code(method, currency) = {
  if type(method) == dictionary { return method.code }
  if method == "transfer" { return transfer-code(currency) }
  if method == "direct-debit" { return direct-debit-code(currency) }
  _method-codes.at(method)
}

/// Whether problems of an e-invoice are shown in the document
/// (`zugferd-errors: "report"`) rather than stopping the compilation. The
/// components then show them where they print the value, and the e-invoice
/// report lists them.
///
/// -> bool
#let report-problems(ctx) = (
  ctx.at("zugferd", default: none) != none
    and ctx.at("zugferd-errors", default: "panic") == "report"
)

/// Combines the signals of the payment means components of an invoice.
///
/// Returns `(transfers, direct-debit, card, paid, kinds)`: the signals of
/// `bank-details` (an array, one per account), `direct-debit`,
/// `card-payment` and `paid` (each `none` if the invoice has none), and the
/// kinds of payment means they state. An invoice has one kind of payment
/// means (one BT-81); more than one kind are conflicting instructions, which
/// the e-invoice reports. The kinds are listed in the order in which they
/// decide the payment sentence: a direct debit, a payment card, a credit
/// transfer, another means.
///
/// -> dictionary
#let resolve(transfers, direct-debit, card, paid) = {
  let stated = (
    direct-debit: direct-debit != none,
    card: card != none,
    transfer: transfers.len() > 0,
    other: false,
  )
  let paid-kind = if paid != none { paid.at("kind", default: none) }
  if paid-kind != none { stated.insert(paid-kind, true) }
  let kinds = ()
  for (kind, present) in stated {
    if present { kinds.push(kind) }
  }
  (
    transfers: transfers,
    direct-debit: direct-debit,
    card: card,
    paid: paid,
    kinds: kinds,
  )
}

/// The payment means of a context: the description `resolve` built, which
/// the root context publishes from the second layout pass on, or `none`.
///
/// -> none | dictionary
#let of-context(ctx) = (
  ctx.at("global", default: (:)).at("payment-means", default: none)
)

/// Whether the bank details show their EPC-QR code by default: only if the
/// buyer pays the amount by credit transfer. A direct debit or a payment card
/// collects it otherwise, and a paid invoice asks for nothing, so a QR code
/// would invite the buyer to pay twice.
///
/// -> bool
#let transfer-requested(means) = {
  if means == none { return true }
  (
    means.paid == none and means.direct-debit == none and means.card == none
  )
}

/// The payment strings of the language, with the sentence of the payment
/// goal for the payment means of the invoice: the layout prints `text`, or
/// `text-due` with prepayments, so these are the sentences of a direct debit
/// or a payment card, and of a credit transfer otherwise. The notes of the
/// cash discounts (`payment-goal(discount: ..)`) follow the sentence.
///
/// -> dictionary
#let goal-strings(payment, means, discount-notes: ()) = {
  let kind = if means == none { none } else {
    means.kinds.first(default: none)
  }
  let text = payment.text
  let text-due = payment.text-due
  if kind == "direct-debit" {
    text = payment.at("text-direct-debit", default: text)
    text-due = payment.at("text-direct-debit-due", default: text-due)
  } else if kind == "card" {
    text = payment.at("text-card", default: text)
    text-due = payment.at("text-card-due", default: text-due)
  }
  if discount-notes.len() > 0 {
    let notes = discount-notes.join(" ")
    let sentence = text
    let sentence-due = text-due
    text = (sum, deadline) => [#sentence(sum, deadline) #notes]
    text-due = (sum, deadline) => [#sentence-due(sum, deadline) #notes]
  }
  payment + (text: text, text-due: text-due)
}
