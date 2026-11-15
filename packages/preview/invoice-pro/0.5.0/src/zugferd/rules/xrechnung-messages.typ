// The messages and hints of the rules of XRechnung (BR-DE-*) that no other
// profile reports, e.g. the buyer reference (BR-DE-15) or the seller contact
// (BR-DE-2). `diagnostics` of engine.typ loads this module for a finding of
// one of them, and messages.typ only for a finding of another rule: an
// invoice whose XRechnung checks fail (e.g. `zugferd: auto` for a buyer
// without buyer reference, which then falls back to EN 16931) does not parse
// the messages of every rule. A rule of XRechnung that shares its message
// with a rule of the other profiles (e.g. BR-DE-19 with IP-PAY-01) is in
// messages.typ. See engine.typ for the registry and the form of a finding.

#import "engine.typ": quoted as _quoted

// The inputs of the payment means, besides the bank details of a credit
// transfer, for hints.
#let _means-hint = "`#bank-details(iban: ..)` for a credit transfer, `#direct-debit(mandate: .., creditor-id: .., debtor-iban: ..)` for a SEPA direct debit, `#card-payment(last4: ..)` for a payment card, or `#paid(method: ..)` for an invoice that is paid already"

// XRechnung requires the city or the post code of an address.
#let _xrechnung-city(f) = (
  "XRechnung requires the " + f.term + " city.",
  "Set `city` on the "
    + f.party
    + ", e.g. \"10115 Berlin\" or `(name: \"Berlin\", post-code: \"10115\")`.",
)
#let _xrechnung-post-code(f) = (
  "XRechnung requires the " + f.term + " post code.",
  "Write the post code in the format of the country of the "
    + f.party
    + " (e.g. \"10115 Berlin\") or pass `city: (name: .., post-code: ..)`.",
)

// The seller contact (BR-DE-5, BR-DE-6, BR-DE-7).
#let _contact-terms = (
  name: "name (BT-41)",
  phone: "phone number (BT-42)",
  email: "email address (BT-43)",
)
#let _xrechnung-contact(f) = (
  "XRechnung requires the seller contact " + _contact-terms.at(f.input) + ".",
  "Set `contact."
    + f.input
    + "` (or `"
    + if f.input == "name" { "contact-name" } else { f.input }
    + "`) on the sender.",
)

/// The message and the hint of every rule of this module, by the key of its
/// entry (see `messages` of messages.typ).
#let messages = (
  "BR-DE-17": f => (
    "XRechnung does not allow the document type "
      + _quoted(f.code)
      + " (BT-3), only 326, 380, 381, 384, 389, 875, 876 and 877.",
    if f.code == "386" {
      "XRechnung has no prepayment invoice: state the advance payment as an invoice (`document-type: \"invoice\"`) or a partial invoice (`document-type: \"326\"`), or use the \"en16931\" profile (as `zugferd: auto` does)."
    } else {
      "Use one of these document types, or the \"en16931\" profile (as `zugferd: auto` does)."
    },
  ),
  "BR-DE-2": f => (
    "XRechnung requires the seller contact (BG-6).",
    "Set `contact: (name: .., phone: .., email: ..)` on the sender.",
  ),
  "BR-DE-5": _xrechnung-contact,
  "BR-DE-6": _xrechnung-contact,
  "BR-DE-7": _xrechnung-contact,
  "BR-DE-27": f => (
    "The seller contact phone number (BT-42) "
      + _quoted(f.phone)
      + " must contain at least three digits.",
    "Write the phone number with its digits, e.g. \"+49 89 1234567\".",
  ),
  "BR-DE-28": f => (
    "The seller contact email address (BT-43) "
      + _quoted(f.email)
      + " does not have the format XRechnung requires.",
    "Write one \"@\" between the name and a domain of ASCII letters, digits, hyphens and dots, and a domain with umlauts in punycode, e.g. \"info@xn--mller-bau-q9a.de\" for \"info@müller-bau.de\".",
  ),
  "BR-DE-3": _xrechnung-city,
  "BR-DE-4": _xrechnung-post-code,
  "BR-DE-8": _xrechnung-city,
  "BR-DE-9": _xrechnung-post-code,
  "BR-DE-10": _xrechnung-city,
  "BR-DE-11": _xrechnung-post-code,
  "BR-DE-15": f => (
    "XRechnung requires the buyer reference (BT-10), e.g. the Leitweg-ID.",
    if f.routing != none {
      (
        "Set the Leitweg-ID of its electronic address as `leitweg-id: id.leitweg("
          + _quoted(f.routing)
          + ")` on the recipient, or another `buyer-reference`."
      )
    } else {
      "Set `buyer-reference` on the recipient, or for a public buyer its Leitweg-ID, e.g. `leitweg-id: id.leitweg(\"04011000-1234512345-06\")`, which can be its electronic address as well."
    },
  ),
  "BR-DE-18": f => if "basis" in f {
    (
      "The amount a cash discount applies to (#BASISBETRAG) has 2 decimals in XRechnung, but "
        + str(f.basis)
        + " has more.",
      "Give the `basis` of the cash discount with at most 2 decimals.",
    )
  } else {
    let syntax = "every line that starts with \"#\" must be a cash discount in the XRechnung syntax, e.g. \"#SKONTO#TAGE=14#PROZENT=2.00#\", followed by a line break"
    (
      "In the payment terms (BT-20), "
        + if f.line != none {
          syntax + ", but " + _quoted(f.line) + " is not."
        } else if f.after.starts-with("#") {
          syntax + "."
        } else {
          (
            "XRechnung reads the text between the first and the last \"#\" of a line as a cash discount, which a line break must follow, but "
              + _quoted(f.after)
              + " goes on after its last \"#\"."
          )
        },
      "Write each cash discount on a line of its own: `#SKONTO#TAGE=` with the days, `#PROZENT=` with the percent and two decimals, optionally `#BASISBETRAG=` with the amount it applies to, and a closing `#`, e.g. \"Zahlbar innerhalb von 30 Tagen.\\n#SKONTO#TAGE=14#PROZENT=2.00#\". Do not start other lines with \"#\", and do not write text after the last \"#\" of a line that contains two.",
    )
  },
  "BR-DE-1": f => (
    "XRechnung requires payment instructions (BG-16).",
    if f.paid {
      "Set `method` on `paid` to the way the invoice was paid, e.g. `paid(method: \"cash\")`, or add the payment means it was paid with, e.g. `#bank-details(iban: ..)` for a credit transfer."
    } else if f.sender-pays {
      "You pay the amount of a credit note or a self-billed invoice: add `#bank-details(iban: ..)` with the recipient's account you transfer it to (not your own), `#paid(method: ..)` if it is paid already, or for a set-off against an invoice `#paid(method: (code: \"97\", name: [Verrechnung]))`."
    } else { "Add the payment means of the invoice: " + _means-hint + "." },
  ),
  "BR-DE-30": f => (
    "XRechnung requires the creditor identifier (BT-90) of a direct debit.",
    "Set `creditor-id` on `direct-debit` to your SEPA creditor identifier.",
  ),
  "BR-DE-31": f => (
    "XRechnung requires the debited account (BT-91) of a direct debit.",
    "Set `debtor-iban` on `direct-debit` to the IBAN of the buyer's account that is debited.",
  ),
  "BR-DE-24-a": f => (
    "A card payment (BT-81 = "
      + f.type-code
      + ") states the payment card (BG-18), but none is given.",
    "Add `#card-payment(last4: ..)` with the last digits of the card the invoice was paid with.",
  ),
)
