// The checks of the e-invoice validation: the business rules of EN 16931,
// the Factur-X profiles and XRechnung, and the rules of invoice-pro itself
// (IP-*: the official rules accept the XML, but the invoice would be wrong),
// which the data model must satisfy before its XML is written. The metadata
// of every rule is in tools/zugferd/registry.json.
//
// A check that fails records a finding `(key: .., field: .., ..values)`: the
// key of the rule's entry, the input field to name, `id` where the entry
// reports several ids, `level` where it has two, and the values its message
// needs. Checks of inputs most invoices do not give are in rare.typ, those
// of XRechnung in xrechnung.typ; the messages in messages.typ and
// xrechnung-messages.typ. All of them load only when an invoice needs them.
//
// A diagnostic is `(level: "error" | "warning", rule: .., field: ..,
// message: .., hint: .. | none)`, errors first, each level in the order of
// the checks.

#import "../code-lists.typ": lists
#import "../xml.typ": fmt-number, rate-digits
#import "../model.typ": profile-terms, vat-id-country, vat-id-prefix
#import "../../utils/iban.typ": iban-valid

#let _zero = decimal("0")

/// A value in quotes for a message, e.g. `"DE"`, or "(none)".
///
/// -> str
#let quoted(value) = if value == none { "(none)" } else {
  "\"" + str(value) + "\""
}

/// Whether `code` is in a code list of code-lists.typ: a string of codes,
/// each between two spaces.
///
/// -> bool
#let in-list(list, code) = (
  type(code) == str
    and code != ""
    and not code.contains(" ")
    and (" " + code + " ") in list
)

// The lists of the checks, one by one: a check captures (and Typst hashes)
// only the lists it names.
#let _countries = lists.country.every
#let _currencies = lists.currency.every
#let _factur-x-currencies = lists.currency.factur-x
#let _eas-codes = lists.eas.every
#let _icd-codes = lists.icd.every
#let _units = lists.unit.every
#let _vat-categories = lists.vat-category.every
#let _means-codes = lists.payment-means.every

// A rate in percent as the XML states it, e.g. "19%" or "9.975%".
#let _percent(rate) = (
  fmt-number(rate * 100, min-digits: 0, max-digits: rate-digits) + "%"
)

/// The input field of an invoice line, e.g. `item 2 (Consulting)`.
///
/// -> str
#let line-field(line) = {
  "item " + line.id + if line.name != none { " (" + line.name + ")" }
}

/// The input field of a VAT group, e.g. `tax S 19%`.
///
/// -> str
#let tax-field(tax) = {
  (
    "tax "
      + if tax.category != none { tax.category + " " }
      + if tax.rate == none { "(no rate)" } else { _percent(tax.rate) }
  )
}

/// IP-PROFILE-01: an input the profile has no business term for, which is
/// therefore not written into the e-invoice. `lowest` is the lowest profile
/// that states it; `inputs` names several inputs in the message.
///
/// -> dictionary
#let not-carried(profile, field, term, lowest, inputs: none) = (
  key: "IP-PROFILE-01",
  field: field,
  profile: profile.name,
  term: term,
  lowest: lowest,
  inputs: inputs,
)

// --- Document -------------------------------------------------------------

// The characters of a printed amount besides its currency: digits,
// separators, signs and spaces. The samples are plain text, whose spaces and
// minus signs are ASCII; the typographic apostrophe (a thousands separator)
// is removed separately. (ASCII only: a class with other characters, or a
// Unicode class such as `\d` or `\s`, takes a fraction of a millisecond to
// compile on every compile.)
#let _amount-characters = regex("[0-9 .,'+\\-()]")

#let _document(model) = {
  let out = ()
  if model.invoice.number == none {
    out.push((key: "BR-02", field: "invoice-nr"))
  }
  let date = model.invoice.issue-date
  if type(date) != datetime or date.year() == none {
    out.push((key: "BR-03", field: "date"))
  }
  // The invoice's `currency`, or the locale.
  let currency-field = model.at("currency-field", default: "locale")
  let currency = model.currency
  if currency == none {
    out.push((key: "BR-05", field: "locale"))
  } else if not in-list(_currencies, currency) {
    import "rare.typ": currency-code
    out += currency-code(currency, currency-field, model.profile)
  }

  // IP-TAX-01: `tax: none` prints 0%, but does not say why no VAT is charged:
  // zero rated, exempt or not subject to VAT. An e-invoice must say it with
  // the VAT category of every item (BT-151).
  let implicit = 0
  for line in model.lines {
    if line.at("implicit", default: false) { implicit += 1 }
  }
  let implicit-group = false
  for tax in model.taxes {
    if tax.at("implicit", default: false) { implicit-group = true }
  }
  if implicit > 0 or implicit-group {
    out.push((key: "IP-TAX-01", field: "tax", count: implicit))
  }

  // IP-PRINT-02: the invoice prints its amounts in the currency the XML
  // states: with its code or the symbol of the locale, and not with "€" for
  // another currency. Unit prices may be printed in a subunit instead (e.g.
  // "ct" for energy tariffs), but not with "€" for another currency either.
  // A formatter that prints no currency says nothing else.
  let printed = model.at("printed-currency", default: none)
  if (
    type(currency) == str
      and in-list(_factur-x-currencies, currency)
      and type(printed) == dictionary
  ) {
    for (kind, sample) in (
      ("amounts", printed.at("amount", default: none)),
      ("unit prices", printed.at("price", default: none)),
    ) {
      if sample == none { continue }
      let sign = sample.replace(_amount-characters, "").replace("’", "")
      if sign == "" { continue }
      let euro = sample.contains("€") and currency != "EUR"
      let states = (
        sample.contains(currency)
          or printed.symbol != none and sample.contains(printed.symbol)
      )
      if not euro and (states or kind == "unit prices") { continue }
      out.push((
        key: "IP-PRINT-02",
        field: "locale",
        kind: kind,
        sign: sign,
        sample: sample,
        currency: currency,
      ))
      break
    }
  }
  out
}

// --- Document type --------------------------------------------------------

