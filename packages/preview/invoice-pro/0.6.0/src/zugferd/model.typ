// Normalizes the computed invoice into the data model of the e-invoice.
//
// The model is a projection of what the invoice computed and prints: the
// quantities, prices and amounts of its lines, the allowances and charges,
// the VAT groups and the totals are read from the computed invoice (the
// line items' `item-data`), never computed a second time. The only amounts
// the printed invoice does not state are the net amounts of an invoice with
// gross prices, which logic/net-amounts.typ derives from the printed ones;
// the sums of the lines, allowances and charges (BT-106 to BT-108) are
// added up here. The texts and identifiers are made plain once. The
// validator checks this model and the builder serializes it; the tests
// compare the XML with it once more (tools/zugferd/guard/roundtrip.typ), so
// all three agree on what ends up in the XML.

#import "../utils/text.typ": plain-ascii, plain-text
#import "code-lists.typ": lists
#import "profile.typ": resolve-profile
#import "../utils/coercion.typ": to-decimal, to-ratio
#import "../data/tax.typ": to-tax-key
#import "../logic/payment-reference.typ": resolve-payment-reference
#import "../logic/document-type.typ": resolve-document-type
#import "../logic/service-period.typ": format-service-period, service-period-of
#import "../logic/payment-means.typ": (
  card-code, direct-debit-code, method-code, resolve as resolve-payment-means,
  transfer-code,
)
#import "../logic/references.typ": (
  service-period-label, service-period-text-label,
)
#import "../logic/printed.typ": shows-identifier, shows-text
#import "../logic/currency.typ": currency-code
#import "../utils/helper.typ": first-given
#import "xml.typ": fmt-number

#let _zero = decimal("0")
#let _one = decimal("1")

// Whether `code` is in a code list of code-lists.typ, a string of codes
// each between two spaces (see `in-list` of rules/engine.typ).
#let _in-list(list, code) = (
  type(code) == str
    and code != ""
    and not code.contains(" ")
    and (" " + code + " ") in list
)

// The first value that is set, or `none`: the same fallbacks as the printed
// invoice takes (see `first-given`).
#let first-of = first-given

// A string that `plain-text` returns as it is (`plain-ascii`): printable
// ASCII words with single spaces between them, as most names, numbers and
// codes are. The test is cheaper than `plain-text`, which runs three
// replacements.
#let _plain-ascii = plain-ascii

// The plain text of a value, or `none` if it has no visible text. A text
// element of such a string, e.g. the name `[Consulting]` of an item, is
// its string as well.
#let text-or-none(value) = {
  if type(value) == str and _plain-ascii in value { return value }
  if (
    type(value) == content
      and value.func() == text
      and _plain-ascii in value.text
  ) { return value.text }
  let result = plain-text(value)
  if result == "" { none } else { result }
}

/// The payment terms (BT-20) of a text, or `none`. Unlike other texts, they
/// keep their line breaks: the XRechnung Skonto syntax (BR-DE-18) writes each
/// cash discount on a line of its own, e.g. "#SKONTO#TAGE=14#PROZENT=2.00#",
/// followed by a line break, which is added when the text ends with such a
/// line.
///
/// -> str | none
#let payment-terms(value) = {
  let terms = plain-text(value, keep-newlines: true)
  if terms == "" { none } else if terms.ends-with("#") { terms + "\n" } else {
    terms
  }
}


// Invisible format characters (Unicode category Cf: zero width space, byte
// order mark, word joiner, soft hyphen, ...), which copied identifiers often
// carry. They are all outside ASCII, so the patterns are compiled (once, on
// first use) only for texts that are not plain ASCII.
#let _invisible-patterns() = (
  invisible: regex("\\p{Cf}"),
  spaces: regex(" {2,}"),
)

// A plain text without invisible characters. The spaces around a removed
// character are joined, as `plain-text` has collapsed the whitespace before.
#let _visible(text) = {
  if text.len() == text.codepoints().len() { return text }
  let patterns = _invisible-patterns()
  text.replace(patterns.invisible, "").replace(patterns.spaces, " ").trim()
}

// The plain text of an identifier without any whitespace or invisible
// characters (VAT IDs, IBANs, email addresses, codes). `plain-text` turns all
// whitespace into single spaces.
#let compact(value) = {
  if type(value) == str and _plain-ascii in value {
    return value.replace(" ", "")
  }
  let result = _visible(plain-text(value).replace(" ", ""))
  if result == "" { none } else { result }
}

// The plain text of an identifier that may contain spaces (e.g. the tax
// number "143/123/45678" or "HRB 12345"), without invisible characters.
#let _identifier(value) = {
  if type(value) == str and _plain-ascii in value { return value }
  let result = _visible(plain-text(value))
  if result == "" { none } else { result }
}

// The value of the key `key` of a party or the root context, `none` for the
// placeholder the root context fills a missing value with for the visual
// invoice, e.g. "#invoice-nr" or "#sender.city-name". Called with the value
// rather than the dictionary, which Typst would hash on every call.
#let _unset(value, key) = if (
  type(value) == str
    and (
      value == "#" + key
        or (value.starts-with("#") and value.ends-with("." + key))
    )
) { none } else { value }

// ISO 3166-1 alpha-2 code of a country: a country of the `country` module or
// its code.
#let _country-code(country) = {
  let code = if type(country) == dictionary {
    country.at("code", default: none)
  } else { country }
  let code = if type(code) in (str, content) { compact(code) } else { none }
  if code == none { none } else { upper(code) }
}

// ISO 3166-1 alpha-2 code of a party's country.
#let country-code(party) = _country-code(party.at("country", default: none))

// Electronic address schemes (EAS) for national VAT identification numbers,
// keyed by the VAT ID prefix (Greece uses "EL"). Only schemes of the EAS code
// list every validator accepts (`eas.every` of code-lists.typ); Denmark and
// Sweden, for example, have none, so their parties fall back to the email
// address.
#let vat-eas-codes = (
  AT: "9914",
  BE: "9925",
  BG: "9926",
  CH: "9927",
  CY: "9928",
  CZ: "9929",
  DE: "9930",
  EE: "9931",
  EL: "9933",
  ES: "9920",
  FI: "0213",
  FR: "9957",
  GB: "9932",
  GR: "9933",
  HR: "9934",
  HU: "9910",
  IE: "9935",
  IT: "0211",
  LT: "9937",
  LU: "9938",
  LV: "9939",
  MT: "9943",
  NL: "9944",
  PL: "9945",
  PT: "9946",
  RO: "9947",
  SI: "9949",
  SK: "9950",
)

/// The prefix of a VAT identifier: its first two characters in upper case,
/// or `none` if it is shorter. Taken by characters, never by bytes, so that
/// a VAT ID starting with any character (e.g. "€") is safe to inspect.
///
/// -> none | str
#let vat-id-prefix(vat-id) = {
  if vat-id == none { return none }
  let chars = vat-id.codepoints()
  if chars.len() < 2 { none } else { upper(chars.at(0) + chars.at(1)) }
}

