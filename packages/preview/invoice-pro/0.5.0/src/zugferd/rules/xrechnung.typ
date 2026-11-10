// The checks that run only in the profile `xrechnung`: those of the German
// CIUS XRechnung 3.0 (BR-DE-*) and PEPPOL-EN16931-R120 of its Schematron;
// engine.typ loads this module for it. The other rules of XRechnung are in
// engine.typ and rare.typ, where they replace a rule of the same check in
// the other profiles (e.g. BR-DE-26 for IP-DOC-02). See engine.typ for the
// findings and the registry.

// The document types XRechnung allows (BR-DE-17).
#let _type-codes = ("326", "380", "381", "384", "389", "875", "876", "877")

/// BR-DE-17: the document type (BT-3). XRechnung only warns about it, but
/// validators such as Mustang reject the invoice, so invoice-pro reports an
/// error.
///
/// -> array
#let document-type(code) = {
  if code in _type-codes { return () }
  ((key: "BR-DE-17", field: "document-type", code: code),)
}

// XR-TELEPHONE-REGEX (three digits, BR-DE-27) and XR-EMAIL-REGEX (BR-DE-28)
// of the XRechnung 3.0 Schematron, compiled on first use.
#let _patterns() = (
  digit: regex("[0-9]"),
  email: regex(
    "^[a-zA-Z0-9!#$%&\"*+/=?^_`{|}~-]+(\\.[a-zA-Z0-9!#$%&\"*+/=?^_`{|}~-]+)*@([a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?\\.)+[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$",
  ),
)

/// The seller contact (BG-6), the cities and post codes of the addresses
/// and the buyer reference (BT-10), which XRechnung requires.
///
/// -> array
#let parties(model) = {
  let out = ()
  let seller = model.seller
  let buyer = model.buyer
  let contact = seller.contact
  if contact == none {
    out.push((key: "BR-DE-2", field: "sender.contact"))
  } else {
    for (key, rule) in (
      ("name", "BR-DE-5"),
      ("phone", "BR-DE-6"),
      ("email", "BR-DE-7"),
    ) {
      if contact.at(key) == none {
        out.push((key: rule, field: "sender.contact." + key, input: key))
      }
    }
    // XRechnung only warns about BR-DE-27 and BR-DE-28, but validators such
    // as Mustang reject the invoice, so invoice-pro reports errors.
    if (
      contact.phone != none
        and contact.phone.matches(_patterns().digit).len() < 3
    ) {
      out.push((
        key: "BR-DE-27",
        field: "sender.contact.phone",
        phone: contact.phone,
      ))
    }
    if (
      contact.email != none and contact.email.match(_patterns().email) == none
    ) {
      out.push((
        key: "BR-DE-28",
        field: "sender.contact.email",
        email: contact.email,
      ))
    }
  }

  for (party, field, city-rule, code-rule, term) in (
    (seller, "sender", "BR-DE-3", "BR-DE-4", "seller"),
    (buyer, "recipient", "BR-DE-8", "BR-DE-9", "buyer"),
    (model.ship-to, "delivery-address", "BR-DE-10", "BR-DE-11", "deliver-to"),
  ) {
    if party == none { continue }
    if party.address.city == none {
      out.push((
        key: city-rule,
        field: field + ".city",
        party: field,
        term: term,
      ))
    }
    if party.address.post-code == none {
      out.push((
        key: code-rule,
        field: field + ".city",
        party: field,
        term: term,
      ))
    }
  }

  if model.invoice.buyer-reference == none {
    // A buyer reached by its Leitweg-ID (EAS 0204) names it as reference.
    let address = buyer.at("electronic-address", default: none)
    out.push((
      key: "BR-DE-15",
      field: "recipient.buyer-reference",
      routing: if (
        type(address) == dictionary
          and address.at("scheme", default: none) == "0204"
      ) { address.at("id", default: none) },
    ))
  }
  out
}

// BR-DE-18, as the XRechnung 3.0 validation tests it: each line of the
// payment terms (BT-20) that starts with "#" matches XR-SKONTO-REGEX, and the
// text after the last "#...#" starts with a line break.
#let _skonto-line() = regex(
  "#(SKONTO)#TAGE=([0-9]+#PROZENT=[0-9]+\\.[0-9]{2})(#BASISBETRAG=-?[0-9]+\\.[0-9]{2})?#$",
)
// Whitespace as XPath's normalize-space() collapses it, and `\s` of XPath
// regular expressions: a space, tab or line break.
#let _xml-whitespace = regex("[ \\t\\r\\n]+")

// What breaks the XRechnung Skonto syntax in the payment terms (BR-DE-18):
// `none` if nothing does, `(line: ..)` for a line that starts with "#" but is
// no cash discount, and `(after: ..)` for the line of the last "#...#" if no
// line break follows it.
#let _skonto-problem(terms) = {
  let lines = terms.split("\n")
  let skonto = false
  for line in lines {
    let normalized = line.replace(_xml-whitespace, " ").trim(" ")
    if normalized.starts-with("#") {
      if normalized.match(_skonto-line()) == none {
        return (line: normalized)
      }
      skonto = true
    }
  }
  if not skonto { return none }
  // The validation splits the terms at `#.+#`, whose `.` is no line break:
  // the last "#...#" reaches from the first to the last "#" of the last line
  // with two "#" and text between them. (No regular expression: compiling
  // this one takes a third of a millisecond on every compile.)
  for i in range(lines.len() - 1, -1, step: -1) {
    let parts = lines.at(i).split("#")
    if parts.len() >= 3 and parts.slice(1, -1).join("#") != "" {
      if (
        i < lines.len() - 1 and parts.last().replace(_xml-whitespace, "") == ""
      ) {
        return none
      }
      return (after: lines.at(i).replace(_xml-whitespace, " ").trim(" "))
    }
  }
  none
}

/// BR-DE-18: the Skonto syntax of the payment terms (BT-20) `terms` as the
/// profile states them, and the amounts the cash discounts apply to, which
/// XRechnung states with 2 decimals.
///
/// -> array
#let payment-terms(payment, terms) = {
  let out = ()
  if terms != none {
    let problem = _skonto-problem(terms)
    if problem != none {
      let input = payment.at("terms-input", default: none)
      out.push((
        key: "BR-DE-18",
        field: if input == none { "payment-goal" } else { input },
        line: problem.at("line", default: none),
        after: problem.at("after", default: none),
      ))
    }
  }
  for discount in payment.at("discounts", default: ()) {
    let basis = discount.basis
    if basis != none and calc.round(basis, digits: 2) != basis {
      out.push((
        key: "BR-DE-18",
        field: "payment-goal.discount",
        basis: basis,
      ))
    }
  }
  out
}

/// PEPPOL-EN16931-R120: a line's net amount is its quantity times its price
/// per base quantity, plus its charges, minus its allowances, within 0.02
/// (0.5 for HUF). A total rounded more coarsely than its price breaks it.
///
/// -> array
#let line-amounts(model, line-field) = {
  let slack = decimal(if model.currency == "HUF" { "0.5" } else { "0.02" })
  let out = ()
  for line in model.lines {
    let expected = line.quantity * line.price / line.base-quantity
    for entry in line.charges { expected += entry.amount }
    for entry in line.allowances { expected -= entry.amount }
    let off = line.net - expected
    if off > slack or off < -slack {
      out.push((
        key: "PEPPOL-EN16931-R120",
        field: line-field(line),
        net: line.net,
        quantity: line.quantity,
        price: line.price,
        base-quantity: line.base-quantity,
        expected: expected,
        slack: slack,
      ))
    }
  }
  out
}
