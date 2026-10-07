// The service period of an invoice: the date or period of the supply, which
// the invoice prints (`references.service-time`) and the e-invoice states
// (the actual delivery date, BT-72, or the invoicing period, BG-14). One
// function resolves it for both, so they cannot differ.

/// Resolves the service period of an invoice:
///
/// 1. the invoice's `service-period` (a `datetime` or a range
///    `(datetime, datetime)`) if it is given,
/// 2. else from the earliest to the latest date of the items (`date` of
///    `item`, `bundle` and `group`, a date or a range); items without a date
///    do not count,
/// 3. else the invoice date, if no item has a date.
///
/// Returns `(start: .., end: .., source: ..)`, with `source` one of
/// `"invoice"`, `"items"` and `"invoice-date"`, or `none` if there is no date
/// at all. A single date has the same `start` and `end`.
///
/// -> none | dictionary
#let resolve-service-period(
  /// The computed items of the line items (each with its `date`).
  /// -> array
  items,
  /// The date of the invoice.
  /// -> datetime | any
  invoice-date,
  /// The invoice's `service-period`.
  /// -> none | datetime | array
  service-period: none,
) = {
  if type(service-period) == datetime {
    return (start: service-period, end: service-period, source: "invoice")
  }
  if type(service-period) == array and service-period.len() == 2 {
    let (start, end) = service-period
    return (start: start, end: end, source: "invoice")
  }

  let start = none
  let end = none
  for item in items {
    let date = if type(item) == dictionary { item.at("date", default: none) }
    let dates = if type(date) == datetime { (date,) } else if (
      type(date) == array
    ) { date } else { () }
    for d in dates {
      if type(d) != datetime { continue }
      if start == none or d < start { start = d }
      if end == none or d > end { end = d }
    }
  }
  if start != none {
    return (start: start, end: end, source: "items")
  }
  if type(invoice-date) == datetime {
    return (start: invoice-date, end: invoice-date, source: "invoice-date")
  }
  none
}

/// Whether the date of a document (the resolved `document-type` of the
/// context, `none` for an invoice) is the date of its supply when nothing
/// else dates it: not for a credit note, which amends an invoice, nor for a
/// prepayment invoice, which precedes the supply.
///
/// -> bool
#let supply-dated(document) = (
  type(document) != dictionary
    or not (
      document.at("credit", default: false)
        or document.at("prepayment", default: false)
    )
)

/// Resolves the service period of the invoice of the root context `ctx`
/// with its computed `items`, see `resolve-service-period`: the one source
/// of the printed service period (`references.service-time`) and the
/// e-invoice (BT-72, BG-14).
///
/// The date of a credit note (`document-type`, e.g. `"credit-note"`, 381),
/// which amends an invoice, and of a prepayment invoice (`"prepayment"`,
/// 386), which asks for an advance payment before the supply, is not the
/// date of a supply: they fall back to no date at all rather than to the
/// invoice date (see `supply-dated`). Their `service-period` and the dates
/// of their items still count.
///
/// -> none | dictionary
#let service-period-of(ctx, items) = {
  let document = ctx.at("document-type", default: none)
  resolve-service-period(
    items,
    if supply-dated(document) { ctx.at("invoice-date", default: none) },
    service-period: ctx.at("service-period", default: none),
  )
}

/// The printed text of a service period: its date, or its first and last
/// date joined by " – ", each formatted with `format-date` (the date format
/// of the locale).
///
/// -> str | content | none
#let format-service-period(period, format-date) = {
  if period == none { return none }
  if period.start == period.end { return format-date(period.start) }
  format-date(period.start) + " – " + format-date(period.end)
}
