#import "xml.typ": dict-to-xml, fmt-amount, fmt-date, fmt-rate, xml-escape
#import "../utils/coercion.typ": to-string

#let profile-urn(profile) = {
  if profile == "minimum" { "urn:factur-x.eu:1p0:minimum" } else if (
    profile == "basic-wl"
  ) { "urn:factur-x.eu:1p0:basicwl" } else if profile == "basic" {
    "urn:factur-x.eu:1p0:basic"
  } else if profile == "xrechnung" {
    "urn:cen.eu:en16931:2017#compliant#urn:xeinkauf.de:kosit:xrechnung_3.0"
  } else { "urn:cen.eu:en16931:2017" }
}

// Retrieve the electronic address for a party, or derive it from the VAT ID if available.
#let get-electronic-address(party, is-outside-scope: false) = {
  if "electronic-address" in party and party.electronic-address != none {
    return party.electronic-address
  }
  let vat-id = if is-outside-scope { none } else {
    party.at("vat-id", default: none)
  }
  let country-code = if (
    "country" in party and type(party.country) == dictionary
  ) {
    party.country.at("code", default: none)
  } else {
    none
  }
  if vat-id != none and vat-id != "" and country-code != none {
    let code = lower(country-code)
    let eas-codes = (
      de: "9930",
      at: "9914",
      ch: "9927",
      be: "9925",
      fr: "9918",
      nl: "9944",
      gb: "9932",
      uk: "9932",
      ie: "9935",
      it: "9906",
      es: "9920",
    )
    if code in eas-codes {
      return (scheme: eas-codes.at(code), id: vat-id)
    }
  }

  // Fallback to email
  let email = {
    if (
      "contact" in party
        and type(party.contact) == dictionary
        and "email" in party.contact
        and party.contact.email != none
    ) {
      party.contact.email
    } else if "email" in party and party.email != none {
      party.email
    } else {
      none
    }
  }
  if email != none and email != "" {
    return (scheme: "EM", id: email)
  }
  none
}

// Map common invoice-pro unit strings to UN/ECE recommendation 20 unit codes.
#let map-unit-code(unit) = {
  if type(unit) == dictionary and "code" in unit {
    return unit.code
  }
  let u = if type(unit) == str { unit } else if unit == none { "" } else {
    to-string(unit)
  }
  if u in ("HUR", "DAY", "MON", "ANN", "KGM", "GRM", "MTR", "LTR", "C62") {
    u
  } else if u in ("hrs", "hr", "h", "Std.", "Stunden") { "HUR" } else if (
    u in ("day", "days", "Tag", "Tage")
  ) { "DAY" } else if u in ("month", "months", "Monat", "Monate") {
    "MON"
  } else if u in ("year", "years", "Jahr", "Jahre") { "ANN" } else if (
    u in ("kg",)
  ) { "KGM" } else if u in ("g", "gram") { "GRM" } else if u in ("m", "meter") {
    "MTR"
  } else if u in ("l", "liter") { "LTR" } else { "C62" }
}

// Emits the exchanged document context dictionary
#let build-document-context(profile) = {
  let doc-context = (:)
  if profile in ("en16931", "xrechnung") {
    doc-context.insert(
      "ram:BusinessProcessSpecifiedDocumentContextParameter",
      (
        "ram:ID": "urn:fdc:peppol.eu:2017:poacc:billing:01:1.0",
      ),
    )
  }
  doc-context.insert(
    "ram:GuidelineSpecifiedDocumentContextParameter",
    (
      "ram:ID": profile-urn(profile),
    ),
  )
  doc-context
}

// Emits the exchanged document details
#let build-exchanged-document(invoice-nr, invoice-date) = (
  "ram:ID": if invoice-nr != none { invoice-nr } else { "" },
  "ram:TypeCode": "380",
  "ram:IssueDateTime": (
    "udt:DateTimeString": (
      "@format": "102",
      "": fmt-date(invoice-date),
    ),
  ),
)

