// The messages and hints of the rules of the registry, but those of the
// rules of XRechnung that no other profile reports (xrechnung-messages.typ).
// `diagnostics` of engine.typ loads this module only for a finding of one of
// its rules: the texts are the largest part of the rules. See engine.typ for
// the registry and the form of a finding.
//
// Every entry of `messages` takes a finding and returns `(message, hint)`
// (the hint may be `none`); the finding holds the values its check found.

#import "../code-lists.typ": lists
#import "engine.typ": in-list, quoted as _quoted
#import "../xml.typ": fmt-number, rate-digits
#import "../model.typ": vat-eas-codes, vat-id-prefix
#import "../../utils/iban.typ": format-iban

// A rate in percent as the XML states it, e.g. "19%" or "9.975%".
#let _percent(rate) = (
  fmt-number(rate * 100, min-digits: 0, max-digits: rate-digits) + "%"
)

// Whether a code that no list of the profile accepts is in the newest list
// of the official validation (CEN 1.3.16), which the other lists lack.
#let _newer(list, code) = (
  type(code) == str
    and "newer" in list
    and not code.contains(" ")
    and (" " + code + " ") in list.newer
)

// The message and the hint for such a code, e.g. XCG (the Caribbean
// guilder, 2025): `subject` names the code, e.g. `The scheme "0240" of the
// global identifier`. XRechnung is validated with the lists of EN 16931
// alone (`xrechnung` of the finding, see `code-finding` of rare.typ).
#let _not-yet(f, subject) = {
  let (validation, validators) = if f.at("xrechnung", default: false) {
    ("every validator of XRechnung", "the validators of XRechnung")
  } else {
    ("the Factur-X validation", "the validators of the Factur-X profiles")
  }
  (
    subject
      + " is not in the code list of "
      + validation
      + " yet: only the newest version of the EN 16931 code list has it.",
    "Use another code while " + validators + " do not know it yet.",
  )
}

// A code that only the code list of the Factur-X validation lacks (`fx-only`
// of a finding, see `code-finding` of rare.typ), which the validation of
// XRechnung accepts: `subject` names the code, e.g. `The scheme "0219" of
// the buyer electronic address (BT-49)`.
#let _factur-x-only(subject, hint) = (
  subject
    + " is not in the code list of the Factur-X validation, although the code list of EN 16931 has it.",
  hint
    + " The \"xrechnung\" profile, whose validation applies the code lists of EN 16931 alone, accepts it.",
)

// The code list a code list rule applies: the Factur-X list in MINIMUM and
// BASIC WL (a rule FX-SCH-A-*), else the one of EN 16931.
#let _list-of(f) = if f.at("id", default: "").starts-with("FX-") {
  "Factur-X"
} else { "EN 16931" }

// Why the e-invoice of a document states no date of the supply when nothing
// dates it (see `supply-dated`): a credit note or a prepayment invoice.
#let _undated-reason(document) = if (
  type(document) == dictionary and document.at("prepayment", default: false)
) { "a prepayment invoice precedes the supply" } else {
  "the date of a credit note is not the date of the supply"
}

// What a title names that is no invoice at all, for IP-DOC-01.
#let _no-invoice = (
  quote: "a quote",
  delivery-note: "a delivery note",
  order: "an order",
  pro-forma: "a pro forma invoice",
  reminder: "a payment reminder",
)

// Hints for country codes that are missing from the code list of EN 16931.
#let _country-hints = (
  EL: "Use \"GR\" (`country.gr`) for Greece; \"EL\" is only the prefix of Greek VAT identifiers.",
  SS: "South Sudan (SS) is missing from the code list the EN 16931 validators apply, so only the \"minimum\" and \"basic-wl\" profiles can state it.",
  UK: "Use \"GB\" (`country.uk`) for the United Kingdom.",
)

// What an identifier of each kind of the `id` module identifies, for messages.
#let _id-kinds = (
  party: "a party identifier",
  legal: "a legal registration identifier",
  routing: "a Leitweg-ID",
  custom: "an identifier",
)

// The VAT categories that require the buyer VAT identifier (BT-48): what
// they are, and what identifies the buyer for them (a reverse charge may take
// the legal registration identifier instead).
#let _buyer-vat-id-terms = (
  K: (
    term: "An intra-community supply (K)",
    required: "the buyer VAT identifier (BT-48)",
  ),
  AE: (
    term: "Reverse charge (AE)",
    required: "the buyer VAT identifier (BT-48) or legal registration identifier (BT-47)",
  ),
)

// Margin schemes have no category in EN 16931: they are written as exempt
// with the note the VAT Directive requires (art. 226 no. 13 and 14).
#let _margin-scheme-hint(scheme, german) = (
  "EN 16931 has no category for margin schemes: write the items as exempt with the note the law requires, e.g. `tax.exempt(grounds: \"Margin scheme - "
    + scheme
    + "\")` (in Germany \""
    + german
    + "\")."
)

// Categories EN 16931 knows, and how to express the others.
#let _category-hints = (
  AA: "Use `tax.vat(..)` with the reduced rate, e.g. `tax.vat(7%)`.",
  H: "Use `tax.vat(..)` with the higher rate.",
  N: "Use `tax.vat(..)` with the additional rate.",
  B: "Split payment (B) is not supported by Factur-X / ZUGFeRD.",
  D: _margin-scheme-hint("travel agents", "Sonderregelung für Reisebüros"),
  F: _margin-scheme-hint(
    "second-hand goods",
    "Gebrauchtgegenstände/Sonderregelung",
  ),
  I: _margin-scheme-hint("works of art", "Kunstgegenstände/Sonderregelung"),
  J: _margin-scheme-hint(
    "collector's items and antiques",
    "Sammlungsstücke und Antiquitäten/Sonderregelung",
  ),
)

// Who has the VAT category of a rule offset, for messages.
#let _holders = ("Items", "Document level allowances", "Document level charges")

// What a kind of payment means is, and the input that states it, for
// messages. A means of `paid` without details names its code.
#let _means-names = (
  transfer: "a credit transfer",
  direct-debit: "a direct debit",
  card: "a payment card",
)
#let _code-names = (
  "10": "cash",
  "20": "a cheque",
  "68": "an online payment service",
)
#let _means-description(means) = {
  let name = _means-names.at(means.kind, default: none)
  if name == none {
    name = _code-names.at(
      means.type-code,
      default: "the payment means code " + means.type-code,
    )
  }
  name + " (`" + means.field + "`)"
}

#let _bug-hint = "This is a bug in invoice-pro. Please report it at https://github.com/leonieziechmann/invoice-pro/issues."

// --- Shared messages ------------------------------------------------------

