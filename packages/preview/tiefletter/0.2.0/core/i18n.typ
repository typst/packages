#import "utils.typ": format-currency

#let languages = (
  english: "en",
  english-at: "en-at",
  english-de: "en-de",
  english-us: "en-us",
  deutsch: "de",
  deutsch-at: "de-at",
  deutsch-de: "de-de",
)

#let lang = state("language-state", languages.english)

/// Selects a language to use in the document. Select from `languages`.
#let select-language(language) = {
  lang.update(language)
}

#let normalize-lang(language: none) = {
  let candidate = if language == none { lang.get() } else { language }

  if candidate in ("en", "en-us", "en-at") {
    "en-at"
  } else if candidate in "en-de" {
    "en-de"
  } else if candidate in ("de", "de-at") {
    "de-at"
  } else if candidate in "de-de" {
    "de-de"
  } else {
    candidate
  }
}

#let letter-base-en = (
  salutation-f: [Dear Ms.],
  salutation-m: [Dear Mr.],
  salutation-o: [Dear],
  table-label: (
    item-number: [*No.*],
    description: [*Description*],
    quantity: [*Qty.*],
    single-price: [*€ / Pcs.*],
    vat-rate: [*VAT Rate*],
    vat-price: [*€ VAT*],
    total-price: [*€ Total*],
  ),
  total-no-vat: [Total excl. VAT],
  total-vat: [VAT],
  total-with-vat: [Total incl. VAT],
)

#let invoice-base-en = (
  invoice: [Invoice],
  invoice-date: [Invoice Date],
  pre-table: number => [We hereby submit to you our invoice with No. #number\. Please find the invoiced items below:],
  request-payment: (total-with-vat, payment-due-date, number) => {
    [Please pay the amount of #format-currency(total-with-vat) until #payment-due-date at the latest to the following account with reference #number:]
  },
  payment: (
    recipient: [Recipient:],
    iban: [IBAN:],
    bic: [BIC:],
    amount: [Amount:],
    reference: [Reference:],
    pay-via-qr: [Payment by QR code],
  ),
  delivery-date: delivery-date => if delivery-date == none {
    [The delivery date is, unless otherwise specified, equivalent to the invoice date.]
  } else { [The delivery date is, unless otherwise specified, on or in #delivery-date.] },
  closing: [Thank you for your business and with kind regards,],
)

#let offer-base-en = (
  offer: [Offer],
  offer-date: [Offer Date],
  pre-offer: number => [We hereby submit to you our offer with No. #number\.],
  pre-table: [Please find the offered items below, individually orderable:],
  post-table: (total, pre-payment-amount, proforma-invoice, offer-valid-until) => {
    [
      #if pre-payment-amount == none or pre-payment-amount == 0 {
        if proforma-invoice { [Upon acceptance of this offer, we will send you a proforma invoice.] } else { [] }
      } else {
        [Upon acceptance of this offer, we will send you #if proforma-invoice { [both] } an invoice for a prepayment of #pre-payment-amount % of the total amount (€ #format-currency(total * (pre-payment-amount / 100))) #if proforma-invoice { [and a proforma invoice] }. The prepayment is to be made before the start of the project. The remaining amount is to be paid 14 days after delivery.]
      }

      #if offer-valid-until == none {
        [The offer is valid for 30 days from the date of issue.]
      } else {
        [The offer is valid until #offer-valid-until.]
      }

    ]
  },
  closing: [I am looking forward to your response, and am always available for further questions.

    With kind regards,],
)

#let kleinunternehmer-regelung-en-at = [In accordance with § 6. Abs. 1 Z 27 (Kleinunternehmerregelung) relieved of VAT.]
#let kleinunternehmer-regelung-en-de = [In accordance with § 19 UStG (Kleinunternehmerregelung) relieved of VAT.]
#let kleinunternehmer-regelung-en-us = [Relieved of VAT.]

#let i18n-en-at = (
  letter: letter-base-en,
  invoice: (
    ..invoice-base-en,
    kleinunternehmer-regelung: kleinunternehmer-regelung-en-at,
  ),
  offer: (
    ..offer-base-en,
    kleinunternehmer-regelung: kleinunternehmer-regelung-en-at,
  ),
)

#let i18n-en-de = (
  letter: letter-base-en,
  invoice: (
    ..invoice-base-en,
    kleinunternehmer-regelung: kleinunternehmer-regelung-en-de,
  ),
  offer: (
    ..offer-base-en,
    kleinunternehmer-regelung: kleinunternehmer-regelung-en-de,
  ),
)

#let i18n-en-us = (
  letter: letter-base-en,
  invoice: (
    ..invoice-base-en,
    kleinunternehmer-regelung: kleinunternehmer-regelung-en-us,
  ),
  offer: (
    ..offer-base-en,
    kleinunternehmer-regelung: kleinunternehmer-regelung-en-us,
  ),
)

#let letter-base-de = (
  salutation-f: [Sehr geehrte Frau],
  salutation-m: [Sehr geehrter Herr],
  salutation-o: [Guten Tag],
  table-label: (
    item-number: [*Pos.*],
    description: [*Bezeichnung*],
    quantity: [*Menge*],
    single-price: [*€ / Stk*],
    vat-rate: [*USt. Satz*],
    vat-price: [*€ USt.*],
    total-price: [*€ Ges.*],
  ),
  total-no-vat: [€ Netto:],
  total-vat: [USt. Gesamt:],
  total-with-vat: [€ Brutto:],
)