// Emits the seller trade party details
#let build-seller-trade-party(
  name,
  address,
  city,
  postcode,
  country,
  tax-nr,
  vat-id,
  include-addresses,
  electronic-address: none,
  contact: none,
  is-outside-scope: false,
) = {
  let vat-id = if is-outside-scope { none } else { vat-id }
  let tax-registrations = {
    if vat-id != none and vat-id != "" {
      (
        (
          "ram:ID": (
            "@schemeID": "VA",
            "": vat-id,
          ),
        ),
      )
    }
    if tax-nr != none and tax-nr != "" {
      (
        (
          "ram:ID": (
            "@schemeID": "FC",
            "": tax-nr,
          ),
        ),
      )
    }
  }

  let res = (:)

  if vat-id == none or vat-id == "" {
    if tax-nr != none and tax-nr != "" {
      res.insert("ram:ID", tax-nr)
    }
  }

  res.insert("ram:Name", name)

  if contact != none {
    let details = (:)
    if "name" in contact and contact.name != none and contact.name != "" {
      details.insert("ram:PersonName", contact.name)
    }
    if "phone" in contact and contact.phone != none and contact.phone != "" {
      details.insert("ram:TelephoneUniversalCommunication", (
        "ram:CompleteNumber": contact.phone,
      ))
    }
    if "email" in contact and contact.email != none and contact.email != "" {
      details.insert("ram:EmailURIUniversalCommunication", (
        "ram:URIID": contact.email,
      ))
    }
    if details.len() > 0 {
      res.insert("ram:DefinedTradeContact", details)
    }
  }

  if include-addresses and address != none and address != () {
    let postal = (:)
    if postcode != none and postcode != "" {
      postal.insert("ram:PostcodeCode", postcode)
    }
    if type(address) == array {
      if address.len() > 0 { postal.insert("ram:LineOne", address.at(0)) }
      if address.len() > 1 { postal.insert("ram:LineTwo", address.at(1)) }
      if address.len() > 2 {
        postal.insert("ram:LineThree", address.slice(2).join(", "))
      }
    } else {
      postal.insert("ram:LineOne", address)
    }
    postal.insert("ram:CityName", city)
    postal.insert("ram:CountryID", country)
    res.insert("ram:PostalTradeAddress", postal)
  }

  if electronic-address != none {
    res.insert("ram:URIUniversalCommunication", (
      "ram:URIID": (
        "@schemeID": electronic-address.scheme,
        "": electronic-address.id,
      ),
    ))
  }

  if tax-registrations.len() > 0 {
    res.insert("ram:SpecifiedTaxRegistration", tax-registrations)
  }

  res
}

// Emits the buyer trade party details
//
// Note: unlike the seller, EN16931 only defines a VAT identifier (BT-48,
// schemeID "VA") for the buyer — there is no buyer equivalent of the
// seller's national tax number (BT-32, schemeID "FC"), so `tax-nr` is
// intentionally not used here.
#let build-buyer-trade-party(
  name,
  address,
  city,
  postcode,
  country,
  vat-id,
  include-addresses,
  electronic-address: none,
  is-outside-scope: false,
) = {
  let vat-id = if is-outside-scope { none } else { vat-id }
  let res = ("ram:Name": name)

  if include-addresses and address != none and address != () {
    let postal = (:)
    if postcode != none and postcode != "" {
      postal.insert("ram:PostcodeCode", postcode)
    }
    if type(address) == array {
      if address.len() > 0 { postal.insert("ram:LineOne", address.at(0)) }
      if address.len() > 1 { postal.insert("ram:LineTwo", address.at(1)) }
      if address.len() > 2 {
        postal.insert("ram:LineThree", address.slice(2).join(", "))
      }
    } else {
      postal.insert("ram:LineOne", address)
    }
    postal.insert("ram:CityName", city)
    postal.insert("ram:CountryID", country)
    res.insert("ram:PostalTradeAddress", postal)
  }

  if electronic-address != none {
    res.insert("ram:URIUniversalCommunication", (
      "ram:URIID": (
        "@schemeID": electronic-address.scheme,
        "": electronic-address.id,
      ),
    ))
  }

  if vat-id != none and vat-id != "" {
    res.insert("ram:SpecifiedTaxRegistration", (
      "ram:ID": (
        "@schemeID": "VA",
        "": vat-id,
      ),
    ))
  }

  res
}