/// The ISO 3166-1 code of the country that issued a VAT identifier: its
/// prefix, with "EL" for Greece and "XI" (Northern Ireland) for the United
/// Kingdom, or `none` if the prefix is not a country code.
///
/// -> none | str
#let vat-id-country(vat-id) = {
  let prefix = vat-id-prefix(vat-id)
  let code = if prefix == "EL" { "GR" } else if prefix == "XI" { "GB" } else {
    prefix
  }
  if _in-list(lists.country.every, code) { code } else { none }
}

// Contact details of a party, from `contact` or the flat `contact-name`,
// `phone` and `email` keys.
#let contact-model(party) = {
  let contact = party.at("contact", default: none)
  let nested = if type(contact) == dictionary { contact } else if (
    contact != none
  ) { (name: contact) } else { (:) }
  let name = first-of(
    nested.at("name", default: none),
    party.at("contact-name", default: none),
  )
  let phone = first-of(
    nested.at("phone", default: none),
    party.at("phone", default: none),
  )
  let email = first-of(
    nested.at("email", default: none),
    party.at("email", default: none),
  )
  let result = (
    name: if name != none { text-or-none(name) },
    phone: if phone != none { text-or-none(phone) },
    email: if email != none { compact(email) },
  )
  if result.name == none and result.phone == none and result.email == none {
    none
  } else { result }
}

/// Retrieves the electronic address (BT-34, BT-49) of a party: the explicit
/// `electronic-address`, else one derived from the VAT ID, else the email.
///
/// An explicit address without an identifier (`""`, `auto`, `(scheme: "EM")`
/// or an empty field of imported data) counts as not given, so the address is
/// derived instead: the XML never gets an address without identifier (BR-62,
/// BR-63). An address without scheme is an email address (`EM`) if it contains
/// "@"; otherwise its scheme stays `none` for the validator to report.
///
/// The VAT ID is used even when the invoice is not subject to VAT: BR-O-02
/// leaves out the VAT identifiers (BT-31, BT-48), not the electronic address.
///
/// Returns `none` or `(scheme: none | str, id: str)`.
///
/// -> none | dictionary
#let get-electronic-address(party) = {
  let explicit = party.at("electronic-address", default: none)
  if type(explicit) == dictionary {
    let id = compact(explicit.at("id", default: none))
    if id != none {
      let scheme = compact(explicit.at("scheme", default: none))
      if scheme != none { scheme = upper(scheme) } else if id.contains("@") {
        scheme = "EM"
      }
      return (scheme: scheme, id: id)
    }
  } else if explicit != auto and explicit != none {
    let id = compact(explicit)
    if id != none {
      return (scheme: if id.contains("@") { "EM" }, id: id)
    }
  }

  // The prefix names the country that issued the VAT ID, and only that
  // country's scheme fits: a Danish VAT ID of a German company is no German VAT
  // endpoint. Without a scheme for the prefix, the email is used.
  let vat-id = compact(party.at("vat-id", default: none))
  let prefix = vat-id-prefix(vat-id)
  if prefix != none and vat-id.codepoints().len() > 2 {
    let scheme = vat-eas-codes.at(prefix, default: none)
    if scheme != none {
      return (scheme: scheme, id: upper(vat-id))
    }
  }

  let contact = contact-model(party)
  if contact != none and contact.email != none {
    return (scheme: "EM", id: contact.email)
  }
  none
}

// An identifier with an optional scheme: a dictionary such as a GLN
// `(scheme: "0088", id: ..)`, or a text without scheme. Identifiers with a
// scheme are written without spaces; `none` if there is no identifier.
#let _scheme-id(value) = {
  if type(value) == dictionary {
    let scheme = compact(value.at("scheme", default: none))
    let id = value.at("id", default: none)
    id = if scheme == none { _identifier(id) } else { compact(id) }
    return if id == none { none } else { (scheme: scheme, id: id) }
  }
  let id = _identifier(value)
  if id == none { none } else { (scheme: none, id: id) }
}

// The identifiers of a party, from the input `keys` in this order. An
// identifier without scheme is the party identifier written as `ram:ID`
// (BT-29, BT-46, BT-71), one with scheme the global identifier (`ram:GlobalID`):
// `id` may be given with a scheme, and a `global-id` without one is an
// ordinary identifier. The keys each value came from are kept (`id-keys`,
// `global-id-keys`), so that the validator reports two different values for
// one of them instead of dropping one.
#let _party-ids(party, keys) = {
  let ids = ()
  let id-keys = ()
  let global-ids = ()
  let global-id-keys = ()
  for key in keys {
    let value = party.at(key, default: none)
    if value == none { continue }
    value = _scheme-id(value)
    if value == none { continue }
    if value.scheme == none {
      if value.id not in ids {
        ids.push(value.id)
        id-keys.push(key)
      }
    } else if value not in global-ids {
      global-ids.push(value)
      global-id-keys.push(key)
    }
  }
  (
    id: ids.first(default: none),
    global-id: global-ids.first(default: none),
    id-keys: id-keys,
    global-id-keys: global-id-keys,
  )
}

// --- Keys of the party dictionaries ------------------------------------------

// The keys of `sender`, `recipient` and `delivery-address` besides the address:
// `true` if the e-invoice reads the key, `false` if only the printed invoice
// uses it.
#let _address-keys = (
  name: true,
  address: true,
  street: true,
  city: true,
  country: true,
  region: true,
  extra: false,
)

/// The keys each party knows, by role: the seller (`sender`), the buyer
/// (`recipient`), the ship-to party (`delivery-address`), the seller's tax
/// representative (`sender.tax-representative`) and the payee (`payee`).
/// `true` marks the keys the e-invoice reads, `false` those only the printed
/// invoice uses.
#let party-keys = (
  seller: _address-keys
    + (
      id: true,
      global-id: true,
      legal-id: true,
      trading-name: true,
      legal-info: true,
      vat-id: true,
      tax-nr: true,
      tax-representative: true,
      electronic-address: true,
      contact: true,
      contact-name: true,
      phone: true,
      email: true,
      // the commercial register entry and the management, which the
      // `registration` part of the theme prints in the legal footer
      register: false,
      management: false,
    ),
  buyer: _address-keys
    + (
      id: true,
      global-id: true,
      legal-id: true,
      trading-name: true,
      vat-id: true,
      electronic-address: true,
      contact: true,
      contact-name: true,
      phone: true,
      email: true,
      buyer-reference: true,
      leitweg-id: true,
      order-nr: true,
      po-nr: true,
      contract-nr: true,
      delivery-note-nr: true,
      delivery-address: true,
      tax-nr: false,
      customer-nr: false,
      customer-id: false,
      order-date: false,
      project: false,
      quote-nr: false,
    ),
  ship-to: _address-keys + (id: true, location-id: true, global-id: true),
  tax-representative: _address-keys + (vat-id: true),
  payee: (name: true, id: true, global-id: true, legal-id: true),
)

// The keys of a party's `contact`, by role. The e-invoice writes the seller
// contact (BG-6) and the buyer contact (BG-9).
#let _contact-keys = (
  seller: (name: true, phone: true, email: true),
  buyer: (name: true, phone: true, email: true),
)

// The keys of an identifier given as a dictionary (`id`, `global-id`,
// `location-id`, `legal-id`, `electronic-address`), including those of a typed
// identifier of the `id` module (`kind`, `problems`).
#let _identifier-keys = (scheme: true, id: true, kind: true, problems: true)