// The document type (BT-3): that the title of the document does not name
// another kind of document (IP-DOC-01), that the profile allows the type
// (BR-DE-17), and that the amounts have the sign of the type.
#let _document-type(model) = {
  let invoice = model.invoice
  let document = invoice.at("document", default: none)
  if type(document) != dictionary { return () }
  let out = ()
  let code = invoice.type-code

  // IP-DOC-01: the title of a document without `document-type` names another
  // kind of document than the invoice (BT-3 = 380) the e-invoice states,
  // e.g. "Gutschrift": the e-invoice would ask the buyer to pay a credit
  // note. Without a title (the sender sets no `subject`, and the locale
  // titles an invoice as its language does) there is nothing to check, and
  // document.typ does not load.
  if document.input == auto and invoice.title != none {
    import "../document.typ": title-kind
    let named = title-kind(invoice.title)
    if named != none and named.kind != "invoice" {
      out.push((
        key: "IP-DOC-01",
        field: "subject",
        kind: named.kind,
        title: invoice.title,
        code: document.code,
      ))
    }
  }

  if model.profile.xrechnung {
    import "xrechnung.typ": document-type
    out += document-type(code)
  }

  // The preceding invoice reference (BG-3), from BASIC WL on, is written
  // with its number (BT-25) only: a date (BT-26) without it would be lost
  // (IP-DOC-05). A document that amends an invoice must refer to it (Art.
  // 219 of the VAT Directive): XRechnung checks it as BR-DE-26, which it
  // only warns about, but validators such as Mustang reject the invoice.
  if model.profile.document-references {
    let number = invoice.at("preceding-invoice-nr", default: none)
    if (
      number == none
        and invoice.at("preceding-invoice-date", default: none) != none
    ) {
      out.push((key: "IP-DOC-05", field: "preceding-invoice-nr"))
    } else if number == none and code == "384" {
      out.push((
        key: if model.profile.xrechnung { "BR-DE-26" } else { "IP-DOC-02" },
        field: "preceding-invoice-nr",
        code: code,
      ))
    }
  }

  // A credit note states the credited amounts as positive amounts: a
  // negative credit note asks the buyer to pay (IP-DOC-03). An invoice with
  // a negative total is valid, but a credit note is the document for it.
  let gross = model.totals.gross
  if gross < _zero {
    out.push((
      key: if document.credit { "IP-DOC-03" } else { "IP-DOC-04" },
      field: "line-items",
      code: code,
      gross: gross,
    ))
  }
  out
}

// --- Document data --------------------------------------------------------

// The data of the document besides its type: the notes (BT-21, BT-22), the
// project reference (BT-11), and that the service period the invoice prints
// is the one the XML states (IP-PERIOD-01).
#let _document-data(model) = {
  let out = ()
  let profile = model.profile

  // The notes are printed in any case, but only BASIC WL and the richer
  // profiles can state them.
  let notes = model.invoice.at("notes", default: ())
  if notes.len() > 0 and not profile.notes {
    out.push(not-carried(profile, "notes", "invoice notes (BT-22)", "basic-wl"))
  }
  // The project reference (BT-11) exists in EN 16931 and XRechnung only.
  if (
    model.invoice.at("project", default: none) != none
      and not profile.procuring-project
  ) {
    out.push(not-carried(
      profile,
      "project",
      "the project reference (BT-11)",
      "en16931",
    ))
  }
  // MINIMUM states neither the service period (BT-72, BG-14) nor the
  // preceding invoice (BG-3), which exist from BASIC WL on.
  if (
    not profile.settlement
      and model.at("delivery", default: (:)).at("source", default: none)
        == "invoice"
  ) {
    out.push(not-carried(
      profile,
      "service-period",
      "the service period (BT-72, BG-14)",
      "basic-wl",
    ))
  }
  if not profile.document-references {
    let given = ()
    for key in ("preceding-invoice-nr", "preceding-invoice-date") {
      if model.invoice.at(key, default: none) != none { given.push(key) }
    }
    if given.len() > 0 {
      out.push(not-carried(
        profile,
        given.first(),
        "the preceding invoice reference (BG-3)",
        "basic-wl",
        inputs: if given.len() > 1 { given },
      ))
    }
  }
  if profile.notes {
    for note in notes {
      if note.subject-code != none {
        import "rare.typ": note-subject-code
        out += note-subject-code(note.subject-code, profile)
      }
    }
  }

  // IP-PERIOD-01: the service period the invoice prints is the one the XML
  // states (BT-72 or BG-14). Another date or period (e.g.
  // `references.service-time(value: datetime(..))`) contradicts it, and so
  // does a text of its own (e.g. `references.service-time(value: "Juni
  // 2026")`) when the XML states the invoice date for want of any date. A
  // text of its own besides dates of the items or the invoice's
  // `service-period` may name the same period in other words: a warning.
  // The delivery information exists from BASIC WL on.
  let delivery = model.at("delivery", default: (:))
  let printed = delivery.at("printed", default: none)
  let stated = delivery.at("text", default: none)
  let source = delivery.at("source", default: none)
  let term = if delivery.at("period", default: none) != none { "BG-14" } else {
    "BT-72"
  }
  // A credit note or a prepayment invoice without dates states none (see
  // `service-period-of`): a date printed there is missing from the
  // e-invoice, a text of its own may be a warning only.
  let document = model.invoice.at("document", default: none)
  if profile.settlement and printed != none and printed != stated {
    let own = delivery.at("printed-own", default: true)
    let contradicts = not own or source == "invoice-date"
    out.push((
      key: "IP-PERIOD-01",
      level: if contradicts { "error" } else { "warning" },
      field: "references",
      printed: printed,
      stated: stated,
      source: source,
      term: term,
      contradicts: contradicts,
      document: document,
    ))
  }

  // BR-DE-TMP-32 (information in the XRechnung 3.0 Schematron): an invoice
  // states the date of the supply (BT-72, BG-14, or BG-26 on every line).
  // An invoice without dates states its invoice date; a credit note, whose
  // own date is not the date of the supply, states none (see
  // `service-period-of`), so it needs the date of the supply it credits.
  if (
    profile.xrechnung
      and delivery.at("date", default: none) == none
      and delivery.at("period", default: none) == none
  ) {
    out.push((
      key: "BR-DE-TMP-32",
      field: "service-period",
      document: document,
    ))
  }

  // IP-PERIOD-03: the printed invoice shows the date of the supply, see
  // `period-shown` of rare.typ.
  if delivery.at("shown", default: none) == false {
    import "rare.typ": period-shown
    out += period-shown(model, stated, term, document)
  }
  out
}

