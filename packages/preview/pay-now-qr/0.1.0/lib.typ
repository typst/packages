#let _plugin = plugin("paynowqr.wasm")

/// Build an EMVCo-compliant PayNow payload string.
///
/// Pass the returned string to any QR renderer (e.g. `@preview/rustycure`'s `qr-code`).
///
/// - amount (int, float): transaction amount (>= 0). Always emitted with 2 decimals.
/// - editable (bool): whether the payer may edit the amount.
/// - reference (str): bill / order code shown to the payer; empty to omit.
/// - expiry (datetime): QR expiry date. Encoded as YYYYMMDD.
/// - company (str): merchant name.
/// - uen (str, none): company UEN. Mutually exclusive with `mobile`.
/// - mobile (str, none): mobile proxy (e.g. "+6591234567"). Mutually exclusive with `uen`.
/// - merchant-country (str): ISO 3166-1 alpha-2. Defaults to "SG".
/// - merchant-city (str): merchant city. Defaults to "Singapore".
#let paynow-payload(
  amount: 0,
  editable: false,
  reference: "",
  expiry: none,
  company: "",
  uen: none,
  mobile: none,
  merchant-country: "SG",
  merchant-city: "Singapore",
) = {
  assert(type(amount) in (int, float), message: "amount must be int or float")
  assert(amount >= 0, message: "amount must be >= 0")
  assert(type(editable) == bool, message: "editable must be a bool")
  assert(type(reference) == str, message: "reference must be a str")
  assert(type(company) == str and company != "", message: "company must be a non-empty str")
  assert(
    type(merchant-country) == str and merchant-country != "",
    message: "merchant-country must be a non-empty str",
  )
  assert(
    type(merchant-city) == str and merchant-city != "",
    message: "merchant-city must be a non-empty str",
  )
  assert(uen != none or mobile != none, message: "either uen or mobile must be provided")
  assert(
    uen == none or mobile == none,
    message: "provide uen OR mobile, not both",
  )
  assert(type(expiry) == datetime, message: "expiry must be a datetime")

  let (proxy-type, proxy-value) = if uen != none {
    ("2", str(uen))
  } else {
    ("0", str(mobile))
  }

  let result = _plugin.payload(
    bytes(str(amount)),
    bytes(if editable { "1" } else { "0" }),
    bytes(reference),
    bytes(expiry.display("[year][month][day]")),
    bytes(company),
    bytes(proxy-type),
    bytes(proxy-value),
    bytes(merchant-country),
    bytes(merchant-city),
  )
  str(result)
}