// The keys of each role that take an identifier, possibly a typed one of the
// `id` module (`id.siret(..)`), whose problems the validator reports.
#let _typed-id-keys = (
  seller: ("id", "global-id", "legal-id", "electronic-address"),
  buyer: (
    "id",
    "global-id",
    "legal-id",
    "electronic-address",
    "leitweg-id",
    "buyer-reference",
  ),
  ship-to: ("id", "location-id", "global-id"),
  payee: ("id", "global-id", "legal-id"),
)

// Keys the normalization of a party adds (see `normalize-party`); they are
// not part of the input. A `post-code`, `city-name` or `state` of the input is
// replaced by the parts of its `city`.
#let _derived-keys = (
  name-inline: true,
  address-inline: true,
  city-inline: true,
  address-lines: true,
  country-explicit: true,
  city-name: true,
  post-code: true,
  state: true,
)

// An input key a party does not know, described by `unknown-key` of
// keys.typ, which loads only for the first unknown key: invoices rarely have
// one.
#let _unknown-key(key, known, path: none) = {
  import "keys.typ": unknown-key
  unknown-key(key, known, path: path)
}

// Whether an input value states nothing: the keys of such values are ignored.
#let _is-unset(value) = value in (none, auto, "", [], ())

// The keys of a party dictionary, of its `contact` and of its identifiers that
// the role does not know (see `party-keys`), each described by `unknown-key`
// of keys.typ, which loads only for the first unknown key.
#let _input-keys(party, role) = {
  let known = party-keys.at(role)
  // A key standing for the city or post code loses nothing next to a city
  // line whose post code was recognized, one standing for the country (e.g.
  // `county`) nothing next to a `country` the party states.
  let has-post-code = (
    text-or-none(_unset(party.at("post-code", default: none), "post-code"))
      != none
  )
  let has-country = party.at(
    "country-explicit",
    default: not _is-unset(party.at("country", default: none)),
  )
  let result = ()
  for (key, value) in party.pairs() {
    if key in known or key in _derived-keys or _is-unset(value) { continue }
    let entry = _unknown-key(key, known)
    if (
      (entry.like == "city" and has-post-code)
        or (entry.like == "country" and has-country == true)
    ) {
      entry.einvoice = false
    }
    result.push(entry)
  }
  let contact = party.at("contact", default: none)
  let contact-keys = _contact-keys.at(role, default: none)
  if contact-keys != none and type(contact) == dictionary {
    for (key, value) in contact.pairs() {
      if key in contact-keys or _is-unset(value) { continue }
      result.push(_unknown-key(key, contact-keys, path: "contact"))
    }
  }
  // An identifier dictionary without `id` is left out, so any other key of it
  // loses the identifier.
  for key in (
    "id",
    "global-id",
    "location-id",
    "legal-id",
    "electronic-address",
    "leitweg-id",
    "buyer-reference",
  ) {
    let value = party.at(key, default: none)
    if key not in known or type(value) != dictionary { continue }
    let lost = _is-unset(value.at("id", default: none))
    for (inner, inner-value) in value.pairs() {
      if inner in _identifier-keys or _is-unset(inner-value) { continue }
      let entry = _unknown-key(inner, _identifier-keys, path: key)
      result.push(entry + (einvoice: entry.einvoice or lost))
    }
  }
  result
}

// --- Parties -------------------------------------------------------------------

// The plain text of the value of the key `key` of a party (see `_unset`), or
// `none`.
#let _key-text(value, key) = if value == none { none } else {
  text-or-none(_unset(value, key))
}

// The postal address of a party (BG-5, BG-8, BG-12, BG-15). EN 16931 has
// three address lines (BT-35, BT-36, BT-162): any further lines are joined
// into the third one, as the XML states them.
#let _address-model(party) = {
  let raw-lines = party.at("address-lines", default: ())
  let lines = ()
  for line in if type(raw-lines) == array { raw-lines } else { (raw-lines,) } {
    let text = if line != none { text-or-none(line) }
    if text != none { lines.push(text) }
  }
  if lines.len() > 3 {
    lines = lines.slice(0, 2) + (lines.slice(2).join(", "),)
  }
  (
    lines: lines,
    city: _key-text(party.at("city-name", default: none), "city-name"),
    post-code: _key-text(party.at("post-code", default: none), "post-code"),
    state: _key-text(party.at("state", default: none), "state"),
    country: _country-code(party.at("country", default: none)),
    // Whether the party states its country (`country` or `region`); otherwise
    // it is the country of the locale or, for a delivery address, the buyer's.
    country-explicit: party.at("country-explicit", default: true) != false,
  )
}

// The text of a party detail that may be given as several lines, e.g.
// `legal-info: ("Sitz: München", "Amtsgericht München, HRB 98765")`: its
// lines joined by ", ", as `info` prints them.
#let _lines-text(value) = {
  if value == none { return none }
  if type(value) == array {
    let lines = ()
    for line in value {
      let text = if line != none { text-or-none(line) }
      if text != none { lines.push(text) }
    }
    value = lines.join(", ")
  }
  text-or-none(value)
}

// The name of a party (BT-27, BT-44, BT-70). A name given as several lines is
// one name, its lines joined by ", " as in the inline sender line.
#let _party-name(party) = _lines-text(first-of(
  _unset(party.at("name-inline", default: none), "name-inline"),
  _unset(party.at("name", default: none), "name"),
))

// A typed identifier of the `id` module (e.g. `id.siret(..)`): a dictionary
// with the `kind` of the identifier and the `problems` found when it was made.
#let _is-typed-id(value) = (
  type(value) == dictionary and "kind" in value and "problems" in value
)

// The typed identifiers a party gives for the identifier keys of its role,
// with the key each was given for, for the validator (IP-ID-01, IP-ID-03).
#let _typed-ids(party, role) = {
  let found = ()
  if role == none { return found }
  for key in _typed-id-keys.at(role, default: ()) {
    let value = party.at(key, default: none)
    if not _is-typed-id(value) { continue }
    found.push((
      key: key,
      scheme: value.at("scheme", default: none),
      id: value.at("id", default: none),
      kind: value.kind,
      problems: if type(value.problems) == array { value.problems } else {
        ()
      },
    ))
  }
  found
}

// The text of an identifier that may be given as a dictionary, e.g. the
// Leitweg-ID `id.leitweg(..)` as buyer reference (BT-10), which states no
// scheme.
#let _id-text(value) = {
  if type(value) == dictionary { value.at("id", default: none) } else { value }
}

// Whether a buyer states a contact point (BG-9): a `contact`, or a contact
// name or phone number of its own. An email address alone is where the
// invoice goes (it can be the electronic address, BT-49), not a contact.
#let _states-contact(party) = (
  not _is-unset(party.at("contact", default: none))
    or not _is-unset(party.at("contact-name", default: none))
    or not _is-unset(party.at("phone", default: none))
)