// --- Parties --------------------------------------------------------------

/// The country of a party (`rule`: missing, a safety net: an address
/// without `country` has the one of the locale) and its code list
/// (BR-CL-14, see `country-code` of rare.typ).
///
/// -> array
#let country(code, rule, field, term, profile) = {
  if code == none { return ((key: rule, field: field, term: term),) }
  if in-list(_countries, code) { return () }
  import "rare.typ": country-code
  country-code(code, field, term, profile)
}

/// IP-COUNTRY-01: a party without `country` is in the country of the
/// locale. If the VAT ID it states was issued by another country, that
/// default is most likely wrong. An explicit `country` always settles it,
/// e.g. for a foreign VAT registration.
///
/// -> array
#let country-of-vat-id(party, field, term, bt) = {
  let address = party.address
  if (
    address.at("country-explicit", default: true) or address.country == none
  ) { return () }
  let vat-id = party.at("stated-vat-id", default: party.vat-id)
  let issuer = vat-id-country(vat-id)
  if issuer == none or issuer == address.country { return () }
  (
    (
      key: "IP-COUNTRY-01",
      field: field + ".country",
      party: field,
      term: term,
      bt: bt,
      country: address.country,
      vat-id: vat-id,
      issuer: issuer,
    ),
  )
}

// Patterns of rare checks, compiled once on first use.
#let _post-code-digits() = regex("[0-9]{3,}")

/// IP-ADDR-01: a city line whose post code the parser of the party's
/// country does not recognize stays whole: the post code is missing, and
/// the number is written into the city name.
///
/// -> array
#let post-code(party, field, term, city-bt, code-bt) = {
  let address = party.address
  if (
    address.post-code != none
      or address.city == none
      or address.country == none
      or address.city.match(_post-code-digits()) == none
  ) { return () }
  (
    (
      key: "IP-ADDR-01",
      field: field + ".city",
      party: field,
      term: term,
      city: address.city,
      country: address.country,
      city-bt: city-bt,
      code-bt: code-bt,
    ),
  )
}

// `rules`: the rule for a missing address and the rule for a missing scheme.
// `required`: the level of a missing address, or `none`. `represented`: the
// party is a seller with a tax representative, whose VAT identifier is not
// the seller's `vat-id` (nor its address).
#let _electronic-address(
  party,
  required,
  rules,
  field,
  term,
  profile,
  represented: false,
  reference: none,
) = {
  let (missing-rule, scheme-rule) = rules
  let address = party.electronic-address
  if address == none or address.id == none {
    if required == none { return () }
    return (
      (
        key: missing-rule,
        level: required,
        field: field,
        term: term,
        vat-id: party.at("stated-vat-id", default: none),
        represented: represented,
        reference: reference,
      ),
    )
  }
  if address.scheme == none {
    return (
      (
        key: scheme-rule,
        field: field + ".electronic-address",
        term: term,
        address: address.id,
      ),
    )
  }
  if in-list(_eas-codes, address.scheme) { return () }
  import "rare.typ": address-scheme
  address-scheme(address.scheme, field, term, profile)
}

/// The input key a party identifier came from (see `id-keys` and
/// `global-id-keys` of the model), for the field of a diagnostic.
///
/// -> str
#let id-key(party, slot) = {
  party.at(slot + "-keys", default: ()).first(default: slot)
}

/// The scheme of the global identifier of a party. `rule`: BR-CL-10 for the
/// seller, buyer and payee, BR-CL-26 for the ship-to party.
///
/// -> array
#let global-id(party, rule, field, profile) = {
  let global-id = party.at("global-id", default: none)
  if (
    global-id == none
      or global-id.scheme == none
      or in-list(_icd-codes, global-id.scheme)
  ) { return () }
  import "rare.typ": global-id-scheme
  let field = field + "." + id-key(party, "global-id")
  global-id-scheme(global-id.scheme, rule, field, profile)
}

/// IP-ID-02: two different values for one identifier of a party, of which
/// only one can be written: a `global-id` without scheme next to `id`, a
/// `location-id` next to `id` of the delivery address, or two identifiers
/// with scheme.
///
/// -> array
#let identifiers(party, field, term) = {
  let out = ()
  let id-keys = party.at("id-keys", default: ())
  if id-keys.len() > 1 {
    let (first, second, ..) = id-keys
    out.push((
      key: "IP-ID-02",
      field: field + "." + second,
      kind: "id",
      first: first,
      second: second,
      term: term,
    ))
  }
  let global-id-keys = party.at("global-id-keys", default: ())
  if global-id-keys.len() > 1 {
    out.push((
      key: "IP-ID-02",
      field: field + "." + global-id-keys.at(1),
      kind: "global-id",
      first: global-id-keys.at(0),
      second: global-id-keys.at(1),
      term: term,
    ))
  }
  out
}

/// The buyer (BT-46), the deliver-to location (BT-71) and the payee (BT-60)
/// have one identifier: either `ram:ID` or `ram:GlobalID` (CII-SR-450,
/// CII-SR-449, CII-SR-451).
///
/// -> array
#let single-identifier(party, rule, field, term) = {
  if (
    party.at("id", default: none) == none
      or party.at("global-id", default: none) == none
  ) { return () }
  (
    (
      key: rule,
      field: field,
      term: term,
      id-key: id-key(party, "id"),
      global-id-key: id-key(party, "global-id"),
    ),
  )
}

/// BR-CO-09: a VAT identifier starts with a country prefix.
///
/// -> array
#let vat-id-prefix-check(vat-id, field) = {
  if vat-id == none { return () }
  let prefix = vat-id-prefix(vat-id)
  if (
    prefix != none
      and (
        in-list(_countries, prefix) or prefix in ("EL", "1A", "AN")
      )
  ) {
    return ()
  }
  ((key: "BR-CO-09", field: field, vat-id: vat-id),)
}