// Emits a single ram:SpecifiedTradeAllowanceCharge (discount/surcharge) entry.
//
// `tax-category`/`tax-rate` are mandatory for document-level allowances/charges
// (BR-53), but intentionally omitted at line level, since the line already
// declares its own tax category via its own ApplicableTradeTax.
#let build-allowance-charge(
  is-charge,
  amount,
  reason,
  tax-category: none,
  tax-rate: none,
) = {
  let entry = (
    "ram:ChargeIndicator": (
      "udt:Indicator": if is-charge { "true" } else { "false" },
    ),
    "ram:ActualAmount": fmt-amount(calc.abs(amount)),
  )
  if reason != none and reason != "" {
    entry.insert("ram:Reason", reason)
  }
  if tax-category != none {
    entry.insert("ram:CategoryTradeTax", (
      "ram:TypeCode": "VAT",
      "ram:CategoryCode": tax-category,
      "ram:RateApplicablePercent": fmt-rate(tax-rate),
    ))
  }
  entry
}

// Emits the line-level SpecifiedTradeAllowanceCharge entries for an item's
// own discounts/surcharges (from `item()`/`bundle()` modifiers).
#let build-line-allowance-charges(discounts, surcharges) = (
  discounts.map(d => build-allowance-charge(false, d.absolute, to-string(
    d.name,
  )))
    + surcharges.map(s => build-allowance-charge(true, s.absolute, to-string(
      s.name,
    )))
)

// Emits a single supply chain line item
#let build-line-item(
  pos,
  name,
  item-id,
  price,
  quantity,
  unit,
  tax-category,
  tax-rate,
  total,
  discounts,
  surcharges,
) = {
  let unit-code = map-unit-code(unit)

  let item-ids = (:)
  if type(item-id) == dictionary {
    if "standard" in item-id and item-id.standard != none {
      item-ids.insert("ram:GlobalID", (
        "@schemeID": "0160",
        "": item-id.standard,
      ))
    }
    if "seller" in item-id and item-id.seller != none {
      item-ids.insert("ram:SellerAssignedID", item-id.seller)
    }
  }

  let applicable-trade-tax = (
    "ram:TypeCode": "VAT",
    "ram:CategoryCode": tax-category,
  )
  if tax-category != "O" {
    applicable-trade-tax.insert("ram:RateApplicablePercent", fmt-rate(tax-rate))
  }

  let line-settlement = (
    "ram:ApplicableTradeTax": applicable-trade-tax,
  )

  let line-allowance-charges = build-line-allowance-charges(
    discounts,
    surcharges,
  )
  if line-allowance-charges != () {
    line-settlement.insert(
      "ram:SpecifiedTradeAllowanceCharge",
      line-allowance-charges,
    )
  }

  let agreement-block = (
    "ram:NetPriceProductTradePrice": (
      "ram:ChargeAmount": fmt-amount(price),
    ),
  )

  line-settlement.insert(
    "ram:SpecifiedTradeSettlementLineMonetarySummation",
    ("ram:LineTotalAmount": fmt-amount(total)),
  )

  (
    "ram:AssociatedDocumentLineDocument": (
      "ram:LineID": str(pos),
    ),
    "ram:SpecifiedTradeProduct": (
      "ram:Name": name,
    )
      + item-ids,
    "ram:SpecifiedLineTradeAgreement": agreement-block,
    "ram:SpecifiedLineTradeDelivery": (
      "ram:BilledQuantity": (
        "@unitCode": unit-code,
        "": fmt-amount(quantity),
      ),
    ),
    "ram:SpecifiedLineTradeSettlement": line-settlement,
  )
}