/// A seller, buyer or ship-to party (`role`: `"seller"`, `"buyer"` or
/// `"ship-to"`). `vat-id` is the VAT identifier the party states;
/// `use-vat-id: false` keeps it out of the XML (BR-O-02), but not out of the
/// electronic address. With a `role`, the keys of the party dictionary are
/// checked against those the role knows (`input-keys`).
///
/// `legal-id` is the legal registration identifier (BT-30, BT-47), a text or
/// an identifier with scheme (`id.siret(..)`), `trading-name` the name the
/// party trades under (BT-28, BT-45) and `legal-info` the additional legal
/// information of the seller (BT-33). The contact of the buyer (BG-9) is only
/// given when the buyer states a contact point (`contact`, `contact-name` or
/// `phone`).
///
/// -> dictionary
#let party-model(party, role: none, use-vat-id: true) = {
  if type(party) != dictionary { party = (:) }
  let vat-id = party.at("vat-id", default: none)
  if vat-id != none { vat-id = compact(vat-id) }
  if vat-id != none { vat-id = upper(vat-id) }
  let id-keys = if role == "ship-to" {
    ("id", "location-id", "global-id")
  } else {
    ("id", "global-id")
  }
  // The details most parties do not give.
  let trading-name = party.at("trading-name", default: none)
  let legal-id = party.at("legal-id", default: none)
  let legal-info = party.at("legal-info", default: none)
  let tax-nr = party.at("tax-nr", default: none)
  (
    (
      name: _party-name(party),
      trading-name: if trading-name != none {
        _lines-text(_unset(trading-name, "trading-name"))
      },
      legal-id: if legal-id != none { _scheme-id(legal-id) },
      legal-info: if legal-info != none {
        _lines-text(_unset(legal-info, "legal-info"))
      },
      vat-id: if use-vat-id { vat-id } else { none },
      stated-vat-id: vat-id,
      tax-nr: if tax-nr != none { _identifier(tax-nr) },
      address: _address-model(party),
      electronic-address: get-electronic-address(party),
      contact: if role != "buyer" or _states-contact(party) {
        contact-model(party)
      },
      typed-ids: _typed-ids(party, role),
      input-keys: if role == none { () } else { _input-keys(party, role) },
    )
      + _party-ids(party, id-keys)
  )
}

// The seller (BG-4). Without an own identifier (BT-29), a legal registration
// identifier (BT-30) or a VAT identifier (BT-31) in the XML, the tax number
// identifies the seller (BR-CO-26).
#let seller-model(party, use-vat-id: true) = {
  let seller = party-model(party, role: "seller", use-vat-id: use-vat-id)
  if (
    seller.id == none
      and seller.global-id == none
      and seller.legal-id == none
      and seller.vat-id == none
  ) {
    seller.id = seller.tax-nr
  }
  seller
}

/// The seller tax representative (BG-11), from `sender.tax-representative`
/// normalized like a party (`normalize-party`): its name (BT-62), VAT
/// identifier (BT-63) and postal address (BG-12); `none` without one.
///
/// -> none | dictionary
#let tax-representative-model(party) = {
  if type(party) != dictionary { return none }
  let vat-id = compact(party.at("vat-id", default: none))
  (
    name: _party-name(party),
    vat-id: if vat-id != none { upper(vat-id) },
    address: _address-model(party),
    input-keys: _input-keys(party, "tax-representative"),
  )
}

/// The payee (BG-10), from `payee` of the invoice: who receives the payment
/// instead of the seller, e.g. a factoring company. Its name (BT-59), its
/// identifier (BT-60, `id` or `global-id`) and its legal registration
/// identifier (BT-61); `none` without a payee.
///
/// -> none | dictionary
#let payee-model(payee) = {
  if type(payee) != dictionary { return none }
  (
    (
      name: _party-name(payee),
      legal-id: _scheme-id(payee.at("legal-id", default: none)),
      typed-ids: _typed-ids(payee, "payee"),
      input-keys: _input-keys(payee, "payee"),
    )
      + _party-ids(payee, ("id", "global-id"))
  )
}

// The ship-to party of an intra-community supply without delivery address: the
// buyer's address (BR-IC-12), without identifiers or input of its own.
#let _ship-to-buyer(address) = (
  name: none,
  id: none,
  global-id: none,
  id-keys: (),
  global-id-keys: (),
  address: address,
  input-keys: (),
  from-buyer: true,
)

/// The UN/ECE Recommendation 20 code of a unit (BT-130, BT-150) as `(code:
/// .., issue: ..)`. A unit of the `unit` module or a dictionary carries its
/// code; without a unit, the quantity is a number of "one" (C62). A unit
/// given as text is resolved by `resolve-text-unit` (units.typ, which loads
/// only for such a unit): a code as it is, or the code of a unit name or
/// abbreviation invoice-pro knows, else C62 with the issue that the text is
/// unknown or ambiguous.
///
/// -> dictionary
#let resolve-unit(unit) = {
  if type(unit) == dictionary {
    let code = compact(unit.at("code", default: none))
    if code != none { return (code: code, issue: none) }
    unit = unit.at("display", default: none)
  }
  let text = plain-text(unit)
  if text == "" { return (code: "C62", issue: none) }
  import "units.typ": resolve-text-unit
  resolve-text-unit(text)
}

/// The UN/ECE Recommendation 20 code of a unit, see `resolve-unit`.
///
/// -> str
#let map-unit-code(unit) = resolve-unit(unit).code

/// The delivery date (BT-72) or the invoicing period (BG-14) of the
/// e-invoice: the service period the invoice prints (see
/// `resolve-service-period`), as `(date: .., period: ..)`. A single date is
/// the delivery date, a period its first and last date.
///
/// -> dictionary
#let _delivery(period) = {
  if period == none {
    (date: none, period: none)
  } else if period.start == period.end {
    (date: period.start, period: none)
  } else {
    (date: none, period: (period.start, period.end))
  }
}

#let _service-period(ctx, items) = service-period-of(ctx, items)

#let determine-delivery-dates(ctx, items) = _delivery(_service-period(
  ctx,
  items,
))

// The service period the invoice prints as a reference, or `none`:
// `(text: .., own: ..)`, its text and whether it is a text of its own rather
// than dates in the date format of the locale. That is the one of
// `references.service-time`, which marks it whatever its title, or a
// reference of its own with the title of the service period, e.g.
// `("Leistungszeitraum", "Juni 2026")`.
#let _printed-service-period(ctx) = {
  let strings = ctx.at("locale", default: (:)).at("strings", default: (:))
  let labels = strings.at("reference", default: (:))
  let label = text-or-none(labels.at("service-time", default: none))
  let references = ctx.at("references", default: ())
  if type(references) != array { return none }
  for reference in references {
    if type(reference) != array or reference.len() != 2 { continue }
    let (title, value) = reference
    let mark = if type(value) == content { value.at("label", default: none) }
    if (
      mark in (service-period-label, service-period-text-label)
        or (
          label != none
            and type(title) in (str, content)
            and text-or-none(title) == label
        )
    ) {
      if type(value) not in (str, content) { return none }
      let text = text-or-none(value)
      if text == none { return none }
      return (text: text, own: mark != service-period-label)
    }
  }
  none
}

