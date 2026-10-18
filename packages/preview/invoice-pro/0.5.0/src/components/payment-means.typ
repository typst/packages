// Payment means besides the bank details of a credit transfer: a SEPA
// direct debit, a payment card, and an invoice that is paid already. Like
// `bank-details`, each component prints its details where it is placed and
// states them in the e-invoice (BG-16, see `logic/payment-means.typ`).

#import "../loom-wrapper.typ": loom, managed-motif
#import "../utils/types.typ"
#import "../utils/text.typ": plain-text
#import "../utils/iban.typ": format-iban, iban-valid, normalize-iban
#import "../utils/creditor-id.typ": creditor-id-valid, normalize-creditor-id
#import "../logic/payment-means.typ": (
  card-code, direct-debit-code, method-kind, method-kinds, of-context,
  report-problems, transfer-code,
)
#import "../logic/document-type.typ": sender-pays
#import "../logic/currency.typ": currency-code

// The scope of every payment means component: the layout that draws it.
#let _scope(ctx) = loom.mutator.batch(ctx, {
  import loom.mutator: *

  nest("theme", {
    ensure("payment-means", (..) => panic(
      "theme::payment-means is not provided",
    ))
  })

  nest("global", {
    nest("total", {
      ensure("gross", 0)
      ensure("prepaid", 0)
    })
  })
})

#let _draw(ctx, _, view, ..) = (ctx.theme.payment-means)(ctx, view)

#let _is-missing(value) = value in (none, "", [])

// A direct debit and a payment card collect the amount from the buyer. The
// sender of a credit note or a self-billed invoice pays the amount to the
// recipient instead, so neither can state how it is paid.
#let _require-buyer-pays(ctx, name) = {
  if sender-pays(ctx.at("document-type", default: none)) {
    panic(
      name
        + ": a credit note or a self-billed invoice is paid by its sender, so the amount cannot be collected from the recipient. Use `bank-details` with the recipient's account or `paid`.",
    )
  }
}

/// Collects the amount of the invoice by SEPA direct debit from the account
/// of the buyer (BT-81 = 59, BG-19).
///
/// Prints the payment method, the mandate reference, the creditor
/// identifier and the debited account, and the payment goal announces the
/// direct debit instead of asking for a transfer. The e-invoice states the
/// mandate reference (BT-89), the creditor identifier (BT-90) and the
/// debited account (BT-91).
///
/// -> content
#let direct-debit(
  /// The mandate reference (BT-89): the identifier of the SEPA direct debit
  /// mandate the buyer signed. Required.
  /// -> str | content
  mandate: none,

  /// Your SEPA creditor identifier (BT-90), e.g. `"DE98ZZZ09999999999"`,
  /// with or without spaces. Required. For an invoice in euro, its check
  /// digits are checked.
  /// -> str | content
  creditor-id: none,

  /// The IBAN of the buyer's account that is debited (BT-91), with or
  /// without spaces. XRechnung requires it. Its check digits are checked.
  /// -> none | str | content
  debtor-iban: none,
) = {
  types.require(mandate, "direct-debit::mandate", none, str, content)
  types.require(creditor-id, "direct-debit::creditor-id", none, str, content)
  types.require(debtor-iban, "direct-debit::debtor-iban", none, str, content)
  assert(
    not _is-missing(mandate),
    message: "direct-debit: the mandate reference is missing. Set `mandate` to the reference of the SEPA direct debit mandate the buyer signed.",
  )
  assert(
    not _is-missing(creditor-id),
    message: "direct-debit: the creditor identifier is missing. Set `creditor-id` to your SEPA creditor identifier, e.g. \"DE98ZZZ09999999999\".",
  )

  managed-motif(
    "direct-debit",
    scope: _scope,
    measure: (ctx, _) => {
      // The root context collects the payment means of the body; inside
      // the line items, they would be printed but not stated.
      let _ = loom.guards.assert-not-inside(ctx, "line-items")
      _require-buyer-pays(ctx, "direct-debit")
      let strings = ctx.locale.strings.payment-means
      // SEPA direct debits are in euro; their creditor identifiers have
      // check digits.
      let sepa = currency-code(ctx.locale) == "EUR"
      let creditor = normalize-creditor-id(creditor-id)
      let creditor-valid = not sepa or creditor-id-valid(creditor)
      let iban = if not _is-missing(debtor-iban) {
        normalize-iban(debtor-iban)
      }
      let valid-iban = iban == none or iban-valid(iban)

      // A wrong identifier makes the printed invoice wrong as well, so it
      // stops the compilation, unless an e-invoice reports its problems in
      // the document (`zugferd-errors: "report"`).
      let report = report-problems(ctx)
      if not report and not creditor-valid {
        panic(
          "direct-debit: the creditor identifier \""
            + creditor
            + "\" is not a valid SEPA creditor identifier (wrong check digits or format). Check it for typos.",
        )
      }
      if not report and not valid-iban {
        panic(
          "direct-debit: the IBAN \""
            + format-iban(iban)
            + "\" of `debtor-iban` is not valid (wrong check digits or format). Check it for typos.",
        )
      }

      let details = (
        (
          label: strings.method,
          value: if sepa { strings.sepa-direct-debit } else {
            strings.direct-debit
          },
        ),
        (label: strings.mandate, value: mandate),
        (label: strings.creditor-id, value: creditor, valid: creditor-valid),
      )
      if iban != none {
        details.push((
          label: strings.debtor-iban,
          value: format-iban(iban),
          valid: valid-iban,
        ))
      }

      let public = (
        mandate: mandate,
        creditor-id: creditor,
        debtor-iban: iban,
      )
      (public, (kind: "direct-debit", text: none, details: details))
    },
    draw: _draw,
    none,
  )
}