// Emits the payment means block
#let build-payment-means(bank-iban, bank-bic) = {
  if bank-iban == none or bank-iban == "" {
    return none
  }

  let bic = if bank-bic != none and bank-bic != "" {
    (
      "ram:PayeeSpecifiedCreditorFinancialInstitution": (
        "ram:BICID": bank-bic,
      ),
    )
  } else { (:) }

  (
    (
      "ram:TypeCode": "58",
      "ram:PayeePartyCreditorFinancialAccount": (
        "ram:IBANID": bank-iban,
      ),
    )
      + bic
  )
}

// Emits the tax breakdown block
#let build-applicable-trade-tax(tax-list) = {
  tax-list.map(tax => {
    let entry = (
      "ram:CalculatedAmount": fmt-amount(tax.absolute),
      "ram:TypeCode": "VAT",
    )
    if tax.at("grounds", default: none) != none {
      entry.insert("ram:ExemptionReason", tax.grounds)
    }
    entry.insert("ram:BasisAmount", fmt-amount(tax.basis))
    entry.insert("ram:CategoryCode", tax.category)
    entry.insert("ram:RateApplicablePercent", fmt-rate(tax.rate))
    entry
  })
}

// Emits the header-level SpecifiedTradeAllowanceCharge entries for the
// document's global discounts/surcharges. A modifier spanning multiple tax
// categories is fanned out into one entry per category (BR-53).
#let build-header-allowance-charges(discounts, surcharges) = {
  let expand(modifiers, is-charge) = modifiers
    .map(mod => mod
      .split
      .values()
      .map(group => build-allowance-charge(
        is-charge,
        group.absolute,
        to-string(mod.name),
        tax-category: group.tax.category,
        tax-rate: group.tax.rate,
      )))
    .flatten()
  expand(discounts, false) + expand(surcharges, true)
}

// Emits the header monetary summation block.
//
// `line-total` (BT-131) is the sum of line net amounts *before* document-level
// allowances/charges, while `net-total` (BT-109) is the total *after* them —
// they only coincide when there are no global discounts/surcharges.
#let build-monetary-summation(
  line-total,
  net-total,
  gross-total,
  total-tax,
  allowance-total,
  charge-total,
  currency,
) = {
  let summation = ("ram:LineTotalAmount": fmt-amount(line-total))
  if charge-total > decimal("0") {
    summation.insert("ram:ChargeTotalAmount", fmt-amount(charge-total))
  }
  if allowance-total > decimal("0") {
    summation.insert("ram:AllowanceTotalAmount", fmt-amount(allowance-total))
  }
  summation.insert("ram:TaxBasisTotalAmount", fmt-amount(net-total))
  summation.insert("ram:TaxTotalAmount", (
    "@currencyID": currency,
    "": fmt-amount(total-tax),
  ))
  summation.insert("ram:GrandTotalAmount", fmt-amount(gross-total))
  summation.insert("ram:DuePayableAmount", fmt-amount(gross-total))
  summation
}

// Emits the SpecifiedTradePaymentTerms block from a `payment-goal` signal
// (see `components/payment-goal.typ`), if any data is available.
#let build-payment-terms(payment-goal, invoice-date) = {
  if payment-goal == none {
    return none
  }

  let due-date = if type(payment-goal.date) == datetime {
    payment-goal.date
  } else if payment-goal.days != none {
    invoice-date + duration(days: payment-goal.days)
  } else { none }

  if due-date != none {
    return (
      "ram:DueDateDateTime": (
        "udt:DateTimeString": (
          "@format": "102",
          "": fmt-date(due-date),
        ),
      ),
    )
  }

  if payment-goal.date != none {
    let description = to-string(payment-goal.date)
    if description != "" {
      return ("ram:Description": description)
    }
  }

  none
}