// Whether the printed invoice shows the date of the supply (IP-PERIOD-03):
// `none` if that cannot be known, as the theme does not say that it prints
// the reference signs (see `logic/printed.typ`); `true` if it prints a
// service period as a reference (`printed-period`) or the dates of the items,
// or shows the text of the service period the e-invoice states
// (`period-text`) elsewhere, e.g. in a reference of another title or the
// text of the invoice, but not as the invoice date; else `false`.
#let _period-shown(ctx, printed, printed-period, period-text, dates-printed) = {
  if type(printed) != dictionary or not printed.at("known", default: false) {
    return none
  }
  if printed-period != none or dates-printed { return true }
  let strings = ctx.at("locale", default: (:)).at("strings", default: (:))
  let invoice-date = strings
    .at("reference", default: (:))
    .at("invoice-date", default: none)
  let except = if invoice-date == none { () } else {
    (plain-text(invoice-date),)
  }
  shows-text(printed, period-text, except: except) == true
}

// The notes of the invoice (BT-22 and BT-21, see `normalize-notes`): the
// plain text of each note with its line breaks, and its subject code in upper
// case. A note without text is left out.
#let _notes(notes) = {
  let result = ()
  for note in notes {
    if type(note) != dictionary { continue }
    let content = plain-text(
      note.at("text", default: none),
      keep-newlines: true,
    )
    if content == "" { continue }
    let code = compact(note.at("subject-code", default: none))
    result.push((
      content: content,
      subject-code: if code != none { upper(code) },
    ))
  }
  result
}

// Categories whose VAT breakdown must not carry an exemption reason
// (BR-S-10, BR-Z-10, BR-AF-10, BR-AG-10).
#let _taxed-categories = ("S", "Z", "L", "M")

// The VAT exemption reason code (BT-121) of the categories that have one
// meaning (BR-AE-10, BR-IC-10, BR-G-10, BR-O-10).
#let _category-codes = (
  AE: "VATEX-EU-AE",
  K: "VATEX-EU-IC",
  G: "VATEX-EU-G",
  O: "VATEX-EU-O",
)

/// The VAT exemption reason codes (BT-121) the items of a VAT group give
/// (`code` of the constructors of the `tax` module): distinct, without
/// whitespace and in upper case, as the validator checks them.
///
/// -> array
#let exemption-codes(codes) = {
  let result = ()
  for code in codes {
    let text = compact(code)
    if text == none { continue }
    text = upper(text)
    if text not in result { result.push(text) }
  }
  result
}

/// The VAT exemption reason code (BT-121) of a VAT category: the one code its
/// items give, else the code of the category for AE, K, G and O (e.g.
/// "VATEX-EU-IC" for an intra-community supply). A taxed category (S, Z, L,
/// M) has none, and neither has a group whose items give different codes:
/// EN 16931 states one per VAT category and rate, so the reasons are stated
/// as text (BT-120) only; the validator reports both.
///
/// -> none | str
#let exemption-code(category, codes) = {
  if category in _taxed-categories or codes.len() > 1 { return none }
  if codes.len() == 1 { codes.first() } else {
    _category-codes.at(category, default: none)
  }
}

/// The exemption reason (BT-120) of a VAT category: the plain text of the
/// grounds the invoice prints for it. The VAT groups of the line items state
/// the note of the language for the categories that need a reason (AE, K, G,
/// O) when their items give no grounds, and print it (see
/// `calculate-taxes`), so the grounds of a group are the only source. A
/// taxed category (S, Z, L, M) states none.
///
/// -> str | none
#let exemption-reason(category, grounds) = {
  if category in _taxed-categories { return none }
  text-or-none(grounds)
}

// The key of the VAT group a tax belongs to, as used by `group-by-tax`: its
// rate as a decimal and its category (see `to-tax-key`).
#let _tax-key(tax) = {
  if type(tax) != dictionary or "rate" not in tax or "category" not in tax {
    return none
  }
  let rate = tax.rate
  if type(rate) == decimal and type(tax.category) == str {
    return str(rate) + "-" + tax.category
  }
  to-tax-key((rate: to-ratio(rate), category: tax.category))
}

// The invoice line period (BG-26) of an item: its date as a period of one
// day, or its period, as `(start, end)`; `none` without a date.
#let _line-period(date) = {
  if type(date) == datetime { return (date, date) }
  if (
    type(date) == array
      and date.len() == 2
      and type(date.first()) == datetime
      and type(date.last()) == datetime
  ) {
    return (date.first(), date.last())
  }
  none
}

// A decimal of the computed invoice: its numbers are decimals already, so a
// conversion runs only for a hand-built one.
#let _decimal(value) = if type(value) == decimal { value } else {
  to-decimal(value)
}

/// The invoice lines (BG-25) of the computed items `items` (`item-data.items`
/// of the line items), in their order: a projection of what each item prints.
/// With net prices, the quantity (BT-129), the price (BT-146) and its base
/// quantity (BT-149), the net amount (BT-131) and the amounts of the item's
/// own allowances and charges (BT-136, BT-141) are those of the item. With
/// gross prices, `nets` holds the net amounts of every item (see
/// logic/net-amounts.typ), which replace the printed gross amounts.
///
/// BR-27: a negative price is stated as a positive price of a negative
/// quantity, which keeps the line's amount.
///
/// It runs once per invoice and visits the items in a loop, calling
/// functions only where there is something to convert: a call per line
/// would hash the item (with its content) every time.
///
/// -> array
#let line-models(items, nets: none) = {
  let lines = ()
  let index = 0
  for item in items {
    let tax = item.at("tax", default: (:))
    if type(tax) != dictionary { tax = (:) }
    let rate = tax.at("rate", default: _zero)
    if type(rate) != decimal { rate = to-ratio(rate) }
    let category = tax.at("category", default: none)
    if type(category) != str or _plain-ascii not in category {
      category = text-or-none(category)
    }

    let quantity = _decimal(item.at("quantity", default: _one))
    let base-quantity = _decimal(item.at("base-quantity", default: _one))
    let price = _decimal(item.at("price", default: _zero))
    let net = _decimal(item.at("total", default: _zero))
    // The allowances and charges of the item, as it prints them: discounts
    // are negative, surcharges positive.
    let modifiers = (
      item.at("discounts", default: ()) + item.at("surcharge", default: ())
    )
    let adjustments = none
    if nets != none {
      let line = nets.at(index)
      net = line.net
      price = if price < _zero { -line.price } else { line.price }
      adjustments = line.adjustments
    }
    if price < _zero {
      price = -price
      quantity = -quantity
    }

    let allowances = ()
    let charges = ()
    let i = 0
    for modifier in modifiers {
      let amount = _decimal(modifier.at("absolute", default: _zero))
      let stated = if adjustments == none { calc.abs(amount) } else {
        adjustments.at(i)
      }
      i += 1
      if stated == _zero { continue }
      // The reason as the XML states it (BR-42, BR-44).
      let reason = text-or-none(modifier.at("name", default: none))
      if amount < _zero {
        allowances.push((amount: stated, reason: first-of(reason, "Discount")))
      } else {
        charges.push((amount: stated, reason: first-of(reason, "Surcharge")))
      }
    }

    let item-id = item.at("item-id", default: none)
    if type(item-id) == str { item-id = (seller: item-id) }
    if type(item-id) != dictionary { item-id = (:) }
    let unit = resolve-unit(item.at("unit", default: none))

    // The texts of the item, most of them not given.
    // The position, e.g. "3" or "2.1".
    let pos = item.at("pos", default: none)
    let id = if type(pos) == str and _plain-ascii in pos { pos } else if (
      pos != none
    ) { text-or-none(pos) }
    let description = item.at("description", default: none)
    let standard-id = item-id.at("standard", default: none)
    let seller-id = item-id.at("seller", default: none)
    let buyer-id = item-id.at("buyer", default: none)
    let note = item.at("note", default: none)
    if note != none { note = plain-text(note, keep-newlines: true) }
    let date = item.at("date", default: none)

    lines.push((
      index: index,
      id: if id != none { id } else { str(index + 1) },
      name: text-or-none(item.at("name", default: none)),
      description: if description != none { text-or-none(description) },
      standard-id: if standard-id != none { compact(standard-id) },
      seller-id: if seller-id != none { text-or-none(seller-id) },
      buyer-id: if buyer-id != none { text-or-none(buyer-id) },
      quantity: quantity,
      base-quantity: base-quantity,
      unit-code: unit.code,
      // A unit text without a known code, or a code that most likely means
      // something else (see `resolve-unit`).
      unit-issue: unit.issue,
      price: price,
      net: net,
      key: _tax-key(tax),
      category: category,
      rate: rate,
      // No tax was set for the item (`tax: none`), see `tax.implicit-zero`.
      implicit: tax.at("implicit", default: false),
      allowances: allowances,
      charges: charges,
      // BT-127: the note of the item, with its line breaks.
      note: if note == "" { none } else { note },
      // BG-26: the date or period of the item as `(start, end)`.
      period: if date != none { _line-period(date) },
      // BT-159: the country of origin, an ISO 3166-1 code.
      origin: item.at("origin", default: none),
    ))
    index += 1
  }
  lines
}