/// States that the amount of the invoice is paid, or charged, with a
/// payment card (BT-81 = 48, 54 or 55, BG-18).
///
/// Prints the kind of card, the last digits of the card number and the card
/// holder, and the payment goal says that the amount is charged to the card
/// instead of asking for a transfer. The e-invoice states the last digits
/// of the card number (BT-87) and the card holder (BT-88); the profiles
/// below EN 16931 state only the payment means code.
///
/// -> content
#let card-payment(
  /// The last 4 digits of the card number (BT-87), e.g. `"1234"`. Up to 6
  /// digits are accepted, never the full number: an invoice must not show
  /// more of it (PCI DSS, BR-51). Required.
  /// -> str | content
  last4: none,

  /// The name of the card holder (BT-88).
  /// -> none | str | content
  holder: none,

  /// The kind of card: `"credit"` (credit card, BT-81 = 54), `"debit"`
  /// (debit card, 55), or `auto` for a card of either kind (bank card, 48).
  /// -> auto | "credit" | "debit"
  kind: auto,
) = {
  types.require(last4, "card-payment::last4", none, str, content)
  types.require(holder, "card-payment::holder", none, str, content)
  types.require(kind, "card-payment::kind", auto, "credit", "debit")
  let digits = plain-text(last4).replace(" ", "")
  let only-digits = true
  for char in digits.clusters() {
    if char not in "0123456789" { only-digits = false }
  }
  assert(
    only-digits and digits.len() >= 4 and digits.len() <= 6,
    message: "card-payment: `last4` must be the last 4 digits of the card number (at most 6), e.g. \"1234\", got "
      + repr(last4)
      + ". An invoice must never show the full card number.",
  )

  managed-motif(
    "card-payment",
    scope: _scope,
    measure: (ctx, _) => {
      // The root context collects the payment means of the body; inside
      // the line items, they would be printed but not stated.
      let _ = loom.guards.assert-not-inside(ctx, "line-items")
      _require-buyer-pays(ctx, "card-payment")
      let strings = ctx.locale.strings.payment-means
      let details = (
        (
          label: strings.method,
          value: if kind == "credit" { strings.credit-card } else if (
            kind == "debit"
          ) { strings.debit-card } else { strings.card },
        ),
        (label: strings.card-number, value: "**** " + digits),
      )
      if not _is-missing(holder) {
        details.push((label: strings.card-holder, value: holder))
      }
      let public = (
        last4: digits,
        holder: if not _is-missing(holder) { holder },
        kind: kind,
      )
      (public, (kind: "card", text: none, details: details))
    },
    draw: _draw,
    none,
  )
}

// The methods of `paid` and the name of each in the language strings.
#let _method-names = (
  cash: "cash",
  cheque: "cheque",
  online: "online",
  transfer: "transfer",
  card: "card",
)