#let invoice-base-de = (
  invoice: [Rechnung],
  invoice-date: [Rechnungsdatum],
  pre-table: number => [Hiermit übermitteln wir Ihnen Ihre Rechnung Nr. #number\. Zudem nachfolgend die verrechneten Positionen:],
  request-payment: (total-with-vat, payment-due-date, number) => {
    [Es wird um Leistung der Zahlung von #format-currency(total-with-vat) bis spätestens #payment-due-date auf unser Bankkonto unter Angabe der Rechnungsnummer '#number' gebeten.]
  },
  payment: (
    recipient: [Empfänger:],
    iban: [IBAN:],
    bic: [BIC:],
    amount: [Betrag:],
    reference: [Zahlungsreferenz:],
    pay-via-qr: [Zahlung via QR Code],
  ),
  delivery-date: delivery-date => if delivery-date == none {
    [Der Lieferzeitpunkt ist, falls nicht anders angegeben, das Rechnungsdatum.]
  } else { [Der Lieferzeitpunkt/Lieferzeitraum ist, falls nicht anders angegeben, am/im #delivery-date.] },
  closing: [Mit vielem Dank für Ihr Vertrauen und freundlichen Grüßen,],
)

#let offer-base-de = (
  offer: [Angebot],
  offer-date: [Angebotsdatum],
  pre-offer: number => [Hiermit übermitteln wir Ihnen unser Angebot Nr. #number\.],
  pre-table: [Zudem nachfolgend die angebotenen Positionen, einzeln beauftragbar:],
  post-table: (total, pre-payment-amount, proforma-invoice, offer-valid-until) => {
    [
      #if pre-payment-amount == none or pre-payment-amount == 0 {
        if proforma-invoice {
          [Mit Annahme dieses Angebots werden wir Ihnen eine Proformarechnung übermitteln.]
        } else { [] }
      } else {
        [Mit Annahme dieses Angebots werden wir Ihnen #if proforma-invoice { [sowohl] } eine Rechnung zur Vorauszahlung über #pre-payment-amount % des Gesamtbetrages (€ #format-currency(total * (pre-payment-amount / 100))) #if proforma-invoice { [als auch eine Proformarechnung ] }übermitteln. Die Vorauszahlung ist vor Beginn des Projektes zu leisten. Die Restzahlung ist binnen 14 Tagen nach Lieferung zu leisten.]
      }

      #if offer-valid-until == none {
        [Dieses Angebot ist für 30 Tage ab Erstellung gültig.]
      } else {
        [Dieses Angebot ist maximal Gültig bis #offer-valid-until.]
      }

    ]
  },
  closing: [Ich freue mich auf Ihre Antwort, und stehe stets für Rückfragen zur Verfügung.

    Mit freundlichen Grüßen,],
)

#let kleinunternehmer-regelung-de-at = [Gemäß § 6. Abs. 1 Z 27 UStG (Kleinunternehmerregelung) von der USt. ausgenommen.]
#let kleinunternehmer-regelung-de-de = [Kein Ausweis von Umsatzsteuer gemäß § 19 UStG (Kleinunternehmerregelung).]

#let i18n-de-at = (
  letter: letter-base-de,
  invoice: (
    ..invoice-base-de,
    kleinunternehmer-regelung: kleinunternehmer-regelung-de-at,
  ),
  offer: (
    ..offer-base-de,
    kleinunternehmer-regelung: kleinunternehmer-regelung-de-at,
  ),
)

#let i18n-de-de = (
  letter: letter-base-de,
  invoice: (
    ..invoice-base-de,
    kleinunternehmer-regelung: kleinunternehmer-regelung-de-de,
  ),
  offer: (
    ..offer-base-de,
    kleinunternehmer-regelung: kleinunternehmer-regelung-de-de,
  ),
)

#let i18n-table = (
  "en-at": i18n-en-at,
  "en-de": i18n-en-de,
  "en-us": i18n-en-us,
  "de-at": i18n-de-at,
  "de-de": i18n-de-de,
)

#let i18n(language: none) = {
  let resolved = normalize-lang(language: language)
  let entry = i18n-table.at(resolved, default: none)

  if entry == none {
    assert(false, message: "Selected language '" + resolved + "' is not available yet.")
  }

  entry
}

#let letter-translations(language: none) = {
  i18n(language: language).letter
}

#let invoice-translations(language: none, invoice-number: none, delivery-date: none, payment-due-date: none) = {
  let base = i18n(language: language).invoice

  (
    invoice: base.invoice,
    invoice-date: base.at("invoice-date"),
    pre-table: base.at("pre-table")(invoice-number),
    request-payment: total-with-vat => base.at("request-payment")(total-with-vat, payment-due-date, invoice-number),
    payment: base.payment,
    kleinunternehmer-regelung: base.at("kleinunternehmer-regelung"),
    delivery-date: base.at("delivery-date")(delivery-date),
    closing: base.closing,
  )
}

#let offer-translations(
  language: none,
  offer-number: none,
  offer-valid-until: none,
  pre-payment-amount: none,
  proforma-invoice: none,
) = {
  let base = i18n(language: language).offer

  (
    offer: base.offer,
    offer-date: base.at("offer-date"),
    pre-offer: base.at("pre-offer")(offer-number),
    pre-table: base.at("pre-table"),
    post-table: total => base.at("post-table")(total, pre-payment-amount, proforma-invoice, offer-valid-until),
    kleinunternehmer-regelung: base.at("kleinunternehmer-regelung"),
    closing: base.closing,
  )
}
