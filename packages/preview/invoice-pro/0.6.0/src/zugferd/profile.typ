// Factur-X / ZUGFeRD profiles and the parts of the invoice each one carries.
//
// The flags mirror the Factur-X 1.09 (ZUGFeRD 2.5) schemas: the builder
// leaves out whatever a profile's schema does not allow, and the validator
// only checks what ends up in the XML.

#let _base = (
  // BT-23: business process, only announced by the EN 16931 based profiles.
  business-process: none,
  // BG-25: invoice lines.
  lines: false,
  // BG-5, BG-8, BG-15 (postal addresses beyond the seller country), BT-34,
  // BT-49 (electronic addresses) and the delivery information (BG-13).
  addresses: false,
  // BG-16, BG-20, BG-21, BG-23, BT-20, BT-83: payment instructions, document
  // level allowances and charges, VAT breakdown, payment terms and reference.
  settlement: false,
  // BT-29, BT-46: party identifiers (`ram:ID`, `ram:GlobalID`).
  party-ids: false,
  // BT-48: buyer VAT identifier.
  buyer-vat-id: false,
  // BG-6: seller contact.
  seller-contact: false,
  // BT-28: seller trading name. (The legal registration identifiers BT-30
  // and BT-47 are part of every profile.)
  seller-trading-name: false,
  // BT-33: seller additional legal information.
  seller-legal-info: false,
  // BT-45: buyer trading name.
  buyer-trading-name: false,
  // BG-9: buyer contact.
  buyer-contact: false,
  // BG-10: payee.
  payee: false,
  // BG-11: seller tax representative.
  tax-representative: false,
  // BT-86: BIC of the payment service provider.
  bic: false,
  // BT-85: name of the payment account.
  account-name: false,
  // BG-18: payment card (BT-87, BT-88). The profiles without it state only
  // the payment means code of a card payment (BT-81).
  payment-card: false,
  // BT-155, BT-156: seller and buyer assigned item identifiers.
  item-ids: false,
  // BT-154: item description.
  item-description: false,
  // BT-12, BT-16, BT-25: contract, despatch advice and preceding invoice.
  document-references: false,
  // BT-21, BT-22: invoice notes.
  notes: false,
  // BT-11: project reference.
  procuring-project: false,
  // BT-159: country of origin of an item.
  item-origin: false,
  // The EN 16931 business rules (BR-*) apply to the whole document.
  en16931: false,
  // The CEN Schematron of EN 16931 validates the document, with its code
  // lists and the rules of the CII syntax (CII-*): KoSIT in EN 16931, both
  // validators in XRechnung. The validation of MINIMUM to BASIC applies the
  // Factur-X Schematron alone, which states the business rules itself.
  cen: false,
  // The German CIUS XRechnung (BR-DE-*) applies on top of EN 16931.
  xrechnung: false,
  // The name of the embedded XML file: "factur-x.xml", and "xrechnung.xml"
  // for the XRECHNUNG profile (ZUGFeRD 2.3 and later, as Mustang embeds it
  // as well).
  file-name: "factur-x.xml",
)

#let profiles = (
  minimum: _base
    + (
      name: "MINIMUM",
      guideline: "urn:factur-x.eu:1p0:minimum",
    ),
  basic-wl: _base
    + (
      name: "BASIC WL",
      guideline: "urn:factur-x.eu:1p0:basicwl",
      addresses: true,
      settlement: true,
      party-ids: true,
      buyer-vat-id: true,
      seller-trading-name: true,
      payee: true,
      tax-representative: true,
      document-references: true,
      notes: true,
    ),
  // BASIC is a CIUS of EN 16931 and therefore carries the EN 16931 prefix.
  basic: _base
    + (
      name: "BASIC",
      guideline: "urn:cen.eu:en16931:2017#compliant#urn:factur-x.eu:1p0:basic",
      lines: true,
      addresses: true,
      settlement: true,
      party-ids: true,
      buyer-vat-id: true,
      seller-trading-name: true,
      payee: true,
      tax-representative: true,
      document-references: true,
      notes: true,
      en16931: true,
    ),
  en16931: _base
    + (
      name: "EN 16931 (COMFORT)",
      guideline: "urn:cen.eu:en16931:2017",
      business-process: "urn:fdc:peppol.eu:2017:poacc:billing:01:1.0",
      lines: true,
      addresses: true,
      settlement: true,
      party-ids: true,
      buyer-vat-id: true,
      seller-contact: true,
      seller-trading-name: true,
      seller-legal-info: true,
      buyer-trading-name: true,
      buyer-contact: true,
      payee: true,
      tax-representative: true,
      bic: true,
      account-name: true,
      payment-card: true,
      item-ids: true,
      item-description: true,
      procuring-project: true,
      item-origin: true,
      document-references: true,
      notes: true,
      en16931: true,
      cen: true,
    ),
  xrechnung: _base
    + (
      name: "XRechnung 3.0",
      guideline: "urn:cen.eu:en16931:2017#compliant#urn:xeinkauf.de:kosit:xrechnung_3.0",
      business-process: "urn:fdc:peppol.eu:2017:poacc:billing:01:1.0",
      lines: true,
      addresses: true,
      settlement: true,
      party-ids: true,
      buyer-vat-id: true,
      seller-contact: true,
      seller-trading-name: true,
      seller-legal-info: true,
      buyer-trading-name: true,
      buyer-contact: true,
      payee: true,
      tax-representative: true,
      bic: true,
      account-name: true,
      payment-card: true,
      item-ids: true,
      item-description: true,
      procuring-project: true,
      item-origin: true,
      document-references: true,
      notes: true,
      en16931: true,
      cen: true,
      xrechnung: true,
      file-name: "xrechnung.xml",
    ),
)

/// Resolves the profile the XML is written in.
///
/// An explicit profile is used as given. `auto` lists the candidates, best
/// first: `"xrechnung"`, the German CIUS of EN 16931, for a buyer in Germany,
/// then `"en16931"`. `process-zugferd` takes the first candidate the invoice
/// satisfies.
///
/// -> dictionary
#let resolve-profile(requested, buyer-country) = {
  let automatic = requested == auto
  let candidates = if not automatic { (requested,) } else if (
    buyer-country == "DE"
  ) { ("xrechnung", "en16931") } else { ("en16931",) }
  (
    id: candidates.first(),
    requested: requested,
    automatic: automatic,
    candidates: candidates,
    skipped: (),
    ..profiles.at(candidates.first(), default: profiles.en16931),
  )
}

/// A resolved profile switched to another of its candidates.
///
/// -> dictionary
#let switch-profile(profile, id) = profile + profiles.at(id) + (id: id)