/// States that the invoice is paid already: the paid amount (BT-113) is the
/// total, and nothing is due (BT-115). An invoice that is paid has no
/// payment goal and no text as `due-date`.
///
/// Prints that the amount was paid, and how, and that nothing is due; on a
/// credit note or a self-billed invoice, that the sender paid it to the
/// recipient. The e-invoice states the payment means the invoice was paid
/// with (BT-81) and the printed sentence as payment terms (BT-20).
///
/// -> content
#let paid(
  /// How the invoice was paid: `"cash"` (BT-81 = 10), `"card"` (a payment
  /// card, 48, or the kind of a `card-payment`), `"transfer"` (credit
  /// transfer to the account of the `bank-details`, 58 or 30),
  /// `"direct-debit"` (by the `direct-debit`, 59 or 49), `"cheque"` (20),
  /// `"online"` (an online payment service, 68), or another payment means
  /// code of UNTDID 4461 with its printed name, e.g.
  /// `(code: "97", name: [Verrechnung])`. A code of a kind that the
  /// `card-payment`, `direct-debit` or `bank-details` of the invoice state
  /// must be their code (e.g. 54 next to `card-payment(kind: "credit")`);
  /// its name is printed next to their details. `auto` names no method: the
  /// payment means of the invoice (`bank-details`, `direct-debit` or
  /// `card-payment`) is the one it was paid with.
  /// -> auto | str | dictionary
  method: auto,

  /// The date of the payment.
  /// -> none | datetime | str | content
  date: none,
) = {
  types.require(
    method,
    "paid::method",
    auto,
    ..method-kinds.keys(),
    (code: str, name: types.text-like),
  )
  types.require(date, "paid::date", none, datetime, str, content)
  types.require-day(date, "paid::date")

  managed-motif(
    "paid",
    scope: _scope,
    measure: (ctx, _) => {
      // The root context collects the payment means of the body; inside
      // the line items, they would be printed but not stated.
      let _ = loom.guards.assert-not-inside(ctx, "line-items")
      let strings = ctx.locale.strings
      let names = strings.payment-means
      let format = ctx.locale.format
      let total = ctx.global.total
      let currency = currency-code(ctx.locale)
      // With prepayments, the amount paid now is the remaining amount due.
      // The sender of a credit note or a self-billed invoice paid the amount
      // to the recipient.
      let has-prepayments = total.prepaid > 0
      let amount = total.at("due", default: total.gross)
      let sentence = if sender-pays(ctx.at("document-type", default: none)) {
        names.paid-credit
      } else if has-prepayments { names.paid-due } else { names.paid }
      let text = sentence(
        (format.currency)(amount),
        if type(date) == datetime { (format.date)(date) } else { date },
      )

      // A payment means code of its own (`(code: .., name: ..)`) of a kind
      // that a component of the invoice details (the bank details of a
      // credit transfer, the direct debit, the payment card) must be the
      // code of that component: an invoice states one (BT-81), and the other
      // would be lost.
      let kind = method-kind(method)
      let means = of-context(ctx)
      if type(method) == dictionary and means != none {
        let (component, stated, hint) = if (
          kind == "card" and means.card != none
        ) {
          (
            "card-payment",
            card-code(means.card.at("kind", default: auto)),
            "Set the kind of the card on `card-payment` (`kind: \"credit\"` for 54, `kind: \"debit\"` for 55, `auto` for 48) and use a `method` of that code, or leave out `method`.",
          )
        } else if kind == "direct-debit" and means.direct-debit != none {
          (
            "direct-debit",
            direct-debit-code(currency),
            "A direct debit is stated as 59 (SEPA direct debit) in euro and as 49 otherwise: use `method: \"direct-debit\"`, or leave out `method`.",
          )
        } else if kind == "transfer" and means.transfers.len() > 0 {
          (
            "bank-details",
            transfer-code(currency),
            "A credit transfer is stated as 58 (SEPA credit transfer) in euro and as 30 otherwise: use `method: \"transfer\"`, or leave out `method`.",
          )
        } else { (none, none, none) }
        if stated != none and stated != method.code {
          panic(
            "paid: `method` names the payment means code \""
              + method.code
              + "\", but the `"
              + component
              + "` of the invoice states the code \""
              + stated
              + "\". An invoice states one payment means code (BT-81). "
              + hint,
          )
        }
      }

      // The method, unless the details of the direct debit or the payment
      // card it names print it already. A name of its own is printed in any
      // case.
      let detailed = (
        means != none
          and type(method) != dictionary
          and (
            (kind == "direct-debit" and means.direct-debit != none)
              or (kind == "card" and means.card != none)
          )
      )
      let method-name = if detailed or method == auto { none } else if (
        type(method) == dictionary
      ) { method.name } else if method == "direct-debit" {
        if currency == "EUR" { names.sepa-direct-debit } else {
          names.direct-debit
        }
      } else { names.at(_method-names.at(method)) }

      // What the invoice prints about the payment: the sentence and the
      // method, which the e-invoice states as payment terms (BT-20), and
      // that nothing is due.
      let lines = (text,)
      let details = ()
      if method-name != none {
        details.push((label: names.method, value: method-name))
        lines.push([#names.method: #method-name])
      }
      details.push((
        label: strings.summary.amount-due,
        value: (format.currency)(0),
      ))

      let public = (method: method, kind: kind, date: date, terms: lines)
      (public, (kind: "paid", text: text, details: details))
    },
    draw: _draw,
    none,
  )
}
