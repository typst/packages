// Shared authoring helpers for DFG and general proposals.

/// Format an integer amount of cents as euros with two decimal places.
///
/// Uses a comma decimal separator for German output and a period otherwise.
/// The caller is responsible for providing an integer number of cents.
///
/// - cents (int): amount in cents
/// - de (bool): whether to use the German comma separator
/// -> str: formatted amount followed by the euro symbol
#let money(cents, de) = {
  let whole = str(int(calc.floor(cents / 100)))
  let digits = str(calc.rem(cents, 100))
  let fraction = if digits.len() == 1 { "0" + digits } else { digits }
  whole + (if de { "," } else { "." }) + fraction + " €"
}

/// Itemized budget with exact totals.
///
/// ```example
/// #proposal-budget((
///   (description: [Participant payments], unit-cost: 5000, quantity: 40),
///   (description: [Travel], unit-cost: 120000),
/// ))
/// ```
///
/// Each row shows quantity × unit cost, subtotal, and a final grand total. All
/// prices are nonnegative integer cents.
///
/// - items (array): records with `description` (str or content), `unit-cost`
///   (nonnegative int cents), and optional `quantity` (positive int, default 1)
/// - language (str): `"english"` (default) or `"german"`; controls labels and
///   decimal separator
/// - total-label (content, str, none): final total label; `none` uses `"Total"`
///   or `"Summe"`
#let proposal-budget(items, language: "english", total-label: none) = {
  assert(type(items) == array, message: "Budget items must be an array of records.")
  assert(language in ("english", "german"), message: "Budget language must be english or german.")
  let de = language == "german"
  let rows = ()
  let total = 0
  for item in items {
    assert(type(item) == dictionary, message: "Each budget item must be a record.")
    assert("description" in item and (type(item.description) == str or type(item.description) == content),
      message: "Each budget item needs a string or content `description`.")
    assert("unit-cost" in item, message: "Each budget item needs `unit-cost` in integer cents.")
    let cost = item.unit-cost
    let quantity = item.at("quantity", default: 1)
    assert(type(cost) == int and cost >= 0, message: "unit-cost must be nonnegative integer cents.")
    assert(type(quantity) == int and quantity > 0, message: "quantity must be a positive integer.")
    let subtotal = cost * quantity
    total += subtotal
    rows += (item.description, [#quantity × #money(cost, de)], [#money(subtotal, de)])
  }
  table(
    columns: (1fr, auto, auto), align: (left, right, right),
    stroke: none, inset: (x: 0pt, y: 4pt), column-gutter: 12pt,
    table.header(
      [*#if de [Position] else [Item]*],
      [*#if de [Anzahl × Einzelpreis] else [Quantity × unit cost]*],
      [*#if de [Betrag] else [Amount]*],
    ),
    ..rows,
    table.hline(stroke: 0.5pt),
    table.cell(colspan: 2)[*#if total-label != none { total-label } else if de [Summe] else [Total]*],
    [*#money(total, de)*],
  )
}