/// BR-CL-11: the scheme of a legal registration identifier (BT-30, BT-47,
/// BT-61) is an ISO/IEC 6523 ICD code. Without a scheme it is stated as it
/// is.
///
/// -> array
#let legal-id(party, field, term, bt, profile) = {
  let legal-id = party.at("legal-id", default: none)
  if (
    legal-id == none
      or legal-id.scheme == none
      or in-list(_icd-codes, legal-id.scheme)
  ) { return () }
  import "rare.typ": legal-id-scheme
  legal-id-scheme(legal-id.scheme, field, term, bt, profile)
}

#let _parties(model) = {
  let profile = model.profile
  let seller = model.seller
  let buyer = model.buyer
  let ship-to = model.ship-to
  let out = ()

  if seller.name == none { out.push((key: "BR-06", field: "sender.name")) }
  if buyer.name == none { out.push((key: "BR-07", field: "recipient.name")) }

  // Keys a party dictionary does not know (see `input-keys` of the model).
  for (party, field, term) in (
    (seller, "sender", "sender"),
    (buyer, "recipient", "recipient"),
    (ship-to, "delivery-address", "delivery address"),
  ) {
    if party != none and party.at("input-keys", default: ()) != () {
      import "rare.typ": input-keys
      out += input-keys(party, field, term)
    }
  }

  // The seller country (BT-40) is written in every profile, the other
  // addresses from BASIC WL on.
  out += country(
    seller.address.country,
    "BR-09",
    "sender.country",
    "seller country code (BT-40)",
    profile,
  )
  out += country-of-vat-id(seller, "sender", "seller", "BT-40")
  if profile.addresses {
    out += country(
      buyer.address.country,
      "BR-11",
      "recipient.country",
      "buyer country code (BT-55)",
      profile,
    )
    out += country-of-vat-id(buyer, "recipient", "buyer", "BT-55")
    if ship-to != none {
      out += country(
        ship-to.address.country,
        "BR-57",
        "delivery-address.country",
        "deliver-to country code (BT-80)",
        profile,
      )
    }
    out += post-code(seller, "sender", "seller", "BT-37", "BT-38")
    out += post-code(buyer, "recipient", "buyer", "BT-52", "BT-53")
    // Without a delivery address of its own, the buyer's address is checked.
    if ship-to != none and not ship-to.at("from-buyer", default: false) {
      out += post-code(
        ship-to,
        "delivery-address",
        "deliver-to",
        "BT-77",
        "BT-78",
      )
    }
  }

  out += vat-id-prefix-check(seller.vat-id, "sender.vat-id")
  if profile.buyer-vat-id {
    out += vat-id-prefix-check(buyer.vat-id, "recipient.vat-id")
  }

  // BR-CO-26: the buyer must be able to identify the seller. The VAT
  // identifier of a tax representative (BT-63) does not identify the seller.
  let seller-legal-id = seller.at("legal-id", default: none)
  let represented = model.at("tax-representative", default: none) != none
  if profile.id == "minimum" {
    // MINIMUM states neither `ram:ID` nor `ram:GlobalID` of the seller.
    if seller.vat-id == none and seller-legal-id == none {
      out.push((
        key: "BR-CO-26",
        field: "sender",
        minimum: true,
        represented: represented,
      ))
    }
  } else if (
    seller.id == none
      and seller.global-id == none
      and seller-legal-id == none
      and seller.vat-id == none
  ) {
    out.push((
      key: "BR-CO-26",
      field: "sender",
      minimum: false,
      represented: represented,
      outside-scope: model.outside-scope,
    ))
  }

  // IP-PRINT-03: the printed invoice shows the seller's VAT ID or tax number
  // the XML states (BT-31, BT-32), one of which the law requires on the
  // invoice (§ 14 Abs. 4 Satz 1 Nr. 2 UStG; Art. 226 No. 3 of the VAT
  // Directive). Only known for a theme that prints the references and no
  // content of its own on every page, see `logic/printed.typ`.
  if seller.at("printed-tax-id", default: none) == false {
    out.push((
      key: "IP-PRINT-03",
      field: "references",
      vat-id: seller.vat-id,
      tax-nr: seller.tax-nr,
    ))
  }

  // Identifiers of the `id` module, legal registration identifiers
  // (BT-30, BT-47) and the details only some profiles state.
  for (party, field, term) in (
    (seller, "sender", "seller"),
    (buyer, "recipient", "buyer"),
    (ship-to, "delivery-address", "deliver-to location"),
  ) {
    if party != none and party.at("typed-ids", default: ()) != () {
      import "rare.typ": typed-ids
      out += typed-ids(party, field, term)
    }
  }
  out += legal-id(seller, "sender", "seller", "BT-30", profile)
  out += legal-id(buyer, "recipient", "buyer", "BT-47", profile)
  for (party, key, field, term, carried, lowest) in (
    (
      seller,
      "trading-name",
      "sender.trading-name",
      "the seller trading name (BT-28)",
      profile.seller-trading-name,
      "basic-wl",
    ),
    (
      seller,
      "legal-info",
      "sender.legal-info",
      "the additional legal information of the seller (BT-33)",
      profile.seller-legal-info,
      "en16931",
    ),
    (
      buyer,
      "trading-name",
      "recipient.trading-name",
      "the buyer trading name (BT-45)",
      profile.buyer-trading-name,
      "en16931",
    ),
  ) {
    if not carried and party.at(key, default: none) != none {
      out.push(not-carried(profile, field, term, lowest))
    }
  }
  if (
    model.at("tax-representative", default: none) != none
      or model.at("payee", default: none) != none
  ) {
    import "rare.typ": payee, tax-representative
    out += tax-representative(model)
    out += payee(model)
  }

  // Party identifiers (BT-29, BT-46) from BASIC WL on; the ship-to party
  // (BT-71) with the delivery information.
  if profile.party-ids {
    out += identifiers(seller, "sender", "seller")
    out += identifiers(buyer, "recipient", "buyer")
    out += global-id(seller, "BR-CL-10", "sender", profile)
    out += global-id(buyer, "BR-CL-10", "recipient", profile)
    if profile.en16931 {
      out += single-identifier(
        buyer,
        "CII-SR-450",
        "recipient",
        "buyer identifier (BT-46)",
      )
    }
  }
  if profile.addresses and ship-to != none {
    out += identifiers(ship-to, "delivery-address", "delivery address")
    out += global-id(ship-to, "BR-CL-26", "delivery-address", profile)
    if profile.en16931 {
      out += single-identifier(
        ship-to,
        "CII-SR-449",
        "delivery-address",
        "deliver-to location identifier (BT-71)",
      )
    }
  }

  if profile.addresses {
    // Required by XRechnung (PEPPOL-EN16931-R020, R010); EN 16931 leaves
    // them optional, but a delivery over Peppol needs them (IP-EADDR-01).
    let (required, seller-rule, buyer-rule) = if profile.xrechnung {
      ("error", "PEPPOL-EN16931-R020", "PEPPOL-EN16931-R010")
    } else if profile.id == "en16931" {
      ("warning", "IP-EADDR-01", "IP-EADDR-01")
    } else { (none, none, none) }
    out += _electronic-address(
      seller,
      required,
      (seller-rule, "BR-62"),
      "sender",
      "seller electronic address (BT-34)",
      profile,
      represented: represented,
    )
    out += _electronic-address(
      buyer,
      required,
      (buyer-rule, "BR-63"),
      "recipient",
      "buyer electronic address (BT-49)",
      profile,
      reference: model.invoice.at("buyer-reference", default: none),
    )
  }

  if profile.xrechnung {
    import "xrechnung.typ": parties
    out += parties(model)
  }

  // The buyer of an intra-community supply (K) or a reverse charge (AE),
  // see `buyer-vat-id` and `intra-community` of rare.typ.
  if profile.settlement {
    let intra-or-reverse = false
    for tax in model.taxes {
      if tax.category in ("K", "AE") {
        intra-or-reverse = true
        break
      }
    }
    if intra-or-reverse {
      import "rare.typ": buyer-vat-id, intra-community
      out += buyer-vat-id(model)
      out += intra-community(model)
    }
  }
  out
}