// Determine delivery date or period from items
#let determine-delivery-dates(ctx, items) = {
  let all-dates = ()
  for item in items {
    let item-date = item.at("date", default: none)
    if item-date == auto or item-date == none {
      all-dates.push(ctx.invoice-date)
    } else if type(item-date) == datetime {
      all-dates.push(item-date)
    } else if type(item-date) == array {
      for d in item-date {
        if type(d) == datetime {
          all-dates.push(d)
        }
      }
    }
  }

  let sorted-dates = all-dates.sorted().dedup()
  if sorted-dates.len() == 0 {
    (date: ctx.invoice-date, period: none)
  } else if sorted-dates.len() == 1 {
    (date: sorted-dates.first(), period: none)
  } else {
    (date: none, period: (sorted-dates.first(), sorted-dates.last()))
  }
}

/// Generates a ZUGFeRD 2.x / Factur-X 1.0 CrossIndustryInvoice XML document
/// from the fully-computed invoice context.
///
/// The XML is returned as `bytes` suitable for embedding via `pdf.attach()`.
///
/// -> bytes
#let build-zugferd-xml(ctx, item-data, payment-goal) = {
  let profile = ctx.zugferd
  if (
    profile == "en16931"
      and ctx.sender.country.code == "DE"
      and ctx.recipient.country.code == "DE"
  ) {
    profile = "xrechnung"
  }
  let currency = ctx.locale.currency.code
  let country = ctx.sender.country.code

  let bank = ctx.global.at("bank", default: none)

  let items = item-data.items
  let taxes = item-data.taxes
  let net-total = item-data.net-total
  let gross-total = item-data.gross-total
  let unmodified-net-total = item-data.at(
    "unmodified-net-total",
    default: net-total,
  )
  let discounts = item-data.at("discounts", default: ())
  let surcharges = item-data.at("surcharges", default: ())

  let include-line-items = profile in ("basic", "en16931", "xrechnung")
  let include-addresses = profile != "minimum"

  let total-tax = taxes.values().map(t => t.absolute).sum(default: decimal("0"))
  let invoice-nr-str = if ctx.invoice-nr != none { ctx.invoice-nr } else { "" }

  let line-items = if include-line-items {
    items
      .enumerate()
      .map(((i, item)) => {
        build-line-item(
          i + 1,
          item.name,
          item.at("item-id", default: none),
          item.price,
          item.quantity,
          item.unit,
          item.tax.category,
          item.tax.rate,
          item.total,
          item.discounts,
          item.surcharge,
        )
      })
  } else { () }

  let (date: delivery-date, period: delivery-period) = determine-delivery-dates(
    ctx,
    items,
  )

  let trade-settlement = (
    "ram:PaymentReference": invoice-nr-str,
    "ram:InvoiceCurrencyCode": currency,
  )

  let bank-iban = if bank != none { bank.iban } else { "" }
  let bank-bic = if bank != none { bank.bic } else { "" }
  let payment-means = build-payment-means(bank-iban, bank-bic)
  if payment-means != none {
    trade-settlement.insert(
      "ram:SpecifiedTradeSettlementPaymentMeans",
      payment-means,
    )
  }

  let applicable-taxes = build-applicable-trade-tax(taxes.values())
  if applicable-taxes != () {
    trade-settlement.insert("ram:ApplicableTradeTax", applicable-taxes)
  }

  if profile != "minimum" and delivery-period != none {
    trade-settlement.insert(
      "ram:BillingSpecifiedPeriod",
      (
        "ram:StartDateTime": (
          "udt:DateTimeString": (
            "@format": "102",
            "": fmt-date(delivery-period.first()),
          ),
        ),
        "ram:EndDateTime": (
          "udt:DateTimeString": (
            "@format": "102",
            "": fmt-date(delivery-period.last()),
          ),
        ),
      ),
    )
  }

  let header-allowance-charges = build-header-allowance-charges(
    discounts,
    surcharges,
  )
  if header-allowance-charges != () {
    trade-settlement.insert(
      "ram:SpecifiedTradeAllowanceCharge",
      header-allowance-charges,
    )
  }

  let payment-terms = build-payment-terms(payment-goal, ctx.invoice-date)
  if payment-terms != none {
    trade-settlement.insert("ram:SpecifiedTradePaymentTerms", payment-terms)
  }

  let allowance-total = discounts
    .map(d => calc.abs(d.absolute))
    .sum(default: decimal("0"))
  let charge-total = surcharges.map(s => s.absolute).sum(default: decimal("0"))

  trade-settlement.insert(
    "ram:SpecifiedTradeSettlementHeaderMonetarySummation",
    build-monetary-summation(
      unmodified-net-total,
      net-total,
      gross-total,
      total-tax,
      allowance-total,
      charge-total,
      currency,
    ),
  )

  let is-outside-scope = taxes.values().any(t => t.category == "O")

  let seller-eas = get-electronic-address(
    ctx.sender,
    is-outside-scope: is-outside-scope,
  )
  let buyer-eas = get-electronic-address(
    ctx.recipient,
    is-outside-scope: is-outside-scope,
  )

  let seller-contact = {
    let contact = ctx.sender.at("contact", default: none)
    if contact != none {
      contact
    } else {
      let contact-name = ctx.sender.at("contact-name", default: none)
      let phone = ctx.sender.at("phone", default: none)
      let email = ctx.sender.at("email", default: none)
      if contact-name != none or phone != none or email != none {
        (name: contact-name, phone: phone, email: email)
      } else {
        none
      }
    }
  }

  let buyer-ref = ctx.recipient.at("buyer-reference", default: ctx.recipient.at(
    "leitweg-id",
    default: none,
  ))

  let header-agreement = (:)
  if buyer-ref != none {
    header-agreement.insert("ram:BuyerReference", buyer-ref)
  }
  header-agreement.insert(
    "ram:SellerTradeParty",
    build-seller-trade-party(
      ctx.sender.name-inline,
      ctx.sender.address-lines,
      ctx.sender.city-name,
      ctx.sender.post-code,
      ctx.sender.country.code,
      ctx.sender.tax-nr,
      ctx.sender.vat-id,
      include-addresses,
      electronic-address: seller-eas,
      contact: seller-contact,
      is-outside-scope: is-outside-scope,
    ),
  )
  header-agreement.insert(
    "ram:BuyerTradeParty",
    build-buyer-trade-party(
      ctx.recipient.name-inline,
      ctx.recipient.address-lines,
      ctx.recipient.city-name,
      ctx.recipient.post-code,
      ctx.recipient.country.code,
      ctx.recipient.vat-id,
      include-addresses,
      electronic-address: buyer-eas,
      is-outside-scope: is-outside-scope,
    ),
  )

  let transaction = (:)
  if line-items != () {
    transaction.insert("ram:IncludedSupplyChainTradeLineItem", line-items)
  }
  transaction.insert("ram:ApplicableHeaderTradeAgreement", header-agreement)
  let header-delivery = (:)
  if profile != "minimum" and delivery-date != none {
    header-delivery = (
      "ram:ActualDeliverySupplyChainEvent": (
        "ram:OccurrenceDateTime": (
          "udt:DateTimeString": (
            "@format": "102",
            "": fmt-date(delivery-date),
          ),
        ),
      ),
    )
  }
  transaction.insert("ram:ApplicableHeaderTradeDelivery", header-delivery)
  transaction.insert("ram:ApplicableHeaderTradeSettlement", trade-settlement)

  let data = (
    "rsm:CrossIndustryInvoice": (
      "@xmlns:rsm": "urn:un:unece:uncefact:data:standard:CrossIndustryInvoice:100",
      "@xmlns:qdt": "urn:un:unece:uncefact:data:standard:QualifiedDataType:100",
      "@xmlns:ram": "urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100",
      "@xmlns:udt": "urn:un:unece:uncefact:data:standard:UnqualifiedDataType:100",
      "@xmlns:xsi": "http://www.w3.org/2001/XMLSchema-instance",
      "rsm:ExchangedDocumentContext": build-document-context(profile),
      "rsm:ExchangedDocument": build-exchanged-document(
        ctx.invoice-nr,
        ctx.invoice-date,
      ),
      "rsm:SupplyChainTradeTransaction": transaction,
    ),
  )

  let xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" + dict-to-xml(data)
  bytes(xml)
}
