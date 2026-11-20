// Offline snapshot of the CoworkingView Price Index.
// Figures live in data/price-index.json. The index is CC BY 4.0.
// Keep attribution() with any figure you republish.

#let _data = json("data/price-index.json")
#let _separators = regex("[\\s_-]+")
#let _product-rank = (
  flex_desk: 0,
  fix_desk: 1,
  private_office: 2,
  day_pass: 3,
  meeting_room: 4,
)
#let _product-label = (
  flex_desk: "Flex desk",
  fix_desk: "Fixed desk",
  private_office: "Private office",
  day_pass: "Day pass",
  meeting_room: "Meeting room",
)

#let _norm-city(value) = {
  if value == none {
    none
  } else {
    lower(str(value).trim()).replace(_separators, " ")
  }
}

#let _norm-product(value) = {
  lower(str(value).trim()).replace(_separators, "_")
}

#let _same-city(row, city) = {
  let key = _norm-city(city)
  key == _norm-city(row.city_slug) or key == _norm-city(row.city_name)
}

#let _num(value) = {
  if value == none {
    "—"
  } else if value == calc.trunc(value) {
    str(int(value))
  } else {
    str(value)
  }
}

#let _amount(row) = {
  let with-currency = if row.currency == none {
    _num(row.median)
  } else {
    _num(row.median) + " " + row.currency
  }
  if row.unit == none {
    with-currency
  } else {
    with-currency + "/" + row.unit
  }
}

#let _select(city, product, products) = {
  let by-city = if city == none {
    _data.rates
  } else {
    _data.rates.filter(row => _same-city(row, city))
  }
  let by-product = if product == none {
    by-city
  } else {
    let key = _norm-product(product)
    by-city.filter(row => _norm-product(row.product) == key)
  }
  if products == none {
    by-product
  } else {
    let keys = products.map(item => _norm-product(item))
    by-product.filter(row => keys.contains(_norm-product(row.product)))
  }
}

#let _credit = {
  text(size: 8pt, _data.attribution)
}

/// The CC BY 4.0 credit string from the recorded Price Index response.
///
/// The text is copied unchanged. Keep it with any figure you republish.
#let attribution() = {
  _data.attribution
}

/// Cities in the snapshot, in the recorded order.
///
/// Each dictionary uses the columns of the open cities table, including
/// `published`. The unpublished fixture row `example-town` is included and its
/// price fields are `none`. Entry prices are Price Index figures, so keep
/// `attribution()` with them.
#let cities() = {
  _data.cities
}

/// The Price Index row for `city` and `product`, or `none` when it is absent.
///
/// `city` is a slug (`berlin`) or a display name (`Abu Dhabi`). Comparison
/// ignores case and treats spaces, hyphens and underscores as the same
/// separator. `product` is a product code: `flex_desk`, `fix_desk`,
/// `private_office`, `day_pass` or `meeting_room`. The same separator rule
/// applies, so `flex desk` matches `flex_desk`.
///
/// The returned dictionary uses the columns of the open rates table. `median`
/// is the published median. `p25` and `p75` are `none` when the index did not
/// publish them. Keep `attribution()` with any figure you republish.
#let rate(city, product) = {
  let found = _select(city, product, none)
  if found.len() == 0 {
    none
  } else {
    found.first()
  }
}

/// A table of snapshot rows, with the CC BY 4.0 attribution under it.
///
/// `city` is a slug or display name. `none`, the default, includes every city
/// that has a rate row. `product` is one product code. `none` includes every
/// product. `products` is an array of product codes. `none` does not filter
/// further. When both `product` and `products` are set, a row must match both.
///
/// A filter that matches nothing still prints the attribution line.
#let rates-table(
  city: none,
  product: none,
  products: none,
) = {
  let rows = _select(city, product, products).sorted(key: row => {
    let rank = _product-rank.at(row.product, default: 99)
    lower(row.city_name) + "-" + str(rank)
  })
  if rows.len() == 0 {
    [
      No matching rows in this snapshot.
      #v(0.6em)
      #_credit
    ]
  } else {
    let cells = rows
      .map(row => (
        row.city_name,
        _product-label.at(row.product, default: row.product),
        _amount(row),
        _num(row.p25),
        _num(row.p75),
        _num(row.sample_size),
        if row.low_confidence { "yes" } else { "no" },
      ))
      .flatten()
    [
      #set text(size: 9pt)
      #table(
        columns: (1.15fr, 1.25fr, 1.55fr, 0.75fr, 0.75fr, 0.7fr, 1.05fr),
        align: (left, left, right, right, right, right, center),
        inset: (x: 5pt, y: 4pt),
        table.header(
          [City],
          [Product],
          [Median],
          [P25],
          [P75],
          [Sample],
          [Low confidence],
        ),
        ..cells,
      )
      #v(0.6em)
      #_credit
    ]
  }
}