// --- Lines ----------------------------------------------------------------

#let _lines(model) = {
  if not model.profile.lines { return () }
  let out = ()
  if model.lines.len() == 0 {
    out.push((key: "BR-16", field: "line-items"))
  }
  // Whether a unit code is in the code list, by code: most lines share one.
  let units = (:)
  for line in model.lines {
    if line.name == none {
      out.push((key: "BR-25", field: line-field(line)))
    }
    let code = line.unit-code
    let known = if type(code) == str and code != "" {
      let seen = units.at(code, default: none)
      if seen == none {
        seen = in-list(_units, code)
        units.insert(code, seen)
      }
      seen
    } else { false }
    let unit-issue = line.at("unit-issue", default: none)
    if not known {
      out.push((key: "BR-CL-23", field: line-field(line), code: code))
    } else if unit-issue != none and unit-issue.kind == "unknown" {
      // IP-UNIT-02: a text invoice-pro does not know has no unit code, and
      // "one" (C62) would be a guess.
      out.push((
        key: "IP-UNIT-02",
        field: line-field(line),
        text: unit-issue.text,
      ))
    } else if unit-issue != none and unit-issue.kind == "ambiguous" {
      out.push((key: "IP-UNIT-01", field: line-field(line), issue: unit-issue))
    }
    // BR-CO-04, a safety net: `tax: none` is zero rated (IP-TAX-01). (A
    // price base quantity is above 0: `item` and `bundle` stop on any other.)
    if line.key == none or line.category == none {
      out.push((key: "BR-CO-04", field: line-field(line)))
    }
  }
  // PEPPOL-EN16931-R120, which only the XRechnung Schematron checks: a line
  // total rounded more coarsely than its price (xrechnung.typ).
  if model.profile.xrechnung {
    import "xrechnung.typ": line-amounts
    out += line-amounts(model, line-field)
  }
  out
}

// The period and the country of origin of the lines (BG-26, BT-159), see
// `line-data` of rare.typ: most lines have neither.
#let _line-data(model) = {
  if not model.profile.lines { return () }
  let given = ()
  for line in model.lines {
    if (
      line.at("period", default: none) != none
        or line.at("origin", default: none) != none
    ) { given.push(line) }
  }
  if given == () { return () }
  import "rare.typ": line-data
  line-data(model.profile, model.at("delivery", default: (:)), given)
}

// --- VAT ------------------------------------------------------------------

// The rule families of the VAT categories: BR-S-*, BR-IC-*, ...
#let _category-rules = (
  S: "BR-S",
  Z: "BR-Z",
  E: "BR-E",
  AE: "BR-AE",
  K: "BR-IC",
  G: "BR-G",
  O: "BR-O",
  L: "BR-AF",
  M: "BR-AG",
)

/// A rule of the family of a VAT category, e.g. `category-rule("K", 2)` is
/// BR-IC-02.
///
/// -> str
#let category-rule(category, number) = (
  _category-rules.at(category)
    + "-"
    + (if number < 10 { "0" } else { "" })
    + str(number)
)

// The categories that need a seller VAT identifier or tax number (BR-x-02,
// -03, -04); K and G need the VAT identifier.
#let _taxed-categories = ("S", "Z", "E", "AE", "L", "M")

// The rules of the VAT categories come in threes: for invoice lines (e.g.
// BR-S-02, BR-S-05), document level allowances (BR-S-03, BR-S-06) and
// document level charges (BR-S-04, BR-S-07). The offset of the rule that
// applies to where a category occurs, or `none`: BASIC WL has no lines, so
// there only the rules of allowances and charges apply.
#let _rule-offset(occurrence, lines) = {
  if lines and occurrence.line { 0 } else if occurrence.allowance {
    1
  } else if occurrence.charge { 2 } else { none }
}

