// The document type of an invoice (`invoice(document-type: ..)`, BT-3 of the
// e-invoice): the named types and the UNTDID 1001 codes the e-invoice
// profiles accept, with what each one means for the printed document, its
// default title and who pays whom.

/// The document types `invoice` names, with their UNTDID 1001 code (BT-3).
///
/// - `"invoice"`: a commercial invoice (380).
/// - `"credit-note"`: a credit note (381); its amounts are credited to the
///   buyer and stated as positive amounts.
/// - `"corrected"`: a corrected invoice (384), which replaces the preceding
///   invoice (`preceding-invoice-nr`).
/// - `"prepayment"`: a prepayment invoice (386) for an advance payment.
/// - `"self-billed"`: a self-billed invoice (389), issued by the buyer (the
///   sender of the document) for a supply of the seller (its recipient).
#let named-types = (
  invoice: "380",
  credit-note: "381",
  corrected: "384",
  prepayment: "386",
  self-billed: "389",
)

// The codes of UNTDID 1001 that EN 16931 (BR-CL-01) and every Factur-X
// profile accept for BT-3, by the kind of document they are:
// - "invoice", "corrected", "prepayment": the buyer pays the seller,
// - "credit-note": the amounts are credited to the buyer,
// - "self-billed": the buyer issues the invoice for the seller,
// - "self-billed-credit-note": the buyer issues a credit note for the seller.
#let _kinds = (
  "71": "invoice",
  "80": "invoice",
  "81": "credit-note",
  "82": "invoice",
  "83": "credit-note",
  "84": "invoice",
  "102": "invoice",
  "130": "invoice",
  "202": "invoice",
  "203": "invoice",
  "204": "invoice",
  "211": "invoice",
  "218": "invoice",
  "219": "invoice",
  "261": "self-billed-credit-note",
  "262": "credit-note",
  "295": "invoice",
  "296": "credit-note",
  "308": "credit-note",
  "325": "invoice",
  "326": "invoice",
  "331": "invoice",
  "380": "invoice",
  "381": "credit-note",
  "382": "invoice",
  "383": "invoice",
  "384": "corrected",
  "385": "invoice",
  "386": "prepayment",
  "387": "invoice",
  "388": "invoice",
  "389": "self-billed",
  "390": "invoice",
  "393": "invoice",
  "394": "invoice",
  "395": "invoice",
  "396": "credit-note",
  "420": "credit-note",
  "456": "invoice",
  "457": "invoice",
  "458": "credit-note",
  "527": "self-billed",
  "532": "credit-note",
  "553": "invoice",
  "575": "invoice",
  "623": "invoice",
  "633": "invoice",
  "751": "invoice",
  "780": "invoice",
  "817": "invoice",
  "870": "invoice",
  "875": "invoice",
  "876": "invoice",
  "877": "invoice",
  "935": "invoice",
)

/// Resolves the `document-type` of an invoice: `auto` (an invoice), one of
/// the `named-types`, or a UNTDID 1001 code (e.g. `"326"` for a partial
/// invoice, also as integer). Panics for any other value.
///
/// Returns a dictionary with
/// - `input`: the value as given (`auto` if not given),
/// - `name`: the name of a named type, else `none`,
/// - `code`: the UNTDID 1001 code (BT-3),
/// - `title`: the key of the default title in `strings.document`,
/// - `credit`: whether the amounts are credited to the buyer (credit notes),
/// - `self-billed`: whether the buyer issues the document, i.e. the sender
///   of the document is the buyer and its recipient the seller,
/// - `sender-pays`: whether the sender of the document pays the amount to
///   its recipient (credit notes and self-billed invoices),
/// - `prepayment`: whether it is a prepayment invoice (386), which asks for
///   an advance payment before the supply.
///
/// -> dictionary
#let resolve-document-type(value) = {
  let code = if value == auto { "380" } else if type(value) == int {
    str(value)
  } else if type(value) == str {
    named-types.at(value, default: value.trim())
  } else { none }
  if code == none or code not in _kinds {
    panic(
      "invoice::document-type must be one of "
        + named-types.keys().map(key => "\"" + key + "\"").join(", ")
        + " or a UNTDID 1001 code of an invoice or credit note (e.g. \"326\" for a partial invoice), got "
        + repr(value)
        + ".",
    )
  }
  let kind = _kinds.at(code)
  let name = none
  for (key, named) in named-types {
    if named == code { name = key }
  }
  let credit = kind in ("credit-note", "self-billed-credit-note")
  let self-billed = kind in ("self-billed", "self-billed-credit-note")
  (
    input: value,
    name: name,
    code: code,
    title: if kind == "self-billed-credit-note" { "credit-note" } else {
      kind
    },
    credit: credit,
    self-billed: self-billed,
    sender-pays: credit != self-billed,
    prepayment: kind == "prepayment",
  )
}

/// Whether the sender of the document pays the amount to its recipient: a
/// credit note refunds the buyer, and the buyer issues a self-billed invoice
/// to pay the seller. `document` is the resolved `document-type` of the
/// context (`none` for an invoice).
///
/// -> bool
#let sender-pays(document) = (
  type(document) == dictionary and document.at("sender-pays", default: false)
)

/// The default title of a document in the language of `strings` (the
/// language strings of the locale): the title of its type, or the title of
/// an invoice if the language has none for it.
///
/// -> str | content
#let document-title(document, strings) = {
  let titles = strings.at("document", default: (:))
  let key = if type(document) == dictionary { document.title } else {
    "invoice"
  }
  titles.at(key, default: titles.at("invoice", default: "Invoice"))
}