#let _missing-country(f) = (
  "The " + f.term + " is missing.",
  "Set `country` on the "
    + f.field.split(".").first()
    + ", e.g. `country: country.de` or `country: \"DE\"`.",
)

#let _global-id-scheme(f) = if _newer(lists.icd, f.scheme) {
  _not-yet(f, "The scheme " + _quoted(f.scheme) + " of the global identifier")
} else {
  (
    "The scheme "
      + _quoted(f.scheme)
      + " of the global identifier is not an ISO/IEC 6523 code.",
    "Use e.g. \"0088\" for a GLN or \"0060\" for a DUNS number.",
  )
}

#let _single-identifier(f) = (
  "The "
    + f.term
    + " can be stated only once, but `"
    + f.id-key
    + "` and `"
    + f.global-id-key
    + "` give one each.",
  "Keep either `"
    + f.id-key
    + "` or `"
    + f.global-id-key
    + "` on the "
    + f.field
    + ".",
)

// A missing electronic address (PEPPOL-EN16931-R020, R010, IP-EADDR-01).
#let _electronic-address(f) = {
  // Name only the inputs that can still provide the address.
  let vat-id = f.vat-id
  let field = f.field
  let hint = if vat-id == none and f.represented {
    (
      "Set `electronic-address`, `vat-id` (the seller's own VAT identifier, not the one of its tax representative) or `email` on the "
        + field
        + "."
    )
  } else if vat-id == none {
    "Set `electronic-address`, `vat-id` or `email` on the " + field + "."
  } else {
    let prefix = vat-id-prefix(vat-id)
    let reason = if prefix != none and prefix not in vat-eas-codes {
      (
        " (there is no electronic address scheme for its prefix "
          + _quoted(prefix)
          + ")"
      )
    } else { "" }
    (
      "No electronic address can be derived from the VAT identifier "
        + _quoted(vat-id)
        + reason
        + ". Set `electronic-address` or `email` on the "
        + field
        + "."
    )
  }
  // A public buyer in Germany receives XRechnung at its Leitweg-ID, the
  // buyer reference (`reference`) of this invoice (EAS 0204), as `id.leitweg`
  // checks it, e.g. "04011000-1234512345-06".
  let reference = f.reference
  if (
    type(reference) == str
      and reference.match(regex("^[0-9]{2,12}(-[0-9A-Z]{1,30})?-[0-9]{2}$"))
        != none
  ) {
    hint = (
      "A public buyer is reached by its Leitweg-ID: set `electronic-address: id.leitweg("
        + _quoted(reference)
        + ")` on the "
        + field
        + ". "
        + hint
    )
  }
  ("The " + f.term + " is missing.", hint)
}

// An electronic address without scheme (BR-62, BR-63).
#let _address-scheme(f) = {
  // A Peppol participant identifier such as "0088:4000001123452" (also with
  // the prefix "iso6523-actorid-upis::") carries its scheme in front of the
  // identifier.
  let (scheme, id) = ("0088", f.address)
  let parts = f.address.split(":")
  if (
    parts.len() >= 2
      and in-list(lists.eas.every, parts.at(-2))
      and parts.last() != ""
  ) {
    (scheme, id) = (parts.at(-2), parts.last())
  }
  (
    "The " + f.term + " " + _quoted(f.address) + " has no scheme identifier.",
    "Give the address with its scheme, e.g. `electronic-address: (scheme: "
      + _quoted(scheme)
      + ", id: "
      + _quoted(id)
      + ")`"
      + if scheme == "0088" and id == f.address { " for a GLN" }
      + ", or give an email address.",
  )
}

// Several payment means (BR-DE-23-b, BR-DE-24-b, CII-SR-467, IP-PAY-03).
#let _several-means(f) = {
  let names = f.means.map(_means-description)
  (
    "The invoice states several payment means: "
      + names.slice(0, -1).join(", ")
      + " and "
      + names.last()
      + ". An invoice states one payment means (BT-81)"
      + if f.paid { ": the one it was paid with." } else {
        ", so that the buyer knows how to pay and does not pay twice."
      },
    if f.paid {
      "Remove the payment means the invoice was not paid with, e.g. `bank-details` of an invoice paid in cash, or set `method` on `paid` to the one it was paid with. To show your bank account for information only, print it as text."
    } else {
      "Keep the payment means the buyer pays with, e.g. remove `bank-details` when the amount is collected by direct debit or charged to a card. To show your bank account for information only, print it as text."
    },
  )
}

// A credit transfer without an account (BR-DE-23-a, CII-SR-470, IP-PAY-04).
#let _transfer-account(f) = (
  "A credit transfer (BT-81 = "
    + f.type-code
    + ") states the account the amount is transferred to (BT-84), but none is given.",
  if f.paid {
    "Add `#bank-details(iban: ..)` with the account the invoice was paid to."
  } else { "Set `iban` on `bank-details`." },
)

// An IBAN with wrong check digits (BR-DE-19, BR-DE-20, IP-PAY-01).
#let _iban(f) = (
  if f.debtor { "The IBAN of the debited account (BT-91) " } else {
    "The IBAN (BT-84) "
  }
    + _quoted(format-iban(f.iban))
    + " is not valid (wrong check digits or format).",
  "Check the IBAN for typos.",
)

// A direct debit named by `paid` without its details (BR-DE-25-a,
// PEPPOL-EN16931-R061).
#let _paid-direct-debit(f) = (
  if f.type-code == "59" {
    "A SEPA direct debit (BT-81 = 59) states the direct debit (BG-19), but none is given."
  } else {
    (
      "A direct debit (BT-81 = "
        + f.type-code
        + ") states the mandate reference (BT-89), but none is given."
    )
  },
  "Add `#direct-debit(mandate: .., creditor-id: .., debtor-iban: ..)` with the direct debit the invoice was paid with.",
)

// A date of an item outside the service period (PEPPOL-EN16931-R110, R111,
// IP-PERIOD-02).
#let _span(period) = {
  let start = period.first().display("[year]-[month]-[day]")
  let end = period.last().display("[year]-[month]-[day]")
  if start == end { start } else { start + " to " + end }
}
#let _item-outside-period(f) = (
  "The date of the item ("
    + _span(f.period)
    + ") is outside the service period of the invoice ("
    + _span(f.service-period)
    + ").",
  "Set `service-period` on the invoice to a period that includes the dates of all items, or leave it out: the dates of the items are the service period then.",
)

// A payee without a name, or that is the seller (BR-17, IP-PAY-05).
#let _payee(f) = if f.kind == "name" {
  (
    "The name of the payee (BT-59) is missing.",
    "Set `name` on the payee, e.g. the name of the factoring company that receives the payment.",
  )
} else {
  (
    "The payee (BG-10) is stated when someone other than the seller receives the payment, but its name, identifier or legal registration identifier is the seller's.",
    "Leave out `payee` when the seller receives the payment itself.",
  )
}