// Where each VAT category and VAT group (by `key`) occurs: on lines, on
// document level allowances or charges.
#let _occurrences(model) = {
  let none-yet = (line: false, allowance: false, charge: false)
  let found = (:)
  for line in model.lines {
    for name in (line.category, line.key) {
      if name == none { continue }
      found.insert(name, found.at(name, default: none-yet) + (line: true))
    }
  }
  for entry in model.allowance-charges {
    let kind = if entry.charge { "charge" } else { "allowance" }
    for name in (entry.category, entry.key) {
      if name == none { continue }
      found.insert(name, found.at(name, default: none-yet) + ((kind): true))
    }
  }
  found
}

#let _taxes(model) = {
  // MINIMUM carries no VAT details, only the totals.
  if not model.profile.settlement { return () }
  let out = ()
  let seller = model.seller
  let lines = model.profile.lines
  let categories = ()
  for tax in model.taxes {
    if tax.category != none and tax.category not in categories {
      categories.push(tax.category)
    }
  }
  let occurrences = _occurrences(model)
  let none-yet = (line: false, allowance: false, charge: false)
  // The rule offset of a VAT category or group (see `_rule-offset`).
  let offset(name) = _rule-offset(
    if name == none { none-yet } else {
      occurrences.at(name, default: none-yet)
    },
    lines,
  )

  // BR-CO-18: an invoice has a VAT breakdown. With lines, BR-16 (no lines)
  // says the same.
  if model.taxes.len() == 0 and not lines {
    out.push((key: "BR-CO-18", field: "line-items"))
  }

  // The number of VAT groups per category and rate as the XML states them
  // (`tax-field` names both, also for a group without category).
  let stated-groups = (:)
  for tax in model.taxes {
    let group = tax-field(tax)
    stated-groups.insert(group, stated-groups.at(group, default: 0) + 1)
  }

  for tax in model.taxes {
    let field = tax-field(tax)
    let category = tax.category

    // BR-48: a VAT breakdown has a rate unless it is not subject to VAT.
    // The test oracle checks the XML for it as well; this names the input.
    if tax.rate == none {
      if category != "O" {
        out.push((key: "BR-48", field: field, category: category))
      }
    } else {
      // IP-DEC-01: the XML states a rate with up to `rate-digits` decimals,
      // so a rate with more would be written as another rate, possibly as
      // the rate of another VAT group.
      let percent = tax.rate * 100
      if calc.round(percent, digits: rate-digits) != percent {
        out.push((
          key: "IP-DEC-01",
          field: field,
          percent: percent,
          rate: tax.rate,
          shared: stated-groups.at(field) > 1,
          category: category,
        ))
      }
    }

    // The VAT category, e.g. the split payment of Italy (B), which only
    // XRechnung accepts (see `category-code` of rare.typ).
    if not in-list(_vat-categories, category) {
      import "rare.typ": category-code
      let found = category-code(category, field, model.profile)
      if found != () {
        out += found
        continue
      }
    }
    if tax.rate == none { continue }

    // The rate of the lines (BR-x-05), allowances (BR-x-06) and charges
    // (BR-x-07) of the group. In BASIC WL, a group of lines only is left to
    // the rules of the VAT breakdown (BR-x-09). The split payment (B) has no
    // rules of its rate.
    let rate-rule = offset(tax.key)
    if rate-rule != none {
      rate-rule = if category in _category-rules {
        category-rule(category, 5 + rate-rule)
      }
    }
    if category in ("S", "L", "M") and tax.rate <= _zero and rate-rule != none {
      out.push((
        key: "vat-rate-positive",
        id: rate-rule,
        field: field,
        category: category,
      ))
    }
    if category in ("Z", "E", "AE", "K", "G") and tax.rate != _zero {
      if rate-rule == none and tax.amount != _zero {
        rate-rule = category-rule(category, 9)
      }
      if rate-rule != none {
        out.push((
          key: "vat-rate-zero",
          id: rate-rule,
          field: field,
          category: category,
        ))
      }
    }
    // BR-O-09: items not subject to VAT carry no VAT, so O has no rate.
    if category == "O" and tax.rate != _zero {
      out.push((key: "BR-O-09", field: field))
    }
    if (
      category == "E"
        and tax.reason == none
        and tax.at("code", default: none) == none
    ) {
      out.push((key: "BR-E-10", field: field))
    }
    // The exemption reason codes (BT-121) the items give.
    if tax.at("codes", default: ()) != () {
      import "rare.typ": exemption-codes
      out += exemption-codes(tax, field, model.profile)
    }
  }

  // The identifiers of the parties each category requires where it occurs:
  // on lines (BR-x-02), allowances (BR-x-03) or charges (BR-x-04). The VAT
  // identifier of the seller tax representative (BT-63) stands in for the
  // seller's own.
  let representative = model.at("tax-representative", default: none)
  let represented = (
    representative != none
      and model.profile.tax-representative
      and representative.vat-id != none
  )
  let taxed = ()
  for category in categories {
    if category in _taxed-categories and offset(category) != none {
      taxed.push(category)
    }
  }
  if (
    taxed.len() > 0
      and seller.vat-id == none
      and seller.tax-nr == none
      and not represented
  ) {
    let first = offset(taxed.first())
    out.push((
      key: "vat-seller-id",
      id: category-rule(taxed.first(), 2 + first),
      field: "sender",
      holder: first,
      categories: taxed,
    ))
  }
  for category in ("K", "G") {
    let at = offset(category)
    if (
      category in categories
        and at != none
        and seller.vat-id == none
        and not represented
    ) {
      out.push((
        key: "vat-seller-vat-id",
        id: category-rule(category, 2 + at),
        field: "sender.vat-id",
        category: category,
      ))
    }
  }
  // The buyer VAT identifier (BT-48) of K and AE: see `buyer-vat-id` of
  // rare.typ. BR-IC-12 is a safety net: the model states the buyer's country
  // as the deliver-to country (BT-80) of K.
  if "K" in categories and model.ship-to == none {
    out.push((key: "BR-IC-12", field: "delivery-address"))
  }
  // BR-IC-11: an intra-community supply states the date of the supply
  // (BT-72) or the invoicing period (BG-14). A credit note or a prepayment
  // invoice, whose own date is not the date of the supply, states none
  // without a `service-period` or dated items (see `service-period-of`).
  let delivery = model.at("delivery", default: (:))
  if (
    "K" in categories
      and delivery.at("date", default: none) == none
      and delivery.at("period", default: none) == none
  ) {
    out.push((
      key: "BR-IC-11",
      field: "service-period",
      document: model.invoice.at("document", default: none),
    ))
  }
  if "O" in categories and categories.len() > 1 {
    let others = ()
    for category in categories {
      if category != "O" { others.push(category) }
    }
    out.push((key: "BR-O-11", field: "tax", others: others))
  }
  // The split payment of Italy (B), which only XRechnung accepts; the
  // validation of BASIC and EN 16931 checks its rules as well.
  if "B" in categories and model.profile.en16931 {
    import "rare.typ": split-payment
    out += split-payment(model, categories)
  }
  out
}

