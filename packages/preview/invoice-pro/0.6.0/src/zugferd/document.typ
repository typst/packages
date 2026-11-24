// The kind of document the title of an invoice names (e.g. "Gutschrift",
// "Angebot" or "Credit note"), which the validator compares with the
// document type of the e-invoice (IP-DOC-01).

// Words and phrases (in lower case) that name a kind of document in the
// languages of invoice-pro, by the kind:
// - "invoice": an invoice, which the e-invoice states without a
//   `document-type` (e.g. "Rechnung zum Angebot 17" is an invoice),
// - "credit-note", "corrected", "self-billed": documents with a document
//   type of their own,
// - "credit-note-or-self-billed": "Gutschrift", which German VAT law uses for
//   self-billed invoices, and colloquially for credit notes,
// - "quote", "delivery-note", "order", "pro-forma", "reminder": documents
//   that are no invoice at all.
#let _title-words = (
  // Invoices
  "rechnung": "invoice",
  "invoice": "invoice",
  "facture": "invoice",
  "fattura": "invoice",
  "factura": "invoice",
  "tax invoice": "invoice",
  "commercial invoice": "invoice",
  "teilrechnung": "invoice",
  "abschlagsrechnung": "invoice",
  "schlussrechnung": "invoice",
  "anzahlungsrechnung": "invoice",
  "vorauszahlungsrechnung": "invoice",
  // Credit notes
  "gutschrift": "credit-note-or-self-billed",
  "gutschriftsanzeige": "credit-note",
  "rechnungskorrektur": "credit-note",
  "korrekturrechnung": "credit-note",
  "stornorechnung": "credit-note",
  "storno": "credit-note",
  "credit note": "credit-note",
  "credit memo": "credit-note",
  "credit invoice": "credit-note",
  "creditnote": "credit-note",
  "avoir": "credit-note",
  "facture d avoir": "credit-note",
  "note de crédit": "credit-note",
  "nota di credito": "credit-note",
  "nota credito": "credit-note",
  "nota de crédito": "credit-note",
  "nota de abono": "credit-note",
  "factura de abono": "credit-note",
  // Corrected invoices
  "korrigierte rechnung": "corrected",
  "berichtigte rechnung": "corrected",
  "rechnungsberichtigung": "corrected",
  "corrected invoice": "corrected",
  "corrective invoice": "corrected",
  "invoice correction": "corrected",
  "facture rectificative": "corrected",
  "facture corrigée": "corrected",
  "fattura rettificativa": "corrected",
  "fattura correttiva": "corrected",
  "factura rectificativa": "corrected",
  "factura corregida": "corrected",
  // Self-billed invoices
  "self billing": "self-billed",
  "self billed": "self-billed",
  "autofacturation": "self-billed",
  "autofattura": "self-billed",
  "autofatturazione": "self-billed",
  "autofactura": "self-billed",
  "facturación por el destinatario": "self-billed",
  // No invoices
  "angebot": "quote",
  "kostenvoranschlag": "quote",
  "kostenangebot": "quote",
  "preisangebot": "quote",
  "quote": "quote",
  "quotation": "quote",
  "offer": "quote",
  "estimate": "quote",
  "devis": "quote",
  "offre": "quote",
  "preventivo": "quote",
  "offerta": "quote",
  "presupuesto": "quote",
  "oferta": "quote",
  "cotización": "quote",
  "lieferschein": "delivery-note",
  "delivery note": "delivery-note",
  "packing slip": "delivery-note",
  "packing list": "delivery-note",
  "bon de livraison": "delivery-note",
  "documento di trasporto": "delivery-note",
  "bolla di consegna": "delivery-note",
  "albarán": "delivery-note",
  "nota de entrega": "delivery-note",
  "auftragsbestätigung": "order",
  "bestellbestätigung": "order",
  "bestellung": "order",
  "order confirmation": "order",
  "purchase order": "order",
  "confirmation de commande": "order",
  "bon de commande": "order",
  "conferma d ordine": "order",
  "conferma ordine": "order",
  "confirmación de pedido": "order",
  "proforma": "pro-forma",
  "pro forma": "pro-forma",
  "proformarechnung": "pro-forma",
  "facture proforma": "pro-forma",
  "facture pro forma": "pro-forma",
  "fattura proforma": "pro-forma",
  "fattura pro forma": "pro-forma",
  "factura proforma": "pro-forma",
  "factura pro forma": "pro-forma",
  "mahnung": "reminder",
  "zahlungserinnerung": "reminder",
  "payment reminder": "reminder",
  "reminder": "reminder",
  "relance": "reminder",
  "sollecito": "reminder",
  "recordatorio de pago": "reminder",
)