// A seller tax representative on an invoice not subject to VAT (BR-O-02,
// BR-O-03, BR-O-04, IP-TAX-05).
#let _outside-scope-representative(f) = (
  "An invoice not subject to VAT (O) states no VAT identifiers, so it cannot name the seller tax representative (BG-11), whose VAT identifier (BT-63) it would state.",
  "Leave out `tax-representative` on invoices of items not subject to VAT.",
)

// A corrected invoice without the invoice it corrects (BR-DE-26 in
// XRechnung, IP-DOC-02 in the other profiles).
#let _uncorrected(f) = (
  "A corrected invoice (BT-3 = "
    + f.code
    + ") replaces a preceding invoice, but it names none (BG-3).",
  "Set `preceding-invoice-nr` (and `preceding-invoice-date`) to the invoice it corrects.",
)

// --- Messages -------------------------------------------------------------

/// The message and the hint of every rule, by the key of its entry.
#let messages = (
  // Document
  "BR-02": f => (
    "The invoice number (BT-1) is missing.",
    "Set `invoice-nr` on the invoice.",
  ),
  "BR-03": f => (
    "The invoice date (BT-2) is missing or is not a calendar date.",
    "Set `date` on the invoice, e.g. `datetime(year: 2026, month: 7, day: 1)`.",
  ),
  "BR-05": f => (
    "The invoice currency code (BT-5) is missing.",
    "Set `currency` on the invoice, e.g. `currency: \"EUR\"`, or use a locale that defines `currency.code`, e.g. `locale.de-de`.",
  ),
  "BR-CL-04": f => if f.fx-only {
    _factur-x-only(
      "The invoice currency code (BT-5) " + _quoted(f.code),
      "Invoice in another currency.",
    )
  } else if f.at("profile", default: none) != none {
    (
      "The invoice currency code (BT-5) "
        + _quoted(f.code)
        + " is missing in the code list of the EN 16931 validation, so no e-invoice in the "
        + f.profile
        + " profile can use it.",
      if in-list(lists.currency.at("withdrawn", default: ""), f.code) {
        "Invoice in the currency that replaced it, e.g. \"EUR\" for \"BGN\" and \"HRK\", or use a profile of Factur-X, whose validation accepts the code (with a warning in \"basic\" and \"en16931\")."
      } else {
        "Invoice in another currency, or use the \"minimum\" or \"basic-wl\" profile, whose validation knows the code."
      },
    )
  } else if _newer(lists.currency, f.code) {
    _not-yet(f, "The invoice currency code (BT-5) " + _quoted(f.code))
  } else {
    (
      "The invoice currency code (BT-5) "
        + _quoted(f.code)
        + " is not an ISO 4217 code.",
      if f.field == "currency" {
        "Set `currency` to an ISO 4217 code such as \"EUR\" or \"USD\"."
      } else {
        "Use a currency code such as \"EUR\" or \"CHF\" in the locale, or set `currency` on the invoice."
      },
    )
  },
  "IP-TAX-01": f => (
    "The invoice sets `tax: none`, so "
      + if f.count <= 1 { "an item has" } else {
        str(f.count) + " items have"
      }
      + " no VAT category (BT-151): printed with 0%, it would be declared as zero rated (Z).",
    "Choose the VAT category with the `tax` module, e.g. `tax.exempt(grounds: ..)` for exempt items, `tax.outside-scope()` for supplies not subject to VAT or `tax.zero()` for zero rated goods, or set `tax-exempt-small-biz: true`.",
  ),
  "IP-PRINT-02": f => (
    "The invoice prints "
      + f.kind
      + " in "
      + _quoted(f.sign)
      + " (e.g. "
      + _quoted(f.sample)
      + "), but the e-invoice states the currency "
      + _quoted(f.currency)
      + " (BT-5).",
    "Set `currency` on the invoice to the printed currency, e.g. `currency: \"PLN\"`, or the currency of the locale's region, e.g. `currency: (code: \"PLN\", symbol: \"zł\")` in a region builder; the amounts are then printed with its symbol.",
  ),
  "IP-DOC-01": f => {
    let title = _quoted(f.title)
    let code = f.code
    let as-invoice = "or `document-type: \"invoice\"` if it is an invoice."
    if f.kind in _no-invoice {
      (
        "The subject "
          + title
          + " names "
          + _no-invoice.at(f.kind)
          + ", which is no invoice, but the e-invoice states a commercial invoice (BT-3 = "
          + code
          + ").",
        "Do not set `zugferd` for quotes, delivery notes, orders, pro forma invoices or payment reminders: an e-invoice is only written for invoices and credit notes. Set `document-type: \"invoice\"` if it is an invoice.",
      )
    } else if f.kind == "corrected" {
      (
        "The subject "
          + title
          + " names a corrected invoice, but the e-invoice states a new commercial invoice (BT-3 = "
          + code
          + "), which the buyer would book and pay a second time.",
        "Set `document-type: \"corrected\"` (384) and `preceding-invoice-nr` to the invoice it replaces, `document-type: \"credit-note\"` (381) for a credit note, "
          + as-invoice,
      )
    } else if f.kind == "self-billed" {
      (
        "The subject "
          + title
          + " names a self-billed invoice, but the e-invoice states a commercial invoice of the sender (BT-3 = "
          + code
          + ").",
        "Set `document-type: \"self-billed\"` (389): the sender is then the buyer, who issues the invoice, and the recipient the seller. Set `document-type: \"invoice\"` if it is an invoice.",
      )
    } else {
      (
        "The subject "
          + title
          + " names a credit note"
          + if f.kind == "credit-note-or-self-billed" {
            " or a self-billed invoice"
          }
          + ", but the e-invoice states a commercial invoice (BT-3 = "
          + code
          + "), which asks the buyer to pay.",
        "Set `document-type: \"credit-note\"` (381) for a credit note and enter the credited items with positive prices, "
          + if f.kind == "credit-note-or-self-billed" {
            "`document-type: \"self-billed\"` (389) for a self-billed invoice (which German VAT law calls \"Gutschrift\"), "
          } else {
            // "Rechnungskorrektur" and the like also name a corrected invoice.
            "`document-type: \"corrected\"` (384) for an invoice that replaces the preceding one, "
          }
          + as-invoice,
      )
    }
  },
  "IP-DOC-05": f => (
    "The date of the preceding invoice (BT-26) is given, but not its number (BT-25): the e-invoice states a preceding invoice by its number, so the date would be lost.",
    "Set `preceding-invoice-nr` on the invoice.",
  ),
  "BR-DE-26": _uncorrected,
  "IP-DOC-02": _uncorrected,
  "IP-DOC-03": f => (
    "A credit note (BT-3 = "
      + f.code
      + ") states the credited amounts as positive amounts, but its total is "
      + fmt-number(f.gross)
      + ", which would ask the buyer to pay "
      + fmt-number(-f.gross)
      + ".",
    "Enter the credited items with positive prices: the document type already says that the amounts are credited to the buyer.",
  ),
  "IP-DOC-04": f => (
    "The total is negative ("
      + fmt-number(f.gross)
      + "), but the document type "
      + _quoted(f.code)
      + " (BT-3) is no credit note: the e-invoice asks the buyer to pay a negative amount.",
    "For a credit, set `document-type: \"credit-note\"` and enter the credited items with positive prices.",
  ),
  "IP-PROFILE-01": f => (
    "The "
      + f.profile
      + " profile cannot state "
      + f.term
      + ", so "
      + if f.inputs == none { "`" + f.field + "` is" } else {
        f.inputs.map(key => "`" + key + "`").join(" and ") + " are"
      }
      + " not written into the e-invoice.",
    "Use the " + _quoted(f.lowest) + " profile or higher to state it.",
  ),
  "BR-CL-08": f => (
    "The subject code "
      + _quoted(f.code)
      + " of a note (BT-21) is not a code of UNTDID 4451.",
    "Use a code such as \"AAI\" (general information), \"REG\" (regulatory information), \"TXD\" (tax declaration) or \"SUR\" (supplier remarks), or leave out `subject-code`.",
  ),
  "IP-PERIOD-01": f => {
    let stated = f.stated
    (
      "The invoice prints the service period "
        + _quoted(f.printed)
        + if f.contradicts { "" } else { " as a text of its own" }
        + ", but the e-invoice states "
        + if stated == none { "none, as " + _undated-reason(f.document) } else {
          (
            _quoted(stated)
              + " ("
              + f.term
              + ")"
              + if f.source == "invoice-date" {
                ", the invoice date, as no item has a date"
              } else if f.source == "items" { ", from the dates of the items" }
          )
        }
        + if f.contradicts or stated == none { "." } else {
          ". Make sure that both name the same period."
        },
      "Set `service-period` on the invoice, e.g. `service-period: (datetime(year: 2026, month: 6, day: 1), datetime(year: 2026, month: 6, day: 30))`, and print it with `references.service-time()` without `value`, which prints the service period of the e-invoice.",
    )
  },
  "BR-DE-TMP-32": f => (
    "XRechnung recommends the date of the supply (BT-72) or the invoicing period (BG-14), which the e-invoice does not state without dates, as "
      + _undated-reason(f.document)
      + ".",
    "Set `service-period` to the date or period of the supply the document refers to, e.g. the one of the preceding invoice, or give the items their `date`.",
  ),
  "IP-PERIOD-03": f => if f.level == "error" {
    (
      "The printed invoice does not show the date of the supply"
        + if f.stated != none {
          " (" + _quoted(f.stated) + " in the e-invoice, " + f.term + ")"
        }
        + ", which German law requires on the invoice, also when it is the date of the invoice (§ 14 Abs. 4 Satz 1 Nr. 6 UStG).",
      "Print it with `references.service-time()`, which the default `references` and every preset include, and set `service-period` if the supply was not on the date of the invoice. A sentence such as \"Leistungsdatum entspricht Rechnungsdatum\" is not recognized: print the date.",
    )
  } else {
    (
      "The e-invoice states the date of the supply "
        + _quoted(f.stated)
        + " ("
        + f.term
        + "), which is not the date of the invoice, but the printed invoice does not show it"
        + if f.small-amount {
          " (a small-amount invoice of at most 250 euros need not show it, § 33 UStDV)."
        } else { " (Art. 226 No. 7 of the VAT Directive)." },
      "Print it with `references.service-time()`, which every preset includes.",
    )
  },

  // Parties
  "BR-06": f => (
    "The seller name (BT-27) is missing.",
    "Set `name` on the sender.",
  ),
  "BR-07": f => (
    "The buyer name (BT-44) is missing.",
    "Set `name` on the recipient.",
  ),
  "IP-KEY-01": f => {
    let entry = f.entry
    let owner = if entry.within == none { "the " + f.term } else {
      "`" + entry.within + "`"
    }
    (
      "`"
        + entry.key
        + "` is not a key of "
        + owner
        + ", so its value is not written into the e-invoice.",
      if entry.hint != none { entry.hint } else if entry.like != none {
        "Did you mean `" + entry.like + "`?"
      } else {
        "Check the spelling of the key, or keep it if only the printed invoice uses it (e.g. through `info.dynamic`)."
      },
    )
  },
  "IP-KEY-02": f => {
    let entry = f.entry
    let owner = if entry.within == none { "the " + f.term } else {
      "`" + entry.within + "`"
    }
    if entry.like == none {
      // A key of an identifier dictionary that has no `id`.
      (
        "`"
          + entry.key
          + "` is not a key of "
          + owner
          + ", which has no `id`, so the identifier is missing from the e-invoice.",
        "Give the identifier as `(scheme: .., id: ..)`.",
      )
    } else {
      (
        "`"
          + entry.key
          + "` is not a key of "
          + owner
          + ". It looks like `"
          + entry.like
          + "`, so its value is missing from the e-invoice.",
        if entry.hint != none { entry.hint } else {
          "Rename it to `" + entry.like + "`."
        },
      )
    }
  },
  "BR-09": _missing-country,
  "BR-11": _missing-country,
  "BR-57": _missing-country,
  "BR-20": _missing-country,
  "BR-CL-14": f => if f.fx-only {
    _factur-x-only(
      "The " + f.term + " " + _quoted(f.code),
      "Use the country the code stands for today.",
    )
  } else {
    (
      "The "
        + f.term
        + " "
        + _quoted(f.code)
        + " is not in the ISO 3166-1 code list of "
        + _list-of(f)
        + ".",
      _country-hints.at(
        f.code,
        default: "Use a country of the `country` module (e.g. `country.de`), an ISO code (e.g. \"DE\") or `country.custom(code: ..)`.",
      ),
    )
  },
  "IP-COUNTRY-01": f => (
    "The "
      + f.term
      + " country ("
      + f.bt
      + ") is not stated and defaults to "
      + _quoted(f.country)
      + ", the country of the locale, but the "
      + f.term
      + " VAT identifier "
      + _quoted(f.vat-id)
      + " was issued by "
      + _quoted(f.issuer)
      + ".",
    "Set `country` on the "
      + f.party
      + ", e.g. `country: "
      + _quoted(f.issuer)
      + "`.",
  ),
  "IP-ADDR-01": f => (
    "The "
      + f.term
      + " city "
      + _quoted(f.city)
      + " contains a number, but no post code in the format of "
      + _quoted(f.country)
      + ": the post code ("
      + f.code-bt
      + ") would be missing, and the number would be written into the city name ("
      + f.city-bt
      + ").",
    "Write the post code as the country expects it (e.g. \"1012 AB Amsterdam\"; `country.custom(code: .., post-code: \"999-9999\")` sets the format of other countries), check `country` on the "
      + f.party
      + ", or pass the parts, e.g. `city: (name: \"Amsterdam\", post-code: \"1012 AB\")`.",
  ),
  "BR-CO-09": f => (
    "The VAT identifier "
      + _quoted(f.vat-id)
      + " does not start with a country prefix.",
    "Write the VAT identifier with its country prefix, e.g. \"DE123456789\".",
  ),
  "BR-CO-26": f => if f.minimum {
    (
      "The MINIMUM profile identifies the seller by its VAT identifier (BT-31) or its legal registration identifier (BT-30), and both are missing.",
      if f.represented {
        "The VAT identifier of the tax representative does not identify the seller. Set `legal-id` on the sender, e.g. the seller's registration number in its own country. A seller identified by `id` needs the \"basic-wl\" profile or higher."
      } else {
        "Set `vat-id` or `legal-id` on the sender, e.g. `legal-id: id.siret(\"..\")` or `legal-id: id.register(\"HRB ..\", court: \"Amtsgericht ..\")`. A seller identified by `tax-nr` or `id` needs the \"basic-wl\" profile or higher."
      },
    )
  } else {
    (
      "The seller cannot be identified: neither a seller identifier (BT-29), a legal registration identifier (BT-30) nor a VAT identifier (BT-31) is given.",
      if f.represented {
        "The VAT identifier of the tax representative does not identify the seller. Set `id` or `legal-id` on the sender, e.g. the seller's registration number in its own country."
      } else if f.outside-scope {
        "An invoice not subject to VAT (O) states no VAT identifier (BR-O-02). Set `tax-nr`, `id` or `legal-id` on the sender."
      } else { "Set `vat-id`, `tax-nr`, `id` or `legal-id` on the sender." },
    )
  },
  "IP-PRINT-03": f => {
    let stated = ()
    if f.vat-id != none {
      stated.push("VAT identifier " + _quoted(f.vat-id) + " (BT-31)")
    }
    if f.tax-nr != none {
      stated.push("tax number " + _quoted(f.tax-nr) + " (BT-32)")
    }
    (
      "The e-invoice states the seller's "
        + stated.join(" and ")
        + ", but the printed invoice shows "
        + if stated.len() > 1 { "neither" } else { "it nowhere" }
        + ". The printed invoice and the e-invoice must state the same details, and the law requires the seller's tax number or VAT identifier on every invoice but a small-amount invoice (§ 14 Abs. 4 Satz 1 Nr. 2 UStG, § 33 UStDV; Art. 226 No. 3 of the VAT Directive).",
      "Print it with the reference signs: keep `references: auto`, use a preset such as `references.preset-b2b()`, or add `references.seller-vat-id()` or `references.seller-tax-nr()` to your references. The address and the `extra` details of the sender and the text of the invoice count as well. A page header or footer of your own (`set page(..)`) cannot be read: give such details as the `footer` of the theme, e.g. `themes.DIN-5008(footer: ..)`, whose text is not checked.",
    )
  },
  "IP-ID-01": f => (
    if type(f.problem) == str { f.problem } else { repr(f.problem) },
    if f.kind == "custom" {
      "Give the code of the scheme and the identifier, e.g. `id.custom(\"0208\", \"0123456749\")`."
    } else if f.scheme == none {
      "Give the register number, e.g. `id.register(\"HRB 4711\", court: \"Amtsgericht München\")`."
    } else {
      (
        "Check the identifier for typos. If it is right as it is, give it with `id.custom("
          + _quoted(f.scheme)
          + ", ..)`, which does not check it."
      )
    },
  ),
  "IP-ID-03": f => if f.misplaced == "routing" {
    (
      "A Leitweg-ID says where a public buyer receives its invoices; it does not identify the "
        + f.term
        + ", which `"
        + f.input
        + "` stands for.",
      "Give the Leitweg-ID as `leitweg-id` of the recipient (the buyer reference, BT-10) and, if the buyer is reached by it, as its `electronic-address`.",
    )
  } else if f.misplaced == "leitweg-id" {
    (
      "`leitweg-id` takes the Leitweg-ID of the buyer, but it is given "
        + _id-kinds.at(f.kind, default: "another identifier")
        + ".",
      "Give the Leitweg-ID with `id.leitweg(..)`, and the identifier of the buyer as `id`, `global-id` or `legal-id`.",
    )
  } else if f.misplaced == "party" {
    (
      "The identifier of the scheme "
        + _quoted(f.scheme)
        + " identifies a company or a location, but no official registrar issues it, so it is no legal registration identifier of the "
        + f.term
        + ".",
      "Give it as `global-id` (the "
        + f.term
        + " identifier), or with `id.custom("
        + _quoted(f.scheme)
        + ", ..)` if it is the registration the "
        + f.term
        + " is known by.",
    )
  } else {
    (
      "A register number is the legal registration identifier of the "
        + f.term
        + ", not its identifier, which `"
        + f.input
        + "` stands for.",
      if f.party == "delivery-address" {
        "The deliver-to location has no legal registration identifier: give its location identifier, e.g. `id.gln(..)`."
      } else { "Give it as `legal-id`." },
    )
  },
  "BR-CL-11": f => if _newer(lists.icd, f.scheme) {
    _not-yet(
      f,
      "The scheme "
        + _quoted(f.scheme)
        + " of the "
        + f.term
        + " legal registration identifier ("
        + f.bt
        + ")",
    )
  } else {
    (
      "The scheme "
        + _quoted(f.scheme)
        + " of the "
        + f.term
        + " legal registration identifier ("
        + f.bt
        + ") is not an ISO/IEC 6523 code.",
      "Use the constructor of the `id` module for the register, e.g. `id.siret(..)`, `id.register(..)` for a register without a scheme, or `id.custom(..)` with the ICD code of the register, e.g. \"0208\" for a Belgian enterprise number.",
    )
  },
  "vat-outside-scope": _outside-scope-representative,
  "IP-TAX-05": _outside-scope-representative,
  "BR-18": f => (
    "The name of the seller tax representative (BT-62) is missing.",
    "Set `name` on the tax representative.",
  ),
  "BR-56": f => (
    "The VAT identifier of the seller tax representative (BT-63) is missing.",
    if f.at("outside-scope", default: false) {
      "An invoice not subject to VAT (O) states no VAT identifiers: leave out `tax-representative` on invoices of items not subject to VAT."
    } else {
      "Set `vat-id` on the tax representative, the VAT identifier it holds for the seller, e.g. `vat-id: \"DE123456789\"`."
    },
  ),
  "IP-VAT-226": f => if f.kind == "address" {
    (
      "The postal address of the seller tax representative (BG-12) is missing, which the invoice must state by law (Art. 226 No. 15 of the VAT Directive 2006/112/EC).",
      "Set `address` and `city` on the tax representative.",
    )
  } else if f.kind == "legal-id" {
    (
      "A cross-border reverse charge (AE) must state the buyer VAT identifier (BT-48) by law (Art. 226 No. 4 of the VAT Directive 2006/112/EC); the legal registration identifier (BT-47) does not replace it.",
      "Set `vat-id` on the recipient.",
    )
  } else {
    (
      if f.category == "K" { _buyer-vat-id-terms.K.term } else {
        "A cross-border reverse charge (AE)"
      }
        + " must state the buyer VAT identifier (BT-48) by law (Art. 226 No. 4 of the VAT Directive 2006/112/EC).",
      "Set `vat-id` on the recipient. The BASIC WL profile has no invoice lines, so its validators do not check this.",
    )
  },
  "BR-17": _payee,
  "IP-PAY-05": _payee,
  "IP-ID-02": f => if f.kind == "id" {
    (
      if f.second == "global-id" {
        (
          "The global identifier of the "
            + f.term
            + " has no scheme, so it would be a second identifier next to `"
            + f.first
            + "`, and only one can be written."
        )
      } else {
        (
          "`"
            + f.first
            + "` and `"
            + f.second
            + "` give two different identifiers of the "
            + f.term
            + ", and only one can be written."
        )
      },
      if f.second == "global-id" {
        "Give the ISO/IEC 6523 scheme of the global identifier, e.g. `global-id: (scheme: \"0088\", id: ..)` for a GLN."
      } else { "`location-id` is another name of `id`: keep one of them." },
    )
  } else {
    (
      "`"
        + f.first
        + "` and `"
        + f.second
        + "` both give an identifier with scheme of the "
        + f.term
        + ", and only one can be written.",
      "Keep one of them, or give `id` without scheme.",
    )
  },
  "BR-CL-10": _global-id-scheme,
  "BR-CL-26": _global-id-scheme,
  "CII-SR-449": _single-identifier,
  "CII-SR-450": _single-identifier,
  "CII-SR-451": _single-identifier,
  "PEPPOL-EN16931-R020": _electronic-address,
  "PEPPOL-EN16931-R010": _electronic-address,
  // The message of the Peppol rules, so that `zugferd: auto` does not list
  // the missing address of a skipped XRechnung once more (see zugferd.typ).
  "IP-EADDR-01": f => {
    let (message, hint) = _electronic-address(f)
    (
      message,
      "EN 16931 leaves it optional, but a delivery over Peppol requires it, as XRechnung does. "
        + hint,
    )
  },
  "BR-62": _address-scheme,
  "BR-63": _address-scheme,
  "BR-CL-25": f => if f.fx-only {
    _factur-x-only(
      "The scheme " + _quoted(f.scheme) + " of the " + f.term,
      "Use another scheme, e.g. \"EM\" for an email address.",
    )
  } else if _newer(lists.eas, f.scheme) {
    _not-yet(f, "The scheme " + _quoted(f.scheme) + " of the " + f.term)
  } else {
    (
      "The scheme "
        + _quoted(f.scheme)
        + " of the "
        + f.term
        + " is not in the CEF EAS code list.",
      "Use e.g. \"EM\" for an email address or \"0088\" for a GLN.",
    )
  },
  "vat-buyer-id": f => {
    let terms = _buyer-vat-id-terms.at(f.category)
    (
      if f.holder == "line" {
        terms.term + " requires " + terms.required + "."
      } else {
        (
          "A document level "
            + if f.holder == "allowance" { "allowance (BG-20)" } else {
              "charge (BG-21)"
            }
            + " of the VAT category "
            + f.category
            + " requires "
            + terms.required
            + "."
        )
      },
      if f.category == "AE" {
        "Set `vat-id` on the recipient or, if the buyer has no VAT identifier (e.g. a domestic reverse charge), its `legal-id`, e.g. `legal-id: id.register(\"HRB 4711\", court: \"Amtsgericht München\")`."
      } else { "Set `vat-id` on the recipient." },
    )
  },
  "BR-IC-12": f => (
    "An intra-community supply (K) requires the deliver-to country (BT-80).",
    "Set `country` on the recipient or pass a `delivery-address`.",
  ),
  "IP-VAT-138": f => if f.kind == "deliver-to" {
    (
      "The intra-community supply (K) states "
        + if f.whose == "representative" {
          "the country of the seller's tax representative "
        } else { "the seller's own country " }
        + _quoted(f.home)
        + " as the deliver-to country (BT-80), but the goods must be dispatched to another member state.",
      "Set `country` on the delivery address or the recipient to the member state the goods are delivered to.",
    )
  } else {
    (
      "The buyer VAT identifier "
        + _quoted(f.vat-id)
        + " was not issued by an EU member state, so the supply is not an intra-community supply (K).",
      "Use `tax.export()` for supplies to countries outside the EU. Goods for Northern Ireland are intra-community supplies to an \"XI\" VAT identifier.",
    )
  },

  // Lines
  "BR-16": f => (
    "The invoice has no line items (BG-25).",
    "Add at least one `item` to `line-items`.",
  ),
  "BR-25": f => (
    "The item name (BT-153) has no text.",
    "Give the item a name that contains text.",
  ),
  "BR-CL-23": f => (
    "The unit code (BT-130) "
      + _quoted(f.code)
      + " is not a UN/ECE Recommendation 20 code.",
    "Use a unit from the `unit` module, e.g. `unit.hour`, or a dictionary such as `(display: \"Std.\", code: \"HUR\")`.",
  ),
  "IP-UNIT-02": f => (
    "The unit "
      + _quoted(f.text)
      + " has no UN/ECE Recommendation 20 code (BT-130) invoice-pro knows.",
    "Use a unit from the `unit` module, e.g. `unit.hour` or `unit.square-metre`, or give its code: `(display: "
      + _quoted(f.text)
      + ", code: \"..\")`, e.g. \"C62\" for a number of units.",
  ),
  "IP-UNIT-01": f => {
    let issue = f.issue
    (
      "The unit "
        + _quoted(issue.text)
        + " is written as the UN/ECE Recommendation 20 code for "
        + issue.meaning
        + ", although it is also a common abbreviation of \""
        + issue.abbreviation
        + "\".",
      "Give the code explicitly, e.g. `(display: "
        + _quoted(issue.text)
        + ", code: \"H87\")` for pieces, or `(display: .., code: "
        + _quoted(issue.text)
        + ")` if you mean the code.",
    )
  },
  "BR-CO-04": f => (
    "The item has no VAT category (BT-151).",
    "Set `tax` on the item, e.g. `tax.vat(19%)`.",
  ),
  "BR-30": f => (
    "The period of the item (BG-26) ends before it starts: "
      + _span(f.period)
      + ".",
    "Give the `date` of the item as `(start, end)`, the earlier date first.",
  ),
  "PEPPOL-EN16931-R110": _item-outside-period,
  "PEPPOL-EN16931-R111": _item-outside-period,
  "IP-PERIOD-02": _item-outside-period,
  "BR-CL-15": f => if f.fx-only {
    _factur-x-only(
      "The country of origin (BT-159) " + _quoted(f.code),
      "Give `origin` as the country the code stands for today.",
    )
  } else {
    (
      "The country of origin (BT-159) "
        + _quoted(f.code)
        + " is not in the ISO 3166-1 code list of EN 16931.",
      if f.code == "EL" { _country-hints.EL } else {
        "Give `origin` as a country of the `country` module (e.g. `country.de`) or an ISO 3166-1 code such as \"DE\"."
      },
    )
  },

  // VAT
  "BR-CO-18": f => (
    "The invoice has no VAT breakdown (BG-23).",
    "Add at least one `item` to `line-items`.",
  ),
  "BR-48": f => (
    "The VAT group of the category "
      + _quoted(f.category)
      + " has no VAT category rate (BT-119), which every VAT breakdown but one not subject to VAT (O) has.",
    _bug-hint,
  ),
  // A code the newest EN 16931 code list has withdrawn (see `code-finding`
  // of rare.typ).
  "IP-CODE-01": f => (
    (
      if f.scheme {
        "The scheme " + _quoted(f.code) + " of the " + f.term
      } else { "The " + f.term + " " + _quoted(f.code) }
    )
      + " was withdrawn from the newest version of the EN 16931 code list (1.3.16). The Factur-X validation of the "
      + f.profile
      + " profile still accepts it, but a validator with the current list, such as KoSIT, rejects the e-invoice.",
    if f.list == "currency" {
      "Invoice in the currency that replaced it, e.g. \"EUR\" for \"BGN\" and \"HRK\"."
    } else if f.scheme {
      "Use a current scheme, e.g. \"EM\" for an email address."
    } else { "Use a current code of the list." },
  ),
  "IP-DEC-01": f => (
    "The VAT rate "
      + fmt-number(f.percent, min-digits: 0, max-digits: 28)
      + "% has more than "
      + str(rate-digits)
      + " decimals, so the e-invoice would state it as "
      + _percent(f.rate)
      + if f.shared {
        (
          ", the rate of another VAT group"
            + if f.category != none { " of category " + f.category }
        )
      }
      + ".",
    "Round the rate to at most "
      + str(rate-digits)
      + " decimals, e.g. `tax.vat(8.125%)`.",
  ),
  "BR-CL-18": f => {
    let default-hint = "Use a constructor of the `tax` module such as `tax.vat(..)`, `tax.zero()` or `tax.exempt(..)`."
    let hint = if f.category == none { default-hint } else {
      _category-hints.at(f.category, default: default-hint)
    }
    if f.fx-only {
      (
        "The VAT category "
          + _quoted(f.category)
          + " is not in the code list of the Factur-X validation, although the code list of EN 16931 has it.",
        hint,
      )
    } else {
      (
        "The VAT category "
          + _quoted(f.category)
          + " is not allowed in "
          + _list-of(f)
          + " (allowed: S, Z, E, AE, K, G, O, L, M"
          + if f.at("xrechnung", default: false) { ", B" }
          + ").",
        hint,
      )
    }
  },
  "vat-rate-positive": f => (
    (
      S: "A standard rated VAT category (S)",
      L: "The IGIC category (L)",
      M: "The IPSI category (M)",
    ).at(f.category)
      + " needs a rate above 0%.",
    "Use `tax.zero()` for zero rated or `tax.exempt(grounds: ..)` for exempt items.",
  ),
  "vat-rate-zero": f => (
    "The VAT category " + f.category + " requires a rate of 0%.",
    "Use the matching constructor of the `tax` module, which sets the rate.",
  ),
  "BR-O-09": f => (
    "Items not subject to VAT (O) carry no VAT, so they have no rate.",
    "Use `tax.outside-scope()`, which has none.",
  ),
  "BR-E-10": f => (
    "Exempt items (E) need the VAT exemption reason (BT-120).",
    "State the legal reason, e.g. `tax.exempt(grounds: \"Steuerfrei nach § 4 Nr. 21 UStG\")`, and its VATEX code if you know it, e.g. `code: \"VATEX-EU-132-1G\"`.",
  ),
  "BR-CL-22": f => if _newer(lists.vatex, f.code) {
    _not-yet(f, "The VAT exemption reason code (BT-121) " + _quoted(f.code))
  } else {
    (
      "The VAT exemption reason code (BT-121) "
        + _quoted(f.code)
        + " is not a code of the VATEX code list.",
      "Use a code of the CEF VATEX list, e.g. \"VATEX-EU-132-1A\" for an exemption of Art. 132 (1) (a) of the VAT Directive, or leave out `code`: the grounds are stated as text (BT-120).",
    )
  },
  "BR-B-01": f => (
    "The split payment (B) is for domestic Italian invoices, but the "
      + f.term
      + " is "
      + _quoted(f.country)
      + ".",
    "Use split payment (`tax.special.transferred(..)`) only between parties in Italy, and `tax.vat(..)` otherwise.",
  ),
  "BR-B-02": f => (
    "An invoice with split payment (B) cannot have standard rated (S) items, allowances or charges.",
    "Invoice the standard rated items in an invoice of their own.",
  ),
  "IP-TAX-02": f => {
    let taxed = f.category in ("S", "Z", "L", "M")
    (
      "The VAT exemption reason code (BT-121) "
        + _quoted(f.code)
        + if taxed {
          (
            " cannot be stated for the VAT category "
              + f.category
              + ", which is not exempt: it has no exemption reason."
          )
        } else {
          (
            " is a code of the VAT category "
              + f.fits
              + ", not of "
              + f.category
              + ", so the e-invoice would state another reason than its category."
          )
        },
      if taxed { "Leave out `code`." } else {
        "Use the constructor of the `tax` module that fits the code, e.g. `tax.intra-community()` for \"VATEX-EU-IC\" or `tax.exempt(code: ..)` for an exemption, or leave out `code`."
      },
    )
  },
  "IP-TAX-03": f => (
    "The items of the VAT category "
      + f.category
      + " give the VAT exemption reason codes "
      + f.codes.map(_quoted).join(", ")
      + ", but the e-invoice states one code (BT-121) per VAT category and rate, so it states the reasons as text only (BT-120).",
    "Give the items of one VAT category and rate the same `code`, or invoice them separately.",
  ),
  "IP-TAX-04": f => (
    "Exempt items (E) with the VAT exemption reason code "
      + _quoted(f.code)
      + " (BT-121) need the exemption reason as text as well: the printed invoice states why no VAT is charged (§ 14 Abs. 4 Satz 1 Nr. 8 UStG, Art. 226 No. 11 of the VAT Directive).",
    "State the legal reason next to the code, e.g. `tax.exempt(grounds: \"Steuerfrei nach § 4 Nr. 14 UStG\", code: \"VATEX-EU-132-1C\")`.",
  ),
  "vat-seller-id": f => (
    _holders.at(f.holder)
      + " with the VAT category "
      + f.categories.join(", ")
      + " require the seller VAT identifier (BT-31), its tax number (BT-32) or the VAT identifier of its tax representative (BT-63).",
    "Set `vat-id` or `tax-nr` on the sender. A seller registered for VAT through a fiscal representative names it with `tax-representative: (name: .., address: .., city: .., country: .., vat-id: ..)` on the sender instead: the representative's VAT identifier is not the seller's `vat-id`.",
  ),
  "vat-seller-vat-id": f => (
    (
      K: "An intra-community supply (K)",
      G: "An export outside the EU (G)",
    ).at(f.category)
      + " requires the seller VAT identifier (BT-31) or the VAT identifier of its tax representative (BT-63).",
    "Set `vat-id` on the sender. A seller registered for VAT through a fiscal representative names it with `tax-representative: (name: .., address: .., city: .., country: .., vat-id: ..)` on the sender instead: the representative's VAT identifier is not the seller's `vat-id`.",
  ),
  "BR-IC-11": f => (
    "An intra-community supply (K) requires the date of the supply (BT-72) or the invoicing period (BG-14), which the e-invoice does not state without dates, as "
      + _undated-reason(f.document)
      + ".",
    "Set `service-period` to the date or period of the supply the document refers to, e.g. the one of the preceding invoice, or give the items their `date`.",
  ),
  "BR-O-11": f => (
    "Items not subject to VAT (O) cannot be combined with other VAT categories ("
      + f.others.join(", ")
      + ") on one invoice.",
    "Invoice the items outside the scope of VAT separately.",
  ),

  // Payment
  "BR-CO-25": f => (
    "An amount is due, but neither the payment due date (BT-9) nor the payment terms (BT-20) are given.",
    "Add `#payment-goal(days: 14)` or set `due-date` on the invoice.",
  ),
  "BR-DE-23-b": _several-means,
  "BR-DE-24-b": _several-means,
  "CII-SR-467": _several-means,
  "IP-PAY-03": _several-means,
  "BR-DE-23-a": _transfer-account,
  "CII-SR-470": _transfer-account,
  "IP-PAY-04": _transfer-account,
  "BR-DE-19": _iban,
  "BR-DE-20": _iban,
  "IP-PAY-01": _iban,
  "BR-DE-25-a": _paid-direct-debit,
  "PEPPOL-EN16931-R061": f => if f.paid { _paid-direct-debit(f) } else {
    (
      "XRechnung requires the mandate reference (BT-89) of a direct debit.",
      "Set `mandate` on `direct-debit` to the reference of the direct debit mandate.",
    )
  },
  "BR-CL-16": f => (
    "The payment means code (BT-81) "
      + _quoted(f.code)
      + " is not in the UNTDID 4461 code list.",
    "Use a code of UNTDID 4461, e.g. \"10\" for cash or \"97\" for a clearing between partners, or one of the methods of `paid`, e.g. `\"cash\"`.",
  ),
  "IP-PAY-02": f => (
    "The creditor identifier (BT-90) "
      + _quoted(f.creditor-id)
      + " is not a valid SEPA creditor identifier (wrong check digits or format).",
    "Check the creditor identifier for typos, e.g. \"DE98ZZZ09999999999\".",
  ),
  "IP-PREPAID-01": f => (
    "The prepaid amount (BT-113) exceeds the invoice total, so the amount due (BT-115) is negative.",
    none,
  ),

  // Consistency
  "IP-DEC-02": f => {
    let excess = f.excess
    (
      "An e-invoice states amounts with 2 decimals, but "
        + if excess.count == 1 { "the " } else {
          str(excess.count) + " amounts have more, e.g. the "
        }
        + excess.term
        + if excess.place != none { " of " + excess.place }
        + " is "
        + str(excess.value)
        + if f.by-currency {
          (
            ": the invoice currency "
              + _quoted(f.currency)
              + " has "
              + str(f.decimals)
              + " decimals"
          )
        }
        + ".",
      if f.by-currency {
        (
          "EN 16931 and the Factur-X profiles state no amounts with more than 2 decimals. Create this invoice without e-invoice (`zugferd: none`), or round its amounts to 2 decimals with a locale of your own instead of `currency`, e.g. `locale: locale.en-de.with((region: (currency: (code: "
            + _quoted(f.currency)
            + ", symbol: "
            + _quoted(f.currency)
            + ", decimals: 2))))`."
        )
      } else {
        "Round money to 2 decimals in the locale, e.g. `locale.custom.normalize(money: x => calc.round(x, digits: 2))`."
      },
    )
  },
  "PEPPOL-EN16931-R120": f => (
    "The line net amount (BT-131) "
      + str(f.net)
      + " is not the quantity "
      + fmt-number(f.quantity, min-digits: 0, max-digits: 6)
      + " times the net price "
      + fmt-number(f.price, min-digits: 0, max-digits: 12)
      + if f.base-quantity != 1 {
        " per " + fmt-number(f.base-quantity, min-digits: 0, max-digits: 6)
      } else { "" }
      + " plus the line's charges minus its allowances ("
      + fmt-number(f.expected, min-digits: 2, max-digits: 6)
      + "): XRechnung allows a difference of "
      + str(f.slack)
      + ".",
    "The line total is rounded to the decimals of the currency: give a price that the quantity turns into an amount of the currency (e.g. whole yen for a currency without decimals).",
  ),
)