// --- Payment --------------------------------------------------------------

// The payment means (BG-16): one kind of payment means, each with the
// details of its kind (XRechnung: BR-DE-1, BR-DE-19, BR-DE-20, BR-DE-23,
// BR-DE-24, BR-DE-25, BR-DE-30, BR-DE-31, PEPPOL-EN16931-R061).
#let _payment-means(model) = {
  let out = ()
  let profile = model.profile
  let xrechnung = profile.xrechnung
  let payment = model.payment
  let means = payment.means

  if means.len() == 0 {
    if xrechnung {
      // On a credit note or a self-billed invoice, the sender pays the
      // amount: to the recipient's account, or by a set-off.
      let document = model.invoice.at("document", default: none)
      let paid = payment.at("paid", default: false)
      out.push((
        key: "BR-DE-1",
        field: if paid { "paid.method" } else { "bank-details" },
        paid: paid,
        sender-pays: (
          type(document) == dictionary
            and document.at("sender-pays", default: false)
        ),
      ))
    }
    return out
  }

  // An invoice states one payment means code (BT-81). XRechnung forbids the
  // details of a direct debit (BG-19: the mandate reference, the creditor
  // identifier or a debited account) next to a credit transfer (BR-DE-23-b)
  // or a payment card (BR-DE-24-b). Kinds of payment means have different
  // codes (see `code-kind`), which break CII-SR-467 of CEN 1.3.16 in EN 16931
  // and XRechnung; BASIC WL and BASIC accept them, but the buyer could pay
  // twice (IP-PAY-03).
  let kinds = ()
  let conflicting = ()
  let debit-details = (
    payment.at("mandate", default: none) != none
      or payment.at("creditor-id", default: none) != none
  )
  for entry in means {
    if entry.kind not in kinds {
      kinds.push(entry.kind)
      conflicting.push(entry)
    }
    if entry.debtor-iban != none { debit-details = true }
  }
  if kinds.len() > 1 {
    let fields = ()
    for entry in conflicting { fields.push(entry.field) }
    out.push((
      key: if xrechnung and debit-details and "transfer" in kinds {
        "BR-DE-23-b"
      } else if xrechnung and debit-details and "card" in kinds {
        "BR-DE-24-b"
      } else if xrechnung or profile.id == "en16931" { "CII-SR-467" } else {
        "IP-PAY-03"
      },
      field: fields.join(", "),
      means: conflicting,
      paid: "paid" in fields,
    ))
  }

  for entry in means {
    if entry.kind == "transfer" {
      if entry.iban == none {
        // `paid(method: "transfer")` without bank details, or bank details
        // without an IBAN (with `zugferd-errors: "report"`; otherwise
        // `bank-details` stops the compilation): no account (BG-17) is
        // written. XRechnung: BR-DE-23-a; EN 16931: CII-SR-470 (CEN 1.3.16);
        // BASIC WL and BASIC accept it, as their BR-61 tests the debited
        // account: IP-PAY-04.
        let paid = entry.field == "paid"
        out.push((
          key: if xrechnung { "BR-DE-23-a" } else if profile.id == "en16931" {
            "CII-SR-470"
          } else { "IP-PAY-04" },
          field: if paid { "paid.method" } else { "bank-details.iban" },
          type-code: entry.type-code,
          paid: paid,
        ))
      } else if not iban-valid(entry.iban) {
        out.push((
          key: if xrechnung and entry.type-code == "58" { "BR-DE-19" } else {
            "IP-PAY-01"
          },
          field: "bank-details.iban",
          iban: entry.iban,
          debtor: false,
        ))
      }
      if entry.account-name != none and not profile.account-name {
        out.push(not-carried(
          profile,
          "bank-details.name",
          "the account name (BT-85)",
          "en16931",
        ))
      }
    } else if entry.kind in ("direct-debit", "card") {
      import "rare.typ": payment-means-details
      out += payment-means-details(entry, payment, profile)
    }
    if not in-list(_means-codes, entry.type-code) {
      import "rare.typ": means-code
      out += means-code(entry.type-code, profile)
    }
  }

  // The check digits of a SEPA creditor identifier (BT-90).
  let sepa-debit = false
  for entry in means {
    if entry.kind == "direct-debit" and entry.type-code == "59" {
      sepa-debit = true
    }
  }
  if sepa-debit and payment.at("creditor-id", default: none) != none {
    import "rare.typ": creditor-id
    out += creditor-id(payment.creditor-id)
  }
  out
}

#let _payment(model) = {
  if not model.profile.settlement {
    import "rare.typ": minimum-payment
    return minimum-payment(model)
  }
  let out = ()
  let payment = model.payment
  let terms = profile-terms(payment, model.profile)

  // XRechnung: the Skonto syntax of the payment terms (BR-DE-18).
  if model.profile.xrechnung {
    import "xrechnung.typ": payment-terms
    out += payment-terms(payment, terms)
  }

  if model.totals.due > _zero and payment.due-date == none and terms == none {
    out.push((key: "BR-CO-25", field: "payment-goal"))
  }

  out += _payment-means(model)

  // IP-PREPAID-01: prepayments above the total leave a negative amount due.
  if model.totals.prepaid > model.totals.gross and model.totals.gross >= _zero {
    out.push((key: "IP-PREPAID-01", field: "prepayment"))
  }
  out
}