// The subject codes of notes (BT-21) the EN 16931 validation accepts
// (BR-CL-08, a restriction of UNTDID 4451), identical to the code list of
// the Factur-X profiles. One text instead of a table: notes are few, and
// most have no subject code.
#let _note-subject-codes = (
  " AAA AAB AAC AAD AAE AAF AAG AAI AAJ AAK AAL AAM AAN AAO AAP AAQ AAR AAS"
    + " AAT AAU AAV AAW AAX AAY AAZ ABA ABB ABC ABD ABE ABF ABG ABH ABI ABJ ABK"
    + " ABL ABM ABN ABO ABP ABQ ABR ABS ABT ABU ABV ABW ABX ABZ ACA ACB ACC ACD"
    + " ACE ACF ACG ACH ACI ACJ ACK ACL ACM ACN ACO ACP ACQ ACR ACS ACT ACU ACV"
    + " ACW ACX ACY ACZ ADA ADB ADC ADD ADE ADF ADG ADH ADI ADJ ADK ADL ADM ADN"
    + " ADO ADP ADQ ADR ADS ADT ADU ADV ADW ADX ADY ADZ AEA AEB AEC AED AEE AEF"
    + " AEG AEH AEI AEJ AEK AEL AEM AEN AEO AEP AEQ AER AES AET AEU AEV AEW AEX"
    + " AEY AEZ AFA AFB AFC AFD AFE AFF AFG AFH AFI AFJ AFK AFL AFM AFN AFO AFP"
    + " AFQ AFR AFS AFT AFU AFV AFW AFX AFY AFZ AGA AGB AGC AGD AGE AGF AGG AGH"
    + " AGI AGJ AGK AGL AGM AGN AGO AGP AGQ AGR AGS AGT AGU AGV AGW AGX AGY AGZ"
    + " AHA AHB AHC AHD AHE AHF AHG AHH AHI AHJ AHK AHL AHM AHN AHO AHP AHQ AHR"
    + " AHS AHT AHU AHV AHW AHX AHY AHZ AIA AIB AIC AID AIE AIF AIG AIH AII AIJ"
    + " AIK AIL AIM AIN AIO AIP AIQ AIR AIS AIT AIU AIV AIW AIX AIY AIZ AJA AJB"
    + " ALC ALD ALE ALF ALG ALH ALI ALJ ALK ALL ALM ALN ALO ALP ALQ ARR ARS AUT"
    + " AUU AUV AUW AUX AUY AUZ AVA AVB AVC AVD AVE AVF BAG BAH BAI BAJ BAK BAL"
    + " BAM BAN BAO BAP BAQ BAR BAS BAT BAU BAV BAW BAX BAY BAZ BBA BBB BLC BLD"
    + " BLE BLF BLG BLH BLI BLJ BLK BLL BLM BLN BLO BLP BLQ BLR BLS BLT BLU BLV"
    + " BLW BLX BLY BLZ BMA BMB BMC BMD BME BMF BMG BMH CCI CCJ CCK CCL CCM CCN"
    + " CCO CEX CHG CIP CLP CLR COI CUR CUS DAR DCL DEL DIN DOC DUT EUR FBC GBL"
    + " GEN GS7 HAN HAZ ICN IIN IMI IND INS INV IRP ITR ITS LAN LIN LOI MCO MDH"
    + " MKS ORI OSI PAC PAI PAY PKG PKT PMD PMT PRD PRF PRI PUR QIN QQD QUT RAH"
    + " REG RET REV RQR SAF SIC SIN SLR SPA SPG SPH SPP SPT SRN SSR SUR TCA TDT"
    + " TRA TRR TXD WHI ZZZ "
)

/// Whether a text is a subject code of a note (BT-21) the EN 16931
/// validation accepts (BR-CL-08).
///
/// -> bool
#let note-subject-code-valid(code) = (
  type(code) == str
    and code.len() == 3
    and _note-subject-codes.contains(" " + code + " ")
)

// Runs of ASCII characters that are no letters: spaces, digits and
// punctuation separate the words of a title. (ASCII only: a Unicode class
// takes a fraction of a millisecond to compile.)
#let _separators = regex("[\\x00-\\x40\\x5B-\\x60\\x7B-\\x7F]+")

// Punctuation outside ASCII that separates words as well.
#let _unicode-separators = (
  "–",
  "—",
  "„",
  "“",
  "”",
  "‘",
  "’",
  "«",
  "»",
  "\u{a0}",
  "\u{202f}",
)

/// The kind of document a title names (see `_title-words`), or `none` if it
/// names none. The first word or phrase of the title that names a kind
/// decides, so that "Rechnung zum Angebot 17" is an invoice and "Angebot
/// zur Rechnung 17" a quote; of the phrases starting at the same word, the
/// longest one (e.g. "facture proforma" rather than "facture").
///
/// Returns `(kind: .., words: ..)`, with the words of the title that name it.
///
/// -> none | dictionary
#let title-kind(title) = {
  if type(title) != str or title == "" { return none }
  let text = lower(title)
  for separator in _unicode-separators {
    if text.contains(separator) { text = text.replace(separator, " ") }
  }
  let words = ()
  for word in text.split(_separators) {
    if word != "" { words.push(word) }
  }
  for i in range(words.len()) {
    for length in (4, 3, 2, 1) {
      if i + length > words.len() { continue }
      let phrase = words.slice(i, i + length).join(" ")
      let kind = _title-words.at(phrase, default: none)
      if kind != none { return (kind: kind, words: phrase) }
    }
  }
  none
}