/// The invoice line (BG-25) of one computed item, see `line-models`.
///
/// -> dictionary
#let line-model(item, index) = {
  let line = line-models((item,)).first()
  line.index = index
  if item.at("pos", default: none) == none { line.id = str(index + 1) }
  line
}

/// The document level allowances (BG-20) and charges (BG-21): every
/// allowance or charge of the invoice is stated once per VAT group it
/// applies to (BR-53), with the amount the invoice computed for that group
/// (`split`); with gross prices, `nets` holds the net amount of each part
/// (see logic/net-amounts.typ). A part of 0 is left out. The reason is the
/// name of the allowance or charge, or "Discount" or "Surcharge" as the XML
/// states it without one (BR-33, BR-38).
///
/// -> array
#let document-allowance-charges(discounts, surcharges, nets: none) = {
  let entries = ()
  let m = 0
  for modifier in discounts + surcharges {
    let reason = text-or-none(modifier.at("name", default: none))
    let parts = if nets != none { nets.at(m) }
    m += 1
    for (key, part) in modifier.at("split", default: (:)).pairs() {
      let amount = _decimal(part.at("absolute", default: _zero))
      let net = if parts == none { calc.abs(amount) } else {
        calc.abs(parts.at(key))
      }
      if net == _zero { continue }
      let tax = part.at("tax", default: (:))
      let rate = tax.at("rate", default: _zero)
      let charge = amount > _zero
      entries.push((
        charge: charge,
        amount: net,
        reason: if reason != none { reason } else if charge {
          "Surcharge"
        } else {
          "Discount"
        },
        key: key,
        category: text-or-none(tax.at("category", default: none)),
        rate: if type(rate) == decimal { rate } else { to-ratio(rate) },
      ))
    }
  }
  entries
}

// --- Payment -------------------------------------------------------------------

// An identifier in upper case (IBAN, BIC, creditor identifier), or `none`.
#let _upper-id(value) = {
  let id = compact(value)
  if id == none { none } else { upper(id) }
}

// A payment means (BG-16) with its payment means code (BT-81), its kind (see
// `code-kind`) and the input it comes from, for messages. The details of a
// credit transfer (BG-17: `iban`, `account-name`, `bic`), a payment card
// (BG-18: `card`) and a direct debit (the debited account of BG-19,
// `debtor-iban`) are set by `payment-means-model`.
#let _means(type-code, kind, field) = (
  type-code: type-code,
  kind: kind,
  field: field,
  iban: none,
  account-name: none,
  bic: none,
  card: none,
  debtor-iban: none,
)

/// The payment means (BG-16) of the invoice, in the order of the XML: one for
/// each account of a credit transfer (`bank-details`, BG-17), the direct
/// debit, the payment card (BG-18), and the method of `paid` if none of them
/// details it (e.g. cash). An invoice has one kind of payment means; the
/// validator reports conflicting ones.
///
/// -> array
#let payment-means-model(means, currency) = {
  let entries = ()
  for bank in means.transfers {
    let iban = _upper-id(bank.at("iban", default: none))
    entries.push(
      _means(transfer-code(currency), "transfer", "bank-details")
        + (
          iban: iban,
          // Only an explicit name of `bank-details` (BT-85).
          account-name: text-or-none(bank.at("account-name", default: none)),
          // The institution of the account (BT-86), stated with the account.
          bic: if iban != none { _upper-id(bank.at("bic", default: none)) },
        ),
    )
  }
  let debit = means.direct-debit
  if debit != none {
    entries.push(
      _means(direct-debit-code(currency), "direct-debit", "direct-debit")
        + (debtor-iban: _upper-id(debit.at("debtor-iban", default: none))),
    )
  }
  let card = means.card
  if card != none {
    entries.push(
      _means(card-code(card.at("kind", default: auto)), "card", "card-payment")
        + (
          card: (
            id: card.last4,
            holder: text-or-none(card.at("holder", default: none)),
          ),
        ),
    )
  }
  let paid = means.paid
  let kind = if paid != none { paid.at("kind", default: none) }
  if kind != none {
    let detailed = (
      (kind == "transfer" and means.transfers.len() > 0)
        or (kind == "direct-debit" and debit != none)
        or (kind == "card" and card != none)
    )
    if not detailed {
      entries.push(_means(method-code(paid.method, currency), kind, "paid"))
    }
  }
  entries
}

/// A cash discount in the Skonto syntax of XRechnung (BR-DE-18): the days,
/// the percentage with two decimals and the amount it applies to, if given,
/// e.g. "#SKONTO#TAGE=14#PROZENT=2.00#".
///
/// -> str
#let skonto-line(discount) = (
  "#SKONTO#TAGE="
    + str(discount.days)
    + "#PROZENT="
    + fmt-number(discount.percent)
    + if discount.basis != none {
      "#BASISBETRAG=" + fmt-number(discount.basis)
    } else { "" }
    + "#"
)

// Payment terms of several parts, each on a line of its own.
#let _terms-lines(first, lines) = {
  let parts = if first == none { () } else { (first,) }
  payment-terms((parts + lines).join("\n"))
}

/// The payment terms (BT-20) a profile states: XRechnung states cash
/// discounts in its Skonto syntax (`terms-xrechnung`, `none` if the terms
/// have none), the other profiles as the invoice prints them.
///
/// -> none | str
#let profile-terms(payment, profile) = {
  let xrechnung = payment.at("terms-xrechnung", default: none)
  if profile.xrechnung and xrechnung != none { xrechnung } else {
    payment.terms
  }
}