// --- Consistency ----------------------------------------------------------

// Whether an amount has more than the 2 decimals the XML states.
#let _cents-exceeded(amount) = calc.round(amount, digits: 2) != amount

// The first amount the XML cannot state because it has more than 2 decimals,
// in the order of the XML, and how many there are: (count: .., term: ..,
// place: .., value: ..). Only the amounts the profile writes count.
#let _excess-decimals(model) = {
  let found = (count: 0)
  let note(found, term, place, value) = {
    if found.count == 0 {
      found += (term: term, place: place, value: value)
    }
    found.count += 1
    found
  }
  let profile = model.profile
  if profile.lines {
    for line in model.lines {
      if _cents-exceeded(line.net) {
        found = note(
          found,
          "line net amount (BT-131)",
          line-field(line),
          line.net,
        )
      }
      for entry in line.allowances {
        if _cents-exceeded(entry.amount) {
          found = note(
            found,
            "line allowance (BT-136)",
            line-field(line),
            entry.amount,
          )
        }
      }
      for entry in line.charges {
        if _cents-exceeded(entry.amount) {
          found = note(
            found,
            "line charge (BT-141)",
            line-field(line),
            entry.amount,
          )
        }
      }
    }
  }
  let totals = model.totals
  let amounts = ()
  if profile.settlement {
    for entry in model.allowance-charges {
      amounts.push(if entry.charge {
        ("document level charge (BT-99)", entry.amount)
      } else {
        ("document level allowance (BT-92)", entry.amount)
      })
    }
    for tax in model.taxes {
      amounts.push(("VAT taxable amount (BT-116)", tax.basis))
      amounts.push(("VAT amount (BT-117)", tax.amount))
    }
    amounts += (
      ("sum of the line net amounts (BT-106)", totals.line),
      ("sum of the allowances (BT-107)", totals.allowance),
      ("sum of the charges (BT-108)", totals.charge),
      ("prepaid amount (BT-113)", totals.prepaid),
    )
  }
  amounts += (
    ("total without VAT (BT-109)", totals.net),
    ("total VAT amount (BT-110)", totals.tax),
    ("total with VAT (BT-112)", totals.gross),
    ("amount due (BT-115)", totals.due),
  )
  for (term, value) in amounts {
    if _cents-exceeded(value) {
      found = note(found, term, none, value)
    }
  }
  found
}

// IP-DEC-02: the XML states amounts with 2 decimals (BR-DEC-*). Amounts
// with more (e.g. of KWD, or of a locale that rounds money more finely)
// would be written rounded, other than printed, and would no longer add up
// (BR-CO-10, BR-S-08, ...). That the XML states what the invoice prints and
// adds up in itself is a property of invoice-pro, which the test oracle
// checks (tools/zugferd/guard/equivalence.typ).
#let _consistency(model) = {
  let excess = _excess-decimals(model)
  if excess.count == 0 { return () }
  // A currency with more decimals (e.g. KWD, `invoice(currency: ..)`)
  // rounds the amounts to them; otherwise the rounding of the locale does.
  let decimals = model.at("currency-decimals", default: 2)
  let by-currency = type(decimals) == int and decimals > 2
  (
    (
      key: "IP-DEC-02",
      field: if by-currency {
        model.at("currency-field", default: "locale")
      } else { "locale" },
      excess: excess,
      by-currency: by-currency,
      currency: model.at("currency", default: none),
      decimals: decimals,
    ),
  )
}

/// The findings of the rules for an e-invoice data model, in the order of
/// the checks.
///
/// -> array
#let findings(model) = (
  _document(model)
    + _document-type(model)
    + _document-data(model)
    + _parties(model)
    + _lines(model)
    + _line-data(model)
    + _taxes(model)
    + _payment(model)
    + _consistency(model)
)

// --- Diagnostics ------------------------------------------------------------

// The rules whose usual level is "warning" (the first `level` of their entry
// in tools/zugferd/registry.json, which tools/zugferd/registry.py checks
// against this list); a finding gives the level of a rule with two.
#let _warnings = (
  "BR-DE-TMP-32",
  "IP-DOC-04",
  "IP-EADDR-01",
  "IP-KEY-01",
  "IP-PERIOD-02",
  "IP-PREPAID-01",
  "IP-PROFILE-01",
  "IP-TAX-03",
  "IP-UNIT-01",
  "IP-VAT-138",
  "PEPPOL-EN16931-R120",
)

/// A diagnostic, e.g. for a report hook or a test.
///
/// -> dictionary
#let diagnostic(level, rule, field, message, hint: none) = (
  level: level,
  rule: rule,
  field: field,
  message: message,
  hint: hint,
)

/// Turns the findings of the checks into diagnostics, errors first. The
/// messages load only now, and only the module of the rules found: the rules
/// of XRechnung that no other profile reports are in xrechnung-messages.typ,
/// every other rule in messages.typ.
///
/// -> array
#let diagnostics(findings) = {
  let errors = ()
  let warnings = ()
  for f in findings {
    let build = none
    if f.key.starts-with("BR-DE-") {
      import "xrechnung-messages.typ": messages as xrechnung-messages
      build = xrechnung-messages.at(f.key, default: none)
    }
    if build == none {
      import "messages.typ": messages
      build = messages.at(f.key, default: none)
    }
    if build == none { panic("invoice-pro: no message for the rule " + f.key) }
    let level = f.at("level", default: if f.key in _warnings {
      "warning"
    } else {
      "error"
    })
    let (message, hint) = build(f)
    let d = diagnostic(
      level,
      f.at("id", default: f.key),
      f.field,
      message,
      hint: hint,
    )
    if level == "error" { errors.push(d) } else { warnings.push(d) }
  }
  errors + warnings
}

/// Checks an e-invoice data model against the rules and returns every
/// diagnostic, errors first (see the top of this file).
///
/// -> array
#let run-rules(model) = {
  let found = findings(model)
  if found == () { return () }
  diagnostics(found)
}