/// Builds the e-invoice data model from the root context and the computed
/// line item data.
///
/// `payment-means` are the payment means of the invoice as the root context
/// resolves them (see `logic/payment-means.typ`); without them, the bank
/// details `bank` are its only payment means. `nets` are the net amounts of
/// an invoice with gross prices (`net-amounts` of logic/net-amounts.typ),
/// derived from `item-data` when `auto`.
///
/// -> dictionary
#let build-model(
  ctx,
  item-data,
  payment-goal: none,
  bank: none,
  payment-means: none,
  nets: auto,
) = {
  let sender = ctx.at("sender", default: (:))
  let recipient = ctx.at("recipient", default: (:))
  // The document type (BT-3), see `resolve-document-type`.
  let document = ctx.at("document-type", default: none)
  if type(document) != dictionary { document = resolve-document-type(auto) }
  // The buyer issues a self-billed invoice: the sender of the document is
  // the buyer and its recipient the seller. From here on, `sender` is the
  // seller and `recipient` the buyer.
  if document.self-billed {
    (sender, recipient) = (recipient, sender)
    // `invoice` adds the delivery address to the recipient; it is the
    // buyer's delivery (BG-13, `ctx.delivery-address`), not an input of the
    // seller.
    if type(sender) == dictionary {
      let _ = sender.remove("delivery-address", default: none)
    }
  }
  let profile = resolve-profile(
    ctx.at("zugferd", default: "en16931"),
    country-code(recipient),
  )

  let items = item-data.at("items", default: ())
  let taxes = item-data.at("taxes", default: (:))
  let tax-mode = item-data.at(
    "tax-mode",
    default: ctx.at("tax-mode", default: "exclusive"),
  )
  let inclusive = tax-mode == "inclusive"
  let locale = ctx.at("locale", default: (:))
  let currency-meta = locale.at("currency", default: (:))
  // With gross prices, the net amounts the XML states, derived once from the
  // printed gross amounts (logic/net-amounts.typ): loaded only for such an
  // invoice.
  if inclusive and nets == auto {
    import "../logic/net-amounts.typ": net-amounts
    let discounts = item-data.at("discounts", default: ())
    let surcharges = item-data.at("surcharges", default: ())
    nets = net-amounts(
      items,
      taxes,
      discounts + surcharges,
      digits: currency-meta.at("decimals", default: 2),
      fine: currency-meta.at("decimals-fine", default: 4),
    )
  }
  if not inclusive or nets == auto { nets = none }

  // BR-O-02: an invoice not subject to VAT carries no VAT identifiers. MINIMUM
  // has no VAT breakdown; there the seller VAT ID is needed for BR-CO-26.
  let categories = ()
  for tax in taxes.values() {
    categories.push(tax.at("category", default: none))
  }
  let outside-scope = profile.id != "minimum" and "O" in categories

  let seller = seller-model(sender, use-vat-id: not outside-scope)
  // What the printed invoice shows besides the components (see
  // `logic/printed.typ`): whether it shows the seller's VAT ID or tax number
  // the XML states (BT-31, BT-32), which the law requires on the invoice;
  // `none` if that cannot be known, e.g. with a theme that prints no
  // references.
  let printed = ctx.at("printed", default: none)
  seller.insert("printed-tax-id", shows-identifier(printed, (
    seller.vat-id,
    seller.tax-nr,
  )))
  let buyer = party-model(
    recipient,
    role: "buyer",
    use-vat-id: not outside-scope,
  )
  // BG-11 and BG-10: the parties besides seller and buyer, if any.
  let tax-representative = tax-representative-model(sender.at(
    "tax-representative",
    default: none,
  ))
  let payee = payee-model(ctx.at("payee", default: none))

  // `location-id` is another name of the deliver to location identifier
  // (BT-71), `id` of the delivery address.
  let delivery-party = ctx.at("delivery-address", default: none)
  let ship-to = if type(delivery-party) == dictionary {
    party-model(delivery-party, role: "ship-to", use-vat-id: false)
  } else if "K" in categories and buyer.address.country != none {
    // BR-IC-12: an intra-community supply names the deliver-to country;
    // without a delivery address, the goods go to the buyer.
    _ship-to-buyer(buyer.address)
  } else { none }

  let lines = line-models(
    items,
    nets: if nets != none { nets.lines },
  )
  let allowance-charges = document-allowance-charges(
    item-data.at("discounts", default: ()),
    item-data.at("surcharges", default: ()),
    nets: if nets != none { nets.modifiers },
  )

  let breakdown = taxes
    .pairs()
    .map(((key, tax)) => {
      let category = text-or-none(tax.at("category", default: none))
      let codes = exemption-codes(tax.at("codes", default: ()))
      (
        key: key,
        category: category,
        rate: to-ratio(tax.at("rate", default: 0)),
        basis: to-decimal(tax.at("basis", default: 0)),
        amount: to-decimal(tax.at("absolute", default: 0)),
        reason: exemption-reason(category, tax.at("grounds", default: none)),
        // BT-121, and the codes the items give (for the validator).
        code: exemption-code(category, codes),
        codes: codes,
        // Some item of the group has no tax (`tax: none`).
        implicit: tax.at("implicit", default: false),
      )
    })

  // Loops rather than `map` and `filter`, which call a closure per line.
  let line-total = _zero
  for line in lines { line-total += line.net }
  let allowance-total = _zero
  let charge-total = _zero
  for entry in allowance-charges {
    if entry.charge { charge-total += entry.amount } else {
      allowance-total += entry.amount
    }
  }
  // The totals the invoice prints (BT-109, BT-112 and the prepayments of
  // BT-113); the VAT total (BT-110) is the sum of the printed VAT amounts.
  let net-total = _decimal(item-data.at("net-total", default: _zero))
  let gross-total = _decimal(item-data.at("gross-total", default: _zero))
  let tax-total = _zero
  for tax in breakdown { tax-total += tax.amount }
  let means = if payment-means != none { payment-means } else {
    resolve-payment-means(
      if bank != none { (bank,) } else { () },
      none,
      none,
      none,
    )
  }
  // An invoice that is paid already (`paid`) has the total as paid amount
  // (BT-113), prepayments included, so nothing is due (BT-115).
  let prepaid-total = if means.paid != none { gross-total } else {
    _decimal(item-data.at("prepaid-total", default: _zero))
  }

  let currency = currency-code(locale)
  // How the invoice prints an amount (`format.currency`) and a unit price
  // (`format.currency-fine`), to check that it prints the currency the XML
  // states (BT-5).
  let printed-currency = (
    symbol: text-or-none(currency-meta.at("symbol", default: none)),
  )
  for (name, key) in (("amount", "currency"), ("price", "currency-fine")) {
    let formatter = locale.at("format", default: (:)).at(key, default: none)
    printed-currency.insert(name, if type(formatter) == function {
      plain-text(formatter(decimal("1")))
    })
  }

  // The service period and the date format the invoice prints it with.
  let service-period = service-period-of(ctx, items)
  let format-date = locale.at("format", default: (:)).at("date", default: none)
  let period-text = if type(format-date) == function {
    text-or-none(format-service-period(service-period, format-date))
  }
  let printed-period = _printed-service-period(ctx)

  // BT-9 and BT-20: the invoice's own `due-date` wins over `payment-terms`.
  // `terms-input` is the input the payment terms come from.
  let due-date = none
  let terms = none
  let terms-input = none
  let explicit-due-date = ctx.at("due-date", default: none)
  if type(explicit-due-date) == datetime {
    due-date = explicit-due-date
  } else {
    terms = payment-terms(explicit-due-date)
    if terms != none { terms-input = "due-date" }
  }
  if payment-goal != none {
    let goal-date = payment-goal.at("date", default: none)
    let days = payment-goal.at("days", default: none)
    let invoice-date = ctx.at("invoice-date", default: none)
    if due-date == none and type(goal-date) == datetime {
      due-date = goal-date
    } else if (
      due-date == none and type(days) == int and type(invoice-date) == datetime
    ) {
      due-date = invoice-date + duration(days: days)
    }
    if terms == none and type(goal-date) != datetime {
      terms = payment-terms(goal-date)
      if terms != none { terms-input = "payment-terms" }
    }
    // Without days or a date, `payment-terms` prints that the amount is due
    // at once ("sofort nach Erhalt"), which are the payment terms. On a
    // document whose sender pays (a credit note or a self-billed invoice),
    // it prints that the sender pays at once ("umgehend") instead.
    if terms == none and due-date == none and goal-date == none {
      let strings = (
        locale.at("strings", default: (:)).at("payment", default: (:))
      )
      let soon = strings.at("deadline-soon", default: none)
      if document.sender-pays {
        soon = strings.at("deadline-soon-credit", default: soon)
      }
      terms = payment-terms(soon)
      if terms != none { terms-input = "payment-terms" }
    }
  }
  // The cash discounts of `payment-terms` follow the terms, each on a line
  // of its own: as the invoice prints them, and in XRechnung in its Skonto
  // syntax (BR-DE-18).
  let discounts = if payment-goal != none {
    payment-goal.at("discounts", default: ())
  } else { () }
  let terms-xrechnung = none
  if discounts.len() > 0 {
    let notes = ()
    let lines = ()
    for discount in discounts {
      notes.push(plain-text(discount.note))
      lines.push(skonto-line(discount))
    }
    terms-xrechnung = _terms-lines(terms, lines)
    terms = _terms-lines(terms, notes)
    if terms-input == none { terms-input = "payment-terms" }
  }
  // A paid invoice states what it prints about the payment.
  if means.paid != none and terms == none {
    let lines = ()
    for line in means.paid.at("terms", default: ()) {
      lines.push(plain-text(line))
    }
    terms = _terms-lines(none, lines)
    if terms != none { terms-input = "paid" }
  }
  let debit = means.direct-debit

  (
    profile: profile,
    tax-mode: tax-mode,
    outside-scope: outside-scope,
    currency: currency,
    // The input the currency comes from: the invoice's `currency`, or the
    // locale.
    currency-field: if ctx.at("currency", default: auto) == auto {
      "locale"
    } else { "currency" },
    // The decimals the amounts of the currency are rounded to.
    currency-decimals: currency-meta.at("decimals", default: 2),
    printed-currency: printed-currency,
    invoice: (
      number: _key-text(ctx.at("invoice-nr", default: none), "invoice-nr"),
      type-code: document.code,
      // The resolved `document-type`, and the title printed on the document
      // (the subject without the invoice number), which must not name
      // another kind of document (IP-DOC-01).
      document: document,
      title: text-or-none(ctx.at("title", default: none)),
      issue-date: ctx.at("invoice-date", default: none),
      // A Leitweg-ID of the `id` module is stated without its scheme.
      buyer-reference: text-or-none(_id-text(first-of(
        ctx.at("buyer-reference", default: none),
        recipient.at("buyer-reference", default: none),
        recipient.at("leitweg-id", default: none),
      ))),
      order-nr: text-or-none(first-of(
        ctx.at("order-nr", default: none),
        recipient.at("order-nr", default: none),
        ctx.at("po-nr", default: none),
        recipient.at("po-nr", default: none),
      )),
      contract-nr: text-or-none(first-of(
        ctx.at("contract-nr", default: none),
        recipient.at("contract-nr", default: none),
      )),
      despatch-nr: text-or-none(first-of(
        ctx.at("delivery-note-nr", default: none),
        recipient.at("delivery-note-nr", default: none),
      )),
      preceding-invoice-nr: text-or-none(first-of(
        ctx.at("preceding-invoice-nr", default: none),
        ctx.at("original-invoice-nr", default: none),
      )),
      // BT-26, a `datetime` or `none`.
      preceding-invoice-date: ctx.at("preceding-invoice-date", default: none),
      // BT-22 and BT-21: `(content: .., subject-code: ..)` each.
      notes: _notes(ctx.at("notes", default: ())),
      // BT-11: the project reference.
      project: text-or-none(ctx.at("project", default: none)),
    ),
    seller: seller,
    buyer: buyer,
    ship-to: ship-to,
    tax-representative: tax-representative,
    payee: payee,
    // The service period (BT-72 or BG-14), see `resolve-service-period` for
    // its `source`. `text` is how `references.service-time` prints it,
    // `printed` the text of the service period the invoice prints as a
    // reference, if any, `printed-own` whether that is a text of its own
    // rather than dates, and `shown` whether the printed invoice shows the
    // date of the supply at all (see `_period-shown`).
    delivery: _delivery(service-period)
      + (
        source: if service-period != none { service-period.source },
        text: period-text,
        printed: if printed-period != none { printed-period.text },
        printed-own: printed-period != none and printed-period.own,
        shown: _period-shown(
          ctx,
          printed,
          printed-period,
          period-text,
          item-data.at("dates-printed", default: false),
        ),
      ),
    lines: lines,
    allowance-charges: allowance-charges,
    taxes: breakdown,
    // BT-106 to BT-108 add up the lines, allowances and charges of the XML;
    // the other totals are those the invoice prints (the test oracle checks
    // that they agree, tools/zugferd/guard/equivalence.typ).
    totals: (
      line: line-total,
      allowance: allowance-total,
      charge: charge-total,
      net: net-total,
      tax: tax-total,
      gross: gross-total,
      prepaid: prepaid-total,
      due: if means.paid != none { _zero } else {
        _decimal(item-data.at(
          "due-total",
          default: gross-total - prepaid-total,
        ))
      },
    ),
    payment: (
      reference: text-or-none(resolve-payment-reference(ctx, bank: bank)),
      // BG-16: the payment means and their details.
      means: payment-means-model(means, currency),
      // BG-19: the mandate reference (BT-89) and the creditor identifier
      // (BT-90) of a direct debit.
      mandate: if debit != none { _identifier(debit.mandate) },
      creditor-id: if debit != none { _upper-id(debit.creditor-id) },
      // The invoice is paid already (`paid`).
      paid: means.paid != none,
      due-date: due-date,
      // BT-20, and in XRechnung, if they differ, the terms with the cash
      // discounts in its Skonto syntax (see `profile-terms`).
      terms: terms,
      terms-xrechnung: terms-xrechnung,
      terms-input: terms-input,
      // The cash discounts of `payment-terms`: `days`, `percent` (in
      // percent) and `basis` (`none` if not given).
      discounts: discounts.map(discount => (
        days: discount.days,
        percent: discount.percent,
        basis: discount.basis,
      )),
    ),
  )
}
